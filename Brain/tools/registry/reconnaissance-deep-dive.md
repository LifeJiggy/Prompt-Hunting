# Reconnaissance Deep Dive — Tool Registry

**Domain:** `reconnaissance-deep-dive`
**Registry Path:** `Brain/tools/registry/reconnaissance-deep-dive.md`
**Source Directory:** `Reconnaissance-Deep-Dive/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages enumeration and fingerprinting tools for deep reconnaissance within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that perform comprehensive asset discovery, technology fingerprinting, OSINT collection, and attack surface mapping. Every tool registered here maps to files in the `Reconnaissance-Deep-Dive/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `subdomain-enum-adv` | `01-Advanced-Subdomain-Enumeration.md` | enumeration | advanced_subdomain_enum |
| `passive-osint` | `02-Passive-OSINT-Collection.md` | osint | passive_osint |
| `active-asset-discovery` | `03-Active-Asset-Discovery.md` | enumeration | active_asset_discovery |
| `tech-stack-fingerprint` | `04-Technology-Stack-Fingerprinting.md` | fingerprinting | technology_fingerprinting |
| `cloud-resource-enum` | `05-Cloud-Resource-Enumeration.md` | enumeration | cloud_resource_enum |
| `api-endpoint-discovery-recon` | `06-API-Endpoint-Discovery.md` | enumeration | api_endpoint_discovery |
| `js-source-analysis` | `07-JavaScript-Source-Analysis.md` | analysis | javascript_source_analysis |
| `config-file-extraction` | `08-Configuration-File-Extraction.md` | extraction | config_file_extraction |
| `version-detection` | `09-Version-Detection-Techniques.md` | fingerprinting | version_detection |
| `content-discovery-recon` | `10-Content-Discovery-Automation.md` | discovery | content_discovery |
| `dir-brute-recon` | `11-Directory-Brute-Forcing.md` | enumeration | directory_brute_forcing |
| `file-type-detection` | `12-File-Type-Detection.md` | detection | file_type_detection |
| `backup-file-discovery` | `13-Backup-File-Discovery.md` | discovery | backup_file_discovery |
| `source-code-leak` | `14-Source-Code-Leak-Detection.md` | detection | source_code_leak_detection |
| `git-repo-analysis` | `15-Git-Repository-Analysis.md` | analysis | git_repository_analysis |
| `dns-enum-adv` | `16-DNS-Enumeration-Advanced.md` | enumeration | advanced_dns_enumeration |
| `cert-transparency` | `17-Certificate-Transparency-Logs.md` | osint | certificate_transparency |
| `historical-data` | `18-Historical-Data-Analysis.md` | analysis | historical_data_analysis |
| `social-media-osint-recon` | `19-Social-Media-OSINT.md` | osint | social_media_osint |
| `employee-linked-assets` | `20-Employee-Linked-Assets.md` | osint | employee_asset_discovery |
| `third-party-integration-discovery` | `21-Third-Party-Integration-Discovery.md` | discovery | third_party_discovery |
| `web-archive-analysis` | `22-Web-Archive-Analysis.md` | analysis | web_archive_analysis |
| `pastebin-leak-search` | `23-Pastebin-and-Leak-Searching.md` | osint | leak_searching |
| `code-repo-mining` | `24-Code-Repository-Mining.md` | osint | code_repository_mining |
| `container-registry-enum` | `25-Container-Registry-Enumeration.md` | enumeration | container_registry_enum |
| `iot-device-discovery` | `26-IoT-Device-Discovery.md` | enumeration | iot_device_discovery |
| `mobile-app-analysis-recon` | `27-Mobile-App-Analysis.md` | analysis | mobile_app_analysis |
| `api-doc-extraction` | `28-API-Documentation-Extraction.md` | extraction | api_documentation_extraction |
| `websocket-endpoint-discovery` | `29-WebSocket-Endpoint-Discovery.md` | enumeration | websocket_endpoint_discovery |
| `graphql-introspection-recon` | `30-GraphQL-Introspection.md` | enumeration | graphql_introspection |
| `xml-rpc-soap-discovery` | `31-XML-RPC-and-SOAP-Discovery.md` | enumeration | xml_rpc_soap_discovery |
| `email-harvesting` | `32-Email-Address-Harvesting.md` | osint | email_address_harvesting |
| `phone-number-enum` | `33-Phone-Number-Enumeration.md` | osint | phone_number_enumeration |
| `physical-location-intel` | `34-Physical-Location-Intelligence.md` | osint | physical_location_intelligence |
| `supply-chain-asset-mapping` | `35-Supply-Chain-Asset-Mapping.md` | mapping | supply_chain_mapping |
| `competitor-analysis-recon` | `36-Competitor-Analysis.md` | analysis | competitor_analysis |
| `partner-network-discovery` | `37-Partner-Network-Discovery.md` | discovery | partner_network_discovery |
| `acquisition-target-analysis` | `38-Acquisition-Target-Analysis.md` | analysis | acquisition_target_analysis |
| `subsidiary-asset-mapping` | `39-Subsidiary-Asset-Mapping.md` | mapping | subsidiary_asset_mapping |
| `regional-infra-mapping` | `40-Regional-Infrastructure-Mapping.md` | mapping | regional_infrastructure_mapping |
| `cms-detection` | `41-Content-Management-System-Detection.md` | fingerprinting | cms_detection |
| `framework-library-id` | `42-Framework-and-Library-Identification.md` | fingerprinting | framework_library_identification |
| `server-config-analysis` | `43-Server-Configuration-Analysis.md` | analysis | server_configuration_analysis |
| `ssl-tls-cert-analysis` | `44-SSL-TLS-Certificate-Analysis.md` | analysis | ssl_tls_analysis |
| `http-header-intel` | `45-HTTP-Header-Intelligence.md` | fingerprinting | http_header_intelligence |
| `cookie-session-analysis` | `46-Cookie-Analysis-and-Session-Management.md` | analysis | cookie_session_analysis |
| `error-page-analysis` | `47-Error-Page-Analysis.md` | analysis | error_page_analysis |
| `debug-endpoint-discovery` | `48-Debug-Endpoint-Discovery.md` | discovery | debug_endpoint_discovery |
| `staging-env-detection` | `49-Staging-Environment-Detection.md` | detection | staging_environment_detection |
| `advanced-recon-strategy` | `50-Advanced-Reconnaissance-Strategy.md` | strategy | advanced_recon_strategy |

