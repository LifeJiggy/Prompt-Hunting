# Automated Regex Pattern Extraction for Security Testing

## Expert Role
You are a regex pattern automation specialist and security engineer who designs, develops, and maintains automated systems for extracting sensitive information, detecting vulnerabilities, and analyzing code and traffic using regular expressions. Your expertise spans complex regex pattern development for security applications, including URL extraction, email harvesting, API key detection, secret scanning in codebases and traffic, vulnerability pattern matching, and bulk file processing at scale. You understand regex engine internals, performance optimization, lookahead/lookbehind assertions, capture groups, and pattern composition for multi-layered detection. Your role is to build robust, maintainable regex automation pipelines that integrate with security tools, CI/CD systems, and incident response workflows to continuously monitor for sensitive data exposure and security weaknesses.

## Core Concepts
- **Regular Expression Fundamentals**: Understanding regex syntax including character classes, quantifiers, anchors, groups, alternation, and escapes. Mastering greedy vs. lazy matching, backreferences, and atomic groups for precise pattern matching.
- **Lookahead and Lookbehind Assertions**: Zero-width assertions that match positions without consuming characters. Positive lookahead (?=...) matches if followed by pattern, negative lookahead (?!...) matches if not followed. Lookbehind (?<=...) and (?<!...) check preceding content.
- **Capture Groups and Backreferences**: Named groups (?P<name>...) for structured extraction, numbered groups for positional matching, and backreferences (\1, \2) for matching repeated patterns. Understanding group nesting and non-capturing groups (?:...).
- **Security-Specific Patterns**: Patterns designed to detect sensitive data: API keys, tokens, passwords, private keys, connection strings, AWS/Azure/GCP credentials, and other secrets that shouldn't be exposed in code or logs.
- **Vulnerability Pattern Matching**: Regex patterns that identify potential security vulnerabilities: SQL injection vectors, XSS payloads, path traversal attempts, command injection patterns, and insecure configurations.
- **Performance Optimization**: Understanding regex engine behavior, avoiding catastrophic backtracking, using atomic groups and possessive quantifiers, compiling patterns for reuse, and parallel execution for large datasets.
- **Bulk Processing Architecture**: Designing systems that process large volumes of files, codebases, logs, and network traffic efficiently. Using streaming processing, chunked reading, and parallel execution for scalability.
- **False Positive Reduction**: Combining regex with contextual analysis, entropy calculation, whitelisting, and multi-pattern validation to reduce false positive rates in secret detection.
- **Pattern Composition**: Building complex detection patterns from simpler building blocks. Creating modular pattern libraries that can be combined for comprehensive coverage.
- **Cross-Platform Compatibility**: Ensuring regex patterns work across different engines (PCRE, RE2, JavaScript, Python, .NET) with awareness of syntax differences and capabilities.

## Prerequisites
- Python 3.8+ with `re`, `regex`, and `pyyaml` libraries
- Understanding of regex syntax across multiple engines (PCRE, JavaScript, Python)
- Familiarity with security concepts: authentication, encryption, API security
- Knowledge of common secret formats (AWS keys, JWT tokens, SSH keys)
- Understanding of file encodings (UTF-8, ASCII, UTF-16)
- Basic knowledge of CI/CD systems and version control
- Command-line proficiency with grep, ripgrep, and find utilities
- Understanding of entropy calculation for secret detection
- Knowledge of common file formats (JSON, YAML, XML, config files)
- Text editor with regex support for pattern development

## Methodology

### Phase 1: Pattern Library Development
1. Research and catalog common secret formats across cloud providers and services
2. Develop base patterns for each secret type with high precision
3. Create vulnerability detection patterns based on OWASP guidelines
4. Build pattern validation test cases with known true/false positives
5. Document patterns with examples and usage guidelines

### Phase 2: Automation Framework Setup
1. Design modular architecture for pattern management
2. Implement pattern loading and compilation system
3. Build file discovery and filtering engine
4. Create parallel processing pipeline for bulk operations
5. Set up logging and metrics collection

### Phase 3: Extraction Engine Development
1. Implement streaming file processing for memory efficiency
2. Build pattern matching engine with context capture
3. Create result deduplication and normalization
4. Implement confidence scoring for findings
5. Build result storage and export system

### Phase 4: Validation and Enrichment
1. Implement entropy calculation for secret validation
2. Build contextual analysis for false positive reduction
3. Create whitelist management for known false positives
4. Implement secret format validation (checksums, structure)
5. Build enrichment pipeline with external data sources

### Phase 5: Integration and Reporting
1. Integrate with version control systems for code scanning
2. Build CI/CD pipeline integration for continuous monitoring
3. Implement real-time alerting for high-confidence findings
4. Create comprehensive reporting with evidence
5. Set up dashboards for metrics visualization

### Phase 6: Optimization and Maintenance
1. Profile and optimize slow patterns
2. Update patterns based on new findings
3. Maintain pattern library with community contributions
4. Implement A/B testing for pattern improvements
5. Archive and version pattern libraries

## Tool Arsenal

