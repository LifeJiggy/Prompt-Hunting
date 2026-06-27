# Core Prompts Hunting - Data Serialization

---

## Metadata

```yaml
version: "1.0.0"
domain: "core-prompts-hunting"
domain_id: "hunting"
type: "serialization-config"
created_at: "2026-06-26T00:00:00Z"
updated_at: "2026-06-26T00:00:00Z"
serialization_format_version: "2.1"
supported_formats:
  - json
  - yaml
  - messagepack
  - protobuf
compression:
  - gzip
  - brotli
  - lz4
total_domain_files: 50
author: "MiMoCode Serialization Engine"
```

---

## Domain Mapping

The `core-prompts-hunting` domain encompasses all 50 specialized prompt files covering the full spectrum of web application security hunting, reconnaissance, vulnerability analysis, and proof-of-concept development. Each file represents a discrete domain of security knowledge with its own serialization schema.

| Domain ID | Domain Name | File Reference | Serialization Category |
|-----------|-------------|----------------|------------------------|
| recon | Reconnaissance & Asset Discovery | 1-Reconnaissance-and-Asset-Discovery.md | reconnaissance |
| js | JavaScript Analysis & Deobfuscation | 2-JavaScript-Analysis-and-Deobfuscation.md | code-analysis |
| api | API Endpoint Analysis | 3-API-Endpoint-Analysis.md | api-security |
| auth | Authentication & Session Management | 4-Authentication-and-Session-Management.md | authentication |
| authz | Authorization & Access Control | 5-Authorization-and-Access-Control.md | authorization |
| input | Input Validation & Sanitization | 6-Input-Validation-and-Sanitization.md | input-handling |
| bizlogic | Business Logic Flaws | 7-Business-Logic-Flaws.md | business-logic |
| client | Client-Side Storage Security | 8-Client-Side-Storage-Security.md | client-side |
| crypto | Cryptography & Data Protection | 9-Cryptography-and-Data-Protection.md | cryptographic |
| error | Error Handling & Info Disclosure | 10-Error-Handling-and-Information-Disclosure.md | information-disclosure |
| upload | File Upload & Processing | 11-File-Upload-and-Processing.md | file-handling |
| ssrf | Server-Side Request Forgery | 12-Server-Side-Request-Forgery-SSRF.md | ssrf |
| csrf | Cross-Site Request Forgery | 13-Cross-Site-Request-Forgery-CSRF.md | csrf |
| cors | Cross-Origin Resource Sharing | 14-Cross-Origin-Resource-Sharing-CORS.md | cors |
| race | Race Conditions & Concurrency | 15-Race-Conditions-and-Concurrency-Issues.md | concurrency |
| thirdparty | Third-Party Component Analysis | 16-Third-Party-Component-Analysis.md | supply-chain |
| config | Configuration & Misconfiguration | 17-Configuration-and-Misconfiguration-Hunting.md | configuration |
| network | Network & Infrastructure Security | 18-Network-and-Infrastructure-Security.md | infrastructure |
| mobile | Mobile & API-Specific Vulns | 19-Mobile-and-API-Specific-Vulnerabilities.md | mobile-security |
| report | Reporting & PoC Development | 20-Reporting-and-Proof-of-Concept-Development.md | reporting |
| waf | WAF Bypass Techniques | 21-Web-Application-Firewall-WAF-Bypass.md | waf-bypass |
| smuggle | HTTP Request Smuggling | 22-HTTP-Request-Smuggling.md | http-smuggling |
| takeover | Subdomain Takeover | 23-Subdomain-Takeover.md | subdomain |
| host | Host Header Injection | 24-Host-Header-Injection.md | host-header |
| xxe | XML External Entity Injection | 25-XML-External-Entity-XXE-Injection.md | xxe |
| deser | Insecure Deserialization | 26-Insecure-Deserialization.md | deserialization |
| cmdi | Command Injection | 27-Command-Injection.md | command-injection |
| nosql | NoSQL Injection | 28-NoSQL-Injection.md | nosql |
| gql | GraphQL Vulnerabilities | 29-GraphQL-Vulnerabilities.md | graphql |
| ws | WebSocket Security | 30-WebSocket-Security.md | websocket |
| ssti | Server-Side Template Injection | 31-Server-Side-Template-Injection.md | ssti |
| jwt | JWT Vulnerabilities | 32-JSON-Web-Token-JWT-Vulnerabilities.md | jwt |
| csp | CSP Bypass Techniques | 33-Content-Security-Policy-CSP-Bypass.md | csp |
| clickjack | Clickjacking & UI Redressing | 34-Clickjacking-and-UI-Redressing.md | clickjacking |
| hpp | HTTP Parameter Pollution | 35-HTTP-Parameter-Pollution.md | hpp |
| ldap | LDAP Injection | 36-LDAP-Injection.md | ldap |
| puzzling | Session Puzzling & Fixation | 37-Session-Puzzling-and-Fixation.md | session |
| filehandle | Insecure File Handling | 38-Insecure-File-Handling.md | file-security |
| xssi | Cross-Site Script Inclusion | 39-Cross-Site-Script-Inclusion-XSSI.md | xssi |
| proto | Prototype Pollution | 40-Prototype-Pollution.md | prototype |
| splitting | HTTP Response Splitting | 41-HTTP-Response-Splitting.md | response-splitting |
| xpath | XPath Injection | 42-XPath-Injection.md | xpath |
| csrf2 | Cross-Site Request Forgery (Extended) | 43-Cross-Site-Request-Forgery-CSRF.md | csrf-extended |
| cors2 | CORS (Extended) | 44-Cross-Origin-Resource-Sharing-CORS.md | cors-extended |
| race2 | Race Conditions (Extended) | 45-Race-Conditions-and-Concurrency-Issues.md | concurrency-extended |
| thirdparty2 | Third-Party (Extended) | 46-Third-Party-Component-Analysis.md | supply-chain-extended |
| config2 | Configuration (Extended) | 47-Configuration-and-Misconfiguration-Hunting.md | configuration-extended |
| network2 | Network (Extended) | 48-Network-and-Infrastructure-Security.md | infrastructure-extended |
| mobile2 | Mobile (Extended) | 49-Mobile-and-API-Specific-Vulnerabilities.md | mobile-security-extended |
| report2 | Reporting (Extended) | 50-Reporting-and-Proof-of-Concept-Development.md | reporting-extended |

---

## Overview

The hunting domain serialization layer provides a unified interface for converting structured vulnerability hunting prompts, findings, session data, and workflow artifacts across multiple data interchange formats. This system ensures:

1. **Format Agnostic Persistence**: All hunting data can be stored, transmitted, and reconstructed regardless of the underlying serialization format.
2. **Lossless Round-Trip**: Serialize → store → deserialize preserves all type information, metadata, and domain-specific structures.
3. **Schema Evolution**: Forward and backward compatibility for prompt file format changes across versions.
4. **Batch Efficiency**: Bulk operations for large-scale recon findings, multi-file prompt loading, and session checkpoint serialization.
5. **Pipeline Integration**: Direct hooks into the hunting workflow pipeline for automated serialization at each stage.

The 50 domain files represent the complete knowledge base for web application security hunting. Each file's content is deserialized into a structured prompt object containing:
- **Metadata block**: version, category, severity mappings, prerequisite chains
- **Prompt content**: the actual hunting instructions, detection patterns, exploitation techniques
- **Cross-references**: links to related domain files for chained vulnerability analysis
- **Output templates**: structured formats for findings and proof-of-concept documentation

---

## Format Support

### JSON (Primary)

JSON serves as the primary interchange format for all hunting domain data. Preferred for API communication, browser-based tools, and configuration files.

```json
{
  "serialization": {
    "format": "json",
    "version": "2.1",
    "domain": "core-prompts-hunting",
    "file_id": 1,
    "filename": "1-Reconnaissance-and-Asset-Discovery.md",
    "domain_key": "recon",
    "category": "reconnaissance",
    "content_hash": "sha256:abcdef1234567890",
    "schema_version": "1.0"
  },
  "prompt": {
    "title": "Reconnaissance and Asset Discovery",
    "prerequisites": [],
    "severity_baseline": "info",
    "hunting_phase": 1,
    "detection_patterns": ["subdomain_enum", "port_scan", "tech_fingerprint"],
    "tools": ["subfinder", "httpx", "nuclei", "katana"],
    "output_format": "findings_bundle"
  }
}
```

**JSON Schema Constraints**:
- Maximum nesting depth: 32 levels
- UTF-8 encoding mandatory
- Numeric precision: IEEE 754 double (sufficient for all domain values)
- Null handling: explicit null vs field omission distinguished

### YAML (Human-Readable)

YAML format for configuration files, prompt authoring, and human-reviewed serialization outputs.

