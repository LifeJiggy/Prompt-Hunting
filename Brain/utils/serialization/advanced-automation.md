# Data Serialization — Advanced Automation Domain (Scanning)

---

## Title / Metadata

```yaml
domain: advanced-automation
category: scanning
version: 1.0.0
created: 2026-06-26
author: Brain Serialization Module
serializer_module: Brain.utils.serialization
registry_ref: Advanced-Automation/registry.json
total_files: 50
serialization_formats: [json, yaml, msgpack, protobuf]
compression_algorithms: [gzip, zlib, brotli]
type_preservation: true
schema_version: 2
description: >
  Defines the complete serialization contract for the Advanced-Automation
  scanning domain. Every automation file in Advanced-Automation/ produces
  structured output that must be serializable, deserializable, compressible,
  and pipeline-integrable. This document specifies the schemas, operations,
  format bindings, and registry mappings required.
```

---

## Overview

The Advanced-Automation domain encompasses 50 automation files covering the full
attack-surface lifecycle — from subdomain enumeration through workflow orchestration.
Each file defines a discrete automation capability whose outputs, inputs, and
intermediate state must survive serialization round-trips without data loss.

This serialization layer sits between the automation scripts and the Brain runtime,
ensuring that:

1. Every scan result can be persisted in any supported wire/storage format.
2. Type fidelity (datetimes, enums, UUIDs, bytes) survives encode/decode cycles.
3. Large scan outputs compress transparently when above threshold.
4. The registry maps each automation file to its exact serialization schema.
5. Pipeline orchestration can deserialize any automation output without knowing
   which tool produced it.

The 50 files group into five functional clusters:

| Cluster | Files | Purpose |
|---------|-------|---------|
| **Recon & Enumeration** | 01-05, 23-25, 40-42, 44-48 | Asset discovery, scope, tracking |
| **Vulnerability Scanning** | 03, 06-20, 36-39 | Active vuln detection |
| **Analysis & Reporting** | 04, 21-22, 29, 35 | Result processing, PoC, reports |
| **Infrastructure & Tooling** | 26-28, 30-34 | Monitoring, chaining, proxy, browser |
| **OSINT & Compliance** | 43, 49-50 | Social media, compliance, orchestration |

---

## Domain Mapping — File-to-Schema Registry

Every automation file maps to a named serialization schema. The registry is
authoritative; the mapping below is the human-readable reference.