---

## Tool Registration Schema

```yaml
recon_registration:
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

### Advanced Subdomain Enumeration

```python
registry.register(
    name="subdomain-enum-adv",
    tool_class=SubdomainEnumAdvTool,
    config={
        "sources": ["crtsh", "virustotal", "shodan", "securitytrails", "alienvault"],
        "recursive": True,
        "max_depth": 3,
        "timeout": 600
    },
    metadata={
        "category": "enumeration",
        "capabilities": ["advanced_subdomain_enum", "passive_dns", "certificate_transparency"],
        "description": "Advanced subdomain enumeration using multiple intelligence sources",
        "tags": ["subdomain", "enumeration", "passive", "dns"],
        "source_file": "01-Advanced-Subdomain-Enumeration.md"
    }
)
```

### Technology Stack Fingerprinting

```python
registry.register(
    name="tech-fingerprint",
    tool_class=TechFingerprintTool,
    config={
        "wappalyzer": True,
        "whatweb": True,
        "custom_signatures": True,
        "timeout": 30
    },
    metadata={
        "category": "fingerprinting",
        "capabilities": ["technology_fingerprinting", "framework_detection", "cms_detection"],
        "description": "Comprehensive technology stack fingerprinting",
        "tags": ["fingerprinting", "technology", "framework", "cms"],
        "source_file": "04-Technology-Stack-Fingerprinting.md"
    }
)
```

### Cloud Resource Enumeration

```python
registry.register(
    name="cloud-resource-enum",
    tool_class=CloudResourceEnumTool,
    config={
        "providers": ["aws", "gcp", "azure"],
        "s3_bucket_enum": True,
        "storage_account_enum": True,
        "timeout": 300
    },
    metadata={
        "category": "enumeration",
        "capabilities": ["cloud_resource_enum", "s3_bucket_discovery", "storage_account_discovery"],
        "description": "Enumerate cloud resources across major providers",
        "tags": ["cloud", "enumeration", "aws", "gcp", "azure"],
        "source_file": "05-Cloud-Resource-Enumeration.md"
    }
)
```

### JavaScript Source Analysis

```python
registry.register(
    name="js-source-analyzer",
    tool_class=JSSourceAnalyzerTool,
    config={
        "endpoint_extraction": True,
        "secret_detection": True,
        "api_key_extraction": True,
        "minified_analysis": True
    },
    metadata={
        "category": "analysis",
        "capabilities": ["javascript_source_analysis", "endpoint_extraction", "secret_detection"],
        "description": "Deep analysis of JavaScript sources for endpoints and secrets",
        "tags": ["javascript", "analysis", "endpoints", "secrets"],
        "source_file": "07-JavaScript-Source-Analysis.md"
    }
)
```

### Certificate Transparency

```python
registry.register(
    name="cert-transparency",
    tool_class=CertTransparencyTool,
    config={
        "crt_sh": True,
        "ct_logs": True,
        "historical": True,
        "timeout": 60
    },
    metadata={
        "category": "osint",
        "capabilities": ["certificate_transparency", "subdomain_discovery", "historical_certs"],
        "description": "Leverage certificate transparency logs for reconnaissance",
        "tags": ["certificates", "transparency", "osint", "subdomain"],
        "source_file": "17-Certificate-Transparency-Logs.md"
    }
)
```

### Email Harvesting

```python
registry.register(
    name="email-harvester",
    tool_class=EmailHarvesterTool,
    config={
        "sources": ["theharvester", "hunter", "github", "linkedin"],
        "verification": True,
        "timeout": 120
    },
    metadata={
        "category": "osint",
        "capabilities": ["email_address_harvesting", "email_verification", "osint_collection"],
        "description": "Harvest and verify email addresses from multiple sources",
        "tags": ["email", "osint", "harvesting", "verification"],
        "source_file": "32-Email-Address-Harvesting.md"
    }
)
```

### GraphQL Introspection

```python
registry.register(
    name="graphql-introspection",
    tool_class=GraphQLIntrospectionTool,
    config={
        "schema_extraction": True,
        "query_enumeration": True,
        "depth_analysis": True,
        "timeout": 60
    },
    metadata={
        "category": "enumeration",
        "capabilities": ["graphql_introspection", "schema_extraction", "query_enumeration"],
        "description": "Perform GraphQL introspection for schema discovery",
        "tags": ["graphql", "introspection", "api", "schema"],
        "source_file": "30-GraphQL-Introspection.md"
    }
)
```

### Staging Environment Detection

```python
registry.register(
    name="staging-detector",
    tool_class=StagingDetectorTool,
    config={
        "subdomain_patterns": ["staging", "dev", "test", "qa", "sandbox"],
        "header_analysis": True,
        "response_comparison": True
    },
    metadata={
        "category": "detection",
        "capabilities": ["staging_environment_detection", "subdomain_pattern_matching", "response_comparison"],
        "description": "Detect staging and development environments",
        "tags": ["staging", "detection", "development", "environment"],
        "source_file": "49-Staging-Environment-Detection.md"
    }
)
```

### Advanced Recon Strategy

```python
registry.register(
    name="advanced-recon-strategy",
    tool_class=AdvancedReconStrategyTool,
    config={
        "pipeline_optimization": True,
        "parallel_execution": True,
        "result_correlation": True,
        "timeout": 3600
    },
    metadata={
        "category": "strategy",
        "capabilities": ["advanced_recon_strategy", "pipeline_optimization", "result_correlation"],
        "description": "Advanced reconnaissance strategy and pipeline optimization",
        "tags": ["strategy", "recon", "pipeline", "advanced"],
        "source_file": "50-Advanced-Reconnaissance-Strategy.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_recon_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> ReconRegistration:
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = ReconRegistration(
        id=generate_id(), name=name,
        version=metadata.get("version", "1.0.0"),
        category=metadata.get("category", "enumeration"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        capabilities=metadata.get("capabilities", []),
        config=config or {}, metadata=metadata or {},
        registered_at=datetime.utcnow(), status="active"
    )
    self._tools[name] = registration
    self._index_category(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "reconnaissance-deep-dive"})
    return registration

def unregister_recon_tool(self, name: str) -> bool:
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[ReconRegistration]:
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[ReconRegistration]:
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_osint_tools(self) -> list[ReconRegistration]:
    return [t for t in self._tools.values() if t.category == "osint" and t.status == "active"]

def discover_fingerprinting_tools(self) -> list[ReconRegistration]:
    return [t for t in self._tools.values() if t.category == "fingerprinting" and t.status == "active"]

def discover_enumeration_tools(self) -> list[ReconRegistration]:
    return [t for t in self._tools.values() if t.category == "enumeration" and t.status == "active"]

def discover_analysis_tools(self) -> list[ReconRegistration]:
    return [t for t in self._tools.values() if t.category == "analysis" and t.status == "active"]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[ReconRegistration]:
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}
```

---

## Tool Metadata

```yaml
recon_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  target_types: list[string]    # web | api | cloud | mobile | network
  passive: bool                 # Whether tool is passive only
  detection_risk: string        # low | medium | high
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class ReconVersionManager:
    def check_compatibility(self, name: str, min_version: str) -> bool:
        tool = self._tools.get(name)
        return tool and semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str) -> ReconRegistration:
        tool = self._tools[name]
        tool.version = new_version
        return tool
