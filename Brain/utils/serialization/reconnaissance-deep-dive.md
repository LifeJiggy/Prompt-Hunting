# Reconnaissance Deep-Dive — Data Serialization Specification

## Metadata

| Field       | Value                                           |
|-------------|-------------------------------------------------|
| Domain      | reconnaissance-deep-dive                        |
| Version     | 1.0.0                                           |
| Format      | Multi-format (JSON, YAML, MessagePack, Protobuf)|
| Scope       | Recon asset lifecycle — discovery → enrichment → reporting |
| Total Assets| 50 domain files                                 |
| Author      | Prompt-Hunting Brain                            |
| Last Updated| 2026-06-26                                      |

---

## Domain Mapping

This domain covers the complete reconnaissance pipeline from initial subdomain enumeration through advanced multi-stage strategy. Each numbered file represents a distinct recon module whose data must be serialized, deserialized, and exchanged across the pipeline.

### File → Module Mapping

| ID  | File                                            | Category            | Data Volume |
|-----|-------------------------------------------------|---------------------|-------------|
| 01  | Advanced-Subdomain-Enumeration.md               | DNS & Naming        | High        |
| 02  | Passive-OSINT-Collection.md                     | Passive Recon       | Very High   |
| 03  | Active-Asset-Discovery.md                       | Active Recon        | High        |
| 04  | Technology-Stack-Fingerprinting.md              | Fingerprinting      | Medium      |
| 05  | Cloud-Resource-Enumeration.md                   | Cloud Recon         | High        |
| 06  | API-Endpoint-Discovery.md                       | API Recon           | High        |
| 07  | JavaScript-Source-Analysis.md                   | Client-Side Recon   | Medium      |
| 08  | Configuration-File-Extraction.md                | Config Recon        | Medium      |
| 09  | Version-Detection-Techniques.md                 | Version Fingerprint | Low         |
| 10  | Content-Discovery-Automation.md                 | Content Recon       | High        |
| 11  | Directory-Brute-Forcing.md                      | Directory Recon     | High        |
| 12  | File-Type-Detection.md                          | File Recon          | Low         |
| 13  | Backup-File-Discovery.md                        | Backup Recon        | Medium      |
| 14  | Source-Code-Leak-Detection.md                   | Code Leak Recon     | Medium      |
| 15  | Git-Repository-Analysis.md                      | Git Recon           | Medium      |
| 16  | DNS-Enumeration-Advanced.md                     | DNS Deep Recon      | High        |
| 17  | Certificate-Transparency-Logs.md                | CT Log Recon        | High        |
| 18  | Historical-Data-Analysis.md                     | Historical Recon    | Very High   |
| 19  | Social-Media-OSINT.md                           | Social Recon        | High        |
| 20  | Employee-Linked-Assets.md                       | Personnel Recon     | Medium      |
| 21  | Third-Party-Integration-Discovery.md            | Integration Recon   | Medium      |
| 22  | Web-Archive-Analysis.md                         | Archive Recon       | High        |
| 23  | Pastebin-and-Leak-Searching.md                  | Leak Recon          | Medium      |
| 24  | Code-Repository-Mining.md                       | Code Recon          | Medium      |
| 25  | Container-Registry-Enumeration.md               | Container Recon     | Medium      |
| 26  | IoT-Device-Discovery.md                         | IoT Recon           | Low         |
| 27  | Mobile-App-Analysis.md                          | Mobile Recon        | Medium      |
| 28  | API-Documentation-Extraction.md                 | API Docs Recon      | Medium      |
| 29  | WebSocket-Endpoint-Discovery.md                 | WebSocket Recon     | Low         |
| 30  | GraphQL-Introspection.md                        | GraphQL Recon       | Medium      |
| 31  | XML-RPC-and-SOAP-Discovery.md                   | Legacy API Recon    | Low         |
| 32  | Email-Address-Harvesting.md                     | Email Recon         | Medium      |
| 33  | Phone-Number-Enumeration.md                     | Phone Recon         | Low         |
| 34  | Physical-Location-Intelligence.md               | Physical Recon      | Low         |
| 35  | Supply-Chain-Asset-Mapping.md                   | Supply Chain Recon  | High        |
| 36  | Competitor-Analysis.md                          | Competitive Recon   | Medium      |
| 37  | Partner-Network-Discovery.md                    | Partner Recon       | Medium      |
| 38  | Acquisition-Target-Analysis.md                  | M&A Recon           | Medium      |
| 39  | Subsidiary-Asset-Mapping.md                     | Subsidiary Recon    | Medium      |
| 40  | Regional-Infrastructure-Mapping.md              | Regional Recon      | High        |
| 41  | Content-Management-System-Detection.md          | CMS Detection       | Low         |
| 42  | Framework-and-Library-Identification.md         | Framework Detection | Low         |
| 43  | Server-Configuration-Analysis.md                | Server Recon        | Medium      |
| 44  | SSL-TLS-Certificate-Analysis.md                 | TLS Recon           | Medium      |
| 45  | HTTP-Header-Intelligence.md                     | Header Recon        | Low         |
| 46  | Cookie-Analysis-and-Session-Management.md       | Session Recon       | Low         |
| 47  | Error-Page-Analysis.md                          | Error Recon         | Low         |
| 48  | Debug-Endpoint-Discovery.md                     | Debug Recon         | Low         |
| 49  | Staging-Environment-Detection.md                | Staging Recon       | Low         |
| 50  | Advanced-Reconnaissance-Strategy.md             | Strategy & Meta     | Very High   |

### Category Groupings

| Category            | File IDs | Serialization Priority |
|---------------------|----------|------------------------|
| DNS & Naming        | 01, 16   | Critical               |
| Passive Recon       | 02, 18, 19, 20, 23, 32, 33, 34 | Critical |
| Active Recon        | 03, 10, 11 | High                |
| Fingerprinting      | 04, 09, 41, 42, 44, 45, 47 | Medium  |
| Cloud Recon         | 05, 25, 40 | High               |
| API Recon           | 06, 28, 29, 30, 31 | High      |
| Client-Side Recon   | 07, 08, 12, 13, 14, 15 | Medium |
| Leak & Code Recon   | 14, 15, 24 | Medium            |
| Infrastructure Recon| 21, 26, 35, 37, 38, 39, 43, 46, 48, 49 | High |
| Strategy & Meta     | 36, 50   | Critical               |
| Archive Recon       | 22       | Medium                 |
| Mobile Recon        | 27       | Medium                 |

---

## Overview

The reconnaissance-deep-dive domain serializes structured and unstructured data produced by 50 specialized reconnaissance modules. The serialization layer must handle:

1. **Heterogeneous schemas** — each module outputs distinct data shapes (DNS records, HTTP responses, credential leaks, employee profiles, cloud resource manifests).
2. **Volume variation** — from single-host scans (low volume) to enterprise-wide enumerations (millions of records).
3. **Temporal sensitivity** — recon data has staleness; timestamps, TTLs, and cache validity windows must survive serialization round-trips.
4. **Cross-module correlation** — data from file 01 (subdomain enumeration) feeds into file 06 (API endpoint discovery), which feeds into file 30 (GraphQL introspection). Serialization schemas must preserve correlation keys.

### Design Principles

- **Schema-per-module**: Each of the 50 files has a canonical serialization schema registered in the domain registry.
- **Format-agnostic core**: The internal representation is format-independent; format-specific encoders/decoders are thin wrappers.
- **Backward-compatible evolution**: New fields are added with defaults; removed fields are marked deprecated, never deleted in the same major version.
- **Deterministic ordering**: Keys are sorted alphabetically in all text formats for diff-friendly outputs and reproducible hashing.

---

## Format Support

### JSON

Primary interchange format. Used for API payloads, file storage, and inter-process communication.

