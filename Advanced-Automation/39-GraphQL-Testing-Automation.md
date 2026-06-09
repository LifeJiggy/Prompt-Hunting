# Automated GraphQL Security Testing

## Expert Role
You are a GraphQL security testing specialist and security engineer who designs, develops, and maintains automated systems for detecting and exploiting GraphQL vulnerabilities. Your expertise spans introspection abuse, query depth testing, batch query testing, field suggestion analysis, mutation authorization, subscription testing, schema analysis, and automated vulnerability detection. You understand GraphQL protocol internals, schema design patterns, query execution semantics, and how GraphQL implementations can be vulnerable to information disclosure, denial of service, and authorization bypass. Your role is to build robust, maintainable testing pipelines that identify GraphQL vulnerabilities before attackers can exploit them, and provide actionable remediation guidance for secure GraphQL implementation.

## Core Concepts
- **GraphQL Schema**: GraphQL uses a type system to define API capabilities. The schema defines types, queries, mutations, and subscriptions. Understanding schema structure is crucial for security testing as it reveals the attack surface.
- **Introspection**: GraphQL supports introspection queries that reveal the entire schema. While useful for development, exposed introspection can leak sensitive information about the API structure and capabilities.
- **Query Depth**: GraphQL queries can be nested deeply, leading to performance issues and denial of service. Attackers can craft deeply nested queries to exhaust server resources.
- **Batch Queries**: GraphQL allows multiple operations in a single request. While efficient, batch queries can be abused for denial of service or to bypass rate limiting.
- **Field Suggestion**: GraphQL may suggest similar field names when a query contains typos. This can leak information about the schema and aid in reconnaissance.
- **Mutations**: GraphQL mutations modify server-side data. Inadequate authorization on mutations can lead to data manipulation or deletion.
- **Subscriptions**: GraphQL subscriptions provide real-time data via WebSocket. They can be vulnerable to hijacking, injection, or DoS attacks.
- **Resolver Functions**: Each GraphQL field has a resolver function that fetches data. Vulnerabilities in resolvers can lead to SQL injection, NoSQL injection, or other security issues.
- **Context and Authentication**: GraphQL resolvers receive context with authentication information. Improper context handling can lead to authorization bypass.
- **Rate Limiting**: GraphQL's flexible querying makes traditional rate limiting challenging. Attackers can abuse this to perform denial of service attacks.

## Prerequisites
- Python 3.8+ with `requests`, `aiohttp`, and `gql` libraries
- Understanding of GraphQL specification and query language
- Familiarity with HTTP/1.1 and WebSocket protocols
- Knowledge of common GraphQL implementations (Apollo, Hasura, GraphQL Yoga)
- Understanding of authentication and authorization mechanisms
- Browser developer tools proficiency
- Basic knowledge of JSON and query parsing
- Command-line proficiency with curl and graphql-cli
- Understanding of DoS attack techniques
- Knowledge of web application security vulnerabilities

## Methodology

### Phase 1: Discovery and Enumeration
1. Identify GraphQL endpoints in the application
2. Perform introspection query to extract schema
3. Map all queries, mutations, and subscriptions
4. Identify authentication mechanisms
5. Document schema structure and relationships

### Phase 2: Introspection and Information Disclosure
1. Test introspection query accessibility
2. Analyze schema for sensitive information
3. Test field suggestion functionality
4. Identify deprecated fields and types
5. Test error message information disclosure

### Phase 3: Query Complexity and DoS
1. Test query depth limitations
2. Test batch query restrictions
3. Analyze query cost and complexity
4. Test rate limiting effectiveness
5. Identify resource-intensive queries

### Phase 4: Authorization Testing
1. Test query authorization
2. Test mutation authorization
3. Test subscription authorization
4. Test field-level authorization
5. Test role-based access control

### Phase 5: Injection Testing
1. Test for SQL injection in resolvers
2. Test for NoSQL injection
3. Test for command injection
4. Test for SSRF via GraphQL
5. Test for template injection

### Phase 6: Reporting and Remediation
1. Document all vulnerabilities found
2. Create proof-of-concept exploits
3. Provide remediation recommendations
4. Implement automated testing
5. Train development teams on GraphQL security

## Tool Arsenal