```

---

## Tool Dependencies

```python
class ReconDependencyManager:
    def resolve_dependencies(self, name: str) -> list[str]:
        tool = self._tools[name]
        return [d["name"] for d in tool.metadata.get("dependencies", {}).get("tool_dependencies", [])]

    def get_complementary_tools(self, name: str) -> list[str]:
        """Find tools that complement a given recon tool."""
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
| 1 | `01-Advanced-Subdomain-Enumeration.md` | subdomain-enum-adv |
| 2 | `02-Passive-OSINT-Collection.md` | passive-osint |
| 3 | `03-Active-Asset-Discovery.md` | active-asset-discovery |
| 4 | `04-Technology-Stack-Fingerprinting.md` | tech-fingerprint |
| 5 | `05-Cloud-Resource-Enumeration.md` | cloud-resource-enum |
| 6 | `06-API-Endpoint-Discovery.md` | api-endpoint-discovery-recon |
| 7 | `07-JavaScript-Source-Analysis.md` | js-source-analyzer |
| 8 | `08-Configuration-File-Extraction.md` | config-file-extraction |
| 9 | `09-Version-Detection-Techniques.md` | version-detection |
| 10 | `10-Content-Discovery-Automation.md` | content-discovery-recon |
| 11 | `11-Directory-Brute-Forcing.md` | dir-brute-recon |
| 12 | `12-File-Type-Detection.md` | file-type-detection |
| 13 | `13-Backup-File-Discovery.md` | backup-file-discovery |
| 14 | `14-Source-Code-Leak-Detection.md` | source-code-leak |
| 15 | `15-Git-Repository-Analysis.md` | git-repo-analysis |
| 16 | `16-DNS-Enumeration-Advanced.md` | dns-enum-adv |
| 17 | `17-Certificate-Transparency-Logs.md` | cert-transparency |
| 18 | `18-Historical-Data-Analysis.md` | historical-data |
| 19 | `19-Social-Media-OSINT.md` | social-media-osint-recon |
| 20 | `20-Employee-Linked-Assets.md` | employee-linked-assets |
| 21 | `21-Third-Party-Integration-Discovery.md` | third-party-integration-discovery |
| 22 | `22-Web-Archive-Analysis.md` | web-archive-analysis |
| 23 | `23-Pastebin-and-Leak-Searching.md` | pastebin-leak-search |
| 24 | `24-Code-Repository-Mining.md` | code-repo-mining |
| 25 | `25-Container-Registry-Enumeration.md` | container-registry-enum |
| 26 | `26-IoT-Device-Discovery.md` | iot-device-discovery |
| 27 | `27-Mobile-App-Analysis.md` | mobile-app-analysis-recon |
| 28 | `28-API-Documentation-Extraction.md` | api-doc-extraction |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | websocket-endpoint-discovery |
| 30 | `30-GraphQL-Introspection.md` | graphql-introspection |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | xml-rpc-soap-discovery |
| 32 | `32-Email-Address-Harvesting.md` | email-harvester |
| 33 | `33-Phone-Number-Enumeration.md` | phone-number-enum |
| 34 | `34-Physical-Location-Intelligence.md` | physical-location-intel |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | supply-chain-asset-mapping |
| 36 | `36-Competitor-Analysis.md` | competitor-analysis-recon |
| 37 | `37-Partner-Network-Discovery.md` | partner-network-discovery |
| 38 | `38-Acquisition-Target-Analysis.md` | acquisition-target-analysis |
| 39 | `39-Subsidiary-Asset-Mapping.md` | subsidiary-asset-mapping |
| 40 | `40-Regional-Infrastructure-Mapping.md` | regional-infra-mapping |
| 41 | `41-Content-Management-System-Detection.md` | cms-detection |
| 42 | `42-Framework-and-Library-Identification.md` | framework-library-id |
| 43 | `43-Server-Configuration-Analysis.md` | server-config-analysis |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | ssl-tls-cert-analysis |
| 45 | `45-HTTP-Header-Intelligence.md` | http-header-intel |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | cookie-session-analysis |
| 47 | `47-Error-Page-Analysis.md` | error-page-analysis |
| 48 | `48-Debug-Endpoint-Discovery.md` | debug-endpoint-discovery |
| 49 | `49-Staging-Environment-Detection.md` | staging-detector |
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | advanced-recon-strategy |
| 51 | `README.md` | (documentation) |