```json
{
  "domain": "advanced-automation",
  "schemas": {
    "01-subdomain-enumeration":       { "file": "01-Subdomain-Enumeration-Automation.md",       "schema": "SubdomainEnumerationResult",   "output_type": "list<Subdomain>" },
    "02-port-scanning":               { "file": "02-Port-Scanning-Automation.md",               "schema": "PortScanResult",               "output_type": "list<PortRecord>" },
    "03-vulnerability-scanning":      { "file": "03-Vulnerability-Scanning-Automation.md",      "schema": "VulnScanResult",               "output_type": "list<VulnFinding>" },
    "04-javascript-analysis":         { "file": "04-JavaScript-Analysis-Automation.md",         "schema": "JSAnalysisResult",             "output_type": "JSAnalysis" },
    "05-api-endpoint-discovery":      { "file": "05-API-Endpoint-Discovery.md",                  "schema": "APIEndpointResult",            "output_type": "list<Endpoint>" },
    "06-parameter-fuzzing":           { "file": "06-Parameter-Fuzzing-Automation.md",           "schema": "FuzzResult",                   "output_type": "list<FuzzHit>" },
    "07-directory-brute-forcing":     { "file": "07-Directory-Brute-Forcing.md",                "schema": "DirBruteResult",               "output_type": "list<DirHit>" },
    "09-authentication-testing":      { "file": "09-Authentication-Testing-Automation.md",      "schema": "AuthTestResult",               "output_type": "AuthTestReport" },
    "10-session-management":          { "file": "10-Session-Management-Testing.md",             "schema": "SessionTestResult",            "output_type": "SessionTestReport" },
    "11-idor-detection":              { "file": "11-IDOR-Detection-Automation.md",              "schema": "IDORResult",                   "output_type": "list<IDORFinding>" },
    "12-sql-injection":               { "file": "12-SQL-Injection-Automation.md",               "schema": "SQLiResult",                   "output_type": "list<SQLiFinding>" },
    "13-xss-detection":               { "file": "13-XSS-Detection-Automation.md",               "schema": "XSSResult",                    "output_type": "list<XSSFinding>" },
    "14-ssrf-testing":                { "file": "14-SSRF-Testing-Automation.md",                "schema": "SSRFResult",                   "output_type": "list<SSRFFinding>" },
    "15-csrf-testing":                { "file": "15-CSRF-Testing-Automation.md",                "schema": "CSRFResult",                   "output_type": "list<CSRFFinding>" },
    "16-command-injection":           { "file": "16-Command-Injection-Automation.md",           "schema": "CMDiResult",                   "output_type": "list<CMDiFinding>" },
    "17-xxe-testing":                 { "file": "17-XXE-Testing-Automation.md",                 "schema": "XXEResult",                    "output_type": "list<XXEFinding>" },
    "18-ssti-testing":                { "file": "18-SSTI-Testing-Automation.md",                "schema": "SSTIResult",                   "output_type": "list<SSTIFinding>" },
    "19-jwt-testing":                 { "file": "19-JWT-Testing-Automation.md",                 "schema": "JWTTestResult",                "output_type": "list<JWTFinding>" },
    "20-deserialization-testing":     { "file": "20-Deserialization-Testing.md",               "schema": "DeserResult",                  "output_type": "list<DeserFinding>" },
    "21-report-generation":           { "file": "21-Report-Generation-Automation.md",           "schema": "ReportOutput",                 "output_type": "Report" },
    "22-poc-development":             { "file": "22-PoC-Development-Automation.md",             "schema": "PoCOutput",                    "output_type": "PoC" },
    "23-target-scouting":             { "file": "23-Target-Scouting-Automation.md",             "schema": "ScoutResult",                  "output_type": "ScoutReport" },
    "24-scope-validation":            { "file": "24-Scope-Validation-Automation.md",            "schema": "ScopeValidationResult",        "output_type": "ScopeReport" },
    "25-asset-tracking":              { "file": "25-Asset-Tracking-Automation.md",              "schema": "AssetTrackingResult",          "output_type": "AssetGraph" },
    "26-change-monitoring":           { "file": "26-Change-Monitoring-Automation.md",           "schema": "ChangeMonitorResult",          "output_type": "list<ChangeEvent>" },
    "27-notification-alerting":       { "file": "27-Notification-Alerting-Automation.md",       "schema": "AlertResult",                  "output_type": "list<Alert>" },
    "28-data-collection":             { "file": "28-Data-Collection-Automation.md",             "schema": "DataCollectionResult",         "output_type": "DataBundle" },
    "29-result-analysis":             { "file": "29-Result-Analysis-Automation.md",             "schema": "AnalysisResult",               "output_type": "AnalysisReport" },
    "30-tool-chaining":               { "file": "30-Tool-Chaining-Automation.md",               "schema": "ChainResult",                  "output_type": "ChainOutput" },
    "31-proxy-integration":           { "file": "31-Proxy-Integration-Automation.md",           "schema": "ProxyResult",                  "output_type": "ProxyLog" },
    "32-browser-automation":          { "file": "32-Browser-Automation-Workflows.md",          "schema": "BrowserResult",                "output_type": "BrowserOutput" },
    "33-headless-browser":            { "file": "33-Headless-Browser-Scripting.md",             "schema": "HeadlessResult",               "output_type": "HeadlessOutput" },
    "34-regex-patterns":              { "file": "34-Regex-Pattern-Automation.md",               "schema": "RegexResult",                  "output_type": "list<RegexMatch>" },
    "35-response-analysis":           { "file": "35-Response-Analysis-Automation.md",           "schema": "ResponseAnalysisResult",       "output_type": "ResponseAnalysis" },
    "36-header-injection":            { "file": "36-Header-Injection-Testing.md",               "schema": "HeaderInjectionResult",        "output_type": "list<HeaderFinding>" },
    "37-cors-testing":                { "file": "37-CORS-Testing-Automation.md",                "schema": "CORSResult",                   "output_type": "CORSReport" },
    "38-websocket-testing":           { "file": "38-WebSocket-Testing-Automation.md",           "schema": "WSResult",                     "output_type": "list<WSFinding>" },
    "39-graphql-testing":             { "file": "39-GraphQL-Testing-Automation.md",             "schema": "GraphQLResult",                "output_type": "GraphQLReport" },
    "40-cloud-service-enum":          { "file": "40-Cloud-Service-Enumeration.md",              "schema": "CloudEnumResult",              "output_type": "list<CloudAsset>" },
    "41-dns-data-extraction":         { "file": "41-DNS-Data-Extraction-Automation.md",         "schema": "DNSExtractionResult",          "output_type": "DNSDataBundle" },
    "42-email-recon":                 { "file": "42-Email-Recon-Automation.md",                 "schema": "EmailReconResult",             "output_type": "EmailReconReport" },
    "43-social-media-osint":          { "file": "43-Social-Media-OSINT-Automation.md",         "schema": "OSINTResult",                  "output_type": "OSINTReport" },
    "44-framework-detection":         { "file": "44-Framework-Detection-Automation.md",         "schema": "FrameworkDetectResult",        "output_type": "list<Framework>" },
    "45-tech-stack-identification":   { "file": "45-Technology-Stack-Identification.md",        "schema": "TechStackResult",              "output_type": "TechStack" },
    "46-endpoint-mapping":            { "file": "46-Endpoint-Mapping-Automation.md",            "schema": "EndpointMapResult",            "output_type": "EndpointGraph" },
    "47-content-discovery":           { "file": "47-Content-Discovery-Automation.md",           "schema": "ContentDiscoveryResult",       "output_type": "list<ContentHit>" },
    "48-version-detection":           { "file": "48-Version-Detection-Automation.md",           "schema": "VersionDetectResult",          "output_type": "list<VersionInfo>" },
    "49-compliance-checking":         { "file": "49-Compliance-Checking-Automation.md",         "schema": "ComplianceResult",             "output_type": "ComplianceReport" },
    "50-workflow-orchestration":      { "file": "50-Workflow-Orchestration-Automation.md",      "schema": "WorkflowResult",               "output_type": "WorkflowOutput" }
  }
}
```

