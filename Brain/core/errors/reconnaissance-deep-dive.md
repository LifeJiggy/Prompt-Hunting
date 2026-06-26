# Errors: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Error Definitions

Errors specific to the reconnaissance subsystem — enumeration, OSINT, and asset discovery.

| Error Code | Name | Description | Recovery |
|-----------|------|-------------|----------|
| `RECON_DNS_FAILED` | DNS Resolution Failed | DNS query failed for target | Retry with different resolver |
| `RECON_SOURCE_UNAVAILABLE` | Source Unavailable | CT log or OSINT source not responding | Try alternative source |
| `RECON_RATE_LIMITED` | Recon Rate Limited | Source imposed rate limit | Back off, retry later |
| `RECON_FALSE_ASSET` | False Asset | Discovered asset does not exist | Verify with live probe |
| `RECON_TAKEOVER_FALSE positive` | False Takeover | Subdomain takeover not actually possible | Verify CNAME chain |
| `RECON_CLOUD_ACCESS_DENIED` | Cloud Access Denied | Cannot enumerate cloud resources | Use alternative enum method |
| `RECON_JS_PARSE_FAILED` | JS Parse Failed | Could not parse JavaScript source | Use manual analysis |
| `RECON_SCOPE_EXCEEDED` | Scope Exceeded | Recon went beyond authorized scope | Stop, verify boundaries |
| `RECON_DATA_STALE` | Stale Data | Recon data is outdated | Refresh data |
| `RECON_ASSET_DUPLICATE` | Duplicate Asset | Same asset discovered multiple times | Deduplicate results |

## Error Hierarchy

```
ReconError (base)
├── RECON_DNS_FAILED
├── RECON_SOURCE_UNAVAILABLE
├── RECON_RATE_LIMITED
├── RECON_FALSE_ASSET
├── RECON_TAKEOVER_FALSE_POSITIVE
├── RECON_CLOUD_ACCESS_DENIED
├── RECON_JS_PARSE_FAILED
├── RECON_SCOPE_EXCEEDED
├── RECON_DATA_STALE
└── RECON_ASSET_DUPLICATE
```