```json
{
  "domain": "reconnaissance-deep-dive",
  "module_id": 1,
  "module_file": "01-Advanced-Subdomain-Enumeration.md",
  "schema_version": "1.0.0",
  "timestamp": "2026-06-26T12:00:00Z",
  "assets": [
    {
      "asset_id": "sub-001",
      "type": "subdomain",
      "value": "api.example.com",
      "source": "certificate-transparency",
      "confidence": 0.95,
      "first_seen": "2026-01-15T08:30:00Z",
      "last_seen": "2026-06-26T12:00:00Z",
      "metadata": {
        "zone": "example.com",
        "dns_records": ["A", "CNAME"],
        "ip_addresses": ["93.184.216.34"],
        "ttl": 3600,
        "wildcard": false
      },
      "tags": ["production", "public-facing"],
      "correlation_keys": {
        "parent_asset": "example.com",
        "linked_modules": [6, 16, 44]
      }
    }
  ],
  "summary": {
    "total_assets": 1,
    "by_type": {"subdomain": 1},
    "by_confidence": {"high": 1},
    "execution_time_ms": 4500,
    "errors": []
  }
}
```

### YAML

Human-readable format for configuration files, documentation, and manual review.

```yaml
domain: reconnaissance-deep-dive
module_id: 1
module_file: 01-Advanced-Subdomain-Enumeration.md
schema_version: "1.0.0"
timestamp: "2026-06-26T12:00:00Z"
assets:
  - asset_id: sub-001
    type: subdomain
    value: api.example.com
    source: certificate-transparency
    confidence: 0.95
    first_seen: "2026-01-15T08:30:00Z"
    last_seen: "2026-06-26T12:00:00Z"
    metadata:
      zone: example.com
      dns_records: [A, CNAME]
      ip_addresses:
        - 93.184.216.34
      ttl: 3600
      wildcard: false
    tags:
      - production
      - public-facing
    correlation_keys:
      parent_asset: example.com
      linked_modules: [6, 16, 44]
summary:
  total_assets: 1
  by_type:
    subdomain: 1
  by_confidence:
    high: 1
  execution_time_ms: 4500
  errors: []
```

### MessagePack

Binary format for high-throughput inter-service communication and large batch transfers. Preserves all types including binary blobs (e.g., certificate DER data, raw HTTP response bodies).

MessagePack encoding rules:
- Integers 0–127 use positive fixint (1 byte).
- Strings use fixstr up to 31 bytes, str8/str16/str32 beyond.
- Timestamps use the ext type (fixext 8 for seconds-only, fixext 12 for nanoseconds).
- Binary data (certificates, response bodies) use bin8/bin16/bin32.
- Nil values preserved for optional fields — never omitted.

### Protocol Buffers (Protobuf)

Schema-enforced binary format for internal pipeline communication. Optimized for minimal wire size and fast deserialization.

```protobuf
syntax = "proto3";

package recon.deep_dive;

message ReconAsset {
  string asset_id = 1;
  string type = 2;
  string value = 3;
  string source = 4;
  float confidence = 5;
  string first_seen = 6;
  string last_seen = 7;
  map<string, string> metadata = 8;
  repeated string tags = 9;
  CorrelationKeys correlation_keys = 10;
}

message CorrelationKeys {
  string parent_asset = 1;
  repeated int32 linked_modules = 2;
}

message ReconModuleOutput {
  string domain = 1;
  int32 module_id = 2;
  string module_file = 3;
  string schema_version = 4;
  string timestamp = 5;
  repeated ReconAsset assets = 6;
  ModuleSummary summary = 7;
}

message ModuleSummary {
  int32 total_assets = 1;
  map<string, int32> by_type = 2;
  map<string, int32> by_confidence = 3;
  int64 execution_time_ms = 4;
  repeated string errors = 5;
}
```

### Format Comparison

| Feature               | JSON     | YAML     | MsgPack  | Protobuf |
|-----------------------|----------|----------|----------|----------|
| Human readable        | Yes      | Yes      | No       | No       |
| Schema enforced       | Optional | Optional | No       | Yes      |
| Binary support        | No       | No       | Yes      | Yes      |
| Compression ratio     | Medium   | Medium   | High     | Highest  |
| Parse speed           | Medium   | Low      | Fast     | Fastest  |
| Cross-language        | Yes      | Yes      | Yes      | Yes      |
| Default pipeline use  | Storage  | Config   | Wire     | Internal |

---

## Asset Serialization

### Canonical Asset Schema

Every asset across all 50 modules conforms to this base schema:

```json
{
  "asset_id": "string — globally unique, prefixed by module (e.g., sub-001, api-042)",
  "type": "string — asset classification (subdomain, ip_address, api_endpoint, credential, employee, etc.)",
  "value": "string — the primary value of the asset (domain name, IP, URL, email, etc.)",
  "source": "string — discovery source (module_id or named source)",
  "confidence": "float 0.0-1.0 — certainty of the asset's validity",
  "first_seen": "ISO 8601 timestamp — first discovery time",
  "last_seen": "ISO 8601 timestamp — most recent validation time",
  "metadata": "map<string, any> — module-specific structured data",
  "tags": "array<string> — user/system tags for filtering and grouping",
  "correlation_keys": {
    "parent_asset": "string — ID of the parent asset this was derived from",
    "linked_modules": "array<int> — module IDs that consume or produce this asset"
  }
}
```

### Module-Specific Metadata Schemas

Each module extends the base metadata map with domain-specific fields:

