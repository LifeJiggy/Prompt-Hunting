# Advanced Chaining Techniques — Data Serialization Domain

```yaml
domain_id: advanced-chaining-techniques
domain_slug: chaining
version: "1.0.0"
created: "2026-06-26"
author: Prompt-Hunting Brain
total_files: 49
serialization_format: "json | yaml | msgpack | protobuf"
compression: "gzip | zlib | none"
state_machine: "chain-execution"
```

## Overview

The `advanced-chaining-techniques` domain defines data serialization schemas for multi-step vulnerability chaining pipelines. Each chain documents a sequence where one vulnerability leads to another, forming kill-chains from initial access through final impact. Serialization covers: chain graph definitions, execution state, evidence capture, step-to-step data passing, and final report aggregation.

The domain is organized into 49 specialized chain files spanning web application vulnerabilities (XSS, SQLi, SSRF, IDOR), infrastructure attacks (SSRF-to-RCE, container escape, cloud misconfig), cryptographic weaknesses, supply-chain vectors, and advanced persistent threat patterns. Every file follows a uniform serialization schema enabling programmatic chain execution, state persistence, and cross-chain correlation.

## Domain Mapping

Each file maps to a serialization schema with explicit input/output types, step dependencies, and evidence structure.

| File | Chain Type | Primary Schema | Input Schema | Output Schema |
|------|-----------|---------------|-------------|--------------|
| 01-Basic-Vulnerability-Chaining.md | `composite` | `chain-graph-v1` | `asset-list` | `chain-report` |
| 02-Information-Disclosure-to-RCE.md | `disclosure-to-rce` | `chain-graph-v1` | `disclosure-vector` | `rce-evidence` |
| 03-XSS-to-Account-Takeover.md | `xss-ato` | `chain-graph-v1` | `xss-injection` | `ato-proof` |
| 04-IDOR-to-Mass-Data-Extraction.md | `idor-breach` | `chain-graph-v1` | `idor-endpoint` | `data-exfil-log` |
| 05-SQL-Injection-to-Shell-Access.md | `sqli-shell` | `chain-graph-v1` | `sqli-vector` | `shell-session` |
| 06-SSRF-to-Internal-Network-Compromise.md | `ssrf-lateral` | `chain-graph-v1` | `ssrf-endpoint` | `network-map` |
| 07-CORS-Misconfiguration-Chains.md | `cors-abuse` | `chain-graph-v1` | `cors-config` | `data-theft-log` |
| 08-CSRF-to-Privilege-Escalation.md | `csrf-privesc` | `chain-graph-v1` | `csrf-vector` | `privilege-level` |
| 09-File-Upload-to-Web-Shell.md | `upload-shell` | `chain-graph-v1` | `upload-endpoint` | `shell-proof` |
| 10-XXE-to-Sensitive-Data-Access.md | `xxe-disclosure` | `chain-graph-v1` | `xxe-endpoint` | `file-dump` |
| 11-Deserialization-to-RCE.md | `deser-rce` | `chain-graph-v1` | `deser-vector` | `rce-session` |
| 12-JWT-Manipulation-Chains.md | `jwt-abuse` | `chain-graph-v1` | `jwt-token` | `auth-bypass` |
| 13-SSTI-to-Complete-Compromise.md | `ssti-rce` | `chain-graph-v1` | `ssti-vector` | `server-control` |
| 15-NoSQL-Injection-to-Data-Breach.md | `nosqli-breach` | `chain-graph-v1` | `nosqli-vector` | `data-dump` |
| 16-GraphQL-Abuse-Chains.md | `graphql-abuse` | `chain-graph-v1` | `graphql-endpoint` | `data-exfil` |
| 17-WebSocket-Security-Chains.md | `ws-hijack` | `chain-graph-v1` | `ws-endpoint` | `session-hijack` |
| 18-Prototype-Pollution-Exploitation.md | `proto-pollute` | `chain-graph-v1` | `pollution-vector` | `rce-or-xss` |
| 19-HTTP-Request-Smuggling-Chains.md | `smuggle` | `chain-graph-v1` | `smuggle-vector` | `cache-or-rce` |
| 20-Host-Header-Injection-Chains.md | `host-header` | `chain-graph-v1` | `host-injection` | `poison-or-ato` |
| 21-DNS-Rebinding-Attacks.md | `dns-rebind` | `chain-graph-v1` | `rebind-domain` | `ssrf-or-rce` |
| 22-Race-Condition-Exploitation.md | `race` | `chain-graph-v1` | `race-vector` | `state-corruption` |
| 23-Subdomain-Takeover-Chains.md | `subdomain- takeover` | `chain-graph-v1` | `dangling-cname` | `domain-control` |
| 24-Open-Redirect-to-Phishing.md | `redirect-phish` | `chain-graph-v1` | `redirect-url` | `credential-theft` |
| 25-Content-Spoofing-Chains.md | `spoof` | `chain-graph-v1` | `spoof-vector` | `trust-abuse` |
| 26-WebCache-Poisoning-Chains.md | `cache-poison` | `chain-graph-v1` | `poison-vector` | `victim-impact` |
| 27-Clickjacking-to-Account-Compromise.md | `clickjack` | `chain-graph-v1` | `frame-vector` | `account-compromise` |
| 28-Parameter-Pollution-Attacks.md | `param-pollute` | `chain-graph-v1` | `param-vector` | `logic-bypass` |
| 29-LDAP-Injection-Chains.md | `ldap-inject` | `chain-graph-v1` | `ldap-vector` | `auth-bypass` |
| 30-XPath-Injection-Exploitation.md | `xpath-inject` | `chain-graph-v1` | `xpath-vector` | `xml-data-dump` |
| 31-Session-Puzzling-Techniques.md | `session-puzzle` | `chain-graph-v1` | `session-vector` | `privilege-change` |
| 32-Insecure-File-Handling-Chains.md | `file-abuse` | `chain-graph-v1` | `file-vector` | `rce-or-traversal` |
| 33-Cross-Site-Script-Inclusion.md | `xssi` | `chain-graph-v1` | `xssi-vector` | `data-leak` |
| 34-HTTP-Response-Splitting.md | `response-split` | `chain-graph-v1` | `split-vector` | `cache-or-xss` |
| 35-Client-Side-Storage-Abuse.md | `storage-abuse` | `chain-graph-v1` | `storage-vector` | `session-or-data` |
| 36-Cryptography-Weakness-Chains.md | `crypto-weak` | `chain-graph-v1` | `crypto-vector` | `key-or-data` |
| 37-Third-Party-Component-Chains.md | `third-party` | `chain-graph-v1` | `component-vector` | `rce-or-escalation` |
| 38-Configuration-Misconfiguration-Chains.md | `config-misconfig` | `chain-graph-v1` | `config-vector` | `access-or-rce` |
| 39-Network-Infrastructure-Chains.md | `net-infra` | `chain-graph-v1` | `network-vector` | `network-control` |
| 40-Mobile-API-Chains.md | `mobile-api` | `chain-graph-v1` | `api-vector` | `data-or-rce` |
| 41-Cloud-Misconfiguration-Chains.md | `cloud-misconfig` | `chain-graph-v1` | `cloud-vector` | `cloud-control` |
| 42-Container-Escape-Chains.md | `container-escape` | `chain-graph-v1` | `escape-vector` | `host-access` |
| 43-Kubernetes-Attack-Chains.md | `k8s-attack` | `chain-graph-v1` | `k8s-vector` | `cluster-control` |
| 44-Blockchain-Exploit-Chains.md | `blockchain` | `chain-graph-v1` | `chain-vector` | `fund-theft` |
| 45-IoT-Device-Compromise-Chains.md | `iot-compromise` | `chain-graph-v1` | `iot-vector` | `device-control` |
| 46-Supply-Chain-Attack-Chains.md | `supply-chain` | `chain-graph-v1` | `supply-vector` | `upstream-control` |
| 47-Zero-Day-Chaining-Strategies.md | `zeroday` | `chain-graph-v1` | `zero-day-vector` | `full-compromise` |
| 48-Multi-Platform-Attack-Chains.md | `multi-platform` | `chain-graph-v1` | `platform-vector` | `cross-platform-control` |
| 49-Advanced-Persistent-Threat-Chains.md | `apt` | `chain-graph-v1` | `apt-vector` | `persistent-access` |
| 50-Master-Chaining-Framework.md | `framework` | `chain-graph-v1` | `any-vector` | `any-impact` |