---

## Format Support

### JSON — Primary Interchange

JSON is the default wire format for all scanning outputs. The serializer uses
`json.dumps` with `ensure_ascii=False` and configurable indentation.

```python
from Brain.utils.serialization import Serializer

s = Serializer(default_format="json")
scan_output = {"targets": ["10.0.0.1"], "findings": [...]}
wire = s.encode(scan_output, format="json")
# Returns UTF-8 bytes with proper escaping
```

Scan-specific JSON extensions:
- `__scan_meta` block injected at root with scan_id, tool, timestamp, domain
- Null values preserved (unlike YAML which may collapse empty maps)
- Arrays of heterogeneous objects supported (mixed finding types)

### YAML — Human-Readable Config & Reports

YAML is used for configuration files, human-readable reports, and registry
definitions. The serializer wraps PyYAML with anchor support disabled for
deterministic output.

```python
wire = s.encode(scan_output, format="yaml")
# Produces readable indented output suitable for diff/review
```

Scan-specific YAML conventions:
- Multi-line strings for payloads (`|` literal block)
- Anchors for repeated target definitions
- Comments stripped on round-trip (YAML does not preserve comments)

### MessagePack — High-Throughput Binary

MessagePack is the preferred format for inter-process scan result transfer and
cache storage. Produces 30-50% smaller payloads than JSON for typical scan data.

```python
wire = s.encode(scan_output, format="msgpack")
# Compact binary, ideal for Redis/IPC between scanner modules
```

Scan-specific MessagePack usage:
- Port scan results with 10K+ records benefit most
- Finding lists with repetitive key structures compress well
- Streaming encode for real-time scan output

### Protocol Buffers — Schema-Enforced

Protocol Buffers provide field-level validation and backward-compatible schema
evolution for critical scan pipelines.

```python
from Brain.utils.serialization import ProtoSerializer

proto = ProtoSerializer(schema_path="schemas/scanning.proto")
encoded = proto.encode("PortScanResult", scan_output)
decoded = proto.decode("PortScanResult", encoded)
```

Scan-specific Protobuf definitions:
- `ScanTarget` — IP, hostname, scope, metadata
- `PortRecord` — port, state, service, version, banner
- `VulnFinding` — id, severity, cvss, evidence, remediation
- `WorkflowStep` — tool, input_ref, output_ref, status, timing

---

## Scan Result Serialization

### Common Scan Result Envelope

Every automation output wraps in a common envelope before serialization:

```json
{
  "__envelope": {
    "domain": "advanced-automation",
    "schema": "PortScanResult",
    "scan_id": "scan_abc123",
    "tool": "nmap",
    "started_at": "2026-06-26T10:00:00Z",
    "completed_at": "2026-06-26T10:02:35Z",
    "format_version": "2.0.0"
  },
  "targets": ["10.0.0.1", "10.0.0.2"],
  "results": [...]
}
```

### Finding Object Schema

All vulnerability-scanning files (03, 09-20, 36-39) produce findings conforming
to:

```json
{
  "id": "uuid",
  "type": "sql-injection|xss|ssrf|...",
  "severity": "critical|high|medium|low|info",
  "cvss_score": 9.8,
  "cvss_vector": "CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H",
  "title": "SQL Injection in login parameter",
  "description": "...",
  "evidence": {
    "request": "POST /login ...",
    "response_snippet": "...",
    "payload": "' OR 1=1 --",
    "sanitized_output": "..."
  },
  "affected_url": "https://target.com/login",
  "affected_parameter": "username",
  "remediation": "...",
  "references": ["CWE-89", "OWASP-A03"],
  "confidence": "confirmed|likely|possible",
  "timestamp": "2026-06-26T10:01:00Z",
  "tags": ["auth-bypass", "input-validation"]
}
```

### Port Scan Result Schema

From `02-Port-Scanning-Automation.md`:

```json
{
  "target": "10.0.0.1",
  "scan_type": "full|quick|stealth",
  "open_ports": [
    {
      "port": 443,
      "protocol": "tcp",
      "state": "open",
      "service": "https",
      "version": "nginx/1.24.0",
      "banner": "...",
      "response_time_ms": 12
    }
  ],
  "closed_ports": [21, 22, 25],
  "filtered_ports": [53],
  "scan_duration_ms": 145000
}
```

### Subdomain Enumeration Schema

From `01-Subdomain-Enumeration-Automation.md`:

```json
{
  "root_domain": "example.com",
  "method": "passive|active|hybrid",
  "subdomains": [
    {
      "fqdn": "api.example.com",
      "ip": "10.0.1.5",
      "source": "crt.sh|dns brute|amass",
      "first_seen": "2026-06-26T10:00:00Z",
      "last_seen": "2026-06-26T10:00:00Z",
      "alive": true,
      "http_status": 200
    }
  ],
  "total_found": 142,
  "new_since_last_scan": 3
}
```

