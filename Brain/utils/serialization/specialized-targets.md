# Specialized Targets Data Serialization

## Title and Metadata

```yaml
domain: specialized-targets
version: "2.1.0"
last_updated: "2026-06-26"
schema_version: "3.0"
classification: internal
description: >
  Data serialization layer for specialized target domain findings.
  Covers 50 distinct specialized target categories spanning IoT,
  mobile, cloud, Web3, critical infrastructure, enterprise, and
  emerging technology sectors.
serialization_library: custom_specialized_serializers
supported_formats: [json, yaml, messagepack, protobuf]
compression_algorithms: [gzip, brotli, zstd]
```

---

## Domain Mapping

| ID | Domain File | Domain Key | Category |
|----|-------------|------------|----------|
| 01 | 01-IoT-Device-Security.md | iot_device | IoT |
| 02 | 02-Mobile-Application-Testing.md | mobile_app | Mobile |
| 03 | 03-Cloud-Infrastructure-Security.md | cloud_infra | Cloud |
| 04 | 04-Container-Security.md | container | Cloud |
| 05 | 05-Kubernetes-Cluster-Security.md | kubernetes | Cloud |
| 06 | 06-Blockchain-Smart-Contracts.md | blockchain_sc | Web3 |
| 07 | 07-DeFi-Protocol-Security.md | defi_protocol | Web3 |
| 08 | 08-NFT-Marketplace-Security.md | nft_marketplace | Web3 |
| 09 | 09-Web3-Application-Security.md | web3_app | Web3 |
| 10 | 10-Cryptocurrency-Exchange-Security.md | crypto_exchange | Finance |
| 11 | 11-Traditional-Finance-API-Security.md | tradfi_api | Finance |
| 12 | 12-Healthcare-System-Security.md | healthcare | Healthcare |
| 13 | 13-Financial-Institution-Security.md | financial_inst | Finance |
| 14 | 14-Government-System-Security.md | government | Government |
| 15 | 15-Education-Platform-Security.md | education | Education |
| 16 | 16-Ecommerce-Platform-Security.md | ecommerce | Commerce |
| 17 | 17-Social-Media-Platform-Security.md | social_media | Social |
| 18 | 18-Content-Management-System-Security.md | cms | Content |
| 19 | 19-Learning-Management-System-Security.md | lms | Education |
| 20 | 20-Human-Resources-System-Security.md | hr_system | Enterprise |
| 21 | 21-Supply-Chain-Management-Security.md | supply_chain | Enterprise |
| 22 | 22-Manufacturing-Control-System-Security.md | manufacturing | Industrial |
| 23 | 23-Smart-Building-Automation.md | smart_building | IoT |
| 24 | 24-Connected-Vehicle-Security.md | connected_vehicle | Automotive |
| 25 | 25-Autonomous-System-Security.md | autonomous_system | Robotics |
| 26 | 26-Industrial-Control-System-Security.md | ics_scada | Industrial |
| 27 | 27-Medical-Device-Security.md | medical_device | Healthcare |
| 28 | 28-Wearable-Technology-Security.md | wearable | IoT |
| 29 | 29-Smart-Home-Device-Security.md | smart_home | IoT |
| 30 | 30-Embedded-System-Security.md | embedded_system | Hardware |
| 31 | 31-Real-Time-Operating-System-Security.md | rtos | Firmware |
| 32 | 32-Firmware-Security-Analysis.md | firmware_analysis | Firmware |
| 33 | 33-Network-Device-Security.md | network_device | Network |
| 34 | 34-Telecommunication-System-Security.md | telecom | Telecommunication |
| 35 | 35-Satellite-Communication-Security.md | satellite_comm | Space |
| 36 | 36-Air-Traffic-Control-System-Security.md | atc_system | Aviation |
| 37 | 37-Power-Grid-Security.md | power_grid | Critical Infrastructure |
| 38 | 38-Water-Treatment-Facility-Security.md | water_treatment | Critical Infrastructure |
| 39 | 39-Transportation-System-Security.md | transportation | Critical Infrastructure |
| 40 | 40-Energy-Management-System-Security.md | energy_management | Energy |
| 41 | 41-Research-Institution-Security.md | research_institution | Academic |
| 42 | 42-Non-Profit-Organization-Security.md | nonprofit | Non-Profit |
| 43 | 43-Startup-Company-Security.md | startup | Enterprise |
| 44 | 44-Enterprise-Corporate-Security.md | enterprise_corp | Enterprise |
| 45 | 45-Fortune-500-Company-Security.md | fortune500 | Enterprise |
| 46 | 46-Open-Source-Project-Security.md | oss_project | Open Source |
| 47 | 47-Academic-Research-Security.md | academic_research | Academic |
| 48 | 48-International-Organization-Security.md | international_org | International |
| 49 | 49-Developing-Country-Infrastructure.md | developing_infra | Global |
| 50 | 50-Global-Scale-System-Security.md | global_scale | Global |

