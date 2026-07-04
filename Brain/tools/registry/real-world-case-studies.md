# Real-World Case Studies — Tool Registry

**Domain:** `real-world-case-studies`
**Registry Path:** `Brain/tools/registry/real-world-case-studies.md`
**Source Directory:** `Real-World-Case-Studies/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages pattern extraction tools for disclosed vulnerability case studies within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that analyze real-world disclosed vulnerabilities, extract attack patterns, and provide actionable intelligence for bug bounty hunting. Every tool registered here maps to files in the `Real-World-Case-Studies/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `idor-ato-cases` | `01-IDOR-Account-Takeover-Case-Studies.md` | vulnerability | idor_analysis |
| `xss-stored-cases` | `02-XSS-Stored-Persistent-Attacks.md` | vulnerability | xss_stored_analysis |
| `sqli-breach-cases` | `03-SQL-Injection-Data-Breaches.md` | vulnerability | sqli_analysis |
| `ssrf-internal-cases` | `04-SSRF-Internal-Network-Access.md` | vulnerability | ssrf_analysis |
| `csrf-state-cases` | `05-CSRF-State-Changing-Attacks.md` | vulnerability | csrf_analysis |
| `cmdi-rce-cases` | `06-Command-Injection-RCE.md` | vulnerability | command_injection_analysis |
| `deser-rce-cases` | `07-Deserialization-Remote-Code-Execution.md` | vulnerability | deserialization_analysis |
| `file-upload-cases` | `08-File-Upload-Arbitrary-Upload.md` | vulnerability | file_upload_analysis |
| `xxe-cases` | `09-XXE-XML-External-Entity-Attacks.md` | vulnerability | xxe_analysis |
| `ssti-cases` | `10-SSTI-Server-Side-Template-Injection.md` | vulnerability | ssti_analysis |
| `jwt-cases` | `11-JWT-Token-Manipulation.md` | vulnerability | jwt_analysis |
| `auth-bypass-cases` | `12-Authentication-Bypass.md` | vulnerability | auth_bypass_analysis |
| `privesc-cases` | `13-Privilege-Escalation.md` | vulnerability | privilege_escalation_analysis |
| `business-logic-cases` | `14-Business-Logic-Flaws.md` | vulnerability | business_logic_analysis |
| `info-disc-cases` | `15-Information-Disclosure.md` | vulnerability | information_disclosure_analysis |
| `heap-overflow-cases` | `16-Memory-Corruption-Heap-Overflow.md` | vulnerability | memory_corruption_analysis |
| `java-deser-cases` | `17-Deserialization-Java-Deserialization.md` | vulnerability | java_deserialization_analysis |
| `php-unserialize-cases` | `18-Deserialization-PHP-Unserialize.md` | vulnerability | php_deserialization_analysis |
| `python-pickle-cases` | `19-Deserialization-Python-Pickle.md` | vulnerability | python_deserialization_analysis |
| `race-condition-cases` | `20-Race-Condition-Time-of-Check.md` | vulnerability | race_condition_analysis |
| `host-header-cases` | `21-Host-Header-Injection.md` | vulnerability | host_header_analysis |
| `dns-rebinding-cases` | `22-DNS-Rebinding-Attacks.md` | vulnerability | dns_rebinding_analysis |
| `websocket-cases` | `23-WebSocket-Security-Issues.md` | vulnerability | websocket_analysis |
| `graphql-cases` | `24-GraphQL-Introspection-Attacks.md` | vulnerability | graphql_analysis |
| `csp-bypass-cases` | `25-CSP-Bypass-Techniques.md` | vulnerability | csp_bypass_analysis |
| `clickjacking-cases` | `26-Clickjacking-UI-Redressing.md` | vulnerability | clickjacking_analysis |
| `response-splitting-cases` | `27-HTTP-Response-Splitting.md` | vulnerability | response_splitting_analysis |
| `ldap-injection-cases` | `28-LDAP-Injection-Attacks.md` | vulnerability | ldap_injection_analysis |
| `xpath-cases` | `29-XPath-Injection-Attacks.md` | vulnerability | xpath_injection_analysis |
| `nosql-cases` | `30-NoSQL-Injection-MongoDB.md` | vulnerability | nosql_analysis |
| `proto-pollution-cases` | `31-Prototype-Pollution-JavaScript.md` | vulnerability | prototype_pollution_analysis |
| `subdomain-takeover-cases` | `32-Subdomain-Takeover.md` | vulnerability | subdomain_takeover_analysis |
| `open-redirect-cases` | `33-Open-Redirect-Phishing.md` | vulnerability | open_redirect_analysis |
| `content-spoof-cases` | `34-Content-Spoofing-Attacks.md` | vulnerability | content_spoofing_analysis |
| `webcache-poison-cases` | `35-WebCache-Poisoning.md` | vulnerability | webcache_poisoning_analysis |
| `smuggling-cases` | `36-HTTP-Request-Smuggling.md` | vulnerability | http_smuggling_analysis |
| `ws-hijack-cases` | `37-WebSocket-Hijacking.md` | vulnerability | websocket_hijacking_analysis |
| `cors-misconfig-cases` | `38-CORS-Misconfiguration.md` | vulnerability | cors_misconfiguration_analysis |
| `token-leak-cases` | `39-Token-Leakage-URL-Parameters.md` | vulnerability | token_leakage_analysis |
| `data-exposure-cases` | `40-Sensitive-Data-Exposure.md` | vulnerability | sensitive_data_analysis |
| `weak-encryption-cases` | `41-Weak-Encryption-Algorithms.md` | vulnerability | weak_encryption_analysis |
| `insecure-crypto-storage-cases` | `42-Insecure-Cryptographic-Storage.md` | vulnerability | insecure_crypto_storage_analysis |
| `path-traversal-cases` | `43-Path-Traversal-File-Inclusion.md` | vulnerability | path_traversal_analysis |
| `lfi-cases` | `44-Local-File-Inclusion-LFI.md` | vulnerability | lfi_analysis |
| `rfi-cases` | `45-Remote-File-Inclusion-RFI.md` | vulnerability | rfi_analysis |
| `ssrf-advanced-cases` | `46-Server-Side-Request-Forgery.md` | vulnerability | ssrf_advanced_analysis |
| `csrff-cases` | `47-Client-Side-Request-Forgery.md` | vulnerability | csrff_analysis |
| `mobile-api-cases` | `48-Mobile-API-Security-Issues.md` | vulnerability | mobile_api_analysis |
| `cloud-misconfig-cases` | `49-Cloud-Misconfiguration-AWS.md` | vulnerability | cloud_misconfiguration_analysis |
| `api-auth-bypass-cases` | `50-API-Authentication-Bypass.md` | vulnerability | api_auth_bypass_analysis |