### Workflow Orchestration Schema

From `50-Workflow-Orchestration-Automation.md`:

```json
{
  "workflow_id": "wf_xyz789",
  "name": "full-recon-pipeline",
  "status": "completed|running|failed",
  "steps": [
    {
      "step_id": 1,
      "automation_file": "01-Subdomain-Enumeration-Automation.md",
      "input_ref": "targets.json",
      "output_ref": "subdomains.json",
      "status": "completed",
      "started_at": "...",
      "completed_at": "...",
      "error": null
    }
  ],
  "total_duration_ms": 300000,
  "output_artifacts": ["subdomains.json", "ports.json", "vulns.json"]
}
```

---

## Serialize Operations

### Single Object Serialization

```python
from Brain.utils.serialization import Serializer

s = Serializer(default_format="json")

# Encode a scan result
scan_result = {
    "scan_id": "scan_001",
    "tool": "nuclei",
    "findings": [...]
}
encoded = s.encode(scan_result)                    # JSON bytes
encoded = s.encode(scan_result, format="msgpack")  # MessagePack bytes
encoded = s.encode(scan_result, format="yaml")     # YAML bytes
```

### With Scan Metadata Injection

```python
encoded = s.encode(
    scan_result,
    format="json",
    meta={"domain": "advanced-automation", "schema": "VulnScanResult"}
)
# Injects __envelope block automatically
```

### Compression on Encode

```python
s = Serializer(compression="gzip", compression_threshold=1024)
encoded = s.encode(large_scan_output)
# Auto-compresses if >1024 bytes; raw bytes include compression header
```

### Stream Encoding for Large Scans

```python
# Memory-efficient for 100K+ port records
for chunk in s.stream_encode(port_iterator(), format="msgpack", chunk_size=500):
    write_to_redis(chunk)
```

---

## Deserialize Operations

### Single Object Deserialization

```python
decoded = s.decode(encoded_bytes)
decoded = s.decode(encoded_bytes, format="msgpack")
decoded = s.decode(encoded_bytes, format="yaml")
```

### Auto-Detect Format

```python
# Format detected from magic bytes / content prefix
decoded = s.decode(data)  # format auto-detected
```

### Deserialization with Schema Validation

```python
decoded = s.decode(
    encoded_bytes,
    expected_schema="VulnScanResult",
    validate=True
)
# Raises SchemaValidationError if structure doesn't match
```

### Deserializing Compressed Data

```python
# Compression auto-detected on decode
compressed = s.encode(data, compression="gzip")
original = s.decode(compressed)  # decompresses transparently
```

### Batch Deserialization

```python
# Decode multiple objects from a concatenated stream
results = s.decode_batch(encoded_batch, format="msgpack")
# Returns list of deserialized objects
```

---

## Compression

### Algorithm Selection for Scan Data

| Algorithm | Scan Data Type | Ratio | Speed | Use Case |
|-----------|---------------|-------|-------|----------|
| gzip      | Port scan results (10K+ records) | 60-70% | Medium | Persistent storage |
| gzip      | Vulnerability findings | 50-65% | Medium | Report archival |
| zlib      | Real-time scan stream | 40-55% | Fast | IPC between scanner modules |
| brotli    | Large JS analysis dumps | 70-80% | Slow | Final report compression |
| none      | Small payloads (<1KB) | 0% | Fastest | API responses |

### Compression Thresholds

```python
# Domain-specific thresholds
COMPRESSION_THRESHOLDS = {
    "subdomain-enumeration": 512,    # Compress if >512 bytes
    "port-scanning": 1024,           # Compress if >1KB
    "vulnerability-scanning": 768,   # Compress if >768 bytes
    "javascript-analysis": 2048,     # JS dumps are large; compress early
    "workflow-orchestration": 4096,  # Orchestrator payloads are big
    "data-collection": 1536,         # Collected data bundles
    "default": 1024
}
```

### Compressed Format Detection

The serializer auto-detects compressed content via magic bytes:
- gzip: `0x1f 0x8b`
- zlib: `0x78 0x9c` (default compression level)
- brotli: `0xce 0xb2 0xcf 0x81`

---

## Type Preservation

### Python Types in Scan Data

Scan automation produces several Python-specific types that survive round-trips:

```python
{
    "scan_started": datetime(2026, 6, 26, 10, 0, 0, tzinfo=UTC),  # datetime
    "scan_id": UUID("123e4567-e89b-12d3-a456-426614174000"),       # UUID
    "cvss_score": Decimal("9.8"),                                    # Decimal
    "response_body": b"<html>...</html>",                           # bytes
    "open_ports": {443, 8443, 9443},                                # set
    "scan_hash": b"\x1f\x8b\x08..."                                # bytes
}
```

### Type Tag Encoding

Non-native types wrap in `$type`/`$value` pairs:

```json
{"$type": "datetime", "$value": "2026-06-26T10:00:00+00:00"}
{"$type": "uuid", "$value": "123e4567-e89b-12d3-a456-426614174000"}
{"$type": "decimal", "$value": "9.8"}
{"$type": "bytes", "$value": "AAEC"}
{"$type": "set", "$value": [443, 8443, 9443]}
```

