# Advanced Chaining Techniques — Tool Registry

**Domain:** `advanced-chaining-techniques`
**Registry Path:** `Brain/tools/registry/advanced-chaining-techniques.md`
**Source Directory:** `Advanced-Chaining-Techniques/`
**File Count:** 49 domain files

---

## Overview

This tool registry manages the lifecycle of chain execution tools within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that execute multi-step vulnerability exploitation chains — combining individual primitives (XSS, IDOR, SSRF, CSRF, etc.) into compound attack paths that achieve higher impact outcomes.

Each registered tool corresponds to one or more files in the `Advanced-Chaining-Techniques/` directory. The registry tracks chain definitions, prerequisite dependencies, execution order, output handoffs, and success criteria for each chain.

---

## Domain Mapping

| Registry Key | Source File | Chain Type | Primary Impact |
|---|---|---|---|
| `basic-vuln-chain` | `01-Basic-Vulnerability-Chaining.md` | compound | multi-impact |
| `info-disc-rce` | `02-Information-Disclosure-to-RCE.md` | escalation | remote_code_execution |
| `xss-ato` | `03-XSS-to-Account-Takeover.md` | escalation | account_takeover |
| `idor-mass-extract` | `04-IDOR-to-Mass-Data-Extraction.md` | escalation | data_breach |
| `sqli-shell` | `05-SQL-Injection-to-Shell-Access.md` | escalation | remote_code_execution |
| `ssrf-internal` | `06-SSRF-to-Internal-Network-Compromise.md` | escalation | network_compromise |
| `cors-chains` | `07-CORS-Misconfiguration-Chains.md` | bypass | cross_origin_abuse |
| `csrf-privesc` | `08-CSRF-to-Privilege-Escalation.md` | escalation | privilege_escalation |
| `upload-webshell` | `09-File-Upload-to-Web-Shell.md` | escalation | remote_code_execution |
| `xxe-data` | `10-XXE-to-Sensitive-Data-Access.md` | escalation | data_breach |
| `deser-rce` | `11-Deserialization-to-RCE.md` | escalation | remote_code_execution |
| `jwt-chains` | `12-JWT-Manipulation-Chains.md` | bypass | authentication_bypass |
| `ssti-compromise` | `13-SSTI-to-Complete-Compromise.md` | escalation | remote_code_execution |
| `nosql-breach` | `15-NoSQL-Injection-to-Data-Breach.md` | escalation | data_breach |
| `graphql-abuse` | `16-GraphQL-Abuse-Chains.md` | compound | multi-impact |
| `websocket-chains` | `17-WebSocket-Security-Chains.md` | compound | multi-impact |
| `proto-pollution` | `18-Prototype-Pollution-Exploitation.md` | escalation | code_injection |
| `smuggling-chains` | `19-HTTP-Request-Smuggling-Chains.md` | bypass | request_smuggling |
| `host-header-chains` | `20-Host-Header-Injection-Chains.md` | escalation | host_header_abuse |
| `dns-rebinding` | `21-DNS-Rebinding-Attacks.md` | bypass | network_bypass |
| `race-exploit` | `22-Race-Condition-Exploitation.md` | concurrency | race_condition |
| `subdomain-takeover` | `23-Subdomain-Takeover-Chains.md` | escalation | domain_hijack |
| `open-redirect-phish` | `24-Open-Redirect-to-Phishing.md` | escalation | credential_theft |
| `content-spoof` | `25-Content-Spoofing-Chains.md` | manipulation | content_injection |
| `webcache-poison` | `26-WebCache-Poisoning-Chains.md` | cache | cache_poisoning |
| `clickjack-ato` | `27-Clickjacking-to-Account-Compromise.md` | escalation | account_takeover |
| `param-pollution` | `28-Parameter-Pollution-Attacks.md` | bypass | parameter_abuse |
| `ldap-chains` | `29-LDAP-Injection-Chains.md` | escalation | ldap_abuse |
| `xpath-exploit` | `30-XPath-Injection-Exploitation.md` | escalation | data_breach |
| `session-puzzle` | `31-Session-Puzzling-Techniques.md` | bypass | session_abuse |
| `file-handling-chains` | `32-Insecure-File-Handling-Chains.md` | escalation | file_system_abuse |
| `xssi-chains` | `33-Cross-Site-Script-Inclusion.md` | exfiltration | data_exfiltration |
| `response-splitting` | `34-HTTP-Response-Splitting.md` | injection | response_injection |
| `client-storage` | `35-Client-Side-Storage-Abuse.md` | abuse | storage_manipulation |
| `crypto-chains` | `36-Cryptography-Weakness-Chains.md` | crypto | crypto_bypass |
| `third-party-chains` | `37-Third-Party-Component-Chains.md` | supply_chain | component_abuse |
| `config-chains` | `38-Configuration-Misconfiguration-Chains.md` | misconfig | config_abuse |
| `network-chains` | `39-Network-Infrastructure-Chains.md` | network | network_compromise |
| `mobile-api-chains` | `40-Mobile-API-Chains.md` | api | mobile_abuse |
| `cloud-chains` | `41-Cloud-Misconfiguration-Chains.md` | cloud | cloud_compromise |
| `container-escape` | `42-Container-Escape-Chains.md` | escalation | container_escape |
| `k8s-chains` | `43-Kubernetes-Attack-Chains.md` | escalation | cluster_compromise |
| `blockchain-chains` | `44-Blockchain-Exploit-Chains.md` | blockchain | smart_contract_abuse |
| `iot-chains` | `45-IoT-Device-Compromise-Chains.md` | iot | device_compromise |
| `supply-chain-attack` | `46-Supply-Chain-Attack-Chains.md` | supply_chain | dependency_abuse |
| `zero-day-chain` | `47-Zero-Day-Chaining-Strategies.md` | advanced | zero_day |
| `multi-platform` | `48-Multi-Platform-Attack-Chains.md` | compound | cross_platform |
| `apt-chains` | `49-Advanced-Persistent-Threat-Chains.md` | apt | persistent_access |
| `master-framework` | `50-Master-Chaining-Framework.md` | framework | meta_chain |