```yaml
serialization:
  format: yaml
  version: "2.1"
  domain: core-prompts-hunting
  file_id: 1
  filename: 1-Reconnaissance-and-Asset-Discovery.md
  domain_key: recon
  category: reconnaissance
  content_hash: "sha256:abcdef1234567890"
  schema_version: "1.0"

prompt:
  title: Reconnaissance and Asset Discovery
  prerequisites: []
  severity_baseline: info
  hunting_phase: 1
  detection_patterns:
    - subdomain_enum
    - port_scan
    - tech_fingerprint
  tools:
    - subfinder
    - httpx
    - nuclei
    - katana
  output_format: findings_bundle
```

**YAML Constraints**:
- YAML 1.2 spec compliance
- Flow style prohibited for domain data (block style only)
- Anchor/alias limit: 128 per document
- Tab characters forbidden

### MessagePack (Binary Efficiency)

MessagePack for high-performance binary serialization in pipeline operations where JSON overhead is unacceptable.

**Binary Layout**:
- Header: 4 bytes (format_id + domain_id + version + flags)
- Body: MessagePack-encoded payload
- Footer: 4 bytes (CRC32 checksum)

**Size Comparison** (typical hunting finding):
| Format | Size | Compression Ratio |
|--------|------|-------------------|
| JSON | 2,847 bytes | baseline |
| YAML | 3,201 bytes | 0.89x |
| MessagePack | 1,923 bytes | 1.48x |
| Protobuf | 1,456 bytes | 1.96x |

### Protobuf (Schema-Enforced)

Protocol Buffers for strongly-typed serialization with enforced schema validation.

```protobuf
syntax = "proto3";
package hunting.serialization;

message HuntingDomainFile {
  uint32 file_id = 1;
  string filename = 2;
  string domain_key = 3;
  string category = 4;
  string content_hash = 5;
  string schema_version = 6;
  PromptMetadata prompt = 7;
  repeated CrossReference references = 8;
}

message PromptMetadata {
  string title = 1;
  repeated string prerequisites = 2;
  string severity_baseline = 3;
  uint32 hunting_phase = 4;
  repeated string detection_patterns = 5;
  repeated string tools = 6;
  string output_format = 7;
}

message CrossReference {
  uint32 target_file_id = 1;
  string relationship_type = 2;
  string description = 3;
}
```

---

## Findings Serialization

Each hunting finding is serialized with a consistent envelope structure across all formats.

### Finding Envelope

```json
{
  "finding": {
    "id": "FINDING-2026-0626-001",
    "domain_file_id": 1,
    "domain_file_name": "1-Reconnaissance-and-Asset-Discovery.md",
    "severity": "high",
    "cvss_score": 8.5,
    "cvss_vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N",
    "title": "Unauthenticated Subdomain Enumeration Exposes Internal Services",
    "description": "...",
    "detection_method": "automated",
    "reproduction_steps": ["step1", "step2", "step3"],
    "impact": "...",
    "remediation": "...",
    "references": ["CVE-2026-XXXX", "CWE-200"],
    "evidence": {
      "request": "...",
      "response": "...",
      "screenshots": [],
      "har_file": null
    },
    "metadata": {
      "hunter_id": "agent-001",
      "session_id": "ses_abc123",
      "timestamp": "2026-06-26T12:00:00Z",
      "tools_used": ["subfinder", "httpx"],
      "confidence": 0.95
    }
  }
}
```

### Severity Enum Mapping

```yaml
severity_levels:
  critical:
    cvss_range: "9.0 - 10.0"
    color: "#FF0000"
    auto_escalate: true
  high:
    cvss_range: "7.0 - 8.9"
    color: "#FF6600"
    auto_escalate: false
  medium:
    cvss_range: "4.0 - 6.9"
    color: "#FFCC00"
    auto_escalate: false
  low:
    cvss_range: "0.1 - 3.9"
    color: "#00CC00"
    auto_escalate: false
  informational:
    cvss_range: "0.0"
    color: "#0066FF"
    auto_escalate: false
```

### Finding Cross-Reference Map

Each finding can reference multiple domain files when vulnerabilities chain across domains:

```json
{
  "cross_references": [
    {
      "source_file": 12,
      "source_name": "12-Server-Side-Request-Forgery-SSRF.md",
      "target_file": 18,
      "target_name": "18-Network-and-Infrastructure-Security.md",
      "chain_description": "SSRF to internal network metadata access",
      "chain_type": "escalation",
      "combined_cvss": 9.8
    }
  ]
}
```

---

## Serialize Operations

### Serialize Single Domain File

```python
def serialize_domain_file(file_id: int, format: str = "json") -> bytes:
    """
    Serialize a single hunting domain file to the specified format.

    Args:
        file_id: Integer ID (1-50) of the domain file
        format: Target format (json|yaml|messagepack|protobuf)

    Returns:
        Serialized bytes ready for storage or transmission
    """
    domain_file = load_domain_file(file_id)
    envelope = build_serialization_envelope(domain_file)

    if format == "json":
        return json.dumps(envelope, ensure_ascii=False).encode("utf-8")
    elif format == "yaml":
        return yaml.dump(envelope, allow_unicode=True).encode("utf-8")
    elif format == "messagepack":
        return msgpack.packb(envelope, use_bin_type=True)
    elif format == "protobuf":
        return serialize_protobuf(envelope)
    else:
        raise SerializationError(f"Unsupported format: {format}")
```

### Serialize Finding

```python
def serialize_finding(finding: Finding, format: str = "json") -> bytes:
    """
    Serialize a hunting finding with full envelope metadata.
    """
    envelope = {
        "finding": {
            "id": finding.id,
            "domain_file_id": finding.domain_file_id,
            "domain_file_name": DOMAIN_FILES[finding.domain_file_id],
            "severity": finding.severity,
            "cvss_score": finding.cvss_score,
            "cvss_vector": finding.cvss_vector,
            "title": finding.title,
            "description": finding.description,
            "detection_method": finding.detection_method,
            "reproduction_steps": finding.reproduction_steps,
            "impact": finding.impact,
            "remediation": finding.remediation,
            "references": finding.references,
            "evidence": serialize_evidence(finding.evidence),
            "metadata": serialize_finding_metadata(finding.metadata)
        }
    }
    return serialize_to_format(envelope, format)
```

### Serialize Session Checkpoint

```python
def serialize_session(session: HuntingSession, format: str = "json") -> bytes:
    """
    Serialize complete hunting session state including all findings,
    active prompts, and workflow position.
    """
    checkpoint = {
        "session": {
            "session_id": session.id,
            "hunter_id": session.hunter_id,
            "started_at": session.started_at,
            "last_updated": session.last_updated,
            "status": session.status,
            "active_domain_files": session.active_files,
            "completed_domain_files": session.completed_files,
            "findings": [serialize_finding(f, "json") for f in session.findings],
            "workflow_position": {
                "phase": session.phase,
                "step": session.step,
                "next_actions": session.next_actions
            },
            "statistics": {
                "total_findings": len(session.findings),
                "by_severity": session.severity_counts,
                "by_domain": session.domain_counts,
                "coverage_percentage": session.coverage
            }
        }
    }
    return serialize_to_format(checkpoint, format)
```

---

## Deserialize Operations

### Deserialize to Domain Object

```python
def deserialize_domain_file(data: bytes, format: str = "json") -> DomainFile:
    """
    Deserialize bytes back into a DomainFile object with full validation.

    Performs schema validation, type coercion, and integrity checks.
    """
    raw = deserialize_from_format(data, format)
    validate_schema(raw, "domain_file")

    return DomainFile(
        file_id=raw["serialization"]["file_id"],
        filename=raw["serialization"]["filename"],
        domain_key=raw["serialization"]["domain_key"],
        category=raw["serialization"]["category"],
        content_hash=raw["serialization"]["content_hash"],
        prompt=PromptMetadata(**raw["prompt"]),
        references=[CrossReference(**ref) for ref in raw.get("references", [])]
    )
```

### Deserialize Finding

```python
def deserialize_finding(data: bytes, format: str = "json") -> Finding:
    """
    Deserialize a finding with full type restoration and validation.
    """
    raw = deserialize_from_format(data, format)
    validate_schema(raw, "finding")

    finding_data = raw["finding"]
    return Finding(
        id=finding_data["id"],
        domain_file_id=finding_data["domain_file_id"],
        severity=finding_data["severity"],
        cvss_score=finding_data["cvss_score"],
        cvss_vector=finding_data["cvss_vector"],
        title=finding_data["title"],
        description=finding_data["description"],
        detection_method=finding_data["detection_method"],
        reproduction_steps=finding_data["reproduction_steps"],
        impact=finding_data["impact"],
        remediation=finding_data["remediation"],
        references=finding_data["references"],
        evidence=deserialize_evidence(finding_data["evidence"]),
        metadata=deserialize_finding_metadata(finding_data["metadata"])
    )
```

### Format-Agnostic Deserializer

```python
def deserialize_from_format(data: bytes, format: str) -> dict:
    """
    Universal deserializer that detects and parses any supported format.
    """
    if format == "json":
        return json.loads(data.decode("utf-8"))
    elif format == "yaml":
        return yaml.safe_load(data.decode("utf-8"))
    elif format == "messagepack":
        return msgpack.unpackb(data, raw=False)
    elif format == "protobuf":
        return deserialize_protobuf(data)
    else:
        raise DeserializationError(f"Unsupported format: {format}")
```