## Format Support

### JSON

```json
{
  "chain_id": "ch-001",
  "domain": "advanced-chaining-techniques",
  "chain_type": "xss-ato",
  "version": "1.0.0",
  "steps": [
    {
      "step_id": "s1",
      "name": "xss-injection",
      "file_ref": "03-XSS-to-Account-Takeover.md",
      "input": {"vector": "reflected-xss", "endpoint": "/search"},
      "output": {"cookie": "redacted", "session_token": "redacted"},
      "status": "completed",
      "evidence_refs": ["ev-001"]
    },
    {
      "step_id": "s2",
      "name": "session-hijack",
      "file_ref": "17-WebSocket-Security-Chains.md",
      "depends_on": ["s1"],
      "input": {"session_token": "${s1.output.session_token}"},
      "output": {"account_access": true},
      "status": "completed",
      "evidence_refs": ["ev-002"]
    }
  ],
  "metadata": {
    "created_at": "2026-06-26T00:00:00Z",
    "author": "operator",
    "target": "example.com",
    "total_steps": 2,
    "completed_steps": 2
  }
}
```

### YAML

```yaml
chain_id: ch-002
domain: advanced-chaining-techniques
chain_type: ssrf-lateral
version: "1.0.0"
steps:
  - step_id: s1
    name: ssrf-endpoint-discovery
    file_ref: 06-SSRF-to-Internal-Network-Compromise.md
    input:
      vector: url-fetch
      endpoint: /api/proxy
    output:
      internal_hosts:
        - 10.0.0.1
        - 10.0.0.2
        - 10.0.0.3
    status: completed
    evidence_refs:
      - ev-001
  - step_id: s2
    name: metadata-extraction
    file_ref: 06-SSRF-to-Internal-Network-Compromise.md
    depends_on:
      - s1
    input:
      target: 10.0.0.1
      path: /latest/meta-data/
    output:
      iam_role: "arn:aws:iam::123456789:role/app-role"
    status: completed
    evidence_refs:
      - ev-002
metadata:
  created_at: "2026-06-26T00:00:00Z"
  author: operator
  target: example.com
```

### MessagePack

```python
import msgpack

chain_data = {
    b"chain_id": b"ch-003",
    b"domain": b"advanced-chaining-techniques",
    b"chain_type": b"sqli-shell",
    b"steps": [
        {
            b"step_id": b"s1",
            b"name": b"sqli-detection",
            b"file_ref": b"05-SQL-Injection-to-Shell-Access.md",
            b"input": {b"vector": b"union-based", b"param": b"id"},
            b"output": {b"db_type": b"mysql", b"version": b"8.0.32"},
            b"status": b"completed"
        },
        {
            b"step_id": b"s2",
            b"name": b"os-shell",
            b"file_ref": b"05-SQL-Injection-to-Shell-Access.md",
            b"depends_on": [b"s1"],
            b"input": {b"technique": b"xp_cmdshell"},
            b"output": {b"shell": True, b"user": b"nt authority\\system"},
            b"status": b"completed"
        }
    ]
}

packed = msgpack.packb(chain_data, use_bin_type=True)
unpacked = msgpack.unpackb(packed, raw=False)
```

### Protocol Buffers

```protobuf
syntax = "proto3";

package chaining;

message ChainStep {
  string step_id = 1;
  string name = 2;
  string file_ref = 3;
  map<string, string> input = 4;
  map<string, string> output = 5;
  StepStatus status = 6;
  repeated string evidence_refs = 7;
  repeated string depends_on = 8;
}

enum StepStatus {
  PENDING = 0;
  IN_PROGRESS = 1;
  COMPLETED = 2;
  FAILED = 3;
  SKIPPED = 4;
}

message ChainGraph {
  string chain_id = 1;
  string domain = 2;
  string chain_type = 3;
  string version = 4;
  repeated ChainStep steps = 5;
  ChainMetadata metadata = 6;
}

message ChainMetadata {
  string created_at = 1;
  string author = 2;
  string target = 3;
  int32 total_steps = 4;
  int32 completed_steps = 5;
}

message EvidenceEntry {
  string evidence_id = 1;
  string step_id = 2;
  string evidence_type = 3;
  bytes content = 4;
  map<string, string> headers = 5;
  string timestamp = 6;
}
```

## Chain State Serialization

Chain execution state tracks progress through multi-step attack chains with rollback capability and checkpoint persistence.

```python
from Brain.utils.serialization import Serializer

chain_state = {
    "chain_id": "ch-004",
    "current_step": "s3",
    "completed_steps": ["s1", "s2"],
    "pending_steps": ["s3", "s4", "s5"],
    "failed_steps": [],
    "step_results": {
        "s1": {"status": "completed", "output": {"ssrf_endpoint": "/api/fetch"}},
        "s2": {"status": "completed", "output": {"internal_ip": "169.254.169.254"}},
        "s3": {"status": "in_progress", "started_at": "2026-06-26T12:00:00Z"}
    },
    "evidence_chain": ["ev-001", "ev-002", "ev-003"],
    "rollback_checkpoints": [
        {"step": "s0", "state_snapshot": "base"},
        {"step": "s1", "state_snapshot": "post-disclosure"},
        {"step": "s2", "state_snapshot": "post-metadata"}
    ],
    "artifacts": {
        "captured_cookies": [],
        "extracted_tokens": [],
        "network_map": [],
        "file_contents": []
    }
}

serializer = Serializer(default_format="json", type_preserving=True)
serialized_state = serializer.encode(chain_state)
```

### State Machine Transitions

```
PENDING → IN_PROGRESS → COMPLETED
                     → FAILED → PENDING (retry)
                     → SKIPPED (dependency failed)
```

## Serialize Operations

### Single Chain Serialization

```python
from Brain.utils.serialization import Serializer

def serialize_chain(chain_definition: dict, format: str = "json") -> bytes:
    serializer = Serializer(
        default_format=format,
        type_preserving=True,
        compression="gzip",
        compression_threshold=4096
    )
    return serializer.encode(chain_definition)

# Usage: serialize each chain file's content
chain_files = [
    "01-Basic-Vulnerability-Chaining.md",
    "02-Information-Disclosure-to-RCE.md",
    "03-XSS-to-Account-Takeover.md",
    "04-IDOR-to-Mass-Data-Extraction.md",
    "05-SQL-Injection-to-Shell-Access.md",
    "06-SSRF-to-Internal-Network-Compromise.md",
    "07-CORS-Misconfiguration-Chains.md",
    "08-CSRF-to-Privilege-Escalation.md",
    "09-File-Upload-to-Web-Shell.md",
    "10-XXE-to-Sensitive-Data-Access.md",
    "11-Deserialization-to-RCE.md",
    "12-JWT-Manipulation-Chains.md",
    "13-SSTI-to-Complete-Compromise.md",
    "15-NoSQL-Injection-to-Data-Breach.md",
    "16-GraphQL-Abuse-Chains.md",
    "17-WebSocket-Security-Chains.md",
    "18-Prototype-Pollution-Exploitation.md",
    "19-HTTP-Request-Smuggling-Chains.md",
    "20-Host-Header-Injection-Chains.md",
    "21-DNS-Rebinding-Attacks.md",
    "22-Race-Condition-Exploitation.md",
    "23-Subdomain-Takeover-Chains.md",
    "24-Open-Redirect-to-Phishing.md",
    "25-Content-Spoofing-Chains.md",
    "26-WebCache-Poisoning-Chains.md",
    "27-Clickjacking-to-Account-Compromise.md",
    "28-Parameter-Pollution-Attacks.md",
    "29-LDAP-Injection-Chains.md",
    "30-XPath-Injection-Exploitation.md",
    "31-Session-Puzzling-Techniques.md",
    "32-Insecure-File-Handling-Chains.md",
    "33-Cross-Site-Script-Inclusion.md",
    "34-HTTP-Response-Splitting.md",
    "35-Client-Side-Storage-Abuse.md",
    "36-Cryptography-Weakness-Chains.md",
    "37-Third-Party-Component-Chains.md",
    "38-Configuration-Misconfiguration-Chains.md",
    "39-Network-Infrastructure-Chains.md",
    "40-Mobile-API-Chains.md",
    "41-Cloud-Misconfiguration-Chains.md",
    "42-Container-Escape-Chains.md",
    "43-Kubernetes-Attack-Chains.md",
    "44-Blockchain-Exploit-Chains.md",
    "45-IoT-Device-Compromise-Chains.md",
    "46-Supply-Chain-Attack-Chains.md",
    "47-Zero-Day-Chaining-Strategies.md",
    "48-Multi-Platform-Attack-Chains.md",
    "49-Advanced-Persistent-Threat-Chains.md",
    "50-Master-Chaining-Framework.md"
]
```

