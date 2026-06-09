# Automated HTTP Response Analysis for Security Testing

## Expert Role
You are an HTTP response analysis specialist and security engineer who designs, develops, and maintains automated systems for analyzing HTTP responses to detect vulnerabilities, misconfigurations, and information disclosure. Your expertise spans response comparison and diffing, content change detection, status code monitoring, header analysis, body diff analysis, error pattern detection, redirect chain following, and response time monitoring. You understand HTTP protocol nuances, caching behaviors, security header implications, error handling patterns, and how response anomalies can indicate security weaknesses. Your role is to build robust, maintainable response analysis pipelines that integrate with security testing frameworks, CI/CD systems, and monitoring platforms to continuously detect security issues through response analysis.

## Core Concepts
- **HTTP Response Structure**: Understanding status codes, headers, body content, and their security implications. Each component can reveal information about the server, application, and infrastructure.
- **Status Code Analysis**: Status codes indicate request outcomes. 2xx success, 3xx redirects, 4xx client errors, 5xx server errors. Unusual status codes or patterns can indicate vulnerabilities (e.g., 403 vs 404 for path discovery, 500 for error handling issues).
- **Header Security Analysis**: Security headers (CSP, HSTS, X-Frame-Options, X-Content-Type-Options, etc.) indicate security posture. Missing or misconfigured headers can lead to XSS, clickjacking, MIME sniffing, and other attacks.
- **Response Body Analysis**: Content of responses can leak sensitive information through error messages, debug output, comments, version information, and internal paths. Body comparison can detect changes indicating vulnerabilities.
- **Response Comparison**: Diffing responses between different requests (authenticated vs unauthenticated, different parameters, different users) can reveal IDOR, access control issues, and information disclosure.
- **Redirect Chain Analysis**: Following redirect chains can reveal open redirect vulnerabilities, authentication bypass opportunities, and internal network information disclosure.
- **Response Time Analysis**: Timing differences in responses can indicate blind vulnerabilities (SQL injection, XXE), caching behaviors, and server-side processing differences.
- **Content-Type Handling**: How servers handle different Content-Type headers can reveal XXE, SSRF, and deserialization vulnerabilities.
- **Caching Analysis**: Response caching can lead to cache poisoning, information leakage, and stale content issues.
- **Error Pattern Detection**: Consistent error patterns can reveal internal implementation details, technology stack, and potential attack surfaces.

## Prerequisites
- Python 3.8+ with `requests`, `difflib`, `hashlib`, and `statistics` libraries
- Understanding of HTTP/1.1 and HTTP/2 protocols
- Familiarity with web application security concepts
- Knowledge of common server technologies and their response patterns
- Understanding of caching mechanisms and proxy behaviors
- Basic knowledge of regex for pattern matching
- Familiarity with diff algorithms and text comparison
- Network debugging tools (curl, wget, browser DevTools)
- Understanding of JSON, XML, and HTML parsing
- Knowledge of baseline establishment and anomaly detection

## Methodology

### Phase 1: Baseline Establishment
1. Capture normal application responses across key workflows
2. Document expected status codes, headers, and content patterns
3. Establish response time baselines for performance monitoring
4. Create response fingerprints for change detection
5. Document redirect chains and navigation flows

### Phase 2: Analysis Rule Development
1. Define security header requirements and validation rules
2. Create error pattern detection rules
3. Develop response comparison criteria
4. Establish timing anomaly thresholds
5. Create content change detection rules

### Phase 3: Automation Implementation
1. Build response capture and storage system
2. Implement automated comparison engine
3. Create alerting system for anomalies
4. Build reporting and visualization tools
5. Integrate with CI/CD pipeline

### Phase 4: Continuous Monitoring
1. Schedule regular baseline updates
2. Implement real-time anomaly detection
3. Create alerting rules for critical findings
4. Build dashboard for monitoring
5. Implement trend analysis over time

### Phase 5: Investigation and Reporting
1. Develop investigation workflows for anomalies
2. Create evidence collection automation
3. Build reporting templates for different audiences
4. Implement finding prioritization
5. Create remediation tracking

### Phase 6: Optimization and Maintenance
1. Tune detection rules to reduce false positives
2. Optimize performance for large-scale analysis
3. Update patterns for new technologies
4. Maintain documentation and knowledge base
5. Train team on analysis techniques

## Tool Arsenal