---

## Compression

All serialization formats support transparent compression layers.

### Compression Configuration

```yaml
compression:
  enabled: true
  default_algorithm: gzip
  algorithms:
    gzip:
      level: 6
      min_size_bytes: 1024
      content_types:
        - application/json
        - application/x-yaml
    brotli:
      level: 4
      min_size_bytes: 512
      content_types:
        - application/json
        - application/x-yaml
        - application/x-protobuf
    lz4:
      level: default
      min_size_bytes: 2048
      content_types:
        - application/x-msgpack
        - application/x-protobuf

  auto_select: true
  threshold_bytes: 1024
```

### Compressed Payload Structure

```json
{
  "compressed_payload": {
    "algorithm": "gzip",
    "original_size": 2847,
    "compressed_size": 1023,
    "compression_ratio": 0.36,
    "checksum": "crc32:abcdef12",
    "data": "<base64-encoded-compressed-bytes>"
  }
}
```

### Size Thresholds by Domain File Complexity

| File Category | Avg Uncompressed | Recommended Algorithm |
|---------------|------------------|-----------------------|
| Recon (files 1-3) | 4.2 KB | gzip |
| Auth/Authz (files 4-5) | 5.8 KB | brotli |
| Injection (files 25-28, 36, 42) | 7.1 KB | brotli |
| Config/Infra (files 17-18, 47-48) | 3.9 KB | gzip |
| Reporting (files 20, 50) | 6.3 KB | brotli |
| Extended (files 43-50) | 5.5 KB | gzip |

---

## Type Preservation

The serialization layer preserves all hunting-specific types across format boundaries.

### Type Registry

```yaml
type_registry:
  # Primitive Types
  severity_enum:
    type: enum
    values: [critical, high, medium, low, informational]
    json_type: string
    protobuf_type: enum

  cvss_score:
    type: float
    precision: 1
    range: [0.0, 10.0]
    json_type: number
    protobuf_type: float

  # Complex Types
  finding_id:
    type: string
    pattern: "FINDING-\\d{4}-\\d{4}-\\d{3}"
    json_type: string
    protobuf_type: string

  domain_file_id:
    type: integer
    range: [1, 50]
    json_type: integer
    protobuf_type: uint32

  timestamp:
    type: datetime
    format: "ISO8601"
    json_type: string
    protobuf_type: string

  evidence_blob:
    type: binary
    encoding: base64
    json_type: string
    protobuf_type: bytes

  # Domain-Specific Types
  hunting_phase:
    type: enum
    values: [recon, discovery, analysis, exploitation, reporting]
    json_type: string
    protobuf_type: enum

  detection_method:
    type: enum
    values: [automated, manual, hybrid, passive, active]
    json_type: string
    protobuf_type: enum

  cross_reference:
    type: object
    fields:
      source_file_id: domain_file_id
      target_file_id: domain_file_id
      relationship_type: string
      description: string
      combined_cvss: cvss_score
```

### Type Coercion Rules

When deserializing across formats, the following coercion rules apply:

| Source Format | Target Format | Coercion |
|---------------|---------------|----------|
| JSON number → YAML | Preserve as-is | No change |
| YAML string "null" → JSON | Convert to JSON null | Explicit null |
| MessagePack timestamp → JSON | ISO8601 string | Auto-convert |
| Protobuf uint32 → JSON | JSON integer | Direct mapping |
| Protobuf bytes → JSON | Base64 string | Auto-encode |
| JSON array → Protobuf repeated | Unwrap to repeated field | Direct mapping |

---

## Custom Serializers

### Domain File Serializer Registry

```python
SERIALIZER_REGISTRY = {
    # Reconnaissance Domain Files
    "recon": {
        "file_ids": [1],
        "serializer": ReconDomainSerializer,
        "custom_fields": ["subdomains", "ports", "technologies", "dns_records"],
        "nested_types": ["AssetNode", "PortScanResult", "TechFingerprint"]
    },
    "js_analysis": {
        "file_ids": [2],
        "serializer": JSAnalysisSerializer,
        "custom_fields": ["obfuscation_patterns", "deobfuscated_output", "api_endpoints"],
        "nested_types": ["ObfuscationLayer", "EndpointList"]
    },
    "api_analysis": {
        "file_ids": [3],
        "serializer": APIAnalysisSerializer,
        "custom_fields": ["endpoints", "parameters", "auth_schemes", "rate_limits"],
        "nested_types": ["EndpointSpec", "ParameterMap"]
    },
    "auth_analysis": {
        "file_ids": [4, 37],
        "serializer": AuthAnalysisSerializer,
        "custom_fields": ["auth_flows", "session_tokens", "mfa_config", "session_fixation_vectors"],
        "nested_types": ["AuthFlow", "SessionConfig", "MFAFactor"]
    },
    "authz_analysis": {
        "file_ids": [5],
        "serializer": AuthzAnalysisSerializer,
        "custom_fields": ["permission_matrices", "role_hierarchies", "idor_vectors"],
        "nested_types": ["PermissionMatrix", "RoleHierarchy"]
    },
    "input_validation": {
        "file_ids": [6],
        "serializer": InputValidationSerializer,
        "custom_fields": ["sanitization_bypasses", "injection_vectors", "encoding_chains"],
        "nested_types": ["BypassVector", "InjectionChain"]
    },
    "business_logic": {
        "file_ids": [7],
        "serializer": BusinessLogicSerializer,
        "custom_fields": ["workflow_steps", "state_machines", "logic_flaws"],
        "nested_types": ["WorkflowStep", "StateMachine", "LogicFlaw"]
    },
    "client_storage": {
        "file_ids": [8],
        "serializer": ClientStorageSerializer,
        "custom_fields": ["cookies", "local_storage", "session_storage", "indexed_db"],
        "nested_types": ["CookieSpec", "StorageItem"]
    },
    "crypto_analysis": {
        "file_ids": [9],
        "serializer": CryptoAnalysisSerializer,
        "custom_fields": ["algorithms", "key_lengths", "weak_patterns", "certificate_chains"],
        "nested_types": ["CryptoAlgorithm", "CertificateChain"]
    },
    "error_analysis": {
        "file_ids": [10],
        "serializer": ErrorAnalysisSerializer,
        "custom_fields": ["error_patterns", "info_disclosure_vectors", "stack_traces"],
        "nested_types": ["ErrorPattern", "DisclosureVector"]
    },
    "file_upload": {
        "file_ids": [11, 38],
        "serializer": FileUploadSerializer,
        "custom_fields": ["upload_handlers", "bypass_techniques", "file_type_validations"],
        "nested_types": ["UploadHandler", "BypassTechnique"]
    },
    "ssrf": {
        "file_ids": [12],
        "serializer": SSRFSerializer,
        "custom_fields": ["target_urls", "filter_bypasses", "internal_services"],
        "nested_types": ["SSRFTarget", "FilterBypass"]
    },
    "csrf_analysis": {
        "file_ids": [13, 43],
        "serializer": CSRFSerializer,
        "custom_fields": ["token_locations", "origin_checks", "state_changing_params"],
        "nested_types": ["TokenLocation", "OriginCheck"]
    },
    "cors_analysis": {
        "file_ids": [14, 44],
        "serializer": CORSSerializer,
        "custom_fields": ["allowed_origins", "credential_modes", "bypass_vectors"],
        "nested_types": ["OriginConfig", "CORSCheck"]
    },
    "race_conditions": {
        "file_ids": [15, 45],
        "serializer": RaceConditionSerializer,
        "custom_fields": ["concurrent_endpoints", "timing_windows", "shared_resources"],
        "nested_types": ["ConcurrentEndpoint", "TimingWindow"]
    },
    "third_party": {
        "file_ids": [16, 46],
        "serializer": ThirdPartySerializer,
        "custom_fields": ["dependencies", "vulnerability_counts", "outdated_versions"],
        "nested_types": ["Dependency", "VulnerabilityEntry"]
    },
    "configuration": {
        "file_ids": [17, 47],
        "serializer": ConfigurationSerializer,
        "custom_fields": ["config_items", "misconfigurations", "hardening_gaps"],
        "nested_types": ["ConfigItem", "Misconfiguration"]
    },
    "network_infra": {
        "file_ids": [18, 48],
        "serializer": NetworkInfraSerializer,
        "custom_fields": ["open_ports", "services", "tls_config", "dns_records"],
        "nested_types": ["PortInfo", "ServiceFingerprint", "TLSConfig"]
    },
    "mobile_api": {
        "file_ids": [19, 49],
        "serializer": MobileAPISerializer,
        "custom_fields": ["api_endpoints", "mobile_configs", "ssl_pinning", "binary_analysis"],
        "nested_types": ["MobileConfig", "BinaryAnalysis"]
    },
    "reporting": {
        "file_ids": [20, 50],
        "serializer": ReportingSerializer,
        "custom_fields": ["report_templates", "poc_templates", "submission_checklists"],
        "nested_types": ["ReportTemplate", "POCTemplate"]
    },
    "waf_bypass": {
        "file_ids": [21],
        "serializer": WAFBypassSerializer,
        "custom_fields": ["waf_signatures", "bypass_payloads", "detection_evasion"],
        "nested_types": ["WAFSignature", "BypassPayload"]
    },
    "http_smuggling": {
        "file_ids": [22],
        "serializer": HTTPSmugglingSerializer,
        "custom_fields": ["smuggling_vectors", "header_anomalies", "backend_behaviors"],
        "nested_types": ["SmugglingVector", "HeaderAnomaly"]
    },
    "subdomain_takeover": {
        "file_ids": [23],
        "serializer": SubdomainTakeoverSerializer,
        "custom_fields": ["dangling_cnames", "unclaimed_services", "detection_signatures"],
        "nested_types": ["DanglingCNAME", "UnclaimedService"]
    },
    "host_header": {
        "file_ids": [24],
        "serializer": HostHeaderSerializer,
        "custom_fields": ["injection_points", "cache_poison_vectors", "password_reset_targets"],
        "nested_types": ["InjectionPoint", "CachePoisonVector"]
    },
    "xxe": {
      "file_ids": [25],
      "serializer": XXESerializer,
      "custom_fields": ["xml_endpoints", "parser_configs", "exfil_channels"],
      "nested_types": ["XMLEndpoint", "ParserConfig"]
    },
    "deserialization": {
      "file_ids": [26],
      "serializer": DeserializationSerializer,
      "custom_fields": ["serialization_formats", "gadget_chains", "rce_vectors"],
      "nested_types": ["SerializationFormat", "GadgetChain"]
    },
    "command_injection": {
      "file_ids": [27],
      "serializer": CommandInjectionSerializer,
      "custom_fields": ["injection_points", "shell_metacharacters", "blind_techniques"],
      "nested_types": ["InjectionPoint", "ShellMetachar"]
    },
    "nosql": {
      "file_ids": [28],
      "serializer": NoSQLSerializer,
      "custom_fields": ["query_operators", "injection_payloads", "database_types"],
      "nested_types": ["QueryOperator", "InjectionPayload"]
    },
    "graphql": {
      "file_ids": [29],
      "serializer": GraphQLSerializer,
      "custom_fields": ["schema_introspection", "query_complexity", "auth_bypass_vectors"],
      "nested_types": ["SchemaInfo", "QueryComplexity"]
    },
    "websocket": {
      "file_ids": [30],
      "serializer": WebSocketSerializer,
      "custom_fields": ["ws_endpoints", "message_formats", "auth_mechanisms"],
      "nested_types": ["WSEndpoint", "MessageFormat"]
    },
    "ssti": {
      "file_ids": [31],
      "serializer": SSTISerializer,
      "custom_fields": ["template_engines", "injection_syntax", "rce_payloads"],
      "nested_types": ["TemplateEngine", "InjectionSyntax"]
    },
    "jwt": {
      "file_ids": [32],
      "serializer": JWTSerializer,
      "custom_fields": ["token_structures", "algorithm_confusion", "key_material"],
      "nested_types": ["TokenStructure", "AlgorithmConfusion"]
    },
    "csp": {
      "file_ids": [33],
      "serializer": CSPSerializer,
      "custom_fields": ["csp_policies", "bypass_techniques", "report_uris"],
      "nested_types": ["CSPPolicy", "BypassTechnique"]
    },
    "clickjacking": {
      "file_ids": [34],
      "serializer": ClickjackingSerializer,
      "custom_fields": ["framing_endpoints", "xfo_headers", "ui_redressing_vectors"],
      "nested_types": ["FramingEndpoint", "UIRedressingVector"]
    },
    "hpp": {
      "file_ids": [35],
      "serializer": HPPSerializer,
      "custom_fields": ["parameter_positions", "pollution_vectors", "backend_behaviors"],
      "nested_types": ["ParameterPosition", "PollutionVector"]
    },
    "ldap": {
      "file_ids": [36],
      "serializer": LDAPSerializer,
      "custom_fields": ["ldap_endpoints", "filter_syntax", "injection_payloads"],
      "nested_types": ["LDAPEndpoint", "FilterSyntax"]
    },
    "xpath": {
      "file_ids": [42],
      "serializer": XPathSerializer,
      "custom_fields": ["xpath_endpoints", "query_syntax", "injection_techniques"],
      "nested_types": ["XPathEndpoint", "QuerySyntax"]
    },
    "xssi": {
      "file_ids": [39],
      "serializer": XSSISerializer,
      "custom_fields": ["inclusion_endpoints", "json_hijacking", "script_tag_vectors"],
      "nested_types": ["InclusionEndpoint", "JSONHijackingVector"]
    },
    "prototype_pollution": {
      "file_ids": [40],
      "serializer": PrototypePollutionSerializer,
      "custom_fields": ["pollution_vectors", "sink_functions", "object_mergers"],
      "nested_types": ["PollutionVector", "SinkFunction"]
    },
    "response_splitting": {
      "file_ids": [41],
      "serializer": ResponseSplittingSerializer,
      "custom_fields": ["injection_headers", "response_manipulation", "cache_impact"],
      "nested_types": ["InjectionHeader", "ResponseManipulation"]
    }
}
```