### Core GraphQL Tester
```python
import requests
import json
import time
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
from urllib.parse import urlparse
import re

@dataclass
class GraphQLTestResult:
    url: str
    test_type: str
    vulnerability: str
    severity: str
    evidence: str
    query: str
    response: str
    timestamp: str

class GraphQLTester:
    def __init__(self, session: requests.Session = None):
        self.session = session or requests.Session()
        self.results = []
        self.schema = None
    
    def test_introspection(self, url: str) -> List[GraphQLTestResult]:
        """Test for introspection query vulnerability"""
        introspection_query = """
        query IntrospectionQuery {
            __schema {
                queryType { name }
                mutationType { name }
                subscriptionType { name }
                types {
                    ...FullType
                }
                directives {
                    name
                    description
                    locations
                    args {
                        ...InputValue
                    }
                }
            }
        }
        
        fragment FullType on __Type {
            kind
            name
            description
            fields(includeDeprecated: true) {
                name
                description
                args {
                    ...InputValue
                }
                type {
                    ...TypeRef
                }
                isDeprecated
                deprecationReason
            }
            inputFields {
                ...InputValue
            }
            interfaces {
                ...TypeRef
            }
            enumValues(includeDeprecated: true) {
                name
                description
                isDeprecated
                deprecationReason
            }
            possibleTypes {
                ...TypeRef
            }
        }
        
        fragment InputValue on __InputValue {
            name
            description
            type { ...TypeRef }
            defaultValue
        }
        
        fragment TypeRef on __Type {
            kind
            name
            ofType {
                kind
                name
                ofType {
                    kind
                    name
                    ofType {
                        kind
                        name
                        ofType {
                            kind
                            name
                            ofType {
                                kind
                                name
                                ofType {
                                    kind
                                    name
                                    ofType {
                                        kind
                                        name
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        """
        
        results = []
        
        try:
            response = self.session.post(
                url,
                json={'query': introspection_query},
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'data' in data and '__schema' in data['data']:
                    result = GraphQLTestResult(
                        url=url,
                        test_type='Introspection',
                        vulnerability='Schema Disclosure',
                        severity='medium',
                        evidence=f"Introspection query successful. Schema exposed.",
                        query=introspection_query,
                        response=json.dumps(data['data'])[:500],
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
                    # Store schema for further analysis
                    self.schema = data['data']['__schema']
                    
        except Exception as e:
            pass
        
        return results
    
    def test_introspection_disabled(self, url: str) -> List[GraphQLTestResult]:
        """Test if introspection is properly disabled"""
        introspection_query = """
        query {
            __schema {
                types {
                    name
                }
            }
        }
        """
        
        results = []
        
        try:
            response = self.session.post(
                url,
                json={'query': introspection_query},
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'errors' in data:
                    error_message = str(data['errors'])
                    if 'introspection' in error_message.lower() or 'disabled' in error_message.lower():
                        result = GraphQLTestResult(
                            url=url,
                            test_type='Introspection',
                            vulnerability='Introspection Disabled',
                            severity='low',
                            evidence=f"Introspection is properly disabled: {error_message[:200]}",
                            query=introspection_query,
                            response=json.dumps(data['errors']),
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
        except Exception as e:
            pass
        
        return results
    
    def test_field_suggestion(self, url: str) -> List[GraphQLTestResult]:
        """Test for field suggestion information disclosure"""
        # Query with typo to trigger suggestion
        typo_query = """
        query {
            users {
                id
                name
                emaill  # Typo in field name
            }
        }
        """
        
        results = []
        
        try:
            response = self.session.post(
                url,
                json={'query': typo_query},
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if 'errors' in data:
                    error_str = json.dumps(data['errors'])
                    
                    # Check for field suggestions
                    if 'did you mean' in error_str.lower() or 'suggestion' in error_str.lower():
                        result = GraphQLTestResult(
                            url=url,
                            test_type='Field Suggestion',
                            vulnerability='Field Suggestion Disclosure',
                            severity='low',
                            evidence=f"Field suggestion enabled: {error_str[:300]}",
                            query=typo_query,
                            response=json.dumps(data['errors']),
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
        except Exception as e:
            pass
        
        return results
    
    def test_query_depth(self, url: str, 
                        max_depth: int = 10) -> List[GraphQLTestResult]:
        """Test for query depth vulnerabilities"""
        results = []
        
        for depth in range(1, max_depth + 1):
            # Generate deeply nested query
            query = self._generate_nested_query(depth)
            
            try:
                start_time = time.time()
                response = self.session.post(
                    url,
                    json={'query': query},
                    headers={'Content-Type': 'application/json'},
                    timeout=30
                )
                response_time = time.time() - start_time
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Check if query succeeded
                    if 'data' in data:
                        result = GraphQLTestResult(
                            url=url,
                            test_type='Query Depth',
                            vulnerability='Deep Nested Query',
                            severity='medium' if depth > 5 else 'low',
                            evidence=f"Query depth {depth} succeeded in {response_time:.2f}s",
                            query=query[:200],
                            response=json.dumps(data['data'])[:200],
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
                        # If response time increases significantly, potential DoS
                        if response_time > 5:
                            result = GraphQLTestResult(
                                url=url,
                                test_type='Query Depth',
                                vulnerability='DoS via Deep Query',
                                severity='high',
                                evidence=f"Query depth {depth} took {response_time:.2f}s",
                                query=query[:200],
                                response=f"Response time: {response_time:.2f}s",
                                timestamp=datetime.now().isoformat()
                            )
                            results.append(result)
                            self.results.append(result)
                            
            except Exception as e:
                continue
        
        return results
    
    def _generate_nested_query(self, depth: int) -> str:
        """Generate nested query of specified depth"""
        query = "query { "
        for i in range(depth):
            query += f"field{i} {{ "
        query += "data "
        for i in range(depth):
            query += "} "
        query += "}"
        return query
    
    def test_batch_queries(self, url: str, 
                          batch_size: int = 10) -> List[GraphQLTestResult]:
        """Test for batch query vulnerabilities"""
        results = []
        
        # Generate batch query
        batch = []
        for i in range(batch_size):
            batch.append({
                'query': f'query {{ user(id: {i}) {{ id name }} }}'
            })
        
        try:
            start_time = time.time()
            response = self.session.post(
                url,
                json=batch,
                headers={'Content-Type': 'application/json'},
                timeout=30
            )
            response_time = time.time() - start_time
            
            if response.status_code == 200:
                data = response.json()
                
                if isinstance(data, list) and len(data) == batch_size:
                    result = GraphQLTestResult(
                        url=url,
                        test_type='Batch Queries',
                        vulnerability='Batch Query Allowed',
                        severity='medium',
                        evidence=f"Batch of {batch_size} queries accepted in {response_time:.2f}s",
                        query=json.dumps(batch)[:200],
                        response=json.dumps(data)[:200],
                        timestamp=datetime.now().isoformat()
                    )
                    results.append(result)
                    self.results.append(result)
                    
                    # Test with larger batch
                    large_batch = [{'query': 'query { __typename }'} for _ in range(1000)]
                    
                    start_time = time.time()
                    response = self.session.post(
                        url,
                        json=large_batch,
                        headers={'Content-Type': 'application/json'},
                        timeout=60
                    )
                    response_time = time.time() - start_time
                    
                    if response.status_code == 200:
                        result = GraphQLTestResult(
                            url=url,
                            test_type='Batch Queries',
                            vulnerability='Large Batch Allowed',
                            severity='high',
                            evidence=f"Large batch of 1000 queries accepted in {response_time:.2f}s",
                            query="Large batch test",
                            response=f"Response time: {response_time:.2f}s",
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
        except Exception as e:
            pass
        
        return results
    
    def test_mutation_authorization(self, url: str, 
                                   auth_token: str = None) -> List[GraphQLTestResult]:
        """Test for mutation authorization vulnerabilities"""
        mutations = [
            {
                'name': 'Delete User',
                'query': 'mutation { deleteUser(id: 1) { success } }'
            },
            {
                'name': 'Update Admin',
                'query': 'mutation { updateUserRole(id: 1, role: "admin") { success } }'
            },
            {
                'name': 'Create Post',
                'query': 'mutation { createPost(title: "test", content: "test") { id } }'
            },
            {
                'name': 'Delete Comment',
                'query': 'mutation { deleteComment(id: 1) { success } }'
            },
        ]
        
        results = []
        
        for mutation in mutations:
            try:
                headers = {'Content-Type': 'application/json'}
                if auth_token:
                    headers['Authorization'] = f'Bearer {auth_token}'
                
                response = self.session.post(
                    url,
                    json={'query': mutation['query']},
                    headers=headers,
                    timeout=30
                )
                
                if response.status_code == 200:
                    data = response.json()
                    
                    # Check if mutation succeeded
                    if 'data' in data and not data.get('errors'):
                        result = GraphQLTestResult(
                            url=url,
                            test_type='Mutation Authorization',
                            vulnerability=f'Unauthorized {mutation["name"]}',
                            severity='high',
                            evidence=f"Mutation '{mutation['name']}' succeeded without proper authorization",
                            query=mutation['query'],
                            response=json.dumps(data['data']),
                            timestamp=datetime.now().isoformat()
                        )
                        results.append(result)
                        self.results.append(result)
                        
            except Exception as e:
                continue
        
        return results
    
    def test_subscription(self, url: str) -> List[GraphQLTestResult]:
        """Test for subscription vulnerabilities"""
        results = []
        
        # Test WebSocket subscription endpoint
        ws_url = url.replace('http://', 'ws://').replace('https://', 'wss://')
        
        try:
            import websocket
            
            # Connect to subscription endpoint
            ws = websocket.create_connection(ws_url, timeout=5)
            
            # Send subscription query
            subscription_query = json.dumps({
                'type': 'connection_init',
                'payload': {}
            })
            
            ws.send(subscription_query)
            response = ws.recv()
            
            # Check if subscription was accepted
            if 'connection_ack' in response or 'data' in response:
                result = GraphQLTestResult(
                    url=url,
                    test_type='Subscription',
                    vulnerability='Subscription Endpoint Accessible',
                    severity='medium',
                    evidence=f"WebSocket subscription endpoint accessible without authentication",
                    query='subscription { onUserCreated { id } }',
                    response=response[:200],
                    timestamp=datetime.now().isoformat()
                )
                results.append(result)
                self.results.append(result)
            
            ws.close()
            
        except Exception as e:
            pass
        
        return results
    
    def test_error_messages(self, url: str) -> List[GraphQLTestResult]:
        """Test for information disclosure in error messages"""
        error_queries = [
            {
                'name': 'Invalid Query',
                'query': 'query { invalidField }'
            },
            {
                'name': 'Malformed Query',
                'query': 'query { '
            },
            {
                'name': 'Missing Required Fields',
                'query': 'mutation { createUser { id } }'
            },
        ]
        
        results = []
        
        for error_query in error_queries:
            try:
                response = self.session.post(
                    url,
                    json={'query': error_query['query']},
                    headers={'Content-Type': 'application/json'},
                    timeout=30
                )
                
                if response.status_code == 200:
                    data = response.json()
                    
                    if 'errors' in data:
                        error_str = json.dumps(data['errors'])
                        
                        # Check for sensitive information in errors
                        sensitive_patterns = [
                            r'internal server error',
                            r'stack trace',
                            r'database',
                            r'file path',
                            r'line number',
                        ]
                        
                        for pattern in sensitive_patterns:
                            if re.search(pattern, error_str, re.IGNORECASE):
                                result = GraphQLTestResult(
                                    url=url,
                                    test_type='Error Messages',
                                    vulnerability='Information Disclosure',
                                    severity='medium',
                                    evidence=f"Sensitive information in error: {error_str[:300]}",
                                    query=error_query['query'],
                                    response=json.dumps(data['errors']),
                                    timestamp=datetime.now().isoformat()
                                )
                                results.append(result)
                                self.results.append(result)
                                break
                                
            except Exception as e:
                continue
        
        return results
```