---

## Tool Registration Schema

```yaml
chain_registration:
  name: string
  version: string
  chain_type: string        # compound | escalation | bypass | concurrency | cache | crypto | injection | exfiltration | cloud | api | network | supply_chain | apt | iot | blockchain | advanced | framework
  source_file: string       # Reference to file in Advanced-Chaining-Techniques/
  steps: list[ChainStep]    # Ordered execution steps
  prerequisites: list[str]  # Required tools/capabilities
  success_criteria: dict    # How to determine chain success
  input_schema: dict
  output_schema: dict
  config: dict
  metadata: dict
  dependencies: dict
  status: enum              # active | disabled | error | pending
```

```yaml
ChainStep:
  step_id: string
  tool_name: string         # Registered tool to execute
  input_mapping: dict       # Maps previous step outputs to this step's inputs
  timeout: int              # Step timeout in seconds
  on_failure: enum          # abort | skip | retry
  retry_count: int
  conditions: list[dict]    # Pre-conditions for step execution
```

---

## Registered Chain Tools

### Basic Vulnerability Chaining

```python
registry.register(
    name="basic-vuln-chain",
    tool_class=BasicVulnChainTool,
    config={
        "max_steps": 5,
        "timeout": 600,
        "parallel_steps": False
    },
    metadata={
        "chain_type": "compound",
        "description": "Chains basic vulnerabilities into compound exploits",
        "tags": ["chaining", "compound", "basic"],
        "source_file": "01-Basic-Vulnerability-Chaining.md",
        "prerequisites": ["nuclei", "ffuf"],
        "success_criteria": {"min_vulns": 2, "chain_complete": True}
    }
)
```

### Information Disclosure to RCE

```python
registry.register(
    name="info-disc-rce",
    tool_class=InfoDiscRCEChainTool,
    config={
        "max_depth": 4,
        "timeout": 900,
        "evidence_threshold": 0.7
    },
    metadata={
        "chain_type": "escalation",
        "description": "Escalates information disclosure findings to remote code execution",
        "tags": ["chaining", "escalation", "rce", "info-disclosure"],
        "source_file": "02-Information-Disclosure-to-RCE.md",
        "prerequisites": ["nuclei", "response-analyzer"],
        "input_capabilities": ["information_disclosure"],
        "output_capabilities": ["remote_code_execution"]
    }
)
```

### XSS to Account Takeover

```python
registry.register(
    name="xss-ato",
    tool_class=XSSATOChainTool,
    config={
        "session_capture": True,
        "cookie_exfil": True,
        "timeout": 300
    },
    metadata={
        "chain_type": "escalation",
        "description": "Chains XSS to session hijack and account takeover",
        "tags": ["chaining", "xss", "ato", "session"],
        "source_file": "03-XSS-to-Account-Takeover.md",
        "prerequisites": ["dalfox", "playwright-scanner"],
        "input_capabilities": ["xss_detection"],
        "output_capabilities": ["account_takeover"]
    }
)
```