### Core Regex Engine
```python
import re
import regex
from typing import List, Dict, Tuple, Optional
from dataclasses import dataclass
from enum import Enum
import hashlib

class PatternType(Enum):
    SECRET = "secret"
    VULNERABILITY = "vulnerability"
    PII = "pii"
    CONFIGURATION = "configuration"
    CUSTOM = "custom"

@dataclass
class Pattern:
    name: str
    regex: str
    pattern_type: PatternType
    confidence: float
    description: str
    tags: List[str]
    examples: List[str]
    false_positives: List[str]

class RegexEngine:
    def __init__(self):
        self.compiled_patterns = {}
        self.pattern_library = []
    
    def add_pattern(self, pattern: Pattern):
        """Add and compile a pattern"""
        try:
            compiled = regex.compile(pattern.regex, regex.MULTILINE | regex.IGNORECASE)
            self.compiled_patterns[pattern.name] = {
                'compiled': compiled,
                'pattern': pattern
            }
            self.pattern_library.append(pattern)
        except regex.error as e:
            raise ValueError(f"Invalid regex for pattern {pattern.name}: {e}")
    
    def extract_matches(self, text: str, pattern_name: Optional[str] = None) -> List[Dict]:
        """Extract all matches from text"""
        matches = []
        
        patterns_to_check = self.compiled_patterns.items()
        if pattern_name:
            patterns_to_check = [(pattern_name, self.compiled_patterns.get(pattern_name))]
        
        for name, data in patterns_to_check:
            if data is None:
                continue
                
            compiled = data['compiled']
            pattern = data['pattern']
            
            for match in compiled.finditer(text):
                match_data = {
                    'pattern_name': name,
                    'pattern_type': pattern.pattern_type.value,
                    'match': match.group(),
                    'start': match.start(),
                    'end': match.end(),
                    'groups': match.groups(),
                    'named_groups': match.groupdict(),
                    'confidence': pattern.confidence,
                    'context': self._get_context(text, match.start(), match.end())
                }
                matches.append(match_data)
        
        return matches
    
    def _get_context(self, text: str, start: int, end: int, context_chars: int = 50) -> str:
        """Get surrounding context for a match"""
        context_start = max(0, start - context_chars)
        context_end = min(len(text), end + context_chars)
        return text[context_start:context_end]
    
    def calculate_entropy(self, text: str) -> float:
        """Calculate Shannon entropy of text"""
        if not text:
            return 0.0
        
        entropy = 0.0
        for char in set(text):
            p = text.count(char) / len(text)
            if p > 0:
                entropy -= p * math.log2(p)
        
        return entropy
    
    def validate_secret(self, secret: str, secret_type: str) -> bool:
        """Validate secret format based on type"""
        validators = {
            'aws_access_key': lambda s: s.startswith('AKIA') and len(s) == 20,
            'aws_secret_key': lambda s: len(s) == 40 and re.match(r'^[A-Za-z0-9/+=]+$', s),
            'jwt': lambda s: s.count('.') == 2 and len(s.split('.')[0]) > 0,
            'private_key': lambda s: '-----BEGIN' in s and 'PRIVATE KEY-----' in s,
            'github_token': lambda s: s.startswith(('ghp_', 'gho_', 'ghu_', 'ghs_', 'ghr_')) and len(s) > 30,
            'slack_token': lambda s: s.startswith(('xoxb-', 'xoxp-', 'xoxa-', 'xoxr-')) and len(s) > 30,
        }
        
        validator = validators.get(secret_type)
        if validator:
            return validator(secret)
        
        return True  # No specific validator, assume valid
```

### Secret Detection Patterns
```python
SECRET_PATTERNS = [
    Pattern(
        name="aws_access_key",
        regex=r"(?:^|[^A-Za-z0-9/+=])(AKIA[0-9A-Z]{16})(?:[^A-Za-z0-9/+=]|$)",
        pattern_type=PatternType.SECRET,
        confidence=0.95,
        description="AWS Access Key ID",
        tags=["aws", "cloud", "credentials"],
        examples=["AKIAIOSFODNN7EXAMPLE"],
        false_positives=["AKIA1234567890ABCDEF"]
    ),
    Pattern(
        name="aws_secret_key",
        regex=r"(?:aws_secret_access_key|AWS_SECRET_ACCESS_KEY|SecretAccessKey)['\"]?\s*[:=]\s*['\"]?([A-Za-z0-9/+=]{40})['\"]?",
        pattern_type=PatternType.SECRET,
        confidence=0.9,
        description="AWS Secret Access Key",
        tags=["aws", "cloud", "credentials"],
        examples=["wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"],
        false_positives=[]
    ),
    Pattern(
        name="github_token",
        regex=r"(?:ghp|gho|ghu|ghs|ghr)_[A-Za-z0-9_]{36,}",
        pattern_type=PatternType.SECRET,
        confidence=0.95,
        description="GitHub Personal Access Token",
        tags=["github", "token", "credentials"],
        examples=["ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef12"],
        false_positives=[]
    ),
    Pattern(
        name="slack_token",
        regex=r"xox[bpas]-[0-9]{10,}-[0-9a-zA-Z-]+",
        pattern_type=PatternType.SECRET,
        confidence=0.95,
        description="Slack Token",
        tags=["slack", "token", "credentials"],
        examples=["xoxb-XXXXXXXXXX-XXXXXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX"],
        false_positives=[]
    ),
    Pattern(
        name="jwt_token",
        regex=r"eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+",
        pattern_type=PatternType.SECRET,
        confidence=0.85,
        description="JSON Web Token",
        tags=["jwt", "token", "authentication"],
        examples=["eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0.abc123"],
        false_positives=[]
    ),
    Pattern(
        name="private_key",
        regex=r"-----BEGIN (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----[\s\S]*?-----END (?:RSA |EC |DSA |OPENSSH )?PRIVATE KEY-----",
        pattern_type=PatternType.SECRET,
        confidence=0.99,
        description="Private Key",
        tags=["crypto", "credentials", "sensitive"],
        examples=["-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA..."],
        false_positives=[]
    ),
    Pattern(
        name="connection_string",
        regex=r"(?:mongodb|mysql|postgres|redis|amqp)://[^\s]+",
        pattern_type=PatternType.SECRET,
        confidence=0.9,
        description="Database Connection String",
        tags=["database", "connection", "credentials"],
        examples=["mongodb://user:pass@host:27017/db"],
        false_positives=[]
    ),
    Pattern(
        name="api_key_generic",
        regex=r"(?:api[_-]?key|apikey|api[_-]?secret)['\"]?\s*[:=]\s*['\"]?([A-Za-z0-9\-_]{20,})['\"]?",
        pattern_type=PatternType.SECRET,
        confidence=0.7,
        description="Generic API Key",
        tags=["api", "key", "credentials"],
        examples=["api_key: abcdefghijklmnopqrstuvwxyz123456"],
        false_positives=[]
    ),
    Pattern(
        name="password_in_code",
        regex=r"(?:password|passwd|pwd)['\"]?\s*[:=]\s*['\"]([^\'\"]{6,})['\"]",
        pattern_type=PatternType.SECRET,
        confidence=0.8,
        description="Password in Code",
        tags=["password", "credentials", "hardcoded"],
        examples=["password = 'mypassword123'"],
        false_positives=[]
    ),
    Pattern(
        name="stripe_key",
        regex=r"(?:sk|pk)_(?:test|live)_[A-Za-z0-9]{20,}",
        pattern_type=PatternType.SECRET,
        confidence=0.95,
        description="Stripe API Key",
        tags=["payment", "stripe", "credentials"],
        examples=["sk_test_abc123def456ghi789"],
        false_positives=[]
    ),
    Pattern(
        name="google_api_key",
        regex=r"AIza[0-9A-Za-z_-]{35}",
        pattern_type=PatternType.SECRET,
        confidence=0.9,
        description="Google API Key",
        tags=["google", "api", "credentials"],
        examples=["AIzaSyD-example1234567890abcdefg"],
        false_positives=[]
    ),
    Pattern(
        name="heroku_api_key",
        regex=r"[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
        pattern_type=PatternType.SECRET,
        confidence=0.6,
        description="UUID Format Secret (Heroku)",
        tags=["heroku", "uuid", "credentials"],
        examples=["12345678-1234-1234-1234-123456789abc"],
        false_positives=[]
    ),
]
```