---

## Overview

The specialized-targets serialization layer converts findings generated across 50 distinct specialized target domains into a unified, cross-domain data format. Each domain has unique attributes — IoT findings carry protocol-level metadata, Web3 findings carry chain and contract addresses, critical infrastructure findings carry regulatory compliance markers — yet all must serialize into a shared schema for pipeline aggregation, deduplication, and reporting.

The serialization layer solves three problems:

1. **Heterogeneous finding shapes** — Each domain defines its own finding attributes. The serializer normalizes these into a common base while preserving domain-specific extensions.
2. **Cross-domain correlation** — A supply chain attack (021) may span IoT firmware (032), cloud infrastructure (03), and embedded systems (030). Serialization must preserve linking metadata across domain boundaries.
3. **Format flexibility** — Downstream consumers (report generators, dashboards, API clients, archival systems) require different wire formats. The serializer supports JSON, YAML, MessagePack, and Protobuf with transparent conversion.

---

## Format Support

### JSON

```json
{
  "meta": {
    "schema_version": "3.0",
    "domain": "iot_device",
    "domain_id": "01",
    "format": "json",
    "timestamp": "2026-06-26T12:00:00Z",
    "batch_id": "b7f3a9c2"
  },
  "finding": {
    "id": "SF-01-2026-0001",
    "title": "Hardcoded MQTT credentials in IoT firmware",
    "severity": "critical",
    "cvss": 9.8,
    "domain": "iot_device",
    "category": "credential_exposure",
    "affected_component": "mqtt_broker_client",
    "description": "Firmware binary contains hardcoded MQTT broker credentials...",
    "domain_attributes": {
      "protocol": "MQTT",
      "firmware_version": "2.1.4",
      "device_model": "SensorX-300",
      "communication_layer": "application",
      "hardware_revision": "B"
    }
  },
  "evidence": {
    "artifacts": [],
    "screenshots": [],
    "pcap_references": [],
    "binary_samples": []
  },
  "remediation": {
    "priority": "immediate",
    "complexity": "medium",
    "estimated_effort_hours": 40,
    "recommended_fix": "Rotate credentials, implement secure boot"
  }
}
```

### YAML

```yaml
meta:
  schema_version: "3.0"
  domain: blockchain_sc
  domain_id: "06"
  format: yaml
  timestamp: "2026-06-26T12:00:00Z"
  batch_id: "c8d4e1f3"
finding:
  id: "SF-06-2026-0012"
  title: "Reentrancy vulnerability in withdraw function"
  severity: critical
  cvss: 9.9
  domain: blockchain_sc
  category: reentrancy
  affected_component: "0x7a3b...e4f2"
  description: "The withdraw function performs external call before state update..."
  domain_attributes:
    chain: ethereum
    contract_address: "0x7a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b"
    compiler_version: "0.8.19"
    optimization_enabled: true
    gas_limit: 3000000
    vulnerability_function: "withdraw(uint256)"
    reentrancy_type: cross-function
    attack_vector: external_call_before_state_update
remediation:
  priority: immediate
  complexity: low
  estimated_effort_hours: 8
  recommended_fix: "Apply checks-effects-interactions pattern"
```

### MessagePack

```
MessagePack binary representation for specialized findings uses the following
type mapping:

  String     -> msgpack str
  Integer    -> msgpack int
  Float      -> msgpack float
  Boolean    -> msgpack bool
  Null       -> msgpack nil
  Array      -> msgpack array
  Map        -> msgpack map
  Bytes      -> msgpack bin
  Timestamp  -> msgpack ext (type -1)
  Domain     -> msgpack ext (type 42)
  Severity   -> msgpack ext (type 43)
  CVSS       -> msgpack ext (type 44)

Binary payload typically 40-60% smaller than equivalent JSON.
```

### Protobuf

```protobuf
syntax = "proto3";
package specialized_targets;

message SpecializedFinding {
  FindingMeta meta = 1;
  FindingCore finding = 2;
  Evidence evidence = 3;
  Remediation remediation = 4;
  map<string, string> domain_attributes = 5;
}

message FindingMeta {
  string schema_version = 1;
  string domain = 2;
  string domain_id = 3;
  string format = 4;
  string timestamp = 5;
  string batch_id = 6;
}

message FindingCore {
  string id = 1;
  string title = 2;
  Severity severity = 3;
  float cvss = 4;
  string domain = 5;
  string category = 6;
  string affected_component = 7;
  string description = 8;
}

enum Severity {
  UNKNOWN = 0;
  INFO = 1;
  LOW = 2;
  MEDIUM = 3;
  HIGH = 4;
  CRITICAL = 5;
}

message Evidence {
  repeated Artifact artifacts = 1;
  repeated Screenshot screenshots = 2;
}

message Remediation {
  Priority priority = 1;
  Complexity complexity = 2;
  int32 estimated_effort_hours = 3;
  string recommended_fix = 4;
}

enum Priority { P_LOW = 0; P_MEDIUM = 1; P_HIGH = 2; P_IMMEDIATE = 3; }
enum Complexity { C_LOW = 0; C_MEDIUM = 1; C_HIGH = 2; }
```

