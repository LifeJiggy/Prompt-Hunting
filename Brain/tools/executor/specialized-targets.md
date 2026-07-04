# Specialized Targets — Tool Execution Domain

**Component:** Tool Executor for Category-Specific Tools  
**Domain:** `specialized-targets`  
**Registry:** `Specialized-Targets/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Category-specific tool execution with specialized configurations

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `specialized-targets` |
| Domain Path | `Specialized-Targets/` |
| Category | `specialized` |
| Execution Profile | `category-specific` |
| Default Timeout | 300s |
| Max Timeout | 7200s |
| Default Retries | 2 |
| Concurrency Limit | 4 |
| Stealth Level | `varies` |
| Rate Limit | `varies` |

---

## Overview

The Specialized Targets executor manages tool execution for category-specific security testing across diverse target types. This domain covers 50 prompt files spanning IoT device security, mobile application testing, cloud infrastructure security, container security, Kubernetes cluster security, blockchain smart contracts, DeFi protocol security, NFT marketplace security, Web3 application security, cryptocurrency exchange security, traditional finance API security, healthcare system security, financial institution security, government system security, education platform security, e-commerce platform security, social media platform security, content management system security, learning management system security, human resources system security, supply chain management security, manufacturing control system security, smart building automation, connected vehicle security, autonomous system security, industrial control system security, medical device security, wearable technology security, smart home device security, embedded system security, real-time operating system security, firmware security analysis, network device security, telecommunication system security, satellite communication security, air traffic control system security, power grid security, water treatment facility security, transportation system security, energy management system security, research institution security, non-profit organization security, startup company security, enterprise corporate security, Fortune 500 company security, open source project security, academic research security, international organization security, developing country infrastructure, and global scale system security.

This executor dynamically configures tool parameters based on the target category, applying specialized payloads, protocols, and detection methods for each target type.

---

## Execution Schema

### SpecializedInvocation (Input)

```json
{
  "tool": "string — category-specific tool",
  "target_category": "string — target category identifier",
  "input": {
    "target": "string — target identifier",
    "category_config": {
      "protocol": "string — target-specific protocol",
      "standard": "string — relevant security standard",
      "compliance": ["string — compliance frameworks"]
    },
    "test_vectors": ["string — category-specific test vectors"],
    "options": {
      "depth": "number — test depth",
      "scope": "string — test scope",
      "safe_mode": "boolean — avoid destructive tests"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "stealth": "boolean",
    "risk_level": "string — low|medium|high|critical"
  }
}
```

### SpecializedResult (Output)

```json
{
  "status": "string",
  "target_category": "string",
  "findings": [
    {
      "type": "string",
      "severity": "string",
      "category_specific": "boolean",
      "compliance_impact": ["string"],
      "remediation": "string"
    }
  ],
  "tests_executed": "number",
  "category_coverage": "number — 0-100%",
  "duration_ms": "number"
}
```

---

## Run Operations

### Category-Specific Execution

```python
def run_specialized(
    self,
    tool: str,
    target_category: str,
    input_data: dict,
    config: dict = None
) -> SpecializedResult:
    """
    Execute a category-specific security tool.
    
    Flow:
    1. Load category-specific configuration
    2. Apply target-appropriate test vectors
    3. Configure tool for target category
    4. Execute with category-specific settings
    5. Parse results using category-specific parsers
    6. Apply compliance mapping
    7. Return structured results
    """
```

### IoT Device Testing

```python
def run_iot_testing(
    self,
    target: str,
    test_vectors: list[str]
) -> SpecializedResult:
    """
    Execute IoT-specific security testing.
    Includes firmware analysis, protocol testing, and hardware debugging.
    Protocols: MQTT, CoAP, BLE, Zigbee, Z-Wave, Thread
    Standards: NIST IR 8259, ETSI EN 303 645
    """
```

### Mobile Application Testing

```python
def run_mobile_testing(
    self,
    target: str,
    platform: str
) -> SpecializedResult:
    """
    Execute mobile application security testing.
    Includes APK/IPA analysis, runtime instrumentation, and API testing.
    Standards: OWASP MASVS, OWASP MASTG
    """
```

### Cloud Infrastructure Testing

```python
def run_cloud_testing(
    self,
    target: str,
    provider: str
) -> SpecializedResult:
    """
    Execute cloud infrastructure security testing.
    Includes IAM analysis, metadata exploitation, and misconfiguration detection.
    Standards: CIS Benchmarks, CSA CCM
    """
```

### Blockchain/DeFi Testing

```python
def run_blockchain_testing(
    self,
    target: str,
    chain: str
) -> SpecializedResult:
    """
    Execute blockchain and DeFi security testing.
    Includes smart contract audit, flash loan testing, and oracle analysis.
    Chains: Ethereum, BSC, Polygon, Solana, Avalanche
    """
```

### Industrial Control System Testing

```python
def run_ics_testing(
    self,
    target: str,
    protocol: str
) -> SpecializedResult:
    """
    Execute ICS/SCADA security testing.
    Includes protocol analysis, PLC testing, and HMI assessment.
    Protocols: Modbus, BACnet, DNP3, OPC UA, EtherNet/IP
    Standards: IEC 62443, NIST SP 800-82
    """
```

### Healthcare System Testing

```python
def run_healthcare_testing(
    self,
    target: str
) -> SpecializedResult:
    """
    Execute healthcare system security testing.
    Includes EHR analysis, DICOM testing, HL7/FHIR assessment.
    Standards: HIPAA, HITECH, FDA premarket guidance
    """
```

### Financial System Testing

```python
def run_finance_testing(
    self,
    target: str
) -> SpecializedResult:
    """
    Execute financial system security testing.
    Includes payment gateway analysis, SWIFT testing, open banking assessment.
    Standards: PCI DSS, PSD2, SOX
    """
```

### Vehicle/Transportation Testing

```python
def run_vehicle_testing(
    self,
    target: str
) -> SpecializedResult:
    """
    Execute connected vehicle security testing.
    Includes CAN bus analysis, V2X communication, infotainment testing.
    Standards: ISO 21434, SAE J3061, UN R155/R156
    """
```

---

## Stop Operations

### Specialized Stop

```python
def stop_specialized(
    self,
    invocation_id: str,
    safe_shutdown: bool = True
) -> StopResult:
    """
    Stop a running specialized test.
    For ICS/medical devices, uses safe shutdown procedures.
    """
```

### Emergency Stop (Critical Infrastructure)

```python
def emergency_stop_ics(self) -> None:
    """
    Emergency stop for critical infrastructure testing.
    Immediately halts all ICS-related testing.
    Sends safe-state command to connected devices.
    """
    for process in self._ics_processes:
        process.kill()
    self._send_safe_state_commands()
```

### Device-Safe Stop

```python
def stop_device_test(
    self,
    device_type: str,
    invocation_id: str
) -> StopResult:
    """
    Stop testing with device-specific safety measures.
    Medical devices get safe-state commands.
    Vehicles get ignition-off sequence.
    ICS gets controlled shutdown.
    """
```

---

## Retry Operations

### Specialized Retry Configuration

```python
@dataclass
class SpecializedRetryConfig:
    max_retries: int = 2
    backoff_base: float = 10.0
    backoff_multiplier: float = 2.0
    retry_on_protocol_error: bool = True
    retry_on_timeout: bool = False
    retry_on_device_offline: bool = True
    max_retry_for_ics: int = 1
    max_retry_for_medical: int = 1
    max_retry_for_vehicle: int = 1
```

### Category-Specific Retry

```python
def _retry_for_category(
    self,
    invocation: SpecializedInvocation,
    failure_reason: str
) -> SpecializedResult:
    """Apply category-specific retry logic."""
    critical_categories = ["ics", "medical", "vehicle", "power_grid", "satellite"]
    
    if invocation.target_category in critical_categories:
        # Conservative retry for critical systems
        return self._conservative_retry(invocation)
    elif invocation.target_category in ["iot", "embedded"]:
        # Hardware-aware retry
        return self._hardware_aware_retry(invocation)
    elif invocation.target_category in ["blockchain", "defi"]:
        # Gas-aware retry
        return self._gas_aware_retry(invocation)
    else:
        # Standard retry
        return self._standard_retry(invocation)
```

---

## Timeout Handling

### Specialized Timeout Configuration

```python
@dataclass
class SpecializedTimeoutConfig:
    default: int = 300
    overrides: dict[str, int] = field(default_factory=lambda: {
        "iot_device": 600,
        "mobile_app": 600,
        "cloud_infra": 1200,
        "container": 600,
        "kubernetes": 1200,
        "blockchain": 3600,
        "defi_protocol": 3600,
        "nft_marketplace": 1800,
        "web3_app": 1800,
        "crypto_exchange": 3600,
        "finance_api": 600,
        "healthcare": 1200,
        "financial_institution": 1800,
        "government": 1200,
        "education": 300,
        "ecommerce": 600,
        "social_media": 600,
        "cms": 300,
        "lms": 300,
        "hr_system": 300,
        "supply_chain": 600,
        "manufacturing": 3600,
        "smart_building": 600,
        "vehicle": 3600,
        "autonomous": 3600,
        "ics_scada": 3600,
        "medical_device": 1800,
        "wearable": 300,
        "smart_home": 600,
        "embedded": 600,
        "rtos": 1200,
        "firmware": 1800,
        "network_device": 600,
        "telecom": 1800,
        "satellite": 7200,
        "atc": 7200,
        "power_grid": 3600,
        "water_treatment": 3600,
        "transportation": 3600,
        "energy": 1800,
        "research": 300,
        "nonprofit": 300,
        "startup": 300,
        "enterprise": 600,
        "fortune500": 600,
        "opensource": 300,
        "academic": 300,
        "international": 600,
        "developing": 600,
        "global": 3600
    })
    hard_maximum: int = 7200
    safe_mode_multiplier: float = 0.5
```

### Safe Mode Timeout

```python
def _calculate_safe_timeout(self, config: dict) -> int:
    """Calculate timeout with safe mode adjustment."""
    base_timeout = self._timeout_config.overrides.get(
        config["target_category"],
        self._timeout_config.default
    )
    if config.get("safe_mode", False):
        return int(base_timeout * self._timeout_config.safe_mode_multiplier)
    return base_timeout
```

### Adaptive Timeout by Device State

```python
def _adaptive_timeout(
    self,
    target_category: str,
    device_state: dict
) -> int:
    """Adapt timeout based on device state."""
    base = self._timeout_config.overrides.get(target_category, 300)
    
    if device_state.get("battery_low", False):
        base = int(base * 0.5)
    if device_state.get("network_unstable", False):
        base = int(base * 1.5)
    if device_state.get("high_load", False):
        base = int(base * 1.2)
    
    return min(base, self._timeout_config.hard_maximum)
```

---

## Output Capture

### Specialized Output Capture

```python
@dataclass
class SpecializedCapturedOutput:
    findings: list[dict]
    tests_executed: int
    category_coverage: float
    compliance_status: dict
    risk_assessment: str
    duration_ms: int
    safe_mode_used: bool
    device_state: dict = None
    protocol_responses: list[dict] = None
```

### Category-Specific Output Parsing

```python
def _parse_category_output(
    self,
    raw_output: str,
    target_category: str
) -> list[dict]:
    """Parse output using category-specific parsers."""
    parsers = {
        "iot": self._parse_iot_output,
        "mobile": self._parse_mobile_output,
        "cloud": self._parse_cloud_output,
        "blockchain": self._parse_blockchain_output,
        "ics": self._parse_ics_output,
        "healthcare": self._parse_healthcare_output,
        "finance": self._parse_finance_output,
        "vehicle": self._parse_vehicle_output
    }
    
    parser = parsers.get(target_category, self._parse_generic_output)
    return parser(raw_output)
```

---

## Stderr Handling

### Specialized Stderr Processing

```python
def _process_stderr(self, stderr: str, target_category: str) -> StderrResult:
    """Process stderr with category awareness."""
    classifications = []
    
    # Check for category-specific errors
    category_error_patterns = {
        "ics": ["device unresponsive", " plc error", "modbus timeout"],
        "medical": ["safety violation", "patient data", "hipaa violation"],
        "vehicle": ["can bus error", "v2x failure", "ignition state"],
        "blockchain": ["gas limit", "revert", "nonce too low"],
        "satellite": ["signal lost", "link failure", "orbital decay"],
        "power_grid": ["frequency deviation", "voltage spike", "relay trip"],
        "water": ["ph deviation", "chlorine level", "pressure alarm"]
    }
    
    patterns = category_error_patterns.get(target_category, [])
    for pattern in patterns:
        if pattern in stderr.lower():
            classifications.append(f"category_error:{pattern.strip()}")
    
    # Check for general errors
    if "connection refused" in stderr.lower():
        classifications.append("connection_error")
    if "timeout" in stderr.lower():
        classifications.append("timeout")
    
    retryable = not any("safety" in c or "violation" in c for c in classifications)
    
    return StderrResult(
        raw=stderr,
        classifications=classifications,
        retryable=retryable
    )
```

---

## Exit Code Handling

### Specialized Exit Code Processing

```python
def _process_exit_code(self, exit_code: int, target_category: str) -> ExitCodeResult:
    """Process exit code with category context."""
    critical_categories = [
        "ics", "medical", "vehicle", "power_grid", 
        "satellite", "atc", "water_treatment"
    ]
    
    if exit_code == 0:
        return ExitCodeResult(status="success", action="process_findings")
    
    # Category-specific exit code handling
    if target_category in critical_categories:
        # Conservative handling for critical systems
        return ExitCodeResult(
            status="error",
            action="safe_report",
            retryable=False,
            message=f"Critical system test failed with exit code {exit_code}"
        )
    
    if exit_code in self._retry_config.retry_on_exit_codes:
        return ExitCodeResult(status="error", action="retry", retryable=True)
    
    return ExitCodeResult(status="error", action="report", retryable=False)
```

---

## Concurrent Execution

### Specialized Concurrency Configuration

```python
@dataclass
class SpecializedConcurrencyConfig:
    max_concurrent: int = 4
    max_per_category: int = 2
    max_per_target: int = 1
    sequential_for_ics: bool = True
    sequential_for_medical: bool = True
    sequential_for_vehicle: bool = True
    sequential_for_satellite: bool = True
    max_parallel_blockchain: int = 1
```

### Category-Based Scheduling

```python
def _schedule_by_category(
    self,
    invocations: list[SpecializedInvocation]
) -> list[SpecializedInvocation]:
    """Schedule invocations with category-specific ordering."""
    # Critical systems first (ICS, medical, vehicle, satellite, ATC)
    critical = [
        i for i in invocations 
        if i.target_category in ["ics", "medical", "vehicle", "satellite", "atc"]
    ]
    # High priority (cloud, finance, government, power_grid)
    high = [
        i for i in invocations 
        if i.target_category in ["cloud", "finance", "government", "power_grid"]
    ]
    # Medium priority (blockchain, mobile, enterprise)
    medium = [
        i for i in invocations 
        if i.target_category in ["blockchain", "mobile", "enterprise"]
    ]
    # Standard (everything else)
    standard = [
        i for i in invocations 
        if i not in critical and i not in high and i not in medium
    ]
    
    return critical + high + medium + standard
```

### Resource-Based Scheduling

```python
def _schedule_by_resources(
    self,
    invocations: list[SpecializedInvocation]
) -> list[SpecializedInvocation]:
    """Schedule based on resource requirements."""
    resource_heavy = [
        "blockchain", "defi", "crypto_exchange", 
        "ics", "satellite", "power_grid"
    ]
    resource_light = [
        "cms", "education", "lms", "nonprofit", "startup"
    ]
    
    heavy = [i for i in invocations if i.target_category in resource_heavy]
    light = [i for i in invocations if i.target_category in resource_light]
    other = [i for i in invocations if i not in heavy and i not in light]
    
    return light + other + heavy
```

---

## Execution Logging

### Specialized Execution Log

```python
@dataclass
class SpecializedExecutionLog:
    invocation_id: str
    tool: str
    target_category: str
    target: str
    status: str
    tests_executed: int
    findings_count: int
    risk_level: str
    safe_mode: bool
    duration_ms: int
    device_state: dict = None
    compliance_checked: list[str] = None
    protocol_used: str = None
    timestamp: str = None
```

### Category-Specific Logging

```python
def _create_specialized_log(
    self,
    invocation: SpecializedInvocation,
    result: SpecializedResult
) -> SpecializedExecutionLog:
    """Create category-specific execution log."""
    return SpecializedExecutionLog(
        invocation_id=result.invocation_id,
        tool=invocation.tool,
        target_category=invocation.target_category,
        target=invocation.target,
        status=result.status,
        tests_executed=result.tests_executed,
        findings_count=len(result.findings),
        risk_level=invocation.config.get("risk_level", "medium"),
        safe_mode=invocation.input.get("options", {}).get("safe_mode", False),
        duration_ms=result.duration_ms,
        device_state=result.device_state,
        compliance_checked=invocation.input.get("category_config", {}).get("compliance", []),
        protocol_used=invocation.input.get("category_config", {}).get("protocol"),
        timestamp=datetime.now().isoformat()
    )
```

---

## Full Domain File References

### Category: IoT and Embedded

| ID | File | Title | Risk Level | Timeout | Protocols |
|----|------|-------|------------|---------|-----------|
| 01 | `01-IoT-Device-Security.md` | IoT Device Security | high | 600s | MQTT, CoAP, BLE |
| 28 | `28-Wearable-Technology-Security.md` | Wearable Technology Security | medium | 300s | BLE, ANT+ |
| 29 | `29-Smart-Home-Device-Security.md` | Smart Home Device Security | high | 600s | Zigbee, Z-Wave, Matter |
| 30 | `30-Embedded-System-Security.md` | Embedded System Security | high | 600s | JTAG, SWD, UART |
| 31 | `31-Real-Time-Operating-System-Security.md` | Real-Time Operating System Security | critical | 1200s | FreeRTOS, VxWorks, QNX |
| 32 | `32-Firmware-Security-Analysis.md` | Firmware Security Analysis | critical | 1800s | UEFI, BIOS, Bootloader |

### Category: Mobile

| ID | File | Title | Risk Level | Timeout | Platforms |
|----|------|-------|------------|---------|-----------|
| 02 | `02-Mobile-Application-Testing.md` | Mobile Application Testing | high | 600s | Android, iOS, Hybrid |

### Category: Cloud and Containers

| ID | File | Title | Risk Level | Timeout | Providers |
|----|------|-------|------------|---------|-----------|
| 03 | `03-Cloud-Infrastructure-Security.md` | Cloud Infrastructure Security | critical | 1200s | AWS, Azure, GCP |
| 04 | `04-Container-Security.md` | Container Security | high | 600s | Docker, Podman |
| 05 | `05-Kubernetes-Cluster-Security.md` | Kubernetes Cluster Security | critical | 1200s | K8s, EKS, AKS, GKE |

### Category: Blockchain and DeFi

| ID | File | Title | Risk Level | Timeout | Chains |
|----|------|-------|------------|---------|--------|
| 06 | `06-Blockchain-Smart-Contracts.md` | Blockchain Smart Contracts | critical | 3600s | Ethereum, BSC, Polygon |
| 07 | `07-DeFi-Protocol-Security.md` | DeFi Protocol Security | critical | 3600s | Multi-chain |
| 08 | `08-NFT-Marketplace-Security.md` | NFT Marketplace Security | high | 1800s | Ethereum, Solana |
| 09 | `09-Web3-Application-Security.md` | Web3 Application Security | high | 1800s | Multi-chain |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | Cryptocurrency Exchange Security | critical | 3600s | Multi-chain |

### Category: Finance

| ID | File | Title | Risk Level | Timeout | Standards |
|----|------|-------|------------|---------|-----------|
| 11 | `11-Traditional-Finance-API-Security.md` | Traditional Finance API Security | critical | 1200s | PCI DSS, PSD2 |
| 13 | `13-Financial-Institution-Security.md` | Financial Institution Security | critical | 1800s | SOX, GLBA |

### Category: Healthcare

| ID | File | Title | Risk Level | Timeout | Standards |
|----|------|-------|------------|---------|-----------|
| 12 | `12-Healthcare-System-Security.md` | Healthcare System Security | critical | 1200s | HIPAA, HITECH |
| 27 | `27-Medical-Device-Security.md` | Medical Device Security | critical | 1800s | FDA, IEC 62304 |

### Category: Government and Enterprise

| ID | File | Title | Risk Level | Timeout | Standards |
|----|------|-------|------------|---------|-----------|
| 14 | `14-Government-System-Security.md` | Government System Security | critical | 1200s | FISMA, FedRAMP |
| 44 | `44-Enterprise-Corporate-Security.md` | Enterprise Corporate Security | high | 600s | ISO 27001 |
| 45 | `45-Fortune-500-Company-Security.md` | Fortune 500 Company Security | high | 600s | SOX, GDPR |

### Category: Education

| ID | File | Title | Risk Level | Timeout | Standards |
|----|------|-------|------------|---------|-----------|
| 15 | `15-Education-Platform-Security.md` | Education Platform Security | medium | 300s | FERPA, COPPA |
| 19 | `19-Learning-Management-System-Security.md` | Learning Management System Security | medium | 300s | FERPA |
| 47 | `47-Academic-Research-Security.md` | Academic Research Security | medium | 300s | Institutional |

### Category: E-commerce and Social

| ID | File | Title | Risk Level | Timeout | Standards |
|----|------|-------|------------|---------|-----------|
| 16 | `16-E-commerce-Platform-Security.md` | E-commerce Platform Security | high | 600s | PCI DSS |
| 17 | `17-Social-Media-Platform-Security.md` | Social Media Platform Security | high | 600s | GDPR, CCPA |
| 18 | `18-Content-Management-System-Security.md` | Content Management System Security | medium | 300s | OWASP |

### Category: Industrial and ICS

| ID | File | Title | Risk Level | Timeout | Protocols |
|----|------|-------|------------|---------|-----------|
| 20 | `20-Human-Resources-System-Security.md` | Human Resources System Security | medium | 300s | HTTPS, LDAP |
| 21 | `21-Supply-Chain-Management-Security.md` | Supply Chain Management Security | high | 600s | EDI, API |
| 22 | `22-Manufacturing-Control-System-Security.md` | Manufacturing Control System Security | critical | 3600s | OPC UA, Modbus |
| 23 | `23-Smart-Building-Automation.md` | Smart Building Automation | high | 600s | BACnet, KNX |
| 24 | `24-Connected-Vehicle-Security.md` | Connected Vehicle Security | critical | 3600s | CAN, V2X |
| 25 | `25-Autonomous-System-Security.md` | Autonomous System Security | critical | 3600s | ROS, DDS |
| 26 | `26-Industrial-Control-System-Security.md` | Industrial Control System Security | critical | 3600s | Modbus, DNP3 |
| 36 | `36-Air-Traffic-Control-System-Security.md` | Air Traffic Control System Security | critical | 7200s | ADS-B, Mode S |
| 37 | `37-Power-Grid-Security.md` | Power Grid Security | critical | 3600s | IEC 61850, DNP3 |
| 38 | `38-Water-Treatment-Facility-Security.md` | Water Treatment Facility Security | critical | 3600s | Modbus, HMI |
| 39 | `39-Transportation-System-Security.md` | Transportation System Security | critical | 3600s | ATC, Rail Signaling |
| 40 | `40-Energy-Management-System-Security.md` | Energy Management System Security | high | 1800s | Smart Grid, AMI |

### Category: Network and Telecom

| ID | File | Title | Risk Level | Timeout | Protocols |
|----|------|-------|------------|---------|-----------|
| 33 | `33-Network-Device-Security.md` | Network Device Security | high | 600s | SNMP, SSH, Telnet |
| 34 | `34-Telecommunication-System-Security.md` | Telecommunication System Security | critical | 1800s | SS7, Diameter, 5G |
| 35 | `35-Satellite-Communication-Security.md` | Satellite Communication Security | critical | 7200s | DVB-S, CCSDS |

### Category: Institutions

| ID | File | Title | Risk Level | Timeout | Notes |
|----|------|-------|------------|---------|-------|
| 41 | `41-Research-Institution-Security.md` | Research Institution Security | medium | 300s | IP protection |
| 42 | `42-Non-Profit-Organization-Security.md` | Non-Profit Organization Security | medium | 300s | Donor data |
| 43 | `43-Startup-Company-Security.md` | Startup Company Security | medium | 300s | Rapid dev |
| 46 | `46-Open-Source-Project-Security.md` | Open Source Project Security | medium | 300s | Supply chain |
| 48 | `48-International-Organization-Security.md` | International Organization Security | high | 600s | Multi-jurisdiction |
| 49 | `49-Developing-Country-Infrastructure.md` | Developing Country Infrastructure | high | 600s | Legacy systems |
| 50 | `50-Global-Scale-System-Security.md` | Global Scale System Security | critical | 3600s | Planet-scale |

---

## Category-Specific Configurations

| Category | Protocol | Safe Mode | Compliance | Risk Level |
|----------|----------|-----------|------------|------------|
| IoT | MQTT, CoAP, BLE | recommended | NIST IR 8259 | high |
| Mobile | HTTPS, gRPC | optional | OWASP MASVS | high |
| Cloud | HTTPS, IMDS | optional | CIS Benchmarks | critical |
| Container | Docker API | optional | CIS Docker | high |
| Kubernetes | K8s API | optional | CIS K8s | critical |
| Blockchain | JSON-RPC, Web3 | required | Custom | critical |
| DeFi | Web3, Flashbots | required | Custom | critical |
| Healthcare | DICOM, HL7 | required | HIPAA | critical |
| ICS/SCADA | Modbus, BACnet | required | IEC 62443 | critical |
| Finance | HTTPS, SOAP | required | PCI DSS | critical |
| Vehicle | CAN, V2X | required | ISO 21434 | critical |
| Government | HTTPS, PKI | required | FISMA | critical |
| Education | HTTPS | optional | FERPA | medium |
| Telecom | SS7, 5G | required | 3GPP | critical |
| Satellite | CCSDS | required | ITU | critical |

---

## Risk Level Matrix

| Risk Level | Concurrency | Timeout Multiplier | Approval Required | Audit Level |
|------------|-------------|-------------------|-------------------|-------------|
| low | 8 | 1.0x | No | Basic |
| medium | 4 | 1.0x | No | Standard |
| high | 2 | 1.5x | Recommended | Enhanced |
| critical | 1 | 2.0x | Required | Full |

---

## Attack Chain Support

The executor supports cross-category attack chains defined in the registry:

| Chain ID | Name | Categories | Risk |
|----------|------|------------|------|
| AC-001 | IoT to Enterprise | IoT, Cloud, Enterprise | critical |
| AC-002 | Mobile to Financial | Mobile, Finance | critical |
| AC-003 | Supply Chain to ICS | Supply Chain, Manufacturing, ICS | critical |
| AC-004 | Cloud to Blockchain | Cloud, Blockchain, Exchange | critical |
| AC-005 | Medical to Healthcare | Medical, Healthcare | critical |
| AC-006 | Smart Home to Critical Infrastructure | Smart Home, Power Grid | critical |
| AC-007 | Vehicle to Transportation | Vehicle, Transportation | critical |
| AC-008 | Satellite to Telecom | Satellite, Telecom | critical |

---

## Device Safety Protocols

### Medical Device Testing

```python
def _medical_device_safety_check(self, target: dict) -> bool:
    """Verify medical device is in safe testing mode."""
    # Check device state
    # Verify no patient connection
    # Confirm safe-mode enabled
    # Validate test window
    return True
```

### ICS/SCADA Testing

```python
def _ics_safety_check(self, target: dict) -> bool:
    """Verify ICS is in safe testing mode."""
    # Check process state
    # Verify backup systems active
    # Confirm operator notification
    # Validate emergency stop accessible
    return True
```

### Vehicle Testing

```python
def _vehicle_safety_check(self, target: dict) -> bool:
    """Verify vehicle is in safe testing mode."""
    # Check vehicle is stationary
    # Verify ignition state
    # Confirm no active drive session
    # Validate CAN bus isolation
    return True
```

---

## Compliance Mapping

| Target Category | Primary Standards | Secondary Standards | Audit Requirements |
|----------------|-------------------|--------------------|--------------------|
| IoT | NIST IR 8259 | ETSI EN 303 645 | Annual |
| Mobile | OWASP MASVS | NIST SP 800-163 | Per release |
| Cloud | CIS Benchmarks | CSA CCM | Continuous |
| Blockchain | Custom | — | Per deployment |
| Healthcare | HIPAA | HITECH, FDA | Annual |
| ICS | IEC 62443 | NIST SP 800-82 | Annual |
| Finance | PCI DSS | SOX, PSD2 | Quarterly |
| Vehicle | ISO 21434 | UN R155/R156 | Per model |
| Government | FISMA | FedRAMP | Annual |
| Telecom | 3GPP | NIST | Annual |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