### IDOR to Mass Data Extraction

```python
registry.register(
    name="idor-mass-extract",
    tool_class=IDORMassExtractChainTool,
    config={
        "id_range_start": 1,
        "id_range_end": 10000,
        "parallel_requests": 10,
        "timeout": 600
    },
    metadata={
        "chain_type": "escalation",
        "description": "Chains IDOR into mass data extraction across user records",
        "tags": ["chaining", "idor", "data-extraction", "mass"],
        "source_file": "04-IDOR-to-Mass-Data-Extraction.md",
        "prerequisites": ["idor-detector", "data-collector"],
        "input_capabilities": ["idor_detection"],
        "output_capabilities": ["data_breach"]
    }
)
```

### SQL Injection to Shell Access

```python
registry.register(
    name="sqli-shell",
    tool_class=SQLIShellChainTool,
    config={
        "dbms_detection": True,
        "os_shell_attempts": 3,
        "timeout": 900
    },
    metadata={
        "chain_type": "escalation",
        "description": "Escalates SQL injection to OS-level command execution",
        "tags": ["chaining", "sqli", "rce", "database"],
        "source_file": "05-SQL-Injection-to-Shell-Access.md",
        "prerequisites": ["sqlmap"],
        "input_capabilities": ["sql_injection"],
        "output_capabilities": ["remote_code_execution"]
    }
)
```

### SSRF to Internal Network Compromise

```python
registry.register(
    name="ssrf-internal",
    tool_class=SSRFInternalChainTool,
    config={
        "internal_range": "10.0.0.0/8",
        "cloud_metadata_urls": ["http://169.254.169.254/latest/meta-data/"],
        "timeout": 600
    },
    metadata={
        "chain_type": "escalation",
        "description": "Chains SSRF to internal network scanning and cloud metadata access",
        "tags": ["chaining", "ssrf", "internal-network", "cloud"],
        "source_file": "06-SSRF-to-Internal-Network-Compromise.md",
        "prerequisites": ["ssrf-explorer"],
        "input_capabilities": ["ssrf_testing"],
        "output_capabilities": ["network_compromise", "cloud_metadata_access"]
    }
)
```

### JWT Manipulation Chains

```python
registry.register(
    name="jwt-chains",
    tool_class=JWTChainTool,
    config={
        "algorithm_attacks": ["none", "hs256-rs256", "key-confusion"],
        "bruteforce_wordlist": "/usr/share/wordlists/jwt.txt",
        "timeout": 300
    },
    metadata={
        "chain_type": "bypass",
        "description": "Chains JWT vulnerabilities for authentication bypass",
        "tags": ["chaining", "jwt", "auth-bypass", "crypto"],
        "source_file": "12-JWT-Manipulation-Chains.md",
        "prerequisites": ["jwt-tool"],
        "input_capabilities": ["jwt_testing"],
        "output_capabilities": ["authentication_bypass"]
    }
)
```

### File Upload to Web Shell

```python
registry.register(
    name="upload-webshell",
    tool_class=UploadWebshellChainTool,
    config={
        "bypass_techniques": ["double-extension", "mime-spoof", "null-byte", "content-type"],
        "shell_types": ["php", "jsp", "asp", "aspx"],
        "timeout": 300
    },
    metadata={
        "chain_type": "escalation",
        "description": "Chains file upload bypass to web shell deployment",
        "tags": ["chaining", "upload", "webshell", "rce"],
        "source_file": "09-File-Upload-to-Web-Shell.md",
        "prerequisites": ["ffuf"],
        "input_capabilities": ["file_upload"],
        "output_capabilities": ["remote_code_execution"]
    }
)
```

### HTTP Request Smuggling Chains

```python
registry.register(
    name="smuggling-chains",
    tool_class=SmugglingChainTool,
    config={
        "techniques": ["CL.TE", "TE.CL", "H2.CL", "H2.TE"],
        "timeout": 300,
        "detection_only": False
    },
    metadata={
        "chain_type": "bypass",
        "description": "Chains HTTP request smuggling for cache poisoning and session hijack",
        "tags": ["chaining", "smuggling", "cache-poisoning", "hijack"],
        "source_file": "19-HTTP-Request-Smuggling-Chains.md",
        "prerequisites": ["nuclei"],
        "input_capabilities": ["http_smuggling"],
        "output_capabilities": ["cache_poisoning", "session_hijack"]
    }
)
```