| Module ID | Module Name                          | Metadata Extension Fields                                                  |
|-----------|--------------------------------------|----------------------------------------------------------------------------|
| 01        | Advanced-Subdomain-Enumeration       | zone, dns_records, ip_addresses, ttl, wildcard, registrar, nameservers     |
| 02        | Passive-OSINT-Collection             | sources_list, raw_results, social_profiles, breach_data_refs               |
| 03        | Active-Asset-Discovery               | scan_type, ports, protocols, response_time_ms, status_code                 |
| 04        | Technology-Stack-Fingerprinting      | technologies, versions, frameworks, servers, cdn, waf, languages           |
| 05        | Cloud-Resource-Enumeration           | provider, account_id, region, resource_type, arn_or_id, public_access     |
| 06        | API-Endpoint-Discovery               | method, path, parameters, auth_required, rate_limit, response_schema       |
| 07        | JavaScript-Source-Analysis           | file_url, endpoints_found, secrets_found, minified, size_bytes            |
| 08        | Configuration-File-Extraction        | file_type, contains_secrets, path_on_server, content_hash                  |
| 09        | Version-Detection-Techniques         | software_name, version_string, cpe, end_of_life                           |
| 10        | Content-Discovery-Automation         | path, status_code, content_length, content_type, interesting_params       |
| 11        | Directory-Brute-Forcing              | directory, files_found, access_level, wordlist_used                        |
| 12        | File-Type-Detection                  | mime_type, magic_bytes, extension, executable, archive                     |
| 13        | Backup-File-Discovery                | backup_type, original_path, size_bytes, readable, contains_source         |
| 14        | Source-Code-Leak-Detection           | language, repository_url, exposure_type, contains_secrets                  |
| 15        | Git-Repository-Analysis              | repo_url, branch, commits_count, authors, exposed_files, hooks            |
| 16        | DNS-Enumeration-Advanced             | record_type, record_value, ttl, nameserver, dnssec_status                 |
| 17        | Certificate-Transparency-Logs        | serial_number, issuer, subject, san_list, not_before, not_after           |
| 18        | Historical-Data-Analysis             | snapshot_date, change_type, previous_value, diff_summary                   |
| 19        | Social-Media-OSINT                   | platform, profile_url, follower_count, post_count, verified               |
| 20        | Employee-Linked-Assets               | name, role, department, linked_domains, social_profiles, devices           |
| 21        | Third-Party-Integration-Discovery    | integration_name, vendor, auth_type, data_shared, exposure_risk           |
| 22        | Web-Archive-Analysis                 | archive_source, capture_date, original_url, status_code_archived           |
| 23        | Pastebin-and-Leak-Searching          | paste_id, date_posted, contains_creds, contains_pii, language             |
| 24        | Code-Repository-Mining               | repo_platform, repo_url, star_count, recent_activity, license             |
| 25        | Container-Registry-Enumeration       | registry_url, image_name, tag, size_bytes, os, layers_count               |
| 26        | IoT-Device-Discovery                 | device_type, firmware_version, manufacturer, open_ports, protocol         |
| 27        | Mobile-App-Analysis                  | platform, package_id, version, permissions, api_endpoints, sdk_versions   |
| 28        | API-Documentation-Extraction         | doc_format, swagger_url, endpoints_count, auth_methods, schemas           |
| 29        | WebSocket-Endpoint-Discovery         | ws_url, protocol, auth_required, message_format, origin_policy            |
| 30        | GraphQL-Introspection                | schema_hash, types_count, queries, mutations, subscriptions               |
| 31        | XML-RPC-and-SOAP-Discovery           | endpoint_type, methods_list, wsdl_url, version                            |
| 32        | Email-Address-Harvesting             | email_format, domain, mx_records, validated, role_account                 |
| 33        | Phone-Number-Enumeration             | number, country_code, type, carrier, linked_identity                       |
| 34        | Physical-Location-Intelligence       | address, coordinates, facility_type, tenant_list, access_method            |
| 35        | Supply-Chain-Asset-Mapping           | vendor_name, service_type, dependency_level, data_exposure                 |
| 36        | Competitor-Analysis                  | competitor_name, domains, technologies, employee_overlap                   |
| 37        | Partner-Network-Discovery            | partner_name, relationship_type, shared_infrastructure, auth_method        |
| 38        | Acquisition-Target-Analysis          | target_name, domains, revenue_estimate, tech_stack, risk_score            |
| 39        | Subsidiary-Asset-Mapping             | subsidiary_name, parent_org, domains, legal_entity, region                |
| 40        | Regional-Infrastructure-Mapping      | region, provider, latency_ms, redundancy, compliance_zone                 |
| 41        | CMS-Detection                        | cms_name, version, plugins, themes, admin_path, xmlrpc_enabled            |
| 42        | Framework-and-Library-Identification | framework_name, version, language, dependency_file, known_cves            |
| 43        | Server-Configuration-Analysis        | server_software, os, modules, config_exposures, admin_interfaces          |
| 44        | SSL-TLS-Certificate-Analysis         | protocol, cipher_suite, key_size, chain_validity, hsts_enabled            |
| 45        | HTTP-Header-Intelligence             | headers_dict, security_headers, server_header, caching_policy             |
| 46        | Cookie-Analysis-and-Session-Mgmt     | cookie_names, flags, http_only, secure, same_site, expiry_policy          |
| 47        | Error-Page-Analysis                  | error_type, stack_trace_visible, debug_info, custom_error_page            |
| 48        | Debug-Endpoint-Discovery             | debug_path, auth_required, exposes_config, exposes_env                     |
| 49        | Staging-Environment-Detection        | env_type, base_url, robots_disallow, password_protection, diff_score      |
| 50        | Advanced-Reconnaissance-Strategy     | strategy_name, modules_used, execution_order, priority, time_budget       |

---

## Serialize Operations

### serialize(module_output, format, options) → bytes

Serializes a module's output to the specified format.

**Parameters:**
- `module_output` — structured data conforming to the module's schema
- `format` — one of `json`, `yaml`, `msgpack`, `protobuf`
- `options` — optional serialization options

**Options:**

| Option            | Type    | Default  | Description                                          |
|-------------------|---------|----------|------------------------------------------------------|
| `indent`          | int     | 2        | Indentation level (JSON/YAML only)                   |
| `sort_keys`       | bool    | true     | Alphabetically sort keys                             |
| `preserve_null`   | bool    | true     | Keep null/None values in output                      |
| `max_depth`       | int     | 20       | Maximum nesting depth before truncation              |
| `encoding`        | string  | utf-8    | Character encoding for text formats                  |
| `timestamp_fmt`   | string  | iso8601  | Timestamp format: iso8601, unix, unix_ms             |
| `binary_mode`     | string  | copy     | Binary data handling: copy, reference, omit          |

**Examples:**

```python
# Serialize subdomain enumeration output to JSON
output = serialize(subdomain_data, "json", indent=2, sort_keys=True)

# Serialize API endpoint discovery to MessagePack for wire transfer
wire_data = serialize(api_data, "msgpack", binary_mode="copy")

# Serialize strategy output to YAML for human review
yaml_config = serialize(strategy_data, "yaml", indent=4, timestamp_fmt="iso8601")

# Serialize certificate data to Protobuf
proto_bytes = serialize(cert_data, "protobuf")
```

### serialize_batch(module_outputs, format, options) → bytes

Serializes multiple module outputs in a single call for batch transfer.

```python
batch = serialize_batch(
    [subdomain_data, api_data, cert_data],
    "msgpack",
    options={"sort_keys": True, "preserve_null": False}
)
```

### serialize_stream(module_output, format, callback, chunk_size)

Streaming serialization for very large outputs (100K+ assets). Calls `callback(chunk_bytes)` for each serialized chunk.

```python
def write_chunk(chunk):
    file_handle.write(chunk)

serialize_stream(large_subdomain_data, "json", write_chunk, chunk_size=65536)
```

---

## Deserialize Operations

### deserialize(data, format, schema_module_id) → dict

Deserializes data from the specified format into the canonical asset schema.

**Parameters:**
- `data` — bytes or string to deserialize
- `format` — one of `json`, `yaml`, `msgpack`, `protobuf`, `auto`
- `schema_module_id` — target module ID (1-50) for schema validation

**Behavior:**
1. Parse raw bytes/string using the specified format parser.
2. Validate against the target module's registered schema.
3. Convert timestamps to canonical ISO 8601.
4. Return structured dict conforming to the canonical asset schema.

```python
# Deserialize JSON recon data
asset = deserialize(json_bytes, "json", schema_module_id=1)

# Deserialize with auto-detection
asset = deserialize(unknown_bytes, "auto", schema_module_id=6)

# Deserialize Protobuf with strict validation
asset = deserialize(proto_bytes, "protobuf", schema_module_id=17)
```

### deserialize_batch(data, format) → list[dict]

Deserializes a batch-serialized payload back into a list of module outputs.

```python
outputs = deserialize_batch(batch_bytes, "msgpack")
# Returns list of dicts, each conforming to its respective module schema
```

### deserialize_stream(source, format, callback, chunk_size)

Streaming deserialization for large payloads. Calls `callback(asset_chunk)` for each deserialized batch.

---

## Compression

All serialization formats support optional compression. Compression is applied after serialization and before writing to storage or network.

### Compression Algorithms

| Algorithm | Ratio | Speed    | Use Case                              |
|-----------|-------|----------|---------------------------------------|
| none      | 1.0x  | Fastest  | Small payloads (<1KB)                 |
| gzip      | ~3x   | Fast     | General purpose, JSON/YAML storage    |
| zstd      | ~4x   | Fast     | High-throughput wire transfer         |
| brotli    | ~5x   | Medium   | Archival storage, largest savings     |
| lz4       | ~2x   | Fastest  | Real-time streaming, minimal CPU cost |

### Compression Integration

```python
# Serialize + compress
compressed = serialize(data, "json", compress="zstd", compress_level=3)

# Decompress + deserialize
data = deserialize(compressed, "json", decompress="zstd")

# Streaming with compression
serialize_stream(data, "json", write_callback, chunk_size=65536, compress="gzip")
```

### Per-Module Compression Defaults