---

## Tool Registration Schema

```yaml
real_world_registration:
  name: string
  version: string
  category: string
  source_file: string
  capabilities: list[string]
  config: dict
  metadata: dict
  dependencies: dict
  status: enum              # active | disabled | error | pending
```

Each tool registration follows this canonical schema:

```yaml
tool:
  name: "pattern_extractor"
  version: "2.1.0"
  domain: "real-world-case-studies"
  category: "analysis"
  input_schema:
    type: "object"
    properties:
      report_content: { type: "string" }
      vuln_class: { type: "string" }
    required: ["report_content"]
  output_schema:
    type: "object"
    properties:
      pattern_id: { type: "string" }
      technique: { type: "string" }
      confidence: { type: "number" }
  config:
    timeout: 60
    retries: 2
    sandbox: false
```

---

## Registered Tools

### IDOR Account Takeover Analysis

```python
registry.register(
    name="idor-ato-analyzer",
    tool_class=IDORATOAnalyzerTool,
    config={
        "pattern_extraction": True,
        "bypass_technique_catalog": True,
        "impact_assessment": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["idor_analysis", "pattern_extraction", "bypass_cataloging"],
        "description": "Extract patterns from IDOR-to-ATO case studies",
        "tags": ["idor", "ato", "case-study", "pattern"],
        "source_file": "01-IDOR-Account-Takeover-Case-Studies.md"
    }
)
```

### SQL Injection Data Breach Analysis

```python
registry.register(
    name="sqli-breach-analyzer",
    tool_class=SQLIBreachAnalyzerTool,
    config={
        "dbms_patterns": True,
        "extraction_techniques": True,
        "waf_bypass_patterns": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["sqli_analysis", "extraction_pattern_analysis", "waf_bypass_patterns"],
        "description": "Analyze SQL injection data breach case studies",
        "tags": ["sqli", "data-breach", "case-study", "database"],
        "source_file": "03-SQL-Injection-Data-Breaches.md"
    }
)
```

