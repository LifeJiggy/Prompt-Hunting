# Validation: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Overview

Schema validation for specialized target tools ensures category-specific parameter validation across 50 target domains.

## Validation Schemas

```yaml
iot_validator:
  input:
    firmware_path: { type: "string", required: true }
    extraction_mode: { type: "string", enum: ["raw", "recursive", "smart"], default: "recursive" }

mobile_validator:
  input:
    app_path: { type: "string", required: true }
    platform: { type: "string", enum: ["ios", "android"], required: true }

cloud_validator:
  input:
    provider: { type: "string", enum: ["aws", "azure", "gcp"], required: true }
    credentials: { type: "object", required: true }

blockchain_validator:
  input:
    contract_address: { type: "string", pattern: "^0x[0-9a-fA-F]{40}$" }
    network: { type: "string", enum: ["mainnet", "goerli", "sepolia", "polygon", "bsc"] }
```

## Domain File References

All 50 files in `Specialized-Targets/` have category-specific validation schemas.