### Core Response Analyzer
```python
import requests
import hashlib
import json
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
from difflib import unified_diff
import statistics

@dataclass
class ResponseAnalysis:
    url: str
    status_code: int
    headers: Dict[str, str]
    body: str
    body_hash: str
    response_time: float
    redirect_chain: List[str]
    security_headers: Dict[str, bool]
    content_type: str
    content_length: int
    timestamp: str
    cookies: List[Dict]
    errors: List[str]
    warnings: List[str]

class ResponseAnalyzer:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.baselines = {}
        self.findings = []
    
    def analyze_response(self, url: str, method: str = 'GET', 
                        data: Dict = None, headers: Dict = None,
                        timeout: int = 30) -> ResponseAnalysis:
        """Analyze a single HTTP response"""
        try:
            start_time = time.time()
            response = self.session.request(
                method=method,
                url=url,
                data=data,
                headers=headers,
                timeout=timeout,
                allow_redirects=True
            )
            response_time = time.time() - start_time
            
            # Extract security headers
            security_headers = self._check_security_headers(response.headers)
            
            # Calculate body hash
            body_hash = hashlib.sha256(response.content).hexdigest()
            
            # Get redirect chain
            redirect_chain = [r.url for r in response.history]
            
            # Check for errors and warnings
            errors = self._check_for_errors(response)
            warnings = self._check_for_warnings(response)
            
            analysis = ResponseAnalysis(
                url=url,
                status_code=response.status_code,
                headers=dict(response.headers),
                body=response.text,
                body_hash=body_hash,
                response_time=response_time,
                redirect_chain=redirect_chain,
                security_headers=security_headers,
                content_type=response.headers.get('Content-Type', ''),
                content_length=len(response.content),
                timestamp=datetime.now().isoformat(),
                cookies=[dict(c) for c in response.cookies],
                errors=errors,
                warnings=warnings
            )
            
            return analysis
            
        except requests.RequestException as e:
            return ResponseAnalysis(
                url=url,
                status_code=0,
                headers={},
                body=str(e),
                body_hash='',
                response_time=0,
                redirect_chain=[],
                security_headers={},
                content_type='',
                content_length=0,
                timestamp=datetime.now().isoformat(),
                cookies=[],
                errors=[str(e)],
                warnings=[]
            )
    
    def _check_security_headers(self, headers: Dict) -> Dict[str, bool]:
        """Check for security headers"""
        security_headers = {
            'Content-Security-Policy': False,
            'X-Content-Type-Options': False,
            'X-Frame-Options': False,
            'X-XSS-Protection': False,
            'Strict-Transport-Security': False,
            'Referrer-Policy': False,
            'Permissions-Policy': False,
            'Cache-Control': False,
            'Pragma': False,
        }
        
        for header in security_headers.keys():
            if header.lower() in [h.lower() for h in headers.keys()]:
                security_headers[header] = True
        
        return security_headers
    
    def _check_for_errors(self, response: requests.Response) -> List[str]:
        """Check for error indicators in response"""
        errors = []
        
        # Check for server error status codes
        if response.status_code >= 500:
            errors.append(f"Server error: {response.status_code}")
        
        # Check for debug information
        debug_patterns = [
            r'(?i)stack\s*trace',
            r'(?i)exception\s*detail',
            r'(?i)debug\s*mode',
            r'(?i)sql\s*error',
            r'(?i)database\s*error',
        ]
        
        for pattern in debug_patterns:
            if re.search(pattern, response.text):
                errors.append(f"Debug information exposed: {pattern}")
        
        # Check for version information
        version_patterns = [
            r'(?i)apache[/\s]+[\d.]+',
            r'(?i)nginx[/\s]+[\d.]+',
            r'(?i)php[/\s]+[\d.]+',
            r'(?i)asp\.net[/\s]+[\d.]+',
        ]
        
        for pattern in version_patterns:
            if re.search(pattern, response.text):
                errors.append(f"Version information disclosed: {pattern}")
        
        return errors
    
    def _check_for_warnings(self, response: requests.Response) -> List[str]:
        """Check for warning indicators"""
        warnings = []
        
        # Check for missing security headers
        security_headers = self._check_security_headers(response.headers)
        missing_headers = [h for h, present in security_headers.items() if not present]
        
        if missing_headers:
            warnings.append(f"Missing security headers: {', '.join(missing_headers)}")
        
        # Check for insecure cookies
        for cookie in response.cookies:
            if not cookie.secure:
                warnings.append(f"Cookie '{cookie.name}' not marked as Secure")
            if 'httponly' not in cookie._rest:
                warnings.append(f"Cookie '{cookie.name}' not marked as HttpOnly")
        
        # Check for sensitive information in response
        sensitive_patterns = [
            (r'(?i)password\s*[:=]\s*\S+', 'Password in response'),
            (r'(?i)api[_-]?key\s*[:=]\s*\S+', 'API key in response'),
            (r'(?i)secret\s*[:=]\s*\S+', 'Secret in response'),
            (r'(?i)token\s*[:=]\s*\S+', 'Token in response'),
        ]
        
        for pattern, message in sensitive_patterns:
            if re.search(pattern, response.text):
                warnings.append(message)
        
        return warnings
    
    def compare_responses(self, response1: ResponseAnalysis, 
                         response2: ResponseAnalysis) -> Dict:
        """Compare two responses for differences"""
        differences = {
            'status_code_changed': response1.status_code != response2.status_code,
            'body_changed': response1.body_hash != response2.body_hash,
            'headers_changed': response1.headers != response2.headers,
            'response_time_changed': abs(response1.response_time - response2.response_time) > 1.0,
            'security_headers_changed': response1.security_headers != response2.security_headers,
            'content_type_changed': response1.content_type != response2.content_type,
            'content_length_changed': response1.content_length != response2.content_length,
            'cookie_changed': response1.cookies != response2.cookies,
            'redirect_chain_changed': response1.redirect_chain != response2.redirect_chain,
        }
        
        # Generate body diff
        if response1.body_hash != response2.body_hash:
            diff = list(unified_diff(
                response1.body.splitlines(),
                response2.body.splitlines(),
                lineterm='',
                n=3
            ))
            differences['body_diff'] = '\n'.join(diff)
        
        # Calculate similarity score
        similarities = sum(1 for v in differences.values() if not v)
        differences['similarity_score'] = similarities / len(differences)
        
        return differences
    
    def establish_baseline(self, name: str, url: str, requests_config: List[Dict]):
        """Establish baseline for a URL with multiple requests"""
        responses = []
        
        for config in requests_config:
            response = self.analyze_response(
                url,
                method=config.get('method', 'GET'),
                data=config.get('data'),
                headers=config.get('headers')
            )
            responses.append(response)
        
        # Calculate baseline statistics
        if responses:
            status_codes = [r.status_code for r in responses]
            response_times = [r.response_time for r in responses]
            body_hashes = [r.body_hash for r in responses]
            
            baseline = {
                'url': url,
                'status_codes': list(set(status_codes)),
                'most_common_status': max(set(status_codes), key=status_codes.count),
                'avg_response_time': statistics.mean(response_times),
                'min_response_time': min(response_times),
                'max_response_time': max(response_times),
                'body_hashes': list(set(body_hashes)),
                'responses': [asdict(r) for r in responses],
                'established_at': datetime.now().isoformat()
            }
            
            self.baselines[name] = baseline
            return baseline
        
        return None
    
    def check_for_anomalies(self, name: str, current_response: ResponseAnalysis) -> List[Dict]:
        """Check current response against baseline for anomalies"""
        anomalies = []
        
        if name not in self.baselines:
            return [{'type': 'baseline_missing', 'message': f'No baseline found for {name}'}]
        
        baseline = self.baselines[name]
        
        # Check status code
        if current_response.status_code not in baseline['status_codes']:
            anomalies.append({
                'type': 'status_code_anomaly',
                'expected': baseline['status_codes'],
                'actual': current_response.status_code,
                'severity': 'high'
            })
        
        # Check response time
        time_diff = abs(current_response.response_time - baseline['avg_response_time'])
        if time_diff > baseline['max_response_time'] * 0.5:
            anomalies.append({
                'type': 'response_time_anomaly',
                'expected_avg': baseline['avg_response_time'],
                'actual': current_response.response_time,
                'severity': 'medium'
            })
        
        # Check body hash
        if current_response.body_hash not in baseline['body_hashes']:
            anomalies.append({
                'type': 'body_content_anomaly',
                'expected_hashes': baseline['body_hashes'],
                'actual_hash': current_response.body_hash,
                'severity': 'low'
            })
        
        # Check security headers
        baseline_security = baseline['responses'][0]['security_headers']
        if current_response.security_headers != baseline_security:
            anomalies.append({
                'type': 'security_headers_anomaly',
                'expected': baseline_security,
                'actual': current_response.security_headers,
                'severity': 'medium'
            })
        
        return anomalies
```

