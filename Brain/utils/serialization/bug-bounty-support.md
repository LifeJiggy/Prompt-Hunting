# Serialization: Bug-Bounty-Support

**Domain Mapping:** `bug-bounty-support/`

## Overview

Data serialization for the support subsystem handles framework definitions, methodology databases, template libraries, and scope analysis results. These structures are loaded on demand and cached for reuse.

## Format Support

| Format | Use Case | Speed | Size |
|--------|----------|-------|------|
| JSON | API responses, config | Fast | Medium |
| YAML | Framework definitions | Medium | Large |
| MessagePack | Cache storage | Very Fast | Small |
| Protobuf | Cross-session transfer | Fast | Very Small |

## Serialization Schema

```yaml
framework_serializable:
  format: "json"
  schema:
    framework_id: { type: "string" }
    version: { type: "string" }
    categories: { type: "array" }
    methodologies: { type: "object" }
    templates: { type: "array" }
    metadata: { type: "object" }

methodology_serializable:
  format: "yaml"
  schema:
    method_id: { type: "string" }
    vuln_class: { type: "string" }
    steps: { type: "array" }
    tools: { type: "array" }
    estimated_time: { type: "string" }
```

## Operations

```python
def serialize_framework(framework):
    return Serializer.to_json(framework, indent=2)

def deserialize_framework(data):
    return Serializer.from_json(data)

def serialize_methodology(method):
    return Serializer.to_yaml(method)

def compress_frameworks(frameworks):
    return Serializer.compress(Serializer.to_msgpack(frameworks), algorithm="gzip")
```

## Domain File References

All 23 files in `bug-bounty-support/` use serialization for framework loading and template management.