### Cloud Misconfiguration Chains

```python
registry.register(
    name="cloud-chains",
    tool_class=CloudChainTool,
    config={
        "providers": ["aws", "gcp", "azure"],
        "metadata_url": "http://169.254.169.254/latest/meta-data/",
        "timeout": 300
    },
    metadata={
        "chain_type": "cloud",
        "description": "Chains cloud misconfigurations for privilege escalation and data access",
        "tags": ["chaining", "cloud", "aws", "gcp", "azure"],
        "source_file": "41-Cloud-Misconfiguration-Chains.md",
        "prerequisites": ["ssrf-explorer", "cloud-enum"],
        "input_capabilities": ["cloud_misconfiguration"],
        "output_capabilities": ["cloud_compromise", "credential_theft"]
    }
)
```

### Kubernetes Attack Chains

```python
registry.register(
    name="k8s-chains",
    tool_class=K8sChainTool,
    config={
        "api_server_check": True,
        "kubelet_exploit": True,
        "timeout": 600
    },
    metadata={
        "chain_type": "escalation",
        "description": "Chains Kubernetes misconfigurations for cluster compromise",
        "tags": ["chaining", "kubernetes", "container", "cluster"],
        "source_file": "43-Kubernetes-Attack-Chains.md",
        "prerequisites": ["container-escape"],
        "input_capabilities": ["kubernetes_misconfiguration"],
        "output_capabilities": ["cluster_compromise"]
    }
)
```

### Master Chaining Framework

```python
registry.register(
    name="master-framework",
    tool_class=MasterChainingFrameworkTool,
    config={
        "max_chain_length": 10,
        "parallel_chains": 3,
        "timeout": 3600,
        "auto_optimize": True
    },
    metadata={
        "chain_type": "framework",
        "description": "Meta-framework for orchestrating all chain types with optimization",
        "tags": ["chaining", "framework", "orchestration", "meta"],
        "source_file": "50-Master-Chaining-Framework.md",
        "prerequisites": [],
        "input_capabilities": ["any_vulnerability"],
        "output_capabilities": ["compound_exploit", "auto_chain"]
    }
)
```

---

## Register / Unregister Operations

```python
def register_chain(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> ChainRegistration:
    """Register a chain execution tool."""
    if name in self._chains:
        raise DuplicateChainError(f"Chain '{name}' already registered")

    registration = ChainRegistration(
        id=generate_id(),
        name=name,
        version=metadata.get("version", "1.0.0"),
        chain_type=metadata.get("chain_type", "compound"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        steps=[],
        prerequisites=metadata.get("prerequisites", []),
        success_criteria=metadata.get("success_criteria", {}),
        config=config or {},
        metadata=metadata or {},
        registered_at=datetime.utcnow(),
        status="active"
    )

    self._chains[name] = registration
    self._index_chain_type(registration)
    self._event_bus.emit("chain.registered", {"name": name, "domain": "advanced-chaining-techniques"})
    return registration

def unregister_chain(self, name: str) -> bool:
    """Remove a chain from the registry."""
    if name not in self._chains:
        return False
    chain = self._chains[name]
    if chain.status == "executing":
        raise ChainInUseError(f"Cannot unregister '{name}' — chain currently executing")
    del self._chains[name]
    self._remove_chain_index(chain)
    self._event_bus.emit("chain.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_chains_by_type(self, chain_type: str) -> list[ChainRegistration]:
    """Discover chains by type (compound, escalation, bypass, etc.)."""
    names = self._chain_types.get(chain_type, set())
    return [self._chains[n] for n in names if self._chains[n].status == "active"]

def discover_chains_by_prerequisite(self, tool_name: str) -> list[ChainRegistration]:
    """Find all chains that require a specific tool."""
    return [
        c for c in self._chains.values()
        if tool_name in c.prerequisites and c.status == "active"
    ]

def discover_chains_by_output(self, output_capability: str) -> list[ChainRegistration]:
    """Find chains that produce a specific output capability."""
    return [
        c for c in self._chains.values()
        if output_capability in c.metadata.get("output_capabilities", []) and c.status == "active"
    ]

def discover_chains_by_input(self, input_capability: str) -> list[ChainRegistration]:
    """Find chains that accept a specific input capability."""
    return [
        c for c in self._chains.values()
        if input_capability in c.metadata.get("input_capabilities", []) and c.status == "active"
    ]

def discover_composable_chains(self) -> list[tuple[ChainRegistration, ChainRegistration]]:
    """Discover pairs of chains where one's output feeds the other's input."""
    pairs = []
    for a in self._chains.values():
        for b in self._chains.values():
            if a.name == b.name:
                continue
            a_outputs = set(a.metadata.get("output_capabilities", []))
            b_inputs = set(b.metadata.get("input_capabilities", []))
            if a_outputs & b_inputs:
                pairs.append((a, b))
    return pairs
```