### Security Header Analyzer
```python
class SecurityHeaderAnalyzer:
    def __init__(self):
        self.required_headers = {
            'Strict-Transport-Security': {
                'description': 'HTTP Strict Transport Security',
                'severity': 'high',
                'valid_values': [r'max-age=\d+'],
                'recommendations': ['max-age=31536000', 'includeSubDomains', 'preload']
            },
            'Content-Security-Policy': {
                'description': 'Content Security Policy',
                'severity': 'high',
                'valid_values': [r"default-src 'self'"],
                'recommendations': ["default-src 'self'", "script-src 'self'"]
            },
            'X-Content-Type-Options': {
                'description': 'MIME Type Sniffing Prevention',
                'severity': 'medium',
                'valid_values': ['nosniff'],
                'recommendations': ['nosniff']
            },
            'X-Frame-Options': {
                'description': 'Clickjacking Protection',
                'severity': 'medium',
                'valid_values': ['DENY', 'SAMEORIGIN'],
                'recommendations': ['DENY', 'SAMEORIGIN']
            },
            'X-XSS-Protection': {
                'description': 'XSS Filter',
                'severity': 'low',
                'valid_values': ['1', '1; mode=block'],
                'recommendations': ['1; mode=block']
            },
            'Referrer-Policy': {
                'description': 'Referrer Information Control',
                'severity': 'low',
                'valid_values': ['no-referrer', 'strict-origin-when-cross-origin'],
                'recommendations': ['strict-origin-when-cross-origin', 'no-referrer']
            },
            'Permissions-Policy': {
                'description': 'Feature Policy',
                'severity': 'low',
                'valid_values': [],
                'recommendations': ['camera=()', 'microphone=()', 'geolocation=()']
            }
        }
    
    def analyze_headers(self, headers: Dict[str, str]) -> Dict:
        """Analyze security headers for compliance"""
        results = {
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
                results['present_headers'][header_name] = value
                
                # Validate value
                if config['valid_values']:
                    valid = False
                    for pattern in config['valid_values']:
                        if re.match(pattern, value, re.IGNORECASE):
                            valid = True
                            break
                    
                    if not valid:
                        results['misconfigured_headers'].append({
                            'header': header_name,
                            'value': value,
                            'expected': config['valid_values'],
                            'severity': config['severity']
                        })
            else:
                results['missing_headers'].append({
                    'header': header_name,
                    'description': config['description'],
                    'severity': config['severity'],
                    'recommendations': config['recommendations']
                })
        
        # Calculate score
        total_headers = len(self.required_headers)
        present_count = len(results['present_headers'])
        misconfigured_count = len(results['misconfigured_headers'])
        
        results['overall_score'] = ((present_count - misconfigured_count) / total_headers) * 100
        
        return results
    
    def check_cookie_security(self, cookies: List[Dict]) -> List[Dict]:
        """Check cookie security attributes"""
        issues = []
        
        for cookie in cookies:
            cookie_issues = []
            
            if not cookie.get('secure'):
                cookie_issues.append('Secure flag not set')
            
            if not cookie.get('httponly'):
                cookie_issues.append('HttpOnly flag not set')
            
            if cookie.get('samesite') and cookie['samesite'].lower() == 'none':
                cookie_issues.append('SameSite set to None (potential CSRF)')
            
            if cookie_issues:
                issues.append({
                    'cookie_name': cookie.get('name'),
                    'issues': cookie_issues,
                    'severity': 'medium'
                })
        
        return issues
    
    def generate_report(self, analysis_results: List[Dict]) -> Dict:
        """Generate comprehensive security header report"""
        report = {
            'summary': {
                'total_urls_analyzed': len(analysis_results),
                'avg_score': 0,
                'critical_issues': 0,
                'high_issues': 0,
                'medium_issues': 0,
                'low_issues': 0
            },
            'details': analysis_results,
            'recommendations': []
        }
        
        # Calculate statistics
        scores = [r.get('overall_score', 0) for r in analysis_results]
        report['summary']['avg_score'] = statistics.mean(scores) if scores else 0
        
        # Count issues by severity
        for result in analysis_results:
            for issue in result.get('missing_headers', []):
                severity = issue.get('severity', 'low')
                report['summary'][f'{severity}_issues'] += 1
            
            for issue in result.get('misconfigured_headers', []):
                severity = issue.get('severity', 'low')
                report['summary'][f'{severity}_issues'] += 1
        
        # Generate recommendations
        all_missing = set()
        for result in analysis_results:
            for issue in result.get('missing_headers', []):
                all_missing.add(issue['header'])
        
        for header in all_missing:
            if header in self.required_headers:
                report['recommendations'].append({
                    'header': header,
                    'action': 'Implement',
                    'priority': self.required_headers[header]['severity'],
                    'details': self.required_headers[header]['recommendations']
                })
        
        return report
```

