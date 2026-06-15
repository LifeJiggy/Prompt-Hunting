# Automation-Efficiency 30: Security for Automation Tools

## Expert Role

You are an elite Bug Bounty Security Architect specializing in securing automation toolchains used in authorized security testing. You understand that the tools used for bug bounty hunting can themselves become attack vectors if improperly secured. Your expertise covers credential management, secrets vault integration, access control, secure configuration, and operational security for automated scanning pipelines.

Your core competencies include:
- Designing zero-trust architectures for bug bounty automation infrastructure
- Implementing secrets management using vaults, environment variables, and encrypted storage
- Building access control systems that limit tool capabilities to minimum required privileges
- Auditing automation configurations for credential leakage and misconfiguration
- Establishing operational security procedures that protect hunter identity and target data

---

## Core Concepts

### The Security Paradox of Security Tools

Bug bounty tools are designed to find vulnerabilities, but they can also introduce them:

1. **Credential Exposure**: API keys, tokens, and passwords stored in plaintext configs
2. **Data Leakage**: Scan results containing sensitive target data stored insecurely
3. **Tool Compromise**: Malicious dependencies or supply chain attacks on automation tools
4. **Privilege Escalation**: Tools running with excessive permissions beyond what's needed
5. **Identity Exposure**: Hunter IP addresses, user agents, and patterns revealing identity

### Threat Model for Bug Bounty Automation

| Threat | Impact | Likelihood | Mitigation |
|--------|--------|------------|------------|
| Credential theft from config files | High | Medium | Secrets vault, encrypted storage |
| Scan data exposure | High | Medium | Encryption at rest and in transit |
| Tool supply chain attack | Critical | Low | Dependency verification, lockfiles |
| API key abuse | High | Medium | Key rotation, usage monitoring |
| Identity correlation | Medium | Medium | Proxy rotation, persona separation |
| Local privilege escalation | High | Low | Minimal permissions, sandboxing |
| Cloud credential exposure | Critical | Medium | IAM policies, metadata protection |

### Security Architecture Layers

```
Layer 1: Identity & Access Management
    - Separate accounts for automation
    - Minimal privilege principle
    - MFA on all management interfaces

Layer 2: Secrets Management
    - Vault-based secret storage
    - Automatic credential rotation
    - Encrypted local cache

Layer 3: Network Security
    - VPN/Tor for scan traffic
    - DNS leak protection
    - Certificate pinning

Layer 4: Data Protection
    - Encryption at rest for all findings
    - Secure deletion of temporary files
    - PII handling procedures

Layer 5: Operational Security
    - Persona separation
    - Audit logging
    - Incident response procedures
```

---

## Prerequisites

### Required Knowledge
- Python security best practices (keyring, cryptography library)
- Environment variable management and .env file security
- Basic understanding of OAuth2, API key management
- Familiarity with secrets vault systems (HashiCorp Vault, AWS Secrets Manager)

### Required Tools
```bash
pip install keyring cryptography python-dotenv secretsmanage
```

### Security Audit Checklist
Before implementing security measures, audit current state:
- [ ] All credentials identified and inventoried
- [ ] Current storage methods documented
- [ ] Access patterns mapped
- [ ] Rotation schedules established
- [ ] Incident response plan created

---

## Methodology

### Phase 1: Credential Inventory and Classification

**Step 1: Credential Discovery and Cataloging**