### GraphQL Schema Analyzer
```python
class GraphQLSchemaAnalyzer:
    def __init__(self):
        self.sensitive_fields = [
            'password', 'secret', 'token', 'key', 'credential',
            'ssn', 'creditCard', 'bankAccount', 'email', 'phone',
        ]
        
        self.dangerous_mutations = [
            'delete', 'remove', 'destroy', 'drop', 'truncate',
            'update', 'modify', 'change', 'set', 'assign',
        ]
    
    def analyze_schema(self, schema: Dict) -> Dict:
        """Analyze GraphQL schema for security issues"""
        analysis = {
            'types': [],
            'queries': [],
            'mutations': [],
            'subscriptions': [],
            'issues': []
        }
        
        if not schema:
            return analysis
        
        # Analyze types
        if 'types' in schema:
            for type_def in schema['types']:
                type_analysis = self._analyze_type(type_def)
                analysis['types'].append(type_analysis)
                
                # Check for sensitive fields
                if type_analysis['has_sensitive_fields']:
                    analysis['issues'].append({
                        'type': 'Sensitive Fields',
                        'severity': 'medium',
                        'details': f"Type '{type_def['name']}' contains sensitive fields"
                    })
        
        # Analyze queries
        if 'queryType' in schema and schema['queryType']:
            analysis['queries'] = self._analyze_operations(
                schema.get('types', []),
                schema['queryType']['name']
            )
        
        # Analyze mutations
        if 'mutationType' in schema and schema['mutationType']:
            analysis['mutations'] = self._analyze_operations(
                schema.get('types', []),
                schema['mutationType']['name']
            )
        
        # Analyze subscriptions
        if 'subscriptionType' in schema and schema['subscriptionType']:
            analysis['subscriptions'] = self._analyze_operations(
                schema.get('types', []),
                schema['subscriptionType']['name']
            )
        
        return analysis
    
    def _analyze_type(self, type_def: Dict) -> Dict:
        """Analyze a GraphQL type"""
        analysis = {
            'name': type_def['name'],
            'kind': type_def['kind'],
            'fields': [],
            'has_sensitive_fields': False,
            'issues': []
        }
        
        if 'fields' in type_def:
            for field in type_def['fields']:
                field_analysis = self._analyze_field(field)
                analysis['fields'].append(field_analysis)
                
                if field_analysis['is_sensitive']:
                    analysis['has_sensitive_fields'] = True
        
        return analysis
    
    def _analyze_field(self, field: Dict) -> Dict:
        """Analyze a GraphQL field"""
        analysis = {
            'name': field['name'],
            'type': self._get_type_name(field['type']),
            'is_sensitive': False,
            'has_arguments': len(field.get('args', [])) > 0,
            'is_deprecated': field.get('isDeprecated', False),
            'issues': []
        }
        
        # Check if field name contains sensitive keywords
        field_name_lower = field['name'].lower()
        for sensitive in self.sensitive_fields:
            if sensitive in field_name_lower:
                analysis['is_sensitive'] = True
                analysis['issues'].append({
                    'type': 'Sensitive Field',
                    'severity': 'medium',
                    'details': f"Field '{field['name']}' may contain sensitive data"
                })
        
        return analysis
    
    def _get_type_name(self, type_ref: Dict) -> str:
        """Extract type name from type reference"""
        if 'name' in type_ref and type_ref['name']:
            return type_ref['name']
        elif 'ofType' in type_ref:
            return self._get_type_name(type_ref['ofType'])
        return 'Unknown'
    
    def _analyze_operations(self, types: List[Dict], 
                           type_name: str) -> List[Dict]:
        """Analyze operations (queries/mutations)"""
        operations = []
        
        for type_def in types:
            if type_def['name'] == type_name and 'fields' in type_def:
                for field in type_def['fields']:
                    operation = {
                        'name': field['name'],
                        'type': type_name,
                        'arguments': [arg['name'] for arg in field.get('args', [])],
                        'return_type': self._get_type_name(field['type']),
                        'is_deprecated': field.get('isDeprecated', False),
                        'issues': []
                    }
                    
                    # Check for dangerous mutations
                    operation_name_lower = field['name'].lower()
                    for dangerous in self.dangerous_mutations:
                        if dangerous in operation_name_lower:
                            operation['issues'].append({
                                'type': 'Dangerous Operation',
                                'severity': 'high',
                                'details': f"Operation '{field['name']}' may be dangerous"
                            })
                    
                    operations.append(operation)
        
        return operations
    
    def identify_sensitive_data(self, schema: Dict) -> List[Dict]:
        """Identify sensitive data in schema"""
        sensitive_data = []
        
        if 'types' in schema:
            for type_def in schema['types']:
                if 'fields' in type_def:
                    for field in type_def['fields']:
                        field_name = field['name'].lower()
                        
                        for sensitive in self.sensitive_fields:
                            if sensitive in field_name:
                                sensitive_data.append({
                                    'type': type_def['name'],
                                    'field': field['name'],
                                    'sensitivity': sensitive,
                                    'severity': 'high'
                                })
        
        return sensitive_data
    
    def generate_security_report(self, analysis: Dict) -> Dict:
        """Generate security report from schema analysis"""
        report = {
            'summary': {
                'total_types': len(analysis.get('types', [])),
                'total_queries': len(analysis.get('queries', [])),
                'total_mutations': len(analysis.get('mutations', [])),
                'total_subscriptions': len(analysis.get('subscriptions', [])),
                'total_issues': len(analysis.get('issues', [])),
            },
            'issues': analysis.get('issues', []),
            'recommendations': []
        }
        
        # Generate recommendations
        if report['summary']['total_issues'] > 0:
            report['recommendations'].append("Review and address identified issues")
        
        if report['summary']['total_mutations'] > 10:
            report['recommendations'].append("Consider splitting large mutation types")
        
        report['recommendations'].extend([
            "Implement field-level authorization",
            "Disable introspection in production",
            "Add query depth limiting",
            "Implement rate limiting",
            "Validate all input arguments",
            "Use persistent queries in production"
        ])
        
        return report
```