---

## Findings Serialization

### Base Finding Structure

Every specialized finding serializes into a base structure regardless of domain:

```python
BASE_FINDING_SCHEMA = {
    "id": "string",           # SF-{DD}-{YYYY}-{NNNN}
    "title": "string",        # Max 200 chars
    "severity": "enum",       # info|low|medium|high|critical
    "cvss": "float",          # 0.0 - 10.0
    "domain": "string",       # Domain key from mapping table
    "domain_id": "string",    # 01-50
    "category": "string",     # Vuln category within domain
    "affected_component": "string",
    "description": "string",  # Max 5000 chars
    "domain_attributes": "map",   # Domain-specific key-value pairs
    "cross_domain_refs": "array", # Links to other domain findings
    "created_at": "timestamp",
    "updated_at": "timestamp",
    "author": "string",
    "review_status": "enum"   # draft|reviewed|validated|submitted
}
```

### Domain-Specific Attribute Schemas

| Domain | Required Domain Attributes |
|--------|---------------------------|
| iot_device (01) | protocol, firmware_version, device_model, communication_layer |
| mobile_app (02) | platform, app_version, package_name, signing_cert_status |
| cloud_infra (03) | provider, service_type, region, iam_role |
| container (04) | runtime, image_name, image_tag, base_os |
| kubernetes (05) | cluster_name, namespace, resource_type, api_version |
| blockchain_sc (06) | chain, contract_address, compiler_version, optimization_enabled |
| defi_protocol (07) | protocol_name, tvl, pool_type, oracle_source |
| nft_marketplace (08) | marketplace, token_standard, royalty_enforcement |
| web3_app (09) | wallet_integration, chain_id, dapp_framework |
| crypto_exchange (10) | exchange_name, hot_wallet_pct, withdrawal_logic |
| tradfi_api (11) | api_standard, auth_method, regulatory_scope |
| healthcare (12) | compliance_framework, phi_involved, device_type |
| financial_inst (13) | institution_type, regulatory_body, data_classification |
| government (14) | classification_level, agency_type, compliance_standard |
| education (15) | lms_platform, student_data_scope, ferpa_applicable |
| ecommerce (16) | platform_type, payment_processor, pci_scope |
| social_media (17) | user_count, content_type, privacy_scope |
| cms (18) | cms_type, plugin_count, user_role_model |
| lms (19) | lms_vendor, course_count, assessment_type |
| hr_system (20) | hr_platform, pii_fields, employee_count |
| supply_chain (21) | supply_chain_stage, vendor_count, logistic_provider |
| manufacturing (22) | plc_type, scada_vendor, operational_technology |
| smart_building (23) | bms_protocol, sensor_count, automation_level |
| connected_vehicle (24) | vehicle_make, ecu_type, can_bus_protocol |
| autonomous_system (25) | system_type, autonomy_level, sensor_fusion |
| ics_scada (26) | protocol_modbus, vendor, plant_type, downtime_impact |
| medical_device (27) | device_class, fda_clearance, patient_connected |
| wearable (28) | device_type, biometric_data, connectivity |
| smart_home (29) | ecosystem, hub_type, device_count |
| embedded_system (30) | mcu_arch, debug_interface, memory_size |
| rtos (31) | rtos_name, version, task_isolation |
| firmware_analysis (32) | firmware_format, signing_status, boot_chain |
| network_device (33) | device_type, firmware_version, management_protocol |
| telecom (34) | carrier, protocol_3gpp, network_slice |
| satellite_comm (35) | orbit_type, frequency_band, ground_station |
| atc_system (36) | radar_type, communication_protocol, safety_classification |
| power_grid (37) | grid_zone, voltage_level, scada_protocol |
| water_treatment (38) | treatment_stage, chemical_process, plc_vendor |
| transportation (39) | transport_mode, signaling_system, safety_standard |
| energy_management (40) | energy_source, smart_meter_type, grid_integration |
| research_institution (41) | institution_type, data_sensitivity, research_domain |
| nonprofit (42) | org_size, donor_data_scope, grant_compliance |
| startup (43) | funding_stage, tech_stack, compliance_status |
| enterprise_corp (44) | industry, employee_count, compliance_frameworks |
| fortune500 (45) | rank, global_presence, regulatory_bodies |
| oss_project (46) | repo_stars, contributor_count, license_type |
| academic_research (47) | institution, publication_status, irb_approval |
| international_org (48) | member_countries, treaty_scope, diplomatic_status |
| developing_infra (49) | country, infrastructure_age, aid_dependency |
| global_scale (50) | regions_served, user_base, cross_border_data |

