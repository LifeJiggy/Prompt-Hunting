---
title: Data Serialization — Real-World Case Studies (Disclosed Patterns)
domain: real-world-case-studies
category: serialization
version: "1.0.0"
created: "2026-06-26"
scope: >
  Defines data serialization schemas, deserialization pipelines, format
  detection, batch operations, and compression strategies for all 50
  disclosed-pattern case studies covering web vulnerability classes,
  memory corruption, cloud misconfigurations, and API security.
tags:
  - serialization
  - case-studies
  - disclosed-patterns
  - vulnerability-class
  - data-pipeline
---

# Data Serialization — Real-World Case Studies Domain

## 1. Domain Mapping

The `real-world-case-studies` domain encompasses 50 distinct vulnerability-class
case study files, each representing a category of disclosed security findings
from public bug bounty reports, CVE disclosures, and penetration testing
engagements. The serialization layer provides a unified data model for
ingesting, storing, querying, and transmitting these case studies across
formats and pipelines.

### 1.1 Domain ID Constants

```yaml
domain_id: real-world-case-studies
domain_version: "1.0.0"
domain_hash: sha256:9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08
entry_count: 50
```

### 1.2 Index of All 50 Domain Files

| Index | File Reference | Vulnerability Class | Severity Range |
|-------|----------------|---------------------|----------------|
| 01 | `01-IDOR-Account-Takeover-Case-Studies.md` | IDOR → ATO chain | Critical |
| 02 | `02-XSS-Stored-Persistent-Attacks.md` | Stored XSS | High–Critical |
| 03 | `03-SQL-Injection-Data-Breaches.md` | SQL Injection | Critical |
| 04 | `04-SSRF-Internal-Network-Access.md` | SSRF | High–Critical |
| 05 | `05-CSRF-State-Changing-Attacks.md` | CSRF | Medium–High |
| 06 | `06-Command-Injection-RCE.md` | Command Injection | Critical |
| 07 | `07-Deserialization-Remote-Code-Execution.md` | Deserialization RCE | Critical |
| 08 | `08-File-Upload-Arbitrary-Upload.md` | File Upload | High–Critical |
| 09 | `09-XXE-XML-External-Entity-Attacks.md` | XXE | High–Critical |
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | SSTI | Critical |
| 11 | `11-JWT-Token-Manipulation.md` | JWT Attacks | High–Critical |
| 12 | `12-Authentication-Bypass.md` | Auth Bypass | Critical |
| 13 | `13-Privilege-Escalation.md` | Privilege Escalation | High–Critical |
| 14 | `14-Business-Logic-Flaws.md` | Business Logic | Medium–Critical |
| 15 | `15-Information-Disclosure.md` | Info Disclosure | Low–High |
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | Heap Overflow | Critical |
| 17 | `17-Deserialization-Java-Deserialization.md` | Java Deser | Critical |
| 18 | `18-Deserialization-PHP-Unserialize.md` | PHP Unserialize | Critical |
| 19 | `19-Deserialization-Python-Pickle.md` | Python Pickle | Critical |
| 20 | `20-Race-Condition-Time-of-Check.md` | Race Condition | Medium–High |
| 21 | `21-Host-Header-Injection.md` | Host Header Injection | Medium–High |
| 22 | `22-DNS-Rebinding-Attacks.md` | DNS Rebinding | High |
| 23 | `23-WebSocket-Security-Issues.md` | WebSocket Security | Medium–Critical |
| 24 | `24-GraphQL-Introspection-Attacks.md` | GraphQL Introspection | Medium–High |
| 25 | `25-CSP-Bypass-Techniques.md` | CSP Bypass | Medium–High |
| 26 | `26-Clickjacking-UI-Redressing.md` | Clickjacking | Medium |
| 27 | `27-HTTP-Response-Splitting.md` | HTTP Response Splitting | High |
| 28 | `28-LDAP-Injection-Attacks.md` | LDAP Injection | High–Critical |
| 29 | `29-XPath-Injection-Attacks.md` | XPath Injection | High |
| 30 | `30-NoSQL-Injection-MongoDB.md` | NoSQL Injection | High–Critical |
| 31 | `31-Prototype-Pollution-JavaScript.md` | Prototype Pollution | High–Critical |
| 32 | `32-Subdomain-Takeover.md` | Subdomain Takeover | High |
| 33 | `33-Open-Redirect-Phishing.md` | Open Redirect | Medium–High |
| 34 | `34-Content-Spoofing-Attacks.md` | Content Spoofing | Medium |
| 35 | `35-WebCache-Poisoning.md` | Web Cache Poisoning | High |
| 36 | `36-HTTP-Request-Smuggling.md` | HTTP Smuggling | High–Critical |
| 37 | `37-WebSocket-Hijacking.md` | WS Hijacking | High |
| 38 | `38-CORS-Misconfiguration.md` | CORS Misconfig | Medium–High |
| 39 | `39-Token-Leakage-URL-Parameters.md` | Token Leakage | Medium–High |
| 40 | `40-Sensitive-Data-Exposure.md` | Data Exposure | Medium–Critical |
| 41 | `41-Weak-Encryption-Algorithms.md` | Weak Crypto | High |
| 42 | `42-Insecure-Cryptographic-Storage.md` | Insecure Crypto Storage | High–Critical |
| 43 | `43-Path-Traversal-File-Inclusion.md` | Path Traversal | High–Critical |
| 44 | `44-Local-File-Inclusion-LFI.md` | LFI | High–Critical |
| 45 | `45-Remote-File-Inclusion-RFI.md` | RFI | Critical |
| 46 | `46-Server-Side-Request-Forgery.md` | SSRF (variant) | High–Critical |
| 47 | `47-Client-Side-Request-Forgery.md` | CSRF variant | Medium–High |
| 48 | `48-Mobile-API-Security-Issues.md` | Mobile API Security | High–Critical |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | Cloud Misconfig | High–Critical |
| 50 | `50-API-Authentication-Bypass.md` | API Auth Bypass | Critical |

