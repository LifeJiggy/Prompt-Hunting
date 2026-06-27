# Core Prompts Learning — Tool Registry

**Domain:** `core-prompts-learning`
**Registry Path:** `Brain/tools/registry/core-prompts-learning.md`
**Source Directory:** `Core-Prompts-Learning/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages content delivery and assessment tools for security learning within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that deliver educational content, track learning progress, assess knowledge, and guide learners through security concepts. Every tool registered here maps to files in the `Core-Prompts-Learning/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `recon-learning` | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | content | recon_learning |
| `js-analysis-learning` | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | content | js_analysis_learning |
| `api-analysis-learning` | `3-API-Endpoint-Analysis-Learning.md` | content | api_analysis_learning |
| `auth-session-learning` | `4-Authentication-and-Session-Management-Learning.md` | content | auth_learning |
| `authz-learning` | `5-Authorization-and-Access-Control-Learning.md` | content | authz_learning |
| `input-validation-learning` | `6-Input-Validation-and-Sanitization-Learning.md` | content | input_validation_learning |
| `business-logic-learning` | `7-Business-Logic-Flaws-Learning.md` | content | business_logic_learning |
| `client-storage-learning` | `8-Client-Side-Storage-Security-Learning.md` | content | client_storage_learning |
| `crypto-learning` | `9-Cryptography-and-Data-Protection-Learning.md` | content | crypto_learning |
| `error-disclosure-learning` | `10-Error-Handling-and-Information-Disclosure-Learning.md` | content | error_handling_learning |
| `file-upload-learning` | `11-File-Upload-and-Processing-Learning.md` | content | file_upload_learning |
| `ssrf-learning` | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | content | ssrf_learning |
| `csrf-learning` | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | content | csrf_learning |
| `cors-learning` | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | content | cors_learning |
| `race-learning` | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | content | race_condition_learning |
| `third-party-learning` | `16-Third-Party-Component-Analysis-Learning.md` | content | third_party_learning |
| `config-learning` | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | content | misconfig_learning |
| `network-learning` | `18-Network-and-Infrastructure-Security-Learning.md` | content | network_learning |
| `mobile-api-learning` | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | content | mobile_api_learning |
| `reporting-learning` | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | content | reporting_learning |
| `waf-bypass-learning` | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | content | waf_bypass_learning |
| `smuggling-learning` | `22-HTTP-Request-Smuggling-Learning.md` | content | smuggling_learning |
| `subdomain-learning` | `23-Subdomain-Takeover-Learning.md` | content | subdomain_learning |
| `host-header-learning` | `24-Host-Header-Injection-Learning.md` | content | host_header_learning |
| `xxe-learning` | `25-XML-External-Entity-XXE-Injection-Learning.md` | content | xxe_learning |
| `deserialization-learning` | `26-Insecure-Deserialization-Learning.md` | content | deserialization_learning |
| `cmdi-learning` | `27-Command-Injection-Learning.md` | content | command_injection_learning |
| `nosql-learning` | `28-NoSQL-Injection-Learning.md` | content | nosql_learning |
| `graphql-learning` | `29-GraphQL-Vulnerabilities-Learning.md` | content | graphql_learning |
| `websocket-learning` | `30-WebSocket-Security-Learning.md` | content | websocket_learning |
| `ssti-learning` | `31-Server-Side-Template-Injection-SSTI-Learning.md` | content | ssti_learning |
| `jwt-learning` | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | content | jwt_learning |
| `csp-learning` | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | content | csp_learning |
| `clickjacking-learning` | `34-Clickjacking-and-UI-Redressing-Learning.md` | content | clickjacking_learning |
| `hpp-learning` | `35-HTTP-Parameter-Pollution-Learning.md` | content | hpp_learning |
| `ldap-learning` | `36-LDAP-Injection-Learning.md` | content | ldap_learning |
| `session-learning` | `37-Session-Puzzling-and-Fixation-Learning.md` | content | session_learning |
| `file-handling-learning` | `38-Insecure-File-Handling-Learning.md` | content | file_handling_learning |
| `client-side-learning` | `39-Advanced-Client-Side-Attacks-Learning.md` | content | client_side_learning |
| `cloud-learning` | `40-Cloud-Security-and-Misconfigurations-Learning.md` | content | cloud_learning |
| `third-party-integration-learning` | `41-Third-Party-Integration-Security-Learning.md` | content | third_party_integration_learning |
| `mobile-app-learning` | `42-Mobile-Application-Security-Learning.md` | content | mobile_app_learning |
| `iot-learning` | `43-IoT-and-Embedded-Device-Security-Learning.md` | content | iot_learning |
| `api-security-learning` | `44-API-Security-and-GraphQL-Learning.md` | content | api_security_learning |
| `wasm-learning` | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | content | wasm_learning |
| `blockchain-learning` | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | content | blockchain_learning |
| `automation-learning` | `47-Automation-and-Tool-Development-Learning.md` | content | automation_learning |
| `reverse-engineering-learning` | `48-Advanced-Reverse-Engineering-Learning.md` | content | reverse_engineering_learning |
| `compliance-learning` | `49-Compliance-and-Regulatory-Security-Learning.md` | content | compliance_learning |
| `threat-modeling-learning` | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | content | threat_modeling_learning |

