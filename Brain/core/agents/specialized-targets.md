# Agent: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Agent Profile

This agent handles target-specific security testing across 50 specialized domains including IoT, mobile, cloud, blockchain, healthcare, industrial control systems, and enterprise environments. Each target type requires unique tooling, methodologies, and compliance considerations. The agent adapts its approach based on the specific target category.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `target_profiling` | Identify target category and applicable methodology |
| `category_adaptation` | Switch tooling and techniques per target type |
| `compliance_mapping` | Apply regulatory requirements (HIPAA, PCI, NIST) |
| `specialized_exploitation` | Execute category-specific attack techniques |
| `impact_contextualization` | Frame impact in domain-specific terms |

## Interface

```python
class SpecializedAgent(BaseAgent):
    name = "specialized-targets"
    capabilities = ["target_profiling", "category_adaptation", "compliance_mapping"]

    def think(self, context: AgentContext) -> Action:
        """Identify target category, load appropriate methodology."""

    def act(self, action: Action) -> ActionResult:
        """Execute category-specific testing with appropriate tools."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Contextualize findings within domain-specific risk framework."""
```

## Configuration

```yaml
agent:
  type: "specialized-targets"
  categories: 50
  compliance_mode: "adaptive"
  category_detection: "automatic"
  methodology_db: "./category_methodologies"
```

## Domain Files Reference

This agent manages all 50 specialized target guides in `Specialized-Targets/`:

**IoT and Embedded (01, 23-32):** `01-IoT-Device-Security.md` covers UART, JTAG, firmware extraction, MQTT, Zigbee, and BLE protocol testing. `23-Smart-Building-Automation.md` examines building management system and SCADA security. `24-Connected-Vehicle-Security.md` covers CAN bus, telematics, and V2X communication testing. `25-Autonomous-System-Security.md` analyzes self-driving and robotic system vulnerabilities. `26-Industrial-Control-System-Security.md` covers PLC, HMI, and DCS testing. `27-Medical-Device-Security.md` examines infusion pumps, patient monitors, and DICOM. `28-Wearable-Technology-Security.md` covers fitness trackers, smartwatches, and health sensors. `29-Smart-Home-Device-Security.md` analyzes routers, cameras, and voice assistants. `30-Embedded-System-Security.md` covers RTOS, firmware analysis, and hardware interfaces. `31-Real-Time-Operating-System-Security.md` examines FreeRTOS, Zephyr, and QNX vulnerabilities. `32-Firmware-Security-Analysis.md` covers extraction, reverse engineering, and update mechanism testing.

**Mobile (02):** `02-Mobile-Application-Testing.md` covers iOS and Android API testing, certificate pinning bypass, deep link exploitation, and local storage analysis.

**Cloud and Containers (03-05):** `03-Cloud-Infrastructure-Security.md` examines AWS, Azure, GCP IAM, storage, and metadata service attacks. `04-Container-Security.md` covers Docker daemon exposure, image vulnerabilities, and runtime escape. `05-Kubernetes-Cluster-Security.md` analyzes API server access, RBAC bypass, and pod escape techniques.

**Blockchain and DeFi (06-10):** `06-Blockchain-Smart-Contracts.md` covers reentrancy, overflow, and access control in Solidity. `07-DeFi-Protocol-Security.md` examines flash loan attacks and oracle manipulation. `08-NFT-Marketplace-Security.md` covers metadata manipulation and ownership bypass. `09-Web3-Application-Security.md` analyzes wallet injection and transaction manipulation. `10-Cryptocurrency-Exchange-Security.md` examines hot wallet security and API key management.

**Finance (11, 13):** `11-Traditional-Finance-API-Security.md` covers banking API testing, SWIFT, and payment processing. `13-Financial-Institution-Security.md` examines PCI-DSS compliance and financial system vulnerabilities.

**Healthcare (12, 27):** `12-Healthcare-System-Security.md` covers EHR systems, HL7/FHIR, and medical data privacy. `27-Medical-Device-Security.md` analyzes FDA-regulated device vulnerabilities.

**Government and Enterprise (14, 44-45):** `14-Government-System-Security.md` covers FISMA compliance and government network testing. `44-Enterprise-Corporate-Security.md` examines Active Directory, Exchange, and enterprise application security. `45-Fortune-500-Company-Security.md` covers large-scale corporate security assessments.

**Education (15, 19):** `15-Education-Platform-Security.md` covers LMS platforms and student data protection. `19-Learning-Management-System-Security.md` examines Canvas, Blackboard, and Moodle vulnerabilities.

**E-commerce and Social (16-17):** `16-E-commerce-Platform-Security.md` covers payment processing, cart manipulation, and inventory attacks. `17-Social-Media-Platform-Security.md` examines privacy settings, API abuse, and content injection.

**CMS (18):** `18-Content-Management-System-Security.md` covers WordPress, Drupal, Joomla plugin vulnerabilities and admin panel security.

**Industrial and ICS (22, 26, 36-40):** `22-Manufacturing-Control-System-Security.md` covers industrial IoT and manufacturing execution systems. `26-Industrial-Control-System-Security.md` examines Modbus, DNP3, and OPC protocols. `36-Air-Traffic-Control-System-Security.md` covers aviation system security. `37-Power-Grid-Security.md` examines SCADA and energy management. `38-Water-Treatment-Facility-Security.md` covers water system SCADA security. `39-Transportation-System-Security.md` analyzes railway and traffic management systems. `40-Energy-Management-System-Security.md` covers smart grid and renewable energy systems.

**Emerging Technology (33-35):** `33-Network-Device-Security.md` covers router, switch, and firewall testing. `34-Telecommunication-System-Security.md` examines 5G, IMS, and SS7 vulnerabilities. `35-Satellite-Communication-Security.md` covers SATCOM and ground station security.

**Institutions (41-43, 46-50):** `41-Research-Institution-Security.md` covers academic network and research data security. `42-Non-Profit-Organization-Security.md` examines donor data and limited-resource environments. `43-Startup-Company-Security.md` covers early-stage company security gaps. `46-Open-Source-Project-Security.md` examines OSS supply chain and repository security. `47-Academic-Research-Security.md` covers research data protection and lab network security. `48-International-Organization-Security.md` examines multinational security requirements. `49-Developing-Country-Infrastructure.md` covers infrastructure security in emerging markets. `50-Global-Scale-System-Security.md` analyzes worldwide distributed system security.

## Integration Points

- Loads target-specific methodologies from `memory/` persistent storage
- Invokes specialized tools via `tools/` executor
- Maps findings to compliance frameworks via `Bug-Bounty-Program-Strategy/`
- Provides domain context to `Report-Writing-Mastery/` for impact framing