### Custom Serializer Interface

```python
class DomainSerializer:
    """Base interface for all domain-specific serializers."""

    def serialize(self, domain_object: DomainObject, format: str) -> bytes:
        """Serialize domain object to target format."""
        raise NotImplementedError

    def deserialize(self, data: bytes, format: str) -> DomainObject:
        """Deserialize bytes to domain object."""
        raise NotImplementedError

    def validate(self, data: dict) -> ValidationResult:
        """Validate serialized data against domain schema."""
        raise NotImplementedError

    def get_custom_fields(self) -> list[str]:
        """Return list of domain-specific custom fields."""
        raise NotImplementedError

    def get_nested_types(self) -> list[str]:
        """Return list of nested type definitions."""
        raise NotImplementedError
```

---

## Format Detection

### Auto-Detection Algorithm

```python
def detect_format(data: bytes) -> str:
    """
    Auto-detect serialization format from raw bytes.

    Detection order:
    1. Magic bytes / signatures
    2. Structural heuristics
    3. Fallback to content analysis
    """
    if len(data) < 4:
        raise FormatDetectionError("Data too short for format detection")

    # Check magic bytes
    if data[:3] == b'\x1f\x8b\x08':  # gzip compressed
        return detect_compressed_format(data)
    if data[0:4] == b'\x89\x48\x53\x4d':  # MessagePack
        return "messagepack"
    if data[0:2] == b'\x0a':  # Protobuf
        return "protobuf"

    # Structural heuristics
    try:
        json.loads(data.decode("utf-8"))
        return "json"
    except (json.JSONDecodeError, UnicodeDecodeError):
        pass

    try:
        yaml.safe_load(data.decode("utf-8"))
        return "yaml"
    except (yaml.YAMLError, UnicodeDecodeError):
        pass

    raise FormatDetectionError("Unable to detect serialization format")
```

### Format Signature Table

| Format | Magic Bytes | ASCII Signature | Hex Pattern |
|--------|-------------|-----------------|-------------|
| JSON | `{` or `[` | First non-whitespace char | `7B` or `5B` |
| YAML | `-` or `{` | Document start marker | `2D` or `7B` |
| MessagePack | Variable | Bin/Str/FixMap prefix | `C0-DF, A0-BF` |
| Protobuf | Field tag | Varint-encoded tag | `08-FF` |
| Gzip | `\x1f\x8b` | Compressed header | `1F 8B 08` |
| Brotli | `\xce\xb2\xcf\x81` | Brotli stream | `CE B2 CF 81` |
| LZ4 | `\x04\x22\x4d\x18` | LZ4 frame | `04 22 4D 18` |

---

## Batch Operations

### Batch Serialize All Domain Files

```python
def batch_serialize_all(format: str = "json", compress: bool = True) -> BatchResult:
    """
    Serialize all 50 domain files in a single batch operation.

    Returns:
        BatchResult with individual file statuses and aggregate metrics
    """
    results = []
    for file_id in range(1, 51):
        try:
            data = serialize_domain_file(file_id, format)
            if compress and len(data) > THRESHOLD_BYTES:
                data = compress_data(data)
            results.append(BatchItemResult(
                file_id=file_id,
                filename=DOMAIN_FILES[file_id],
                status="success",
                size=len(data),
                checksum=compute_checksum(data)
            ))
        except Exception as e:
            results.append(BatchItemResult(
                file_id=file_id,
                filename=DOMAIN_FILES[file_id],
                status="failed",
                error=str(e)
            ))

    return BatchResult(
        total=50,
        succeeded=sum(1 for r in results if r.status == "success"),
        failed=sum(1 for r in results if r.status == "failed"),
        total_bytes=sum(r.size for r in results if r.status == "success"),
        items=results
    )
```

### Batch Deserialize