---

## Tool Registration Schema

```yaml
learning_registration:
  name: string
  version: string
  category: string            # content | assessment | progress | certification
  source_file: string
  capabilities: list[string]
  config: dict
  metadata: dict
  dependencies: dict
  status: enum
```

---

## Registered Tools

### Reconnaissance Learning

```python
registry.register(
    name="recon-learning",
    tool_class=ReconLearningTool,
    config={
        "difficulty_levels": ["beginner", "intermediate", "advanced"],
        "interactive_examples": True,
        "hands_on_labs": True
    },
    metadata={
        "category": "content",
        "capabilities": ["recon_learning", "asset_discovery_education", "hands_on_labs"],
        "description": "Interactive learning module for reconnaissance and asset discovery",
        "tags": ["learning", "recon", "interactive", "labs"],
        "source_file": "1-Reconnaissance-and-Asset-Discovery-Learning.md"
    }
)
```

### WAF Bypass Learning

```python
registry.register(
    name="waf-bypass-learning",
    tool_class=WAFBypassLearningTool,
    config={
        "bypass_categories": ["encoding", "evasion", "protocol"],
        "practical_exercises": True,
        "difficulty": "advanced"
    },
    metadata={
        "category": "content",
        "capabilities": ["waf_bypass_learning", "evasion_techniques_education"],
        "description": "Advanced learning module for WAF bypass techniques",
        "tags": ["learning", "waf", "bypass", "advanced"],
        "source_file": "21-Web-Application-Firewall-WAF-Bypass-Learning.md"
    }
)
```

### SSTI Learning

```python
registry.register(
    name="ssti-learning",
    tool_class=SSTILearningTool,
    config={
        "engines_covered": ["jinja2", "twig", "freemarker", "erb", "spring", "velocity"],
        "rce_progression": True,
        "sandbox_exercises": True
    },
    metadata={
        "category": "content",
        "capabilities": ["ssti_learning", "template_injection_education", "rce_progression"],
        "description": "Learning module for server-side template injection",
        "tags": ["learning", "ssti", "template", "rce"],
        "source_file": "31-Server-Side-Template-Injection-SSTI-Learning.md"
    }
)
```

### Cloud Security Learning

```python
registry.register(
    name="cloud-learning",
    tool_class=CloudLearningTool,
    config={
        "cloud_providers": ["aws", "gcp", "azure"],
        "lab_environments": True,
        "real_world_scenarios": True
    },
    metadata={
        "category": "content",
        "capabilities": ["cloud_learning", "cloud_misconfiguration_education", "lab_environments"],
        "description": "Cloud security and misconfiguration learning module",
        "tags": ["learning", "cloud", "aws", "gcp", "azure"],
        "source_file": "40-Cloud-Security-and-Misconfigurations-Learning.md"
    }
)
```