### Vulnerability Pattern Detection
```python
VULNERABILITY_PATTERNS = [
    Pattern(
        name="sql_injection",
        regex=r"(?:'|\")\s*(?:OR|AND|UNION|SELECT|INSERT|UPDATE|DELETE|DROP|EXEC|EXECUTE)\s+",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.8,
        description="SQL Injection Pattern",
        tags=["sqli", "injection", "database"],
        examples=["' OR '1'='1", "' UNION SELECT * FROM users--"],
        false_positives=[]
    ),
    Pattern(
        name="xss_pattern",
        regex=r"<script[^>]*>|javascript:|on(?:load|error|click|mouseover)\s*=",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.85,
        description="Cross-Site Scripting Pattern",
        tags=["xss", "injection", "web"],
        examples=["<script>alert('XSS')</script>", "javascript:alert(1)"],
        false_positives=[]
    ),
    Pattern(
        name="path_traversal",
        regex=r"\.\.\/|\.\.\\|%2e%2e%2f|%2e%2e\/|%2e%2e%5c",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.9,
        description="Path Traversal Pattern",
        tags=["lfi", "path-traversal", "file-system"],
        examples=["../../../etc/passwd", "..\\..\\windows\\system32"],
        false_positives=[]
    ),
    Pattern(
        name="command_injection",
        regex=r"[;&|`$]\s*(?:cat|ls|dir|type|echo|whoami|id|uname|wget|curl)\s",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.85,
        description="Command Injection Pattern",
        tags=["rce", "command-injection", "os"],
        examples=["; cat /etc/passwd", "| ls -la"],
        false_positives=[]
    ),
    Pattern(
        name="ssrf_pattern",
        regex=r"(?:https?|ftp):\/\/(?:localhost|127\.0\.0\.1|0\.0\.0\.0|169\.254\.169\.254)",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.8,
        description="SSRF Pattern - Internal Address",
        tags=["ssrf", "internal-network", "metadata"],
        examples=["http://169.254.169.254/latest/meta-data/"],
        false_positives=[]
    ),
    Pattern(
        name="insecure_http",
        regex=r"http:\/\/(?!localhost|127\.0\.0\.1|0\.0\.0\.0)",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.7,
        description="Insecure HTTP Usage",
        tags=["crypto", "transport", "misconfiguration"],
        examples=["http://example.com/api"],
        false_positives=[]
    ),
    Pattern(
        name="debug_mode",
        regex=r"(?:debug|DEBUG)\s*[:=]\s*(?:true|True|1|on|yes)",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.75,
        description="Debug Mode Enabled",
        tags=["configuration", "debug", "misconfiguration"],
        examples=["DEBUG = true", "debug: on"],
        false_positives=[]
    ),
    Pattern(
        name="hardcoded_ip",
        regex=r"\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b",
        pattern_type=PatternType.VULNERABILITY,
        confidence=0.6,
        description="Hardcoded IP Address",
        tags=["configuration", "network", "hardcoded"],
        examples=["192.168.1.100", "10.0.0.1"],
        false_positives=[]
    ),
]
```

### Bulk File Processor
```python
import os
import gzip
import hashlib
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed
from typing import Generator

