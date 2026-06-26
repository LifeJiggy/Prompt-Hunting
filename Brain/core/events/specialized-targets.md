# Events: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Event Definitions

Events for target-specific security testing across 50 specialized domains — IoT, mobile, cloud, blockchain, healthcare, ICS, and enterprise environments.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `target.category.detected` | `{target_id, category, confidence}` | Target type identified |
| `target.methodology.loaded` | `{target_id, methodology_id, tools[]}` | Category-specific method loaded |
| `target.category.test.started` | `{target_id, category, test_type}` | Category testing began |
| `target.category.test.completed` | `{target_id, category, findings}` | Category testing finished |
| `target.compliance.mapped` | `{target_id, framework, requirements[]}` | Regulatory requirements mapped |
| `target.specialized.vuln.found` | `{vuln_id, category, technique}` | Category-specific vuln found |
| `target.tool.deployed` | `{tool_name, target_id, category}` | Specialized tool invoked |
| `target.category.expertise.applied` | `{target_id, expertise_area}` | Domain expert knowledge applied |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `recon.asset.discovered` | Reconnaissance | Classify target type |
| `automation.pipeline.created` | Automation | Select category-specific tools |

## Category Mapping

Events are categorized across 50 target types:
- **IoT/Embedded (01, 23-32):** Hardware, firmware, RTOS testing events
- **Mobile (02):** iOS/Android application testing events
- **Cloud (03-05):** AWS/Azure/GCP and container security events
- **Blockchain (06-10):** Smart contract and DeFi protocol events
- **Finance (11, 13):** Banking API and financial system events
- **Healthcare (12, 27):** Medical device and EHR system events
- **Enterprise (14, 44-45):** Corporate infrastructure events
- **Education (15, 19):** LMS and academic platform events
- **E-commerce (16-17):** Online store and social platform events
- **Industrial (22, 26, 36-40):** ICS, SCADA, and infrastructure events
- **Emerging Tech (33-35):** Telecom, satellite, and network events
- **Institutions (41-43, 46-50):** Research, nonprofit, and global org events

## Event Flow

```
recon.asset.discovered
        │
        ▼
target.category.detected
        │
        ▼
target.methodology.loaded
        │
        ▼
target.tool.deployed
        │
        ▼
target.category.test.started
        │
        ▼
target.specialized.vuln.found
        │
        ▼
target.compliance.mapped
        │
        ▼
target.category.test.completed
```
