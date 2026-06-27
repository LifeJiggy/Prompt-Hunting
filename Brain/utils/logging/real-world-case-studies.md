# Logging: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Overview

Pattern-focused logging tracks disclosed report analysis, pattern derivation, and hunt prompt generation.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "disclosed_analyzer"
  domain: "real-world-cases"
  message: "Pattern derived"
  data:
    case_id: "case_01"
    vuln_class: "idor"
    pattern_confidence: 0.85
    bounty: 10000
    hunt_prompt_generated: true
```

## Domain File References

Logging applies to all 50 files in `Real-World-Case-Studies/` — disclosed analysis and pattern extraction are logged.