---

## Serialize Operations

### Core Serialize Function

```python
def serialize_finding(finding: Finding, fmt: str = "json", compress: bool = False) -> bytes:
    """
    Serialize a specialized finding into the specified format.

    Args:
        finding: Finding object with domain-specific attributes
        fmt: Output format - 'json', 'yaml', 'messagepack', 'protobuf'
        compress: Apply compression after serialization

    Returns:
        Serialized bytes ready for storage or transmission
    """
    normalized = _normalize_domain_attributes(finding)
    _validate_domain_attributes(normalized)

    if fmt == "json":
        payload = _serialize_json(normalized)
    elif fmt == "yaml":
        payload = _serialize_yaml(normalized)
    elif fmt == "messagepack":
        payload = _serialize_msgpack(normalized)
    elif fmt == "protobuf":
        payload = _serialize_protobuf(normalized)
    else:
        raise UnsupportedFormatError(fmt)

    if compress:
        payload = _compress(payload)

    return payload


def _normalize_domain_attributes(finding: Finding) -> dict:
    """Merge domain_attributes into finding, preserving unknown keys."""
    base = finding.to_dict()
    domain_schema = DOMAIN_SCHEMAS.get(finding.domain, {})
    for key, spec in domain_schema.get("required", {}).items():
        if key not in base["domain_attributes"]:
            raise MissingDomainAttributeError(finding.domain, key)
    base["_domain_extensions"] = {
        k: v for k, v in base.pop("domain_attributes", {}).items()
        if k not in domain_schema.get("standard_keys", set())
    }
    return base
```

### Serialize with Domain Context

```python
def serialize_with_context(
    findings: list[Finding],
    context: SerializationContext
) -> bytes:
    """
    Batch serialize findings with pipeline context metadata.

    Context includes pipeline_id, batch_id, and downstream
    consumer hints for format negotiation.
    """
    envelope = {
        "pipeline_id": context.pipeline_id,
        "batch_id": context.batch_id,
        "total_findings": len(findings),
        "domains_represented": list({f.domain for f in findings}),
        "serialization_timestamp": datetime.utcnow().isoformat(),
        "findings": []
    }

    for f in findings:
        normalized = _normalize_domain_attributes(f)
        envelope["findings"].append(normalized)

    return serialize_finding(envelope, fmt=context.target_format)
```

---

## Deserialize Operations

### Core Deserialize Function

```python
def deserialize_finding(data: bytes, fmt: str = "auto") -> Finding:
    """
    Deserialize bytes into a specialized Finding object.

    Auto-detects format from magic bytes or header.
    """
    if fmt == "auto":
        fmt = detect_format(data)

    if fmt == "json":
        raw = _deserialize_json(data)
    elif fmt == "yaml":
        raw = _deserialize_yaml(data)
    elif fmt == "messagepack":
        raw = _deserialize_msgpack(data)
    elif fmt == "protobuf":
        raw = _deserialize_protobuf(data)
    else:
        raise UnsupportedFormatError(fmt)

    _rebuild_domain_extensions(raw)
    _validate_deserialized_finding(raw)

    return Finding.from_dict(raw)


def detect_format(data: bytes) -> str:
    """
    Detect serialization format from raw bytes.

    Detection order:
    1. Protobuf: starts with valid field tag byte (0x0A)
    2. MessagePack: msgpack magic range detection
    3. JSON: first non-whitespace byte is '{'
    4. YAML: first non-whitespace bytes match '---' or key pattern
    5. Compressed: check for gzip (1F 8B), brotli, zstd headers
    """
    if data[:1] == b'\x0a':
        return "protobuf"
    if _is_msgpack(data):
        return "messagepack"
    first = data.lstrip()[:1]
    if first == b'{':
        return "json"
    if first == b'-' or _looks_like_yaml(data):
        return "yaml"
    if data[:2] == b'\x1f\x8b':
        return detect_format(_decompress_gzip(data))
    if data[:4] == b'\x28\xb5\x2f\xfd':
        return detect_format(_decompress_zstd(data))
    raise FormatDetectionError("Unable to determine serialization format")
```

### Batch Deserialization

```python
def deserialize_batch(data: bytes, fmt: str = "auto") -> list[Finding]:
    """
    Deserialize a batch envelope containing multiple findings.
    Handles cross-domain batches (e.g., supply chain incident
    spanning IoT, cloud, and embedded domains).
    """
    if fmt == "auto":
        fmt = detect_format(data)

    envelope = deserialize_finding(data, fmt)

    if isinstance(envelope, dict) and "findings" in envelope:
        return [Finding.from_dict(f) for f in envelope["findings"]]
    return [envelope] if isinstance(envelope, Finding) else []
```

---

## Compression