### Deserialization Analysis

```python
registry.register(
    name="deser-analyzer",
    tool_class=DeserializationAnalyzerTool,
    config={
        "java_analysis": True,
        "php_analysis": True,
        "python_analysis": True,
        "gadget_chain_mapping": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["deserialization_analysis", "gadget_chain_mapping", "polyglot_detection"],
        "description": "Analyze deserialization vulnerability case studies across languages",
        "tags": ["deserialization", "java", "php", "python", "case-study"],
        "source_file": "07-Deserialization-Remote-Code-Execution.md"
    }
)
```

### Race Condition Analysis

```python
registry.register(
    name="race-analyzer",
    tool_class=RaceConditionAnalyzerTool,
    config={
        "timing_patterns": True,
        "concurrency_flaw_detection": True,
        "exploit_techniques": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["race_condition_analysis", "timing_pattern_extraction", "concurrency_flaw_detection"],
        "description": "Analyze race condition vulnerability case studies",
        "tags": ["race-condition", "concurrency", "case-study", "timing"],
        "source_file": "20-Race-Condition-Time-of-Check.md"
    }
)
```

### GraphQL Attack Analysis

```python
registry.register(
    name="graphql-case-analyzer",
    tool_class=GraphQLCaseAnalyzerTool,
    config={
        "introspection_abuse": True,
        "batch_query_patterns": True,
        "authorization_bypass": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["graphql_analysis", "introspection_abuse_patterns", "authorization_bypass_patterns"],
        "description": "Analyze GraphQL vulnerability case studies",
        "tags": ["graphql", "api", "case-study", "introspection"],
        "source_file": "24-GraphQL-Introspection-Attacks.md"
    }
)
```

### Cloud Misconfiguration Analysis

```python
registry.register(
    name="cloud-misconfig-cases-analyzer",
    tool_class=CloudMisconfigCasesAnalyzerTool,
    config={
        "aws_s3_patterns": True,
        "iam_abuse_patterns": True,
        "metadata_exploitation": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["cloud_misconfiguration_analysis", "aws_pattern_extraction", "iam_abuse_patterns"],
        "description": "Analyze cloud misconfiguration case studies",
        "tags": ["cloud", "aws", "misconfiguration", "case-study"],
        "source_file": "49-Cloud-Misconfiguration-AWS.md"
    }
)
```

### HTTP Smuggling Analysis

```python
registry.register(
    name="smuggling-case-analyzer",
    tool_class=SmugglingCaseAnalyzerTool,
    config={
        "cl_te_patterns": True,
        "te_cl_patterns": True,
        "h2_cl_patterns": True,
        "cache_poisoning_chains": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["http_smuggling_analysis", "technique_cataloging", "chain_mapping"],
        "description": "Analyze HTTP request smuggling case studies",
        "tags": ["smuggling", "http", "case-study", "cache-poisoning"],
        "source_file": "36-HTTP-Request-Smuggling.md"
    }
)
```

### JWT Token Manipulation Analysis

```python
registry.register(
    name="jwt-case-analyzer",
    tool_class=JWTCaseAnalyzerTool,
    config={
        "algorithm_confusion_patterns": True,
        "secret_analysis_patterns": True,
        "token_theft_patterns": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["jwt_analysis", "algorithm_confusion_patterns", "token_theft_patterns"],
        "description": "Analyze JWT token manipulation case studies",
        "tags": ["jwt", "token", "case-study", "authentication"],
        "source_file": "11-JWT-Token-Manipulation.md"
    }
)
```

### XSS Stored Attack Analysis

```python
registry.register(
    name="xss-stored-analyzer",
    tool_class=XSSStoredAnalyzerTool,
    config={
        "filter_bypass_patterns": True,
        "context_escape_patterns": True,
        "exfil_technique_catalog": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["xss_stored_analysis", "filter_bypass_patterns", "context_escape_patterns"],
        "description": "Analyze stored XSS attack case studies",
        "tags": ["xss", "stored", "case-study", "filter-bypass"],
        "source_file": "02-XSS-Stored-Persistent-Attacks.md"
    }
)
```

