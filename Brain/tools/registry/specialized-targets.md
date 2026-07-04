# Specialized Targets — Tool Registry

**Domain:** `specialized-targets`
**Registry Path:** `Brain/tools/registry/specialized-targets.md`
**Source Directory:** `Specialized-Targets/`
**File Count:** 50 domain files

---

## Overview

This tool registry manages category-specific tools for specialized target security testing within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that perform security assessments across IoT, mobile, cloud, blockchain, industrial control systems, and enterprise environments. Every tool registered here maps to files in the `Specialized-Targets/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `iot-device-security` | `01-IoT-Device-Security.md` | iot | iot_device_security |
| `mobile-app-testing` | `02-Mobile-Application-Testing.md` | mobile | mobile_app_testing |
| `cloud-infra-security` | `03-Cloud-Infrastructure-Security.md` | cloud | cloud_infrastructure_security |
| `container-security` | `04-Container-Security.md` | container | container_security |
| `kubernetes-security` | `05-Kubernetes-Cluster-Security.md` | container | kubernetes_security |
| `blockchain-smart-contracts` | `06-Blockchain-Smart-Contracts.md` | blockchain | smart_contract_security |
| `defi-protocol-security` | `07-DeFi-Protocol-Security.md` | blockchain | defi_protocol_security |
| `nft-marketplace-security` | `08-NFT-Marketplace-Security.md` | blockchain | nft_marketplace_security |
| `web3-app-security` | `09-Web3-Application-Security.md` | blockchain | web3_application_security |
| `crypto-exchange-security` | `10-Cryptocurrency-Exchange-Security.md` | blockchain | cryptocurrency_exchange_security |
| `tradfi-api-security` | `11-Traditional-Finance-API-Security.md` | finance | tradfi_api_security |
| `healthcare-security` | `12-Healthcare-System-Security.md` | industry | healthcare_security |
| `financial-inst-security` | `13-Financial-Institution-Security.md` | industry | financial_institution_security |
| `government-security` | `14-Government-System-Security.md` | industry | government_system_security |
| `education-security` | `15-Education-Platform-Security.md` | industry | education_platform_security |
| `ecommerce-security` | `16-E-commerce-Platform-Security.md` | industry | ecommerce_platform_security |
| `social-media-security` | `17-Social-Media-Platform-Security.md` | industry | social_media_security |
| `cms-security` | `18-Content-Management-System-Security.md` | industry | cms_security |
| `lms-security` | `19-Learning-Management-System-Security.md` | industry | lms_security |
| `hr-system-security` | `20-Human-Resources-System-Security.md` | industry | hr_system_security |
| `supply-chain-security` | `21-Supply-Chain-Management-Security.md` | industry | supply_chain_management_security |
| `manufacturing-security` | `22-Manufacturing-Control-System-Security.md` | ics | manufacturing_control_security |
| `smart-building-security` | `23-Smart-Building-Automation.md` | iot | smart_building_automation |
| `connected-vehicle-security` | `24-Connected-Vehicle-Security.md` | iot | connected_vehicle_security |
| `autonomous-system-security` | `25-Autonomous-System-Security.md` | ics | autonomous_system_security |
| `ics-security` | `26-Industrial-Control-System-Security.md` | ics | ics_security |
| `medical-device-security` | `27-Medical-Device-Security.md` | iot | medical_device_security |
| `wearable-security` | `28-Wearable-Technology-Security.md` | iot | wearable_technology_security |
| `smart-home-security` | `29-Smart-Home-Device-Security.md` | iot | smart_home_device_security |
| `embedded-security` | `30-Embedded-System-Security.md` | iot | embedded_system_security |
| `rtos-security` | `31-Real-Time-Operating-System-Security.md` | iot | rtos_security |
| `firmware-security` | `32-Firmware-Security-Analysis.md` | iot | firmware_security_analysis |
| `network-device-security` | `33-Network-Device-Security.md` | network | network_device_security |
| `telecom-security` | `34-Telecommunication-System-Security.md` | telecom | telecommunication_security |
| `satellite-security` | `35-Satellite-Communication-Security.md` | telecom | satellite_communication_security |
| `atc-security` | `36-Air-Traffic-Control-System-Security.md` | critical | air_traffic_control_security |
| `power-grid-security` | `37-Power-Grid-Security.md` | critical | power_grid_security |
| `water-treatment-security` | `38-Water-Treatment-Facility-Security.md` | critical | water_treatment_security |
| `transportation-security` | `39-Transportation-System-Security.md` | critical | transportation_system_security |
| `energy-mgmt-security` | `40-Energy-Management-System-Security.md` | critical | energy_management_security |
| `research-inst-security` | `41-Research-Institution-Security.md` | industry | research_institution_security |
| `nonprofit-security` | `42-Non-Profit-Organization-Security.md` | industry | nonprofit_security |
| `startup-security` | `43-Startup-Company-Security.md` | industry | startup_company_security |
| `enterprise-security` | `44-Enterprise-Corporate-Security.md` | industry | enterprise_corporate_security |
| `fortune500-security` | `45-Fortune-500-Company-Security.md` | industry | fortune500_security |
| `opensource-security` | `46-Open-Source-Project-Security.md` | industry | open_source_project_security |
| `academic-security` | `47-Academic-Research-Security.md` | industry | academic_research_security |
| `intl-org-security` | `48-International-Organization-Security.md` | industry | international_organization_security |
| `dev-country-infra` | `49-Developing-Country-Infrastructure.md` | critical | developing_country_infrastructure |
| `global-scale-security` | `50-Global-Scale-System-Security.md` | critical | global_scale_system_security |

---

## Tool Registration Schema

```yaml
specialized_registration:
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

