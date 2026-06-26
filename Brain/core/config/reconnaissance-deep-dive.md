# Config: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Configuration Schema

Configuration for the reconnaissance subsystem — enumeration, OSINT, fingerprinting, and asset discovery.

```yaml
reconnaissance:
  # Subdomain Enumeration
  subdomain:
    sources: ["crt.sh", "virustotal", "securitytrails", "shodan", "github"]
    brute_force: true
    wordlist: "./wordlists/subdomains.txt"
    max_depth: 3
    takeover_check: true

  # OSINT
  osint:
    passive_only: false
    search_engines: ["google", "bing", "yandex"]
    github_search: true
    pastebin_monitor: true
    social_media: true
    employee_enumeration: true

  # Fingerprinting
  fingerprint:
    technology_detection: true
    version_detection: true
    waf_detection: true
    cms_detection: true
    framework_detection: true

  # Cloud Enumeration
  cloud:
    aws:
      enabled: true
      s3_enum: true
      lambda_enum: true
    azure:
      enabled: true
      blob_enum: true
    gcp:
      enabled: true
      gcs_enum: true

  # API Discovery
  api:
    swagger_enum: true
    graphql_introspection: true
    websocket_discovery: true
    soap_discovery: true

  # Rate Limiting
  rate_limiting:
    global_rps: 10
    per_source_rps: 5
    backoff_on_error: true
    max_retries: 3

  # Asset Management
  assets:
    store_in_memory: true
    asset_graph: true
    live_verification: true
    change_detection: true
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `BRAIN_RECON_RPS` | 10 | Global requests per second |
| `BRAIN_RECON_TAKEOVER` | true | Enable takeover checks |
| `BRAIN_RECON_CLOUD` | true | Enable cloud enumeration |
| `BRAIN_RECON_API` | true | Enable API discovery |
