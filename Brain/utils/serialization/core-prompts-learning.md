# Data Serialization — Core-Prompts Learning Domain (Progress)

---

## Title / Metadata

```yaml
domain: core-prompts-learning
category: learning-progress
version: 1.0.0
created: 2026-06-26
author: Brain Serialization Module
serializer_module: Brain.utils.serialization
registry_ref: core-prompts-learning/registry.json
total_files: 50
serialization_formats: [json, yaml, msgpack, protobuf]
compression_algorithms: [gzip, zlib, brotli]
type_preservation: true
schema_version: 2
description: >
  Defines the complete serialization contract for the core-prompts-learning
  domain. Every learning file in core-prompts/ produces structured learning
  progress that must be serializable, deserializable, compressible, and
  pipeline-integrable. This document specifies the schemas, operations, format
  bindings, and registry mappings for all 50 learning module files.
```

---

## Overview

The core-prompts-learning domain encompasses 50 learning files covering the full
web security knowledge lifecycle — from reconnaissance fundamentals through
advanced threat modeling. Each file defines a discrete learning module whose
progress metrics, mastery levels, exercise completions, and knowledge graphs
must survive serialization round-trips without data loss.

This serialization layer sits between the learning content and the Brain
progress tracker, ensuring that:

1. Every learning progress snapshot can be persisted in any supported wire/storage format.
2. Type fidelity (datetimes, enums, UUIDs, progress percentages) survives encode/decode cycles.
3. Large learning graphs compress transparently when above threshold.
4. The registry maps each learning file to its exact serialization schema.
5. Pipeline orchestration can deserialize any learning output without knowing
   which module produced it.

The 50 files group into five functional clusters:

| Cluster | Files | Purpose |
|---------|-------|---------|
| **Reconnaissance & Discovery** | 01, 17, 18, 23, 24, 40 | Asset discovery, network recon, cloud |
| **Injection & Exploitation** | 06, 12, 22, 25, 27, 28, 31, 36 | Input attacks, SSRF, XXE, SSTI, injection |
| **Authentication & Access** | 04, 05, 13, 14, 32, 37 | Auth, session, CSRF, CORS, JWT, fixation |
| **Client-Side & API** | 02, 03, 08, 19, 29, 30, 33, 34, 35, 39, 44, 45 | JS, API, GraphQL, WebSocket, CSP, HPP |
| **Advanced & Specialized** | 07, 09, 10, 11, 15, 16, 20, 21, 26, 38, 41, 42, 43, 46, 47, 48, 49, 50 | Business logic, crypto, WAF, deserialization, reporting, IoT, blockchain |

---

## Domain Mapping — File-to-Schema Registry

Every learning file maps to a named serialization schema. The registry is
authoritative; the mapping below is the human-readable reference.

