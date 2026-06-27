# Core Prompts Hunting — Tool Registry

**Domain:** `core-prompts-hunting`
**Registry Path:** `Brain/tools/registry/core-prompts-hunting.md`
**Source Directory:** `Core-Prompts-hunting/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages security scanner tools and vulnerability hunting prompts within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that cover the full spectrum of web application security testing — from reconnaissance and input validation to advanced attack techniques. Every tool registered here maps to files in the `Core-Prompts-hunting/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `recon-asset-discovery` | `1-Reconnaissance-and-Asset-Discovery.md` | reconnaissance | asset_discovery |
| `js-analysis-deobfuscation` | `2-JavaScript-Analysis-and-Deobfuscation.md` | analysis | js_analysis |
| `api-endpoint-analysis` | `3-API-Endpoint-Analysis.md` | analysis | api_analysis |
| `auth-session-mgmt` | `4-Authentication-and-Session-Management.md` | testing | authentication_testing |
| `authz-access-control` | `5-Authorization-and-Access-Control.md` | testing | authorization_testing |
| `input-validation-sanitization` | `6-Input-Validation-and-Sanitization.md` | testing | input_validation |
| `business-logic-flaws` | `7-Business-Logic-Flaws.md` | testing | business_logic_testing |
| `client-storage-security` | `8-Client-Side-Storage-Security.md` | testing | client_storage_testing |
| `crypto-data-protection` | `9-Cryptography-and-Data-Protection.md` | testing | crypto_testing |
| `error-info-disclosure` | `10-Error-Handling-and-Information-Disclosure.md` | testing | information_disclosure |
| `file-upload-processing` | `11-File-Upload-and-Processing.md` | testing | file_upload_testing |
| `ssrf-testing` | `12-Server-Side-Request-Forgery-SSRF.md` | vulnerability | ssrf_testing |
| `csrf-testing` | `13-Cross-Site-Request-Forgery-CSRF.md` | vulnerability | csrf_testing |
| `cors-testing` | `14-Cross-Origin-Resource-Sharing-CORS.md` | vulnerability | cors_testing |
| `race-condition` | `15-Race-Conditions-and-Concurrency-Issues.md` | vulnerability | race_condition_testing |
| `third-party-analysis` | `16-Third-Party-Component-Analysis.md` | analysis | third_party_analysis |
| `config-misconfig` | `17-Configuration-and-Misconfiguration-Hunting.md` | testing | misconfiguration_hunting |
| `network-infra` | `18-Network-and-Infrastructure-Security.md` | testing | network_security |
| `mobile-api` | `19-Mobile-and-API-Specific-Vulnerabilities.md` | testing | mobile_api_testing |
| `reporting-poc` | `20-Reporting-and-Proof-of-Concept-Development.md` | reporting | poc_reporting |
| `waf-bypass` | `21-Web-Application-Firewall-WAF-Bypass.md` | bypass | waf_bypass |
| `http-smuggling` | `22-HTTP-Request-Smuggling.md` | vulnerability | http_smuggling |
| `subdomain-takeover` | `23-Subdomain-Takeover.md` | vulnerability | subdomain_takeover |
| `host-header-injection` | `24-Host-Header-Injection.md` | vulnerability | host_header_injection |
| `xxe-injection` | `25-XML-External-Entity-XXE-Injection.md` | vulnerability | xxe_testing |
| `insecure-deserialization` | `26-Insecure-Deserialization.md` | vulnerability | deserialization_testing |
| `command-injection` | `27-Command-Injection.md` | vulnerability | command_injection |
| `nosql-injection` | `28-NoSQL-Injection.md` | vulnerability | nosql_injection |
| `graphql-vulns` | `29-GraphQL-Vulnerabilities.md` | vulnerability | graphql_testing |
| `websocket-security` | `30-WebSocket-Security.md` | vulnerability | websocket_testing |
| `ssti-testing` | `31-Server-Side-Template-Injection.md` | vulnerability | ssti_testing |
| `jwt-vulns` | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | vulnerability | jwt_testing |
| `csp-bypass` | `33-Content-Security-Policy-CSP-Bypass.md` | bypass | csp_bypass |
| `clickjacking` | `34-Clickjacking-and-UI-Redressing.md` | vulnerability | clickjacking_testing |
| `hpp-testing` | `35-HTTP-Parameter-Pollution.md` | vulnerability | hpp_testing |
| `ldap-injection` | `36-LDAP-Injection.md` | vulnerability | ldap_injection |
| `session-puzzling` | `37-Session-Puzzling-and-Fixation.md` | vulnerability | session_puzzling |
| `insecure-file-handling` | `38-Insecure-File-Handling.md` | vulnerability | file_handling_testing |
| `xssi-testing` | `39-Cross-Site-Script-Inclusion-XSSI.md` | vulnerability | xssi_testing |
| `prototype-pollution` | `40-Prototype-Pollution.md` | vulnerability | prototype_pollution |
| `response-splitting` | `41-HTTP-Response-Splitting.md` | vulnerability | response_splitting |
| `xpath-injection` | `42-XPath-Injection.md` | vulnerability | xpath_injection |
| `csrf-advanced` | `43-Cross-Site-Request-Forgery-CSRF.md` | vulnerability | csrf_advanced |
| `cors-advanced` | `44-Cross-Origin-Resource-Sharing-CORS.md` | vulnerability | cors_advanced |
| `race-advanced` | `45-Race-Conditions-and-Concurrency-Issues.md` | vulnerability | race_condition_advanced |
| `third-party-advanced` | `46-Third-Party-Component-Analysis.md` | analysis | third_party_advanced |
| `config-advanced` | `47-Configuration-and-Misconfiguration-Hunting.md` | testing | misconfig_advanced |
| `network-advanced` | `48-Network-and-Infrastructure-Security.md` | testing | network_advanced |
| `mobile-api-advanced` | `49-Mobile-and-API-Specific-Vulnerabilities.md` | testing | mobile_api_advanced |
| `reporting-advanced` | `50-Reporting-and-Proof-of-Concept-Development.md` | reporting | reporting_advanced |

