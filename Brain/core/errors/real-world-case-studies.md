# Errors: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Error Definitions

Errors specific to disclosed report analysis and pattern extraction from 50 real-world findings.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `DISCLOSED_REPORT_NOT_FOUND` | Report Missing | Referenced disclosed report not available | Search alternative sources |
| `DISCLOSED_BOUNTY_UNKNOWN` | Bounty Unknown | Bounty amount not disclosed | Estimate from severity |
| `DISCLOSED_PATTERN_EXPIRED` | Pattern Expired | Extracted pattern no longer applicable | Update pattern |
| `DISCLOSED_TECHNIQUE_OUTDATED` | Outdated Technique | Exploitation technique patched | Find updated variant |
| `DISCLOSED_PLATFORM_MISMATCH` | Platform Mismatch | Pattern not applicable to target platform | Adapt for platform |
| `DISCLOSED_SEVERITY_MISALIGNED` | Severity Misaligned | Reported severity differs from CVSS | Note discrepancy |

## Error Hierarchy

```
DisclosedError (base)
├── DISCLOSED_REPORT_NOT_FOUND
├── DISCLOSED_BOUNTY_UNKNOWN
├── DISCLOSED_PATTERN_EXPIRED
├── DISCLOSED_TECHNIQUE_OUTDATED
├── DISCLOSED_PLATFORM_MISMATCH
└── DISCLOSED_SEVERITY_MISALIGNED
```