```json
{
  "domain": "core-prompts-learning",
  "schemas": {
    "01-reconnaissance-asset-discovery":    { "file": "1-Reconnaissance-and-Asset-Discovery-Learning.md",          "schema": "ReconProgress",              "output_type": "ReconModuleProgress" },
    "02-javascript-analysis-deobfuscation": { "file": "2-JavaScript-Analysis-and-Deobfuscation-Learning.md",      "schema": "JSAnalysisProgress",         "output_type": "JSModuleProgress" },
    "03-api-endpoint-analysis":             { "file": "3-API-Endpoint-Analysis-Learning.md",                      "schema": "APIProgress",                "output_type": "APIModuleProgress" },
    "04-authentication-session-mgmt":       { "file": "4-Authentication-and-Session-Management-Learning.md",      "schema": "AuthProgress",               "output_type": "AuthModuleProgress" },
    "05-authorization-access-control":      { "file": "5-Authorization-and-Access-Control-Learning.md",           "schema": "AuthzProgress",              "output_type": "AuthzModuleProgress" },
    "06-input-validation-sanitization":     { "file": "6-Input-Validation-and-Sanitization-Learning.md",          "schema": "InputValidationProgress",    "output_type": "InputModuleProgress" },
    "07-business-logic-flaws":              { "file": "7-Business-Logic-Flaws-Learning.md",                        "schema": "BizLogicProgress",           "output_type": "BizLogicModuleProgress" },
    "08-client-side-storage-security":      { "file": "8-Client-Side-Storage-Security-Learning.md",                "schema": "ClientStorageProgress",      "output_type": "ClientStorageModuleProgress" },
    "09-cryptography-data-protection":      { "file": "9-Cryptography-and-Data-Protection-Learning.md",           "schema": "CryptoProgress",             "output_type": "CryptoModuleProgress" },
    "10-error-handling-info-disclosure":    { "file": "10-Error-Handling-and-Information-Disclosure-Learning.md",  "schema": "ErrorHandlingProgress",      "output_type": "ErrorModuleProgress" },
    "11-file-upload-processing":            { "file": "11-File-Upload-and-Processing-Learning.md",                "schema": "FileUploadProgress",         "output_type": "FileUploadModuleProgress" },
    "12-ssrf":                              { "file": "12-Server-Side-Request-Forgery-SSRF-Learning.md",          "schema": "SSRFProgress",               "output_type": "SSRFModuleProgress" },
    "13-csrf":                              { "file": "13-Cross-Site-Request-Forgery-CSRF-Learning.md",           "schema": "CSRFProgress",               "output_type": "CSRFModuleProgress" },
    "14-cors":                              { "file": "14-Cross-Origin-Resource-Sharing-CORS-Learning.md",       "schema": "CORSProgress",               "output_type": "CORSModuleProgress" },
    "15-race-conditions-concurrency":       { "file": "15-Race-Conditions-and-Concurrency-Issues-Learning.md",    "schema": "RaceConditionProgress",      "output_type": "RaceModuleProgress" },
    "16-third-party-component-analysis":    { "file": "16-Third-Party-Component-Analysis-Learning.md",            "schema": "ThirdPartyProgress",         "output_type": "ThirdPartyModuleProgress" },
    "17-configuration-misconfiguration":    { "file": "17-Configuration-and-Misconfiguration-Hunting-Learning.md","schema": "ConfigProgress",            "output_type": "ConfigModuleProgress" },
    "18-network-infrastructure-security":   { "file": "18-Network-and-Infrastructure-Security-Learning.md",       "schema": "NetworkProgress",            "output_type": "NetworkModuleProgress" },
    "19-mobile-api-vulnerabilities":        { "file": "19-Mobile-and-API-Specific-Vulnerabilities-Learning.md",   "schema": "MobileAPIProgress",          "output_type": "MobileAPIModuleProgress" },
    "20-reporting-poc-development":         { "file": "20-Reporting-and-Proof-of-Concept-Development-Learning.md","schema": "ReportingProgress",         "output_type": "ReportingModuleProgress" },
    "21-waf-bypass":                        { "file": "21-Web-Application-Firewall-WAF-Bypass-Learning.md",       "schema": "WAFBypassProgress",          "output_type": "WAFModuleProgress" },
    "22-http-request-smuggling":            { "file": "22-HTTP-Request-Smuggling-Learning.md",                    "schema": "SmugglingProgress",          "output_type": "SmugglingModuleProgress" },
    "23-subdomain-takeover":                { "file": "23-Subdomain-Takeover-Learning.md",                        "schema": "SubdomainTakeoverProgress",  "output_type": "SubdomainModuleProgress" },
    "24-host-header-injection":             { "file": "24-Host-Header-Injection-Learning.md",                     "schema": "HostHeaderProgress",         "output_type": "HostHeaderModuleProgress" },
    "25-xxe-injection":                     { "file": "25-XML-External-Entity-XXE-Injection-Learning.md",         "schema": "XXEProgress",                "output_type": "XXEModuleProgress" },
    "26-insecure-deserialization":          { "file": "26-Insecure-Deserialization-Learning.md",                  "schema": "DeserializationProgress",    "output_type": "DeserializationModuleProgress" },
    "27-command-injection":                 { "file": "27-Command-Injection-Learning.md",                        "schema": "CMDiProgress",               "output_type": "CMDiModuleProgress" },
    "28-nosql-injection":                   { "file": "28-NoSQL-Injection-Learning.md",                          "schema": "NoSQLProgress",              "output_type": "NoSQLModuleProgress" },
    "29-graphql-vulnerabilities":           { "file": "29-GraphQL-Vulnerabilities-Learning.md",                   "schema": "GraphQLProgress",            "output_type": "GraphQLModuleProgress" },
    "30-websocket-security":                { "file": "30-WebSocket-Security-Learning.md",                        "schema": "WebSocketProgress",          "output_type": "WebSocketModuleProgress" },
    "31-ssti":                              { "file": "31-Server-Side-Template-Injection-SSTI-Learning.md",       "schema": "SSTIProgress",               "output_type": "STIModuleProgress" },
    "32-jwt-vulnerabilities":               { "file": "32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md",        "schema": "JWTProgress",                "output_type": "JWTModuleProgress" },
    "33-csp-bypass":                        { "file": "33-Content-Security-Policy-CSP-Bypass-Learning.md",        "schema": "CSPProgress",                "output_type": "CSPModuleProgress" },
    "34-clickjacking-ui-redressing":        { "file": "34-Clickjacking-and-UI-Redressing-Learning.md",            "schema": "ClickjackingProgress",       "output_type": "ClickjackingModuleProgress" },
    "35-http-parameter-pollution":          { "file": "35-HTTP-Parameter-Pollution-Learning.md",                  "schema": "HPPProgress",                "output_type": "HPPModuleProgress" },
    "36-ldap-injection":                    { "file": "36-LDAP-Injection-Learning.md",                           "schema": "LDAPProgress",               "output_type": "LDAPModuleProgress" },
    "37-session-puzzling-fixation":         { "file": "37-Session-Puzzling-and-Fixation-Learning.md",             "schema": "SessionFixProgress",         "output_type": "SessionFixModuleProgress" },
    "38-insecure-file-handling":            { "file": "38-Insecure-File-Handling-Learning.md",                    "schema": "InsecureFileProgress",       "output_type": "InsecureFileModuleProgress" },
    "39-advanced-client-side-attacks":      { "file": "39-Advanced-Client-Side-Attacks-Learning.md",              "schema": "AdvClientProgress",          "output_type": "AdvClientModuleProgress" },
    "40-cloud-security-misconfig":          { "file": "40-Cloud-Security-and-Misconfigurations-Learning.md",      "schema": "CloudProgress",              "output_type": "CloudModuleProgress" },
    "41-third-party-integration-security":  { "file": "41-Third-Party-Integration-Security-Learning.md",          "schema": "IntegrationProgress",        "output_type": "IntegrationModuleProgress" },
    "42-mobile-application-security":       { "file": "42-Mobile-Application-Security-Learning.md",               "schema": "MobileAppProgress",          "output_type": "MobileAppModuleProgress" },
    "43-iot-embedded-device-security":      { "file": "43-IoT-and-Embedded-Device-Security-Learning.md",          "schema": "IoTProgress",                "output_type": "IoTModuleProgress" },
    "44-api-security-graphql":              { "file": "44-API-Security-and-GraphQL-Learning.md",                  "schema": "APISecProgress",             "output_type": "APISecModuleProgress" },
    "45-webassembly-modern-web":            { "file": "45-WebAssembly-and-Modern-Web-Technologies-Learning.md",   "schema": "WasmProgress",               "output_type": "WasmModuleProgress" },
    "46-blockchain-cryptocurrency":         { "file": "46-Blockchain-and-Cryptocurrency-Security-Learning.md",    "schema": "BlockchainProgress",         "output_type": "BlockchainModuleProgress" },
    "47-automation-tool-development":       { "file": "47-Automation-and-Tool-Development-Learning.md",           "schema": "AutomationProgress",         "output_type": "AutomationModuleProgress" },
    "48-advanced-reverse-engineering":      { "file": "48-Advanced-Reverse-Engineering-Learning.md",              "schema": "ReverseEngProgress",         "output_type": "ReverseEngModuleProgress" },
    "49-compliance-regulatory-security":    { "file": "49-Compliance-and-Regulatory-Security-Learning.md",        "schema": "ComplianceProgress",         "output_type": "ComplianceModuleProgress" },
    "50-threat-modeling-risk-assessment":   { "file": "50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md","schema": "ThreatModelProgress",      "output_type": "ThreatModelModuleProgress" }
  }
}
```

---

## Format Support

### JSON — Primary Interchange

JSON is the default wire format for all learning progress outputs. The serializer uses
`json.dumps` with `ensure_ascii=False` and configurable indentation.

```python
from Brain.utils.serialization import Serializer

s = Serializer(default_format="json")
learning_progress = {"module_id": "01", "mastery": 0.85, "exercises_done": 12}
wire = s.encode(learning_progress, format="json")
# Returns UTF-8 bytes with proper escaping
```

Learning-specific JSON extensions:
- `__learning_meta` block injected at root with module_id, domain, timestamp, version
- Null values preserved (unlike YAML which may collapse empty maps)
- Arrays of heterogeneous objects supported (mixed exercise types)

### YAML — Human-Readable Config & Reports

YAML is used for configuration files, human-readable learning reports, and registry
definitions. The serializer wraps PyYAML with anchor support disabled for
deterministic output.

```python
wire = s.encode(learning_progress, format="yaml")
# Produces readable indented output suitable for diff/review
```