## 2. Overview

### 2.1 Purpose

The serialization layer for the `real-world-case-studies` domain serves three
core functions:

1. **Ingestion normalization** — Convert heterogeneous case study markdown files
   into a canonical internal representation that supports cross-file queries.
2. **Transport encoding** — Serialize case study records into wire formats
   (JSON, YAML, MessagePack, Protobuf) for API consumption, caching, and
   inter-service communication.
3. **Archival compression** — Produce compact binary representations for
   long-term storage with minimal loss of fidelity.

### 2.2 Design Principles

- **Zero data loss** — Every field in the markdown source must survive round-trip
  serialization/deserialization without mutation.
- **Forward compatibility** — New vulnerability classes or fields can be added
  without breaking existing consumers.
- **Schema-driven** — All formats derive from a single canonical schema; custom
  serializers are generated, not hand-coded.
- **Domain awareness** — Serializers are context-aware; they understand that a
  `severity` field in `01-IDOR-Account-Takeover-Case-Studies.md` means something
  different from a `severity` field in `16-Memory-Corruption-Heap-Overflow.md`.

## 3. Format Support

### 3.1 JSON (Primary Exchange Format)

```json
{
  "domain": "real-world-case-studies",
  "schema_version": "1.0.0",
  "entries": [
    {
      "id": "RCS-01",
      "file": "01-IDOR-Account-Takeover-Case-Studies.md",
      "vuln_class": "IDOR",
      "chain_target": "Account Takeover",
      "severity": "Critical",
      "cvss_range": [8.5, 10.0],
      "disclosed_reports": 12,
      "payout_range_usd": [500, 25000],
      "attack_primitives": ["object-reference-manipulation", "authz-missing"],
      "platforms": ["HackerOne", "Bugcrowd", "Intigriti"],
      "tags": ["idor", "ato", "authentication", "authorization"],
      "created_at": "2026-06-26T00:00:00Z",
      "updated_at": "2026-06-26T00:00:00Z"
    }
  ]
}
```

### 3.2 YAML (Configuration & Human-Readable)

```yaml
domain: real-world-case-studies
schema_version: "1.0.0"
entries:
  - id: RCS-02
    file: 02-XSS-Stored-Persistent-Attacks.md
    vuln_class: XSS
    sub_class: Stored
    severity: High
    cvss_range: [6.5, 9.0]
    disclosed_reports: 47
    payout_range_usd: [250, 15000]
    attack_primitives:
      - persistent-script-injection
      - dom-manipulation
      - cookie-theft
    platforms: [HackerOne, Bugcrowd]
    tags: [xss, stored, persistent, dom]
```

### 3.3 MessagePack (Binary Wire Format)

MessagePack encoding uses the following type mapping for the case study schema:

| Field Type | MsgPack Type | Notes |
|------------|-------------|-------|
| `id` | str | UTF-8 encoded |
| `vuln_class` | str | Short identifier |
| `severity` | fixstr | 1–31 byte string |
| `cvss_range` | array[fixint] | Two-element array |
| `disclosed_reports` | uint32 | Report count |
| `payout_range_usd` | array[uint32] | Min/max pair |
| `attack_primitives` | array[str] | Variable length |
| `tags` | array[str] | Variable length |
| `created_at` | str (ISO 8601) | UTC timestamp |

### 3.4 Protocol Buffers (Schema Definition)

```protobuf
syntax = "proto3";
package real_world_case_studies;

message CaseStudyEntry {
  string id = 1;
  string file = 2;
  string vuln_class = 3;
  string sub_class = 4;
  string severity = 5;
  repeated float cvss_range = 6;
  uint32 disclosed_reports = 7;
  repeated uint32 payout_range_usd = 8;
  repeated string attack_primitives = 9;
  repeated string platforms = 10;
  repeated string tags = 11;
  string created_at = 12;
  string updated_at = 13;
  string chain_description = 14;
  map<string, string> metadata = 15;
}

message CaseStudyDomain {
  string domain = 1;
  string schema_version = 2;
  repeated CaseStudyEntry entries = 3;
}
```

## 4. Pattern Serialization

### 4.1 Attack Pattern Schema

Each of the 50 case study files encodes one or more attack patterns. The
serialization schema captures each pattern as a structured object:

```json
{
  "pattern_id": "RCS-36-P1",
  "source_file": "36-HTTP-Request-Smuggling.md",
  "pattern_name": "CL.TE Smuggling",
  "category": "HTTP Request Smuggling",
  "sub_category": "CL.TE",
  "root_cause": "front-end uses Content-Length, back-end uses Transfer-Encoding",
  "detection_signals": [
    "400 error on TE header",
    "asymmetric Content-Length parsing",
    "chunk extension handling mismatch"
  ],
  "exploit_steps": [
    "Craft request with TE: chunked and conflicting CL",
    "Smuggle request prefix into back-end pipe",
    "Hijack subsequent victim request"
  ],
  "affected_protocols": ["HTTP/1.1"],
  "mitigation": ["normalize headers at reverse proxy", "reject ambiguous requests"],
  "references": ["HackerOne report #12345", "CVE-2023-XXXXX"]
}
```

### 4.2 Cross-Reference Serialization

Patterns that chain across files (e.g., IDOR → Auth Bypass → ATO) use a
linked-reference schema:

```json
{
  "chain_id": "RCS-CHAIN-01-12",
  "source": "01-IDOR-Account-Takeover-Case-Studies.md",
  "target": "12-Authentication-Bypass.md",
  "link_type": "chaining_primitive",
  "description": "IDOR on password-reset token leads to auth bypass",
  "confidence": "confirmed",
  "payout_multiplier": 2.5
}
```

## 5. Serialize Operations

### 5.1 Markdown-to-Canonical Serialize

```
Input:  Raw markdown file (e.g., 01-IDOR-Account-Takeover-Case-Studies.md)
Step 1: Parse YAML frontmatter → metadata object
Step 2: Parse markdown body → section tree
Step 3: Extract structured fields (severity, CVSS, payout, etc.)
Step 4: Merge metadata + parsed body into CaseStudyEntry
Step 5: Validate against schema
Step 6: Encode to target format (JSON / YAML / MsgPack / Protobuf)
Output: Serialized CaseStudyEntry
```

### 5.2 Batch Serialize

```python
# Pseudocode for batch serialization of all 50 files
FILES = [
    "01-IDOR-Account-Takeover-Case-Studies.md",
    "02-XSS-Stored-Persistent-Attacks.md",
    "03-SQL-Injection-Data-Breaches.md",
    # ... through file 50
    "50-API-Authentication-Bypass.md",
]

for file in FILES:
    raw = read_file(f"Brain/utils/serialization/{file}")
    entry = parse_case_study(raw)
    serialized = encode(entry, format="json")
    write_output(f"dist/real-world-case-studies/{entry.id}.json", serialized)
```

### 5.3 Delta Serialize (Incremental)

When a case study file is updated, only the delta is serialized:

