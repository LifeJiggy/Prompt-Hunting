# Config: Advanced-Chaining-Techniques

**Domain Mapping:** `Advanced-Chaining-Techniques/`

## Configuration Schema

Configuration for the vulnerability chaining subsystem — chain discovery, design, and execution parameters.

```yaml
chaining:
  # Chain Discovery
  discovery:
    enabled: true
    min_primitives: 2
    max_chain_length: 10
    auto_discover: true
    confidence_threshold: 0.6

  # Chain Design
  design:
    require_demonstration: true
    impact_validation: true
    prefer_shortest_path: true
    consider_environment: true
    max_branching_factor: 5

  # Chain Execution
  execution:
    state_persistence: "per_step"
    timeout_per_step: 120
    rollback_on_failure: true
    verify_chain_integrity: true
    max_parallel_chains: 3

  # Chain Patterns
  patterns:
    known_patterns_db: "./chain_patterns.json"
    auto_update: true
    min_occurrences: 3
    confidence_decay: 0.95

  # Severity Amplification
  severity:
    amplify_on_chain: true
    min_amplified_severity: "high"
    require_impact_proof: true
    impact_documentation: "detailed"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_CHAIN_MAX_LENGTH` | 10 | Maximum chain steps |
| `BRAIN_CHAIN_TIMEOUT` | 120 | Step timeout seconds |
| `BRAIN_CHAIN_PATTERNS` | `./chain_patterns.json` | Pattern database path |
| `BRAIN_CHAIN_CONFIDENCE` | 0.6 | Minimum confidence threshold |