| Algorithm | Ratio | Speed | Use Case |
|-----------|-------|-------|----------|
| gzip | 2.5-3x | Fast | Default for API transport |
| brotli | 3.0-3.5x | Medium | Web delivery, CDN caching |
| zstd | 3.0-4x | Very Fast | High-throughput pipelines |

```python
COMPRESSION_THRESHOLDS = {
    "gzip": 1024,      # Compress if > 1KB
    "brotli": 2048,    # Compress if > 2KB
    "zstd": 512,       # Compress if > 512B
}

def maybe_compress(data: bytes, algo: str = "zstd") -> bytes:
    threshold = COMPRESSION_THRESHOLDS.get(algo, 1024)
    if len(data) < threshold:
        return data
    if algo == "gzip":
        return gzip.compress(data, compresslevel=6)
    elif algo == "brotli":
        return brotli.compress(data, quality=4)
    elif algo == "zstd":
        return zstd.compress(data, level=3)
    return data
```

---

## Type Preservation

Specialized domains use types that don't map cleanly to JSON primitives. The serializer preserves these via extension types:

| Original Type | Serialized As | Extension Tag |
|---------------|---------------|---------------|
| `bytes` | base64 string | `!bytes` |
| `datetime` | ISO 8601 string | `!datetime` |
| `Decimal` | string | `!decimal` |
| `BigInt` | string | `!bigint` |
| `enum` | string value | `!enum:ClassName` |
| `set` | array (sorted) | `!set` |
| `tuple` | array | `!tuple` |
| `IP/Network` | string | `!ip` |
| `Ethereum Address` | checksummed hex | `!eth_addr` |
| `Solana Pubkey` | base58 string | `!sol_addr` |
| `IPFS CID` | string | `!ipfs` |
| `URI` | string | `!uri` |

```python
TYPE_TAGS = {
    "bytes": "!bytes",
    "datetime": "!datetime",
    "decimal": "!decimal",
    "bigint": "!bigint",
    "set": "!set",
    "tuple": "!tuple",
    "ip": "!ip",
    "eth_addr": "!eth_addr",
    "sol_addr": "!sol_addr",
    "ipfs": "!ipfs",
    "uri": "!uri",
}
```

---

## Custom Serializers

### Domain-Specific Serializer Registry

Each domain can register custom serializers for non-trivial attribute types:

```python
DOMAIN_SERIALIZER_REGISTRY = {
    "iot_device": {
        "packet_capture": PacketCaptureSerializer,
        "firmware_binary": FirmwareBinarySerializer,
        "device_fingerprint": DeviceFingerprintSerializer,
    },
    "blockchain_sc": {
        "transaction_trace": TransactionTraceSerializer,
        "bytecode_diff": BytecodeDiffSerializer,
        "gas_profile": GasProfileSerializer,
    },
    "ics_scada": {
        "modbus_frame": ModbusFrameSerializer,
        "plc_program": PLCProgramSerializer,
        "scada_alarm": SCADAAlarmSerializer,
    },
    "medical_device": {
        "dicom_metadata": DICOMSerializer,
        "fhir_resource": FHIRResourceSerializer,
        "clinical_trial_data": ClinicalTrialSerializer,
    },
    "power_grid": {
        "phasor_data": PhasorDataSerializer,
        "scada_packet": SCADAPacketSerializer,
        "grid_topology": GridTopologySerializer,
    },
    "satellite_comm": {
        "telemetry_frame": TelemetryFrameSerializer,
        "orbital_data": OrbitalDataSerializer,
        "spectrum_data": SpectrumDataSerializer,
    },
}
```

### Custom Serializer Interface

```python
class DomainSerializer:
    """Base class for domain-specific serializers."""

    def serialize(self, obj) -> dict:
        """Convert domain-specific object to serializable dict."""
        raise NotImplementedError

    def deserialize(self, data: dict):
        """Reconstruct domain-specific object from dict."""
        raise NotImplementedError

    def validate(self, data: dict) -> bool:
        """Validate serialized data against domain schema."""
        raise NotImplementedError

    def estimate_size(self, obj) -> int:
        """Estimate serialized size in bytes for compression decisions."""
        raise NotImplementedError
```

---

## Format Detection

```python
MAGIC_BYTES = {
    b'\x0a': "protobuf",
    b'\x1f\x8b': "gzip_compressed_json",
    b'\x28\xb5\x2f\xfd': "zstd_compressed",
    b'{': "json",
    b'[': "json_array",
    b'-': "yaml",
    b'%': "yaml_directive",
}

def detect_format_with_compression(data: bytes) -> tuple[str, bool]:
    """Returns (underlying_format, is_compressed)."""
    if data[:2] in (b'\x1f\x8b',):
        return detect_format(gzip.decompress(data)), True
    if data[:4] in (b'\x28\xb5\x2f\xfd',):
        return detect_format(zstd.decompress(data)), True
    return detect_format(data), False
```

---

## Batch Operations

### Batch Serialize