```json
{
  "operation": "delta",
  "entry_id": "RCS-14",
  "file": "14-Business-Logic-Flaws.md",
  "changed_fields": ["disclosed_reports", "payout_range_usd"],
  "previous_values": {
    "disclosed_reports": 8,
    "payout_range_usd": [200, 10000]
  },
  "new_values": {
    "disclosed_reports": 11,
    "payout_range_usd": [300, 18000]
  },
  "delta_patch": "v1.0.0→v1.1.0"
}
```

## 6. Deserialize Operations

### 6.1 JSON Deserialization

```json
{
  "format": "json",
  "strict_mode": true,
  "unknown_field_policy": "ignore",
  "missing_field_policy": "error",
  "type_coercion": {
    "string_to_int": true,
    "null_to_default": false
  }
}
```

### 6.2 YAML Deserialization

```yaml
format: yaml
anchors: true
aliases: true
merge_keys: [<<]
custom_tags:
  - "!severity"    # Custom tag for severity enums
  - "!cvss_range"  # Custom tag for CVSS pair
  - "!payout"      # Custom tag for USD range
```

### 6.3 MessagePack Deserialization

MsgPack deserialization uses the same schema-driven approach. The decoder
verifies field count and types match the registered schema before materializing
the `CaseStudyEntry` object.

### 6.4 Protobuf Deserialization

Protobuf decoding relies on the compiled `.pb.go` or `.pb.js` stubs generated
from the `.proto` definition. Unknown fields in newer wire data are preserved
but not decoded, ensuring forward compatibility.

## 7. Compression

### 7.1 Compression Strategies by Format

| Format | Default Algorithm | Ratio (est.) | Use Case |
|--------|-------------------|-------------|----------|
| JSON | gzip level 6 | ~3.2:1 | API transport, caching |
| YAML | zstd level 3 | ~4.1:1 | Config files, archival |
| MessagePack | lz4 | ~2.8:1 | High-throughput pipelines |
| Protobuf | snappy | ~2.5:1 | gRPC inter-service |
| Markdown (raw) | brotli level 4 | ~5.5:1 | Long-term archival |

### 7.2 Compressed Payload Envelope

```json
{
  "compression": "gzip",
  "original_format": "json",
  "original_size_bytes": 184320,
  "compressed_size_bytes": 57600,
  "checksum": "sha256:a1b2c3d4...",
  "entry_count": 50,
  "payload": "<base64-encoded compressed bytes>"
}
```

### 7.3 Domain-Specific Compression Notes

- The 50-entry corpus compresses to approximately 190 KB in gzip JSON format.
- MessagePack + lz4 yields approximately 260 KB but decodes 4× faster.
- Brotli on raw markdown achieves the best ratio due to high textual redundancy
  across vulnerability class descriptions.

## 8. Type Preservation

### 8.1 Type Map

| Conceptual Type | JSON | YAML | MsgPack | Protobuf |
|-----------------|------|------|---------|----------|
| Entry ID | string | string | str | string |
| Severity | string enum | string | fixstr | string |
| CVSS Range | [float, float] | [float, float] | array[float] | repeated float |
| Report Count | integer | integer | uint32 | uint32 |
| Payout Range | [int, int] | [int, int] | array[uint32] | repeated uint32 |
| Primitive List | [string] | [string] | array[str] | repeated string |
| Metadata Map | {k: v} | {k: v} | map | map<string,string> |
| Timestamp | ISO 8601 string | ISO 8601 string | str | string |
| Boolean Flags | true/false | true/false | bool | bool |

### 8.2 Precision Guarantees

- CVSS scores: IEEE 754 single-precision (float32) in Protobuf; full
  double-precision (float64) in JSON and YAML.
- Payout values: Unsigned 32-bit integer; max value $4,294,967,295.
- Timestamps: ISO 8601 with second resolution; sub-second precision optional.

## 9. Custom Serializers

### 9.1 VulnerabilityClassSerializer

Handles the 50-entry domain with awareness of vulnerability-specific fields.