Learning-specific YAML conventions:
- Multi-line strings for exercise descriptions (`|` literal block)
- Anchors for repeated module definitions
- Comments stripped on round-trip (YAML does not preserve comments)

### MessagePack — High-Throughput Binary

MessagePack is the preferred format for inter-process learning progress transfer and
cache storage. Produces 30-50% smaller payloads than JSON for typical learning data.

```python
wire = s.encode(learning_progress, format="msgpack")
# Compact binary, ideal for Redis/IPC between learning modules
```

Learning-specific MessagePack usage:
- Knowledge graph traversals with 10K+ node records benefit most
- Exercise completion lists with repetitive key structures compress well
- Streaming encode for real-time progress updates

### Protocol Buffers — Schema-Enforced

Protocol Buffers provide field-level validation and backward-compatible schema
evolution for critical learning pipelines.

```python
from Brain.utils.serialization import ProtoSerializer

proto = ProtoSerializer(schema_path="schemas/learning.proto")
encoded = proto.encode("LearningProgress", learning_progress)
decoded = proto.decode("LearningProgress", encoded)
```

Learning-specific Protobuf definitions:
- `LearningModule` — id, title, category, difficulty, total_exercises
- `ExerciseRecord` — id, module_id, type, status, score, time_spent
- `MasterySnapshot` — module_id, mastery_pct, confidence, last_assessed
- `KnowledgeNode` — id, concept, connections, strength, last_reinforced

---

## Progress Serialization

### Learning Progress Envelope

Every learning progress update wraps in a common envelope before serialization:

```json
{
  "__envelope": {
    "domain": "core-prompts-learning",
    "schema": "ReconProgress",
    "module_id": "01",
    "session_id": "sess_abc123",
    "started_at": "2026-06-26T10:00:00Z",
    "updated_at": "2026-06-26T10:15:35Z",
    "format_version": "2.0.0"
  },
  "module": "Reconnaissance and Asset Discovery",
  "mastery": 0.85,
  "exercises_completed": 12,
  "exercises_total": 15,
  "knowledge_nodes": [...]
}
```

### Mastery Level Schema

All learning files produce mastery data conforming to:

```json
{
  "module_id": "01",
  "module_name": "Reconnaissance and Asset Discovery",
  "category": "reconnaissance",
  "difficulty": "intermediate",
  "mastery": {
    "overall": 0.85,
    "by_skill": {
      "subdomain-enumeration": 0.90,
      "port-scanning": 0.80,
      "service-fingerprinting": 0.82,
      "technology-detection": 0.88
    },
    "confidence": 0.92,
    "assessments_taken": 5,
    "last_assessed": "2026-06-26T10:15:00Z"
  },
  "exercises": {
    "completed": 12,
    "total": 15,
    "list": [
      {
        "exercise_id": "ex_001",
        "title": "Subdomain enumeration with crt.sh",
        "type": "practical",
        "status": "completed",
        "score": 0.95,
        "time_spent_sec": 300,
        "attempts": 1
      }
    ]
  },
  "time_invested": {
    "total_hours": 4.5,
    "sessions": 3,
    "first_started": "2026-06-24T08:00:00Z",
    "last_active": "2026-06-26T10:15:00Z"
  }
}
```

### Knowledge Graph Schema

From knowledge graph traversal across modules:

```json
{
  "nodes": [
    {
      "node_id": "kn_001",
      "concept": "subdomain-enumeration",
      "module_id": "01",
      "strength": 0.90,
      "connections": ["port-scanning", "service-fingerprinting", "dns-enumeration"],
      "last_reinforced": "2026-06-26T10:00:00Z",
      "reinforcement_count": 7
    }
  ],
  "edges": [
    {
      "source": "kn_001",
      "target": "kn_002",
      "relation": "prerequisite",
      "weight": 0.85
    }
  ],
  "total_nodes": 245,
  "total_edges": 512,
  "coverage_pct": 0.72
}
```

### Exercise Completion Schema

From individual exercise tracking:

```json
{
  "exercise_id": "ex_012",
  "module_id": "04",
  "module_name": "Authentication and Session Management",
  "title": "Session token analysis exercise",
  "type": "lab",
  "difficulty": "advanced",
  "status": "completed",
  "score": 0.92,
  "max_score": 1.0,
  "attempts": [
    {
      "attempt_num": 1,
      "started_at": "2026-06-26T09:00:00Z",
      "completed_at": "2026-06-26T09:25:00Z",
      "score": 0.75,
      "hints_used": 2,
      "errors": 3
    },
    {
      "attempt_num": 2,
      "started_at": "2026-06-26T09:30:00Z",
      "completed_at": "2026-06-26T09:50:00Z",
      "score": 0.92,
      "hints_used": 0,
      "errors": 1
    }
  ],
  "skills_practiced": ["jwt-analysis", "cookie-inspection", "token-replay"],
  "feedback": {
    "rating": 4,
    "comments": "Good exercise, needed more SSRF scenarios"
  }
}
```

---

## Serialize Operations

### Core Serialize API

```python
from Brain.utils.serialization import LearningSerializer

ls = LearningSerializer(domain="core-prompts-learning")

# Encode a single learning module progress
wire = ls.encode_module_progress(
    module_id="01",
    progress=module_progress_dict,
    format="json"
)

# Encode a full mastery snapshot
wire = ls.encode_mastery_snapshot(
    snapshot=mastery_snapshot_dict,
    format="msgpack"
)

# Encode knowledge graph
wire = ls.encode_knowledge_graph(
    graph=knowledge_graph_dict,
    format="protobuf"
)
```

### Batch Serialize

```python
# Serialize all 50 modules in one pass
batch_wire = ls.encode_batch(
    modules=list_of_progress_dicts,
    format="json",
    compression="gzip"
)

# Serialize with streaming for large graphs
ls.encode_stream(
    source=large_knowledge_graph,
    destination="progress_archive.msgpack",
    format="msgpack",
    chunk_size=1000
)
```

### Selective Serialization

```python
# Serialize only fields above a threshold
wire = ls.encode_filtered(
    progress=module_progress_dict,
    fields=["mastery", "exercises", "time_invested"],
    format="json"
)

# Serialize with custom field ordering
wire = ls.encode_ordered(
    progress=module_progress_dict,
    field_order=["module_id", "mastery", "exercises", "time_invested"],
    format="yaml"
)
```

---

## Deserialize Operations

### Core Deserialize API

```python
from Brain.utils.serialization import LearningDeserializer

ld = LearningDeserializer(domain="core-prompts-learning")

# Decode to module progress
progress = ld.decode_module_progress(
    wire=raw_bytes,
    format="json"
)

# Decode mastery snapshot
snapshot = ld.decode_mastery_snapshot(
    wire=raw_bytes,
    format="msgpack"
)

# Decode with schema validation
progress = ld.decode_validated(
    wire=raw_bytes,
    schema="ReconProgress",
    format="json",
    strict=True
)
```