| Module Category       | Default Algorithm | Rationale                                    |
|-----------------------|-------------------|----------------------------------------------|
| DNS & Naming          | zstd              | High volume, frequent wire transfer          |
| Passive Recon         | brotli            | Archival, rarely re-read                     |
| Active Recon          | gzip              | Moderate volume, quick access needed         |
| Fingerprinting        | none              | Small payloads                               |
| Cloud Recon           | zstd              | High volume, cross-service transfer          |
| API Recon             | gzip              | Structured data, moderate size               |
| Client-Side Recon     | gzip              | Contains raw response bodies                 |
| Leak & Code Recon     | brotli            | Sensitive data, archival                     |
| Infrastructure Recon  | zstd              | High volume, pipeline transit                |
| Strategy & Meta       | none              | Configuration, small size                    |

---

## Type Preservation

### Primitive Types

| Type      | JSON       | YAML       | MsgPack       | Protobuf     | Notes                           |
|-----------|------------|------------|---------------|--------------|---------------------------------|
| string    | string     | string     | str           | string       | UTF-8 encoded                   |
| integer   | number     | int        | int/fixint    | int32/int64  | MsgPack uses smallest fitting   |
| float     | number     | float      | float32/64    | float/double | NaN/Inf preserved via extension |
| boolean   | true/false | true/false | bool          | bool         | YAML accepts yes/no/on/off      |
| null      | null       | null       | nil           | N/A          | Proto3 omits zero values        |
| binary    | N/A        | N/A        | bin           | bytes        | Base64 in text formats          |
| array     | array      | sequence   | array         | repeated     | Order preserved                 |
| object    | object     | mapping    | map           | map/message  | Key order: alphabetical         |

### Timestamp Handling

```python
# Canonical format: ISO 8601 with Z suffix
"2026-06-26T12:00:00Z"

# Unix seconds: 1750939200
# Unix milliseconds: 1750939200000

# MsgPack ext type 0: timestamp
# Protobuf: string field with format annotation
```

### Special Values

| Value            | Handling                                               |
|------------------|--------------------------------------------------------|
| Empty string     | Preserved as `""`, never converted to null              |
| Empty array      | Preserved as `[]`, never omitted                        |
| Empty object     | Preserved as `{}`, never omitted                        |
| Zero confidence  | Preserved as `0.0`, indicates unvalidated asset         |
| Unknown timestamp| Serialized as `"0001-01-01T00:00:00Z"` (sentinel)      |
| Binary (DER cert)| Base64 in JSON/YAML, native bin in MsgPack/Protobuf    |
| Large integers   | JSON: string wrapper to avoid JS precision loss         |

---

## Custom Serializers

### Per-Module Custom Serializers

Each module can register custom serializers for non-standard data types:

```python
# Module 17: Certificate Transparency Logs
class CertTransSerializer:
    def serialize(cert_data):
        # Convert X.509 objects to DER bytes, preserve SAN lists
        return {
            "der_bytes": base64_encode(cert_data.der),
            "san_list": sorted(cert_data.san),
            "issuer_dn": cert_data.issuer.rfc4514(),
            "not_before": cert_data.not_before.isoformat(),
            "not_after": cert_data.not_after.isoformat(),
        }

    def deserialize(data):
        # Reconstruct X.509 from DER
        cert = x509.load_der_x509_certificate(base64_decode(data["der_bytes"]))
        return CertRecord(cert=cert, san_list=data["san_list"])

# Module 15: Git Repository Analysis
class GitRepoSerializer:
    def serialize(repo_data):
        # Convert commit objects to hashable representation
        return {
            "repo_url": repo_data.url,
            "commits": [
                {"sha": c.hexsha, "author": c.author.name, "date": c.committed_datetime.isoformat()}
                for c in repo_data.commits
            ],
            "file_tree": repo_data.tree.traverse(),
        }

# Module 05: Cloud Resource Enumeration
class CloudResourceSerializer:
    def serialize(resource):
        # Normalize ARN, GCP self-link, Azure resource ID to common format
        return {
            "provider": resource.provider,
            "resource_id": resource.normalized_id(),
            "region": resource.region,
            "arn_or_self_link": resource.native_id,
            "public_access": resource.is_public(),
        }
```

### Extension Type Registry

| Type ID | Extension Name         | Modules Using It       | Description                     |
|---------|------------------------|------------------------|---------------------------------|
| 0x01    | X509 Certificate       | 17, 44                 | DER-encoded certificate         |
| 0x02    | HTTP Response Snapshot | 03, 04, 10, 45, 47     | Full HTTP response with headers |
| 0x03    | Git Diff               | 15, 24                 | Unified diff format             |
| 0x04    | Binary Blob            | 08, 13, 25             | Raw file content                |
| 0x05    | Geo Coordinates        | 34, 40                 | Lat/Lng with precision          |
| 0x06    | Network Trace          | 03, 40                 | TCP/UDP connection trace        |

---

## Format Detection

### Auto-Detection Algorithm

When format is specified as `auto`, the deserializer applies this detection logic:

```
1. If data starts with 0x9f, 0xdc, 0x82, 0xa4 → MsgPack (common fixint/map/array headers)
2. If data starts with 0x0a → Protobuf (field tag byte for field 1, wire type 2)
3. If data starts with '{' or '[' → JSON
4. If data starts with '---' → YAML (document separator)
5. If data starts with '%' → YAML (%YAML directive)
6. If data starts with '<' → XML (fallback for SOAP/legacy)
7. Otherwise → attempt MsgPack, then JSON, then YAML
```

### Sniff API

```python
detected_format = sniff_format(data_bytes)
# Returns: "json" | "yaml" | "msgpack" | "protobuf" | "unknown"
```

---

## Batch Operations

### Batch Composition

A batch groups outputs from multiple modules into a single serializable payload:

```json
{
  "batch_id": "batch-20260626-001",
  "batch_type": "reconnaissance-deep-dive",
  "created_at": "2026-06-26T12:00:00Z",
  "module_count": 50,
  "modules": [
    {
      "module_id": 1,
      "module_file": "01-Advanced-Subdomain-Enumeration.md",
      "schema_version": "1.0.0",
      "asset_count": 342,
      "output_ref": "offset:0, length:18432",
      "checksum": "sha256:a1b2c3..."
    },
    {
      "module_id": 2,
      "module_file": "02-Passive-OSINT-Collection.md",
      "schema_version": "1.0.0",
      "asset_count": 1205,
      "output_ref": "offset:18432, length:94208",
      "checksum": "sha256:d4e5f6..."
    }
  ],
  "total_assets": 1547,
  "batch_checksum": "sha256:..."
}
```

### Batch Operations API

```python
# Create a batch from completed module outputs
batch = create_batch(
    module_outputs=[output1, output2, output3],
    batch_type="reconnaissance-deep-dive"
)

# Serialize entire batch
batch_bytes = serialize(batch, "msgpack", compress="zstd")

# Deserialize batch
batch = deserialize(batch_bytes, "msgpack")

# Extract specific module output from batch
output1 = extract_module(batch, module_id=1)

# Iterate all assets across all modules
for asset in iter_batch_assets(batch):
    process(asset)
```

### Batch Limits

| Constraint              | Value    | Rationale                              |
|-------------------------|----------|----------------------------------------|
| Max modules per batch   | 50       | One per domain file                    |
| Max assets per module   | 1,000,000| Memory constraint                      |
| Max batch size (wire)   | 500 MB   | Network transfer limit                 |
| Max batch size (stored) | 2 GB     | Disk storage limit with compression    |
| Max batch age           | 24 hours | Staleness threshold                    |

---

## Registry Schema

The domain registry maps module IDs to their schemas, serializers, and configuration.