```python
class VulnerabilityClassSerializer:
    DOMAIN = "real-world-case-studies"
    ENTRY_COUNT = 50

    def serialize(self, entry: CaseStudyEntry, fmt: str) -> bytes:
        if fmt == "json":
            return json.dumps(self._to_dict(entry)).encode("utf-8")
        elif fmt == "msgpack":
            return msgpack.packb(self._to_dict(entry))
        elif fmt == "protobuf":
            return self._to_proto(entry).SerializeToString()
        elif fmt == "yaml":
            return yaml.dump(self._to_dict(entry)).encode("utf-8")
        raise ValueError(f"Unsupported format: {fmt}")

    def deserialize(self, data: bytes, fmt: str) -> CaseStudyEntry:
        if fmt == "json":
            return CaseStudyEntry.from_dict(json.loads(data))
        elif fmt == "msgpack":
            return CaseStudyEntry.from_dict(msgpack.unpackb(data))
        elif fmt == "protobuf":
            proto = CaseStudyEntry_pb2.CaseStudyEntry()
            proto.ParseFromString(data)
            return CaseStudyEntry.from_proto(proto)
        elif fmt == "yaml":
            return CaseStudyEntry.from_dict(yaml.safe_load(data))
        raise ValueError(f"Unsupported format: {fmt}")
```

### 9.2 ChainSerializer

Handles cross-file attack chain references.

```python
class ChainSerializer:
    def serialize_chain(self, chain: AttackChain) -> dict:
        return {
            "chain_id": chain.id,
            "links": [
                {
                    "source": link.source_file,
                    "target": link.target_file,
                    "type": link.link_type,
                    "description": link.description,
                }
                for link in chain.links
            ],
            "payout_multiplier": chain.multiplier,
        }
```

### 9.3 SeveritySerializer

Maps severity strings to numeric values for sorting and filtering:

```python
SEVERITY_MAP = {
    "Critical": 4,
    "High": 3,
    "Medium": 2,
    "Low": 1,
    "Info": 0,
}
```

## 10. Format Detection

### 10.1 Auto-Detection Heuristic

```python
def detect_format(data: bytes) -> str:
    if data.startswith(b"{") or data.startswith(b"["):
        return "json"
    if data.startswith(b"---") or data.startswith(b"domain:"):
        return "yaml"
    if data[0] in MSGPACK_FIXSTR_MARKER_RANGE:
        return "msgpack"
    if data[:4] == b"\x0a\x00\x00\x00":
        return "protobuf"
    return "unknown"
```

### 10.2 File Extension Mapping

| Extension | Format | MIME Type |
|-----------|--------|-----------|
| `.json` | JSON | application/json |
| `.yaml` / `.yml` | YAML | application/x-yaml |
| `.msgpack` | MessagePack | application/msgpack |
| `.pb` / `.proto.bin` | Protobuf | application/protobuf |
| `.md` | Markdown (source) | text/markdown |

### 10.3 Content-Type Negotiation

The serialization API supports `Accept` header negotiation:

```
Accept: application/json          → JSON
Accept: application/x-yaml        → YAML
Accept: application/msgpack       → MessagePack
Accept: application/protobuf      → Protobuf
Accept: application/json+gzip     → Compressed JSON
```

## 11. Batch Operations

### 11.1 Batch Serialize All 50 Files

```yaml
operation: batch_serialize
domain: real-world-case-studies
source_dir: Brain/utils/serialization/
target_format: json
output_dir: dist/real-world-case-studies/
compression: gzip
parallelism: 8
error_handling: skip_and_report
progress:
  enabled: true
  interval: 5
  total: 50
```

### 11.2 Batch Serialize Selective Subset

```yaml
operation: batch_serialize
domain: real-world-case-studies
include:
  - "01-IDOR-*"
  - "03-SQL-*"
  - "10-SSTI-*"
  - "30-NoSQL-*"
  - "36-HTTP-*"
exclude:
  - "*Cloud*"
target_format: msgpack
```

### 11.3 Batch Deserialization

```yaml
operation: batch_deserialize
source_dir: dist/real-world-case-studies/
source_format: auto
target_format: json
output_dir: data/deserialized/
validation: strict
dedup_by: entry_id
```

### 11.4 Batch Cross-Reference Build

```yaml
operation: build_cross_references
domain: real-world-case-studies
entries: 50
link_types:
  - chaining_primitive
  - prerequisite_for
  - alternative_to
  - escalation_from
output: cross-references.json
```

## 12. Registry Schema

### 12.1 Domain Registry Entry

```json
{
  "registry_key": "real-world-case-studies",
  "domain_id": "real-world-case-studies",
  "version": "1.0.0",
  "entry_count": 50,
  "schema": "CaseStudyEntry",
  "formats": ["json", "yaml", "msgpack", "protobuf"],
  "compression": ["gzip", "zstd", "lz4", "snappy", "brotli"],
  "source_format": "markdown",
  "pipeline": "case-study-ingestion",
  "maintainer": "Prompt-Hunting",
  "last_registered": "2026-06-26T00:00:00Z"
}
```

