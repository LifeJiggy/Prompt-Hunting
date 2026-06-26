# Config: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Configuration Schema

Configuration for disclosed report analysis and pattern extraction from 50 real-world findings.

```yaml
disclosed:
  # Analysis
  analysis:
    root_cause_analysis: true
    exploitation_documentation: true
    severity_correlation: true
    bounty_tracking: true
    platform_comparison: true

  # Pattern Database
  patterns:
    storage: "./disclosed_patterns.json"
    auto_generate_hunt_prompts: true
    confidence_threshold: 0.6
    min_bounty: 100

  # Platform Sources
  platforms:
    hackerone:
      enabled: true
      min_bounty: 100
      disclosed_only: true
    bugcrowd:
      enabled: true
      min_bounty: 100
      disclosed_only: true
    intigriti:
      enabled: true
      min_bounty: 50

  # Vulnerability Class Coverage
  coverage:
    injection: true
    xss: true
    auth: true
    ssrf: true
    deserialization: true
    logic: true
    crypto: true
    file_inclusion: true
    advanced: true

  # Hunt Prompt Generation
  hunt_prompts:
    auto_generate: true
    include_poc: true
    include_bypass: true
    format: "structured"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_DISC_MIN_BOUNTY` | 100 | Minimum bounty filter |
| `BRAIN_DISC_AUTO_HUNT` | true | Auto-generate hunt prompts |
| `BRAIN_DISC_CONFIDENCE` | 0.6 | Pattern confidence threshold |