```python
def serialize_batch(
    findings: list[Finding],
    fmt: str = "json",
    compress: str = "zstd",
    chunk_size: int = 500
) -> list[bytes]:
    """
    Serialize findings in chunks for memory-efficient processing.
    Each chunk is independently compressible and deserializable.
    """
    chunks = []
    for i in range(0, len(findings), chunk_size):
        chunk = findings[i:i + chunk_size]
        envelope = {
            "chunk_index": i // chunk_size,
            "chunk_total": (len(findings) + chunk_size - 1) // chunk_size,
            "findings_count": len(chunk),
            "findings": [_normalize_domain_attributes(f) for f in chunk]
        }
        payload = serialize_finding(envelope, fmt=fmt)
        if compress:
            payload = maybe_compress(payload, algo=compress)
        chunks.append(payload)
    return chunks
```

### Batch Deserialize

```python
def deserialize_batch_stream(
    chunks: list[bytes],
    fmt: str = "auto"
) -> Generator[Finding, None, None]:
    """
    Lazily deserialize chunked batch data.
    Yields findings one at a time for memory efficiency.
    """
    for chunk in chunks:
        envelope = deserialize_finding(chunk, fmt=fmt)
        for f_data in envelope.get("findings", []):
            yield Finding.from_dict(f_data)
```

### Cross-Domain Batch Correlation

```python
def correlate_batch(findings: list[Finding]) -> dict[str, list[Finding]]:
    """
    Group findings by cross-domain reference chains.
    Useful for incidents spanning multiple specialized domains.
    """
    groups = defaultdict(list)
    for f in findings:
        refs = f.cross_domain_refs or []
        group_key = refs[0] if refs else f.id
        groups[group_key].append(f)
    return dict(groups)
```

---

## Registry Schema

```json
{
  "registry": {
    "version": "3.0",
    "total_domains": 50,
    "domains": {
      "iot_device": {
        "id": "01",
        "file": "01-IoT-Device-Security.md",
        "category": "iot",
        "severity_range": ["low", "critical"],
        "has_firmware": true,
        "has_network_traffic": true,
        "custom_serializer": true
      },
      "mobile_app": {
        "id": "02",
        "file": "02-Mobile-Application-Testing.md",
        "category": "mobile",
        "platforms": ["android", "ios", "harmonyos"],
        "custom_serializer": true
      },
      "cloud_infra": {
        "id": "03",
        "file": "03-Cloud-Infrastructure-Security.md",
        "category": "cloud",
        "providers": ["aws", "gcp", "azure", "alibaba", "oci"],
        "custom_serializer": false
      },
      "blockchain_sc": {
        "id": "06",
        "file": "06-Blockchain-Smart-Contracts.md",
        "category": "web3",
        "chains": ["ethereum", "solana", "polygon", "bsc"],
        "custom_serializer": true
      },
      "ics_scada": {
        "id": "26",
        "file": "26-Industrial-Control-System-Security.md",
        "category": "industrial",
        "protocols": ["modbus", "opcua", "dnp3", "bacnet"],
        "custom_serializer": true
      },
      "power_grid": {
        "id": "37",
        "file": "37-Power-Grid-Security.md",
        "category": "critical_infrastructure",
        "regulatory": ["nerc_cip", "ferc"],
        "custom_serializer": true
      }
    }
  }
}
```

---

## Error Handling

### Error Types

```python
class SerializationError(Exception):
    """Base error for all serialization failures."""
    pass

class UnsupportedFormatError(SerializationError):
    """Target format not supported."""
    def __init__(self, fmt: str):
        super().__init__(f"Unsupported format: {fmt}")
        self.format = fmt

class FormatDetectionError(SerializationError):
    """Unable to auto-detect format from bytes."""
    pass

class MissingDomainAttributeError(SerializationError):
    """Required domain attribute missing from finding."""
    def __init__(self, domain: str, attr: str):
        super().__init__(f"Domain '{domain}' requires attribute '{attr}'")
        self.domain = domain
        self.attribute = attr

class DomainSchemaViolationError(SerializationError):
    """Finding violates domain schema constraints."""
    pass

class CompressionError(SerializationError):
    """Compression/decompression failed."""
    pass

class DeserializationError(SerializationError):
    """Data cannot be deserialized into expected structure."""
    pass

class CrossDomainRefError(SerializationError):
    """Cross-domain reference points to non-existent finding."""
    pass
```

### Error Recovery

```python
def safe_deserialize(data: bytes, fmt: str = "auto") -> Optional[Finding]:
    """
    Attempt deserialization with graceful error recovery.
    Returns None if data is unrecoverable, or a partial Finding
    with error metadata if partially parseable.
    """
    try:
        return deserialize_finding(data, fmt)
    except FormatDetectionError:
        return None
    except DeserializationError as e:
        return _build_partial_finding(data, error=e)
    except Exception as e:
        return _build_error_finding(data, error=e)
```

---

## Pipeline Integration