---

## Tool Registration Schema

```yaml
hunting_registration:
  name: string
  version: string
  category: string
  source_file: string
  capabilities: list[string]
  config: dict
  metadata: dict
  dependencies: dict
  status: enum
```

---

## Registered Tools

### Reconnaissance and Asset Discovery

```python
registry.register(
    name="recon-asset-discovery",
    tool_class=ReconAssetDiscoveryTool,
    config={
        "subdomain_enum": True,
        "port_scan": True,
        "tech_fingerprint": True,
        "depth": 3
    },
    metadata={
        "category": "reconnaissance",
        "capabilities": ["asset_discovery", "subdomain_enumeration", "port_scanning", "technology_fingerprinting"],
        "description": "Comprehensive reconnaissance and asset discovery scanner",
        "tags": ["recon", "discovery", "assets", "passive"],
        "source_file": "1-Reconnaissance-and-Asset-Discovery.md"
    }
)
```

### WAF Bypass

```python
registry.register(
    name="waf-bypass",
    tool_class=WAFBypassTool,
    config={
        "waf_detection": True,
        "bypass_techniques": ["case_variation", "encoding", "chunking", "parameter_pollution"],
        "timeout": 120
    },
    metadata={
        "category": "bypass",
        "capabilities": ["waf_bypass", "waf_detection", "evasion_techniques"],
        "description": "Bypass Web Application Firewalls using advanced evasion",
        "tags": ["waf", "bypass", "evasion", "advanced"],
        "source_file": "21-Web-Application-Firewall-WAF-Bypass.md"
    }
)
```

### HTTP Request Smuggling

```python
registry.register(
    name="http-smuggling",
    tool_class=HTTPSmugglingTool,
    config={
        "techniques": ["CL.TE", "TE.CL", "H2.CL", "H2.TE"],
        "detection_mode": "safe",
        "timeout": 60
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["http_smuggling", "request_smuggling", "cache_poisoning"],
        "description": "Detect and exploit HTTP request smuggling vulnerabilities",
        "tags": ["smuggling", "http", "vulnerability"],
        "source_file": "22-HTTP-Request-Smuggling.md"
    }
)
```

### SSTI Testing

```python
registry.register(
    name="ssti-scanner",
    tool_class=SSTIScannerTool,
    config={
        "engines": ["jinja2", "twig", "freemarker", "erb", "velocity", "mako"],
        "rce_test": True,
        "timeout": 60
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["ssti_testing", "template_injection", "rce_detection"],
        "description": "Server-side template injection detection and exploitation",
        "tags": ["ssti", "template", "injection", "rce"],
        "source_file": "31-Server-Side-Template-Injection.md"
    }
)
```