```python
def batch_deserialize(data_map: dict[int, bytes], format: str = "json") -> dict[int, DomainFile]:
    """
    Deserialize multiple domain files from a map of file_id → serialized bytes.
    """
    results = {}
    errors = {}

    for file_id, data in data_map.items():
        try:
            results[file_id] = deserialize_domain_file(data, format)
        except Exception as e:
            errors[file_id] = str(e)

    if errors:
        raise BatchDeserializationError(
            f"Failed to deserialize {len(errors)} files",
            errors=errors,
            partial_results=results
        )

    return results
```

### Batch Finding Serialization

```python
def batch_serialize_findings(findings: list[Finding], format: str = "json") -> bytes:
    """
    Serialize multiple findings into a single batch payload.
    """
    batch = {
        "batch": {
            "type": "findings",
            "count": len(findings),
            "format_version": "2.1",
            "created_at": datetime.utcnow().isoformat(),
            "checksum": None  # Computed after serialization
        },
        "findings": [json.loads(serialize_finding(f, "json")) for f in findings]
    }

    result = serialize_to_format(batch, format)
    batch["batch"]["checksum"] = compute_checksum(result)
    return serialize_to_format(batch, format)
```

---

## Registry Schema

### Complete Domain File Registry

```yaml
domain_registry:
  version: "2.1"
  domain: "core-prompts-hunting"
  total_files: 50
  last_indexed: "2026-06-26T00:00:00Z"

  files:
    - id: 1
      filename: "1-Reconnaissance-and-Asset-Discovery.md"
      domain_key: "recon"
      category: "reconnaissance"
      severity_focus: ["info", "low"]
      prerequisite_files: []
      dependent_files: [12, 18, 23]
      tags: ["recon", "subdomain", "port-scan", "fingerprint"]
      estimated_size_kb: 4.2

    - id: 2
      filename: "2-JavaScript-Analysis-and-Deobfuscation.md"
      domain_key: "js_analysis"
      category: "code-analysis"
      severity_focus: ["medium", "high"]
      prerequisite_files: [1]
      dependent_files: [3, 29, 40]
      tags: ["javascript", "deobfuscation", "static-analysis"]
      estimated_size_kb: 5.1

    - id: 3
      filename: "3-API-Endpoint-Analysis.md"
      domain_key: "api_analysis"
      category: "api-security"
      severity_focus: ["medium", "high", "critical"]
      prerequisite_files: [1, 2]
      dependent_files: [4, 5, 19]
      tags: ["api", "endpoints", "rest", "graphql"]
      estimated_size_kb: 6.3

    - id: 4
      filename: "4-Authentication-and-Session-Management.md"
      domain_key: "auth_analysis"
      category: "authentication"
      severity_focus: ["high", "critical"]
      prerequisite_files: [3]
      dependent_files: [5, 37]
      tags: ["authentication", "session", "login", "mfa"]
      estimated_size_kb: 5.8

    - id: 5
      filename: "5-Authorization-and-Access-Control.md"
      domain_key: "authz_analysis"
      category: "authorization"
      severity_focus: ["high", "critical"]
      prerequisite_files: [4]
      dependent_files: [7, 37]
      tags: ["authorization", "idor", "access-control", "rbac"]
      estimated_size_kb: 5.4

    - id: 6
      filename: "6-Input-Validation-and-Sanitization.md"
      domain_key: "input_validation"
      category: "input-handling"
      severity_focus: ["medium", "high", "critical"]
      prerequisite_files: []
      dependent_files: [27, 28, 31, 36, 42]
      tags: ["input-validation", "sanitization", "encoding"]
      estimated_size_kb: 4.8

    - id: 7
      filename: "7-Business-Logic-Flaws.md"
      domain_key: "business_logic"
      category: "business-logic"
      severity_focus: ["medium", "high"]
      prerequisite_files: [3, 4, 5]
      dependent_files: [15]
      tags: ["business-logic", "workflow", "state-machine"]
      estimated_size_kb: 6.7

    - id: 8
      filename: "8-Client-Side-Storage-Security.md"
      domain_key: "client_storage"
      category: "client-side"
      severity_focus: ["medium", "low"]
      prerequisite_files: []
      dependent_files: [32, 33]
      tags: ["cookies", "localstorage", "sessionstorage"]
      estimated_size_kb: 3.2

    - id: 9
      filename: "9-Cryptography-and-Data-Protection.md"
      domain_key: "crypto_analysis"
      category: "cryptographic"
      severity_focus: ["high", "critical"]
      prerequisite_files: []
      dependent_files: [4, 32]
      tags: ["cryptography", "encryption", "hashing", "tls"]
      estimated_size_kb: 5.5

    - id: 10
      filename: "10-Error-Handling-and-Information-Disclosure.md"
      domain_key: "error_analysis"
      category: "information-disclosure"
      severity_focus: ["low", "medium"]
      prerequisite_files: []
      dependent_files: [17, 47]
      tags: ["errors", "information-disclosure", "stack-traces"]
      estimated_size_kb: 3.8

    - id: 11
      filename: "11-File-Upload-and-Processing.md"
      domain_key: "file_upload"
      category: "file-handling"
      severity_focus: ["high", "critical"]
      prerequisite_files: []
      dependent_files: [38]
      tags: ["file-upload", "webshell", "file-inclusion"]
      estimated_size_kb: 5.2

    - id: 12
      filename: "12-Server-Side-Request-Forgery-SSRF.md"
      domain_key: "ssrf"
      category: "ssrf"
      severity_focus: ["high", "critical"]
      prerequisite_files: [1, 3]
      dependent_files: [18, 48]
      tags: ["ssrf", "internal-network", "cloud-metadata"]
      estimated_size_kb: 6.1

    - id: 13
      filename: "13-Cross-Site-Request-Forgery-CSRF.md"
      domain_key: "csrf_analysis"
      category: "csrf"
      severity_focus: ["medium", "high"]
      prerequisite_files: [4]
      dependent_files: [14, 43]
      tags: ["csrf", "tokens", "origin-checks"]
      estimated_size_kb: 4.5

    - id: 14
      filename: "14-Cross-Origin-Resource-Sharing-CORS.md"
      domain_key: "cors_analysis"
      category: "cors"
      severity_focus: ["medium", "high"]
      prerequisite_files: []
      dependent_files: [33, 44]
      tags: ["cors", "origin", "credentials", "preflight"]
      estimated_size_kb: 4.1

    - id: 15
      filename: "15-Race-Conditions-and-Concurrency-Issues.md"
      domain_key: "race_conditions"
      category: "concurrency"
      severity_focus: ["medium", "high"]
      prerequisite_files: [7]
      dependent_files: [45]
      tags: ["race-condition", "concurrency", "timing"]
      estimated_size_kb: 4.9

    - id: 16
      filename: "16-Third-Party-Component-Analysis.md"
      domain_key: "third_party"
      category: "supply-chain"
      severity_focus: ["medium", "high", "critical"]
      prerequisite_files: [2]
      dependent_files: [46]
      tags: ["dependencies", "supply-chain", "cve"]
      estimated_size_kb: 4.3

    - id: 17
      filename: "17-Configuration-and-Misconfiguration-Hunting.md"
      domain_key: "configuration"
      category: "configuration"
      severity_focus: ["low", "medium", "high"]
      prerequisite_files: []
      dependent_files: [47]
      tags: ["configuration", "hardening", "defaults"]
      estimated_size_kb: 3.9

    - id: 18
      filename: "18-Network-and-Infrastructure-Security.md"
      domain_key: "network_infra"
      category: "infrastructure"
      severity_focus: ["medium", "high"]
      prerequisite_files: [1]
      dependent_files: [48]
      tags: ["network", "infrastructure", "dns", "tls"]
      estimated_size_kb: 4.7

    - id: 19
      filename: "19-Mobile-and-API-Specific-Vulnerabilities.md"
      domain_key: "mobile_api"
      category: "mobile-security"
      severity_focus: ["high", "critical"]
      prerequisite_files: [3]
      dependent_files: [49]
      tags: ["mobile", "android", "ios", "api"]
      estimated_size_kb: 5.9

    - id: 20
      filename: "20-Reporting-and-Proof-of-Concept-Development.md"
      domain_key: "reporting"
      category: "reporting"
      severity_focus: ["info", "low", "medium", "high", "critical"]
      prerequisite_files: []
      dependent_files: [50]
      tags: ["reporting", "poc", "writeup", "submission"]
      estimated_size_kb: 6.3

    - id: 21
      filename: "21-Web-Application-Firewall-WAF-Bypass.md"
      domain_key: "waf_bypass"
      category: "waf-bypass"
      severity_focus: ["medium", "high"]
      prerequisite_files: [6]
      dependent_files: [22, 25, 27]
      tags: ["waf", "bypass", "evasion", "filtering"]
      estimated_size_kb: 5.6

    - id: 22
      filename: "22-HTTP-Request-Smuggling.md"
      domain_key: "http_smuggling"
      category: "http-smuggling"
      severity_focus: ["high", "critical"]
      prerequisite_files: [1, 18]
      dependent_files: []
      tags: ["smuggling", "cl-te", "te-cl", "h2"]
      estimated_size_kb: 5.3

    - id: 23
      filename: "23-Subdomain-Takeover.md"
      domain_key: "subdomain_takeover"
      category: "subdomain"
      severity_focus: ["high", "critical"]
      prerequisite_files: [1]
      dependent_files: []
      tags: ["subdomain", "takeover", "dangling", "cname"]
      estimated_size_kb: 4.4

    - id: 24
      filename: "24-Host-Header-Injection.md"
      domain_key: "host_header"
      category: "host-header"
      severity_focus: ["medium", "high"]
      prerequisite_files: []
      dependent_files: [13]
      tags: ["host-header", "injection", "cache-poison", "password-reset"]
      estimated_size_kb: 3.6

    - id: 25
      filename: "25-XML-External-Entity-XXE-Injection.md"
      domain_key: "xxe"
      category: "xxe"
      severity_focus: ["high", "critical"]
      prerequisite_files: [6]
      dependent_files: [12]
      tags: ["xxe", "xml", "external-entity", "ssrf"]
      estimated_size_kb: 4.8

    - id: 26
      filename: "26-Insecure-Deserialization.md"
      domain_key: "deserialization"
      category: "deserialization"
      severity_focus: ["critical"]
      prerequisite_files: []
      dependent_files: [27]
      tags: ["deserialization", "rce", "gadget-chain", "java"]
      estimated_size_kb: 5.7

    - id: 27
      filename: "27-Command-Injection.md"
      domain_key: "command_injection"
      category: "command-injection"
      severity_focus: ["critical"]
      prerequisite_files: [6]
      dependent_files: []
      tags: ["command-injection", "rce", "shell", "blind"]
      estimated_size_kb: 5.1

    - id: 28
      filename: "28-NoSQL-Injection.md"
      domain_key: "nosql"
      category: "nosql"
      severity_focus: ["high", "critical"]
      prerequisite_files: [6]
      dependent_files: []
      tags: ["nosql", "mongodb", "operator-injection"]
      estimated_size_kb: 4.6

    - id: 29
      filename: "29-GraphQL-Vulnerabilities.md"
      domain_key: "graphql"
      category: "graphql"
      severity_focus: ["medium", "high"]
      prerequisite_files: [3]
      dependent_files: []
      tags: ["graphql", "introspection", "batching", "dos"]
      estimated_size_kb: 5.4

    - id: 30
      filename: "30-WebSocket-Security.md"
      domain_key: "websocket"
      category: "websocket"
      severity_focus: ["medium", "high"]
      prerequisite_files: [3]
      dependent_files: []
      tags: ["websocket", "real-time", "message-injection"]
      estimated_size_kb: 4.0

    - id: 31
      filename: "31-Server-Side-Template-Injection.md"
      domain_key: "ssti"
      category: "ssti"
      severity_focus: ["critical"]
      prerequisite_files: [6]
      dependent_files: [27]
      tags: ["ssti", "template", "rce", "jinja2", "twig"]
      estimated_size_kb: 5.8

    - id: 32
      filename: "32-JSON-Web-Token-JWT-Vulnerabilities.md"
      domain_key: "jwt"
      category: "jwt"
      severity_focus: ["high", "critical"]
      prerequisite_files: [4, 9]
      dependent_files: []
      tags: ["jwt", "token", "algorithm-confusion", "key-rotation"]
      estimated_size_kb: 5.2

    - id: 33
      filename: "33-Content-Security-Policy-CSP-Bypass.md"
      domain_key: "csp"
      category: "csp"
      severity_focus: ["medium", "high"]
      prerequisite_files: [14]
      dependent_files: []
      tags: ["csp", "bypass", "xss", "report-uri"]
      estimated_size_kb: 4.7

    - id: 34
      filename: "34-Clickjacking-and-UI-Redressing.md"
      domain_key: "clickjacking"
      category: "clickjacking"
      severity_focus: ["medium"]
      prerequisite_files: []
      dependent_files: []
      tags: ["clickjacking", "framing", "xfo", "ui-redressing"]
      estimated_size_kb: 3.4

    - id: 35
      filename: "35-HTTP-Parameter-Pollution.md"
      domain_key: "hpp"
      category: "hpp"
      severity_focus: ["medium", "high"]
      prerequisite_files: [6]
      dependent_files: [13]
      tags: ["hpp", "parameter-pollution", "parameter-smuggling"]
      estimated_size_kb: 3.7

    - id: 36
      filename: "36-LDAP-Injection.md"
      domain_key: "ldap"
      category: "ldap"
      severity_focus: ["high", "critical"]
      prerequisite_files: [6]
      dependent_files: []
      tags: ["ldap", "injection", "directory", "authentication-bypass"]
      estimated_size_kb: 4.2

    - id: 37
      filename: "37-Session-Puzzling-and-Fixation.md"
      domain_key: "puzzling"
      category: "session"
      severity_focus: ["high"]
      prerequisite_files: [4]
      dependent_files: []
      tags: ["session", "puzzling", "fixation", "hijacking"]
      estimated_size_kb: 4.5

    - id: 38
      filename: "38-Insecure-File-Handling.md"
      domain_key: "filehandle"
      category: "file-security"
      severity_focus: ["high", "critical"]
      prerequisite_files: [11]
      dependent_files: []
      tags: ["file-handling", "path-traversal", "symlink", "race"]
      estimated_size_kb: 4.3

    - id: 39
      filename: "39-Cross-Site-Script-Inclusion-XSSI.md"
      domain_key: "xssi"
      category: "xssi"
      severity_focus: ["medium"]
      prerequisite_files: [14]
      dependent_files: []
      tags: ["xssi", "json-hijacking", "script-inclusion"]
      estimated_size_kb: 3.1

    - id: 40
      filename: "40-Prototype-Pollution.md"
      domain_key: "proto"
      category: "prototype"
      severity_focus: ["high", "critical"]
      prerequisite_files: [2]
      dependent_files: [27]
      tags: ["prototype-pollution", "javascript", "rce", "xss"]
      estimated_size_kb: 5.0

    - id: 41
      filename: "41-HTTP-Response-Splitting.md"
      domain_key: "splitting"
      category: "response-splitting"
      severity_focus: ["medium", "high"]
      prerequisite_files: []
      dependent_files: [13]
      tags: ["response-splitting", "header-injection", "crlf"]
      estimated_size_kb: 3.5

    - id: 42
      filename: "42-XPath-Injection.md"
      domain_key: "xpath"
      category: "xpath"
      severity_focus: ["high", "critical"]
      prerequisite_files: [6]
      dependent_files: []
      tags: ["xpath", "injection", "xml", "authentication-bypass"]
      estimated_size_kb: 4.0

    - id: 43
      filename: "43-Cross-Site-Request-Forgery-CSRF.md"
      domain_key: "csrf2"
      category: "csrf-extended"
      severity_focus: ["medium", "high"]
      prerequisite_files: [13]
      dependent_files: []
      tags: ["csrf", "advanced", "tokenless", "method-based"]
      estimated_size_kb: 5.0

    - id: 44
      filename: "44-Cross-Origin-Resource-Sharing-CORS.md"
      domain_key: "cors2"
      category: "cors-extended"
      severity_focus: ["medium", "high"]
      prerequisite_files: [14]
      dependent_files: []
      tags: ["cors", "advanced", "null-origin", "regex-bypass"]
      estimated_size_kb: 4.6

    - id: 45
      filename: "45-Race-Conditions-and-Concurrency-Issues.md"
      domain_key: "race2"
      category: "concurrency-extended"
      severity_focus: ["medium", "high"]
      prerequisite_files: [15]
      dependent_files: []
      tags: ["race-condition", "advanced", "toctou", "double-spending"]
      estimated_size_kb: 5.3

    - id: 46
      filename: "46-Third-Party-Component-Analysis.md"
      domain_key: "thirdparty2"
      category: "supply-chain-extended"
      severity_focus: ["medium", "high", "critical"]
      prerequisite_files: [16]
      dependent_files: []
      tags: ["supply-chain", "advanced", "typosquatting", "dependency-confusion"]
      estimated_size_kb: 4.8

    - id: 47
      filename: "47-Configuration-and-Misconfiguration-Hunting.md"
      domain_key: "config2"
      category: "configuration-extended"
      severity_focus: ["low", "medium", "high"]
      prerequisite_files: [17]
      dependent_files: []
      tags: ["configuration", "advanced", "hardening", "audit"]
      estimated_size_kb: 4.4

    - id: 48
      filename: "48-Network-and-Infrastructure-Security.md"
      domain_key: "network2"
      category: "infrastructure-extended"
      severity_focus: ["medium", "high"]
      prerequisite_files: [18]
      dependent_files: []
      tags: ["network", "advanced", "lateral-movement", "pivot"]
      estimated_size_kb: 5.1

    - id: 49
      filename: "49-Mobile-and-API-Specific-Vulnerabilities.md"
      domain_key: "mobile2"
      category: "mobile-security-extended"
      severity_focus: ["high", "critical"]
      prerequisite_files: [19]
      dependent_files: []
      tags: ["mobile", "advanced", "apkid", "frida", "ssl-pinning"]
      estimated_size_kb: 6.2

    - id: 50
      filename: "50-Reporting-and-Proof-of-Concept-Development.md"
      domain_key: "report2"
      category: "reporting-extended"
      severity_focus: ["info", "low", "medium", "high", "critical"]
      prerequisite_files: [20]
      dependent_files: []
      tags: ["reporting", "advanced", "chaining", "escalation"]
      estimated_size_kb: 7.1
```