```json
{
  "domain": "reconnaissance-deep-dive",
  "version": "1.0.0",
  "modules": {
    "1": {
      "file": "01-Advanced-Subdomain-Enumeration.md",
      "name": "Advanced Subdomain Enumeration",
      "category": "DNS & Naming",
      "schema_version": "1.0.0",
      "serializer": "SubdomainSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "zstd",
      "max_assets": 1000000,
      "correlation_keys": ["zone", "dns_records"],
      "input_dependencies": [],
      "output_consumers": [6, 16, 30, 44, 49]
    },
    "2": {
      "file": "02-Passive-OSINT-Collection.md",
      "name": "Passive OSINT Collection",
      "category": "Passive Recon",
      "schema_version": "1.0.0",
      "serializer": "OSINTSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "brotli",
      "max_assets": 1000000,
      "correlation_keys": ["sources_list", "social_profiles"],
      "input_dependencies": [],
      "output_consumers": [19, 20, 32, 33]
    },
    "3": {
      "file": "03-Active-Asset-Discovery.md",
      "name": "Active Asset Discovery",
      "category": "Active Recon",
      "schema_version": "1.0.0",
      "serializer": "AssetDiscoverySerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 500000,
      "correlation_keys": ["ip_addresses", "ports"],
      "input_dependencies": [1, 16],
      "output_consumers": [4, 9, 43, 45]
    },
    "4": {
      "file": "04-Technology-Stack-Fingerprinting.md",
      "name": "Technology Stack Fingerprinting",
      "category": "Fingerprinting",
      "schema_version": "1.0.0",
      "serializer": "TechStackSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["technologies", "versions"],
      "input_dependencies": [3],
      "output_consumers": [41, 42, 43]
    },
    "5": {
      "file": "05-Cloud-Resource-Enumeration.md",
      "name": "Cloud Resource Enumeration",
      "category": "Cloud Recon",
      "schema_version": "1.0.0",
      "serializer": "CloudResourceSerializer",
      "format_priority": ["json", "protobuf"],
      "default_compression": "zstd",
      "max_assets": 500000,
      "correlation_keys": ["provider", "account_id", "region"],
      "input_dependencies": [],
      "output_consumers": [35, 40]
    },
    "6": {
      "file": "06-API-Endpoint-Discovery.md",
      "name": "API Endpoint Discovery",
      "category": "API Recon",
      "schema_version": "1.0.0",
      "serializer": "APIEndpointSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 200000,
      "correlation_keys": ["method", "path", "auth_required"],
      "input_dependencies": [1, 7, 28, 30],
      "output_consumers": [29, 30, 31]
    },
    "7": {
      "file": "07-JavaScript-Source-Analysis.md",
      "name": "JavaScript Source Analysis",
      "category": "Client-Side Recon",
      "schema_version": "1.0.0",
      "serializer": "JSSourceSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["file_url", "endpoints_found"],
      "input_dependencies": [1],
      "output_consumers": [6, 8]
    },
    "8": {
      "file": "08-Configuration-File-Extraction.md",
      "name": "Configuration File Extraction",
      "category": "Client-Side Recon",
      "schema_version": "1.0.0",
      "serializer": "ConfigFileSerializer",
      "format_priority": ["json"],
      "default_compression": "brotli",
      "max_assets": 10000,
      "correlation_keys": ["file_type", "contains_secrets"],
      "input_dependencies": [10, 11, 13],
      "output_consumers": [14, 15]
    },
    "9": {
      "file": "09-Version-Detection-Techniques.md",
      "name": "Version Detection Techniques",
      "category": "Version Fingerprint",
      "schema_version": "1.0.0",
      "serializer": "VersionDetectSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["software_name", "version_string"],
      "input_dependencies": [3, 4],
      "output_consumers": [42]
    },
    "10": {
      "file": "10-Content-Discovery-Automation.md",
      "name": "Content Discovery Automation",
      "category": "Content Recon",
      "schema_version": "1.0.0",
      "serializer": "ContentDiscoverySerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 500000,
      "correlation_keys": ["path", "status_code"],
      "input_dependencies": [1, 3],
      "output_consumers": [8, 11, 12, 13]
    },
    "11": {
      "file": "11-Directory-Brute-Forcing.md",
      "name": "Directory Brute-Forcing",
      "category": "Directory Recon",
      "schema_version": "1.0.0",
      "serializer": "DirectoryBruteSerializer",
      "format_priority": ["json"],
      "default_compression": "gzip",
      "max_assets": 1000000,
      "correlation_keys": ["directory", "access_level"],
      "input_dependencies": [1, 3, 10],
      "output_consumers": [8, 12, 13, 48]
    },
    "12": {
      "file": "12-File-Type-Detection.md",
      "name": "File Type Detection",
      "category": "File Recon",
      "schema_version": "1.0.0",
      "serializer": "FileTypeSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 100000,
      "correlation_keys": ["mime_type", "extension"],
      "input_dependencies": [10, 11],
      "output_consumers": [13, 14]
    },
    "13": {
      "file": "13-Backup-File-Discovery.md",
      "name": "Backup File Discovery",
      "category": "Backup Recon",
      "schema_version": "1.0.0",
      "serializer": "BackupFileSerializer",
      "format_priority": ["json"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["backup_type", "original_path"],
      "input_dependencies": [10, 11, 12],
      "output_consumers": [8, 14, 15]
    },
    "14": {
      "file": "14-Source-Code-Leak-Detection.md",
      "name": "Source Code Leak Detection",
      "category": "Code Leak Recon",
      "schema_version": "1.0.0",
      "serializer": "CodeLeakSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "brotli",
      "max_assets": 50000,
      "correlation_keys": ["language", "exposure_type"],
      "input_dependencies": [8, 13, 15],
      "output_consumers": [24]
    },
    "15": {
      "file": "15-Git-Repository-Analysis.md",
      "name": "Git Repository Analysis",
      "category": "Git Recon",
      "schema_version": "1.0.0",
      "serializer": "GitRepoSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["repo_url", "branch"],
      "input_dependencies": [8, 13],
      "output_consumers": [14, 24]
    },
    "16": {
      "file": "16-DNS-Enumeration-Advanced.md",
      "name": "DNS Enumeration Advanced",
      "category": "DNS Deep Recon",
      "schema_version": "1.0.0",
      "serializer": "DNSEnumSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "zstd",
      "max_assets": 500000,
      "correlation_keys": ["record_type", "record_value"],
      "input_dependencies": [1],
      "output_consumers": [3, 17, 44]
    },
    "17": {
      "file": "17-Certificate-Transparency-Logs.md",
      "name": "Certificate Transparency Logs",
      "category": "CT Log Recon",
      "schema_version": "1.0.0",
      "serializer": "CertTransSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 1000000,
      "correlation_keys": ["serial_number", "san_list"],
      "input_dependencies": [1, 16],
      "output_consumers": [1, 44]
    },
    "18": {
      "file": "18-Historical-Data-Analysis.md",
      "name": "Historical Data Analysis",
      "category": "Historical Recon",
      "schema_version": "1.0.0",
      "serializer": "HistoricalDataSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "brotli",
      "max_assets": 1000000,
      "correlation_keys": ["snapshot_date", "change_type"],
      "input_dependencies": [1, 17, 22],
      "output_consumers": [50]
    },
    "19": {
      "file": "19-Social-Media-OSINT.md",
      "name": "Social Media OSINT",
      "category": "Social Recon",
      "schema_version": "1.0.0",
      "serializer": "SocialMediaSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["platform", "profile_url"],
      "input_dependencies": [2],
      "output_consumers": [20, 32, 33]
    },
    "20": {
      "file": "20-Employee-Linked-Assets.md",
      "name": "Employee Linked Assets",
      "category": "Personnel Recon",
      "schema_version": "1.0.0",
      "serializer": "EmployeeAssetSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["name", "linked_domains"],
      "input_dependencies": [2, 19],
      "output_consumers": [21, 32, 37]
    },
    "21": {
      "file": "21-Third-Party-Integration-Discovery.md",
      "name": "Third Party Integration Discovery",
      "category": "Integration Recon",
      "schema_version": "1.0.0",
      "serializer": "IntegrationSerializer",
      "format_priority": ["json"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["integration_name", "vendor"],
      "input_dependencies": [7, 20],
      "output_consumers": [35, 37]
    },
    "22": {
      "file": "22-Web-Archive-Analysis.md",
      "name": "Web Archive Analysis",
      "category": "Archive Recon",
      "schema_version": "1.0.0",
      "serializer": "WebArchiveSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 500000,
      "correlation_keys": ["archive_source", "capture_date"],
      "input_dependencies": [1],
      "output_consumers": [18, 49]
    },
    "23": {
      "file": "23-Pastebin-and-Leak-Searching.md",
      "name": "Pastebin and Leak Searching",
      "category": "Leak Recon",
      "schema_version": "1.0.0",
      "serializer": "LeakSearchSerializer",
      "format_priority": ["json"],
      "default_compression": "brotli",
      "max_assets": 100000,
      "correlation_keys": ["paste_id", "contains_creds"],
      "input_dependencies": [32],
      "output_consumers": [14, 24]
    },
    "24": {
      "file": "24-Code-Repository-Mining.md",
      "name": "Code Repository Mining",
      "category": "Code Recon",
      "schema_version": "1.0.0",
      "serializer": "CodeRepoSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["repo_platform", "repo_url"],
      "input_dependencies": [14, 15, 23],
      "output_consumers": [21, 35]
    },
    "25": {
      "file": "25-Container-Registry-Enumeration.md",
      "name": "Container Registry Enumeration",
      "category": "Container Recon",
      "schema_version": "1.0.0",
      "serializer": "ContainerRegistrySerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "zstd",
      "max_assets": 200000,
      "correlation_keys": ["registry_url", "image_name", "tag"],
      "input_dependencies": [5],
      "output_consumers": [42]
    },
    "26": {
      "file": "26-IoT-Device-Discovery.md",
      "name": "IoT Device Discovery",
      "category": "IoT Recon",
      "schema_version": "1.0.0",
      "serializer": "IoTDeviceSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["device_type", "manufacturer"],
      "input_dependencies": [3],
      "output_consumers": []
    },
    "27": {
      "file": "27-Mobile-App-Analysis.md",
      "name": "Mobile App Analysis",
      "category": "Mobile Recon",
      "schema_version": "1.0.0",
      "serializer": "MobileAppSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["platform", "package_id"],
      "input_dependencies": [],
      "output_consumers": [6, 28]
    },
    "28": {
      "file": "28-API-Documentation-Extraction.md",
      "name": "API Documentation Extraction",
      "category": "API Docs Recon",
      "schema_version": "1.0.0",
      "serializer": "APIDocSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["doc_format", "swagger_url"],
      "input_dependencies": [6, 27],
      "output_consumers": [6, 30, 31]
    },
    "29": {
      "file": "29-WebSocket-Endpoint-Discovery.md",
      "name": "WebSocket Endpoint Discovery",
      "category": "WebSocket Recon",
      "schema_version": "1.0.0",
      "serializer": "WebSocketSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 10000,
      "correlation_keys": ["ws_url", "protocol"],
      "input_dependencies": [6],
      "output_consumers": []
    },
    "30": {
      "file": "30-GraphQL-Introspection.md",
      "name": "GraphQL Introspection",
      "category": "GraphQL Recon",
      "schema_version": "1.0.0",
      "serializer": "GraphQLSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["schema_hash", "types_count"],
      "input_dependencies": [1, 6, 28],
      "output_consumers": [6]
    },
    "31": {
      "file": "31-XML-RPC-and-SOAP-Discovery.md",
      "name": "XML-RPC and SOAP Discovery",
      "category": "Legacy API Recon",
      "schema_version": "1.0.0",
      "serializer": "LegacyAPISerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 10000,
      "correlation_keys": ["endpoint_type", "methods_list"],
      "input_dependencies": [6, 28],
      "output_consumers": []
    },
    "32": {
      "file": "32-Email-Address-Harvesting.md",
      "name": "Email Address Harvesting",
      "category": "Email Recon",
      "schema_version": "1.0.0",
      "serializer": "EmailHarvestSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["email_format", "domain"],
      "input_dependencies": [2, 19, 33],
      "output_consumers": [20, 23]
    },
    "33": {
      "file": "33-Phone-Number-Enumeration.md",
      "name": "Phone Number Enumeration",
      "category": "Phone Recon",
      "schema_version": "1.0.0",
      "serializer": "PhoneEnumSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["number", "country_code"],
      "input_dependencies": [2, 19],
      "output_consumers": [20, 32]
    },
    "34": {
      "file": "34-Physical-Location-Intelligence.md",
      "name": "Physical Location Intelligence",
      "category": "Physical Recon",
      "schema_version": "1.0.0",
      "serializer": "PhysicalLocationSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "none",
      "max_assets": 10000,
      "correlation_keys": ["address", "coordinates"],
      "input_dependencies": [20],
      "output_consumers": [40]
    },
    "35": {
      "file": "35-Supply-Chain-Asset-Mapping.md",
      "name": "Supply Chain Asset Mapping",
      "category": "Supply Chain Recon",
      "schema_version": "1.0.0",
      "serializer": "SupplyChainSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["vendor_name", "dependency_level"],
      "input_dependencies": [5, 21, 24],
      "output_consumers": [50]
    },
    "36": {
      "file": "36-Competitor-Analysis.md",
      "name": "Competitor Analysis",
      "category": "Competitive Recon",
      "schema_version": "1.0.0",
      "serializer": "CompetitorAnalysisSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["competitor_name", "domains"],
      "input_dependencies": [4, 9, 20],
      "output_consumers": [50]
    },
    "37": {
      "file": "37-Partner-Network-Discovery.md",
      "name": "Partner Network Discovery",
      "category": "Partner Recon",
      "schema_version": "1.0.0",
      "serializer": "PartnerNetSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["partner_name", "relationship_type"],
      "input_dependencies": [20, 21],
      "output_consumers": [35, 50]
    },
    "38": {
      "file": "38-Acquisition-Target-Analysis.md",
      "name": "Acquisition Target Analysis",
      "category": "M&A Recon",
      "schema_version": "1.0.0",
      "serializer": "AcquisitionSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 50000,
      "correlation_keys": ["target_name", "domains"],
      "input_dependencies": [36],
      "output_consumers": [50]
    },
    "39": {
      "file": "39-Subsidiary-Asset-Mapping.md",
      "name": "Subsidiary Asset Mapping",
      "category": "Subsidiary Recon",
      "schema_version": "1.0.0",
      "serializer": "SubsidiarySerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["subsidiary_name", "parent_org"],
      "input_dependencies": [38],
      "output_consumers": [40, 50]
    },
    "40": {
      "file": "40-Regional-Infrastructure-Mapping.md",
      "name": "Regional Infrastructure Mapping",
      "category": "Regional Recon",
      "schema_version": "1.0.0",
      "serializer": "RegionalInfraSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "zstd",
      "max_assets": 200000,
      "correlation_keys": ["region", "provider"],
      "input_dependencies": [5, 34, 39],
      "output_consumers": [50]
    },
    "41": {
      "file": "41-Content-Management-System-Detection.md",
      "name": "CMS Detection",
      "category": "CMS Detection",
      "schema_version": "1.0.0",
      "serializer": "CMSDetectionSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["cms_name", "version"],
      "input_dependencies": [4],
      "output_consumers": [42]
    },
    "42": {
      "file": "42-Framework-and-Library-Identification.md",
      "name": "Framework and Library Identification",
      "category": "Framework Detection",
      "schema_version": "1.0.0",
      "serializer": "FrameworkSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 100000,
      "correlation_keys": ["framework_name", "language"],
      "input_dependencies": [4, 9, 25, 41],
      "output_consumers": [50]
    },
    "43": {
      "file": "43-Server-Configuration-Analysis.md",
      "name": "Server Configuration Analysis",
      "category": "Server Recon",
      "schema_version": "1.0.0",
      "serializer": "ServerConfigSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "gzip",
      "max_assets": 100000,
      "correlation_keys": ["server_software", "os"],
      "input_dependencies": [3, 4, 9],
      "output_consumers": [44, 45, 46]
    },
    "44": {
      "file": "44-SSL-TLS-Certificate-Analysis.md",
      "name": "SSL TLS Certificate Analysis",
      "category": "TLS Recon",
      "schema_version": "1.0.0",
      "serializer": "SSLTLSAnalysisSerializer",
      "format_priority": ["json", "msgpack"],
      "default_compression": "gzip",
      "max_assets": 200000,
      "correlation_keys": ["protocol", "cipher_suite"],
      "input_dependencies": [1, 16, 17, 43],
      "output_consumers": [45]
    },
    "45": {
      "file": "45-HTTP-Header-Intelligence.md",
      "name": "HTTP Header Intelligence",
      "category": "Header Recon",
      "schema_version": "1.0.0",
      "serializer": "HTTPHeaderSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 100000,
      "correlation_keys": ["headers_dict", "security_headers"],
      "input_dependencies": [3, 43, 44],
      "output_consumers": [46, 47, 48, 49]
    },
    "46": {
      "file": "46-Cookie-Analysis-and-Session-Management.md",
      "name": "Cookie Analysis and Session Management",
      "category": "Session Recon",
      "schema_version": "1.0.0",
      "serializer": "CookieAnalysisSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["cookie_names", "flags"],
      "input_dependencies": [45],
      "output_consumers": []
    },
    "47": {
      "file": "47-Error-Page-Analysis.md",
      "name": "Error Page Analysis",
      "category": "Error Recon",
      "schema_version": "1.0.0",
      "serializer": "ErrorPageSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["error_type", "stack_trace_visible"],
      "input_dependencies": [3, 45],
      "output_consumers": [48]
    },
    "48": {
      "file": "48-Debug-Endpoint-Discovery.md",
      "name": "Debug Endpoint Discovery",
      "category": "Debug Recon",
      "schema_version": "1.0.0",
      "serializer": "DebugEndpointSerializer",
      "format_priority": ["json"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["debug_path", "auth_required"],
      "input_dependencies": [10, 11, 47],
      "output_consumers": []
    },
    "49": {
      "file": "49-Staging-Environment-Detection.md",
      "name": "Staging Environment Detection",
      "category": "Staging Recon",
      "schema_version": "1.0.0",
      "serializer": "StagingDetectSerializer",
      "format_priority": ["json", "yaml"],
      "default_compression": "none",
      "max_assets": 50000,
      "correlation_keys": ["env_type", "base_url"],
      "input_dependencies": [1, 3, 22, 45],
      "output_consumers": [50]
    },
    "50": {
      "file": "50-Advanced-Reconnaissance-Strategy.md",
      "name": "Advanced Reconnaissance Strategy",
      "category": "Strategy & Meta",
      "schema_version": "1.0.0",
      "serializer": "StrategySerializer",
      "format_priority": ["yaml", "json"],
      "default_compression": "none",
      "max_assets": 1000,
      "correlation_keys": ["strategy_name", "modules_used"],
      "input_dependencies": [1, 2, 3, 5, 18, 35, 36, 37, 38, 39, 40, 42, 49],
      "output_consumers": []
    }
  }
}
```