---

## Categories Index

| Category | Count | Tools |
|---|---|---|
| `enumeration` | 12 | subdomain-enum-adv, active-asset-discovery, cloud-resource-enum, api-endpoint-discovery-recon, dir-brute-recon, dns-enum-adv, container-registry-enum, iot-device-discovery, websocket-endpoint-discovery, graphql-introspection, xml-rpc-soap-discovery |
| `osint` | 8 | passive-osint, cert-transparency, social-media-osint-recon, employee-linked-assets, pastebin-leak-search, code-repo-mining, email-harvester, phone-number-enum, physical-location-intel |
| `fingerprinting` | 6 | tech-fingerprint, version-detection, cms-detection, framework-library-id, http-header-intel |
| `analysis` | 10 | js-source-analyzer, historical-data, web-archive-analysis, mobile-app-analysis-recon, competitor-analysis-recon, server-config-analysis, ssl-tls-cert-analysis, cookie-session-analysis, error-page-analysis, acquisition-target-analysis |
| `discovery` | 5 | content-discovery-recon, backup-file-discovery, third-party-integration-discovery, partner-network-discovery, debug-endpoint-discovery |
| `detection` | 3 | file-type-detection, source-code-leak, staging-detector |
| `extraction` | 2 | config-file-extraction, api-doc-extraction |
| `mapping` | 4 | supply-chain-asset-mapping, subsidiary-asset-mapping, regional-infra-mapping |
| `strategy` | 1 | advanced-recon-strategy |

---

*Part of the Brain tools subsystem — Reconnaissance Deep Dive Domain Registry.*