---

## Error Handling

### Serialization Error Taxonomy

```yaml
serialization_errors:
  format_errors:
    UnsupportedFormatError:
      description: "Target format not in supported list"
      recoverable: false
      fallback: "serialize_to_json"

    FormatDetectionError:
      description: "Unable to auto-detect input format"
      recoverable: true
      fallback: "prompt_user_for_format"

    EncodingError:
      description: "Character encoding mismatch"
      recoverable: true
      fallback: "force_utf8"

  schema_errors:
    SchemaValidationError:
      description: "Data does not match expected schema"
      recoverable: false
      fallback: "log_and_skip"

    MissingRequiredFieldError:
      description: "Required field absent from payload"
      recoverable: true
      fallback: "use_default_value"

    TypeCoercionError:
      description: "Type cannot be coerced between formats"
      recoverable: true
      fallback: "string_representation"

  compression_errors:
    CompressionError:
      description: "Compression algorithm failed"
      recoverable: true
      fallback: "store_uncompressed"

    DecompressionError:
      description: "Decompression failed or data corrupted"
      recoverable: false
      fallback: "attempt_alternative_algorithm"

  integrity_errors:
    ChecksumMismatchError:
      description: "Data integrity check failed"
      recoverable: false
      fallback: "request_retransmission"

    HashMismatchError:
      description: "Content hash does not match expected"
      recoverable: false
      fallback: "flag_for_review"

  batch_errors:
    BatchPartialFailureError:
      description: "Some items in batch failed serialization"
      recoverable: true
      fallback: "return_partial_results"

    BatchTimeoutError:
      description: "Batch operation exceeded time limit"
      recoverable: true
      fallback: "reduce_batch_size"
```