### Batch Deserialize

```python
# Deserialize all modules from archive
modules = ld.decode_batch(
    wire=batch_wire,
    format="json",
    compression="gzip"
)

# Stream deserialization for large files
for chunk in ld.decode_stream("progress_archive.msgpack", format="msgpack"):
    process(chunk)
```

### Format-Agnostic Deserialize

```python
# Auto-detect format and deserialize
progress = ld.decode_auto(wire=raw_bytes)

# Deserialize with fallback chain
progress = ld.decode_with_fallback(
    wire=raw_bytes,
    formats=["protobuf", "msgpack", "json"]
)
```

---

## Compression

### Compression Strategies

```python
from Brain.utils.serialization import LearningCompressor

lc = LearningCompressor()

# Compress large knowledge graphs
compressed = lc.compress(
    data=knowledge_graph,
    algorithm="brotli",
    level=6
)

# Decompress
original = lc.decompress(
    data=compressed,
    algorithm="brotli"
)

# Auto-select algorithm based on data characteristics
compressed = lc.compress_optimal(data=learning_progress)
```

### Compression Thresholds

| Data Size | Algorithm | Ratio |
|-----------|-----------|-------|
| < 1 KB | none | 1:1 |
| 1 KB - 10 KB | gzip (level 6) | ~3:1 |
| 10 KB - 100 KB | brotli (level 6) | ~5:1 |
| > 100 KB | brotli (level 9) | ~7:1 |

### Domain-Specific Compression

```python
# Knowledge graph edge compression (repetitive relation types)
compressed = lc.compress_graph_edges(edges=edge_list, algorithm="brotli")

# Exercise list compression (repetitive key structures)
compressed = lc.compress_exercises(exercises=exercise_list, algorithm="gzip")

# Mastery snapshot compression (small but frequent)
compressed = lc.compress_mastery(mastery=mastery_dict, algorithm="zlib")
```

---

## Type Preservation

### Type Fidelity Matrix

| Python Type | JSON | YAML | MessagePack | Protobuf |
|-------------|------|------|-------------|----------|
| `datetime` | ISO 8601 string | ISO 8601 string | int64 (epoch ms) | Timestamp |
| `UUID` | hex string | hex string | bytes(16) | string |
| `bytes` | base64 string | base64 string | bin | bytes |
| `Enum` | string value | string value | int | enum |
| `float` | number | number | float64 | float/double |
| `None` | null | null | nil | not set |
| `Decimal` | string | string | string | string |
| `set` | array | array | array | repeated |

### Custom Type Encoders

```python
from Brain.utils.serialization import TypePreserver

tp = TypePreserver()

# Register custom encoder for learning-specific types
tp.register_encoder(
    type_name="MasteryLevel",
    encode_fn=lambda v: {"overall": v.overall, "by_skill": v.by_skill},
    decode_fn=lambda d: MasteryLevel(**d)
)

# Preserve datetime precision across formats
tp.register_encoder(
    type_name="datetime",
    encode_fn=lambda v: v.isoformat(),
    decode_fn=lambda d: datetime.fromisoformat(d)
)

# Preserve UUID format
tp.register_encoder(
    type_name="UUID",
    encode_fn=lambda v: str(v),
    decode_fn=lambda d: UUID(d)
)
```

### Round-Trip Guarantee

```python
# All types survive encode/decode cycles
original = {
    "module_id": UUID("550e8400-e29b-41d4-a716-446655440000"),
    "mastery": Decimal("0.8523"),
    "completed_at": datetime(2026, 6, 26, 10, 15, 0),
    "tags": {"recon", "network", "infrastructure"},
    "status": ModuleStatus.IN_PROGRESS
}

# Round-trip through any format
for fmt in ["json", "yaml", "msgpack", "protobuf"]:
    wire = ls.encode(original, format=fmt)
    restored = ld.decode(wire, format=fmt)
    assert restored == original  # Guaranteed
```

---

## Custom Serializers

### Module-Specific Serializers

```python
from Brain.utils.serialization import (
    ReconProgressSerializer,
    JSAnalysisProgressSerializer,
    APIProgressSerializer,
    AuthProgressSerializer,
    AuthzProgressSerializer,
    InputValidationProgressSerializer,
    BizLogicProgressSerializer,
    ClientStorageProgressSerializer,
    CryptoProgressSerializer,
    ErrorHandlingProgressSerializer,
    FileUploadProgressSerializer,
    SSRFProgressSerializer,
    CSRFProgressSerializer,
    CORSProgressSerializer,
    RaceConditionProgressSerializer,
    ThirdPartyProgressSerializer,
    ConfigProgressSerializer,
    NetworkProgressSerializer,
    MobileAPIProgressSerializer,
    ReportingProgressSerializer,
    WAFBypassProgressSerializer,
    SmugglingProgressSerializer,
    SubdomainTakeoverProgressSerializer,
    HostHeaderProgressSerializer,
    XXEProgressSerializer,
    DeserializationProgressSerializer,
    CMDiProgressSerializer,
    NoSQLProgressSerializer,
    GraphQLProgressSerializer,
    WebSocketProgressSerializer,
    SSTIProgressSerializer,
    JWTProgressSerializer,
    CSPProgressSerializer,
    ClickjackingProgressSerializer,
    HPPProgressSerializer,
    LDAPProgressSerializer,
    SessionFixProgressSerializer,
    InsecureFileProgressSerializer,
    AdvClientProgressSerializer,
    CloudProgressSerializer,
    IntegrationProgressSerializer,
    MobileAppProgressSerializer,
    IoTProgressSerializer,
    APISecProgressSerializer,
    WasmProgressSerializer,
    BlockchainProgressSerializer,
    AutomationProgressSerializer,
    ReverseEngProgressSerializer,
    ComplianceProgressSerializer,
    ThreatModelProgressSerializer
)
```

### Custom Serializer Base Class

```python
class LearningModuleSerializer:
    """Base class for all learning module serializers."""

    def __init__(self, module_id: str, module_name: str):
        self.module_id = module_id
        self.module_name = module_name

    def encode(self, progress: dict, format: str = "json") -> bytes:
        envelope = self._wrap_envelope(progress)
        return self._serialize(envelope, format)

    def decode(self, wire: bytes, format: str = "json") -> dict:
        raw = self._deserialize(wire, format)
        return self._unwrap_envelope(raw)

    def _wrap_envelope(self, progress: dict) -> dict:
        return {
            "__learning_meta": {
                "domain": "core-prompts-learning",
                "module_id": self.module_id,
                "module_name": self.module_name,
                "timestamp": datetime.utcnow().isoformat()
            },
            "data": progress
        }

    def _unwrap_envelope(self, data: dict) -> dict:
        return data.get("data", data)
```