### Subdomain Takeover Analysis

```python
registry.register(
    name="subdomain-takeover-analyzer",
    tool_class=SubdomainTakeoverAnalyzerTool,
    config={
        "dangling_cname_patterns": True,
        "cloud_service_patterns": True,
        "reclaim_opportunities": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["subdomain_takeover_analysis", "dangling_cname_patterns", "cloud_service_patterns"],
        "description": "Analyze subdomain takeover case studies",
        "tags": ["subdomain", "takeover", "case-study", "dns"],
        "source_file": "32-Subdomain-Takeover.md"
    }
)
```

### Prototype Pollution Analysis

```python
registry.register(
    name="proto-pollution-analyzer",
    tool_class=PrototypePollutionAnalyzerTool,
    config={
        "javascript_sink_analysis": True,
        "gadget_chain_discovery": True,
        "rce_path_mapping": True
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["prototype_pollution_analysis", "javascript_sink_analysis", "rce_path_mapping"],
        "description": "Analyze JavaScript prototype pollution case studies",
        "tags": ["prototype", "pollution", "javascript", "case-study"],
        "source_file": "31-Prototype-Pollution-JavaScript.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_real_world_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> RealWorldRegistration:
    """Register a pattern extraction tool for disclosed case studies."""
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = RealWorldRegistration(
        id=generate_id(), name=name,
        version=metadata.get("version", "1.0.0"),
        category=metadata.get("category", "vulnerability"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        capabilities=metadata.get("capabilities", []),
        config=config or {}, metadata=metadata or {},
        registered_at=datetime.utcnow(), status="active"
    )
    self._tools[name] = registration
    self._index_category(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "real-world-case-studies"})
    return registration

def unregister_real_world_tool(self, name: str) -> bool:
    """Remove a pattern extraction tool from the registry."""
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True

def register_batch(self, tools: list[dict]) -> list[RealWorldRegistration]:
    """Register multiple tools in a single call."""
    registrations = []
    for tool_def in tools:
        reg = self.register_real_world_tool(
            name=tool_def["name"],
            tool_class=tool_def["class"],
            config=tool_def.get("config"),
            metadata=tool_def.get("metadata")
        )
        registrations.append(reg)
    return registrations
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[RealWorldRegistration]:
    """Discover tools by vulnerability category."""
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[RealWorldRegistration]:
    """Discover tools by specific capability."""
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_by_vuln_class(self, vuln_class: str) -> list[RealWorldRegistration]:
    """Discover tools by vulnerability class (e.g., 'injection', 'auth', 'crypto')."""
    return [t for t in self._tools.values() if vuln_class in t.metadata.get("tags", []) and t.status == "active"]

def discover_pattern_extractors(self) -> list[RealWorldRegistration]:
    """Discover tools that extract patterns from case studies."""
    return [t for t in self._tools.values() if "pattern_extraction" in t.capabilities and t.status == "active"]

def discover_by_source_file(self, filename: str) -> list[RealWorldRegistration]:
    """Discover tools mapped to a specific domain file."""
    return [t for t in self._tools.values() if t.source_file == filename]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[RealWorldRegistration]:
    """List all registered pattern extraction tools."""
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    """List all categories and their tools."""
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}

def list_by_vuln_class(self) -> dict[str, list[str]]:
    """List tools grouped by vulnerability class."""
    vuln_map = {}
    for t in self._tools.values():
        for tag in t.metadata.get("tags", []):
            if tag != "case-study":
                vuln_map.setdefault(tag, []).append(t.name)
    return {k: sorted(v) for k, v in sorted(vuln_map.items())}
```

---

## Tool Metadata

```yaml
real_world_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  case_count: int
  severity_distribution: dict
  disclosure_platforms: list[string]
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class RealWorldVersionManager:
    """Manages version lifecycle for disclosed analysis tools."""

    def check_compatibility(self, name: str, min_version: str) -> bool:
        """Check if tool meets minimum version requirement."""
        tool = self._tools.get(name)
        if not tool:
            return False
        return semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str, new_class: type = None) -> RealWorldRegistration:
        """Upgrade tool to new version with optional class replacement."""
        tool = self._tools[name]
        old_version = tool.version
        tool.version = new_version
        if new_class:
            tool.tool_class = new_class
        tool.metadata.setdefault("upgrade_history", []).append({
            "from": old_version,
            "to": new_version,
            "timestamp": datetime.utcnow().isoformat()
        })
        self._event_bus.emit("tool.upgraded", {"name": name, "from": old_version, "to": new_version})
        return tool
```

