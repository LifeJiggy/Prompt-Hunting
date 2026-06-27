# Logging: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

Analysis-focused logging tracks case study selection, pattern extraction, MITRE mapping, and defensive recommendation generation.

## Log Entry Schema

```yaml
log_entry:
  timestamp: "2025-01-15T10:30:45.123Z"
  level: "INFO"
  component: "case_analyzer"
  domain: "high-level-cases"
  message: "Case analysis completed"
  data:
    case_id: "case_05"
    category: "critical_infrastructure"
    ttps_extracted: 12
    mitre_mappings: 15
    defenses_generated: 8
    analysis_duration_s: 180
```

## Domain File References

Logging applies to all 46 files in `High-Level-World-Case-Studies/` — case analysis progress and extracted patterns are logged.
