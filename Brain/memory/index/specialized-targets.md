# Memory Index: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

The memory index for specialized targets enables fast retrieval of category-specific methodologies, tool configurations, compliance mappings, and historical findings across 50 target types. This index is essential for quickly loading the right testing approach when a new target is categorized.

The index maps each target category to its methodology, tools, protocols, attack surface, and compliance requirements. When a target is identified as "IoT device," the index instantly provides the relevant testing framework from the 50 specialized target files.

## Index Schema

```yaml
# Category Index Entry
category_entry:
  category_id: "cat_{name}"
  filename: "01-IoT-Device-Security.md"
  title: "IoT Device Security"
  subcategories: ["smart_home", "industrial", "medical", "wearable"]
  tools: ["binwalk", "firmware-mod-kit", "jtag", "uart"]
  protocols: ["mqtt", "zigbee", "ble", "coap"]
  attack_surface: ["hardware", "firmware", "network", "cloud", "mobile_app"]
  compliance: []
  difficulty: "advanced"
  estimated_duration: "4-8 hours"

# Finding Index Entry
finding_entry:
  finding_id: "find_{uuid}"
  category: "iot"
  vuln_type: "hardcoded_credentials"
  severity: "critical"
  target: "smart_camera_01"
  methodology_used: "method_01"
  tools_used: ["binwalk", "strings"]
  discovered_at: "2025-01-15"
  compliance_impact: []
```

## Query API

```python
def find_methodology(index, category):
    """Find testing methodology for a target category."""
    return index.query(category_index, category)

def find_by_category(index, category):
    """Find all findings for a specific category."""
    return index.query(finding_index, category)

def find_by_compliance(index, framework):
    """Find findings relevant to a compliance framework."""
    return index.query(compliance_index, framework)

def find_by_tool(index, tool_name):
    """Find categories that use a specific tool."""
    return index.query(tool_index, tool_name)
```

## Domain File References

All 50 files indexed by category:

**IoT/Embedded (01, 23-32):** IoT Device, Smart Building, Connected Vehicle, Autonomous System, ICS, Medical Device, Wearable, Smart Home, Embedded, RTOS, Firmware.

**Mobile (02):** Mobile Application Testing.

**Cloud (03-05):** Cloud Infrastructure, Container, Kubernetes.

**Blockchain (06-10):** Smart Contracts, DeFi, NFT, Web3, Crypto Exchange.

**Finance (11, 13):** Traditional Finance API, Financial Institution.

**Healthcare (12, 27):** Healthcare System, Medical Device.

**Enterprise (14, 44-45):** Government, Enterprise Corporate, Fortune 500.

**Education (15, 19):** Education Platform, LMS.

**E-commerce (16-17):** E-commerce, Social Media.

**CMS (18):** Content Management System.

**Industrial (22, 26, 36-40):** Manufacturing, ICS, Air Traffic, Power Grid, Water Treatment, Transportation, Energy Management.

**Emerging (33-35):** Network Device, Telecom, Satellite.

**Institutions (41-43, 46-50):** Research, Non-Profit, Startup, Open Source, Academic, International, Developing Country, Global Scale.

## Integration

- **Working memory** loads category methodology during target assessment
- **Long-term storage** persists category-specific findings and tool configs
- **Consolidation** merges cross-category insights and updates tool effectiveness