---

## Error Handling

### Serialization Errors

| Error Code | Error Type           | Description                                          | Recovery                              |
|------------|----------------------|------------------------------------------------------|---------------------------------------|
| SER-001    | SchemaValidation     | Data does not conform to target module schema         | Log offending fields, serialize valid subset |
| SER-002    | FormatUnsupported    | Requested format not supported for this module        | Fall back to module's first format_priority |
| SER-003    | TypeMismatch         | Field type does not match schema definition           | Attempt type coercion, log warning   |
| SER-004    | DepthExceeded        | Nesting depth exceeds max_depth option                | Truncate at limit, add truncation marker |
| SER-005    | EncodingError        | Character encoding conversion failed                  | Replace with replacement character, log |
| SER-006    | BinaryDataOmitted    | Binary data not supported in requested format         | Base64 encode or skip based on option |
| SER-007    | TimestampInvalid     | Timestamp not parseable to ISO 8601                   | Use sentinel value, log warning      |
| DES-001    | FormatDetection      | Auto-detection could not identify format              | Return error with hex dump of header |
| DES-002    | CorruptData          | Input data is corrupted or truncated                  | Attempt partial parse, log corruption |
| DES-003    | SchemaMismatch       | Data does not match expected module schema            | Attempt flexible parse, log fields   |
| DES-004    | VersionMismatch      | Data schema version differs from registry version     | Apply migration if available, else warn |
| DES-005    | DecompressFailed     | Decompression failed or data is not compressed        | Try raw parse, log compression error |
| BATCH-001  | ModuleCountExceeded  | Batch contains more than 50 modules                   | Reject batch, return error           |
| BATCH-002  | AssetCountExceeded   | Module output exceeds max_assets limit                | Truncate module output, log warning  |
| BATCH-003  | BatchSizeExceeded    | Serialized batch exceeds size limit                   | Split batch, serialize in chunks     |
| BATCH-004  | ChecksumMismatch     | Batch integrity check failed after deserialization    | Reject batch, re-request             |