### Chain Graph Serialization

```python
def serialize_chain_graph(graph: dict) -> dict:
    return {
        "chain_id": graph["chain_id"],
        "nodes": [
            {
                "id": step["step_id"],
                "label": step["name"],
                "file_ref": step["file_ref"],
                "schema": step.get("schema", "chain-graph-v1"),
                "type": step.get("chain_type", "composite")
            }
            for step in graph["steps"]
        ],
        "edges": [
            {
                "source": dep,
                "target": step["step_id"]
            }
            for step in graph["steps"]
            for dep in step.get("depends_on", [])
        ],
        "metadata": graph.get("metadata", {})
    }
```

### Evidence Serialization

```python
evidence_entry = {
    "evidence_id": "ev-001",
    "step_id": "s1",
    "chain_id": "ch-001",
    "evidence_type": "http-request",
    "content": {
        "method": "GET",
        "url": "https://target.com/api/proxy?url=http://169.254.169.254/latest/meta-data/",
        "headers": {
            "Host": "target.com",
            "User-Agent": "Mozilla/5.0"
        },
        "response_status": 200,
        "response_body_snippet": "ami-id\ninstance-id\niam/security-credentials/"
    },
    "captured_at": "2026-06-26T12:00:00Z",
    "redacted": True,
    "format": "json"
}
```

## Deserialize Operations

### Single Chain Deserialization

```python
def deserialize_chain(data: bytes, format: str = "json") -> dict:
    serializer = Serializer(default_format=format, type_preserving=True)
    return serializer.decode(data)

# Auto-detect format
def deserialize_chain_auto(data: bytes) -> dict:
    from Brain.utils.serialization import detect_format
    detected = detect_format(data)
    return deserialize_chain(data, format=detected)
```

### State Restoration

```python
def restore_chain_state(state_data: bytes) -> dict:
    serializer = Serializer(type_preserving=True)
    state = serializer.decode(state_data)

    validated = {
        "chain_id": state["chain_id"],
        "current_step": state["current_step"],
        "completed_steps": set(state["completed_steps"]),
        "pending_steps": set(state["pending_steps"]),
        "failed_steps": set(state["failed_steps"]),
        "step_results": state["step_results"],
        "evidence_chain": state["evidence_chain"],
        "rollback_checkpoints": state["rollback_checkpoints"],
        "artifacts": state.get("artifacts", {})
    }

    return validated
```

### Cross-Chain Deserialization

```python
def deserialize_multi_chain(data: bytes) -> list:
    serializer = Serializer(type_preserving=True)
    payload = serializer.decode(data)

    chains = []
    for chain_data in payload.get("chains", []):
        chain = deserialize_chain(
            serializer.encode(chain_data),
            format="json"
        )
        chains.append(chain)

    return chains
```

### Batch Chain Loading

```python
def load_all_chains(chain_dir: str) -> dict:
    import os
    import glob

    chains = {}
    pattern = os.path.join(chain_dir, "*.md")
    for filepath in glob.glob(pattern):
        filename = os.path.basename(filepath)
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()
        chain_id = filename.replace(".md", "")
        chains[chain_id] = {
            "filename": filename,
            "content": content,
            "serialized": Serializer().encode({"id": chain_id, "content": content})
        }
    return chains
```

## Compression

### Chain-Specific Compression

```python
from Brain.utils.serialization import Serializer

def compress_chain(chain_data: dict, algorithm: str = "gzip") -> bytes:
    serializer = Serializer(
        default_format="json",
        compression=algorithm,
        compression_threshold=2048,
        type_preserving=True
    )
    return serializer.encode(chain_data)

# Chain data typically compresses 40-60% for JSON format
# MessagePack + gzip achieves 55-70% reduction
```

### Compression Strategies by Chain Type

| Chain Type | Best Format | Compression | Expected Ratio |
|-----------|------------|-------------|----------------|
| `xss-ato` | JSON | gzip | 45-55% |
| `sqli-shell` | MessagePack | zlib | 50-65% |
| `ssrf-lateral` | JSON | gzip | 40-50% |
| `deser-rce` | Protobuf | none | 60-75% (schema-enforced) |
| `cloud-misconfig` | YAML | gzip | 35-45% |
| `k8s-attack` | JSON | gzip | 40-50% |
| `apt` | MessagePack | gzip | 55-70% |
| `framework` | JSON | gzip | 45-55% |

### Streaming Compression for Large Chains

```python
def stream_compress_chains(chains: list, output_path: str):
    import gzip

    serializer = Serializer(default_format="json", type_preserving=True)
    with gzip.open(output_path, "wb") as f:
        for chain in chains:
            serialized = serializer.encode(chain)
            length_bytes = len(serialized).to_bytes(4, "big")
            f.write(length_bytes)
            f.write(serialized)
```

## Type Preservation

### Chain-Specific Type Tags

```python
chain_types = {
    "chain_id": {"$type": "string", "pattern": "^ch-\\d{3,6}$"},
    "created_at": {"$type": "datetime", "format": "iso8601"},
    "depends_on": {"$type": "list", "element_type": "string"},
    "step_results": {"$type": "ordered_dict", "key_type": "string", "value_type": "step-result"},
    "status": {"$type": "enum", "values": ["pending", "in_progress", "completed", "failed", "skipped"]},
    "evidence_refs": {"$type": "list", "element_type": "string", "pattern": "^ev-\\d{3,6}$"},
    "output": {"$type": "dict", "value_type": "any"},
    "artifacts": {"$type": "dict", "value_type": "list"}
}
```

### Extended Type Tags

```python
extended_types = {
    "http-request": {
        "$type": "http-request",
        "$value": {
            "method": "GET|POST|PUT|DELETE",
            "url": "string",
            "headers": "dict",
            "body": "string|bytes|null",
            "response_status": "int",
            "response_headers": "dict",
            "response_body": "string"
        }
    },
    "shell-session": {
        "$type": "shell-session",
        "$value": {
            "prompt": "string",
            "commands": "list[command-output]",
            "user": "string",
            "hostname": "string",
            "working_dir": "string"
        }
    },
    "network-map": {
        "$type": "network-map",
        "$value": {
            "hosts": "list[host-entry]",
            "connections": "list[connection]",
            "credentials": "list[credential]"
        }
    },
    "jwt-token": {
        "$type": "jwt",
        "$value": {
            "header": "dict",
            "payload": "dict",
            "signature": "string"
        }
    },
    "ssti-payload": {
        "$type": "ssti",
        "$value": {
            "template_engine": "string",
            "payload": "string",
            "response": "string",
            "rce_proof": "string"
        }
    }
}
```

### Round-Trip Type Preservation

```python
from Brain.utils.serialization import TypePreservingSerializer

ts = TypePreservingSerializer()

chain_with_types = {
    "chain_id": "ch-005",
    "created_at": datetime(2026, 6, 26, tzinfo=UTC),
    "steps": [
        {
            "step_id": "s1",
            "status": StepStatus.COMPLETED,
            "started_at": datetime(2026, 6, 26, 12, 0, 0),
            "completed_at": datetime(2026, 6, 26, 12, 5, 0),
            "output": {
                "jwt_token": JWTObject(header={"alg": "HS256"}, payload={"sub": "user1"}),
                "evidence_hash": uuid4()
            }
        }
    ]
}

encoded = ts.encode(chain_with_types)
decoded = ts.decode(encoded)
# decoded == chain_with_types  (all custom types preserved)
```

