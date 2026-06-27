# Tool Validators: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Input validators for specialized target tools ensure category-specific parameter validation across 50 target domains.

## Validation Schemas

```yaml
iot_tool_validator:
  input:
    firmware_path: { type: "string", required: true }
    extraction_mode: { type: "string", enum: ["raw", "recursive", "smart"], default: "recursive" }
    target_arch: { type: "string", enum: ["arm", "mips", "x86", "x86_64", "auto"], default: "auto" }

mobile_tool_validator:
  input:
    app_path: { type: "string", required: true }
    platform: { type: "string", enum: ["ios", "android"], required: true }
    decompile: { type: "boolean", default: true }
    extract_secrets: { type: "boolean", default: true }

cloud_tool_validator:
  input:
    provider: { type: "string", enum: ["aws", "azure", "gcp"], required: true }
    credentials: { type: "object", required: true }
    services: { type: "array", items: { type: "string" }, optional: true }

blockchain_tool_validator:
  input:
    contract_address: { type: "string", pattern: "^0x[0-9a-fA-F]{40}$" }
    network: { type: "string", enum: ["mainnet", "goerli", "sepolia", "polygon", "bsc"] }
    source_code: { type: "string", optional: true }

ics_tool_validator:
  input:
    target_ip: { type: "string", format: "ipv4", required: true }
    protocol: { type: "string", enum: ["modbus", "dnp3", "opc", "bacnet"], required: true }
    port: { type: "integer", min: 1, max: 65535 }
```

## Domain File References

All 50 files in `Specialized-Targets/` have category-specific validation schemas for their tool inputs.