### Prototype Pollution

```python
registry.register(
    name="proto-pollution-scanner",
    tool_class=PrototypePollutionScannerTool,
    config={
        "sink_detection": True,
        "javascript_analysis": True,
        "timeout": 120
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["prototype_pollution", "javascript_analysis", "sink_detection"],
        "description": "Detect JavaScript prototype pollution vulnerabilities",
        "tags": ["prototype", "pollution", "javascript", "vulnerability"],
        "source_file": "40-Prototype-Pollution.md"
    }
)
```

### GraphQL Vulnerabilities

```python
registry.register(
    name="graphql-scanner",
    tool_class=GraphQLScannerTool,
    config={
        "introspection": True,
        "depth_limit": 10,
        "batch_queries": True,
        "timeout": 60
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["graphql_testing", "introspection_abuse", "batch_query_abuse"],
        "description": "GraphQL API vulnerability scanner",
        "tags": ["graphql", "api", "introspection", "vulnerability"],
        "source_file": "29-GraphQL-Vulnerabilities.md"
    }
)
```

### JWT Vulnerabilities

```python
registry.register(
    name="jwt-scanner",
    tool_class=JWTScannerTool,
    config={
        "algorithm_attacks": True,
        "secret_analysis": True,
        "token_manipulation": True,
        "timeout": 60
    },
    metadata={
        "category": "vulnerability",
        "capabilities": ["jwt_testing", "algorithm_confusion", "secret_bruteforce", "token_analysis"],
        "description": "JSON Web Token vulnerability scanner",
        "tags": ["jwt", "token", "authentication", "crypto"],
        "source_file": "32-JSON-Web-Token-JWT-Vulnerabilities.md"
    }
)
```

### CSP Bypass

```python
registry.register(
    name="csp-bypass-scanner",
    tool_class=CSPBypassScannerTool,
    config={
        "bypass_techniques": ["base-uri", "jsonp", "svg", "host-header"],
        "timeout": 60
    },
    metadata={
        "category": "bypass",
        "capabilities": ["csp_bypass", "policy_analysis", "bypass_technique_detection"],
        "description": "Content Security Policy bypass detection and exploitation",
        "tags": ["csp", "bypass", "security-policy"],
        "source_file": "33-Content-Security-Policy-CSP-Bypass.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_hunting_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> HuntingRegistration:
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = HuntingRegistration(
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
    self._event_bus.emit("tool.registered", {"name": name, "domain": "core-prompts-hunting"})
    return registration

def unregister_hunting_tool(self, name: str) -> bool:
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[HuntingRegistration]:
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[HuntingRegistration]:
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_vulnerability_tools(self) -> list[HuntingRegistration]:
    return [t for t in self._tools.values() if t.category == "vulnerability" and t.status == "active"]

def discover_bypass_tools(self) -> list[HuntingRegistration]:
    return [t for t in self._tools.values() if t.category == "bypass" and t.status == "active"]

def discover_recon_tools(self) -> list[HuntingRegistration]:
    return [t for t in self._tools.values() if t.category == "reconnaissance" and t.status == "active"]

def discover_testing_tools(self) -> list[HuntingRegistration]:
    return [t for t in self._tools.values() if t.category == "testing" and t.status == "active"]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[HuntingRegistration]:
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}
```

---

## Tool Metadata

```yaml
hunting_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  target_types: list[string]    # web | api | mobile | cloud | network
  severity_potential: string    # low | medium | high | critical
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class HuntingVersionManager:
    def check_compatibility(self, name: str, min_version: str) -> bool:
        tool = self._tools.get(name)
        return tool and semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str) -> HuntingRegistration:
        tool = self._tools[name]
        tool.version = new_version
        return tool
```

---

## Tool Dependencies

```python
class HuntingDependencyManager:
    def resolve_dependencies(self, name: str) -> list[str]:
        tool = self._tools[name]
        return [d["name"] for d in tool.metadata.get("dependencies", {}).get("tool_dependencies", [])]
```

---

## Full Domain File References