## Custom Serializers

### Chain-Specific Encoders

```python
from Brain.utils.serialization import Serializer, register_encoder

class ChainDefinition:
    def __init__(self, chain_id, chain_type, steps, metadata):
        self.chain_id = chain_id
        self.chain_type = chain_type
        self.steps = steps
        self.metadata = metadata

@register_encoder(ChainDefinition)
def encode_chain_def(obj: ChainDefinition) -> dict:
    return {
        "$type": "chain-definition",
        "chain_id": obj.chain_id,
        "chain_type": obj.chain_type,
        "steps": [
            {
                "step_id": s["step_id"],
                "name": s["name"],
                "file_ref": s["file_ref"],
                "input": s.get("input", {}),
                "output": s.get("output", {}),
                "status": s.get("status", "pending"),
                "depends_on": s.get("depends_on", [])
            }
            for s in obj.steps
        ],
        "metadata": obj.metadata
    }

class StepResult:
    def __init__(self, step_id, status, output, evidence_refs):
        self.step_id = step_id
        self.status = status
        self.output = output
        self.evidence_refs = evidence_refs

@register_encoder(StepResult)
def encode_step_result(obj: StepResult) -> dict:
    return {
        "$type": "step-result",
        "step_id": obj.step_id,
        "status": obj.status,
        "output": obj.output,
        "evidence_refs": obj.evidence_refs
    }

def decode_chain_def(data: dict) -> ChainDefinition:
    return ChainDefinition(
        chain_id=data["chain_id"],
        chain_type=data["chain_type"],
        steps=data["steps"],
        metadata=data.get("metadata", {})
    )

def decode_step_result(data: dict) -> StepResult:
    return StepResult(
        step_id=data["step_id"],
        status=data["status"],
        output=data["output"],
        evidence_refs=data["evidence_refs"]
    )

serializer = Serializer(
    custom_decoders={
        "chain-definition": decode_chain_def,
        "step-result": decode_step_result
    }
)
```

### Evidence Type Serializers

```python
@register_encoder(HttpRequest)
def encode_http_request(obj: HttpRequest) -> dict:
    return {
        "$type": "http-request",
        "method": obj.method,
        "url": obj.url,
        "headers": obj.headers,
        "body": obj.body,
        "response_status": obj.response_status,
        "response_body": obj.response_body[:1024]
    }

@register_encoder(ShellSession)
def encode_shell_session(obj: ShellSession) -> dict:
    return {
        "$type": "shell-session",
        "prompt": obj.prompt,
        "commands": [
            {"cmd": c.command, "output": c.output[:512]}
            for c in obj.commands
        ],
        "user": obj.user,
        "hostname": obj.hostname
    }

@register_encoder(NetworkMap)
def encode_network_map(obj: NetworkMap) -> dict:
    return {
        "$type": "network-map",
        "hosts": [
            {"ip": h.ip, "hostname": h.hostname, "ports": h.open_ports}
            for h in obj.hosts
        ],
        "connections": [
            {"src": c.src, "dst": c.dst, "port": c.port}
            for c in obj.connections
        ]
    }
```

## Format Detection

### Chain Format Detection

```python
from Brain.utils.serialization import detect_format

def detect_chain_format(data: bytes) -> str:
    detected = detect_format(data)
    if detected == "unknown":
        try:
            import json
            json.loads(data)
            return "json"
        except json.JSONDecodeError:
            pass

        try:
            import yaml
            yaml.safe_load(data)
            return "yaml"
        except yaml.YAMLError:
            pass

        return "unknown"
    return detected
```

### Detection Heuristics for Chain Data

| Marker | Format | Notes |
|--------|--------|-------|
| `0x1f 0x8b` | gzip-compressed | Auto-decompress then detect inner format |
| `0x78 0x9c` | zlib-compressed | Auto-decompress then detect inner format |
| `{` or `[` | JSON | Most chain files use JSON |
| `---` | YAML | Used for human-readable chain configs |
| `0x90-0x9f` | MessagePack | Binary chain state storage |
| `chain_id` key | Chain JSON | Domain-specific indicator |
| `steps` key | Chain graph | Confirms chain structure |

### Auto-Detection Pipeline

```python
def auto_detect_and_decode(data: bytes) -> dict:
    serializer = Serializer(type_preserving=True)

    outer_format = detect_format(data)
    if outer_format in ("gzip", "zlib"):
        data = serializer.decompress(data, format=outer_format)
        inner_format = detect_format(data)
    else:
        inner_format = outer_format

    return serializer.decode(data, format=inner_format)
```

## Batch Operations

### Batch Chain Serialization

```python
def batch_serialize_chains(chains: list, format: str = "json") -> bytes:
    serializer = Serializer(
        default_format=format,
        type_preserving=True,
        compression="gzip",
        compression_threshold=4096
    )
    return serializer.encode_batch(chains)

def batch_deserialize_chains(data: bytes) -> list:
    serializer = Serializer(type_preserving=True)
    return serializer.decode_batch(data)
```

### Streaming Chain Processing

```python
def stream_chain_processing(chain_iterator, output_path: str):
    serializer = Serializer(default_format="json", type_preserving=True)

    for chain in chain_iterator:
        serialized = serializer.encode(chain)
        with open(output_path, "ab") as f:
            length = len(serialized).to_bytes(4, "big")
            f.write(length)
            f.write(serialized)
```

### Batch Evidence Collection

```python
def batch_serialize_evidence(evidence_list: list) -> bytes:
    serializer = Serializer(
        default_format="msgpack",
        type_preserving=True,
        compression="zlib"
    )

    evidence_batch = {
        "batch_id": f"eb-{uuid4().hex[:8]}",
        "count": len(evidence_list),
        "entries": evidence_list,
        "created_at": datetime.utcnow().isoformat()
    }

    return serializer.encode(evidence_batch)
```

### Batch Operations Across All 49 Files

```python
ALL_CHAIN_FILES = [
    "01-Basic-Vulnerability-Chaining.md",
    "02-Information-Disclosure-to-RCE.md",
    "03-XSS-to-Account-Takeover.md",
    "04-IDOR-to-Mass-Data-Extraction.md",
    "05-SQL-Injection-to-Shell-Access.md",
    "06-SSRF-to-Internal-Network-Compromise.md",
    "07-CORS-Misconfiguration-Chains.md",
    "08-CSRF-to-Privilege-Escalation.md",
    "09-File-Upload-to-Web-Shell.md",
    "10-XXE-to-Sensitive-Data-Access.md",
    "11-Deserialization-to-RCE.md",
    "12-JWT-Manipulation-Chains.md",
    "13-SSTI-to-Complete-Compromise.md",
    "15-NoSQL-Injection-to-Data-Breach.md",
    "16-GraphQL-Abuse-Chains.md",
    "17-WebSocket-Security-Chains.md",
    "18-Prototype-Pollution-Exploitation.md",
    "19-HTTP-Request-Smuggling-Chains.md",
    "20-Host-Header-Injection-Chains.md",
    "21-DNS-Rebinding-Attacks.md",
    "22-Race-Condition-Exploitation.md",
    "23-Subdomain-Takeover-Chains.md",
    "24-Open-Redirect-to-Phishing.md",
    "25-Content-Spoofing-Chains.md",
    "26-WebCache-Poisoning-Chains.md",
    "27-Clickjacking-to-Account-Compromise.md",
    "28-Parameter-Pollution-Attacks.md",
    "29-LDAP-Injection-Chains.md",
    "30-XPath-Injection-Exploitation.md",
    "31-Session-Puzzling-Techniques.md",
    "32-Insecure-File-Handling-Chains.md",
    "33-Cross-Site-Script-Inclusion.md",
    "34-HTTP-Response-Splitting.md",
    "35-Client-Side-Storage-Abuse.md",
    "36-Cryptography-Weakness-Chains.md",
    "37-Third-Party-Component-Chains.md",
    "38-Configuration-Misconfiguration-Chains.md",
    "39-Network-Infrastructure-Chains.md",
    "40-Mobile-API-Chains.md",
    "41-Cloud-Misconfiguration-Chains.md",
    "42-Container-Escape-Chains.md",
    "43-Kubernetes-Attack-Chains.md",
    "44-Blockchain-Exploit-Chains.md",
    "45-IoT-Device-Compromise-Chains.md",
    "46-Supply-Chain-Attack-Chains.md",
    "47-Zero-Day-Chaining-Strategies.md",
    "48-Multi-Platform-Attack-Chains.md",
    "49-Advanced-Persistent-Threat-Chains.md",
    "50-Master-Chaining-Framework.md"
]

def batch_load_all_chains(chain_dir: str) -> dict:
    import os
    serializer = Serializer(type_preserving=True)

    chains = {}
    for filename in ALL_CHAIN_FILES:
        filepath = os.path.join(chain_dir, filename)
        if os.path.exists(filepath):
            with open(filepath, "r", encoding="utf-8") as f:
                content = f.read()
            chain_id = filename.replace(".md", "")
            chains[chain_id] = serializer.encode({
                "id": chain_id,
                "content": content,
                "format": "markdown"
            })

    return chains
```