### Threat Modeling Learning

```python
registry.register(
    name="threat-modeling-learning",
    tool_class=ThreatModelingLearningTool,
    config={
        "frameworks": ["stride", "dread", "pasta", "attack_tree"],
        "case_studies": True,
        "assessment_quizzes": True
    },
    metadata={
        "category": "content",
        "capabilities": ["threat_modeling_learning", "risk_assessment_education", "framework_training"],
        "description": "Advanced threat modeling and risk assessment learning",
        "tags": ["learning", "threat-modeling", "risk", "advanced"],
        "source_file": "50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md"
    }
)
```

### Reverse Engineering Learning

```python
registry.register(
    name="reverse-engineering-learning",
    tool_class=ReverseEngineeringLearningTool,
    config={
        "tools_covered": ["ghidra", "ida", "radare2", "x64dbg"],
        "binary_types": ["pe", "elf", "macho"],
        "practical_exercises": True
    },
    metadata={
        "category": "content",
        "capabilities": ["reverse_engineering_learning", "binary_analysis_education"],
        "description": "Advanced reverse engineering and binary analysis learning",
        "tags": ["learning", "reverse-engineering", "binary", "advanced"],
        "source_file": "48-Advanced-Reverse-Engineering-Learning.md"
    }
)
```

### Blockchain Learning

```python
registry.register(
    name="blockchain-learning",
    tool_class=BlockchainLearningTool,
    config={
        "chains_covered": ["ethereum", "solana", "bitcoin"],
        "smart_contract_analysis": True,
        "exploit_development": True
    },
    metadata={
        "category": "content",
        "capabilities": ["blockchain_learning", "smart_contract_security_education"],
        "description": "Blockchain and cryptocurrency security learning module",
        "tags": ["learning", "blockchain", "smart-contract", "web3"],
        "source_file": "46-Blockchain-and-Cryptocurrency-Security-Learning.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_learning_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> LearningRegistration:
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = LearningRegistration(
        id=generate_id(), name=name,
        version=metadata.get("version", "1.0.0"),
        category=metadata.get("category", "content"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        capabilities=metadata.get("capabilities", []),
        config=config or {}, metadata=metadata or {},
        registered_at=datetime.utcnow(), status="active"
    )
    self._tools[name] = registration
    self._index_category(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "core-prompts-learning"})
    return registration

def unregister_learning_tool(self, name: str) -> bool:
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[LearningRegistration]:
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[LearningRegistration]:
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_by_difficulty(self, difficulty: str) -> list[LearningRegistration]:
    return [t for t in self._tools.values() if t.metadata.get("difficulty") == difficulty and t.status == "active"]

def discover_by_topic(self, topic: str) -> list[LearningRegistration]:
    """Discover learning tools by security topic."""
    return [t for t in self._tools.values() if topic in t.metadata.get("tags", []) and t.status == "active"]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[LearningRegistration]:
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}

def list_by_difficulty(self) -> dict[str, list[str]]:
    difficulty_map = {}
    for t in self._tools.values():
        diff = t.metadata.get("difficulty", "unspecified")
        difficulty_map.setdefault(diff, []).append(t.name)
    return {k: sorted(v) for k, v in sorted(difficulty_map.items())}
```

---

## Tool Metadata

```yaml
learning_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  difficulty: string            # beginner | intermediate | advanced | expert
  estimated_time: string        # e.g., "2 hours"
  prerequisites: list[string]
  learning_objectives: list[string]
  hands_on: bool
  assessment_included: bool
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class LearningVersionManager:
    def check_compatibility(self, name: str, min_version: str) -> bool:
        tool = self._tools.get(name)
        return tool and semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str) -> LearningRegistration:
        tool = self._tools[name]
        tool.version = new_version
        return tool
```