---

## Format Detection

### Auto-Detection Logic

```python
from Brain.utils.serialization import FormatDetector

fd = FormatDetector()

detected = fd.detect(wire=raw_bytes)
# Returns: {"format": "json", "compression": "gzip", "confidence": 0.98}

# Detect with explicit format hint
detected = fd.detect(wire=raw_bytes, hint="protobuf")

# Detect from file extension
detected = fd.detect_from_path("progress_module01.json.gz")
# Returns: {"format": "json", "compression": "gzip"}
```

### Detection Patterns

| Format | Magic Bytes | Header |
|--------|-------------|--------|
| JSON | `{` or `[` | UTF-8 text starting with `{` |
| YAML | `---` or text | UTF-8 text starting with `---` |
| MessagePack | `0x91-0x9f`, `0xa1-0xbf` | Binary with map/array prefix |
| Protobuf | varies | Binary with varint length prefix |
| gzip | `0x1f 0x8b` | Two-byte magic |
| brotli | varies | Context-dependent |
| zlib | `0x78 0x01`, `0x78 0x9c`, `0x78 0xda` | Two-byte magic |

### Confidence Scoring

```python
detected = fd.detect(wire=raw_bytes)
# confidence > 0.95: trust the detection
# confidence 0.7-0.95: use with validation
# confidence < 0.7: fall back to user-specified format
```

---

## Batch Operations

### Batch Encode

```python
from Brain.utils.serialization import BatchLearningSerializer

bls = BatchLearningSerializer(domain="core-prompts-learning")

# Encode all 50 modules at once
batch = bls.encode_all(
    modules={
        "01": module_01_progress,
        "02": module_02_progress,
        # ... all 50
    },
    format="json",
    compression="gzip"
)

# Encode with parallelism
batch = bls.encode_parallel(
    modules=all_modules,
    format="msgpack",
    workers=8
)
```

### Batch Decode

```python
# Decode all modules from batch archive
all_progress = bls.decode_all(
    wire=batch_wire,
    format="json",
    compression="gzip"
)

# Decode selectively
progress_01 = bls.decode_module(
    wire=batch_wire,
    module_id="01",
    format="json"
)
```

### Batch Transform

```python
# Transform between formats in batch
yaml_batch = bls.transform_batch(
    source_wire=json_batch,
    source_format="json",
    target_format="yaml",
    compression="gzip"
)

# Normalize mastery values across all modules
normalized = bls.normalize_batch(
    modules=all_progress,
    mastery_range=(0.0, 1.0),
    confidence_threshold=0.8
)
```

---

## Registry Schema

### Registry Entry Structure

```json
{
  "domain": "core-prompts-learning",
  "version": "2.0.0",
  "last_updated": "2026-06-26T10:00:00Z",
  "total_modules": 50,
  "registry": {
    "01": {
      "file": "1-Reconnaissance-and-Asset-Discovery-Learning.md",
      "schema": "ReconProgress",
      "output_type": "ReconModuleProgress",
      "serializer": "ReconProgressSerializer",
      "format_priority": ["json", "msgpack", "yaml"],
      "compression_required": false,
      "validation_schema": "schemas/learning/recon.json"
    }
  }
}
```

### Registry Loading

```python
from Brain.utils.serialization import LearningRegistry

registry = LearningRegistry.load("core-prompts-learning/registry.json")

# Get schema for module 01
schema = registry.get_schema("01")
# Returns: {"schema": "ReconProgress", "output_type": "ReconModuleProgress", ...}

# Get serializer for module 04
serializer = registry.get_serializer("04")
# Returns: AuthProgressSerializer instance

# Validate module output against schema
is_valid = registry.validate("12", ssrf_progress_dict)
```

---

## Error Handling

### Serialization Errors

```python
from Brain.utils.serialization import (
    SerializationError,
    DeserializationError,
    SchemaValidationError,
    CompressionError,
    FormatDetectionError
)

try:
    wire = ls.encode(progress, format="protobuf")
except SerializationError as e:
    # e.message: "Failed to serialize LearningProgress"
    # e.module_id: "01"
    # e.format: "protobuf"
    # e.cause: original exception
    logger.error(f"Serialization failed: {e}")

try:
    progress = ld.decode(wire, format="json")
except DeserializationError as e:
    # e.message: "Invalid JSON in learning progress"
    # e.offset: byte offset where error occurred
    # e.expected: expected schema structure
    # e.actual: received structure
    logger.error(f"Deserialization failed: {e}")

try:
    registry.validate("01", progress)
except SchemaValidationError as e:
    # e.field: "mastery.overall"
    # e.expected: "0.0 <= x <= 1.0"
    # e.actual: "1.5"
    logger.error(f"Validation failed: {e}")
```

### Error Recovery

```python
# Attempt recovery with fallback formats
progress = ld.decode_with_fallback(
    wire=raw_bytes,
    formats=["json", "yaml", "msgpack"],
    on_error="skip_invalid"
)

# Skip corrupt entries in batch
results = bls.decode_all(
    wire=batch_wire,
    format="json",
    on_error="skip_corrupt"
)
# Returns: {"success": [...], "errors": [{"module_id": "03", "error": "..."}]}
```

### Validation Gates

```python
# Pre-serialization validation
ls.validate_before_encode(
    progress=module_progress,
    checks=[
        "mastery_range",          # 0.0 <= mastery <= 1.0
        "exercise_counts",        # completed <= total
        "timestamp_ordering",     # started < updated < now
        "required_fields",        # module_id, module_name present
        "type_coherence"          # all types match schema
    ]
)

# Post-deserialization validation
ld.validate_after_decode(
    progress=restored_progress,
    checks=[
        "schema_compliance",
        "data_integrity",
        "referential_integrity",  # exercise IDs exist in module
        "mastery_consistency"     # mastery matches exercise scores
    ]
)
```

---

## Pipeline Integration

### Learning Pipeline Stages

```python
from Brain.utils.serialization import LearningPipeline

pipeline = LearningPipeline(domain="core-prompts-learning")

# Stage 1: Capture exercise completion
pipeline.add_stage("capture", lambda ctx: capture_exercise(ctx))

# Stage 2: Update mastery calculation
pipeline.add_stage("mastery", lambda ctx: recalculate_mastery(ctx))

# Stage 3: Serialize progress
pipeline.add_stage("serialize", lambda ctx: ls.encode(ctx.progress, format="msgpack"))

# Stage 4: Compress for storage
pipeline.add_stage("compress", lambda ctx: lc.compress(ctx.wire, algorithm="brotli"))

# Stage 5: Store to persistence
pipeline.add_stage("store", lambda ctx: store_to_db(ctx.compressed))

# Run pipeline
result = pipeline.execute(module_id="01", exercise_data=exercise_dict)
```