| # | File | Registered Tool |
|---|---|---|
| 1 | `1-Reconnaissance-and-Asset-Discovery.md` | recon-asset-discovery |
| 2 | `2-JavaScript-Analysis-and-Deobfuscation.md` | js-analysis-deobfuscation |
| 3 | `3-API-Endpoint-Analysis.md` | api-endpoint-analysis |
| 4 | `4-Authentication-and-Session-Management.md` | auth-session-mgmt |
| 5 | `5-Authorization-and-Access-Control.md` | authz-access-control |
| 6 | `6-Input-Validation-and-Sanitization.md` | input-validation-sanitization |
| 7 | `7-Business-Logic-Flaws.md` | business-logic-flaws |
| 8 | `8-Client-Side-Storage-Security.md` | client-storage-security |
| 9 | `9-Cryptography-and-Data-Protection.md` | crypto-data-protection |
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | error-info-disclosure |
| 11 | `11-File-Upload-and-Processing.md` | file-upload-processing |
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | ssrf-testing |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | csrf-testing |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | cors-testing |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | race-condition |
| 16 | `16-Third-Party-Component-Analysis.md` | third-party-analysis |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | config-misconfig |
| 18 | `18-Network-and-Infrastructure-Security.md` | network-infra |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | mobile-api |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | reporting-poc |
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | waf-bypass |
| 22 | `22-HTTP-Request-Smuggling.md` | http-smuggling |
| 23 | `23-Subdomain-Takeover.md` | subdomain-takeover |
| 24 | `24-Host-Header-Injection.md` | host-header-injection |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | xxe-injection |
| 26 | `26-Insecure-Deserialization.md` | insecure-deserialization |
| 27 | `27-Command-Injection.md` | command-injection |
| 28 | `28-NoSQL-Injection.md` | nosql-injection |
| 29 | `29-GraphQL-Vulnerabilities.md` | graphql-vulns |
| 30 | `30-WebSocket-Security.md` | websocket-security |
| 31 | `31-Server-Side-Template-Injection.md` | ssti-testing |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | jwt-vulns |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | csp-bypass |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | clickjacking |
| 35 | `35-HTTP-Parameter-Pollution.md` | hpp-testing |
| 36 | `36-LDAP-Injection.md` | ldap-injection |
| 37 | `37-Session-Puzzling-and-Fixation.md` | session-puzzling |
| 38 | `38-Insecure-File-Handling.md` | insecure-file-handling |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | xssi-testing |
| 40 | `40-Prototype-Pollution.md` | prototype-pollution |
| 41 | `41-HTTP-Response-Splitting.md` | response-splitting |
| 42 | `42-XPath-Injection.md` | xpath-injection |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | csrf-advanced |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | cors-advanced |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | race-advanced |
| 46 | `46-Third-Party-Component-Analysis.md` | third-party-advanced |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | config-advanced |
| 48 | `48-Network-and-Infrastructure-Security.md` | network-advanced |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | mobile-api-advanced |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | reporting-advanced |
| 51 | `README.md` | (documentation) |

---

## Capabilities Index

| Capability | Tools |
|---|---|
| `asset_discovery` | recon-asset-discovery |
| `js_analysis` | js-analysis-deobfuscation |
| `api_analysis` | api-endpoint-analysis |
| `authentication_testing` | auth-session-mgmt |
| `authorization_testing` | authz-access-control |
| `input_validation` | input-validation-sanitization |
| `business_logic_testing` | business-logic-flaws |
| `ssrf_testing` | ssrf-testing |
| `csrf_testing` | csrf-testing, csrf-advanced |
| `cors_testing` | cors-testing, cors-advanced |
| `race_condition_testing` | race-condition, race-advanced |
| `http_smuggling` | http-smuggling |
| `subdomain_takeover` | subdomain-takeover |
| `xxe_testing` | xxe-injection |
| `deserialization_testing` | insecure-deserialization |
| `command_injection` | command-injection |
| `nosql_injection` | nosql-injection |
| `graphql_testing` | graphql-vulns |
| `websocket_testing` | websocket-security |
| `ssti_testing` | ssti-testing |
| `jwt_testing` | jwt-vulns |
| `waf_bypass` | waf-bypass |
| `csp_bypass` | csp-bypass |
| `prototype_pollution` | prototype-pollution |
| `clickjacking_testing` | clickjacking |
| `hpp_testing` | hpp-testing |
| `ldap_injection` | ldap-injection |
| `session_puzzling` | session-puzzling |
| `xpath_injection` | xpath-injection |
| `xssi_testing` | xssi-testing |
| `poc_reporting` | reporting-poc, reporting-advanced |

---

*Part of the Brain tools subsystem — Core Prompts Hunting Domain Registry.*