class BulkFileProcessor:
    def __init__(self, engine: RegexEngine, max_workers: int = 4):
        self.engine = engine
        self.max_workers = max_workers
        self.results = []
        self.stats = {
            'files_scanned': 0,
            'matches_found': 0,
            'errors': 0,
            'bytes_processed': 0
        }
    
    def discover_files(self, root_path: str, extensions: List[str] = None, 
                       exclude_patterns: List[str] = None) -> Generator[Path, None, None]:
        """Discover files to scan"""
        root = Path(root_path)
        
        if extensions is None:
            extensions = [
                '.py', '.js', '.ts', '.java', '.go', '.rb', '.php',
                '.json', '.yaml', '.yml', '.toml', '.ini', '.cfg',
                '.env', '.config', '.xml', '.properties',
                '.md', '.txt', '.log', '.csv'
            ]
        
        for file_path in root.rglob('*'):
            if not file_path.is_file():
                continue
            
            # Check extension
            if extensions and file_path.suffix not in extensions:
                continue
            
            # Check exclude patterns
            if exclude_patterns:
                if any(pattern in str(file_path) for pattern in exclude_patterns):
                    continue
            
            yield file_path
    
    def read_file_content(self, file_path: Path) -> Optional[str]:
        """Read file content with encoding detection"""
        encodings = ['utf-8', 'ascii', 'latin-1', 'utf-16']
        
        for encoding in encodings:
            try:
                # Handle gzip files
                if file_path.suffix == '.gz':
                    with gzip.open(file_path, 'rt', encoding=encoding) as f:
                        return f.read()
                else:
                    with open(file_path, 'r', encoding=encoding) as f:
                        return f.read()
            except (UnicodeDecodeError, UnicodeError):
                continue
        
        return None
    
    def process_file(self, file_path: Path) -> Dict:
        """Process a single file"""
        try:
            content = self.read_file_content(file_path)
            if content is None:
                return {'file': str(file_path), 'error': 'Could not read file', 'matches': []}
            
            # Extract matches
            matches = self.engine.extract_matches(content)
            
            # Add file information to matches
            for match in matches:
                match['file'] = str(file_path)
                match['file_size'] = file_path.stat().st_size
                match['file_hash'] = self._calculate_file_hash(file_path)
            
            # Update statistics
            self.stats['files_scanned'] += 1
            self.stats['matches_found'] += len(matches)
            self.stats['bytes_processed'] += len(content.encode('utf-8'))
            
            return {
                'file': str(file_path),
                'matches': matches,
                'size': len(content)
            }
            
        except Exception as e:
            self.stats['errors'] += 1
            return {'file': str(file_path), 'error': str(e), 'matches': []}
    
    def _calculate_file_hash(self, file_path: Path) -> str:
        """Calculate SHA-256 hash of file"""
        sha256_hash = hashlib.sha256()
        with open(file_path, 'rb') as f:
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
        return sha256_hash.hexdigest()
    
    def process_directory(self, root_path: str, extensions: List[str] = None,
                         exclude_patterns: List[str] = None) -> List[Dict]:
        """Process all files in a directory"""
        files = list(self.discover_files(root_path, extensions, exclude_patterns))
        results = []
        
        with ProcessPoolExecutor(max_workers=self.max_workers) as executor:
            future_to_file = {
                executor.submit(self.process_file, file_path): file_path
                for file_path in files
            }
            
            for future in as_completed(future_to_file):
                file_path = future_to_file[future]
                try:
                    result = future.result()
                    results.append(result)
                except Exception as e:
                    results.append({
                        'file': str(file_path),
                        'error': str(e),
                        'matches': []
                    })
        
        self.results = results
        return results
    
    def generate_report(self) -> Dict:
        """Generate summary report"""
        all_matches = []
        for result in self.results:
            all_matches.extend(result.get('matches', []))
        
        # Group matches by pattern
        by_pattern = {}
        for match in all_matches:
            pattern = match['pattern_name']
            if pattern not in by_pattern:
                by_pattern[pattern] = []
            by_pattern[pattern].append(match)
        
        # Calculate confidence distribution
        confidence_dist = {
            'high': len([m for m in all_matches if m['confidence'] >= 0.9]),
            'medium': len([m for m in all_matches if 0.7 <= m['confidence'] < 0.9]),
            'low': len([m for m in all_matches if m['confidence'] < 0.7])
        }
        
        return {
            'statistics': self.stats,
            'total_matches': len(all_matches),
            'matches_by_pattern': by_pattern,
            'confidence_distribution': confidence_dist,
            'unique_files_with_matches': len(set(m['file'] for m in all_matches))
        }
```

### URL and Email Extraction
```python
class URLEmailExtractor:
    def __init__(self):
        self.url_pattern = re.compile(
            r'https?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
            re.IGNORECASE
        )
        self.email_pattern = re.compile(
            r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
            re.IGNORECASE
        )
        self.domain_pattern = re.compile(
            r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}',
            re.IGNORECASE
        )
    
    def extract_urls(self, text: str) -> List[Dict]:
        """Extract URLs with context"""
        urls = []
        for match in self.url_pattern.finditer(text):
            url = match.group()
            urls.append({
                'url': url,
                'start': match.start(),
                'end': match.end(),
                'context': self._get_context(text, match.start(), match.end()),
                'domain': self._extract_domain(url),
                'is_https': url.startswith('https://')
            })
        return urls
    
    def extract_emails(self, text: str) -> List[Dict]:
        """Extract email addresses with context"""
        emails = []
        for match in self.email_pattern.finditer(text):
            email = match.group()
            emails.append({
                'email': email,
                'start': match.start(),
                'end': match.end(),
                'context': self._get_context(text, match.start(), match.end()),
                'domain': email.split('@')[1],
                'is_corporate': self._is_corporate_email(email)
            })
        return emails
    
    def extract_domains(self, text: str) -> List[str]:
        """Extract unique domains"""
        domains = set()
        for match in self.domain_pattern.finditer(text):
            domain = match.group()
            if not domain.endswith(('.png', '.jpg', '.gif', '.css', '.js')):
                domains.add(domain)
        return sorted(list(domains))
    
    def _extract_domain(self, url: str) -> str:
        """Extract domain from URL"""
        from urllib.parse import urlparse
        try:
            parsed = urlparse(url)
            return parsed.netloc
        except:
            return ''
    
    def _is_corporate_email(self, email: str) -> bool:
        """Check if email is likely corporate (not personal)"""
        personal_domains = [
            'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com',
            'aol.com', 'icloud.com', 'mail.com', 'protonmail.com'
        ]
        domain = email.split('@')[1].lower()
        return domain not in personal_domains
    
    def _get_context(self, text: str, start: int, end: int, context_chars: int = 50) -> str:
        context_start = max(0, start - context_chars)
        context_end = min(len(text), end + context_chars)
        return text[context_start:context_end]