---

## Tool Listing

```python
def list_all_chains(self, sort_by: str = "name") -> list[ChainRegistration]:
    """List all registered chains."""
    chains = list(self._chains.values())
    chains.sort(key=lambda c: getattr(c, sort_by, c.name))
    return chains

def list_chain_types(self) -> dict[str, list[str]]:
    """List all chain types and their chain names."""
    return {ct: sorted(list(names)) for ct, names in sorted(self._chain_types.items())}

def list_by_source_file(self) -> dict[str, str]:
    """Map source files to their registered chain names."""
    return {c.name: c.source_file for c in self._chains.values()}
```

---

## Tool Metadata

```yaml
chain_metadata:
  name: string
  version: string
  chain_type: string
  source_file: string
  description: string
  tags: list[str]
  prerequisites: list[string]
  input_capabilities: list[string]
  output_capabilities: list[string]
  success_criteria: dict
  estimated_duration: int          # seconds
  risk_level: string               # low | medium | high | critical
  requires_confirmation: bool      # Human approval before execution
  max_concurrent: int              # Max concurrent executions
  config_schema: dict
  author: string
  license: string
  domain_files: list[string]
  related_chains: list[string]     # Names of composable chains
```

---

## Tool Versioning

```python
class ChainVersionManager:
    def check_chain_compatibility(self, name: str, min_version: str) -> bool:
        chain = self._chains.get(name)
        if not chain:
            return False
        return semver.compare(chain.version, min_version) >= 0

    def upgrade_chain(self, name: str, new_version: str, new_steps: list = None) -> ChainRegistration:
        chain = self._chains[name]
        old_version = chain.version
        chain.version = new_version
        if new_steps:
            chain.steps = new_steps
        chain.metadata.setdefault("upgrade_history", []).append({
            "from": old_version, "to": new_version,
            "timestamp": datetime.utcnow().isoformat()
        })
        self._event_bus.emit("chain.upgraded", {"name": name, "from": old_version, "to": new_version})
        return chain
```

---

## Tool Dependencies

```python
class ChainDependencyManager:
    def resolve_chain_dependencies(self, name: str) -> list[str]:
        """Resolve tool prerequisites in dependency order."""
        chain = self._chains[name]
        visited = set()
        order = []
        for prereq in chain.prerequisites:
            if prereq not in visited:
                visited.add(prereq)
                order.append(prereq)
        return order

    def get_composable_chains(self, name: str) -> list[str]:
        """Find chains that can be composed after this chain."""
        chain = self._chains[name]
        outputs = set(chain.metadata.get("output_capabilities", []))
        return [
            c.name for c in self._chains.values()
            if c.name != name and outputs & set(c.metadata.get("input_capabilities", []))
        ]
```

---

## Full Domain File References