```python
import os
import re
import json
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, asdict
from typing import List, Optional
from enum import Enum

class CredentialType(Enum):
    API_KEY = "api_key"
    OAUTH_TOKEN = "oauth_token"
    PASSWORD = "password"
    SSH_KEY = "ssh_key"
    CERTIFICATE = "certificate"
    DATABASE_URL = "database_url"
    WEBHOOK_SECRET = "webhook_secret"

@dataclass
class Credential:
    name: str
    cred_type: CredentialType
    location: str
    service: str
    owner: str
    created_at: str
    last_rotated: str
    rotation_days: int
    in_use: bool
    risk_level: str  # critical, high, medium, low

class CredentialAuditor:
    """Audit and inventory all credentials in automation workspace."""
    
    CREDENTIAL_PATTERNS = {
        "api_key": [
            r'(?i)(api[_-]?key|apikey)\s*[=:]\s*["\']([^"\']+)["\']',
            r'(?i)(key|token)\s*[=:]\s*["\']([A-Za-z0-9_\-]{20,})["\']',
        ],
        "secret": [
            r'(?i)(secret|secret[_-]?key)\s*[=:]\s*["\']([^"\']+)["\']',
            r'(?i)(password|passwd|pwd)\s*[=:]\s*["\']([^"\']+)["\']',
        ],
        "token": [
            r'(?i)(token|access[_-]?token|auth[_-]?token)\s*[=:]\s*["\']([^"\']+)["\']',
            r'(?i)(bearer)\s+[A-Za-z0-9_\-\.]+',
        ],
        "aws": [
            r'(?i)AKIA[0-9A-Z]{16}',
            r'(?i)(aws[_-]?access[_-]?key[_-]?id|aws[_-]?secret[_-]?access[_-]?key)',
        ],
        "github": [
            r'ghp_[A-Za-z0-9]{36}',
            r'(?i)github[_-]?token',
        ],
    }
    
    def __init__(self, workspace_path):
        self.workspace = Path(workspace_path)
        self.credentials = []
    
    def scan_workspace(self):
        """Scan workspace for credentials in files."""
        file_patterns = [
            "*.py", "*.yaml", "*.yml", "*.json", "*.toml",
            "*.env", "*.ini", "*.cfg", "*.conf", "*.sh",
            "*.md", "*.txt"
        ]
        
        for pattern in file_patterns:
            for file_path in self.workspace.rglob(pattern):
                if ".git" in file_path.parts:
                    continue
                
                self._scan_file(file_path)
        
        return self.credentials
    
    def _scan_file(self, file_path):
        """Scan individual file for credential patterns."""
        try:
            content = file_path.read_text(encoding='utf-8', errors='ignore')
        except Exception:
            return
        
        for cred_type, patterns in self.CREDENTIAL_PATTERNS.items():
            for pattern in patterns:
                matches = re.finditer(pattern, content)
                for match in matches:
                    cred = Credential(
                        name=match.group(0)[:50],
                        cred_type=CredentialType(cred_type),
                        location=str(file_path),
                        service=self._detect_service(content, match),
                        owner="unknown",
                        created_at=datetime.now().isoformat(),
                        last_rotated="unknown",
                        rotation_days=90,
                        in_use=True,
                        risk_level=self._assess_risk(cred_type, file_path)
                    )
                    self.credentials.append(cred)
    
    def _detect_service(self, content, match):
        """Detect which service the credential belongs to."""
        service_indicators = {
            "github": ["github.com", "GITHUB_TOKEN"],
            "hackerone": ["hackerone.com", "H1_"],
            "bugcrowd": ["bugcrowd.com", "BUGCROWD_"],
            "shodan": ["shodan.io", "SHODAN_"],
            "censys": ["censys.io", "CENSYS_"],
            "virustotal": ["virustotal.com", "VT_"],
            "aws": ["amazonaws.com", "AWS_"],
            "cloudflare": ["cloudflare.com", "CF_"],
        }
        
        for service, indicators in service_indicators.items():
            for indicator in indicators:
                if indicator.lower() in content.lower():
                    return service
        
        return "unknown"
    
    def _assess_risk(self, cred_type, file_path):
        """Assess risk level based on credential type and location."""
        risk_factors = []
        
        if cred_type in ["api_key", "secret", "password"]:
            risk_factors.append("sensitive_type")
        
        if ".env" in str(file_path):
            risk_factors.append("env_file")
        
        if ".git" in str(file_path):
            risk_factors.append("version_control")
        
        if "config" in str(file_path).lower():
            risk_factors.append("config_file")
        
        if len(risk_factors) >= 2:
            return "critical"
        elif len(risk_factors) == 1:
            return "high"
        else:
            return "medium"
    
    def generate_report(self):
        """Generate credential audit report."""
        report = {
            "scan_date": datetime.now().isoformat(),
            "total_credentials": len(self.credentials),
            "by_type": {},
            "by_risk": {"critical": [], "high": [], "medium": [], "low": []},
            "by_service": {},
            "recommendations": []
        }
        
        for cred in self.credentials:
            # By type
            if cred.cred_type.value not in report["by_type"]:
                report["by_type"][cred.cred_type.value] = []
            report["by_type"][cred.cred_type.value].append(cred.name)
            
            # By risk
            report["by_risk"][cred.risk_level].append({
                "name": cred.name,
                "location": cred.location,
                "service": cred.service
            })
            
            # By service
            if cred.service not in report["by_service"]:
                report["by_service"][cred.service] = []
            report["by_service"][cred.service].append(cred.name)
        
        # Generate recommendations
        if report["by_risk"]["critical"]:
            report["recommendations"].append(
                "IMMEDIATE: Rotate all critical-risk credentials"
            )
        if len(self.credentials) > 10:
            report["recommendations"].append(
                "Consider using a centralized secrets vault"
            )
        
        return report
```