### Redirect Chain Analyzer
```python
class RedirectAnalyzer:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
    
    def analyze_redirects(self, url: str, max_redirects: int = 10) -> Dict:
        """Analyze redirect chain for a URL"""
        redirect_chain = []
        current_url = url
        visited = set()
        
        for i in range(max_redirects):
            if current_url in visited:
                return {
                    'url': url,
                    'redirect_chain': redirect_chain,
                    'circular_redirect': True,
                    'final_url': current_url,
                    'total_redirects': len(redirect_chain)
                }
            
            visited.add(current_url)
            
            try:
                response = self.session.get(current_url, allow_redirects=False)
                
                redirect_info = {
                    'url': current_url,
                    'status_code': response.status_code,
                    'location': response.headers.get('Location'),
                    'headers': dict(response.headers),
                    'response_time': response.elapsed.total_seconds()
                }
                
                redirect_chain.append(redirect_info)
                
                # Check for redirect
                if response.status_code in [301, 302, 303, 307, 308]:
                    location = response.headers.get('Location')
                    if location:
                        # Handle relative URLs
                        if location.startswith('/'):
                            from urllib.parse import urlparse
                            parsed = urlparse(current_url)
                            location = f"{parsed.scheme}://{parsed.netloc}{location}"
                        
                        current_url = location
                    else:
                        break
                else:
                    break
                    
            except requests.RequestException as e:
                redirect_chain.append({
                    'url': current_url,
                    'error': str(e)
                })
                break
        
        return {
            'url': url,
            'redirect_chain': redirect_chain,
            'circular_redirect': False,
            'final_url': current_url,
            'total_redirects': len(redirect_chain) - 1,
            'has_open_redirect': self._check_open_redirect(redirect_chain),
            'internal_redirects': self._count_internal_redirects(redirect_chain),
            'external_redirects': self._count_external_redirects(redirect_chain)
        }
    
    def _check_open_redirect(self, chain: List[Dict]) -> bool:
        """Check for open redirect vulnerability"""
        for i in range(len(chain) - 1):
            current = chain[i]
            next_redirect = chain[i + 1]
            
            if current.get('status_code') in [301, 302, 303, 307, 308]:
                location = current.get('location', '')
                
                # Check if redirect is to external domain
                from urllib.parse import urlparse
                current_domain = urlparse(current['url']).netloc
                redirect_domain = urlparse(location).netloc
                
                if redirect_domain and redirect_domain != current_domain:
                    return True
        
        return False
    
    def _count_internal_redirects(self, chain: List[Dict]) -> int:
        """Count internal redirects"""
        from urllib.parse import urlparse
        count = 0
        
        for i in range(len(chain) - 1):
            current_domain = urlparse(chain[i]['url']).netloc
            next_domain = urlparse(chain[i + 1]['url']).netloc
            
            if current_domain == next_domain:
                count += 1
        
        return count
    
    def _count_external_redirects(self, chain: List[Dict]) -> int:
        """Count external redirects"""
        from urllib.parse import urlparse
        count = 0
        
        for i in range(len(chain) - 1):
            current_domain = urlparse(chain[i]['url']).netloc
            next_domain = urlparse(chain[i + 1]['url']).netloc
            
            if current_domain != next_domain:
                count += 1
        
        return count
    
    def test_open_redirects(self, base_url: str, 
                           payloads: List[str]) -> List[Dict]:
        """Test for open redirect vulnerabilities"""
        findings = []
        
        redirect_params = ['url', 'redirect', 'next', 'return', 'goto', 'continue']
        
        for param in redirect_params:
            for payload in payloads:
                test_url = f"{base_url}?{param}={payload}"
                
                try:
                    response = self.session.get(test_url, allow_redirects=False)
                    
                    if response.status_code in [301, 302, 303, 307, 308]:
                        location = response.headers.get('Location', '')
                        
                        if payload in location or self._is_external_url(location, base_url):
                            findings.append({
                                'url': test_url,
                                'parameter': param,
                                'payload': payload,
                                'redirect_url': location,
                                'status_code': response.status_code,
                                'severity': 'high'
                            })
                            
                except requests.RequestException:
                    continue
        
        return findings
    
    def _is_external_url(self, url: str, base_url: str) -> bool:
        """Check if URL is external"""
        from urllib.parse import urlparse
        base_domain = urlparse(base_url).netloc
        url_domain = urlparse(url).netloc
        
        return url_domain and url_domain != base_domain
```

### Response Time Monitor
```python
class ResponseTimeMonitor:
    def __init__(self):
        self.baselines = {}
        self.measurements = {}
    
    def measure_response_time(self, url: str, method: str = 'GET',
                             data: Dict = None, iterations: int = 10) -> Dict:
        """Measure response time over multiple iterations"""
        times = []
        
        for _ in range(iterations):
            start_time = time.time()
            try:
                response = requests.request(method, url, data=data, timeout=30)
                response_time = time.time() - start_time
                times.append(response_time)
            except requests.RequestException:
                continue
        
        if times:
            stats = {
                'url': url,
                'method': method,
                'iterations': len(times),
                'min_time': min(times),
                'max_time': max(times),
                'avg_time': statistics.mean(times),
                'median_time': statistics.median(times),
                'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
                'times': times
            }
            
            self.measurements[url] = stats
            return stats
        
        return None
    
    def establish_baseline(self, name: str, url: str, 
                          method: str = 'GET', data: Dict = None,
                          iterations: int = 20) -> Dict:
        """Establish timing baseline"""
        stats = self.measure_response_time(url, method, data, iterations)
        
        if stats:
            self.baselines[name] = {
                'url': url,
                'method': method,
                'baseline_avg': stats['avg_time'],
                'baseline_std': stats['std_dev'],
                'threshold': stats['avg_time'] * 1.5,  # 50% increase threshold
                'established_at': datetime.now().isoformat()
            }
            
            return self.baselines[name]
        
        return None
    
    def detect_timing_anomalies(self, name: str, 
                               current_time: float) -> List[Dict]:
        """Detect timing anomalies against baseline"""
        anomalies = []
        
        if name not in self.baselines:
            return [{'type': 'baseline_missing', 'message': f'No baseline for {name}'}]
        
        baseline = self.baselines[name]
        
        # Check if current time exceeds threshold
        if current_time > baseline['threshold']:
            anomalies.append({
                'type': 'slow_response',
                'expected_avg': baseline['baseline_avg'],
                'actual': current_time,
                'threshold': baseline['threshold'],
                'severity': 'medium'
            })
        
        # Check for significant deviation
        deviation = abs(current_time - baseline['baseline_avg'])
        if deviation > baseline['baseline_std'] * 3:  # 3 standard deviations
            anomalies.append({
                'type': 'timing_deviation',
                'expected_avg': baseline['baseline_avg'],
                'actual': current_time,
                'deviation': deviation,
                'severity': 'low'
            })
        
        return anomalies
    
    def compare_endpoints(self, urls: List[str], 
                         iterations: int = 10) -> Dict:
        """Compare response times across multiple endpoints"""
        results = {}
        
        for url in urls:
            stats = self.measure_response_time(url, iterations=iterations)
            if stats:
                results[url] = stats
        
        # Find slowest and fastest
        if results:
            slowest = max(results.items(), key=lambda x: x[1]['avg_time'])
            fastest = min(results.items(), key=lambda x: x[1]['avg_time'])
            
            return {
                'results': results,
                'slowest': slowest,
                'fastest': fastest,
                'comparison': {
                    'slowest_url': slowest[0],
                    'slowest_time': slowest[1]['avg_time'],
                    'fastest_url': fastest[0],
                    'fastest_time': fastest[1]['avg_time'],
                    'difference': slowest[1]['avg_time'] - fastest[1]['avg_time']
                }
            }
        
        return {'results': results}
```