| # | File | Registered Chain Tool |
|---|---|---|
| 1 | `01-Basic-Vulnerability-Chaining.md` | basic-vuln-chain |
| 2 | `02-Information-Disclosure-to-RCE.md` | info-disc-rce |
| 3 | `03-XSS-to-Account-Takeover.md` | xss-ato |
| 4 | `04-IDOR-to-Mass-Data-Extraction.md` | idor-mass-extract |
| 5 | `05-SQL-Injection-to-Shell-Access.md` | sqli-shell |
| 6 | `06-SSRF-to-Internal-Network-Compromise.md` | ssrf-internal |
| 7 | `07-CORS-Misconfiguration-Chains.md` | cors-chains |
| 8 | `08-CSRF-to-Privilege-Escalation.md` | csrf-privesc |
| 9 | `09-File-Upload-to-Web-Shell.md` | upload-webshell |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | xxe-data |
| 11 | `11-Deserialization-to-RCE.md` | deser-rce |
| 12 | `12-JWT-Manipulation-Chains.md` | jwt-chains |
| 13 | `13-SSTI-to-Complete-Compromise.md` | ssti-compromise |
| 14 | `15-NoSQL-Injection-to-Data-Breach.md` | nosql-breach |
| 15 | `16-GraphQL-Abuse-Chains.md` | graphql-abuse |
| 16 | `17-WebSocket-Security-Chains.md` | websocket-chains |
| 17 | `18-Prototype-Pollution-Exploitation.md` | proto-pollution |
| 18 | `19-HTTP-Request-Smuggling-Chains.md` | smuggling-chains |
| 19 | `20-Host-Header-Injection-Chains.md` | host-header-chains |
| 20 | `21-DNS-Rebinding-Attacks.md` | dns-rebinding |
| 21 | `22-Race-Condition-Exploitation.md` | race-exploit |
| 22 | `23-Subdomain-Takeover-Chains.md` | subdomain-takeover |
| 23 | `24-Open-Redirect-to-Phishing.md` | open-redirect-phish |
| 24 | `25-Content-Spoofing-Chains.md` | content-spoof |
| 25 | `26-WebCache-Poisoning-Chains.md` | webcache-poison |
| 26 | `27-Clickjacking-to-Account-Compromise.md` | clickjack-ato |
| 27 | `28-Parameter-Pollution-Attacks.md` | param-pollution |
| 28 | `29-LDAP-Injection-Chains.md` | ldap-chains |
| 29 | `30-XPath-Injection-Exploitation.md` | xpath-exploit |
| 30 | `31-Session-Puzzling-Techniques.md` | session-puzzle |
| 31 | `32-Insecure-File-Handling-Chains.md` | file-handling-chains |
| 32 | `33-Cross-Site-Script-Inclusion.md` | xssi-chains |
| 33 | `34-HTTP-Response-Splitting.md` | response-splitting |
| 34 | `35-Client-Side-Storage-Abuse.md` | client-storage |
| 35 | `36-Cryptography-Weakness-Chains.md` | crypto-chains |
| 36 | `37-Third-Party-Component-Chains.md` | third-party-chains |
| 37 | `38-Configuration-Misconfiguration-Chains.md` | config-chains |
| 38 | `39-Network-Infrastructure-Chains.md` | network-chains |
| 39 | `40-Mobile-API-Chains.md` | mobile-api-chains |
| 40 | `41-Cloud-Misconfiguration-Chains.md` | cloud-chains |
| 41 | `42-Container-Escape-Chains.md` | container-escape |
| 42 | `43-Kubernetes-Attack-Chains.md` | k8s-chains |
| 43 | `44-Blockchain-Exploit-Chains.md` | blockchain-chains |
| 44 | `45-IoT-Device-Compromise-Chains.md` | iot-chains |
| 45 | `46-Supply-Chain-Attack-Chains.md` | supply-chain-attack |
| 46 | `47-Zero-Day-Chaining-Strategies.md` | zero-day-chain |
| 47 | `48-Multi-Platform-Attack-Chains.md` | multi-platform |
| 48 | `49-Advanced-Persistent-Threat-Chains.md` | apt-chains |
| 49 | `50-Master-Chaining-Framework.md` | master-framework |
| 50 | `README.md` | (documentation) |

---

## Chain Types Index

| Chain Type | Count | Tools |
|---|---|---|
| `compound` | 5 | basic-vuln-chain, graphql-abuse, websocket-chains, multi-platform, content-spoof |
| `escalation` | 19 | info-disc-rce, xss-ato, idor-mass-extract, sqli-shell, ssrf-internal, csrf-privesc, upload-webshell, xxe-data, deser-rce, ssti-compromise, nosql-breach, proto-pollution, subdomain-takeover, open-redirect-phish, clickjack-ato, ldap-chains, xpath-exploit, file-handling-chains, container-escape, k8s-chains |
| `bypass` | 6 | cors-chains, jwt-chains, smuggling-chains, dns-rebinding, param-pollution, session-puzzle, response-splitting |
| `cache` | 1 | webcache-poison |
| `concurrency` | 1 | race-exploit |
| `crypto` | 1 | crypto-chains |
| `injection` | 1 | response-splitting |
| `exfiltration` | 1 | xssi-chains |
| `cloud` | 2 | cloud-chains, k8s-chains |
| `network` | 2 | network-chains, host-header-chains |
| `supply_chain` | 2 | third-party-chains, supply-chain-attack |
| `api` | 1 | mobile-api-chains |
| `apt` | 1 | apt-chains |
| `iot` | 1 | iot-chains |
| `blockchain` | 1 | blockchain-chains |
| `advanced` | 1 | zero-day-chain |
| `framework` | 1 | master-framework |
| `misconfig` | 1 | config-chains |

---

*Part of the Brain tools subsystem — Advanced Chaining Techniques Domain Registry.*