### GraphQL Security Scanner
```python
class GraphQLSecurityScanner:
    def __init__(self):
        self.tester = GraphQLTester()
        self.schema_analyzer = GraphQLSchemaAnalyzer()
    
    def scan_endpoint(self, url: str, 
                     auth_token: str = None) -> Dict:
        """Perform comprehensive GraphQL security scan"""
        results = {
            'url': url,
            'timestamp': datetime.now().isoformat(),
            'tests': {},
            'vulnerabilities': [],
            'schema_analysis': None,
            'recommendations': []
        }
        
        # Test introspection
        print("Testing introspection...")
        introspection_results = self.tester.test_introspection(url)
        results['tests']['introspection'] = [asdict(r) for r in introspection_results]
        results['vulnerabilities'].extend([asdict(r) for r in introspection_results])
        
        # Test field suggestion
        print("Testing field suggestion...")
        suggestion_results = self.tester.test_field_suggestion(url)
        results['tests']['field_suggestion'] = [asdict(r) for r in suggestion_results]
        results['vulnerabilities'].extend([asdict(r) for r in suggestion_results])
        
        # Test query depth
        print("Testing query depth...")
        depth_results = self.tester.test_query_depth(url)
        results['tests']['query_depth'] = [asdict(r) for r in depth_results]
        results['vulnerabilities'].extend([asdict(r) for r in depth_results])
        
        # Test batch queries
        print("Testing batch queries...")
        batch_results = self.tester.test_batch_queries(url)
        results['tests']['batch_queries'] = [asdict(r) for r in batch_results]
        results['vulnerabilities'].extend([asdict(r) for r in batch_results])
        
        # Test mutation authorization
        print("Testing mutation authorization...")
        mutation_results = self.tester.test_mutation_authorization(url, auth_token)
        results['tests']['mutation_authorization'] = [asdict(r) for r in mutation_results]
        results['vulnerabilities'].extend([asdict(r) for r in mutation_results])
        
        # Test error messages
        print("Testing error messages...")
        error_results = self.tester.test_error_messages(url)
        results['tests']['error_messages'] = [asdict(r) for r in error_results]
        results['vulnerabilities'].extend([asdict(r) for r in error_results])
        
        # Analyze schema if introspection succeeded
        if self.tester.schema:
            print("Analyzing schema...")
            results['schema_analysis'] = self.schema_analyzer.analyze_schema(
                self.tester.schema
            )
        
        # Generate recommendations
        results['recommendations'] = self._generate_recommendations(results)
        
        return results
    
    def _generate_recommendations(self, results: Dict) -> List[str]:
        """Generate security recommendations"""
        recommendations = []
        
        # Check for critical vulnerabilities
        critical_vulns = [v for v in results['vulnerabilities'] if v['severity'] == 'critical']
        if critical_vulns:
            recommendations.append("IMMEDIATE: Fix critical vulnerabilities")
        
        # Check for high vulnerabilities
        high_vulns = [v for v in results['vulnerabilities'] if v['severity'] == 'high']
        if high_vulns:
            recommendations.append("High priority: Address high-severity vulnerabilities")
        
        # Check for specific issues
        if any(v['vulnerability'] == 'Schema Disclosure' for v in results['vulnerabilities']):
            recommendations.append("Disable introspection in production")
        
        if any(v['vulnerability'] == 'Deep Nested Query' for v in results['vulnerabilities']):
            recommendations.append("Implement query depth limiting")
        
        if any(v['vulnerability'] == 'Batch Query Allowed' for v in results['vulnerabilities']):
            recommendations.append("Implement batch query restrictions")
        
        if any('Unauthorized' in v['vulnerability'] for v in results['vulnerabilities']):
            recommendations.append("Implement proper authorization for mutations")
        
        # General recommendations
        recommendations.extend([
            "Use persistent queries in production",
            "Implement rate limiting for GraphQL endpoints",
            "Add input validation for all arguments",
            "Use field-level authorization",
            "Implement query cost analysis",
            "Add logging and monitoring for GraphQL activity"
        ])
        
        return list(set(recommendations))
    
    def generate_html_report(self, scan_results: Dict) -> str:
        """Generate HTML report for GraphQL scan"""
        html = '''
<!DOCTYPE html>
<html>
<head>
    <title>GraphQL Security Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .vulnerability { border: 1px solid #ccc; padding: 10px; margin: 10px 0; }
        .critical { border-color: #ff0000; background-color: #ffe6e6; }
        .high { border-color: #ff6600; background-color: #fff2e6; }
        .medium { border-color: #ffcc00; background-color: #fff9e6; }
        .low { border-color: #00cc00; background-color: #e6ffe6; }
        .summary { background-color: #f5f5f5; padding: 15px; margin: 10px 0; }
    </style>
</head>
<body>
    <h1>GraphQL Security Report</h1>
    <div class="summary">
        <h2>Summary</h2>
        <p><strong>URL:</strong> ''' + scan_results['url'] + '''</p>
        <p><strong>Timestamp:</strong> ''' + scan_results['timestamp'] + '''</p>
        <p><strong>Total Vulnerabilities:</strong> ''' + str(len(scan_results['vulnerabilities'])) + '''</p>
    </div>
    
    <h2>Vulnerabilities</h2>
        '''
        
        for vuln in scan_results['vulnerabilities']:
            severity = vuln['severity']
            html += f'''
            <div class="vulnerability {severity}">
                <h3>{vuln['vulnerability']}</h3>
                <p><strong>Severity:</strong> {severity}</p>
                <p><strong>Test Type:</strong> {vuln['test_type']}</p>
                <p><strong>Evidence:</strong> {vuln['evidence']}</p>
                <p><strong>Query:</strong> <code>{vuln['query'][:200]}</code></p>
            </div>
            '''
        
        html += '''
    <h2>Recommendations</h2>
    <ul>
        '''
        
        for rec in scan_results['recommendations']:
            html += f'<li>{rec}</li>'
        
        html += '''
    </ul>
</body>
</html>
        '''
        
        return html
```

