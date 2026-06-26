# Config: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Configuration Schema

Configuration for major incident analysis and attack pattern extraction.

```yaml
case_studies:
  # Analysis
  analysis:
    mitre_mapping: true
    mitre_version: "14.1"
    impact_quantification: true
    timeline_reconstruction: true
    pattern_extraction: true
    min_case_severity: "high"

  # Pattern Database
  patterns:
    storage: "./attack_patterns.json"
    auto_update: true
    confidence_threshold: 0.7
    min_occurrences: 2
    decay_factor: 0.95

  # Case Selection
  selection:
    similarity_matching: true
    target_profiling: true
    category_filtering: true
    max_cases_per_session: 5

  # Defensive Recommendations
  defense:
    auto_generate: true
    priority_mapping: true
    implementation_effort: true
    cost_estimation: false

  # Categories
  categories:
    critical_infrastructure: true
    zero_day: true
    supply_chain: true
    cloud: true
    mobile: true
    blockchain: true
    enterprise: true
    ics_scada: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_CASE_MITRE` | true | Enable MITRE mapping |
| `BRAIN_CASE_MIN_SEVERITY` | high | Minimum case severity |
| `BRAIN_CASE_MAX_PER_SESSION` | 5 | Max cases per session |