### Scan-Specific Type Tags

```json
{"$type": "severity_enum", "$value": "high"}
{"$type": "scan_status", "$value": "completed"}
{"$type": "port_record", "$value": {"port": 443, "state": "open"}}
```

---

## Custom Serializers

### Scan Finding Serializer

```python
from Brain.utils.serialization import register_encoder

@register_encoder(VulnFinding)
def encode_finding(obj):
    return {
        "$type": "vuln_finding",
        "id": str(obj.id),
        "type": obj.type,
        "severity": obj.severity.value,
        "cvss_score": float(obj.cvss_score),
        "evidence": obj.evidence,
        "timestamp": {"$type": "datetime", "$value": obj.timestamp.isoformat()}
    }
```

### Port Record Serializer

```python
@register_encoder(PortRecord)
def encode_port(obj):
    return {
        "$type": "port_record",
        "port": obj.port,
        "protocol": obj.protocol.value,
        "state": obj.state.value,
        "service": obj.service,
        "version": obj.version,
        "banner": {"$type": "bytes", "$value": obj.banner_b64} if obj.banner else None
    }
```

### Workflow Step Serializer

```python
@register_encoder(WorkflowStep)
def encode_step(obj):
    return {
        "$type": "workflow_step",
        "step_id": obj.step_id,
        "automation_file": obj.automation_file,
        "status": obj.status.value,
        "started_at": {"$type": "datetime", "$value": obj.started_at.isoformat()},
        "completed_at": {"$type": "datetime", "$value": obj.completed_at.isoformat()} if obj.completed_at else None,
        "error": obj.error
    }
```

### Deserializer Registry

```python
custom_decoders = {
    "vuln_finding": decode_finding,
    "port_record": decode_port,
    "workflow_step": decode_step,
    "scan_envelope": decode_envelope,
    "subdomain_record": decode_subdomain,
    "endpoint_record": decode_endpoint,
    "fuzz_hit": decode_fuzz_hit,
    "dir_hit": decode_dir_hit,
    "auth_test_report": decode_auth_test,
    "idor_finding": decode_idor,
    "sqli_finding": decode_sqli,
    "xss_finding": decode_xss,
    "ssrf_finding": decode_ssrf,
    "csrf_finding": decode_csrf,
    "cmdi_finding": decode_cmdi,
    "xxe_finding": decode_xxe,
    "ssti_finding": decode_ssti,
    "jwt_finding": decode_jwt,
    "deser_finding": decode_deser,
    "header_finding": decode_header,
    "cors_report": decode_cors,
    "ws_finding": decode_ws,
    "graphql_report": decode_graphql,
    "cloud_asset": decode_cloud,
    "dns_bundle": decode_dns,
    "email_recon": decode_email,
    "osint_report": decode_osint,
    "framework_record": decode_framework,
    "tech_stack": decode_tech,
    "endpoint_graph": decode_endpoint_graph,
    "content_hit": decode_content,
    "version_info": decode_version,
    "compliance_report": decode_compliance,
    "change_event": decode_change,
    "alert": decode_alert,
    "regex_match": decode_regex,
    "response_analysis": decode_response,
    "browser_output": decode_browser,
    "headless_output": decode_headless,
    "proxy_log": decode_proxy,
    "data_bundle": decode_data,
    "analysis_report": decode_analysis,
    "chain_output": decode_chain,
    "poc_output": decode_poc,
    "report": decode_report,
    "scout_report": decode_scout,
    "scope_report": decode_scope,
    "asset_graph": decode_asset_graph
}
```

---

## Format Detection

### Detection Logic for Scan Outputs

```python
from Brain.utils.serialization import detect_format

# Port scan JSON
detect_format(b'{"open_ports": [{"port": 443}]}')  # "json"

# Subdomain YAML config
detect_format(b'---\ntargets:\n  - 10.0.0.1\n')  # "yaml"

# Compressed vulnerability findings
detect_format(b'\x1f\x8b\x08\x00...')  # "gzip" (compressed content)

# Binary scan cache
detect_format(b'\x94\xa5ports\xa3tcp...')  # "msgpack"

# Protobuf-encoded workflow
detect_format(b'\x0a\x0fscan_abc123\x12\x04nmap')  # "protobuf"
```

### Scan-Specific Detection Rules

| Pattern | Format | Source Automation |
|---------|--------|-------------------|
| `{` or `[` prefix | JSON | All 50 files |
| `---` prefix | YAML | Config files, registry |
| `0x1f 0x8b` | gzip | Compressed cache |
| `0x78` | zlib | IPC stream |
| `0x90-0x9f` | msgpack | Binary storage |
| Protobuf varint prefix | protobuf | Schema-enforced pipelines |

---

## Batch Operations

### Batch Encoding for Scan Pipelines

```python
from Brain.utils.serialization import Serializer

s = Serializer()

# Batch encode multiple scan results
scan_results = [result_01, result_02, result_03, ...]  # from 50 automations
batch_wire = s.encode_batch(scan_results, format="msgpack")

# Decode batch
decoded_results = s.decode_batch(batch_wire)
```