### IoT Device Security

```python
registry.register(
    name="iot-device-security",
    tool_class=IoTDeviceSecurityTool,
    config={
        "firmware_analysis": True,
        "protocol_analysis": True,
        "hardware_interfaces": True,
        "timeout": 600
    },
    metadata={
        "category": "iot",
        "capabilities": ["iot_device_security", "firmware_analysis", "protocol_analysis"],
        "description": "Comprehensive IoT device security assessment",
        "tags": ["iot", "firmware", "embedded", "protocol"],
        "source_file": "01-IoT-Device-Security.md"
    }
)
```

### Mobile Application Testing

```python
registry.register(
    name="mobile-app-testing",
    tool_class=MobileAppTestingTool,
    config={
        "platforms": ["android", "ios"],
        "static_analysis": True,
        "dynamic_analysis": True,
        "api_testing": True,
        "timeout": 600
    },
    metadata={
        "category": "mobile",
        "capabilities": ["mobile_app_testing", "static_analysis", "dynamic_analysis", "api_testing"],
        "description": "Mobile application security testing across platforms",
        "tags": ["mobile", "android", "ios", "appsec"],
        "source_file": "02-Mobile-Application-Testing.md"
    }
)
```

### Cloud Infrastructure Security

```python
registry.register(
    name="cloud-infra-security",
    tool_class=CloudInfraSecurityTool,
    config={
        "providers": ["aws", "gcp", "azure"],
        "iam_audit": True,
        "storage_audit": True,
        "network_audit": True,
        "timeout": 600
    },
    metadata={
        "category": "cloud",
        "capabilities": ["cloud_infrastructure_security", "iam_audit", "storage_audit", "network_audit"],
        "description": "Cloud infrastructure security assessment across providers",
        "tags": ["cloud", "aws", "gcp", "azure", "iam"],
        "source_file": "03-Cloud-Infrastructure-Security.md"
    }
)
```

### Kubernetes Security

```python
registry.register(
    name="kubernetes-security",
    tool_class=KubernetesSecurityTool,
    config={
        "rbac_audit": True,
        "pod_security": True,
        "network_policy": True,
        "secret_management": True,
        "timeout": 300
    },
    metadata={
        "category": "container",
        "capabilities": ["kubernetes_security", "rbac_audit", "pod_security", "network_policy"],
        "description": "Kubernetes cluster security assessment",
        "tags": ["kubernetes", "container", "rbac", "pod-security"],
        "source_file": "05-Kubernetes-Cluster-Security.md"
    }
)
```

### Blockchain Smart Contract Security