### 12.2 File-Level Registry

Each of the 50 files registers independently:

```json
{
  "file_id": "RCS-43",
  "filename": "43-Path-Traversal-File-Inclusion.md",
  "vuln_class": "Path Traversal",
  "canonical_name": "Path Traversal / File Inclusion",
  "severity_default": "High",
  "associated_cves": [],
  "cross_references": ["RCS-44", "RCS-45"],
  "serialization_status": "active"
}
```

### 12.3 Registry for All 50 Files

```
RCS-01  → 01-IDOR-Account-Takeover-Case-Studies.md       [IDOR → ATO]
RCS-02  → 02-XSS-Stored-Persistent-Attacks.md           [Stored XSS]
RCS-03  → 03-SQL-Injection-Data-Breaches.md              [SQLi]
RCS-04  → 04-SSRF-Internal-Network-Access.md            [SSRF]
RCS-05  → 05-CSRF-State-Changing-Attacks.md              [CSRF]
RCS-06  → 06-Command-Injection-RCE.md                    [CMDi → RCE]
RCS-07  → 07-Deserialization-Remote-Code-Execution.md    [Deser RCE]
RCS-08  → 08-File-Upload-Arbitrary-Upload.md             [File Upload]
RCS-09  → 09-XXE-XML-External-Entity-Attacks.md          [XXE]
RCS-10  → 10-SSTI-Server-Side-Template-Injection.md      [SSTI]
RCS-11  → 11-JWT-Token-Manipulation.md                   [JWT]
RCS-12  → 12-Authentication-Bypass.md                    [Auth Bypass]
RCS-13  → 13-Privilege-Escalation.md                     [Privesc]
RCS-14  → 14-Business-Logic-Flaws.md                     [Biz Logic]
RCS-15  → 15-Information-Disclosure.md                   [Info Leak]
RCS-16  → 16-Memory-Corruption-Heap-Overflow.md          [Heap Overflow]
RCS-17  → 17-Deserialization-Java-Deserialization.md      [Java Deser]
RCS-18  → 18-Deserialization-PHP-Unserialize.md           [PHP Deser]
RCS-19  → 19-Deserialization-Python-Pickle.md             [Pickle]
RCS-20  → 20-Race-Condition-Time-of-Check.md             [TOCTOU]
RCS-21  → 21-Host-Header-Injection.md                    [Host Header]
RCS-22  → 22-DNS-Rebinding-Attacks.md                    [DNS Rebind]
RCS-23  → 23-WebSocket-Security-Issues.md                [WebSocket]
RCS-24  → 24-GraphQL-Introspection-Attacks.md            [GraphQL]
RCS-25  → 25-CSP-Bypass-Techniques.md                    [CSP Bypass]
RCS-26  → 26-Clickjacking-UI-Redressing.md               [Clickjack]
RCS-27  → 27-HTTP-Response-Splitting.md                  [Resp Split]
RCS-28  → 28-LDAP-Injection-Attacks.md                   [LDAPi]
RCS-29  → 29-XPath-Injection-Attacks.md                  [XPathi]
RCS-30  → 30-NoSQL-Injection-MongoDB.md                  [NoSQLi]
RCS-31  → 31-Prototype-Pollution-JavaScript.md           [Proto Poll]
RCS-32  → 32-Subdomain-Takeover.md                       [Sub Takeover]
RCS-33  → 33-Open-Redirect-Phishing.md                   [Open Redir]
RCS-34  → 34-Content-Spoofing-Attacks.md                 [Content Spoof]
RCS-35  → 35-WebCache-Poisoning.md                       [Cache Poison]
RCS-36  → 36-HTTP-Request-Smuggling.md                   [HTTP Smuggle]
RCS-37  → 37-WebSocket-Hijacking.md                      [WS Hijack]
RCS-38  → 38-CORS-Misconfiguration.md                    [CORS]
RCS-39  → 39-Token-Leakage-URL-Parameters.md             [Token Leak]
RCS-40  → 40-Sensitive-Data-Exposure.md                  [Data Exposure]
RCS-41  → 41-Weak-Encryption-Algorithms.md               [Weak Crypto]
RCS-42  → 42-Insecure-Cryptographic-Storage.md           [Insecure Store]
RCS-43  → 43-Path-Traversal-File-Inclusion.md            [Path Traversal]
RCS-44  → 44-Local-File-Inclusion-LFI.md                 [LFI]
RCS-45  → 45-Remote-File-Inclusion-RFI.md                [RFI]
RCS-46  → 46-Server-Side-Request-Forgery.md              [SSRF v2]
RCS-47  → 47-Client-Side-Request-Forgery.md              [CSRF v2]
RCS-48  → 48-Mobile-API-Security-Issues.md               [Mobile API]
RCS-49  → 49-Cloud-Misconfiguration-AWS.md               [Cloud]
RCS-50  → 50-API-Authentication-Bypass.md                [API Auth]
```

