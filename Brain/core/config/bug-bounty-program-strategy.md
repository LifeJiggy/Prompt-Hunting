# Config: Bug-Bounty-Program-Strategy

**Domain Mapping:** `Bug-Bounty-Program-Strategy/`

## Configuration Schema

Configuration for program selection, ROI scoring, and strategic planning.

```yaml
strategy:
  # Program Scoring
  scoring:
    weights:
      bounty_range: 0.35
      response_time: 0.15
      competition_level: 0.15
      scope_clarity: 0.15
      program_maturity: 0.10
      hunter_friendliness: 0.10
    min_score_threshold: 0.5
    rescore_interval: 86400

  # Time Management
  time:
    max_hours_per_week: 40
    allocation_strategy: "roi_weighted"
    minimum_time_per_program: 2
    maximum_programs: 10
    time_zone_aware: true

  # Reward Analysis
  rewards:
    track_bounties: true
    currency: "USD"
    exchange_rate_update: 86400
    min_bounty_threshold: 100
    negotiation_enabled: true

  # Program Discovery
  discovery:
    platforms: ["hackerone", "bugcrowd", "intigriti", "immunefi"]
    auto_discover: true
    discovery_interval: 604800
    private_program_alerts: true

  # Competition Analysis
  competition:
    track_competitors: true
    activity_threshold: 10
    saturation_alert: true
    hunter_count_estimation: true

  # Reporting
  reporting:
    weekly_report: true
    monthly_report: true
    roi_dashboard: true
    program_comparison: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_STRAT_MIN_SCORE` | 0.5 | Minimum program score |
| `BRAIN_STRAT_MAX_PROGRAMS` | 10 | Maximum tracked programs |
| `BRAIN_STRAT_MAX_HOURS` | 40 | Weekly hour limit |
| `BRAIN_STRAT_PLATFORMS` | all | Active platforms |