### Pipeline Hooks

```python
# Pre-serialization hook
pipeline.hook("pre_serialize", lambda progress: {
    **progress,
    "__computed": {
        "mastery_delta": calculate_delta(progress),
        "next_review_date": calculate_srs(progress)
    }
})

# Post-serialization hook
pipeline.hook("post_serialize", lambda wire, ctx: {
    "wire": wire,
    "size_bytes": len(wire),
    "hash": hashlib.sha256(wire).hexdigest()
})

# Post-deserialization hook
pipeline.hook("post_deserialize", lambda progress: {
    **progress,
    "deserialized_at": datetime.utcnow().isoformat(),
    "integrity_verified": True
})
```

### Cross-Module Serialization

```python
# Serialize data that spans multiple modules
cross_module = ls.encode_cross_module(
    data={
        "modules": ["01", "04", "12"],
        "shared_concept": "session-token-analysis",
        "prerequisite_chain": ["01" -> "04" -> "12"],
        "aggregate_mastery": 0.87
    },
    format="json"
)
```

---

## Full Domain File References

### File 01: Reconnaissance and Asset Discovery

- **Schema**: `ReconProgress`
- **Output Type**: `ReconModuleProgress`
- **File**: `1-Reconnaissance-and-Asset-Discovery-Learning.md`
- **Key Fields**: subdomain-enumeration, port-scanning, service-fingerprinting, technology-detection
- **Serialization Notes**: Large graph data from subdomain enumeration requires compression

### File 02: JavaScript Analysis and Deobfuscation

- **Schema**: `JSAnalysisProgress`
- **Output Type**: `JSModuleProgress`
- **File**: `2-JavaScript-Analysis-and-Deobfuscation-Learning.md`
- **Key Fields**: deobfuscation-techniques, ast-parsing, minification-reversal, source-map-analysis
- **Serialization Notes**: AST nodes may contain deeply nested structures

### File 03: API Endpoint Analysis

- **Schema**: `APIProgress`
- **Output Type**: `APIModuleProgress`
- **File**: `3-API-Endpoint-Analysis-Learning.md`
- **Key Fields**: endpoint-discovery, parameter-analysis, rate-limiting, response-analysis
- **Serialization Notes**: API response examples can be large; compress when >10KB

### File 04: Authentication and Session Management

- **Schema**: `AuthProgress`
- **Output Type**: `AuthModuleProgress`
- **File**: `4-Authentication-and-Session-Management-Learning.md`
- **Key Fields**: session-token-analysis, cookie-security, auth-flow-tracing, session-fixation
- **Serialization Notes**: Session tokens must be redacted in serialized output

### File 05: Authorization and Access Control

- **Schema**: `AuthzProgress`
- **Output Type**: `AuthzModuleProgress`
- **File**: `5-Authorization-and-Access-Control-Learning.md`
- **Key Fields**: idor-detection, privilege-escalation, rbac-testing, abac-analysis
- **Serialization Notes**: Authorization matrices can be large; use streaming for 100+ endpoints

### File 06: Input Validation and Sanitization

- **Schema**: `InputValidationProgress`
- **Output Type**: `InputModuleProgress`
- **File**: `6-Input-Validation-and-Sanitization-Learning.md`
- **Key Fields**: xss-prevention, sql-injection-prevention, input-encoding, sanitization-bypass
- **Serialization Notes**: Payload examples should be base64-encoded to avoid encoding issues

### File 07: Business Logic Flaws

- **Schema**: `BizLogicProgress`
- **Output Type**: `BizLogicModuleProgress`
- **File**: `7-Business-Logic-Flaws-Learning.md`
- **Key Fields**: workflow-bypass, price-manipulation, quantity-attacks, state-confusion
- **Serialization Notes**: Business logic flows may contain complex nested conditions

### File 08: Client-Side Storage Security

- **Schema**: `ClientStorageProgress`
- **Output Type**: `ClientStorageModuleProgress`
- **File**: `8-Client-Side-Storage-Security-Learning.md`
- **Key Fields**: localstorage, sessionstorage, cookies, indexeddb, service-workers
- **Serialization Notes**: Storage dumps can be large; compress and truncate to 100KB max

### File 09: Cryptography and Data Protection

- **Schema**: `CryptoProgress`
- **Output Type**: `CryptoModuleProgress`
- **File**: `9-Cryptography-and-Data-Protection-Learning.md`
- **Key Fields**: encryption-analysis, hash-collisions, key-management, tls-configuration
- **Serialization Notes**: Crypto keys and hashes must be sanitized in serialized output

### File 10: Error Handling and Information Disclosure

- **Schema**: `ErrorHandlingProgress`
- **Output Type**: `ErrorModuleProgress`
- **File**: `10-Error-Handling-and-Information-Disclosure-Learning.md`
- **Key Fields**: stack-trace-analysis, verbose-errors, debug-endpoints, error-messages
- **Serialization Notes**: Error samples may contain sensitive data; apply redaction

### File 11: File Upload and Processing

- **Schema**: `FileUploadProgress`
- **Output Type**: `FileUploadModuleProgress`
- **File**: `11-File-Upload-and-Processing-Learning.md`
- **Key Fields**: upload-bypass, file-type-detection, path-traversal, content-sniffing
- **Serialization Notes**: File metadata should include hash but not file contents

### File 12: Server-Side Request Forgery (SSRF)

- **Schema**: `SSRFProgress`
- **Output Type**: `SSRFModuleProgress`
- **File**: `12-Server-Side-Request-Forgery-SSRF-Learning.md`
- **Key Fields**: ssrf-techniques, filter-bypass, protocol-smuggling, cloud-metadata
- **Serialization Notes**: SSRF payloads may contain encoded URLs; preserve encoding

### File 13: Cross-Site Request Forgery (CSRF)

- **Schema**: `CSRFProgress`
- **Output Type**: `CSRFModuleProgress`
- **File**: `13-Cross-Site-Request-Forgery-CSRF-Learning.md`
- **Key Fields**: token-analysis, same-site-cookies, origin-validation, csrf-bypass
- **Serialization Notes**: CSRF proof payloads should be HTML-encoded in YAML

### File 14: Cross-Origin Resource Sharing (CORS)

- **Schema**: `CORSProgress`
- **Output Type**: `CORSModuleProgress`
- **File**: `14-Cross-Origin-Resource-Sharing-CORS-Learning.md`
- **Key Fields**: origin-reflection, wildcard-creds, preflight-bypass, null-origin
- **Serialization Notes**: CORS header examples should be stored as arrays

### File 15: Race Conditions and Concurrency Issues