```

### Token Extraction and Analysis
```python
class TokenAnalyzer:
    def __init__(self):
        self.token_patterns = {
            'jwt': re.compile(r'eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+'),
            'bearer': re.compile(r'[Bb]earer\s+[A-Za-z0-9\-._~+/]+=*'),
            'basic': re.compile(r'[Bb]asic\s+[A-Za-z0-9+/]+=*'),
            'api_key': re.compile(r'[Aa]pi[-_]?[Kk]ey[:\s]+[A-Za-z0-9\-_]{20,}'),
            'oauth': re.compile(r'[Oo][Aa]uth[-_]?[Tt]oken[:\s]+[A-Za-z0-9\-_]{20,}'),
        }
    
    def extract_tokens(self, text: str) -> List[Dict]:
        """Extract all tokens from text"""
        tokens = []
        
        for token_type, pattern in self.token_patterns.items():
            for match in pattern.finditer(text):
                token = match.group()
                tokens.append({
                    'type': token_type,
                    'value': token,
                    'start': match.start(),
                    'end': match.end(),
                    'entropy': self._calculate_entropy(token),
                    'decoded': self._decode_token(token, token_type)
                })
        
        return tokens
    
    def analyze_jwt(self, jwt_token: str) -> Dict:
        """Analyze JWT token structure"""
        parts = jwt_token.split('.')
        if len(parts) != 3:
            return {'error': 'Invalid JWT format'}
        
        import base64
        import json
        
        def decode_base64url(data):
            # Add padding
            padding = 4 - len(data) % 4
            if padding != 4:
                data += '=' * padding
            # Replace URL-safe characters
            data = data.replace('-', '+').replace('_', '/')
            return base64.b64decode(data).decode('utf-8')
        
        try:
            header = json.loads(decode_base64url(parts[0]))
            payload = json.loads(decode_base64url(parts[1]))
            
            return {
                'header': header,
                'payload': payload,
                'algorithm': header.get('alg'),
                'expiry': payload.get('exp'),
                'issued_at': payload.get('iat'),
                'subject': payload.get('sub'),
                'issuer': payload.get('iss'),
                'is_expired': self._check_jwt_expiry(payload.get('exp'))
            }
        except Exception as e:
            return {'error': f'Failed to decode JWT: {str(e)}'}
    
    def _calculate_entropy(self, text: str) -> float:
        """Calculate Shannon entropy"""
        if not text:
            return 0.0
        
        entropy = 0.0
        for char in set(text):
            p = text.count(char) / len(text)
            if p > 0:
                entropy -= p * math.log2(p)
        
        return round(entropy, 3)
    
    def _decode_token(self, token: str, token_type: str) -> Optional[Dict]:
        """Decode token based on type"""
        if token_type == 'jwt':
            return self.analyze_jwt(token)
        elif token_type == 'basic':
            import base64
            try:
                encoded = token.split(' ')[1]
                decoded = base64.b64decode(encoded).decode('utf-8')
                username, password = decoded.split(':', 1)
                return {'username': username, 'password': password}
            except:
                return None
        return None
    
    def _check_jwt_expiry(self, exp_timestamp: Optional[int]) -> bool:
        """Check if JWT is expired"""
        if exp_timestamp is None:
            return False
        import time
        return time.time() > exp_timestamp
```

### Pattern Validation Test Suite
```python
class PatternValidator:
    def __init__(self, engine: RegexEngine):
        self.engine = engine
        self.test_results = {}
    
    def add_test_case(self, pattern_name: str, test_string: str, should_match: bool):
        """Add a test case for a pattern"""
        if pattern_name not in self.test_results:
            self.test_results[pattern_name] = {
                'true_positives': [],
                'false_negatives': [],
                'true_negatives': [],
                'false_positives': []
            }
        
        matches = self.engine.extract_matches(test_string, pattern_name)
        matched = len(matches) > 0
        
        if matched and should_match:
            self.test_results[pattern_name]['true_positives'].append(test_string)
        elif not matched and not should_match:
            self.test_results[pattern_name]['true_negatives'].append(test_string)
        elif matched and not should_match:
            self.test_results[pattern_name]['false_positives'].append(test_string)
        elif not matched and should_match:
            self.test_results[pattern_name]['false_negatives'].append(test_string)
    
    def validate_pattern(self, pattern_name: str) -> Dict:
        """Validate a pattern's accuracy"""
        if pattern_name not in self.test_results:
            return {'error': 'No test cases for pattern'}
        
        results = self.test_results[pattern_name]
        tp = len(results['true_positives'])
        tn = len(results['true_negatives'])
        fp = len(results['false_positives'])
        fn = len(results['false_negatives'])
        
        total = tp + tn + fp + fn
        if total == 0:
            return {'error': 'No test cases'}
        
        accuracy = (tp + tn) / total
        precision = tp / (tp + fp) if (tp + fp) > 0 else 0
        recall = tp / (tp + fn) if (tp + fn) > 0 else 0
        f1 = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
        
        return {
            'accuracy': round(accuracy, 3),
            'precision': round(precision, 3),
            'recall': round(recall, 3),
            'f1_score': round(f1, 3),
            'true_positives': tp,
            'true_negatives': tn,
            'false_positives': fp,
            'false_negatives': fn
        }
    
    def validate_all_patterns(self) -> Dict:
        """Validate all patterns with test cases"""
        validation_results = {}
        for pattern_name in self.test_results.keys():
            validation_results[pattern_name] = self.validate_pattern(pattern_name)
        return validation_results