### Streaming for Large Datasets

```python
# Subdomain enumeration with 100K+ records
for chunk in s.stream_encode(subdomain_stream(), format="msgpack", chunk_size=1000):
    write_to_persistent_store(chunk)

# Port scan streaming
for chunk in s.stream_encode(port_stream(), format="jsonl", chunk_size=500):
    append_to_file(chunk)
```

### Batch Compression

```python
# Compress entire batch
compressed_batch = s.encode_batch(findings, format="msgpack", compression="gzip")

# Individual compression thresholds still apply per record
```

---

## Registry Schema

### Top-Level Registry Structure

```json
{
  "domain": "advanced-automation",
  "version": "1.0.0",
  "total_files": 50,
  "serialization_version": "2.0.0",
  "clusters": {
    "recon-enumeration": {
      "description": "Asset discovery, scope validation, tracking",
      "files": ["01", "02", "04", "05", "23", "24", "25", "40", "41", "42", "44", "45", "46", "47", "48"],
      "primary_format": "json",
      "compression": "gzip"
    },
    "vulnerability-scanning": {
      "description": "Active vulnerability detection and exploitation",
      "files": ["03", "06", "07", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "36", "37", "38", "39"],
      "primary_format": "json",
      "compression": "gzip"
    },
    "analysis-reporting": {
      "description": "Result processing, PoC development, report generation",
      "files": ["21", "22", "29", "35"],
      "primary_format": "yaml",
      "compression": "brotli"
    },
    "infrastructure-tooling": {
      "description": "Monitoring, chaining, proxy integration, browser automation",
      "files": ["26", "27", "28", "30", "31", "32", "33", "34"],
      "primary_format": "msgpack",
      "compression": "zlib"
    },
    "osint-compliance": {
      "description": "Social media OSINT, compliance checking, workflow orchestration",
      "files": ["43", "49", "50"],
      "primary_format": "json",
      "compression": "gzip"
    }
  },
  "schema_registry": "schemas/advanced-automation.proto"
}
```

### Per-File Registry Entry

```json
{
  "id": "03-vulnerability-scanning",
  "file": "03-Vulnerability-Scanning-Automation.md",
  "schema": "VulnScanResult",
  "output_type": "list<VulnFinding>",
  "serialization": {
    "primary_format": "json",
    "binary_format": "msgpack",
    "config_format": "yaml",
    "compression": "gzip",
    "compression_threshold": 768,
    "type_preserving": true,
    "custom_types": ["VulnFinding", "Evidence", "CVSSVector"]
  },
  "dependencies": ["01-subdomain-enumeration", "02-port-scanning"],
  "consumed_by": ["21-report-generation", "29-result-analysis", "50-workflow-orchestration"]
}
```

---

## Error Handling

### Serialization Errors

```python
class ScanSerializationError(Exception):
    """Base error for scan serialization failures."""
    pass

class SchemaValidationError(ScanSerializationError):
    """Raised when output doesn't match expected schema."""
    def __init__(self, expected, actual, path="root"):
        self.expected = expected
        self.actual = actual
        self.path = path
        super().__init__(f"Schema mismatch at {path}: expected {expected}, got {actual}")

class FormatDetectionError(ScanSerializationError):
    """Raised when format cannot be auto-detected."""
    pass

class CompressionError(ScanSerializationError):
    """Raised on compression/decompression failure."""
    pass

class TypePreservationError(ScanSerializationError):
    """Raised when a type cannot be round-tripped."""
    pass
```

### Error Handling in Scan Pipelines

```python
from Brain.utils.serialization import Serializer, ScanSerializationError

s = Serializer()

try:
    encoded = s.encode(scan_result, format="json")
except ScanSerializationError as e:
    logger.error(f"Serialization failed: {e}")
    # Fallback to string representation
    encoded = s.encode({"error": str(scan_result)}, format="json")

try:
    decoded = s.decode(unknown_data)
except FormatDetectionError:
    # Try each format
    for fmt in ["json", "yaml", "msgpack"]:
        try:
            decoded = s.decode(unknown_data, format=fmt)
            break
        except Exception:
            continue
    else:
        raise ScanSerializationError("Unable to decode scan data in any supported format")
```

### Error Recovery Patterns

```python
# Partial batch decode — skip corrupted records
def safe_decode_batch(data, format="msgpack"):
    results = []
    errors = []
    for i, record in enumerate(data):
        try:
            results.append(s.decode(record, format=format))
        except ScanSerializationError as e:
            errors.append({"index": i, "error": str(e)})
    return {"results": results, "errors": errors, "partial": bool(errors)}
```

---

## Pipeline Integration

### Scanner → Serializer → Storage

```python
from Brain.utils.serialization import Serializer

s = Serializer(
    default_format="json",
    compression="gzip",
    compression_threshold=1024,
    type_preserving=True
)

# Pipeline: scan → serialize → store
scan_result = run_subdomain_enum(targets)       # Automation 01
encoded = s.encode(scan_result, format="msgpack")
store_to_cache(scan_id, encoded)                # Redis / file

# Pipeline: retrieve → deserialize → analyze
cached = retrieve_from_cache(scan_id)
result = s.decode(cached, expected_schema="SubdomainEnumerationResult")
analysis = analyze_results(result)              # Automation 29
```