- **Schema**: `RaceConditionProgress`
- **Output Type**: `RaceModuleProgress`
- **File**: `15-Race-Conditions-and-Concurrency-Issues-Learning.md`
- **Key Fields**: time-of-check, double-spend, parallel-requests, lock-bypass
- **Serialization Notes**: Race condition traces are time-ordered; preserve timestamps

### File 16: Third-Party Component Analysis

- **Schema**: `ThirdPartyProgress`
- **Output Type**: `ThirdPartyModuleProgress`
- **File**: `16-Third-Party-Component-Analysis-Learning.md`
- **Key Fields**: dependency-audit, version-checking, vulnerability-matching, supply-chain
- **Serialization Notes**: Dependency trees can be deep; flatten for serialization

### File 17: Configuration and Misconfiguration Hunting

- **Schema**: `ConfigProgress`
- **Output Type**: `ConfigModuleProgress`
- **File**: `17-Configuration-and-Misconfiguration-Hunting-Learning.md`
- **Key Fields**: default-creds, debug-enabled, directory-listing, header-misconfig
- **Serialization Notes**: Config snapshots should be compared across time; store diffs

### File 18: Network and Infrastructure Security

- **Schema**: `NetworkProgress`
- **Output Type**: `NetworkModuleProgress`
- **File**: `18-Network-and-Infrastructure-Security-Learning.md`
- **Key Fields**: port-analysis, service-enumeration, ssl-tls-audit, dns-configuration
- **Serialization Notes**: Network scan results can be very large; always compress

### File 19: Mobile and API-Specific Vulnerabilities

- **Schema**: `MobileAPIProgress`
- **Output Type**: `MobileAPIModuleProgress`
- **File**: `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md`
- **Key Fields**: api-versioning, mobile-backend, token-exposure, api-rate-limiting
- **Serialization Notes**: API request/response pairs should be stored as tuples

### File 20: Reporting and Proof-of-Concept Development

- **Schema**: `ReportingProgress`
- **Output Type**: `ReportingModuleProgress`
- **File**: `20-Reporting-and-Proof-of-Concept-Development-Learning.md`
- **Key Fields**: report-structure, poc-creation, severity-assessment, remediation
- **Serialization Notes**: Report templates should be stored as YAML for readability

### File 21: Web Application Firewall (WAF) Bypass

- **Schema**: `WAFBypassProgress`
- **Output Type**: `WAFModuleProgress`
- **File**: `21-Web-Application-Firewall-WAF-Bypass-Learning.md`
- **Key Fields**: encoding-bypass, chunked-transfer, http2-smuggling, case-variation
- **Serialization Notes**: Bypass payloads should be base64-encoded to preserve bytes

### File 22: HTTP Request Smuggling

- **Schema**: `SmugglingProgress`
- **Output Type**: `SmugglingModuleProgress`
- **File**: `22-HTTP-Request-Smuggling-Learning.md`
- **Key Fields**: cl-te, te-cl, h2-cl, h2-te, detection-techniques
- **Serialization Notes**: Raw HTTP requests must preserve exact byte sequences

### File 23: Subdomain Takeover

- **Schema**: `SubdomainTakeoverProgress`
- **Output Type**: `SubdomainModuleProgress`
- **File**: `23-Subdomain-Takeover-Learning.md`
- **Key Fields**: dns-verification, dangling-cname, cloud-service-mapping, proof-creation
- **Serialization Notes**: DNS records should be stored with timestamps for freshness

### File 24: Host Header Injection

- **Schema**: `HostHeaderProgress`
- **Output Type**: `HostHeaderModuleProgress`
- **File**: `24-Host-Header-Injection-Learning.md`
- **Key Fields**: password-reset-poisoning, cache-poisoning, virtual-host-routing
- **Serialization Notes**: Host header variations should be stored as ordered list

### File 25: XML External Entity (XXE) Injection

- **Schema**: `XXEProgress`
- **Output Type**: `XXEModuleProgress`
- **File**: `25-XML-External-Entity-XXE-Injection-Learning.md`
- **Key Fields**: entity-exploitation, blind-xxe, svg-upload, soap-injection
- **Serialization Notes**: XXE payloads contain XML; store as CDATA or base64

### File 26: Insecure Deserialization

- **Schema**: `DeserializationProgress`
- **Output Type**: `DeserializationModuleProgress`
- **File**: `26-Insecure-Deserialization-Learning.md`
- **Key Fields**: java-rce, php-object-injection, python-pickle, .net-viewstate
- **Serialization Notes**: Serialized payloads may contain binary data; use base64

### File 27: Command Injection

- **Schema**: `CMDiProgress`
- **Output Type**: `CMDiModuleProgress`
- **File**: `27-Command-Injection-Learning.md`
- **Key Fields**: blind-cmdi, os-command, code-evaluation, filter-evasion
- **Serialization Notes**: Command output samples should be truncated to 4KB

### File 28: NoSQL Injection

- **Schema**: `NoSQLProgress`
- **Output Type**: `NoSQLModuleProgress`
- **File**: `28-NoSQL-Injection-Learning.md`
- **Key Fields**: mongo-operator-injection, json-injection, nosql-auth-bypass
- **Serialization Notes**: NoSQL queries use JSON operators; preserve $-prefixed keys

### File 29: GraphQL Vulnerabilities

- **Schema**: `GraphQLProgress`
- **Output Type**: `GraphQLModuleProgress`
- **File**: `29-GraphQL-Vulnerabilities-Learning.md`
- **Key Fields**: introspection-exploitation, batching-attacks, idor-via-graphql, dos
- **Serialization Notes**: GraphQL queries may be large; compress with brotli

### File 30: WebSocket Security

- **Schema**: `WebSocketProgress`
- **Output Type**: `WebSocketModuleProgress`
- **File**: `30-WebSocket-Security-Learning.md`
- **Key Fields**: ws-hijacking, message-injection, origin-bypass, ws-auth-bypass
- **Serialization Notes**: WebSocket message logs should be stored with frame metadata

### File 31: Server-Side Template Injection (SSTI)

- **Schema**: `SSTIProgress`
- **Output Type**: `STIModuleProgress`
- **File**: `31-Server-Side-Template-Injection-SSTI-Learning.md`
- **Key Fields**: engine-detection, payload-construction, rce-via-template, sandboxes
- **Serialization Notes**: Template payloads may contain special chars; escape properly

### File 32: JSON Web Token (JWT) Vulnerabilities

- **Schema**: `JWTProgress`
- **Output Type**: `JWTModuleProgress`
- **File**: `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md`
- **Key Fields**: alg-none, key-confusion, claim-manipulation, jwt-replay
- **Serialization Notes**: JWT tokens should be stored with header, payload, signature split

### File 33: Content Security Policy (CSP) Bypass