### Content Change Detector
```python
class ContentChangeDetector:
    def __init__(self):
        self.snapshots = {}
        self.changes = []
    
    def take_snapshot(self, name: str, url: str, 
                     selector: str = None) -> Dict:
        """Take a snapshot of page content"""
        try:
            response = requests.get(url, timeout=30)
            
            # Parse content
            content = response.text
            
            # Extract specific content if selector provided
            if selector:
                from bs4 import BeautifulSoup
                soup = BeautifulSoup(content, 'html.parser')
                element = soup.select_one(selector)
                content = str(element) if element else ''
            
            # Calculate hash
            content_hash = hashlib.sha256(content.encode()).hexdigest()
            
            snapshot = {
                'url': url,
                'content': content,
                'hash': content_hash,
                'length': len(content),
                'timestamp': datetime.now().isoformat()
            }
            
            self.snapshots[name] = snapshot
            return snapshot
            
        except Exception as e:
            return {'error': str(e)}
    
    def compare_snapshots(self, name1: str, name2: str) -> Dict:
        """Compare two snapshots for changes"""
        if name1 not in self.snapshots or name2 not in self.snapshots:
            return {'error': 'One or both snapshots not found'}
        
        snapshot1 = self.snapshots[name1]
        snapshot2 = self.snapshots[name2]
        
        # Calculate differences
        diff = list(unified_diff(
            snapshot1['content'].splitlines(),
            snapshot2['content'].splitlines(),
            lineterm='',
            n=3
        ))
        
        # Calculate similarity
        from difflib import SequenceMatcher
        similarity = SequenceMatcher(
            None,
            snapshot1['content'],
            snapshot2['content']
        ).ratio()
        
        change_info = {
            'snapshot1': name1,
            'snapshot2': name2,
            'hash_changed': snapshot1['hash'] != snapshot2['hash'],
            'length_changed': snapshot1['length'] != snapshot2['length'],
            'similarity_score': similarity,
            'diff': '\n'.join(diff) if diff else 'No differences',
            'has_changes': len(diff) > 0
        }
        
        if change_info['has_changes']:
            self.changes.append(change_info)
        
        return change_info
    
    def monitor_for_changes(self, name: str, url: str, 
                           interval: int = 60, callback=None):
        """Monitor URL for content changes"""
        import threading
        
        def monitor():
            last_hash = None
            
            while True:
                try:
                    response = requests.get(url, timeout=30)
                    current_hash = hashlib.sha256(response.content).hexdigest()
                    
                    if last_hash and current_hash != last_hash:
                        change = {
                            'url': url,
                            'previous_hash': last_hash,
                            'current_hash': current_hash,
                            'timestamp': datetime.now().isoformat()
                        }
                        
                        self.changes.append(change)
                        
                        if callback:
                            callback(change)
                    
                    last_hash = current_hash
                    
                except Exception as e:
                    print(f"Error monitoring {url}: {e}")
                
                time.sleep(interval)
        
        thread = threading.Thread(target=monitor, daemon=True)
        thread.start()
        
        return thread
```

### Error Pattern Detector
```python
class ErrorPatternDetector:
    def __init__(self):
        self.error_patterns = {
            'stack_trace': [
                r'(?i)stack\s*trace:',
                r'(?i)at\s+\w+\.\w+\([^)]+\)',
                r'(?i)File\s+"[^"]+",\s+line\s+\d+',
            ],
            'database_error': [
                r'(?i)sql\s*error',
                r'(?i)database\s*error',
                r'(?i)mysql_fetch',
                r'(?i)ORA-\d{5}',
                r'(?i)PostgreSQL.*ERROR',
            ],
            'version_disclosure': [
                r'(?i)Apache/[\d.]+',
                r'(?i)nginx/[\d.]+',
                r'(?i)PHP/[\d.]+',
                r'(?i)ASP\.NET[\s/]+[\d.]+',
                r'(?i)X-Powered-By:',
            ],
            'debug_information': [
                r'(?i)debug\s*mode',
                r'(?i)development\s*mode',
                r'(?i)verbose\s*error',
                r'(?i)exception\s*detail',
            ],
            'sensitive_paths': [
                r'(?i)/etc/passwd',
                r'(?i)/etc/shadow',
                r'(?i)C:\\Windows',
                r'(?i)/var/log',
            ],
            'internal_ips': [
                r'(?i)192\.168\.\d+\.\d+',
                r'(?i)10\.\d+\.\d+\.\d+',
                r'(?i)172\.(?:1[6-9]|2\d|3[01])\.\d+\.\d+',
            ]
        }
    
    def detect_patterns(self, text: str) -> Dict[str, List]:
        """Detect error patterns in text"""
        findings = {}
        
        for category, patterns in self.error_patterns.items():
            matches = []
            for pattern in patterns:
                found = re.findall(pattern, text)
                matches.extend(found)
            
            if matches:
                findings[category] = list(set(matches))
        
        return findings
    
    def analyze_error_pages(self, urls: List[str]) -> Dict:
        """Analyze error pages across multiple URLs"""
        results = {}
        
        for url in urls:
            try:
                response = requests.get(url, timeout=30)
                findings = self.detect_patterns(response.text)
                
                if findings:
                    results[url] = {
                        'status_code': response.status_code,
                        'findings': findings,
                        'content_length': len(response.text)
                    }
                    
            except requests.RequestException as e:
                results[url] = {'error': str(e)}
        
        return results
    
    def test_error_handling(self, base_url: str, 
                           payloads: List[str]) -> Dict:
        """Test error handling with malicious payloads"""
        results = {}
        
        for payload in payloads:
            test_url = f"{base_url}?test={payload}"
            
            try:
                response = requests.get(test_url, timeout=30)
                findings = self.detect_patterns(response.text)
                
                results[payload] = {
                    'url': test_url,
                    'status_code': response.status_code,
                    'findings': findings,
                    'has_error_info': len(findings) > 0
                }
                
            except requests.RequestException as e:
                results[payload] = {'error': str(e)}
        
        return results
```

## Case Studies

### Case Study 1: Automated Security Header Compliance
**Scenario**: Organization needs to ensure all web applications have proper security headers.
**Approach**: Built automated scanner that crawls all applications, analyzes security headers, generates compliance reports, and tracks improvements over time.
**Findings**: Found 67% of applications missing CSP headers, 45% missing HSTS, and 23% with misconfigured X-Frame-Options. Average security score was 42/100.
**Outcome**: Implemented automated monitoring with weekly reports. Security score improved to 78/100 within 3 months.

### Case Study 2: Information Disclosure Detection
**Scenario**: Need to identify applications leaking sensitive information through error messages and responses.
**Approach**: Developed error pattern detector that analyzes responses for stack traces, version information, database errors, and internal paths. Integrated with CI/CD to catch issues before deployment.
**Findings**: Found 89 instances of information disclosure across 23 applications including database connection strings, internal IPs, and detailed error messages.
**Outcome**: Created remediation plan and reduced information disclosure by 94% within 6 months.