## Case Studies

### Case Study 1: Introspection Leading to Schema Disclosure
**Scenario**: GraphQL API exposes introspection query in production.
**Approach**: Performed introspection query and extracted complete schema. Identified sensitive fields and dangerous mutations.
**Findings**: Complete schema disclosure including user PII fields, admin mutations, and internal types.
**Outcome**: Disabled introspection in production, implemented query whitelisting, added monitoring.

### Case Study 2: DoS via Deep Nested Queries
**Scenario**: GraphQL API doesn't limit query depth, allowing deeply nested queries.
**Approach**: Tested increasing query depths until server response time degraded significantly.
**Findings**: Query depth of 20 caused 30-second response times, depth of 50 caused server crash.
**Outcome**: Implemented query depth limiting to 10 levels, added query cost analysis, configured rate limiting.

### Case Study 3: Unauthorized Mutation Access
**Scenario**: GraphQL mutations don't check user authorization properly.
**Approach**: Tested mutations without authentication and with low-privilege tokens.
**Findings**: Critical mutations (deleteUser, updateRole) accessible without proper authorization.
**Outcome**: Implemented field-level authorization, added role-based access control, tested all mutations.

### Case Study 4: Information Disclosure via Error Messages
**Scenario**: GraphQL error messages expose internal implementation details.
**Approach**: Sent malformed queries and analyzed error responses.
**Findings**: Error messages revealed database structure, file paths, and stack traces.
**Outcome**: Implemented custom error handling, removed sensitive information from errors, added error logging.