## Registry Schema

### Chain Type Registry

```python
CHAIN_TYPE_REGISTRY = {
    "basic-vulnerability-chaining": {
        "file": "01-Basic-Vulnerability-Chaining.md",
        "schema": "chain-graph-v1",
        "category": "composite",
        "severity_range": ["low", "critical"],
        "required_capabilities": ["recon", "exploitation"]
    },
    "information-disclosure-to-rce": {
        "file": "02-Information-Disclosure-to-RCE.md",
        "schema": "chain-graph-v1",
        "category": "disclosure-to-rce",
        "severity_range": ["medium", "critical"],
        "required_capabilities": ["recon", "exploitation", "rce"]
    },
    "xss-to-account-takeover": {
        "file": "03-XSS-to-Account-Takeover.md",
        "schema": "chain-graph-v1",
        "category": "xss-ato",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["xss", "session-hijack"]
    },
    "idor-to-mass-data-extraction": {
        "file": "04-IDOR-to-Mass-Data-Extraction.md",
        "schema": "chain-graph-v1",
        "category": "idor-breach",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["idor", "data-exfil"]
    },
    "sql-injection-to-shell-access": {
        "file": "05-SQL-Injection-to-Shell-Access.md",
        "schema": "chain-graph-v1",
        "category": "sqli-shell",
        "severity_range": ["critical"],
        "required_capabilities": ["sqli", "rce"]
    },
    "ssrf-to-internal-network-compromise": {
        "file": "06-SSRF-to-Internal-Network-Compromise.md",
        "schema": "chain-graph-v1",
        "category": "ssrf-lateral",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["ssrf", "lateral-movement"]
    },
    "cors-misconfiguration-chains": {
        "file": "07-CORS-Misconfiguration-Chains.md",
        "schema": "chain-graph-v1",
        "category": "cors-abuse",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["cors-abuse", "data-theft"]
    },
    "csrf-to-privilege-escalation": {
        "file": "08-CSRF-to-Privilege-Escalation.md",
        "schema": "chain-graph-v1",
        "category": "csrf-privesc",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["csrf", "privesc"]
    },
    "file-upload-to-web-shell": {
        "file": "09-File-Upload-to-Web-Shell.md",
        "schema": "chain-graph-v1",
        "category": "upload-shell",
        "severity_range": ["critical"],
        "required_capabilities": ["file-upload", "rce"]
    },
    "xxe-to-sensitive-data-access": {
        "file": "10-XXE-to-Sensitive-Data-Access.md",
        "schema": "chain-graph-v1",
        "category": "xxe-disclosure",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["xxe", "data-exfil"]
    },
    "deserialization-to-rce": {
        "file": "11-Deserialization-to-RCE.md",
        "schema": "chain-graph-v1",
        "category": "deser-rce",
        "severity_range": ["critical"],
        "required_capabilities": ["deserialization", "rce"]
    },
    "jwt-manipulation-chains": {
        "file": "12-JWT-Manipulation-Chains.md",
        "schema": "chain-graph-v1",
        "category": "jwt-abuse",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["jwt", "auth-bypass"]
    },
    "ssti-to-complete-compromise": {
        "file": "13-SSTI-to-Complete-Compromise.md",
        "schema": "chain-graph-v1",
        "category": "ssti-rce",
        "severity_range": ["critical"],
        "required_capabilities": ["ssti", "rce"]
    },
    "nosql-injection-to-data-breach": {
        "file": "15-NoSQL-Injection-to-Data-Breach.md",
        "schema": "chain-graph-v1",
        "category": "nosqli-breach",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["nosqli", "data-exfil"]
    },
    "graphql-abuse-chains": {
        "file": "16-GraphQL-Abuse-Chains.md",
        "schema": "chain-graph-v1",
        "category": "graphql-abuse",
        "severity_range": ["medium", "critical"],
        "required_capabilities": ["graphql", "introspection"]
    },
    "websocket-security-chains": {
        "file": "17-WebSocket-Security-Chains.md",
        "schema": "chain-graph-v1",
        "category": "ws-hijack",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["websocket", "session-hijack"]
    },
    "prototype-pollution-exploitation": {
        "file": "18-Prototype-Pollution-Exploitation.md",
        "schema": "chain-graph-v1",
        "category": "proto-pollute",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["prototype-pollution", "rce-or-xss"]
    },
    "http-request-smuggling-chains": {
        "file": "19-HTTP-Request-Smuggling-Chains.md",
        "schema": "chain-graph-v1",
        "category": "smuggle",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["smuggling", "cache-or-rce"]
    },
    "host-header-injection-chains": {
        "file": "20-Host-Header-Injection-Chains.md",
        "schema": "chain-graph-v1",
        "category": "host-header",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["host-header", "poison-or-ato"]
    },
    "dns-rebinding-attacks": {
        "file": "21-DNS-Rebinding-Attacks.md",
        "schema": "chain-graph-v1",
        "category": "dns-rebind",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["dns-rebinding", "ssrf-or-rce"]
    },
    "race-condition-exploitation": {
        "file": "22-Race-Condition-Exploitation.md",
        "schema": "chain-graph-v1",
        "category": "race",
        "severity_range": ["medium", "critical"],
        "required_capabilities": ["race-condition", "state-corruption"]
    },
    "subdomain-takeover-chains": {
        "file": "23-Subdomain-Takeover-Chains.md",
        "schema": "chain-graph-v1",
        "category": "subdomain-takeover",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["subdomain-takeover", "domain-control"]
    },
    "open-redirect-to-phishing": {
        "file": "24-Open-Redirect-to-Phishing.md",
        "schema": "chain-graph-v1",
        "category": "redirect-phish",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["open-redirect", "phishing"]
    },
    "content-spoofing-chains": {
        "file": "25-Content-Spoofing-Chains.md",
        "schema": "chain-graph-v1",
        "category": "spoof",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["content-spoofing", "trust-abuse"]
    },
    "webcache-poisoning-chains": {
        "file": "26-WebCache-Poisoning-Chains.md",
        "schema": "chain-graph-v1",
        "category": "cache-poison",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["cache-poisoning", "victim-impact"]
    },
    "clickjacking-to-account-compromise": {
        "file": "27-Clickjacking-to-Account-Compromise.md",
        "schema": "chain-graph-v1",
        "category": "clickjack",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["clickjacking", "account-compromise"]
    },
    "parameter-pollution-attacks": {
        "file": "28-Parameter-Pollution-Attacks.md",
        "schema": "chain-graph-v1",
        "category": "param-pollute",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["param-pollution", "logic-bypass"]
    },
    "ldap-injection-chains": {
        "file": "29-LDAP-Injection-Chains.md",
        "schema": "chain-graph-v1",
        "category": "ldap-inject",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["ldap-injection", "auth-bypass"]
    },
    "xpath-injection-exploitation": {
        "file": "30-XPath-Injection-Exploitation.md",
        "schema": "chain-graph-v1",
        "category": "xpath-inject",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["xpath-injection", "data-exfil"]
    },
    "session-puzzling-techniques": {
        "file": "31-Session-Puzzling-Techniques.md",
        "schema": "chain-graph-v1",
        "category": "session-puzzle",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["session-puzzling", "privilege-change"]
    },
    "insecure-file-handling-chains": {
        "file": "32-Insecure-File-Handling-Chains.md",
        "schema": "chain-graph-v1",
        "category": "file-abuse",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["file-handling", "rce-or-traversal"]
    },
    "cross-site-script-inclusion": {
        "file": "33-Cross-Site-Script-Inclusion.md",
        "schema": "chain-graph-v1",
        "category": "xssi",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["xssi", "data-leak"]
    },
    "http-response-splitting": {
        "file": "34-HTTP-Response-Splitting.md",
        "schema": "chain-graph-v1",
        "category": "response-split",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["response-splitting", "cache-or-xss"]
    },
    "client-side-storage-abuse": {
        "file": "35-Client-Side-Storage-Abuse.md",
        "schema": "chain-graph-v1",
        "category": "storage-abuse",
        "severity_range": ["medium", "high"],
        "required_capabilities": ["storage-abuse", "session-or-data"]
    },
    "cryptography-weakness-chains": {
        "file": "36-Cryptography-Weakness-Chains.md",
        "schema": "chain-graph-v1",
        "category": "crypto-weak",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["crypto-analysis", "key-or-data"]
    },
    "third-party-component-chains": {
        "file": "37-Third-Party-Component-Chains.md",
        "schema": "chain-graph-v1",
        "category": "third-party",
        "severity_range": ["medium", "critical"],
        "required_capabilities": ["component-analysis", "rce-or-escalation"]
    },
    "configuration-misconfiguration-chains": {
        "file": "38-Configuration-Misconfiguration-Chains.md",
        "schema": "chain-graph-v1",
        "category": "config-misconfig",
        "severity_range": ["medium", "critical"],
        "required_capabilities": ["config-audit", "access-or-rce"]
    },
    "network-infrastructure-chains": {
        "file": "39-Network-Infrastructure-Chains.md",
        "schema": "chain-graph-v1",
        "category": "net-infra",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["network-analysis", "network-control"]
    },
    "mobile-api-chains": {
        "file": "40-Mobile-API-Chains.md",
        "schema": "chain-graph-v1",
        "category": "mobile-api",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["mobile-testing", "data-or-rce"]
    },
    "cloud-misconfiguration-chains": {
        "file": "41-Cloud-Misconfiguration-Chains.md",
        "schema": "chain-graph-v1",
        "category": "cloud-misconfig",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["cloud-audit", "cloud-control"]
    },
    "container-escape-chains": {
        "file": "42-Container-Escape-Chains.md",
        "schema": "chain-graph-v1",
        "category": "container-escape",
        "severity_range": ["critical"],
        "required_capabilities": ["container-security", "host-access"]
    },
    "kubernetes-attack-chains": {
        "file": "43-Kubernetes-Attack-Chains.md",
        "schema": "chain-graph-v1",
        "category": "k8s-attack",
        "severity_range": ["critical"],
        "required_capabilities": ["k8s-security", "cluster-control"]
    },
    "blockchain-exploit-chains": {
        "file": "44-Blockchain-Exploit-Chains.md",
        "schema": "chain-graph-v1",
        "category": "blockchain",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["smart-contract", "fund-theft"]
    },
    "iot-device-compromise-chains": {
        "file": "45-IoT-Device-Compromise-Chains.md",
        "schema": "chain-graph-v1",
        "category": "iot-compromise",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["iot-security", "device-control"]
    },
    "supply-chain-attack-chains": {
        "file": "46-Supply-Chain-Attack-Chains.md",
        "schema": "chain-graph-v1",
        "category": "supply-chain",
        "severity_range": ["critical"],
        "required_capabilities": ["supply-chain", "upstream-control"]
    },
    "zero-day-chaining-strategies": {
        "file": "47-Zero-Day-Chaining-Strategies.md",
        "schema": "chain-graph-v1",
        "category": "zeroday",
        "severity_range": ["critical"],
        "required_capabilities": ["zeroday", "full-compromise"]
    },
    "multi-platform-attack-chains": {
        "file": "48-Multi-Platform-Attack-Chains.md",
        "schema": "chain-graph-v1",
        "category": "multi-platform",
        "severity_range": ["high", "critical"],
        "required_capabilities": ["multi-platform", "cross-platform-control"]
    },
    "advanced-persistent-threat-chains": {
        "file": "49-Advanced-Persistent-Threat-Chains.md",
        "schema": "chain-graph-v1",
        "category": "apt",
        "severity_range": ["critical"],
        "required_capabilities": ["apt", "persistent-access"]
    },
    "master-chaining-framework": {
        "file": "50-Master-Chaining-Framework.md",
        "schema": "chain-graph-v1",
        "category": "framework",
        "severity_range": ["info", "critical"],
        "required_capabilities": ["framework", "any-impact"]
    }
}

def get_chain_registry() -> dict:
    return CHAIN_TYPE_REGISTRY

def get_chain_info(chain_type: str) -> dict:
    return CHAIN_TYPE_REGISTRY.get(chain_type, None)

def list_chain_types() -> list:
    return list(CHAIN_TYPE_REGISTRY.keys())
```