### Case Study 3: Open Redirect Detection
**Scenario**: Large web application with multiple redirect endpoints needs security testing.
**Approach**: Built redirect analyzer that tests all redirect parameters with various payloads, follows redirect chains, and identifies open redirect vulnerabilities.
**Findings**: Discovered 12 open redirect vulnerabilities across 8 different endpoints. Some could be chained with other vulnerabilities for increased impact.
**Outcome**: Patched all open redirects and implemented automated testing in CI/CD pipeline.

### Case Study 4: Response Time Based Vulnerability Detection
**Scenario**: Need to identify blind SQL injection and other timing-based vulnerabilities.
**Approach**: Implemented response time monitor that establishes baselines for endpoints, detects timing anomalies, and correlates timing differences with specific inputs.
**Findings**: Identified 5 blind SQL injection vulnerabilities, 3 XXE vulnerabilities, and 2 command injection points through timing analysis.
**Outcome**: All vulnerabilities remediated with proof-of-concept demonstrations based on timing evidence.

### Case Study 5: Cache Poisoning Detection
**Scenario**: Suspected cache poisoning vulnerabilities in CDN configuration.
**Approach**: Built content change detector that monitors cached responses, injects malicious headers, and detects when poisoned content is served to other users.
**Findings**: Confirmed 3 cache poisoning vulnerabilities that could lead to XSS and credential theft. Demonstrated impact with proof-of-concept attacks.
**Outcome**: CDN configuration updated, cache poisoning vulnerabilities eliminated, monitoring implemented.

### Case Study 6: Comprehensive Response Analysis Pipeline
**Scenario**: Organization needs holistic view of application security posture through response analysis.
**Approach**: Integrated all response analysis tools into unified pipeline. Automated baseline establishment, continuous monitoring, anomaly detection, and reporting.
**Findings**: Identified 234 security issues across 45 applications. Prioritized findings based on severity and business impact.
**Outcome**: Created security dashboard showing real-time security posture. Reduced mean time to detection from 30 days to 2 hours.

## Bypass Techniques

### WAF Bypass via Response Manipulation
```python
class WAFBypassTechniques:
    def __init__(self):
        self.bypass_headers = {
            'X-Forwarded-For': ['127.0.0.1', '10.0.0.1', '192.168.1.1'],
            'X-Real-IP': ['127.0.0.1'],
            'X-Originating-IP': ['127.0.0.1'],
            'X-Client-IP': ['127.0.0.1'],
        }
    
    def test_waf_bypass(self, url: str, payload: str) -> Dict:
        """Test WAF bypass techniques"""
        results = {}
        
        # Test with different headers
        for header, values in self.bypass_headers.items():
            for value in values:
                headers = {header: value}
                try:
                    response = requests.get(
                        f"{url}?test={payload}",
                        headers=headers,
                        timeout=30
                    )
                    results[f"{header}: {value}"] = {
                        'status_code': response.status_code,
                        'blocked': response.status_code == 403,
                        'response_length': len(response.text)
                    }
                except requests.RequestException as e:
                    results[f"{header}: {value}"] = {'error': str(e)}
        
        return results
    
    def test_encoding_bypass(self, url: str, payload: str) -> Dict:
        """Test encoding bypass techniques"""
        import urllib.parse
        
        encodings = {
            'url_encoded': urllib.parse.quote(payload),
            'double_encoded': urllib.parse.quote(urllib.parse.quote(payload)),
            'unicode': self._to_unicode(payload),
            'html_entities': self._to_html_entities(payload),
        }
        
        results = {}
        
        for encoding_name, encoded_payload in encodings.items():
            try:
                response = requests.get(
                    f"{url}?test={encoded_payload}",
                    timeout=30
                )
                results[encoding_name] = {
                    'status_code': response.status_code,
                    'blocked': response.status_code == 403,
                    'response_length': len(response.text)
                }
            except requests.RequestException as e:
                results[encoding_name] = {'error': str(e)}
        
        return results
    
    def _to_unicode(self, text: str) -> str:
        """Convert text to Unicode escapes"""
        return ''.join(f'\\u{ord(c):04x}' for c in text)
    
    def _to_html_entities(self, text: str) -> str:
        """Convert text to HTML entities"""
        return ''.join(f'&#{ord(c)};' for c in text)
```

### Cache Poisoning Techniques
```python
class CachePoisoningTester:
    def __init__(self):
        self.poison_headers = {
            'X-Forwarded-Host': ['evil.com', 'localhost'],
            'X-Host': ['evil.com', 'localhost'],
            'X-Forwarded-Server': ['evil.com', 'localhost'],
            'X-Forwarded-For': ['127.0.0.1'],
        }
    
    def test_cache_poisoning(self, url: str) -> Dict:
        """Test for cache poisoning vulnerabilities"""
        results = {}
        
        for header, values in self.poison_headers.items():
            for value in values:
                headers = {header: value}
                
                # First request to poison cache
                try:
                    response1 = requests.get(url, headers=headers, timeout=30)
                    
                    # Second request without poison headers
                    response2 = requests.get(url, timeout=30)
                    
                    # Check if poisoned content is served
                    if response1.text == response2.text and response1.headers.get('X-Cache'):
                        results[f"{header}: {value}"] = {
                            'poisoned': True,
                            'cache_hit': 'HIT' in response2.headers.get('X-Cache', ''),
                            'severity': 'high'
                        }
                    else:
                        results[f"{header}: {value}"] = {'poisoned': False}
                        
                except requests.RequestException as e:
                    results[f"{header}: {value}"] = {'error': str(e)}
        
        return results
```

### Response Splitting Techniques
```python
class ResponseSplittingTester:
    def __init__(self):
        self.split_payloads = [
            '%0d%0a%0d%0a',
            '\r\n\r\n',
            '%0D%0A%0D%0A',
            '%0d%0aContent-Length:%200%0d%0a%0d%0aHTTP/1.1%20200%20OK',
        ]
    
    def test_response_splitting(self, url: str, 
                               parameter: str) -> Dict:
        """Test for response splitting vulnerabilities"""
        results = {}
        
        for payload in self.split_payloads:
            try:
                test_url = f"{url}?{parameter}={payload}"
                response = requests.get(test_url, timeout=30)
                
                # Check for response splitting indicators
                has_injection = (
                    '\r\n' in response.text and
                    response.text.count('\r\n') > response.text.count('HTTP')
                )
                
                results[payload] = {
                    'status_code': response.status_code,
                    'has_injection': has_injection,
                    'response_headers': dict(response.headers),
                    'severity': 'high' if has_injection else 'low'
                }
                
            except requests.RequestException as e:
                results[payload] = {'error': str(e)}
        
        return results
```

## Advanced Techniques