### Error Response Format

```json
{
  "error": {
    "code": "SERIALIZATION_SCHEMA_VALIDATION_ERROR",
    "message": "Field 'severity' contains invalid value 'urgent'",
    "domain_file_id": 7,
    "domain_file_name": "7-Business-Logic-Flaws.md",
    "field_path": "finding.severity",
    "provided_value": "urgent",
    "allowed_values": ["critical", "high", "medium", "low", "informational"],
    "recovery_suggestion": "Use one of the allowed severity values",
    "recoverable": false,
    "timestamp": "2026-06-26T12:00:00Z",
    "trace_id": "trace_abc123"
  }
}
```

### Retry Configuration

```yaml
retry_policy:
  max_retries: 3
  retryable_errors:
    - EncodingError
    - CompressionError
    - BatchTimeoutError
    - BatchPartialFailureError
  backoff:
    strategy: exponential
    initial_delay_ms: 100
    max_delay_ms: 5000
    multiplier: 2.0
  circuit_breaker:
    enabled: true
    failure_threshold: 5
    recovery_timeout_s: 30
```

---

## Pipeline Integration

### Serialization Pipeline Stages

```yaml
pipeline:
  name: "hunting-serialization-pipeline"
  version: "2.1"

  stages:
    - name: "input-validation"
      description: "Validate incoming data against domain schemas"
      handler: "validate_input_stage"
      error_action: "reject"
      timeout_ms: 5000

    - name: "format-normalization"
      description: "Normalize input to canonical internal format"
      handler: "normalize_format_stage"
      error_action: "fallback_to_json"
      timeout_ms: 2000

    - name: "type-resolution"
      description: "Resolve custom types and apply coercion rules"
      handler: "resolve_types_stage"
      error_action: "string_fallback"
      timeout_ms: 1000

    - name: "enrichment"
      description: "Add computed fields (hashes, timestamps, metadata)"
      handler: "enrich_payload_stage"
      error_action: "skip_enrichment"
      timeout_ms: 500

    - name: "serialization"
      description: "Serialize to target format"
      handler: "serialize_payload_stage"
      error_action: "fail"
      timeout_ms: 5000

    - name: "compression"
      description: "Apply compression if size exceeds threshold"
      handler: "compress_payload_stage"
      error_action: "store_raw"
      timeout_ms: 2000

    - name: "checksum"
      description: "Compute and attach integrity checksum"
      handler: "compute_checksum_stage"
      error_action: "fail"
      timeout_ms: 500

    - name: "output"
      description: "Write serialized payload to destination"
      handler: "write_output_stage"
      error_action: "retry"
      timeout_ms: 10000
```

### Pipeline Hooks

```yaml
hooks:
  pre_serialize:
    - "log_serialization_start"
    - "validate_domain_file_exists"
    - "check_format_compatibility"

  post_serialize:
    - "log_serialization_complete"
    - "update_metrics"
    - "notify_pipeline_monitor"

  pre_deserialize:
    - "validate_checksum"
    - "detect_format"
    - "check_schema_version"

  post_deserialize:
    - "validate_domain_object"
    - "log_deserialization_complete"
    - "update_session_state"

  on_error:
    - "log_error_details"
    - "emit_error_metric"
    - "trigger_retry_if_recoverable"
    - "notify_on_critical_failure"
```

### Domain File Loading Order

The pipeline loads domain files in dependency order to ensure all cross-references are resolved:

```yaml
loading_order:
  phase_1_foundational:
    - 6    # Input Validation (base for injection classes)
    - 1    # Reconnaissance (base for discovery)
    - 9    # Cryptography (base for auth)
    - 17   # Configuration (base for hardening)
    - 18   # Network Infrastructure (base for network)

  phase_2_core:
    - 2    # JavaScript Analysis
    - 3    # API Endpoint Analysis
    - 4    # Authentication
    - 5    # Authorization
    - 7    # Business Logic
    - 8    # Client-Side Storage
    - 10   # Error Handling
    - 11   # File Upload

  phase_3_vulnerability_classes:
    - 12   # SSRF
    - 13   # CSRF
    - 14   # CORS
    - 15   # Race Conditions
    - 16   # Third-Party Components
    - 19   # Mobile & API
    - 21   # WAF Bypass
    - 22   # HTTP Smuggling
    - 23   # Subdomain Takeover
    - 24   # Host Header Injection
    - 25   # XXE
    - 26   # Insecure Deserialization
    - 27   # Command Injection
    - 28   # NoSQL Injection
    - 29   # GraphQL
    - 30   # WebSocket
    - 31   # SSTI
    - 32   # JWT
    - 33   # CSP Bypass
    - 34   # Clickjacking
    - 35   # HPP
    - 36   # LDAP Injection
    - 37   # Session Puzzling
    - 38   # Insecure File Handling
    - 39   # XSSI
    - 40   # Prototype Pollution
    - 41   # Response Splitting
    - 42   # XPath Injection

  phase_4_extended:
    - 43   # CSRF Extended
    - 44   # CORS Extended
    - 45   # Race Conditions Extended
    - 46   # Third-Party Extended
    - 47   # Configuration Extended
    - 48   # Network Extended
    - 49   # Mobile Extended

  phase_5_output:
    - 20   # Reporting
    - 50   # Reporting Extended
```

---

## Full Domain File References

### Complete File Index