### Cross-Automation Data Flow

```
01-Subdomain-Enumeration ──→ 02-Port-Scanning ──→ 03-Vulnerability-Scanning
         │                          │                        │
         ▼                          ▼                        ▼
    [json cache]              [msgpack cache]           [json cache]
         │                          │                        │
         └──────────────────────────┼────────────────────────┘
                                    ▼
                           29-Result-Analysis
                                    │
                                    ▼
                           21-Report-Generation
```

Each arrow represents a serialize → store → retrieve → deserialize cycle.

### Pipeline Configuration

```yaml
# pipeline_config.yaml
serialization:
  default_format: json
  cache_format: msgpack
  compression: gzip
  compression_threshold: 1024
  type_preserving: true

pipeline:
  steps:
    - automation: 01-Subdomain-Enumeration
      input: targets.yaml
      output: subdomains.msgpack
      format: msgpack
    - automation: 02-Port-Scanning
      input: subdomains.msgpack
      output: ports.json
      format: json
      compression: gzip
    - automation: 03-Vulnerability-Scanning
      input: ports.json
      output: vulns.json
      format: json
      compression: gzip
    - automation: 29-Result-Analysis
      input: vulns.json
      output: analysis.yaml
      format: yaml
    - automation: 21-Report-Generation
      input: analysis.yaml
      output: report.md
      format: text
```

---

## Full Domain File References

### Reconnaissance & Enumeration Cluster

| # | File | Schema | Key Types | Formats |
|---|------|--------|-----------|---------|
| 01 | `01-Subdomain-Enumeration-Automation.md` | SubdomainEnumerationResult | Subdomain, DNSRecord | json, msgpack |
| 02 | `02-Port-Scanning-Automation.md` | PortScanResult | PortRecord, ServiceInfo | json, msgpack |
| 04 | `04-JavaScript-Analysis-Automation.md` | JSAnalysisResult | JSEndpoint, Secret, Link | json, yaml |
| 05 | `05-API-Endpoint-Discovery.md` | APIEndpointResult | Endpoint, HTTPMethod, Param | json, msgpack |
| 23 | `23-Target-Scouting-Automation.md` | ScoutResult | Target, TechFingerprint | json |
| 24 | `24-Scope-Validation-Automation.md` | ScopeValidationResult | ScopeRule, ValidationResult | yaml |
| 25 | `25-Asset-Tracking-Automation.md` | AssetTrackingResult | Asset, AssetChange, History | json, msgpack |
| 40 | `40-Cloud-Service-Enumeration.md` | CloudEnumResult | CloudAsset, CloudProvider | json |
| 41 | `41-DNS-Data-Extraction-Automation.md` | DNSExtractionResult | DNSRecord, MXRecord, TXTRecord | json, yaml |
| 42 | `42-Email-Recon-Automation.md` | EmailReconResult | EmailAddress, Domain | json |
| 44 | `44-Framework-Detection-Automation.md` | FrameworkDetectResult | Framework, DetectionMethod | json |
| 45 | `45-Technology-Stack-Identification.md` | TechStackResult | TechComponent, Version | json, yaml |
| 46 | `46-Endpoint-Mapping-Automation.md` | EndpointMapResult | EndpointNode, Edge | json, msgpack |
| 47 | `47-Content-Discovery-Automation.md` | ContentDiscoveryResult | ContentHit, ContentPath | json |
| 48 | `48-Version-Detection-Automation.md` | VersionDetectResult | VersionInfo, CPE | json |

### Vulnerability Scanning Cluster

| # | File | Schema | Key Types | Formats |
|---|------|--------|-----------|---------|
| 03 | `03-Vulnerability-Scanning-Automation.md` | VulnScanResult | VulnFinding, Evidence | json, msgpack |
| 06 | `06-Parameter-Fuzzing-Automation.md` | FuzzResult | FuzzHit, Payload | json, msgpack |
| 07 | `07-Directory-Brute-Forcing.md` | DirBruteResult | DirHit, StatusCode | json |
| 09 | `09-Authentication-Testing-Automation.md` | AuthTestResult | AuthTestReport, Credential | json, yaml |
| 10 | `10-Session-Management-Testing.md` | SessionTestResult | SessionTestReport, Token | json, yaml |
| 11 | `11-IDOR-Detection-Automation.md` | IDORResult | IDORFinding, AccessControl | json, msgpack |
| 12 | `12-SQL-Injection-Automation.md` | SQLiResult | SQLiFinding, Payload | json, msgpack |
| 13 | `13-XSS-Detection-Automation.md` | XSSResult | XSSFinding, ReflectionPoint | json, msgpack |
| 14 | `14-SSRF-Testing-Automation.md` | SSRFResult | SSRFFinding, InternalService | json, msgpack |
| 15 | `15-CSRF-Testing-Automation.md` | CSRFResult | CSRFFinding, Token | json |
| 16 | `16-Command-Injection-Automation.md` | CMDiResult | CMDiFinding, Payload | json, msgpack |
| 17 | `17-XXE-Testing-Automation.md` | XXEResult | XXEFinding, XMLPayload | json |
| 18 | `18-SSTI-Testing-Automation.md` | SSTIResult | SSTIFinding, TemplateEngine | json |
| 19 | `19-JWT-Testing-Automation.md` | JWTTestResult | JWTFinding, JWTToken | json, msgpack |
| 20 | `20-Deserialization-Testing.md` | DeserResult | DeserFinding, DeserPayload | json |
| 36 | `36-Header-Injection-Testing.md` | HeaderInjectionResult | HeaderFinding, InjectedHeader | json |
| 37 | `37-CORS-Testing-Automation.md` | CORSResult | CORSReport, CORSConfig | json, yaml |
| 38 | `38-WebSocket-Testing-Automation.md` | WSResult | WSFinding, WSFrame | json |
| 39 | `39-GraphQL-Testing-Automation.md` | GraphQLResult | GraphQLReport, QuerySchema | json, msgpack |