### Case Study 5: Batch Query DoS Attack
**Scenario**: GraphQL API accepts unlimited batch queries.
**Approach**: Sent increasing batch sizes to test for rate limiting.
**Findings**: Batch of 1000 queries caused significant server load, no rate limiting detected.
**Outcome**: Implemented batch query limits, added request throttling, configured resource monitoring.

### Case Study 6: Subscription Hijacking
**Scenario**: GraphQL subscriptions don't validate user authentication.
**Approach**: Connected to WebSocket subscription endpoint without authentication.
**Findings**: Real-time data stream accessible without authentication, sensitive data exposed.
**Outcome**: Implemented subscription authentication, added connection validation, secured WebSocket endpoints.

## Bypass Techniques

### Introspection Bypass
```python
class IntrospectionBypass:
    def test_introspection_bypass(self, url: str) -> Dict:
        """Test various introspection bypass techniques"""
        bypass_techniques = [
            # Alternative introspection queries
            "query { __schema { types { name } } }",
            "query { __type(name: \"User\") { name fields { name } } }",
            
            # Use extensions
            '{"query":"query { __typename }","extensions":{"introspection":true}}',
            
            # Use GET method
            f"{url}?query={{__schema{{types{{name}}}}}}",
        ]
        
        results = {}
        
        for technique in bypass_techniques:
            try:
                if technique.startswith('http'):
                    response = requests.get(technique, timeout=30)
                else:
                    response = requests.post(
                        url,
                        json={'query': technique},
                        headers={'Content-Type': 'application/json'},
                        timeout=30
                    )
                
                if response.status_code == 200:
                    data = response.json()
                    if 'data' in data and '__schema' in str(data):
                        results[technique[:50]] = {
                            'bypassed': True,
                            'severity': 'medium'
                        }
                    else:
                        results[technique[:50]] = {'bypassed': False}
                        
            except Exception as e:
                results[technique[:50]] = {'error': str(e)}
        
        return results
```

### Authorization Bypass
```python
class AuthBypassTechniques:
    def test_auth_bypass(self, url: str) -> Dict:
        """Test various authorization bypass techniques"""
        techniques = [
            {
                'name': 'No Auth',
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
                'name': 'SQL Injection',
                'headers': {'Authorization': "Bearer ' OR '1'='1"}
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                response = requests.post(
                    url,
                    json={'query': 'mutation { deleteUser(id: 1) { success } }'},
                    headers=technique['headers'],
                    timeout=30
                )
                
                if response.status_code == 200:
                    data = response.json()
                    if 'data' in data and not data.get('errors'):
                        results[technique['name']] = {
                            'bypassed': True,
                            'severity': 'critical'
                        }
                    else:
                        results[technique['name']] = {'bypassed': False}
                        
            except Exception as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

### Rate Limiting Bypass
```python
class RateLimitBypass:
    def test_rate_limit_bypass(self, url: str) -> Dict:
        """Test various rate limiting bypass techniques"""
        techniques = [
            {
                'name': 'Batch Queries',
                'query': '[{"query":"query { __typename }"},{"query":"query { __typename }"}]'
            },
            {
                'name': 'Multiple Endpoints',
                'endpoints': ['/graphql', '/api/graphql', '/v1/graphql']
            },
            {
                'name': 'Different Methods',
                'methods': ['GET', 'POST', 'PUT']
            },
        ]
        
        results = {}
        
        for technique in techniques:
            try:
                if 'query' in technique:
                    # Test batch queries
                    responses = []
                    for i in range(10):
                        response = requests.post(
                            url,
                            json=json.loads(technique['query']),
                            timeout=30
                        )
                        responses.append(response.status_code)
                    
                    if all(r == 200 for r in responses):
                        results[technique['name']] = {
                            'bypassed': True,
                            'severity': 'high'
                        }
                    else:
                        results[technique['name']] = {'bypassed': False}
                        
            except Exception as e:
                results[technique['name']] = {'error': str(e)}
        
        return results