```

## Case Studies

### Case Study 1: Automated Secret Scanning in CI/CD
**Scenario**: Development team needs to prevent secrets from being committed to version control.
**Approach**: Implemented pre-commit hooks and CI/CD pipeline integration using the regex engine. Custom patterns for internal API keys and tokens were developed. Entropy analysis added to reduce false positives.
**Findings**: Caught 47 secrets in the first month including AWS keys, database passwords, and internal API tokens. Prevented 12 potential data breaches.
**Outcome**: Zero secrets leaked to production in 6 months since implementation.

### Case Study 2: Log File Analysis for Security Incidents
**Scenario**: Security team needs to analyze 10GB of application logs for indicators of compromise.
**Approach**: Built streaming log processor using the bulk file processor with custom patterns for attack indicators. Implemented parallel processing for speed.
**Findings**: Identified 234 SQL injection attempts, 89 XSS attempts, 12 credential stuffing attacks, and 3 successful unauthorized access attempts.
**Outcome**: Complete security incident report with timeline and evidence for each finding.

### Case Study 3: Code Review Automation for Security
**Scenario**: Manual code review is too slow for the development velocity.
**Approach**: Integrated regex scanning into pull request workflow. Custom patterns for common vulnerability classes (SQLi, XSS, CSRF) with context-aware analysis.
**Findings**: Caught 156 security issues in pull requests over 3 months. Reduced security review time from 2 days to 2 hours per release.
**Outcome**: Security testing integrated into development workflow with automated feedback.

### Case Study 4: API Traffic Analysis
**Scenario**: Need to analyze API traffic for sensitive data exposure.
**Approach**: Built traffic analyzer using regex patterns for PII, credentials, and sensitive data. Integrated with proxy logs for real-time monitoring.
**Findings**: Discovered 89 instances of PII in API responses, 23 instances of verbose error messages, and 5 hardcoded credentials in API documentation.
**Outcome**: API security hardening plan with specific remediation for each finding.

### Case Study 5: Cloud Configuration Audit
**Scenario**: Need to audit cloud configuration files for security misconfigurations.
**Approach**: Developed patterns for AWS, Azure, and GCP configuration files. Scanned entire infrastructure codebase for misconfigurations.
**Findings**: Found 34 misconfigurations including public S3 buckets, overly permissive IAM policies, and exposed database credentials.
**Outcome**: Complete cloud security posture assessment with remediation recommendations.

### Case Study 6: Compliance Monitoring
**Scenario**: Organization needs to maintain compliance with GDPR, HIPAA, and PCI DSS.
**Approach**: Built compliance scanning system with patterns for each regulation. Automated scanning of codebase and data stores.
**Findings**: Identified 67 compliance violations across 3 regulations. Found 23 instances of unencrypted PII, 12 instances of missing access controls.
**Outcome**: Compliance dashboard with real-time monitoring and automated reporting.

## Bypass Techniques

### Encoding Bypass Detection
```python
class EncodingBypassDetector:
    def __init__(self):
        self.encoding_patterns = {
            'url_encoding': re.compile(r'%[0-9a-fA-F]{2}'),
            'unicode_escape': re.compile(r'\\u[0-9a-fA-F]{4}'),
            'hex_encoding': re.compile(r'\\x[0-9a-fA-F]{2}'),
            'base64': re.compile(r'[A-Za-z0-9+/]{20,}={0,2}'),
            'html_entities': re.compile(r'&[a-zA-Z]+;|&#[0-9]+;'),
        }
    
    def detect_encoding(self, text: str) -> Dict[str, List]:
        """Detect encoded content in text"""
        findings = {}
        for encoding_type, pattern in self.encoding_patterns.items():
            matches = pattern.findall(text)
            if matches:
                findings[encoding_type] = matches
        return findings
    
    def decode_and_analyze(self, text: str, engine: RegexEngine) -> List[Dict]:
        """Decode encoded content and analyze"""
        findings = []
        
        # Try URL decoding
        try:
            from urllib.parse import unquote
            decoded = unquote(text)
            matches = engine.extract_matches(decoded)
            for match in matches:
                match['encoding'] = 'url_encoded'
                match['original'] = text
                findings.append(match)
        except:
            pass
        
        # Try base64 decoding
        try:
            import base64
            # Try different padding
            for padding in range(4):
                try:
                    padded = text + '=' * padding
                    decoded = base64.b64decode(padded).decode('utf-8')
                    matches = engine.extract_matches(decoded)
                    for match in matches:
                        match['encoding'] = 'base64'
                        match['original'] = text
                        findings.append(match)
                    break
                except:
                    continue
        except:
            pass
        
        return findings
```

### Obfuscation Detection
```python
class ObfuscationDetector:
    def __init__(self):
        self.obfuscation_patterns = {
            'string_concat': re.compile(r'["\'][^"\']*["\'](?:\s*\+\s*["\'][^"\']*["\'])+'),
            'char_code': re.compile(r'String\.fromCharCode\((?:[0-9]+(?:\s*,\s*|\)))+\)'),
            'eval_usage': re.compile(r'eval\([^)]+\)'),
            'atob_usage': re.compile(r'atob\([^)]+\)'),
            'hex_string': re.compile(r'\\x[0-9a-fA-F]{2}(?:\\x[0-9a-fA-F]{2})*'),
        }
    
    def detect_obfuscation(self, text: str) -> Dict[str, List]:
        """Detect obfuscation techniques"""
        findings = {}
        for technique, pattern in self.obfuscation_patterns.items():
            matches = pattern.findall(text)
            if matches:
                findings[technique] = matches
        return findings
    
    def deobfuscate_string_concat(self, text: str) -> str:
        """Deobfuscate string concatenation"""
        import ast
        try:
            # Wrap in quotes for proper parsing
            if not text.startswith('"') and not text.startswith("'"):
                text = f'"{text}"'
            # Use ast.literal_eval for safe evaluation
            return ast.literal_eval(text)
        except:
            return text
```

### Whitespace and Comment Evasion
```python
class WhitespaceEvader:
    def __init__(self):
        self.whitespace_chars = {
            'space': ' ',
            'tab': '\t',
            'newline': '\n',
            'carriage_return': '\r',
            'form_feed': '\f',
            'vertical_tab': '\v',
            'non_breaking_space': '\u00a0',
            'zero_width_space': '\u200b',
        }
    
    def normalize_whitespace(self, text: str) -> str:
        """Normalize all whitespace to standard space"""
        normalized = text
        for char_name, char_value in self.whitespace_chars.items():
            normalized = normalized.replace(char_value, ' ')
        # Collapse multiple spaces
        normalized = re.sub(r' +', ' ', normalized)
        return normalized.strip()
    
    def remove_comments(self, text: str, language: str = 'javascript') -> str:
        """Remove comments from code"""
        if language in ['javascript', 'typescript', 'java', 'c', 'cpp']:
            # Remove single-line comments
            text = re.sub(r'//.*$', '', text, flags=re.MULTILINE)
            # Remove multi-line comments
            text = re.sub(r'/\*[\s\S]*?\*/', '', text)
        elif language == 'python':
            # Remove single-line comments
            text = re.sub(r'#.*$', '', text, flags=re.MULTILINE)
            # Remove multi-line strings (docstrings)
            text = re.sub(r'"""[\s\S]*?"""', '', text)
            text = re.sub(r"'''[\s\S]*?'''", '', text)
        return text
```

## Advanced Techniques

### Multi-Pattern Composite Detection
```python
class CompositeDetector:
    def __init__(self, engine: RegexEngine):
        self.engine = engine
        self.composite_rules = []
    
    def add_composite_rule(self, name: str, patterns: List[str], 
                          logic: str = 'AND', description: str = ''):
        """Add a composite detection rule"""
        self.composite_rules.append({
            'name': name,
            'patterns': patterns,
            'logic': logic,
            'description': description
        })
    
    def evaluate_composite_rules(self, text: str) -> List[Dict]:
        """Evaluate all composite rules against text"""
        findings = []
        
        for rule in self.composite_rules:
            pattern_matches = {}
            for pattern_name in rule['patterns']:
                matches = self.engine.extract_matches(text, pattern_name)
                pattern_matches[pattern_name] = len(matches) > 0
            
            # Evaluate logic
            if rule['logic'] == 'AND':
                result = all(pattern_matches.values())
            elif rule['logic'] == 'OR':
                result = any(pattern_matches.values())
            elif rule['logic'] == 'NOT':
                result = not all(pattern_matches.values())
            else:
                result = False
            
            if result:
                findings.append({
                    'rule_name': rule['name'],
                    'description': rule['description'],
                    'logic': rule['logic'],
                    'pattern_results': pattern_matches
                })
        
        return findings