## Error Handling

### Chain Serialization Errors

```python
class ChainSerializationError(Exception):
    def __init__(self, chain_id: str, step_id: str, message: str):
        self.chain_id = chain_id
        self.step_id = step_id
        self.message = message
        super().__init__(f"Chain {chain_id} step {step_id}: {message}")

class ChainDeserializationError(Exception):
    def __init__(self, chain_id: str, format: str, message: str):
        self.chain_id = chain_id
        self.format = format
        self.message = message
        super().__init__(f"Chain {chain_id} format {format}: {message}")

class ChainStateCorruptionError(Exception):
    def __init__(self, chain_id: str, expected_step: str, actual_step: str):
        self.chain_id = chain_id
        self.expected_step = expected_step
        self.actual_step = actual_step
        super().__init__(
            f"Chain {chain_id} state corruption: "
            f"expected step {expected_step}, found {actual_step}"
        )

class EvidenceIntegrityError(Exception):
    def __init__(self, evidence_id: str, message: str):
        self.evidence_id = evidence_id
        self.message = message
        super().__init__(f"Evidence {evidence_id}: {message}")
```

### Error Recovery Strategies

```python
def safe_serialize_chain(chain: dict, format: str = "json") -> bytes:
    try:
        serializer = Serializer(
            default_format=format,
            type_preserving=True,
            compression="gzip"
        )
        return serializer.encode(chain)
    except TypeError as e:
        # Fallback: strip non-serializable fields
        sanitized = _sanitize_chain(chain)
        return Serializer(default_format=format).encode(sanitized)
    except Exception as e:
        raise ChainSerializationError(
            chain.get("chain_id", "unknown"),
            "all",
            str(e)
        )

def safe_deserialize_chain(data: bytes, format: str = None) -> dict:
    try:
        if format is None:
            format = detect_format(data)
        serializer = Serializer(type_preserving=True)
        return serializer.decode(data, format=format)
    except Exception as e:
        raise ChainDeserializationError(
            "unknown",
            format or "auto",
            str(e)
    )

def _sanitize_chain(chain: dict) -> dict:
    """Remove non-serializable fields for fallback encoding."""
    import json

    def _clean(obj):
        if isinstance(obj, dict):
            return {k: _clean(v) for k, v in obj.items()
                    if k not in ("_internal", "_raw")}
        elif isinstance(obj, (list, tuple)):
            return [_clean(item) for item in obj]
        try:
            json.dumps(obj)
            return obj
        except (TypeError, ValueError):
            return str(obj)

    return _clean(chain)
```

### Validation on Deserialization

