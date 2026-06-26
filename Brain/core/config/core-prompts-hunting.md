# Config: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Configuration Schema

Configuration for the core vulnerability hunting methodology across 50 vulnerability classes.

```yaml
hunting:
  # Test Depth
  depth:
    default: "thorough"  # quick, thorough, exhaustive
    per_class_timeout: 600
    max_endpoints_per_class: 100
    follow_redirects: true
    max_redirect_depth: 5

  # Bypass Configuration
  bypass:
    max_attempts: 3
    encoding_types: ["url", "double_url", "html", "unicode", "base64"]
    waf_fingerprint: true
    auto_select_bypass: true

  # Exploitation
  exploitation:
    safe_mode: true  # Do not exfiltrate data
    proof_of_concept: true
    max_exploitation_depth: 3
    verify_before_report: true

  # Vulnerability Classes
  classes:
    enabled: [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50]
    priority_order: [4,5,12,27,25,26,31,7,11,14]
    parallel_classes: 3

  # Tool Integration
  tools:
    burp_suite:
      enabled: true
      project_path: "./burp_projects"
    nuclei:
      enabled: true
      template_path: "./nuclei_templates"
    sqlmap:
      enabled: true
      safe_level: 2
    ffuf:
      enabled: true
      wordlist_path: "./wordlists"

  # Reporting
  reporting:
    auto_document: true
    screenshot_evidence: true
    curl_reproduction: true
    severity_classification: "cvss_3.1"
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_HUNT_DEPTH` | thorough | Test depth level |
| `BRAIN_HUNT_TIMEOUT` | 600 | Per-class timeout seconds |
| `BRAIN_HUNT_BYPASS_MAX` | 3 | Max bypass attempts |
| `BRAIN_HUNT_SAFE_MODE` | true | Safe exploitation mode |