```

### Context-Aware Detection
```python
class ContextAwareDetector:
    def __init__(self, engine: RegexEngine):
        self.engine = engine
        self.context_rules = {
            'comment': re.compile(r'(?:/\*|\*|//|#|--)\s*.*', re.MULTILINE),
            'test': re.compile(r'(?:test|spec|mock|fake|dummy|example)', re.IGNORECASE),
            'documentation': re.compile(r'(?:doc|readme|changelog|license)', re.IGNORECASE),
            'variable_assignment': re.compile(r'(?:var|let|const|private|public|protected)\s+\w+\s*='),
        }
    
    def analyze_context(self, text: str, match_start: int, match_end: int) -> Dict:
        """Analyze context around a match"""
        # Get surrounding lines
        lines = text[:match_end].split('\n')
        line_number = len(lines)
        current_line = lines[-1] if lines else ''
        
        # Get previous lines for context
        start_line = max(0, line_number - 5)
        end_line = min(len(lines), line_number + 5)
        context_lines = lines[start_line:end_line]
        
        context_analysis = {
            'line_number': line_number,
            'current_line': current_line,
            'context_lines': context_lines,
            'in_comment': False,
            'in_test': False,
            'in_documentation': False,
            'is_assignment': False
        }
        
        # Analyze context
        for line in context_lines:
            if self.context_rules['comment'].search(line):
                context_analysis['in_comment'] = True
            if self.context_rules['test'].search(line):
                context_analysis['in_test'] = True
            if self.context_rules['documentation'].search(line):
                context_analysis['in_documentation'] = True
            if self.context_rules['variable_assignment'].search(line):
                context_analysis['is_assignment'] = True
        
        return context_analysis
    
    def filter_matches_by_context(self, matches: List[Dict], text: str) -> List[Dict]:
        """Filter matches based on context analysis"""
        filtered_matches = []
        
        for match in matches:
            context = self.analyze_context(text, match['start'], match['end'])
            
            # Apply context-based filtering
            if context['in_comment'] and context['confidence'] < 0.9:
                continue  # Skip low-confidence matches in comments
            if context['in_test'] and context['confidence'] < 0.8:
                continue  # Skip low-confidence matches in test files
            if context['in_documentation']:
                continue  # Skip matches in documentation
            
            match['context'] = context
            filtered_matches.append(match)
        
        return filtered_matches
```

## Detection Indicators

### Regex-Specific Artifacts
- Patterns with catastrophic backtracking vulnerabilities
- Overly broad patterns generating high false positive rates
- Patterns with known bypass techniques
- Inconsistent pattern behavior across regex engines
- Patterns not handling Unicode properly
- Patterns with hardcoded values that may change
- Patterns not accounting for encoding variations
- Patterns with performance issues on large inputs

### Processing Indicators
- High memory usage during pattern matching
- Slow execution times on large files
- Inconsistent results across different file encodings
- Missing matches due to line ending differences
- False positives from pattern overlap
- Incomplete coverage of target patterns
- Patterns not updated for new secret formats
- Missing validation for detected secrets

## Impact Assessment

### Pattern Effectiveness Metrics
- **Detection Rate**: Percentage of true secrets detected
- **False Positive Rate**: Percentage of false positives in findings
- **Coverage**: Percentage of secret types covered by patterns
- **Performance**: Time to scan typical codebase
- **Maintenance Effort**: Time required to update patterns
- **Integration Success**: Ease of integration with existing tools
- **User Adoption**: Percentage of development teams using the system
- **Breach Prevention**: Number of secrets prevented from leaking

### Business Impact
- **Risk Reduction**: Reduction in potential data breaches
- **Compliance**: Achievement of compliance requirements
- **Developer Productivity**: Reduction in manual security review time
- **Incident Response**: Faster identification and remediation of exposures
- **Cost Savings**: Avoided costs from potential breaches
- **Reputation**: Protection of brand reputation
- **Audit Readiness**: Improved audit trail and documentation
- **Security Culture**: Improved security awareness among developers

## Common Pitfalls

### Pattern Development Pitfalls
- **Overly Broad Patterns**: Patterns that match too much, causing false positives
- **Catastrophic Backtracking**: Patterns with exponential time complexity
- **Engine Incompatibility**: Patterns that work in one engine but not another
- **Encoding Issues**: Patterns not handling different encodings properly
- **Unicode Problems**: Patterns failing on Unicode characters
- **Case Sensitivity**: Inconsistent case handling across patterns
- **Boundary Issues**: Patterns not matching at string boundaries
- **Escaping Errors**: Incorrectly escaped special characters

### Implementation Pitfalls
- **Memory Exhaustion**: Loading entire files into memory
- **Performance Issues**: Not optimizing for large files
- **Concurrency Problems**: Race conditions in parallel processing
- **Error Handling**: Not handling file read errors gracefully
- **Logging**: Insufficient logging for debugging
- **Configuration**: Hardcoded values instead of configuration
- **Testing**: Inadequate test coverage for patterns
- **Documentation**: Poor documentation for pattern usage

## Integration Points

### Version Control Integration
```python
class GitIntegration:
    def __init__(self, repo_path: str):
        self.repo_path = repo_path
    
    def get_changed_files(self, commit_hash: str) -> List[str]:
        """Get files changed in a commit"""
        import subprocess
        result = subprocess.run(
            ['git', 'diff-tree', '--no-commit-id', '--name-only', '-r', commit_hash],
            cwd=self.repo_path,
            capture_output=True,
            text=True
        )
        return result.stdout.strip().split('\n')
    
    def scan_commit(self, commit_hash: str, engine: RegexEngine) -> Dict:
        """Scan all files in a commit"""
        changed_files = self.get_changed_files(commit_hash)
        results = []
        
        for file_path in changed_files:
            full_path = os.path.join(self.repo_path, file_path)
            if os.path.exists(full_path):
                processor = BulkFileProcessor(engine)
                result = processor.process_file(Path(full_path))
                results.append(result)
        
        return {
            'commit': commit_hash,
            'files_scanned': len(changed_files),
            'results': results
        }