## 13. Error Handling

### 13.1 Serialization Errors

| Error Code | Condition | Recovery |
|------------|-----------|----------|
| `SER-001` | Unknown field in source data | Log warning, drop field |
| `SER-002` | Type mismatch during encode | Attempt coercion, else error |
| `SER-003` | Target format buffer overflow | Switch to streaming encoder |
| `SER-004` | Schema version mismatch | Apply migration, else error |
| `SER-005` | Empty input | Return default empty entry |

### 13.2 Deserialization Errors

| Error Code | Condition | Recovery |
|------------|-----------|----------|
| `DES-001` | Malformed input data | Report byte offset, skip entry |
| `DES-002` | Missing required field | Use schema default if available |
| `DES-003` | Unknown enum value | Store raw value, flag for review |
| `DES-004` | Truncated data | Return partial entry with flag |
| `DES-005` | Checksum mismatch | Reject, log integrity violation |

### 13.3 Error Response Format

```json
{
  "errors": [
    {
      "code": "SER-002",
      "file": "14-Business-Logic-Flaws.md",
      "field": "cvss_range",
      "message": "Expected array of 2 floats, got string '6.5-9.0'",
      "severity": "warning",
      "recovery_action": "coerced_string_to_array"
    }
  ],
  "entries_processed": 48,
  "entries_failed": 2,
  "entries_skipped": 0
}
```

## 14. Pipeline Integration

### 14.1 Ingestion Pipeline

```
[Markdown Files] → [Parser] → [Validator] → [Serializer] → [Compressor] → [Store]
       50 files        ↓           ↓              ↓               ↓           ↓
                    Frontmatter  Schema       Target fmt     gzip/zstd    Registry
                    extraction   validation   encoding       compression  update
```

### 14.2 Query Pipeline

```
[Query] → [Deserializer] → [Indexer] → [Filter] → [Sort] → [Response]
   ↓            ↓              ↓           ↓          ↓          ↓
 JSON/YAML   Format        In-memory    Severity   Payout     Serialized
  /MsgPack   detection     B-tree       + class    + reports  result set
```

### 14.3 Export Pipeline

```
[Internal Model] → [Serializer] → [Formatter] → [Compressor] → [Delivery]
       ↓                ↓              ↓              ↓             ↓
  CaseStudyEntry    Format-specific  Markdown/     gzip/brotli   API/CDN
                    encoding         HTML/PDF      compression   export
```

### 14.4 Pipeline Configuration

```yaml
pipelines:
  ingestion:
    input: "Brain/utils/serialization/*.md"
    parser: markdown_frontmatter
    validator: case_study_schema_v1
    serializer: json
    compressor: gzip
    output: "data/real-world-case-studies/"

  query:
    input_format: auto
    index_fields: [vuln_class, severity, file]
    sort_fields: [disclosed_reports, payout_range_usd]
    cache_format: msgpack
    cache_ttl: 3600

  export:
    input: data/real-world-case-studies/
    formats: [json, yaml, markdown, html]
    output: dist/
```

## 15. Full Domain File References

### 15.1 Source File Manifest

All 50 source files reside at:

