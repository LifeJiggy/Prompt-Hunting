# Errors: Specialized-Targets

**Domain Mapping:** `Specialized-Targets/`

## Error Definitions

Errors specific to target-specific security testing across 50 specialized domains.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `SPEC_CATEGORY_UNKNOWN` | Unknown Category | Cannot determine target category | Manual categorization |
| `SPEC_METHODLOGY_MISSING` | Methodology Missing | No testing methodology for this category | Use generic web methodology |
| `SPEC_TOOL_NOT_AVAILABLE` | Tool Not Available | Specialized tool not installed | Install or find alternative |
| `SPEC_PROTOCOL_UNSUPPORTED` | Unsupported Protocol | Target protocol not supported | Use protocol-specific tool |
| `SPEC_COMPLIANCE_CONFLICT` | Compliance Conflict | Testing conflicts with compliance requirements | Adjust testing approach |
| `SPEC_HARDWARE_REQUIRED` | Hardware Required | Testing requires physical hardware access | Document hardware requirements |
| `SPEC_FIRMWARE_ENCRYPTED` | Encrypted Firmware | Cannot analyze encrypted firmware | Attempt key extraction |
| `SPEC_NETWORK_ISOLATED` | Network Isolated | Target network is air-gapped | Document physical access needs |
| `SPEC_SAFETY_RISK` | Safety Risk | Testing could cause physical harm | Abort, document risk |
| `SPEC_REGULATORY_BLOCK` | Regulatory Block | Testing blocked by regulation | Document legal constraints |

## Error Hierarchy

```
SpecializedError (base)
├── SPEC_CATEGORY_UNKNOWN
├── SPEC_METHODLOGY_MISSING
├── SPEC_TOOL_NOT_AVAILABLE
├── SPEC_PROTOCOL_UNSUPPORTED
├── SPEC_COMPLIANCE_CONFLICT
├── SPEC_HARDWARE_REQUIRED
├── SPEC_FIRMWARE_ENCRYPTED
├── SPEC_NETWORK_ISOLATED
├── SPEC_SAFETY_RISK
└── SPEC_REGULATORY_BLOCK
```