### Analysis & Reporting Cluster

| # | File | Schema | Key Types | Formats |
|---|------|--------|-----------|---------|
| 21 | `21-Report-Generation-Automation.md` | ReportOutput | Report, FindingSummary | yaml, json |
| 22 | `22-PoC-Development-Automation.md` | PoCOutput | PoC, ReproductionStep | json, yaml |
| 29 | `29-Result-Analysis-Automation.md` | AnalysisResult | AnalysisReport, Trend | yaml, json |
| 35 | `35-Response-Analysis-Automation.md` | ResponseAnalysisResult | ResponseAnalysis, Pattern | json |

### Infrastructure & Tooling Cluster

| # | File | Schema | Key Types | Formats |
|---|------|--------|-----------|---------|
| 26 | `26-Change-Monitoring-Automation.md` | ChangeMonitorResult | ChangeEvent, Diff | msgpack, json |
| 27 | `27-Notification-Alerting-Automation.md` | AlertResult | Alert, AlertConfig | json |
| 28 | `28-Data-Collection-Automation.md` | DataCollectionResult | DataBundle, DataPoint | msgpack, json |
| 30 | `30-Tool-Chaining-Automation.md` | ChainResult | ChainOutput, ToolStep | json, msgpack |
| 31 | `31-Proxy-Integration-Automation.md` | ProxyResult | ProxyLog, ProxyConfig | json |
| 32 | `32-Browser-Automation-Workflows.md` | BrowserResult | BrowserOutput, PageState | json, msgpack |
| 33 | `33-Headless-Browser-Scripting.md` | HeadlessResult | HeadlessOutput, ScriptResult | json |
| 34 | `34-Regex-Pattern-Automation.md` | RegexResult | RegexMatch, Pattern | json |

### OSINT & Compliance Cluster

| # | File | Schema | Key Types | Formats |
|---|------|--------|-----------|---------|
| 43 | `43-Social-Media-OSINT-Automation.md` | OSINTResult | OSINTReport, SocialProfile | json |
| 49 | `49-Compliance-Checking-Automation.md` | ComplianceResult | ComplianceReport, Check | yaml, json |
| 50 | `50-Workflow-Orchestration-Automation.md` | WorkflowResult | WorkflowOutput, WorkflowStep | json, msgpack |

---

## Appendix A — Schema Definition Template

Every new automation file should include this serialization block:

```markdown
## Serialization Schema

```yaml
schema_name: <SchemaName>
output_type: <type>
formats: [json, msgpack]
compression: gzip
compression_threshold: 1024
type_preserving: true
custom_types:
  - name: <CustomType>
    fields: [field1, field2]
    encoders: [json, msgpack]
```

## Serialization Example

```json
{
  "__envelope": {
    "domain": "advanced-automation",
    "schema": "<SchemaName>",
    "scan_id": "scan_xxx"
  },
  "results": [...]
}
```
```

## Appendix B — Serialization Quick Reference

| Operation | Method | Default Format |
|-----------|--------|----------------|
| Encode | `s.encode(data)` | json |
| Decode | `s.decode(data)` | auto-detect |
| Batch encode | `s.encode_batch(list)` | json |
| Batch decode | `s.decode_batch(data)` | auto-detect |
| Stream encode | `s.stream_encode(iter)` | jsonl |
| Compress | `s.compress(data)` | gzip |
| Decompress | `s.decompress(data)` | auto-detect |
| Detect format | `detect_format(data)` | — |
| Register type | `register_encoder(cls)` | — |

## Appendix C — Compression Quick Reference

| Format | Magic Bytes | Header |
|--------|-------------|--------|
| gzip   | `1f 8b`     | 10 bytes |
| zlib   | `78 9c`     | 2 bytes |
| brotli | `ce b2 cf 81` | 1 byte |

## Appendix D — Cross-References

- `Brain/utils/serialization/README.md` — Core serialization module docs
- `Advanced-Automation/registry.json` — Authoritative file registry
- `Brain/runtime/` — Runtime engine that consumes serialized outputs
- `Brain/session-managements/` — Session state serialization