### Correlation Analysis Engine
```python
class CorrelationAnalyzer:
    def __init__(self):
        self.correlations = {}
    
    def analyze_correlations(self, responses: List[Dict]) -> Dict:
        """Analyze correlations between responses"""
        correlations = {
            'status_code_patterns': self._analyze_status_codes(responses),
            'timing_patterns': self._analyze_timing(responses),
            'header_patterns': self._analyze_headers(responses),
            'content_patterns': self._analyze_content(responses),
        }
        
        return correlations
    
    def _analyze_status_codes(self, responses: List[Dict]) -> Dict:
        """Analyze status code patterns"""
        status_codes = [r.get('status_code') for r in responses]
        
        return {
            'distribution': dict(Counter(status_codes)),
            'unusual_codes': [code for code in set(status_codes) if code not in [200, 301, 302, 404]],
            'error_rate': sum(1 for code in status_codes if code >= 400) / len(status_codes),
        }
    
    def _analyze_timing(self, responses: List[Dict]) -> Dict:
        """Analyze timing patterns"""
        times = [r.get('response_time', 0) for r in responses]
        
        return {
            'avg_time': statistics.mean(times),
            'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
            'outliers': [t for t in times if t > statistics.mean(times) + 2 * statistics.stdev(times)],
        }
    
    def _analyze_headers(self, responses: List[Dict]) -> Dict:
        """Analyze header patterns"""
        header_counts = {}
        
        for response in responses:
            headers = response.get('headers', {})
            for header in headers:
                header_counts[header] = header_counts.get(header, 0) + 1
        
        return {
            'common_headers': dict(sorted(header_counts.items(), key=lambda x: x[1], reverse=True)[:10]),
            'inconsistent_headers': [h for h, c in header_counts.items() if c != len(responses)],
        }
    
    def _analyze_content(self, responses: List[Dict]) -> Dict:
        """Analyze content patterns"""
        content_lengths = [r.get('content_length', 0) for r in responses]
        content_hashes = [r.get('body_hash', '') for r in responses]
        
        return {
            'avg_length': statistics.mean(content_lengths),
            'unique_content': len(set(content_hashes)),
            'duplicate_content': len(responses) - len(set(content_hashes)),
        }
    
    def detect_anomalies(self, current_response: Dict, 
                        baseline: Dict) -> List[Dict]:
        """Detect anomalies in current response against baseline"""
        anomalies = []
        
        # Check status code
        if current_response.get('status_code') != baseline.get('most_common_status'):
            anomalies.append({
                'type': 'status_code_anomaly',
                'severity': 'high',
                'details': {
                    'expected': baseline.get('most_common_status'),
                    'actual': current_response.get('status_code')
                }
            })
        
        # Check timing
        current_time = current_response.get('response_time', 0)
        baseline_avg = baseline.get('avg_time', 0)
        baseline_std = baseline.get('std_dev', 0)
        
        if current_time > baseline_avg + 3 * baseline_std:
            anomalies.append({
                'type': 'timing_anomaly',
                'severity': 'medium',
                'details': {
                    'expected_avg': baseline_avg,
                    'actual': current_time
                }
            })
        
        # Check content
        if current_response.get('body_hash') != baseline.get('most_common_hash'):
            anomalies.append({
                'type': 'content_anomaly',
                'severity': 'low',
                'details': {
                    'expected_hash': baseline.get('most_common_hash'),
                    'actual_hash': current_response.get('body_hash')
                }
            })
        
        return anomalies
```

### Automated Regression Detection
```python
class RegressionDetector:
    def __init__(self):
        self.baselines = {}
        self.regressions = []
    
    def establish_baseline(self, name: str, url: str, 
                          method: str = 'GET', iterations: int = 10):
        """Establish performance baseline"""
        times = []
        
        for _ in range(iterations):
            start_time = time.time()
            try:
                response = requests.request(method, url, timeout=30)
                response_time = time.time() - start_time
                times.append(response_time)
            except requests.RequestException:
                continue
        
        if times:
            self.baselines[name] = {
                'url': url,
                'method': method,
                'avg_time': statistics.mean(times),
                'std_dev': statistics.stdev(times) if len(times) > 1 else 0,
                'max_time': max(times),
                'min_time': min(times),
                'established_at': datetime.now().isoformat()
            }
    
    def detect_regression(self, name: str, current_time: float) -> Dict:
        """Detect performance regression"""
        if name not in self.baselines:
            return {'error': 'No baseline found'}
        
        baseline = self.baselines[name]
        
        # Calculate regression metrics
        time_diff = current_time - baseline['avg_time']
        percentage_increase = (time_diff / baseline['avg_time']) * 100
        
        # Determine if regression
        is_regression = current_time > baseline['avg_time'] + 2 * baseline['std_dev']
        
        if is_regression:
            regression = {
                'name': name,
                'baseline_avg': baseline['avg_time'],
                'current_time': current_time,
                'time_diff': time_diff,
                'percentage_increase': percentage_increase,
                'severity': 'high' if percentage_increase > 100 else 'medium',
                'detected_at': datetime.now().isoformat()
            }
            
            self.regressions.append(regression)
            return regression
        
        return {'is_regression': False}
    
    def generate_regression_report(self) -> Dict:
        """Generate regression detection report"""
        return {
            'total_regressions': len(self.regressions),
            'high_severity': len([r for r in self.regressions if r['severity'] == 'high']),
            'medium_severity': len([r for r in self.regressions if r['severity'] == 'medium']),
            'regressions': self.regressions,
            'generated_at': datetime.now().isoformat()
        }
```

## Detection Indicators

### Response Analysis Artifacts
- Missing security headers (CSP, HSTS, X-Frame-Options)
- Server version information disclosed
- Detailed error messages with stack traces
- Internal IP addresses in responses
- Database error messages exposed
- Debug mode indicators present
- Insecure cookie attributes
- Open redirect vulnerabilities

### Timing Analysis Artifacts
- Significant response time variations
- Timing-based vulnerabilities (blind SQLi, XXE)
- Cache hit/miss patterns
- Server-side processing delays
- Rate limiting responses

### Content Analysis Artifacts
- Sensitive data in responses
- HTML comments with internal information
- JavaScript variables with credentials
- Hidden form fields with sensitive data
- Error pages with excessive detail

## Impact Assessment

### Analysis Effectiveness Metrics
- **Detection Rate**: Percentage of vulnerabilities detected through response analysis
- **False Positive Rate**: Percentage of findings requiring manual verification
- **Coverage**: Percentage of application endpoints analyzed
- **Response Time**: Time to complete full analysis
- **Regression Detection**: Number of performance regressions caught
- **Security Improvement**: Reduction in security issues over time