- **Schema**: `CSPProgress`
- **Output Type**: `CSPModuleProgress`
- **File**: `33-Content-Security-Policy-CSP-Bypass-Learning.md`
- **Key Fields**: directive-analysis, bypass-techniques, report-uri-exploitation
- **Serialization Notes**: CSP headers should be stored as list of directives

### File 34: Clickjacking and UI Redressing

- **Schema**: `ClickjackingProgress`
- **Output Type**: `ClickjackingModuleProgress`
- **File**: "34-Clickjacking-and-UI-Redressing-Learning.md"
- **Key Fields**: frame-busting-bypass, x-frame-options, overlay-attacks, drag-and-drop
- **Serialization Notes**: Frame embedding proofs should include iframe HTML snippets

### File 35: HTTP Parameter Pollution

- **Schema**: `HPPProgress`
- **Output Type**: `HPPModuleProgress`
- **File**: `35-HTTP-Parameter-Pollution-Learning.md`
- **Key Fields**: backend-pollution, front-end-pollution, parameter-injection, hpp-bypass
- **Serialization Notes**: Parameter lists should preserve duplicate key ordering

### File 36: LDAP Injection

- **Schema**: `LDAPProgress`
- **Output Type**: `LDAPModuleProgress`
- **File**: `36-LDAP-Injection-Learning.md`
- **Key Fields**: filter-injection, authentication-bypass, attribute-manipulation
- **Serialization Notes**: LDAP filter strings should be stored with escape sequences preserved

### File 37: Session Puzzling and Fixation

- **Schema**: `SessionFixProgress`
- **Output Type**: `SessionFixModuleProgress`
- **File**: `37-Session-Puzzling-and-Fixation-Learning.md`
- **Key Fields**: session-puzzling, fixation-attack, session-token-prediction, scope-confusion
- **Serialization Notes**: Session state transitions should be stored as ordered sequences

### File 38: Insecure File Handling

- **Schema**: `InsecureFileProgress`
- **Output Type**: `InsecureFileModuleProgress`
- **File**: `38-Insecure-File-Handling-Learning.md`
- **Key Fields**: path-traversal, symlink-attacks, race-conditions, temp-file-exploitation
- **Serialization Notes**: File path examples should be sanitized to prevent traversal in display

### File 39: Advanced Client-Side Attacks

- **Schema**: `AdvClientProgress`
- **Output Type**: `AdvClientModuleProgress`
- **File**: `39-Advanced-Client-Side-Attacks-Learning.md`
- **Key Fields**: prototype-pollution, dom-clobbering, postmessage-xss, service-worker-poison
- **Serialization Notes**: DOM object trees can be deep; flatten for serialization

### File 40: Cloud Security and Misconfigurations

- **Schema**: `CloudProgress`
- **Output Type**: `CloudModuleProgress`
- **File**: `40-Cloud-Security-and-Misconfigurations-Learning.md`
- **Key Fields**: s3-misconfig, iam-escalation, lambda-exploitation, metadata-exposure
- **Serialization Notes**: Cloud resource inventories can be large; compress always

### File 41: Third-Party Integration Security

- **Schema**: `IntegrationProgress`
- **Output Type**: `IntegrationModuleProgress`
- **File**: `41-Third-Party-Integration-Security-Learning.md`
- **Key Fields**: oauth-integration, webhook-security, api-key-leakage, supply-chain
- **Serialization Notes**: OAuth flow traces contain tokens; redact before serialization

### File 42: Mobile Application Security

- **Schema**: `MobileAppProgress`
- **Output Type**: `MobileAppModuleProgress`
- **File**: `42-Mobile-Application-Security-Learning.md`
- **Key Fields**: apk-analysis, ios-binary-audit, certificate-pinning, mobile-backend
- **Serialization Notes**: Binary analysis results should store hashes, not full binaries

### File 43: IoT and Embedded Device Security

- **Schema**: `IoTProgress`
- **Output Type**: `IoTModuleProgress`
- **File**: `43-IoT-and-Embedded-Device-Security-Learning.md`
- **Key Fields**: firmware-analysis, hardware-attacks, mqtt-security, upnp-exploitation
- **Serialization Notes**: Firmware metadata should include hashes and version info

### File 44: API Security and GraphQL

- **Schema**: `APISecProgress`
- **Output Type**: `APISecModuleProgress`
- **File**: `44-API-Security-and-GraphQL-Learning.md`
- **Key Fields**: api-authentication, rate-limiting-bypass, mass-assignment, graphql-dos
- **Serialization Notes**: API endpoint maps should be stored as adjacency lists

### File 45: WebAssembly and Modern Web Technologies

- **Schema**: `WasmProgress`
- **Output Type**: `WasmModuleProgress`
- **File**: `45-WebAssembly-and-Modern-Web-Technologies-Learning.md`
- **Key Fields**: wasm-reverse-engineering, memory-corruption, wasm-sandbox-escape
- **Serialization Notes**: Wasm bytecodes should be stored as hex, not raw bytes

### File 46: Blockchain and Cryptocurrency Security

- **Schema**: `BlockchainProgress`
- **Output Type**: `BlockchainModuleProgress`
- **File**: `46-Blockchain-and-Cryptocurrency-Security-Learning.md`
- **Key Fields**: smart-contract-audit, reentrancy, flash-loan, oracle-manipulation
- **Serialization Notes**: Contract bytecode and transaction traces can be very large

### File 47: Automation and Tool Development

- **Schema**: `AutomationProgress`
- **Output Type**: `AutomationModuleProgress`
- **File**: `47-Automation-and-Tool-Development-Learning.md`
- **Key Fields**: tool-creation, workflow-design, api-integration, result-parsing
- **Serialization Notes**: Tool configurations should be serialized as nested objects

### File 48: Advanced Reverse Engineering

- **Schema**: `ReverseEngProgress`
- **Output Type**: `ReverseEngModuleProgress`
- **File**: `48-Advanced-Reverse-Engineering-Learning.md`
- **Key Fields**: binary-analysis, decompilation, anti-analysis-bypass, dynamic-analysis
- **Serialization Notes**: RE annotations should be stored as structured tags

### File 49: Compliance and Regulatory Security

- **Schema**: `ComplianceProgress`
- **Output Type**: `ComplianceModuleProgress`
- **File**: `49-Compliance-and-Regulatory-Security-Learning.md`
- **Key Fields**: pci-dss, hipaa, gdpr, sox-compliance, audit-preparation
- **Serialization Notes**: Compliance checklists should be stored as boolean matrices

### File 50: Advanced Threat Modeling and Risk Assessment

- **Schema**: `ThreatModelProgress`
- **Output Type**: `ThreatModelModuleProgress`
- **File**: `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md`
- **Key Fields**: stride-analysis, attack-trees, risk-scoring, threat-integration
- **Serialization Notes**: Threat model graphs can be large; use streaming serialization