```python
registry.register(
    name="smart-contract-security",
    tool_class=SmartContractSecurityTool,
    config={
        "static_analysis": True,
        "formal_verification": True,
        "exploit_generation": True,
        "timeout": 300
    },
    metadata={
        "category": "blockchain",
        "capabilities": ["smart_contract_security", "static_analysis", "formal_verification", "exploit_generation"],
        "description": "Blockchain smart contract security audit",
        "tags": ["blockchain", "smart-contract", "solidity", "web3"],
        "source_file": "06-Blockchain-Smart-Contracts.md"
    }
)
```

### DeFi Protocol Security

```python
registry.register(
    name="defi-security",
    tool_class=DeFiSecurityTool,
    config={
        "flash_loan_analysis": True,
        "oracle_manipulation": True,
        "reentrancy_detection": True,
        "timeout": 300
    },
    metadata={
        "category": "blockchain",
        "capabilities": ["defi_protocol_security", "flash_loan_analysis", "oracle_manipulation"],
        "description": "DeFi protocol security assessment",
        "tags": ["defi", "blockchain", "flash-loan", "oracle"],
        "source_file": "07-DeFi-Protocol-Security.md"
    }
)
```

### Industrial Control System Security

```python
registry.register(
    name="ics-security",
    tool_class=ICSSecurityTool,
    config={
        "protocols": ["modbus", "bacnet", "opc", "dnp3"],
        "scada_analysis": True,
        "plc_analysis": True,
        "timeout": 600
    },
    metadata={
        "category": "ics",
        "capabilities": ["ics_security", "scada_analysis", "plc_analysis", "protocol_analysis"],
        "description": "Industrial control system security assessment",
        "tags": ["ics", "scada", "plc", "industrial", "critical-infrastructure"],
        "source_file": "26-Industrial-Control-System-Security.md"
    }
)
```

### Medical Device Security

```python
registry.register(
    name="medical-device-security",
    tool_class=MedicalDeviceSecurityTool,
    config={
        "dicom_analysis": True,
        "hl7_analysis": True,
        "firmware_extraction": True,
        "timeout": 600
    },
    metadata={
        "category": "iot",
        "capabilities": ["medical_device_security", "dicom_analysis", "hl7_analysis", "firmware_extraction"],
        "description": "Medical device security assessment",
        "tags": ["medical", "healthcare", "dicom", "hl7", "iot"],
        "source_file": "27-Medical-Device-Security.md"
    }
)
```

### Power Grid Security

```python
registry.register(
    name="power-grid-security",
    tool_class=PowerGridSecurityTool,
    config={
        "scada_analysis": True,
        "grid_protocol_analysis": True,
        "substation_testing": True,
        "timeout": 600
    },
    metadata={
        "category": "critical",
        "capabilities": ["power_grid_security", "scada_analysis", "grid_protocol_analysis"],
        "description": "Power grid infrastructure security assessment",
        "tags": ["power-grid", "critical-infrastructure", "scada", "energy"],
        "source_file": "37-Power-Grid-Security.md"
    }
)
```

### Enterprise Corporate Security

```python
registry.register(
    name="enterprise-security",
    tool_class=EnterpriseSecurityTool,
    config={
        "active_directory_audit": True,
        "exchange_audit": True,
        "sharepoint_audit": True,
        "m365_audit": True,
        "timeout": 600
    },
    metadata={
        "category": "industry",
        "capabilities": ["enterprise_corporate_security", "active_directory_audit", "m365_audit"],
        "description": "Enterprise corporate environment security assessment",
        "tags": ["enterprise", "active-directory", "m365", "exchange", "sharepoint"],
        "source_file": "44-Enterprise-Corporate-Security.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_specialized_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> SpecializedRegistration:
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = SpecializedRegistration(
        id=generate_id(), name=name,
        version=metadata.get("version", "1.0.0"),
        category=metadata.get("category", "specialized"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        capabilities=metadata.get("capabilities", []),
        config=config or {}, metadata=metadata or {},
        registered_at=datetime.utcnow(), status="active"
    )
    self._tools[name] = registration
    self._index_category(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "specialized-targets"})
    return registration

def unregister_specialized_tool(self, name: str) -> bool:
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[SpecializedRegistration]:
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_iot_tools(self) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if t.category == "iot" and t.status == "active"]

def discover_blockchain_tools(self) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if t.category == "blockchain" and t.status == "active"]

def discover_ics_tools(self) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if t.category == "ics" and t.status == "active"]

def discover_critical_infrastructure_tools(self) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if t.category == "critical" and t.status == "active"]

def discover_industry_tools(self) -> list[SpecializedRegistration]:
    return [t for t in self._tools.values() if t.category == "industry" and t.status == "active"]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[SpecializedRegistration]:
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}

def list_by_category_group(self) -> dict[str, list[str]]:
    """Group tools by broader category groups."""
    groups = {
        "embedded_iot": [],
        "cloud_container": [],
        "blockchain_web3": [],
        "critical_infrastructure": [],
        "enterprise_industry": [],
        "telecom_network": []
    }
    for t in self._tools.values():
        if t.category in ("iot",):
            groups["embedded_iot"].append(t.name)
        elif t.category in ("cloud", "container"):
            groups["cloud_container"].append(t.name)
        elif t.category in ("blockchain",):
            groups["blockchain_web3"].append(t.name)
        elif t.category in ("ics", "critical"):
            groups["critical_infrastructure"].append(t.name)
        elif t.category in ("industry", "finance"):
            groups["enterprise_industry"].append(t.name)
        elif t.category in ("telecom", "network"):
            groups["telecom_network"].append(t.name)
    return {k: sorted(v) for k, v in groups.items() if v}
```