---

## Tool Dependencies

```python
class RealWorldDependencyManager:
    """Manages dependencies between disclosed analysis tools."""

    def resolve_dependencies(self, name: str) -> list[str]:
        """Resolve all dependencies for a tool."""
        tool = self._tools[name]
        return [d["name"] for d in tool.metadata.get("dependencies", {}).get("tool_dependencies", [])]

    def check_external_dependencies(self, name: str) -> dict[str, bool]:
        """Check if external binaries and libraries are available."""
        tool = self._tools[name]
        ext_deps = tool.metadata.get("dependencies", {})
        results = {}
        binary = ext_deps.get("binary")
        if binary:
            results[binary] = shutil.which(binary) is not None
        return results

    def get_complementary_tools(self, name: str) -> list[str]:
        """Find tools that complement a given analysis tool."""
        tool = self._tools[name]
        caps = set(tool.capabilities)
        return [
            t.name for t in self._tools.values()
            if t.name != name and not caps.intersection(set(t.capabilities))
        ]
```

---

## Full Domain File References

| # | File | Registered Tool |
|---|---|---|
| 1 | `01-IDOR-Account-Takeover-Case-Studies.md` | idor-ato-analyzer |
| 2 | `02-XSS-Stored-Persistent-Attacks.md` | xss-stored-analyzer |
| 3 | `03-SQL-Injection-Data-Breaches.md` | sqli-breach-analyzer |
| 4 | `04-SSRF-Internal-Network-Access.md` | ssrf-internal-cases |
| 5 | `05-CSRF-State-Changing-Attacks.md` | csrf-state-cases |
| 6 | `06-Command-Injection-RCE.md` | cmdi-rce-cases |
| 7 | `07-Deserialization-Remote-Code-Execution.md` | deser-analyzer |
| 8 | `08-File-Upload-Arbitrary-Upload.md` | file-upload-cases |
| 9 | `09-XXE-XML-External-Entity-Attacks.md` | xxe-cases |
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | ssti-cases |
| 11 | `11-JWT-Token-Manipulation.md` | jwt-case-analyzer |
| 12 | `12-Authentication-Bypass.md` | auth-bypass-cases |
| 13 | `13-Privilege-Escalation.md` | privesc-cases |
| 14 | `14-Business-Logic-Flaws.md` | business-logic-cases |
| 15 | `15-Information-Disclosure.md` | info-disc-cases |
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | heap-overflow-cases |
| 17 | `17-Deserialization-Java-Deserialization.md` | java-deser-cases |
| 18 | `18-Deserialization-PHP-Unserialize.md` | php-unserialize-cases |
| 19 | `19-Deserialization-Python-Pickle.md` | python-pickle-cases |
| 20 | `20-Race-Condition-Time-of-Check.md` | race-analyzer |
| 21 | `21-Host-Header-Injection.md` | host-header-cases |
| 22 | `22-DNS-Rebinding-Attacks.md` | dns-rebinding-cases |
| 23 | `23-WebSocket-Security-Issues.md` | websocket-cases |
| 24 | `24-GraphQL-Introspection-Attacks.md` | graphql-case-analyzer |
| 25 | `25-CSP-Bypass-Techniques.md` | csp-bypass-cases |
| 26 | `26-Clickjacking-UI-Redressing.md` | clickjacking-cases |
| 27 | `27-HTTP-Response-Splitting.md` | response-splitting-cases |
| 28 | `28-LDAP-Injection-Attacks.md` | ldap-injection-cases |
| 29 | `29-XPath-Injection-Attacks.md` | xpath-cases |
| 30 | `30-NoSQL-Injection-MongoDB.md` | nosql-cases |
| 31 | `31-Prototype-Pollution-JavaScript.md` | proto-pollution-analyzer |
| 32 | `32-Subdomain-Takeover.md` | subdomain-takeover-analyzer |
| 33 | `33-Open-Redirect-Phishing.md` | open-redirect-cases |
| 34 | `34-Content-Spoofing-Attacks.md` | content-spoof-cases |
| 35 | `35-WebCache-Poisoning.md` | webcache-poison-cases |
| 36 | `36-HTTP-Request-Smuggling.md` | smuggling-case-analyzer |
| 37 | `37-WebSocket-Hijacking.md` | ws-hijack-cases |
| 38 | `38-CORS-Misconfiguration.md` | cors-misconfig-cases |
| 39 | `39-Token-Leakage-URL-Parameters.md` | token-leak-cases |
| 40 | `40-Sensitive-Data-Exposure.md` | data-exposure-cases |
| 41 | `41-Weak-Encryption-Algorithms.md` | weak-encryption-cases |
| 42 | `42-Insecure-Cryptographic-Storage.md` | insecure-crypto-storage-cases |
| 43 | `43-Path-Traversal-File-Inclusion.md` | path-traversal-cases |
| 44 | `44-Local-File-Inclusion-LFI.md` | lfi-cases |
| 45 | `45-Remote-File-Inclusion-RFI.md` | rfi-cases |
| 46 | `46-Server-Side-Request-Forgery.md` | ssrf-advanced-cases |
| 47 | `47-Client-Side-Request-Forgery.md` | csrff-cases |
| 48 | `48-Mobile-API-Security-Issues.md` | mobile-api-cases |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | cloud-misconfig-cases-analyzer |
| 50 | `50-API-Authentication-Bypass.md` | api-auth-bypass-cases |
| 51 | `README.md` | (documentation) |