### Serialization in the Finding Pipeline

```
Finding Generation (Domain)
       |
       v
Domain-Specific Validation
       |
       v
Normalize Domain Attributes
       |
       v
Base Finding Validation
       |
       v
Apply Custom Serializer (if registered)
       |
       v
Serialize to Target Format
       |
       v
Compress (if size > threshold)
       |
       v
Write to Output (storage / queue / network)
```

### Pipeline Hooks

```python
SERIALIZATION_PIPELINE_HOOKS = {
    "pre_serialize": [
        "validate_domain_attributes",
        "check_cross_domain_refs",
        "enrich_with_cvss_vector",
        "apply_redaction_rules",
    ],
    "post_serialize": [
        "validate_serialized_bytes",
        "update_batch_checksum",
        "log_serialization_metrics",
    ],
    "pre_deserialize": [
        "validate_format_compatibility",
        "check_schema_version",
    ],
    "post_deserialize": [
        "rebuild_domain_extensions",
        "validate_deserialized_finding",
        "update_finding_index",
    ],
}
```

### Pipeline Metrics

```python
PIPELINE_METRICS = {
    "serialize": {
        "total_operations": "counter",
        "bytes_serialized": "counter",
        "average_duration_ms": "histogram",
        "domain_breakdown": "per_domain_counter",
        "format_breakdown": "per_format_counter",
    },
    "deserialize": {
        "total_operations": "counter",
        "bytes_deserialized": "counter",
        "average_duration_ms": "histogram",
        "error_rate": "gauge",
    },
    "compression": {
        "ratio": "histogram",
        "bytes_saved": "counter",
        "algorithm_usage": "per_algo_counter",
    },
}
```

---

## Full Domain File References

All 50 domain files referenced by the serialization layer:

| # | File | Domain Key | Serialization Complexity |
|---|------|------------|--------------------------|
| 01 | `01-IoT-Device-Security.md` | iot_device | High - firmware/packet data |
| 02 | `02-Mobile-Application-Testing.md` | mobile_app | Medium - binary analysis |
| 03 | `03-Cloud-Infrastructure-Security.md` | cloud_infra | Low - standard JSON |
| 04 | `04-Container-Security.md` | container | Low - config-based |
| 05 | `05-Kubernetes-Cluster-Security.md` | kubernetes | Low - manifest data |
| 06 | `06-Blockchain-Smart-Contracts.md` | blockchain_sc | High - bytecode/traces |
| 07 | `07-DeFi-Protocol-Security.md` | defi_protocol | High - financial math |
| 08 | `08-NFT-Marketplace-Security.md` | nft_marketplace | Medium - token data |
| 09 | `09-Web3-Application-Security.md` | web3_app | Medium - chain-specific |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | crypto_exchange | High - wallet/tx data |
| 11 | `11-Traditional-Finance-API-Security.md` | tradfi_api | Medium - regulatory |
| 12 | `12-Healthcare-System-Security.md` | healthcare | High - HIPAA/PHI |
| 13 | `13-Financial-Institution-Security.md` | financial_inst | High - PCI/SOX |
| 14 | `14-Government-System-Security.md` | government | High - classification |
| 15 | `15-Education-Platform-Security.md` | education | Medium - FERPA |
| 16 | `16-Ecommerce-Platform-Security.md` | ecommerce | Medium - PCI |
| 17 | `17-Social-Media-Platform-Security.md` | social_media | Medium - user data |
| 18 | `18-Content-Management-System-Security.md` | cms | Low - plugin data |
| 19 | `19-Learning-Management-System-Security.md` | lms | Medium - assessment |
| 20 | `20-Human-Resources-System-Security.md` | hr_system | Medium - PII |
| 21 | `21-Supply-Chain-Management-Security.md` | supply_chain | High - multi-domain |
| 22 | `22-Manufacturing-Control-System-Security.md` | manufacturing | High - OT data |
| 23 | `23-Smart-Building-Automation.md` | smart_building | Medium - protocol data |
| 24 | `24-Connected-Vehicle-Security.md` | connected_vehicle | High - CAN bus |
| 25 | `25-Autonomous-System-Security.md` | autonomous_system | High - sensor data |
| 26 | `26-Industrial-Control-System-Security.md` | ics_scada | High - Modbus/OPC UA |
| 27 | `27-Medical-Device-Security.md` | medical_device | High - DICOM/FHIR |
| 28 | `28-Wearable-Technology-Security.md` | wearable | Medium - biometric |
| 29 | `29-Smart-Home-Device-Security.md` | smart_home | Low - device data |
| 30 | `30-Embedded-System-Security.md` | embedded_system | High - binary/memory |
| 31 | `31-Real-Time-Operating-System-Security.md` | rtos | High - task/kernel |
| 32 | `32-Firmware-Security-Analysis.md` | firmware_analysis | High - binary analysis |
| 33 | `33-Network-Device-Security.md` | network_device | Medium - config |
| 34 | `34-Telecommunication-System-Security.md` | telecom | High - 3GPP |
| 35 | `35-Satellite-Communication-Security.md` | satellite_comm | High - telemetry |
| 36 | `36-Air-Traffic-Control-System-Security.md` | atc_system | Critical - safety |
| 37 | `37-Power-Grid-Security.md` | power_grid | Critical - grid ops |
| 38 | `38-Water-Treatment-Facility-Security.md` | water_treatment | Critical - process |
| 39 | `39-Transportation-System-Security.md` | transportation | High - signaling |
| 40 | `40-Energy-Management-System-Security.md` | energy_management | Medium - metering |
| 41 | `41-Research-Institution-Security.md` | research_institution | Medium - research data |
| 42 | `42-Non-Profit-Organization-Security.md` | nonprofit | Low - donor data |
| 43 | `43-Startup-Company-Security.md` | startup | Low - minimal infra |
| 44 | `44-Enterprise-Corporate-Security.md` | enterprise_corp | Medium - corp data |
| 45 | `45-Fortune-500-Company-Security.md` | fortune500 | High - global scale |
| 46 | `46-Open-Source-Project-Security.md` | oss_project | Low - repo data |
| 47 | `47-Academic-Research-Security.md` | academic_research | Medium - research |
| 48 | `48-International-Organization-Security.md` | international_org | High - diplomatic |
| 49 | `49-Developing-Country-Infrastructure.md` | developing_infra | High - legacy systems |
| 50 | `50-Global-Scale-System-Security.md` | global_scale | Critical - cross-border |