| # | Filename | Domain Key | Category | Serialized ID |
|---|----------|------------|----------|---------------|
| 1 | 1-Reconnaissance-and-Asset-Discovery.md | recon | reconnaissance | HUNT-001 |
| 2 | 2-JavaScript-Analysis-and-Deobfuscation.md | js_analysis | code-analysis | HUNT-002 |
| 3 | 3-API-Endpoint-Analysis.md | api_analysis | api-security | HUNT-003 |
| 4 | 4-Authentication-and-Session-Management.md | auth_analysis | authentication | HUNT-004 |
| 5 | 5-Authorization-and-Access-Control.md | authz_analysis | authorization | HUNT-005 |
| 6 | 6-Input-Validation-and-Sanitization.md | input_validation | input-handling | HUNT-006 |
| 7 | 7-Business-Logic-Flaws.md | business_logic | business-logic | HUNT-007 |
| 8 | 8-Client-Side-Storage-Security.md | client_storage | client-side | HUNT-008 |
| 9 | 9-Cryptography-and-Data-Protection.md | crypto_analysis | cryptographic | HUNT-009 |
| 10 | 10-Error-Handling-and-Information-Disclosure.md | error_analysis | information-disclosure | HUNT-010 |
| 11 | 11-File-Upload-and-Processing.md | file_upload | file-handling | HUNT-011 |
| 12 | 12-Server-Side-Request-Forgery-SSRF.md | ssrf | ssrf | HUNT-012 |
| 13 | 13-Cross-Site-Request-Forgery-CSRF.md | csrf_analysis | csrf | HUNT-013 |
| 14 | 14-Cross-Origin-Resource-Sharing-CORS.md | cors_analysis | cors | HUNT-014 |
| 15 | 15-Race-Conditions-and-Concurrency-Issues.md | race_conditions | concurrency | HUNT-015 |
| 16 | 16-Third-Party-Component-Analysis.md | third_party | supply-chain | HUNT-016 |
| 17 | 17-Configuration-and-Misconfiguration-Hunting.md | configuration | configuration | HUNT-017 |
| 18 | 18-Network-and-Infrastructure-Security.md | network_infra | infrastructure | HUNT-018 |
| 19 | 19-Mobile-and-API-Specific-Vulnerabilities.md | mobile_api | mobile-security | HUNT-019 |
| 20 | 20-Reporting-and-Proof-of-Concept-Development.md | reporting | reporting | HUNT-020 |
| 21 | 21-Web-Application-Firewall-WAF-Bypass.md | waf_bypass | waf-bypass | HUNT-021 |
| 22 | 22-HTTP-Request-Smuggling.md | http_smuggling | http-smuggling | HUNT-022 |
| 23 | 23-Subdomain-Takeover.md | subdomain_takeover | subdomain | HUNT-023 |
| 24 | 24-Host-Header-Injection.md | host_header | host-header | HUNT-024 |
| 25 | 25-XML-External-Entity-XXE-Injection.md | xxe | xxe | HUNT-025 |
| 26 | 26-Insecure-Deserialization.md | deser | deserialization | HUNT-026 |
| 27 | 27-Command-Injection.md | cmdi | command-injection | HUNT-027 |
| 28 | 28-NoSQL-Injection.md | nosql | nosql | HUNT-028 |
| 29 | 29-GraphQL-Vulnerabilities.md | gql | graphql | HUNT-029 |
| 30 | 30-WebSocket-Security.md | ws | websocket | HUNT-030 |
| 31 | 31-Server-Side-Template-Injection.md | ssti | ssti | HUNT-031 |
| 32 | 32-JSON-Web-Token-JWT-Vulnerabilities.md | jwt | jwt | HUNT-032 |
| 33 | 33-Content-Security-Policy-CSP-Bypass.md | csp | csp | HUNT-033 |
| 34 | 34-Clickjacking-and-UI-Redressing.md | clickjack | clickjacking | HUNT-034 |
| 35 | 35-HTTP-Parameter-Pollution.md | hpp | hpp | HUNT-035 |
| 36 | 36-LDAP-Injection.md | ldap | ldap | HUNT-036 |
| 37 | 37-Session-Puzzling-and-Fixation.md | puzzling | session | HUNT-037 |
| 38 | 38-Insecure-File-Handling.md | filehandle | file-security | HUNT-038 |
| 39 | 39-Cross-Site-Script-Inclusion-XSSI.md | xssi | xssi | HUNT-039 |
| 40 | 40-Prototype-Pollution.md | proto | prototype | HUNT-040 |
| 41 | 41-HTTP-Response-Splitting.md | splitting | response-splitting | HUNT-041 |
| 42 | 42-XPath-Injection.md | xpath | xpath | HUNT-042 |
| 43 | 43-Cross-Site-Request-Forgery-CSRF.md | csrf2 | csrf-extended | HUNT-043 |
| 44 | 44-Cross-Origin-Resource-Sharing-CORS.md | cors2 | cors-extended | HUNT-044 |
| 45 | 45-Race-Conditions-and-Concurrency-Issues.md | race2 | concurrency-extended | HUNT-045 |
| 46 | 46-Third-Party-Component-Analysis.md | thirdparty2 | supply-chain-extended | HUNT-046 |
| 47 | 47-Configuration-and-Misconfiguration-Hunting.md | config2 | configuration-extended | HUNT-047 |
| 48 | 48-Network-and-Infrastructure-Security.md | network2 | infrastructure-extended | HUNT-048 |
| 49 | 49-Mobile-and-API-Specific-Vulnerabilities.md | mobile2 | mobile-security-extended | HUNT-049 |
| 50 | 50-Reporting-and-Proof-of-Concept-Development.md | report2 | reporting-extended | HUNT-050 |

### File Dependency Graph (Serialization-Relevant)

```
Phase 1 (Foundational):
  [6] Input Validation ──┬── [27] Command Injection
                         ├── [28] NoSQL Injection
                         ├── [31] SSTI
                         ├── [36] LDAP Injection
                         └── [42] XPath Injection

  [1] Recon ─────────────┬── [12] SSRF
                         ├── [18] Network
                         └── [23] Subdomain Takeover

  [9] Cryptography ──────┬── [4] Authentication
                         └── [32] JWT

  [17] Configuration ──── [10] Error Handling
  [18] Network ────────── [22] HTTP Smuggling

Phase 2 (Core):
  [2] JS Analysis ───────┬── [3] API Analysis
                         ├── [29] GraphQL
                         └── [40] Prototype Pollution

  [3] API ───────────────┬── [4] Authentication
                         ├── [19] Mobile & API
                         └── [30] WebSocket

  [4] Authentication ────┬── [5] Authorization
                         └── [37] Session Puzzling

  [7] Business Logic ──── [15] Race Conditions
  [11] File Upload ────── [38] Insecure File Handling

Phase 3 (Vulnerability Classes):
  [12] SSRF ───────────── [18] Network
  [13] CSRF ───────────── [43] CSRF Extended
  [14] CORS ─────────────┬── [33] CSP Bypass
                         ├── [39] XSSI
                         └── [44] CORS Extended

  [15] Race Conditions ── [45] Race Conditions Extended
  [16] Third-Party ────── [46] Third-Party Extended

Phase 4 (Extended):
  [43-50] Extended variants of core vulnerability classes

Phase 5 (Output):
  [20] Reporting ──────── [50] Reporting Extended
```

### Serialization Cross-Reference Matrix

When serializing findings that chain multiple domain files, the cross-reference matrix determines the combined serialization envelope:

| Source File | Target Files | Chain Type | Combined Severity |
|-------------|--------------|------------|-------------------|
| 1 (Recon) | 12 (SSRF) | Recon → Exploit | max(source, target) |
| 1 (Recon) | 23 (Takeover) | Recon → Exploit | target |
| 3 (API) | 4 (Auth) | Endpoint → Auth | max(source, target) |
| 4 (Auth) | 5 (Authz) | Auth → Authz | target |
| 6 (Input) | 27 (Cmdi) | Validation → RCE | target |
| 6 (Input) | 31 (SSTI) | Validation → RCE | target |
| 12 (SSRF) | 18 (Network) | SSRF → Internal | max(source, target) |
| 13 (CSRF) | 14 (CORS) | CSRF → CORS | max(source, target) |
| 14 (CORS) | 33 (CSP) | CORS → CSP | medium |
| 15 (Race) | 7 (BizLogic) | Race → Logic | max(source, target) |
| 25 (XXE) | 12 (SSRF) | XXE → SSRF | max(source, target) |
| 26 (Deser) | 27 (Cmdi) | Deser → RCE | target |
| 31 (SSTI) | 27 (Cmdi) | SSTI → RCE | target |
| 40 (Proto) | 27 (Cmdi) | Proto → RCE | target |
| 2 (JS) | 40 (Proto) | JS → Proto | high |

---

## Appendix: Serialization Constants

```python
# Domain Identification
DOMAIN_ID = "core-prompts-hunting"
DOMAIN_VERSION = "2.1.0"
SCHEMA_VERSION = "1.0"

# Format Identifiers
FORMAT_JSON = "json"
FORMAT_YAML = "yaml"
FORMAT_MSGPACK = "messagepack"
FORMAT_PROTOBUF = "protobuf"

# Compression Algorithms
COMPRESS_GZIP = "gzip"
COMPRESS_BROTLI = "brotli"
COMPRESS_LZ4 = "lz4"

# Size Thresholds
COMPRESS_THRESHOLD_BYTES = 1024
MAX_BATCH_SIZE = 100
MAX_NESTING_DEPTH = 32
MAX_ANCHOR_COUNT = 128

# Checksum Algorithm
CHECKSUM_ALGORITHM = "crc32"
HASH_ALGORITHM = "sha256"

# Error Codes
ERR_UNSUPPORTED_FORMAT = "SER_UNSUPPORTED_FORMAT"
ERR_FORMAT_DETECTION = "SER_FORMAT_DETECTION_FAILED"
ERR_SCHEMA_VALIDATION = "SER_SCHEMA_VALIDATION_ERROR"
ERR_TYPE_COERCION = "SER_TYPE_COERCION_ERROR"
ERR_COMPRESSION = "SER_COMPRESSION_ERROR"
ERR_CHECKSUM = "SER_CHECKSUM_MISMATCH"
ERR_BATCH_PARTIAL = "SER_BATCH_PARTIAL_FAILURE"
ERR_BATCH_TIMEOUT = "SER_BATCH_TIMEOUT"
```

---

*End of core-prompts-hunting serialization definition.*
*Total domain files referenced: 50*
*Serialization formats supported: JSON, YAML, MessagePack, Protobuf*
*Compression algorithms: gzip, brotli, lz4*