```

## Advanced Techniques

### GraphQL Subscription Attacks
```python
class SubscriptionAttacks:
    def test_subscription_attacks(self, url: str) -> Dict:
        """Test GraphQL subscription attacks"""
        ws_url = url.replace('http://', 'ws://').replace('https://', 'wss://')
        
        attacks = [
            {
                'name': 'Subscription Without Auth',
                'query': json.dumps({
                    'type': 'connection_init',
                    'payload': {}
                })
            },
            {
                'name': 'Subscription Injection',
                'query': json.dumps({
                    'type': 'start',
                    'id': '1',
                    'payload': {
                        'query': 'subscription { onMessage { content } }'
                    }
                })
            },
        ]
        
        results = {}
        
        for attack in attacks:
            try:
                import websocket
                ws = websocket.create_connection(ws_url, timeout=5)
                
                # Send initialization
                ws.send(json.dumps({
                    'type': 'connection_init',
                    'payload': {}
                }))
                
                # Wait for ack
                try:
                    ack = ws.recv()
                except:
                    pass
                
                # Send attack payload
                ws.send(attack['query'])
                
                try:
                    response = ws.recv()
                    results[attack['name']] = {
                        'success': True,
                        'response': response[:200],
                        'severity': 'high'
                    }
                except:
                    results[attack['name']] = {
                        'success': False,
                        'severity': 'low'
                    }
                
                ws.close()
                
            except Exception as e:
                results[attack['name']] = {'error': str(e)}
        
        return results
```

### GraphQL Query Cost Analysis
```python
class QueryCostAnalyzer:
    def analyze_query_cost(self, query: str, schema: Dict) -> Dict:
        """Analyze the cost of a GraphQL query"""
        # Parse query to estimate complexity
        depth = self._calculate_depth(query)
        fields = self._count_fields(query)
        arguments = self._count_arguments(query)
        
        # Calculate cost score
        cost_score = (depth * 10) + (fields * 5) + (arguments * 3)
        
        # Determine risk level
        if cost_score > 100:
            risk_level = 'critical'
        elif cost_score > 50:
            risk_level = 'high'
        elif cost_score > 20:
            risk_level = 'medium'
        else:
            risk_level = 'low'
        
        return {
            'query': query[:100],
            'depth': depth,
            'fields': fields,
            'arguments': arguments,
            'cost_score': cost_score,
            'risk_level': risk_level,
            'recommendations': self._get_recommendations(risk_level)
        }
    
    def _calculate_depth(self, query: str) -> int:
        """Calculate query depth"""
        depth = 0
        max_depth = 0
        
        for char in query:
            if char == '{':
                depth += 1
                max_depth = max(max_depth, depth)
            elif char == '}':
                depth -= 1
        
        return max_depth
    
    def _count_fields(self, query: str) -> int:
        """Count fields in query"""
        # Simple field counting (would need proper parsing in production)
        fields = re.findall(r'\b\w+\s*(?:\{|$)', query)
        return len(fields)
    
    def _count_arguments(self, query: str) -> int:
        """Count arguments in query"""
        arguments = re.findall(r'\(\w+:\s*\w+\)', query)
        return len(arguments)
    
    def _get_recommendations(self, risk_level: str) -> List[str]:
        """Get recommendations based on risk level"""
        recommendations = {
            'critical': [
                "Query is too expensive, consider breaking into smaller queries",
                "Implement query cost limiting",
                "Use persistent queries with cost analysis"
            ],
            'high': [
                "Query is expensive, consider optimizing",
                "Add field selection to reduce data transfer",
                "Implement query depth limiting"
            ],
            'medium': [
                "Query has moderate cost",
                "Consider adding pagination",
                "Monitor query performance"
            ],
            'low': [
                "Query cost is acceptable",
                "Continue monitoring"
            ]
        }
        
        return recommendations.get(risk_level, [])
```

## Detection Indicators

### GraphQL Vulnerability Artifacts
- Introspection query returns schema
- Field suggestions reveal field names
- Deep nested queries cause performance issues
- Batch queries bypass rate limiting
- Mutations execute without authorization
- Error messages expose internal details
- Subscriptions accessible without authentication
- Sensitive fields exposed in schema

### Exploitation Artifacts
- Schema reconnaissance
- DoS via query complexity
- Authorization bypass
- Data exfiltration via queries
- Mutation abuse
- Subscription hijacking
- Error-based information disclosure

## Impact Assessment

### Vulnerability Severity
- **Critical**: Authorization bypass, schema disclosure, DoS via mutations
- **High**: Deep query DoS, batch query abuse, subscription hijacking
- **Medium**: Field suggestion disclosure, error information leakage
- **Low**: Query complexity issues, missing security headers

### Business Impact
- **Data Breach**: Exfiltration of sensitive data via GraphQL queries
- **Denial of Service**: Server exhaustion via complex queries
- **Unauthorized Access**: Bypass of authorization controls
- **Information Disclosure**: Schema and implementation details exposed
- **Compliance Violations**: Failure to protect sensitive data

## Common Pitfalls

### Testing Pitfalls
- **Schema Complexity**: Large schemas are difficult to test completely
- **Query Parsing**: GraphQL query parsing can be complex
- **Authorization Logic**: Field-level authorization is hard to test
- **Performance Testing**: DoS testing can impact production systems
- **Subscription Testing**: WebSocket testing requires special handling
- **Error Handling**: GraphQL errors may not indicate vulnerabilities
- **Context Dependency**: Authorization depends on user context
- **Resolver Logic**: Vulnerabilities may be in resolver functions

### Implementation Pitfalls
- **Exposed Introspection**: Leaving introspection enabled in production
- **Missing Depth Limits**: Not limiting query nesting depth
- **Weak Authorization**: Not implementing field-level authorization
- **No Rate Limiting**: Not limiting query complexity or frequency
- **Verbose Errors**: Exposing internal details in error messages
- **Missing Input Validation**: Not validating query arguments
- **Hardcoded Secrets**: Embedding secrets in GraphQL operations
- **No Logging**: Not logging GraphQL queries and mutations

## Integration Points

### CI/CD Integration
```yaml
# GitHub Actions workflow
name: GraphQL Security Testing
on: [push, pull_request]