---

## Tool Dependencies

```python
class LearningDependencyManager:
    def resolve_dependencies(self, name: str) -> list[str]:
        tool = self._tools[name]
        return tool.metadata.get("prerequisites", [])

    def get_learning_path(self, topic: str) -> list[str]:
        """Generate a learning path for a given topic."""
        related = [t for t in self._tools.values() if topic in t.metadata.get("tags", [])]
        related.sort(key=lambda t: {"beginner": 1, "intermediate": 2, "advanced": 3, "expert": 4}.get(t.metadata.get("difficulty", ""), 5))
        return [t.name for t in related]
```

---

## Full Domain File References

| # | File | Registered Tool |
|---|---|---|
| 1 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | recon-learning |
| 2 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | js-analysis-learning |
| 3 | `3-API-Endpoint-Analysis-Learning.md` | api-analysis-learning |
| 4 | `4-Authentication-and-Session-Management-Learning.md` | auth-session-learning |
| 5 | `5-Authorization-and-Access-Control-Learning.md` | authz-learning |
| 6 | `6-Input-Validation-and-Sanitization-Learning.md` | input-validation-learning |
| 7 | `7-Business-Logic-Flaws-Learning.md` | business-logic-learning |
| 8 | `8-Client-Side-Storage-Security-Learning.md` | client-storage-learning |
| 9 | `9-Cryptography-and-Data-Protection-Learning.md` | crypto-learning |
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | error-disclosure-learning |
| 11 | `11-File-Upload-and-Processing-Learning.md` | file-upload-learning |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | ssrf-learning |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | csrf-learning |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | cors-learning |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | race-learning |
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | third-party-learning |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | config-learning |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | network-learning |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | mobile-api-learning |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | reporting-learning |
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | waf-bypass-learning |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | smuggling-learning |
| 23 | `23-Subdomain-Takeover-Learning.md` | subdomain-learning |
| 24 | `24-Host-Header-Injection-Learning.md` | host-header-learning |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | xxe-learning |
| 26 | `26-Insecure-Deserialization-Learning.md` | deserialization-learning |
| 27 | `27-Command-Injection-Learning.md` | cmdi-learning |
| 28 | `28-NoSQL-Injection-Learning.md` | nosql-learning |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | graphql-learning |
| 30 | `30-WebSocket-Security-Learning.md` | websocket-learning |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | ssti-learning |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | jwt-learning |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | csp-learning |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | clickjacking-learning |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | hpp-learning |
| 36 | `36-LDAP-Injection-Learning.md` | ldap-learning |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | session-learning |
| 38 | `38-Insecure-File-Handling-Learning.md` | file-handling-learning |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | client-side-learning |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | cloud-learning |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | third-party-integration-learning |
| 42 | `42-Mobile-Application-Security-Learning.md` | mobile-app-learning |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | iot-learning |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | api-security-learning |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | wasm-learning |
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | blockchain-learning |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | automation-learning |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | reverse-engineering-learning |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | compliance-learning |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | threat-modeling-learning |
| 51 | `README.md` | (documentation) |

---

## Learning Path Index

| Topic | Learning Tools (Ordered by Difficulty) |
|---|---|
| `web-security` | recon-learning -> input-validation-learning -> auth-session-learning -> csrf-learning -> ssrf-learning -> ssti-learning |
| `api-security` | api-analysis-learning -> graphql-learning -> jwt-learning -> api-security-learning |
| `cloud-security` | cloud-learning -> third-party-integration-learning |
| `advanced` | waf-bypass-learning -> smuggling-learning -> reverse-engineering-learning -> threat-modeling-learning |
| `iot-embedded` | iot-learning -> mobile-app-learning |
| `web3` | blockchain-learning |
| `compliance` | compliance-learning -> threat-modeling-learning |

---

*Part of the Brain tools subsystem — Core Prompts Learning Domain Registry.*