---

## Vulnerability Classes Index

| Vuln Class | Case Study Tools |
|---|---|
| `idor` | idor-ato-analyzer |
| `xss` | xss-stored-analyzer |
| `sqli` | sqli-breach-analyzer |
| `ssrf` | ssrf-internal-cases, ssrf-advanced-cases |
| `csrf` | csrf-state-cases, csrff-cases |
| `command-injection` | cmdi-rce-cases |
| `deserialization` | deser-analyzer, java-deser-cases, php-unserialize-cases, python-pickle-cases |
| `file-upload` | file-upload-cases |
| `xxe` | xxe-cases |
| `ssti` | ssti-cases |
| `jwt` | jwt-case-analyzer |
| `auth-bypass` | auth-bypass-cases, api-auth-bypass-cases |
| `privesc` | privesc-cases |
| `business-logic` | business-logic-cases |
| `info-disclosure` | info-disc-cases |
| `memory-corruption` | heap-overflow-cases |
| `race-condition` | race-analyzer |
| `host-header` | host-header-cases |
| `dns-rebinding` | dns-rebinding-cases |
| `websocket` | websocket-cases, ws-hijack-cases |
| `graphql` | graphql-case-analyzer |
| `csp-bypass` | csp-bypass-cases |
| `clickjacking` | clickjacking-cases |
| `response-splitting` | response-splitting-cases |
| `ldap` | ldap-injection-cases |
| `xpath` | xpath-cases |
| `nosql` | nosql-cases |
| `prototype-pollution` | proto-pollution-analyzer |
| `subdomain-takeover` | subdomain-takeover-analyzer |
| `open-redirect` | open-redirect-cases |
| `content-spoofing` | content-spoof-cases |
| `webcache-poisoning` | webcache-poison-cases |
| `smuggling` | smuggling-case-analyzer |
| `cors` | cors-misconfig-cases |
| `token-leakage` | token-leak-cases |
| `crypto` | weak-encryption-cases, insecure-crypto-storage-cases |
| `path-traversal` | path-traversal-cases, lfi-cases, rfi-cases |
| `cloud` | cloud-misconfig-cases-analyzer |
| `mobile-api` | mobile-api-cases |
| `sensitive-data` | data-exposure-cases |

---

## Lifecycle Hooks

| Hook Point | Description |
|---|---|
| `pre_register` | Validate tool configuration before registration |
| `post_register` | Index tool in capability and category maps |
| `pre_unregister` | Check for active analysis sessions |
| `post_unregister` | Clean up indices and emit events |
| `on_pattern_extracted` | Emit event when a new pattern is extracted |
| `on_case_analyzed` | Emit event when case study analysis completes |
| `on_upgrade` | Validate new version, update metadata |

---

*Part of the Brain tools subsystem — Real-World Case Studies Domain Registry.*