### Error Response Format

```json
{
  "error": {
    "code": "SER-001",
    "type": "SchemaValidation",
    "message": "Field 'confidence' expected float, got string 'high'",
    "module_id": 1,
    "field_path": "assets[0].confidence",
    "suggestion": "Convert string to float 0.95",
    "recoverable": true
  },
  "partial_output": {
    "assets_valid": 341,
    "assets_invalid": 1
  }
}
```

### Graceful Degradation Strategy

1. **Partial serialization**: If some fields fail validation, serialize valid fields and mark invalid ones with `_error` keys.
2. **Format fallback**: If protobuf schema is missing, fall back to JSON with msgpack binary encoding.
3. **Compression fallback**: If zstd is unavailable, fall back to gzip, then to uncompressed.
4. **Batch splitting**: If a batch exceeds wire limits, split into sub-batches with sequential IDs.
5. **Stale data tolerance**: If timestamps exceed the staleness threshold, serialize with `_stale: true` flag rather than rejecting.

---

## Pipeline Integration

### Serialization in the Recon Pipeline

The serialization layer sits between module execution and data persistence/routing:

```
Module Execution → Serialize → Compress → Route/Store → Deserialize → Process
       ↑                                                              │
       └──────────────────────────────────────────────────────────────┘
```

### Pipeline Hooks

| Hook Point              | Operation         | Description                                    |
|-------------------------|-------------------|------------------------------------------------|
| `pre_serialize`         | Validation        | Validate module output against schema          |
| `post_serialize`        | Checksum          | Compute SHA-256 checksum of serialized bytes   |
| `pre_compress`          | Size check        | Evaluate compression ratio estimate            |
| `post_compress`         | Metrics           | Record compression ratio, time, output size    |
| `pre_deserialize`       | Format detection  | Auto-detect format if not specified            |
| `post_deserialize`      | Validation        | Validate deserialized data against schema      |
| `pre_batch`             | Ordering          | Sort module outputs by module_id               |
| `post_batch`            | Integrity         | Compute batch-level checksum                   |

### Pipeline Configuration

```yaml
serialization:
  default_format: json
  fallback_format: msgpack
  default_compression: zstd
  compression_threshold: 1024  # bytes — compress above this size
  max_batch_size: 536870912    # 512 MB
  checksum_algorithm: sha256
  timestamp_format: iso8601
  strict_mode: false  # true = reject on any validation error
  schema_registry: registry.json

  module_overrides:
    17:  # Certificate Transparency — binary-heavy
      format: msgpack
      compression: gzip
      binary_mode: copy
    50:  # Strategy — config only
      format: yaml
      compression: none
    2:   # Passive OSINT — very large, archival
      format: json
      compression: brotli
      strict_mode: true  # OSINT data must be valid
```

### Data Flow Between Modules

