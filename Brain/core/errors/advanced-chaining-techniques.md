# Errors: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Error Definitions

Errors specific to the vulnerability chaining subsystem.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `CHAIN_TOO_LONG` | Chain Exceeds Max Length | Chain has more steps than allowed | Shorten chain or split |
| `CHAIN_STEP_FAILED` | Chain Step Failed | Intermediate step in chain failed | Evaluate alternative path |
| `CHAIN_PRIMITIVE_MISSING` | Missing Primitive | Required vulnerability primitive not found | Re-scan for missing vuln |
| `CHAIN_IMPACT_UNDEMONSTRABLE` | Impact Not Demonstrable | Cannot prove end-to-end impact | Document theoretical chain |
| `CHAIN_LOOP_DETECTED` | Chain Loop | Chain contains circular dependency | Break loop, redesign |
| `CHAIN_STATE_CORRUPT` | Chain State Corrupt | Intermediate chain state invalid | Restart chain from last checkpoint |
| `CHAIN_ENVIRONMENT_CHANGED` | Environment Changed | Target environment changed during chain | Re-evaluate chain validity |
| `CHAIN_SEVERITY_LOW` | Low Severity Chain | Chain does not amplify to critical | Abandon, find better primitives |
| `CHAIN_TIMEOUT` | Chain Execution Timeout | Chain exceeded time limit | Parallelize steps, optimize |

## Error Hierarchy

```
ChainingError (base)
├── CHAIN_TOO_LONG
├── CHAIN_STEP_FAILED
├── CHAIN_PRIMITIVE_MISSING
├── CHAIN_IMPACT_UNDEMONSTRABLE
├── CHAIN_LOOP_DETECTED
├── CHAIN_STATE_CORRUPT
├── CHAIN_ENVIRONMENT_CHANGED
├── CHAIN_SEVERITY_LOW
└── CHAIN_TIMEOUT
```