**Step 2: Secrets Vault Implementation**

```python
import keyring
import hashlib
from base64 import b64encode, b64decode
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

class SecretsManager:
    """Centralized secrets management for automation tools."""
    
    def __init__(self, service_name="bugbounty-automation"):
        self.service_name = service_name
        self._ensure_keyring_backend()
    
    def _ensure_keyring_backend(self):
        """Configure keyring backend for cross-platform support."""
        try:
            import keyring.backends.Windows
            keyring.set_keyring(keyring.backends.Windows.WinVaultKeyring())
        except Exception:
            pass
    
    def store_secret(self, key, value, description=""):
        """Store a secret in the system keyring."""
        keyring.set_password(self.service_name, key, value)
        
        # Log rotation metadata
        metadata = {
            "stored_at": datetime.now().isoformat(),
            "description": description,
            "key_hash": hashlib.sha256(key.encode()).hexdigest()[:16]
        }
        
        metadata_key = f"{key}_metadata"
        keyring.set_password(self.service_name, metadata_key, json.dumps(metadata))
        
        return True
    
    def retrieve_secret(self, key):
        """Retrieve a secret from the system keyring."""
        value = keyring.get_password(self.service_name, key)
        
        if value is None:
            raise KeyError(f"Secret not found: {key}")
        
        return value
    
    def delete_secret(self, key):
        """Delete a secret from the system keyring."""
        keyring.delete_password(self.service_name, key)
        
        # Clean up metadata
        try:
            keyring.delete_password(self.service_name, f"{key}_metadata")
        except KeyError:
            pass
        
        return True
    
    def list_secrets(self):
        """List all stored secrets (names only, not values)."""
        secrets = []
        
        # This is platform-dependent; keyring doesn't have a universal list method
        # We maintain our own index
        index_key = "_secrets_index"
        try:
            index_json = keyring.get_password(self.service_name, index_key)
            if index_json:
                secrets = json.loads(index_json)
        except Exception:
            pass
        
        return secrets
    
    def rotate_secret(self, key, new_value):
        """Rotate a secret with history tracking."""
        old_value = self.retrieve_secret(key)
        
        # Store new value
        self.store_secret(key, new_value, description="Rotated")
        
        # Archive old value
        archive_key = f"{key}_archived_{datetime.now().strftime('%Y%m%d')}"
        self.store_secret(archive_key, old_value, description="Archived during rotation")
        
        return True
    
    def export_for_tool(self, tool_name):
        """Export secrets in tool-specific format."""
        secrets = self.list_secrets()
        tool_secrets = {}
        
        for secret_name in secrets:
            if tool_name.lower() in secret_name.lower():
                value = self.retrieve_secret(secret_name)
                tool_secrets[secret_name] = value
        
        return tool_secrets

class EncryptedLocalCache:
    """Encrypted local cache for secrets when keyring is unavailable."""
    
    def __init__(self, master_password):
        self.master_password = master_password.encode()
        self._derive_key()
        self.cache_file = Path.home() / ".bugbounty_cache.enc"
    
    def _derive_key(self):
        """Derive encryption key from master password."""
        salt = b"bugbounty_salt_v1"  # In production, use random salt
        kdf = PBKDF2HMAC(
            algorithm=hashes.SHA256(),
            length=32,
            salt=salt,
            iterations=100000,
        )
        self.key = b64encode(kdf.derive(self.master_password))
        self.cipher = Fernet(self.key)
    
    def store(self, secrets_dict):
        """Store encrypted secrets cache."""
        data = json.dumps(secrets_dict).encode()
        encrypted = self.cipher.encrypt(data)
        
        self.cache_file.write_bytes(encrypted)
        self.cache_file.chmod(0o600)
    
    def retrieve(self):
        """Retrieve and decrypt secrets cache."""
        if not self.cache_file.exists():
            return {}
        
        encrypted = self.cache_file.read_bytes()
        decrypted = self.cipher.decrypt(encrypted)
        
        return json.loads(decrypted.decode())
```