```

### CI/CD Pipeline Integration
```yaml
# GitHub Actions workflow
name: Secret Scanning
on: [push, pull_request]

jobs:
  scan:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: pip install -r requirements.txt
      - name: Run secret scanning
        run: python -m secret_scanner scan --path . --output results.json
      - name: Upload results
        uses: actions/upload-artifact@v3
        with:
          name: scan-results
          path: results.json
```

### Alerting Integration
```python
import requests

class AlertManager:
    def __init__(self, webhook_url: str):
        self.webhook_url = webhook_url
    
    def send_alert(self, findings: Dict):
        """Send alert for high-confidence findings"""
        high_confidence = [
            f for f in findings.get('matches', [])
            if f.get('confidence', 0) >= 0.9
        ]
        
        if high_confidence:
            payload = {
                'text': f'🚨 High-confidence secrets detected: {len(high_confidence)} findings',
                'findings': high_confidence[:10]  # Limit to first 10
            }
            requests.post(self.webhook_url, json=payload)
```

## Practice Labs

### Lab 1: Pattern Development
Create a regex pattern library for:
1. AWS credentials (access keys, secret keys, session tokens)
2. GitHub tokens (personal access, OAuth, app tokens)
3. Database connection strings (MongoDB, MySQL, PostgreSQL)
4. Private keys (RSA, EC, SSH)
5. Generic API keys with validation

### Lab 2: Bulk Scanner
Build a bulk file scanner that:
1. Discovers all files in a directory tree
2. Reads files with encoding detection
3. Applies multiple pattern sets in parallel
4. Generates detailed reports with context
5. Handles large files efficiently

### Lab 3: Validation Framework
Create a pattern validation system that:
1. Defines test cases for each pattern
2. Calculates precision, recall, and F1 scores
3. Identifies patterns needing improvement
4. Generates validation reports
5. Tracks pattern performance over time

### Lab 4: Context-Aware Analysis
Build a context-aware analyzer that:
1. Identifies surrounding code context
2. Filters findings based on context
3. Provides confidence adjustments
4. Generates context-enriched reports
5. Reduces false positives through analysis

### Lab 5: Integration Project
Create a complete integration that:
1. Hooks into git pre-commit
2. Integrates with CI/CD pipeline
3. Sends alerts for high-severity findings
4. Generates compliance reports
5. Tracks metrics over time

## Ethics

### Responsible Secret Detection
- **Authorization**: Only scan codebases and systems you have permission to access
- **Data Handling**: Treat all detected secrets as confidential
- **Disclosure**: Report findings through responsible disclosure channels
- **Storage**: Don't store detected secrets longer than necessary
- **Access Control**: Limit access to scan results to authorized personnel
- **Encryption**: Encrypt scan results at rest and in transit
- **Retention**: Implement data retention policies for scan results
- **Audit**: Maintain audit logs of all scanning activities
- **Compliance**: Follow applicable regulations (GDPR, HIPAA, etc.)
- **Training**: Educate users on proper handling of detected secrets

## Quick Reference

### Common Regex Patterns
```regex
# Email
[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}

# URL
https?://[^\s]+

# IPv4
\b(?:[0-9]{1,3}\.){3}[0-9]{1,3}\b

# Date (YYYY-MM-DD)
\d{4}-(?:0[1-9]|1[0-2])-(?:0[1-9]|[12]\d|3[01])

# Credit Card
\b(?:\d[ -]*?){13,16}\b

# AWS Access Key
AKIA[0-9A-Z]{16}

# GitHub Token
ghp_[A-Za-z0-9]{36}

# JWT
eyJ[A-Za-z0-9_-]*\.eyJ[A-Za-z0-9_-]*\.[A-Za-z0-9_-]+

# Private Key
-----BEGIN (?:RSA |EC |DSA )?PRIVATE KEY-----
```

### Python Regex Flags
```python
import re

# Case-insensitive
re.IGNORECASE or re.I

# Multiline (^ and $ match line boundaries)
re.MULTILINE or re.M

# Dot matches newline
re.DOTALL or re.S

# Unicode matching
re.UNICODE or re.U

# Verbose (allows comments)
re.VERBOSE or re.X
```

### Performance Tips
1. **Compile patterns**: Use `re.compile()` for repeated use
2. **Use non-capturing groups**: `(?:...)` instead of `(...)` when not capturing
3. **Avoid catastrophic backtracking**: Be specific with quantifiers
4. **Use atomic groups**: `(?>...)` where available
5. **Prefer simpler patterns**: Break complex patterns into simpler ones
6. **Test with real data**: Validate patterns against actual inputs
7. **Profile regularly**: Identify slow patterns and optimize
8. **Use appropriate tools**: `ripgrep` for file scanning, `regex` library for advanced features

### Debugging Techniques
```python
# Test a pattern
import re
pattern = re.compile(r'your-pattern')
test_string = 'your-test-string'
match = pattern.search(test_string)
if match:
    print(f"Matched: {match.group()}")
    print(f"Groups: {match.groups()}")
    print(f"Start: {match.start()}, End: {match.end()}")

# Use regex101.com for visual debugging
# Test with edge cases
# Check for performance issues with large inputs
```

### Troubleshooting Quick Fixes
1. **No matches**: Check pattern syntax, test with simpler input
2. **Too many matches**: Make pattern more specific, add word boundaries
3. **Slow performance**: Optimize pattern, avoid backtracking
4. **Encoding errors**: Handle different encodings, use Unicode patterns
5. **False positives**: Add context analysis, improve pattern specificity
6. **Missing matches**: Check line endings, handle different formats
7. **Group issues**: Use named groups, verify capture group numbering
8. **Engine differences**: Test across target engines, use compatible syntax