---

## Tool Metadata

```yaml
specialized_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  target_platforms: list[string]
  regulatory_compliance: list[string]  # HIPAA, PCI-DSS, NERC-CIP, etc.
  risk_level: string                    # low | medium | high | critical
  physical_access_required: bool
  specialized_hardware: list[string]
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class SpecializedVersionManager:
    def check_compatibility(self, name: str, min_version: str) -> bool:
        tool = self._tools.get(name)
        return tool and semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str) -> SpecializedRegistration:
        tool = self._tools[name]
        tool.version = new_version
        return tool
```

---

## Tool Dependencies

```python
class SpecializedDependencyManager:
    def resolve_dependencies(self, name: str) -> list[str]:
        tool = self._tools[name]
        return [d["name"] for d in tool.metadata.get("dependencies", {}).get("tool_dependencies", [])]

    def check_hardware_requirements(self, name: str) -> dict[str, bool]:
        tool = self._tools[name]
        results = {}
        for hw in tool.metadata.get("specialized_hardware", []):
            results[hw] = False  # Placeholder — would check actual hardware
        return results

    def get_regulatory_requirements(self, name: str) -> list[str]:
        tool = self._tools[name]
        return tool.metadata.get("regulatory_compliance", [])
```

---

## Full Domain File References

| # | File | Registered Tool |
|---|---|---|
| 1 | `01-IoT-Device-Security.md` | iot-device-security |
| 2 | `02-Mobile-Application-Testing.md` | mobile-app-testing |
| 3 | `03-Cloud-Infrastructure-Security.md` | cloud-infra-security |
| 4 | `04-Container-Security.md` | container-security |
| 5 | `05-Kubernetes-Cluster-Security.md` | kubernetes-security |
| 6 | `06-Blockchain-Smart-Contracts.md` | smart-contract-security |
| 7 | `07-DeFi-Protocol-Security.md` | defi-security |
| 8 | `08-NFT-Marketplace-Security.md` | nft-marketplace-security |
| 9 | `09-Web3-Application-Security.md` | web3-app-security |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | crypto-exchange-security |
| 11 | `11-Traditional-Finance-API-Security.md` | tradfi-api-security |
| 12 | `12-Healthcare-System-Security.md` | healthcare-security |
| 13 | `13-Financial-Institution-Security.md` | financial-inst-security |
| 14 | `14-Government-System-Security.md` | government-security |
| 15 | `15-Education-Platform-Security.md` | education-security |
| 16 | `16-E-commerce-Platform-Security.md` | ecommerce-security |
| 17 | `17-Social-Media-Platform-Security.md` | social-media-security |
| 18 | `18-Content-Management-System-Security.md` | cms-security |
| 19 | `19-Learning-Management-System-Security.md` | lms-security |
| 20 | `20-Human-Resources-System-Security.md` | hr-system-security |
| 21 | `21-Supply-Chain-Management-Security.md` | supply-chain-security |
| 22 | `22-Manufacturing-Control-System-Security.md` | manufacturing-security |
| 23 | `23-Smart-Building-Automation.md` | smart-building-security |
| 24 | `24-Connected-Vehicle-Security.md` | connected-vehicle-security |
| 25 | `25-Autonomous-System-Security.md` | autonomous-system-security |
| 26 | `26-Industrial-Control-System-Security.md` | ics-security |
| 27 | `27-Medical-Device-Security.md` | medical-device-security |
| 28 | `28-Wearable-Technology-Security.md` | wearable-security |
| 29 | `29-Smart-Home-Device-Security.md` | smart-home-security |
| 30 | `30-Embedded-System-Security.md` | embedded-security |
| 31 | `31-Real-Time-Operating-System-Security.md` | rtos-security |
| 32 | `32-Firmware-Security-Analysis.md` | firmware-security |
| 33 | `33-Network-Device-Security.md` | network-device-security |
| 34 | `34-Telecommunication-System-Security.md` | telecom-security |
| 35 | `35-Satellite-Communication-Security.md` | satellite-security |
| 36 | `36-Air-Traffic-Control-System-Security.md` | atc-security |
| 37 | `37-Power-Grid-Security.md` | power-grid-security |
| 38 | `38-Water-Treatment-Facility-Security.md` | water-treatment-security |
| 39 | `39-Transportation-System-Security.md` | transportation-security |
| 40 | `40-Energy-Management-System-Security.md` | energy-mgmt-security |
| 41 | `41-Research-Institution-Security.md` | research-inst-security |
| 42 | `42-Non-Profit-Organization-Security.md` | nonprofit-security |
| 43 | `43-Startup-Company-Security.md` | startup-security |
| 44 | `44-Enterprise-Corporate-Security.md` | enterprise-security |
| 45 | `45-Fortune-500-Company-Security.md` | fortune500-security |
| 46 | `46-Open-Source-Project-Security.md` | opensource-security |
| 47 | `47-Academic-Research-Security.md` | academic-security |
| 48 | `48-International-Organization-Security.md` | intl-org-security |
| 49 | `49-Developing-Country-Infrastructure.md` | dev-country-infra |
| 50 | `50-Global-Scale-System-Security.md` | global-scale-security |
| 51 | `README.md` | (documentation) |