### Phase 2: Secure Configuration Management

**Step 3: Environment-Based Configuration**

```python
from dotenv import load_dotenv
import os

class SecureConfig:
    """Secure configuration management using environment variables."""
    
    REQUIRED_VARS = [
        "HACKERONE_API_TOKEN",
        "SHODAN_API_KEY",
        "CENSYS_API_ID",
        "CENSYS_API_SECRET",
    ]
    
    OPTIONAL_VARS = [
        "PROXY_URL",
        "TOR_SOCKS_PROXY",
        "DATABASE_URL",
        "REDIS_URL",
    ]
    
    def __init__(self, env_file=None):
        if env_file:
            load_dotenv(env_file)
        else:
            load_dotenv()
        
        self._validate_required()
    
    def _validate_required(self):
        """Validate all required environment variables are set."""
        missing = []
        for var in self.REQUIRED_VARS:
            if not os.getenv(var):
                missing.append(var)
        
        if missing:
            raise EnvironmentError(
                f"Missing required environment variables: {', '.join(missing)}\n"
                f"Copy .env.example to .env and fill in values"
            )
    
    def get(self, key, default=None):
        """Get configuration value."""
        return os.getenv(key, default)
    
    def get_safe(self, key):
        """Get configuration value with masking for display."""
        value = os.getenv(key)
        if value and len(value) > 8:
            return f"{value[:4]}...{value[-4:]}"
        return "***" if value else None
    
    def get_all_masked(self):
        """Get all configuration values masked for display."""
        all_vars = self.REQUIRED_VARS + self.OPTIONAL_VARS
        masked = {}
        for var in all_vars:
            masked[var] = self.get_safe(var)
        return masked
    
    def create_env_template(self, path=".env.example"):
        """Create .env template file."""
        template_lines = [
            "# Bug Bounty Automation Configuration",
            "# Copy this file to .env and fill in values",
            "# NEVER commit .env to version control",
            "",
            "# Required API Keys",
        ]
        
        for var in self.REQUIRED_VARS:
            template_lines.append(f"{var}=your_value_here")
        
        template_lines.extend([
            "",
            "# Optional Configuration",
        ])
        
        for var in self.OPTIONAL_VARS:
            template_lines.append(f"{var}=")
        
        with open(path, 'w') as f:
            f.write('\n'.join(template_lines))
        
        # Ensure .gitignore includes .env
        self._ensure_gitignore()
        
        return path
    
    def _ensure_gitignore(self):
        """Ensure .env is in .gitignore."""
        gitignore_path = Path(".gitignore")
        
        if gitignore_path.exists():
            content = gitignore_path.read_text()
            if ".env" not in content:
                with open(gitignore_path, 'a') as f:
                    f.write("\n# Environment variables (NEVER commit)\n.env\n")
        else:
            with open(gitignore_path, 'w') as f:
                f.write("# Environment variables (NEVER commit)\n.env\n")
```

**Step 4: Access Control Implementation**