```python
def validate_chain_graph(data: dict) -> bool:
    required_fields = ["chain_id", "steps", "metadata"]
    for field in required_fields:
        if field not in data:
            return False

    step_ids = set()
    for step in data["steps"]:
        if "step_id" not in step or "name" not in step:
            return False
        if step["step_id"] in step_ids:
            return False
        step_ids.add(step["step_id"])

    for step in data["steps"]:
        for dep in step.get("depends_on", []):
            if dep not in step_ids:
                return False

    return True
```

## Pipeline Integration

### Chain Execution Pipeline

```python
from Brain.utils.serialization import Serializer

class ChainPipeline:
    def __init__(self, chain_dir: str):
        self.chain_dir = chain_dir
        self.serializer = Serializer(
            default_format="json",
            type_preserving=True,
            compression="gzip"
        )
        self.registry = get_chain_registry()
        self.state_store = {}

    def load_chain(self, chain_type: str) -> dict:
        info = self.registry.get(chain_type)
        if not info:
            raise ValueError(f"Unknown chain type: {chain_type}")

        import os
        filepath = os.path.join(self.chain_dir, info["file"])
        with open(filepath, "r", encoding="utf-8") as f:
            content = f.read()

        return self.serializer.encode({
            "chain_type": chain_type,
            "schema": info["schema"],
            "category": info["category"],
            "content": content
        })

    def execute_step(self, chain_id: str, step_id: str, input_data: dict) -> dict:
        state = self.state_store.get(chain_id, {
            "chain_id": chain_id,
            "current_step": "s1",
            "completed_steps": [],
            "pending_steps": [],
            "step_results": {},
            "evidence_chain": []
        })

        state["step_results"][step_id] = {
            "status": "completed",
            "input": input_data,
            "output": {},
            "timestamp": datetime.utcnow().isoformat()
        }
        state["completed_steps"].append(step_id)

        self.state_store[chain_id] = state
        return state

    def save_state(self, chain_id: str) -> bytes:
        state = self.state_store.get(chain_id)
        if not state:
            raise ValueError(f"No state for chain: {chain_id}")

        serialized = self.serializer.encode(state)
        state_path = os.path.join(self.chain_dir, f".state/{chain_id}.json")
        os.makedirs(os.path.dirname(state_path), exist_ok=True)
        with open(state_path, "wb") as f:
            f.write(serialized)

        return serialized

    def load_state(self, chain_id: str) -> dict:
        state_path = os.path.join(self.chain_dir, f".state/{chain_id}.json")
        if not os.path.exists(state_path):
            return None

        with open(state_path, "rb") as f:
            data = f.read()

        state = self.serializer.decode(data)
        self.state_store[chain_id] = state
        return state

    def rollback(self, chain_id: str, to_step: str) -> dict:
        state = self.state_store.get(chain_id)
        if not state:
            raise ValueError(f"No state for chain: {chain_id}")

        checkpoint = None
        for cp in state.get("rollback_checkpoints", []):
            if cp["step"] == to_step:
                checkpoint = cp
                break

        if not checkpoint:
            raise ValueError(f"No checkpoint for step: {to_step}")

        self.state_store[chain_id] = checkpoint["state_snapshot"]
        return self.state_store[chain_id]

    def export_chain(self, chain_id: str, format: str = "json") -> bytes:
        state = self.state_store.get(chain_id)
        if not state:
            raise ValueError(f"No state for chain: {chain_id}")

        return self.serializer.encode(state, format=format)
```

### Pipeline Stage Integration

```python
PIPELINE_STAGES = {
    "recon": {
        "description": "Initial reconnaissance and target identification",
        "chain_files": [
            "01-Basic-Vulnerability-Chaining.md",
            "06-SSRF-to-Internal-Network-Compromise.md",
            "23-Subdomain-Takeover-Chains.md",
            "38-Configuration-Misconfiguration-Chains.md",
            "39-Network-Infrastructure-Chains.md"
        ],
        "input_schema": "target-list",
        "output_schema": "recon-report"
    },
    "exploitation": {
        "description": "Active exploitation of discovered vulnerabilities",
        "chain_files": [
            "02-Information-Disclosure-to-RCE.md",
            "03-XSS-to-Account-Takeover.md",
            "05-SQL-Injection-to-Shell-Access.md",
            "09-File-Upload-to-Web-Shell.md",
            "11-Deserialization-to-RCE.md",
            "13-SSTI-to-Complete-Compromise.md",
            "19-HTTP-Request-Smuggling-Chains.md",
            "47-Zero-Day-Chaining-Strategies.md"
        ],
        "input_schema": "recon-report",
        "output_schema": "exploit-log"
    },
    "lateral-movement": {
        "description": "Post-exploitation lateral movement",
        "chain_files": [
            "04-IDOR-to-Mass-Data-Extraction.md",
            "06-SSRF-to-Internal-Network-Compromise.md",
            "29-LDAP-Injection-Chains.md",
            "31-Session-Puzzling-Techniques.md",
            "42-Container-Escape-Chains.md",
            "43-Kubernetes-Attack-Chains.md",
            "48-Multi-Platform-Attack-Chains.md"
        ],
        "input_schema": "exploit-log",
        "output_schema": "lateral-map"
    },
    "persistence": {
        "description": "Establishing persistent access",
        "chain_files": [
            "12-JWT-Manipulation-Chains.md",
            "22-Race-Condition-Exploitation.md",
            "49-Advanced-Persistent-Threat-Chains.md",
            "46-Supply-Chain-Attack-Chains.md"
        ],
        "input_schema": "lateral-map",
        "output_schema": "persistence-report"
    },
    "exfiltration": {
        "description": "Data extraction and impact demonstration",
        "chain_files": [
            "10-XXE-to-Sensitive-Data-Access.md",
            "15-NoSQL-Injection-to-Data-Breach.md",
            "16-GraphQL-Abuse-Chains.md",
            "24-Open-Redirect-to-Phishing.md",
            "26-WebCache-Poisoning-Chains.md",
            "33-Cross-Site-Script-Inclusion.md",
            "36-Cryptography-Weakness-Chains.md",
            "44-Blockchain-Exploit-Chains.md",
            "45-IoT-Device-Compromise-Chains.md"
        ],
        "input_schema": "persistence-report",
        "output_schema": "final-report"
    }
}

def get_stage_chains(stage: str) -> list:
    return PIPELINE_STAGES.get(stage, {}).get("chain_files", [])

def get_full_pipeline() -> dict:
    return PIPELINE_STAGES
```

## Full Domain File References

Complete enumeration of all 49 chain files in the `advanced-chaining-techniques` domain with serialization metadata:

| # | File | Chain Category | Schema Version | Serialization Notes |
|---|------|---------------|---------------|---------------------|
| 1 | `01-Basic-Vulnerability-Chaining.md` | composite | v1 | Foundation chain; defines base step serialization template |
| 2 | `02-Information-Disclosure-to-RCE.md` | disclosure-to-rce | v1 | Two-step chain; info-leak → exploitation |
| 3 | `03-XSS-to-Account-Takeover.md` | xss-ato | v1 | Three-step chain; injection → session → account |
| 4 | `04-IDOR-to-Mass-Data-Extraction.md` | idor-breach | v1 | Bulk data extraction; paginated evidence serialization |
| 5 | `05-SQL-Injection-to-Shell-Access.md` | sqli-shell | v1 | DB-to-OS escalation; multi-dialect support |
| 6 | `06-SSRF-to-Internal-Network-Compromise.md` | ssrf-lateral | v1 | Network discovery chain; topology serialization |
| 7 | `07-CORS-Misconfiguration-Chains.md` | cors-abuse | v1 | Origin bypass chain; credential theft flow |
| 8 | `08-CSRF-to-Privilege-Escalation.md` | csrf-privesc | v1 | Cross-site escalation; state change tracking |
| 9 | `09-File-Upload-to-Web-Shell.md` | upload-shell | v1 | Upload → execution chain; file type bypass |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | xxe-disclosure | v1 | XML external entity chain; file read serialization |
| 11 | `11-Deserialization-to-RCE.md` | deser-rce | v1 | Object deserialization chain; gadget chain serialization |
| 12 | `12-JWT-Manipulation-Chains.md` | jwt-abuse | v1 | Token manipulation chain; algorithm confusion |
| 13 | `13-SSTI-to-Complete-Compromise.md` | ssti-rce | v1 | Template injection chain; engine detection |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | nosqli-breach | v1 | NoSQL injection chain; operator injection |
| 16 | `16-GraphQL-Abuse-Chains.md` | graphql-abuse | v1 | GraphQL introspection chain; query batching |
| 17 | `17-WebSocket-Security-Chains.md` | ws-hijack | v1 | WebSocket hijacking chain; connection state |
| 18 | `18-Prototype-Pollution-Exploitation.md` | proto-pollute | v1 | Prototype pollution chain; sink identification |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | smuggle | v1 | Request smuggling chain; CL.TE/TE.CL |
| 20 | `20-Host-Header-Injection-Chains.md` | host-header | v1 | Host header injection chain; password reset abuse |
| 21 | `21-DNS-Rebinding-Attacks.md` | dns-rebind | v1 | DNS rebinding chain; race window serialization |
| 22 | `22-Race-Condition-Exploitation.md` | race | v1 | Race condition chain; timing window data |
| 23 | `23-Subdomain-Takeover-Chains.md` | subdomain-takeover | v1 | Subdomain takeover chain; CNAME verification |
| 24 | `24-Open-Redirect-to-Phishing.md` | redirect-phish | v1 | Open redirect chain; credential phishing flow |
| 25 | `25-Content-Spoofing-Chains.md` | spoof | v1 | Content spoofing chain; trust chain abuse |
| 26 | `26-WebCache-Poisoning-Chains.md` | cache-poison | v1 | Cache poisoning chain; key generation |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | clickjack | v1 | Clickjacking chain; frame interaction data |
| 28 | `28-Parameter-Pollution-Attacks.md` | param-pollute | v1 | Parameter pollution chain; parser differential |
| 29 | `29-LDAP-Injection-Chains.md` | ldap-inject | v1 | LDAP injection chain; filter manipulation |
| 30 | `30-XPath-Injection-Exploitation.md` | xpath-inject | v1 | XPath injection chain; XML data extraction |
| 31 | `31-Session-Puzzling-Techniques.md` | session-puzzle | v1 | Session variable confusion; scope tracking |
| 32 | `32-Insecure-File-Handling-Chains.md` | file-abuse | v1 | File handling chain; path traversal + LFI |
| 33 | `33-Cross-Site-Script-Inclusion.md` | xssi | v1 | XSSI chain; JSONP abuse serialization |
| 34 | `34-HTTP-Response-Splitting.md` | response-split | v1 | Response splitting chain; header injection |
| 35 | `35-Client-Side-Storage-Abuse.md` | storage-abuse | v1 | LocalStorage/IndexedDB abuse chain |
| 36 | `36-Cryptography-Weakness-Chains.md` | crypto-weak | v1 | Crypto weakness chain; key recovery flow |
| 37 | `37-Third-Party-Component-Chains.md` | third-party | v1 | Third-party component chain; dependency abuse |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | config-misconfig | v1 | Config misconfig chain; default credential abuse |
| 39 | `39-Network-Infrastructure-Chains.md` | net-infra | v1 | Network infrastructure chain; service enumeration |
| 40 | `40-Mobile-API-Chains.md` | mobile-api | v1 | Mobile API chain; binary analysis + API abuse |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | cloud-misconfig | v1 | Cloud misconfig chain; IAM escalation |
| 42 | `42-Container-Escape-Chains.md` | container-escape | v1 | Container escape chain; namespace abuse |
| 43 | `43-Kubernetes-Attack-Chains.md` | k8s-attack | v1 | Kubernetes attack chain; API server abuse |
| 44 | `44-Blockchain-Exploit-Chains.md` | blockchain | v1 | Blockchain exploit chain; smart contract abuse |
| 45 | `45-IoT-Device-Compromise-Chains.md` | iot-compromise | v1 | IoT compromise chain; firmware + network |
| 46 | `46-Supply-Chain-Attack-Chains.md` | supply-chain | v1 | Supply chain attack chain; dependency confusion |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | zeroday | v1 | Zero-day chaining; multi-day combination |
| 48 | `48-Multi-Platform-Attack-Chains.md` | multi-platform | v1 | Multi-platform chain; cross-system lateral |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | apt | v1 | APT chain; long-term persistence serialization |
| 50 | `50-Master-Chaining-Framework.md` | framework | v1 | Master framework; orchestrates all chain types |

### Serialization Schema Versioning

```python
SCHEMA_VERSIONS = {
    "chain-graph-v1": {
        "version": "1.0.0",
        "fields": [
            "chain_id", "chain_type", "domain", "version",
            "steps", "metadata", "evidence"
        ],
        "backward_compatible": True,
        "deprecated_fields": [],
        "migration_notes": "Initial release"
    }
}

def get_schema_version(schema_name: str) -> dict:
    return SCHEMA_VERSIONS.get(schema_name, None)

def validate_schema(chain_data: dict, schema_name: str) -> bool:
    schema = SCHEMA_VERSIONS.get(schema_name)
    if not schema:
        return False

    for field in schema["fields"]:
        if field not in chain_data:
            return False

    return True
```

### Cross-Chain Reference Map

```python
CROSS_CHAIN_REFERENCES = {
    "01-Basic-Vulnerability-Chaining.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": []
    },
    "02-Information-Disclosure-to-RCE.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": ["38-Configuration-Misconfiguration-Chains.md"]
    },
    "03-XSS-to-Account-Takeover.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": ["27-Clickjacking-to-Account-Compromise.md"]
    },
    "04-IDOR-to-Mass-Data-Extraction.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": ["16-GraphQL-Abuse-Chains.md"]
    },
    "05-SQL-Injection-to-Shell-Access.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": ["10-XXE-to-Sensitive-Data-Access.md"]
    },
    "06-SSRF-to-Internal-Network-Compromise.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": ["39-Network-Infrastructure-Chains.md"]
    },
    "42-Container-Escape-Chains.md": {
        "referenced_by": ["48-Multi-Platform-Attack-Chains.md", "49-Advanced-Persistent-Threat-Chains.md"],
        "references": ["43-Kubernetes-Attack-Chains.md"]
    },
    "43-Kubernetes-Attack-Chains.md": {
        "referenced_by": ["42-Container-Escape-Chains.md", "48-Multi-Platform-Attack-Chains.md"],
        "references": ["41-Cloud-Misconfiguration-Chains.md"]
    },
    "49-Advanced-Persistent-Threat-Chains.md": {
        "referenced_by": ["50-Master-Chaining-Framework.md"],
        "references": [
            "46-Supply-Chain-Attack-Chains.md",
            "48-Multi-Platform-Attack-Chains.md",
            "47-Zero-Day-Chaining-Strategies.md"
        ]
    },
    "50-Master-Chaining-Framework.md": {
        "referenced_by": [],
        "references": [
            "01-Basic-Vulnerability-Chaining.md",
            "49-Advanced-Persistent-Threat-Chains.md",
            "47-Zero-Day-Chaining-Strategies.md"
        ]
    }
}

def get_chain_references(chain_file: str) -> dict:
    return CROSS_CHAIN_REFERENCES.get(chain_file, {
        "referenced_by": [],
        "references": []
    })

def get_reverse_references(chain_file: str) -> list:
    refs = []
    for file, data in CROSS_CHAIN_REFERENCES.items():
        if chain_file in data.get("references", []):
            refs.append(file)
    return refs
```

### Domain Constants

```python
DOMAIN_ID = "advanced-chaining-techniques"
DOMAIN_SLUG = "chaining"
DOMAIN_VERSION = "1.0.0"
TOTAL_CHAIN_FILES = 49
SCHEMA_VERSION = "chain-graph-v1"
SUPPORTED_FORMATS = ["json", "yaml", "msgpack", "protobuf"]
SUPPORTED_COMPRESSION = ["gzip", "zlib", "none"]
CHAIN_CATEGORIES = list(set(
    info["category"]
    for info in CHAIN_TYPE_REGISTRY.values()
))
```