---

## Categories Index

| Category | Count | Tools |
|---|---|---|
| `iot` | 10 | iot-device-security, smart-building-security, connected-vehicle-security, medical-device-security, wearable-security, smart-home-security, embedded-security, rtos-security, firmware-security |
| `mobile` | 1 | mobile-app-testing |
| `cloud` | 1 | cloud-infra-security |
| `container` | 2 | container-security, kubernetes-security |
| `blockchain` | 5 | smart-contract-security, defi-security, nft-marketplace-security, web3-app-security, crypto-exchange-security |
| `finance` | 1 | tradfi-api-security |
| `ics` | 4 | manufacturing-security, autonomous-system-security, ics-security |
| `critical` | 5 | atc-security, power-grid-security, water-treatment-security, transportation-security, energy-mgmt-security, dev-country-infra, global-scale-security |
| `telecom` | 2 | telecom-security, satellite-security |
| `network` | 1 | network-device-security |
| `industry` | 14 | healthcare-security, financial-inst-security, government-security, education-security, ecommerce-security, social-media-security, cms-security, lms-security, hr-system-security, supply-chain-security, research-inst-security, nonprofit-security, startup-security, enterprise-security, fortune500-security, opensource-security, academic-security, intl-org-security |

---

## Regulatory Compliance Map

| Tool | Compliance Frameworks |
|---|---|
| `healthcare-security` | HIPAA, HITECH, FDA 21 CFR Part 11 |
| `financial-inst-security` | PCI-DSS, SOX, GLBA |
| `power-grid-security` | NERC-CIP, CISA |
| `medical-device-security` | FDA, IEC 62304, HIPAA |
| `government-security` | FISMA, FedRAMP, NIST 800-53 |
| `enterprise-security` | SOC2, ISO 27001, GDPR |
| `cloud-infra-security` | CSA CCM, SOC2, ISO 27017 |
| `ecommerce-security` | PCI-DSS, GDPR, CCPA |
| `education-security` | FERPA, COPPA |
| `intl-org-security` | ISO 27001, GDPR, local regulations |

---

*Part of the Brain tools subsystem — Specialized Targets Domain Registry.*