```python
from functools import wraps
from enum import Enum

class Permission(Enum):
    SCAN_NETWORK = "scan_network"
    SCAN_WEB = "scan_web"
    ACCESS_API = "access_api"
    READ_DATA = "read_data"
    WRITE_DATA = "write_data"
    DELETE_DATA = "delete_data"
    MANAGE_CREDENTIALS = "manage_credentials"
    VIEW_REPORTS = "view_reports"

class ToolAccessControl:
    """Role-based access control for automation tools."""
    
    DEFAULT_PERMISSIONS = {
        "scanner": [
            Permission.SCAN_NETWORK,
            Permission.SCAN_WEB,
            Permission.READ_DATA,
            Permission.WRITE_DATA,
            Permission.VIEW_REPORTS,
        ],
        "reporter": [
            Permission.READ_DATA,
            Permission.VIEW_REPORTS,
        ],
        "admin": [p for p in Permission],
    }
    
    def __init__(self):
        self.user_roles = {}
        self.audit_log = []
    
    def assign_role(self, user_id, role):
        """Assign a role to a user."""
        if role not in self.DEFAULT_PERMISSIONS:
            raise ValueError(f"Unknown role: {role}")
        
        self.user_roles[user_id] = role
        self._log_audit(user_id, "role_assigned", {"role": role})
    
    def check_permission(self, user_id, permission):
        """Check if user has a specific permission."""
        role = self.user_roles.get(user_id)
        if not role:
            return False
        
        permissions = self.DEFAULT_PERMISSIONS.get(role, [])
        return permission in permissions
    
    def require_permission(self, permission):
        """Decorator to enforce permission check."""
        def decorator(func):
            @wraps(func)
            def wrapper(user_id, *args, **kwargs):
                if not self.check_permission(user_id, permission):
                    self._log_audit(
                        user_id,
                        "permission_denied",
                        {"permission": permission.value}
                    )
                    raise PermissionError(
                        f"User {user_id} lacks permission: {permission.value}"
                    )
                
                self._log_audit(
                    user_id,
                    "permission_granted",
                    {"permission": permission.value}
                )
                return func(user_id, *args, **kwargs)
            return wrapper
        return decorator
    
    def _log_audit(self, user_id, action, details):
        """Log access control audit event."""
        self.audit_log.append({
            "timestamp": datetime.now().isoformat(),
            "user_id": user_id,
            "action": action,
            "details": details
        })
    
    def get_audit_log(self, user_id=None, action=None):
        """Query audit log with optional filters."""
        filtered = self.audit_log
        
        if user_id:
            filtered = [e for e in filtered if e["user_id"] == user_id]
        
        if action:
            filtered = [e for e in filtered if e["action"] == action]
        
        return filtered

# Usage example
acl = ToolAccessControl()
acl.assign_role("hunter_001", "scanner")

@acl.require_permission(Permission.SCAN_WEB)
def run_web_scan(user_id, target):
    print(f"Running web scan on {target} for user {user_id}")
    return {"status": "success", "target": target}
```

### Phase 3: Operational Security

**Step 5: Identity Protection**

```python
import random
import string
from datetime import datetime, timedelta

class IdentityProtection:
    """Protect hunter identity during automated scanning."""
    
    def __init__(self):
        self.user_agents = [
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
            "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15",
            "Mozilla/5.0 (X11; Linux x86_64; rv:102.0) Gecko/20100101 Firefox/102.0",
        ]
        self.proxy_list = []
        self.session_map = {}
    
    def get_rotating_headers(self, session_id=None):
        """Get headers with rotating user agent."""
        if not session_id:
            session_id = ''.join(random.choices(string.ascii_letters, k=16))
        
        headers = {
            "User-Agent": random.choice(self.user_agents),
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9",
            "Accept-Language": "en-US,en;q=0.9",
            "Accept-Encoding": "gzip, deflate, br",
            "Connection": "keep-alive",
            "Upgrade-Insecure-Requests": "1",
        }
        
        self.session_map[session_id] = {
            "user_agent": headers["User-Agent"],
            "created_at": datetime.now().isoformat(),
            "request_count": 0
        }
        
        return headers
    
    def check_rate_limit_compliance(self, target_domain):
        """Ensure scanning complies with rate limits."""
        # This would integrate with your rate limiting system
        # Placeholder for demonstration
        return {
            "compliant": True,
            "requests_remaining": 100,
            "reset_at": (datetime.now() + timedelta(minutes=1)).isoformat()
        }
    
    def generate_persona(self):
        """Generate a consistent but distinct scanning persona."""
        persona = {
            "id": ''.join(random.choices(string.ascii_lowercase, k=12)),
            "user_agent": random.choice(self.user_agents),
            "timezone": random.choice(["UTC", "US/Eastern", "Europe/London"]),
            "language": "en-US",
            "session_timeout": random.randint(1800, 3600),
            "created_at": datetime.now().isoformat()
        }
        
        return persona

class SecureFileManager:
    """Secure temporary file management."""
    
    def __init__(self, temp_dir=None):
        self.temp_dir = Path(temp_dir or "/tmp/bb_scan")
        self.temp_dir.mkdir(parents=True, exist_ok=True)
    
    def create_secure_temp(self, suffix=".tmp"):
        """Create a secure temporary file with restricted permissions."""
        import tempfile
        
        fd, path = tempfile.mkstemp(
            suffix=suffix,
            dir=str(self.temp_dir)
        )
        
        # Set restrictive permissions
        os.chmod(path, 0o600)
        
        return path
    
    def secure_delete(self, file_path):
        """Securely delete a file by overwriting before deletion."""
        file_path = Path(file_path)
        
        if not file_path.exists():
            return True
        
        # Get file size
        file_size = file_path.stat().st_size
        
        # Overwrite with random data
        with open(file_path, 'wb') as f:
            f.write(os.urandom(file_size))
        
        # Overwrite with zeros
        with open(file_path, 'wb') as f:
            f.write(b'\x00' * file_size)
        
        # Delete
        file_path.unlink()
        
        return True
    
    def cleanup_old_files(self, max_age_hours=24):
        """Remove temporary files older than specified age."""
        cutoff = datetime.now() - timedelta(hours=max_age_hours)
        removed = 0
        
        for file_path in self.temp_dir.rglob("*"):
            if file_path.is_file():
                mtime = datetime.fromtimestamp(file_path.stat().st_mtime)
                if mtime < cutoff:
                    self.secure_delete(file_path)
                    removed += 1
        
        return removed
```