### Reference Loading Strategy

```python
DOMAIN_FILE_MAP = {
    "01": "01-IoT-Device-Security.md",
    "02": "02-Mobile-Application-Testing.md",
    "03": "03-Cloud-Infrastructure-Security.md",
    "04": "04-Container-Security.md",
    "05": "05-Kubernetes-Cluster-Security.md",
    "06": "06-Blockchain-Smart-Contracts.md",
    "07": "07-DeFi-Protocol-Security.md",
    "08": "08-NFT-Marketplace-Security.md",
    "09": "09-Web3-Application-Security.md",
    "10": "10-Cryptocurrency-Exchange-Security.md",
    "11": "11-Traditional-Finance-API-Security.md",
    "12": "12-Healthcare-System-Security.md",
    "13": "13-Financial-Institution-Security.md",
    "14": "14-Government-System-Security.md",
    "15": "15-Education-Platform-Security.md",
    "16": "16-Ecommerce-Platform-Security.md",
    "17": "17-Social-Media-Platform-Security.md",
    "18": "18-Content-Management-System-Security.md",
    "19": "19-Learning-Management-System-Security.md",
    "20": "20-Human-Resources-System-Security.md",
    "21": "21-Supply-Chain-Management-Security.md",
    "22": "22-Manufacturing-Control-System-Security.md",
    "23": "23-Smart-Building-Automation.md",
    "24": "24-Connected-Vehicle-Security.md",
    "25": "25-Autonomous-System-Security.md",
    "26": "26-Industrial-Control-System-Security.md",
    "27": "27-Medical-Device-Security.md",
    "28": "28-Wearable-Technology-Security.md",
    "29": "29-Smart-Home-Device-Security.md",
    "30": "30-Embedded-System-Security.md",
    "31": "31-Real-Time-Operating-System-Security.md",
    "32": "32-Firmware-Security-Analysis.md",
    "33": "33-Network-Device-Security.md",
    "34": "34-Telecommunication-System-Security.md",
    "35": "35-Satellite-Communication-Security.md",
    "36": "36-Air-Traffic-Control-System-Security.md",
    "37": "37-Power-Grid-Security.md",
    "38": "38-Water-Treatment-Facility-Security.md",
    "39": "39-Transportation-System-Security.md",
    "40": "40-Energy-Management-System-Security.md",
    "41": "41-Research-Institution-Security.md",
    "42": "42-Non-Profit-Organization-Security.md",
    "43": "43-Startup-Company-Security.md",
    "44": "44-Enterprise-Corporate-Security.md",
    "45": "45-Fortune-500-Company-Security.md",
    "46": "46-Open-Source-Project-Security.md",
    "47": "47-Academic-Research-Security.md",
    "48": "48-International-Organization-Security.md",
    "49": "49-Developing-Country-Infrastructure.md",
    "50": "50-Global-Scale-System-Security.md",
}
```

---

## Appendix: Schema Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2025-01-01 | Initial 20 domain schemas |
| 1.5 | 2025-06-15 | Added domains 21-40, cross-domain refs |
| 2.0 | 2025-12-01 | Added domains 41-50, protobuf support |
| 2.1 | 2026-03-15 | Custom serializer registry, compression |
| 3.0 | 2026-06-26 | Full 50-domain schema, MessagePack, batch ops |