```
Brain/utils/serialization/
├── 01-IDOR-Account-Takeover-Case-Studies.md
├── 02-XSS-Stored-Persistent-Attacks.md
├── 03-SQL-Injection-Data-Breaches.md
├── 04-SSRF-Internal-Network-Access.md
├── 05-CSRF-State-Changing-Attacks.md
├── 06-Command-Injection-RCE.md
├── 07-Deserialization-Remote-Code-Execution.md
├── 08-File-Upload-Arbitrary-Upload.md
├── 09-XXE-XML-External-Entity-Attacks.md
├── 10-SSTI-Server-Side-Template-Injection.md
├── 11-JWT-Token-Manipulation.md
├── 12-Authentication-Bypass.md
├── 13-Privilege-Escalation.md
├── 14-Business-Logic-Flaws.md
├── 15-Information-Disclosure.md
├── 16-Memory-Corruption-Heap-Overflow.md
├── 17-Deserialization-Java-Deserialization.md
├── 18-Deserialization-PHP-Unserialize.md
├── 19-Deserialization-Python-Pickle.md
├── 20-Race-Condition-Time-of-Check.md
├── 21-Host-Header-Injection.md
├── 22-DNS-Rebinding-Attacks.md
├── 23-WebSocket-Security-Issues.md
├── 24-GraphQL-Introspection-Attacks.md
├── 25-CSP-Bypass-Techniques.md
├── 26-Clickjacking-UI-Redressing.md
├── 27-HTTP-Response-Splitting.md
├── 28-LDAP-Injection-Attacks.md
├── 29-XPath-Injection-Attacks.md
├── 30-NoSQL-Injection-MongoDB.md
├── 31-Prototype-Pollution-JavaScript.md
├── 32-Subdomain-Takeover.md
├── 33-Open-Redirect-Phishing.md
├── 34-Content-Spoofing-Attacks.md
├── 35-WebCache-Poisoning.md
├── 36-HTTP-Request-Smuggling.md
├── 37-WebSocket-Hijacking.md
├── 38-CORS-Misconfiguration.md
├── 39-Token-Leakage-URL-Parameters.md
├── 40-Sensitive-Data-Exposure.md
├── 41-Weak-Encryption-Algorithms.md
├── 42-Insecure-Cryptographic-Storage.md
├── 43-Path-Traversal-File-Inclusion.md
├── 44-Local-File-Inclusion-LFI.md
├── 45-Remote-File-Inclusion-RFI.md
├── 46-Server-Side-Request-Forgery.md
├── 47-Client-Side-Request-Forgery.md
├── 48-Mobile-API-Security-Issues.md
├── 49-Cloud-Misconfiguration-AWS.md
└── 50-API-Authentication-Bypass.md
```

### 15.2 Serialized Output Manifest

```
dist/real-world-case-studies/
├── RCS-01.json.gz
├── RCS-02.json.gz
├── ...
├── RCS-50.json.gz
├── index.json          ← master index of all entries
├── chains.json         ← cross-reference chain data
└── manifest.sha256     ← integrity checksums
```

### 15.3 Cross-Reference Matrix

The following files share cross-reference links during serialization:

| Primary File | Linked Files | Link Type |
|-------------|-------------|-----------|
| 01 (IDOR) | 12, 13 | chaining_primitive, prerequisite_for |
| 03 (SQLi) | 40, 43 | escalation_from, alternative_to |
| 04 (SSRF) | 46 | alternative_to |
| 06 (CMDi) | 07, 10 | prerequisite_for, alternative_to |
| 07 (Deser) | 17, 18, 19 | sub_class_of |
| 10 (SSTI) | 06 | escalation_from |
| 11 (JWT) | 12, 39 | chaining_primitive, prerequisite_for |
| 12 (Auth) | 13, 50 | prerequisite_for, alternative_to |
| 16 (Heap) | 07 | alternative_to |
| 33 (Open Redir) | 11, 12 | chaining_primitive |
| 36 (Smuggle) | 35 | escalation_from |
| 43 (Path) | 44, 45 | sub_class_of |
| 46 (SSRF v2) | 04 | alternative_to |
| 49 (Cloud) | 04, 46 | chaining_primitive |

### 15.4 Serialization Statistics

| Metric | Value |
|--------|-------|
| Total source files | 50 |
| Total serialized entries | 50 |
| Cross-reference chains | 14 |
| Supported output formats | 4 (JSON, YAML, MsgPack, Protobuf) |
| Compression algorithms | 5 (gzip, zstd, lz4, snappy, brotli) |
| Estimated JSON size (uncompressed) | 184 KB |
| Estimated JSON+gzip size | 57 KB |
| Estimated MsgPack+lz4 size | 260 KB |
| Schema fields per entry | 15 |
| Custom serializer classes | 3 |

---

*Generated for the Prompt-Hunting `real-world-case-studies` domain.*
*Schema version 1.0.0 — 2026-06-26.*