---

## Tool Arsenal

### Security Scanning Commands

```python
def scan_for_exposed_secrets(workspace_path):
    """Scan workspace for accidentally exposed secrets."""
    auditor = CredentialAuditor(workspace_path)
    credentials = auditor.scan_workspace()
    report = auditor.generate_report()
    
    # Print summary
    print(f"\nCredential Audit Report")
    print(f"{'='*50}")
    print(f"Total credentials found: {report['total_credentials']}")
    print(f"\nBy risk level:")
    for level, items in report['by_risk'].items():
        print(f"  {level}: {len(items)}")
    
    if report['recommendations']:
        print(f"\nRecommendations:")
        for rec in report['recommendations']:
            print(f"  - {rec}")
    
    return report

def validate_security_config():
    """Validate security configuration."""
    checks = []
    
    # Check .env exists and .gitignore includes it
    env_exists = Path(".env").exists()
    gitignore_secure = False
    
    if Path(".gitignore").exists():
        gitignore_content = Path(".gitignore").read_text()
        gitignore_secure = ".env" in gitignore_content
    
    checks.append({
        "name": "Environment file exists",
        "passed": env_exists,
        "severity": "high" if not env_exists else "info"
    })
    
    checks.append({
        "name": ".gitignore includes .env",
        "passed": gitignore_secure,
        "severity": "critical" if env_exists and not gitignore_secure else "info"
    })
    
    # Check file permissions
    env_path = Path(".env")
    if env_path.exists():
        import stat
        mode = env_path.stat().st_mode
        world_readable = bool(mode & stat.S_IROTH)
        checks.append({
            "name": ".env not world-readable",
            "passed": not world_readable,
            "severity": "high" if world_readable else "info"
        })
    
    # Print results
    print("\nSecurity Configuration Validation")
    print("="*50)
    for check in checks:
        status = "PASS" if check["passed"] else "FAIL"
        print(f"[{status}] {check['name']} (severity: {check['severity']})")
    
    return checks
```

### Secrets Rotation Automation

```python
def rotate_all_secrets(workspace_path, secrets_manager):
    """Automated rotation of all stored secrets."""
    secrets = secrets_manager.list_secrets()
    
    rotation_log = []
    
    for secret_name in secrets:
        try:
            # In production, generate new value from source
            # This is a placeholder
            new_value = f"rotated_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
            
            secrets_manager.rotate_secret(secret_name, new_value)
            
            rotation_log.append({
                "secret": secret_name,
                "status": "success",
                "rotated_at": datetime.now().isoformat()
            })
            
            print(f"Rotated: {secret_name}")
        
        except Exception as e:
            rotation_log.append({
                "secret": secret_name,
                "status": "failed",
                "error": str(e)
            })
            
            print(f"Failed to rotate {secret_name}: {e}")
    
    return rotation_log
```

---

## Real-World Examples

### Example 1: Secure Nuclei Scanner Configuration

```python
def setup_secure_nuclei(api_token, workspace):
    """Configure nuclei with security best practices."""
    import yaml
    
    config = {
        "api-key": api_token,
        "severity": "low,medium,high,critical",
        "rate-limit": 50,
        "bulk-size": 25,
        "concurrency": 25,
        "proxy": os.getenv("PROXY_URL"),
        "disable-update-check": True,
        "stats-json": True,
        "output": str(workspace / "results" / "nuclei_output.json"),
        "log": str(workspace / "logs" / "nuclei.log"),
    }
    
    # Write config with restricted permissions
    config_path = workspace / "config" / "nuclei.yaml"
    config_path.parent.mkdir(parents=True, exist_ok=True)
    
    with open(config_path, 'w') as f:
        yaml.dump(config, f, default_flow_style=False)
    
    os.chmod(config_path, 0o600)
    
    return config_path

def run_nuclei_secure(user_id, target, config_path):
    """Run nuclei with access control and logging."""
    acl = ToolAccessControl()
    
    @acl.require_permission(Permission.SCAN_WEB)
    def _run_scan(uid, tgt):
        import subprocess
        
        cmd = [
            "nuclei",
            "-target", tgt,
            "-config", str(config_path),
            "-json"
        ]
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=3600
        )
        
        return {
            "output": result.stdout,
            "errors": result.stderr,
            "returncode": result.returncode
        }
    
    return _run_scan(user_id, target)
```