### Business Impact
- **Risk Reduction**: Reduction in potential vulnerabilities
- **Compliance**: Achievement of security header compliance
- **Performance**: Improvement in application performance
- **Developer Feedback**: Faster security feedback to development
- **Incident Prevention**: Prevention of security incidents
- **Cost Savings**: Avoided costs from security incidents
- **User Trust**: Improved user trust through security
- **Audit Readiness**: Improved audit trail and documentation

## Common Pitfalls

### Technical Pitfalls
- **False Positives**: Overly broad patterns detecting non-issues
- **False Negatives**: Missing actual vulnerabilities
- **Performance Issues**: Slow analysis on large applications
- **Encoding Issues**: Mishandling different character encodings
- **Redirect Chains**: Not properly following redirects
- **Session Handling**: Not maintaining authentication state
- **Rate Limiting**: Triggering rate limits during analysis
- **Network Issues**: Not handling network errors gracefully

### Operational Pitfalls
- **Baseline Drift**: Baselines becoming outdated
- **Alert Fatigue**: Too many alerts reducing effectiveness
- **Tool Sprawl**: Using too many different tools
- **Skill Gaps**: Team lacking response analysis skills
- **Documentation**: Poor documentation of findings
- **Remediation**: Not tracking remediation progress
- **Integration**: Poor integration with existing workflows
- **Maintenance**: Not maintaining analysis tools

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: Response Analysis
on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run response analysis
        run: python -m response_analyzer scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: analysis-results
          path: results/
```

### Monitoring Integration
```python
# Prometheus metrics
from prometheus_client import Counter, Histogram, Gauge

analysis_counter = Counter(
    'response_analysis_total',
    'Total response analyses',
    ['status', 'severity']
)

analysis_duration = Histogram(
    'response_analysis_duration_seconds',
    'Duration of response analysis',
    ['endpoint']
)

active_findings = Gauge(
    'response_analysis_active_findings',
    'Number of active findings',
    ['severity']
)

def record_analysis(status, severity, duration):
    analysis_counter.labels(status, severity).inc()
    analysis_duration.labels('default').observe(duration)
```

### Alerting Integration
```python
import requests

class AlertManager:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
    
    def send_alert(self, finding: Dict):
        """Send alert for security finding"""
        severity = finding.get('severity', 'low')
        title = finding.get('title', 'Security Finding')
        details = finding.get('details', '')
        
        payload = {
            'text': f"🚨 [{severity.upper()}] {title}",
            'attachments': [{
                'color': 'danger' if severity == 'high' else 'warning',
                'fields': [
                    {'title': 'Severity', 'value': severity, 'short': True},
                    {'title': 'Title', 'value': title, 'short': True},
                    {'title': 'Details', 'value': details, 'short': False},
                ]
            }]
        }
        
        requests.post(self.webhook_url, json=payload)
```

## Practice Labs

### Lab 1: Security Header Analysis
Create a security header analyzer that:
1. Scans a list of URLs for security headers
2. Validates header values against best practices
3. Generates compliance reports
4. Tracks improvements over time

### Lab 2: Redirect Chain Analysis
Build a redirect analyzer that:
1. Follows redirect chains for multiple URLs
2. Identifies open redirect vulnerabilities
3. Detects circular redirects
4. Generates redirect flow diagrams

### Lab 3: Timing Analysis
Develop a timing analyzer that:
1. Establishes timing baselines for endpoints
2. Detects timing anomalies
3. Correlates timing differences with inputs
4. Identifies blind vulnerabilities

### Lab 4: Content Change Detection
Create a content change detector that:
1. Monitors pages for content changes
2. Alerts on unauthorized changes
3. Tracks change history
4. Identifies potential tampering

### Lab 5: Comprehensive Analysis Pipeline
Build a complete analysis pipeline that:
1. Integrates all analysis components
2. Provides unified reporting
3. Offers dashboard visualization
4. Supports automated remediation tracking

## Ethics

### Responsible Response Analysis
- **Authorization**: Only analyze applications you have permission to test
- **Rate Limiting**: Implement delays between requests to avoid DoS
- **Data Handling**: Treat all captured data as potentially sensitive
- **Scope Respect**: Stay within authorized testing boundaries
- **Credential Security**: Don't log or expose credentials
- **Impact Awareness**: Be aware of potential impact on production systems
- **Disclosure**: Report findings through responsible channels
- **Documentation**: Maintain audit trail of all analysis activities
- **Privacy**: Handle personal data according to regulations
- **Cleanup**: Remove test data and artifacts after analysis

## Quick Reference

### Status Code Reference
- **200 OK**: Successful request
- **301 Moved Permanently**: Permanent redirect
- **302 Found**: Temporary redirect
- **304 Not Modified**: Cached content
- **400 Bad Request**: Client error
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Access denied
- **404 Not Found**: Resource not found
- **500 Internal Server Error**: Server error
- **502 Bad Gateway**: Gateway error
- **503 Service Unavailable**: Service unavailable

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

Recommended Headers:
  - Cache-Control: no-store, no-cache, must-revalidate
  - Pragma: no-cache
  - Expires: 0
```

### Analysis Commands
```bash
# Test security headers
curl -I https://target.example.com

# Follow redirects
curl -L -v https://target.example.com

# Measure response time
curl -w "@curl-format.txt" -o /dev/null -s https://target.example.com

# Test with different headers
curl -H "X-Forwarded-For: 127.0.0.1" https://target.example.com

# Check for information disclosure
curl -s https://target.example.com | grep -i "password\|secret\|key"
```

### Common Patterns
```regex
# Version information
Apache/[\d.]+
nginx/[\d.]+
PHP/[\d.]+
ASP\.NET[\s/]+[\d.]+

# Error messages
(?i)stack\s*trace
(?i)exception\s*detail
(?i)debug\s*mode

# Sensitive data
(?i)password\s*[:=]\s*\S+
(?i)api[_-]?key\s*[:=]\s*\S+
(?i)secret\s*[:=]\s*\S+

# Internal IPs
192\.168\.\d+\.\d+
10\.\d+\.\d+\.\d+
172\.(?:1[6-9]|2\d|3[01])\.\d+\.\d+
```

### Troubleshooting Quick Fixes
1. **High false positives**: Tune patterns, add context analysis
2. **Missing findings**: Update patterns, check encoding
3. **Slow analysis**: Optimize code, parallelize operations
4. **Network errors**: Add retry logic, handle timeouts
5. **Session issues**: Implement proper authentication
6. **Rate limiting**: Add delays, rotate IPs
7. **Encoding issues**: Handle different encodings properly
8. **Report generation**: Use templates, automate reporting