jobs:
  graphql-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run GraphQL tests
        run: python -m graphql_tester scan --config config.yaml
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: graphql-results
          path: results/
```

### Monitoring Integration
```python
# Real-time GraphQL monitoring
import time
from datetime import datetime

class GraphQLMonitor:
    def __init__(self):
        self.queries = []
        self.alerts = []
    
    def monitor_query(self, query: str, user_id: str, 
                     response_time: float):
        """Monitor GraphQL query"""
        query_data = {
            'query': query[:500],
            'user_id': user_id,
            'response_time': response_time,
            'timestamp': datetime.now().isoformat()
        }
        
        self.queries.append(query_data)
        
        # Check for suspicious activity
        if self._is_suspicious(query):
            self.send_alert(query_data)
    
    def _is_suspicious(self, query: str) -> bool:
        """Check if query is suspicious"""
        suspicious_patterns = [
            r'__schema',
            r'__type',
            r'introspection',
            r'delete',
            r'drop',
            r'truncate',
        ]
        
        for pattern in suspicious_patterns:
            if re.search(pattern, query, re.IGNORECASE):
                return True
        
        return False
    
    def send_alert(self, query_data: Dict):
        """Send alert for suspicious activity"""
        alert = {
            'type': 'Suspicious GraphQL Activity',
            'details': query_data,
            'timestamp': datetime.now().isoformat()
        }
        self.alerts.append(alert)
```

### Reporting Integration
```python
class GraphQLReporter:
    def generate_report(self, scan_results: Dict) -> Dict:
        """Generate comprehensive GraphQL security report"""
        report = {
            'summary': {
                'total_vulnerabilities': len(scan_results['vulnerabilities']),
                'critical': len([v for v in scan_results['vulnerabilities'] if v['severity'] == 'critical']),
                'high': len([v for v in scan_results['vulnerabilities'] if v['severity'] == 'high']),
                'medium': len([v for v in scan_results['vulnerabilities'] if v['severity'] == 'medium']),
                'low': len([v for v in scan_results['vulnerabilities'] if v['severity'] == 'low']),
            },
            'vulnerabilities': scan_results['vulnerabilities'],
            'recommendations': scan_results['recommendations'],
            'generated_at': datetime.now().isoformat()
        }
        
        return report
```

## Practice Labs

### Lab 1: Introspection Testing
Create a GraphQL introspection tester that:
1. Tests introspection query accessibility
2. Extracts and analyzes schema
3. Identifies sensitive fields and types
4. Generates security report

### Lab 2: Query Depth Testing
Build a query depth tester that:
1. Tests increasing query depths
2. Measures server response time
3. Identifies DoS vulnerabilities
4. Recommends depth limits

### Lab 3: Authorization Testing
Develop a mutation authorization tester that:
1. Tests mutations without authentication
2. Tests with different user roles
3. Identifies authorization bypass
4. Generates exploit proofs

### Lab 4: Schema Analysis
Create a schema analyzer that:
1. Analyzes schema structure
2. Identifies security issues
3. Recommends improvements
4. Tracks changes over time

### Lab 5: Comprehensive GraphQL Scanner
Build a complete GraphQL scanning suite that:
1. Integrates all testing components
2. Provides unified reporting
3. Supports automated testing
4. Offers dashboard visualization

## Ethics

### Responsible GraphQL Testing
- **Authorization**: Only test GraphQL endpoints with explicit permission
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

### GraphQL Commands
```bash
# Introspection query
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"{ __schema { types { name } } }"}'

# Test mutation
curl -X POST https://target.com/graphql \
  -H "Content-Type: application/json" \
  -d '{"query":"mutation { deleteUser(id: 1) { success } }"}'

# Test subscription (WebSocket)
wscat -c wss://target.com/graphql \
  -x '{"type":"connection_init","payload":{}}'
```

### Common GraphQL Vulnerabilities
1. **Schema Disclosure**: Introspection query accessible
2. **Query Depth DoS**: Deep nested queries cause performance issues
3. **Authorization Bypass**: Mutations accessible without auth
4. **Batch Query Abuse**: Unlimited batch queries
5. **Information Disclosure**: Error messages expose internals
6. **Subscription Hijacking**: Unauthenticated real-time data

### Testing Checklist
- [ ] Test introspection accessibility
- [ ] Test query depth limits
- [ ] Test batch query restrictions
- [ ] Test mutation authorization
- [ ] Test subscription authentication
- [ ] Test error message disclosure
- [ ] Test field suggestion disclosure
- [ ] Test rate limiting
- [ ] Test input validation
- [ ] Test resolver security

### Troubleshooting Quick Fixes
1. **Introspection blocked**: Try alternative queries
2. **Query rejected**: Check query syntax
3. **Timeout issues**: Reduce query complexity
4. **Connection refused**: Verify endpoint URL
5. **Auth errors**: Check token format
6. **Performance issues**: Optimize query fields
7. **Error messages**: Analyze error responses
8. **Subscription fails**: Check WebSocket connection