### Example 2: Encrypted Findings Storage

```python
class EncryptedFindingsStorage:
    """Encrypt findings at rest to protect sensitive data."""
    
    def __init__(self, encryption_key):
        self.cipher = Fernet(encryption_key)
        self.storage_dir = Path("encrypted_findings")
        self.storage_dir.mkdir(exist_ok=True)
    
    def store_finding(self, finding_id, finding_data):
        """Encrypt and store a finding."""
        data_json = json.dumps(finding_data).encode()
        encrypted = self.cipher.encrypt(data_json)
        
        file_path = self.storage_dir / f"{finding_id}.enc"
        file_path.write_bytes(encrypted)
        file_path.chmod(0o600)
        
        return file_path
    
    def retrieve_finding(self, finding_id):
        """Retrieve and decrypt a finding."""
        file_path = self.storage_dir / f"{finding_id}.enc"
        
        if not file_path.exists():
            raise FileNotFoundError(f"Finding not found: {finding_id}")
        
        encrypted = file_path.read_bytes()
        decrypted = self.cipher.decrypt(encrypted)
        
        return json.loads(decrypted.decode())
    
    def list_findings(self):
        """List all stored finding IDs."""
        return [f.stem for f in self.storage_dir.glob("*.enc")]
```

### Example 3: Audit Trail for Compliance

```python
class AuditTrail:
    """Maintain audit trail for all automation activities."""
    
    def __init__(self, log_path="audit.log"):
        self.log_path = Path(log_path)
        self.log_path.parent.mkdir(parents=True, exist_ok=True)
    
    def log_event(self, event_type, user_id, details):
        """Log an audit event."""
        event = {
            "timestamp": datetime.now().isoformat(),
            "event_type": event_type,
            "user_id": user_id,
            "details": details,
            "session_id": os.getenv("SESSION_ID", "unknown")
        }
        
        with open(self.log_path, 'a') as f:
            f.write(json.dumps(event) + "\n")
        
        return event
    
    def query_events(self, event_type=None, user_id=None, 
                     start_time=None, end_time=None):
        """Query audit events with filters."""
        events = []
        
        with open(self.log_path) as f:
            for line in f:
                if line.strip():
                    event = json.loads(line)
                    
                    if event_type and event["event_type"] != event_type:
                        continue
                    if user_id and event["user_id"] != user_id:
                        continue
                    if start_time and event["timestamp"] < start_time:
                        continue
                    if end_time and event["timestamp"] > end_time:
                        continue
                    
                    events.append(event)
        
        return events
    
    def generate_compliance_report(self, start_date, end_date):
        """Generate compliance report for time period."""
        events = self.query_events(start_time=start_date, end_time=end_date)
        
        report = {
            "period": {"start": start_date, "end": end_date},
            "total_events": len(events),
            "by_type": {},
            "by_user": {},
            "security_events": []
        }
        
        for event in events:
            # Count by type
            etype = event["event_type"]
            report["by_type"][etype] = report["by_type"].get(etype, 0) + 1
            
            # Count by user
            uid = event["user_id"]
            report["by_user"][uid] = report["by_user"].get(uid, 0) + 1
            
            # Flag security events
            if "denied" in etype or "failed" in etype:
                report["security_events"].append(event)
        
        return report
```

---

## Common Pitfalls

### Pitfall 1: Hardcoding Credentials in Scripts
Never hardcode API keys, tokens, or passwords directly in Python scripts. Use environment variables or secrets vaults.

### Pitfall 2: Logging Sensitive Data
Ensure logging frameworks don't capture credentials, tokens, or sensitive findings in plaintext logs.

### Pitfall 3: Exposing Secrets in Version Control
Always verify `.gitignore` includes `.env`, credential files, and any local configuration containing secrets.