```
Module 01 (Subdomains) ──→ Module 06 (API Endpoints)
                        ──→ Module 16 (DNS Advanced)
                        ──→ Module 17 (CT Logs)
                        ──→ Module 22 (Web Archives)
                        ──→ Module 49 (Staging Detection)

Module 02 (OSINT) ──→ Module 19 (Social Media)
                  ──→ Module 20 (Employee Assets)
                  ──→ Module 32 (Email Harvesting)
                  ──→ Module 33 (Phone Enumeration)

Module 03 (Active Discovery) ──→ Module 04 (Tech Stack)
                              ──→ Module 10 (Content Discovery)
                              ──→ Module 11 (Directory Brute)
                              ──→ Module 26 (IoT Discovery)
                              ──→ Module 43 (Server Config)

Module 50 (Strategy) ←── ALL upstream modules feed here
```

---

## Full Domain File References

All 50 files in the reconnaissance-deep-dive domain:

| #  | File                                            | Serialization Status |
|----|-------------------------------------------------|---------------------|
| 01 | Advanced-Subdomain-Enumeration.md               | Registered          |
| 02 | Passive-OSINT-Collection.md                     | Registered          |
| 03 | Active-Asset-Discovery.md                       | Registered          |
| 04 | Technology-Stack-Fingerprinting.md              | Registered          |
| 05 | Cloud-Resource-Enumeration.md                   | Registered          |
| 06 | API-Endpoint-Discovery.md                       | Registered          |
| 07 | JavaScript-Source-Analysis.md                   | Registered          |
| 08 | Configuration-File-Extraction.md                | Registered          |
| 09 | Version-Detection-Techniques.md                 | Registered          |
| 10 | Content-Discovery-Automation.md                 | Registered          |
| 11 | Directory-Brute-Forcing.md                      | Registered          |
| 12 | File-Type-Detection.md                          | Registered          |
| 13 | Backup-File-Discovery.md                        | Registered          |
| 14 | Source-Code-Leak-Detection.md                   | Registered          |
| 15 | Git-Repository-Analysis.md                      | Registered          |
| 16 | DNS-Enumeration-Advanced.md                     | Registered          |
| 17 | Certificate-Transparency-Logs.md                | Registered          |
| 18 | Historical-Data-Analysis.md                     | Registered          |
| 19 | Social-Media-OSINT.md                           | Registered          |
| 20 | Employee-Linked-Assets.md                       | Registered          |
| 21 | Third-Party-Integration-Discovery.md            | Registered          |
| 22 | Web-Archive-Analysis.md                         | Registered          |
| 23 | Pastebin-and-Leak-Searching.md                  | Registered          |
| 24 | Code-Repository-Mining.md                       | Registered          |
| 25 | Container-Registry-Enumeration.md               | Registered          |
| 26 | IoT-Device-Discovery.md                         | Registered          |
| 27 | Mobile-App-Analysis.md                          | Registered          |
| 28 | API-Documentation-Extraction.md                 | Registered          |
| 29 | WebSocket-Endpoint-Discovery.md                 | Registered          |
| 30 | GraphQL-Introspection.md                        | Registered          |
| 31 | XML-RPC-and-SOAP-Discovery.md                   | Registered          |
| 32 | Email-Address-Harvesting.md                     | Registered          |
| 33 | Phone-Number-Enumeration.md                     | Registered          |
| 34 | Physical-Location-Intelligence.md               | Registered          |
| 35 | Supply-Chain-Asset-Mapping.md                   | Registered          |
| 36 | Competitor-Analysis.md                          | Registered          |
| 37 | Partner-Network-Discovery.md                    | Registered          |
| 38 | Acquisition-Target-Analysis.md                  | Registered          |
| 39 | Subsidiary-Asset-Mapping.md                     | Registered          |
| 40 | Regional-Infrastructure-Mapping.md              | Registered          |
| 41 | Content-Management-System-Detection.md          | Registered          |
| 42 | Framework-and-Library-Identification.md         | Registered          |
| 43 | Server-Configuration-Analysis.md                | Registered          |
| 44 | SSL-TLS-Certificate-Analysis.md                 | Registered          |
| 45 | HTTP-Header-Intelligence.md                     | Registered          |
| 46 | Cookie-Analysis-and-Session-Management.md       | Registered          |
| 47 | Error-Page-Analysis.md                          | Registered          |
| 48 | Debug-Endpoint-Discovery.md                     | Registered          |
| 49 | Staging-Environment-Detection.md                | Registered          |
| 50 | Advanced-Reconnaissance-Strategy.md             | Registered          |

### Reference Integrity

All 50 files are registered in the domain registry. The `input_dependencies` and `output_consumers` fields in the registry define the directed acyclic graph (DAG) of data flow across the recon pipeline. Every module ID (1-50) appears at least once as either a dependency or consumer, ensuring complete coverage.

### File Path Convention

Domain files are located at:

```
Brain/reconnaissance-deep-dive/
├── 01-Advanced-Subdomain-Enumeration.md
├── 02-Passive-OSINT-Collection.md
├── 03-Active-Asset-Discovery.md
├── 04-Technology-Stack-Fingerprinting.md
├── 05-Cloud-Resource-Enumeration.md
├── 06-API-Endpoint-Discovery.md
├── 07-JavaScript-Source-Analysis.md
├── 08-Configuration-File-Extraction.md
├── 09-Version-Detection-Techniques.md
├── 10-Content-Discovery-Automation.md
├── 11-Directory-Brute-Forcing.md
├── 12-File-Type-Detection.md
├── 13-Backup-File-Discovery.md
├── 14-Source-Code-Leak-Detection.md
├── 15-Git-Repository-Analysis.md
├── 16-DNS-Enumeration-Advanced.md
├── 17-Certificate-Transparency-Logs.md
├── 18-Historical-Data-Analysis.md
├── 19-Social-Media-OSINT.md
├── 20-Employee-Linked-Assets.md
├── 21-Third-Party-Integration-Discovery.md
├── 22-Web-Archive-Analysis.md
├── 23-Pastebin-and-Leak-Searching.md
├── 24-Code-Repository-Mining.md
├── 25-Container-Registry-Enumeration.md
├── 26-IoT-Device-Discovery.md
├── 27-Mobile-App-Analysis.md
├── 28-API-Documentation-Extraction.md
├── 29-WebSocket-Endpoint-Discovery.md
├── 30-GraphQL-Introspection.md
├── 31-XML-RPC-and-SOAP-Discovery.md
├── 32-Email-Address-Harvesting.md
├── 33-Phone-Number-Enumeration.md
├── 34-Physical-Location-Intelligence.md
├── 35-Supply-Chain-Asset-Mapping.md
├── 36-Competitor-Analysis.md
├── 37-Partner-Network-Discovery.md
├── 38-Acquisition-Target-Analysis.md
├── 39-Subsidiary-Asset-Mapping.md
├── 40-Regional-Infrastructure-Mapping.md
├── 41-Content-Management-System-Detection.md
├── 42-Framework-and-Library-Identification.md
├── 43-Server-Configuration-Analysis.md
├── 44-SSL-TLS-Certificate-Analysis.md
├── 45-HTTP-Header-Intelligence.md
├── 46-Cookie-Analysis-and-Session-Management.md
├── 47-Error-Page-Analysis.md
├── 48-Debug-Endpoint-Discovery.md
├── 49-Staging-Environment-Detection.md
└── 50-Advanced-Reconnaissance-Strategy.md
```

---

## Appendix: Version Migration Rules

When the schema version changes, the following migration rules apply:

| From → To | Migration                                                |
|-----------|----------------------------------------------------------|
| 1.0 → 1.1 | Add new optional fields with defaults; no breaking changes |
| 1.1 → 2.0 | Rename/deprecate fields; provide 1.x compat shim         |
| 2.0 → 3.0 | Restructure asset schema; provide migration script        |

Migration is applied at deserialization time. The `schema_version` field in every serialized payload enables automatic version detection and migration routing.

---

*End of serialization specification for reconnaissance-deep-dive domain.*