### Pitfall 4: Overly Broad Permissions
Run automation tools with minimum required privileges. A scanner doesn't need admin access to your system.

### Pitfall 5: Ignoring Dependency Security
Regularly audit dependencies for known vulnerabilities. Use `pip-audit` or `safety` to check installed packages.

### Pitfall 6: No Credential Rotation Policy
Establish and enforce regular rotation schedules for all API keys and tokens. Stale credentials are security liabilities.

### Pitfall 7: Unencrypted Data at Rest
Encrypt findings databases, scan results, and evidence files containing sensitive target data.

---

## Advanced Techniques

### Hardware Security Module Integration

```python
class HSMIntegration:
    """Hardware Security Module integration for key management."""
    
    def __init__(self, hsm_endpoint):
        self.endpoint = hsm_endpoint
    
    def generate_key(self, key_alias, key_type="AES-256"):
        """Generate encryption key in HSM."""
        # Placeholder for HSM API integration
        return {
            "alias": key_alias,
            "type": key_type,
            "created_at": datetime.now().isoformat()
        }
    
    def encrypt_with_hsm_key(self, key_alias, plaintext):
        """Encrypt data using HSM-managed key."""
        # Placeholder for HSM encryption API
        return f"hsm_encrypted_{key_alias}_{plaintext[:8]}"
    
    def decrypt_with_hsm_key(self, key_alias, ciphertext):
        """Decrypt data using HSM-managed key."""
        # Placeholder for HSM decryption API
        return ciphertext.split("_")[-1]
```

### Secret Detection in CI/CD

```python
def pre_commit_secret_check():
    """Pre-commit hook to detect secrets before git commit."""
    import subprocess
    
    # Run git diff to get staged changes
    result = subprocess.run(
        ["git", "diff", "--cached", "--name-only"],
        capture_output=True,
        text=True
    )
    
    staged_files = result.stdout.strip().split('\n')
    
    auditor = CredentialAuditor(".")
    findings = []
    
    for file_path in staged_files:
        if not file_path:
            continue
        
        # Check if file would introduce secrets
        credentials = auditor._scan_file(Path(file_path))
        if credentials:
            findings.append({
                "file": file_path,
                "secrets_found": len(credentials)
            })
    
    if findings:
        print("WARNING: Potential secrets detected in staged files:")
        for finding in findings:
            print(f"  {finding['file']}: {finding['secrets_found']} secrets")
        print("\nUse environment variables or secrets vault instead.")
        return False
    
    return True
```

---

## Reporting Template

### Security Audit Report

```markdown
## Automation Security Audit Report

**Audit Date**: [Date]
**Auditor**: [Name/Tool]
**Workspace**: [Path]

### Credential Inventory
| Type | Count | Critical | High | Medium |
|------|-------|----------|------|--------|
| API Keys | [N] | [N] | [N] | [N] |
| Tokens | [N] | [N] | [N] | [N] |
| Passwords | [N] | [N] | [N] | [N] |
| Total | [N] | [N] | [N] | [N] |

### Security Findings
| Finding | Severity | Status | Recommendation |
|---------|----------|--------|----------------|
| [Finding] | [Sev] | [Status] | [Action] |

### Access Control Review
- [ ] Credentials encrypted at rest
- [ ] Access logs maintained
- [ ] Rotation schedule enforced
- [ ] Least privilege verified

### Recommendations
1. [Priority recommendation]
2. [Secondary recommendation]
3. [Additional recommendations]
```

---

## Quick Reference

### Security Checklist
- [ ] All credentials in secrets vault
- [ ] .env in .gitignore
- [ ] No hardcoded secrets in code
- [ ] Encryption enabled for findings
- [ ] Access logging enabled
- [ ] Regular rotation scheduled
- [ ] Dependency audit completed
- [ ] Secure deletion procedures in place

### Key Rotation Schedule
| Secret Type | Rotation Frequency | Method |
|-------------|-------------------|--------|
| API Keys | 90 days | Manual/Vault |
| OAuth Tokens | 30 days | Auto-refresh |
| Database Passwords | 60 days | Vault rotation |
| SSH Keys | 180 days | Manual |

### Emergency Response
1. Identify compromised credential
2. Immediately rotate or revoke
3. Check audit logs for abuse
4. Update all systems using credential
5. Document incident
6. Review and improve controls
