# Events: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Event Definitions

Events for the reconnaissance subsystem — tracking asset discovery, OSINT collection, fingerprinting, and attack surface mapping across 50 recon methodologies.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `recon.domain.enumerated` | `{domain, subdomains_count, sources[]}` | Subdomain enum complete |
| `recon.asset.discovered` | `{asset_id, type, address, status}` | New asset found |
| `recon.asset.live` | `{asset_id, http_status, technology}` | Asset confirmed live |
| `recon.fingerprint.complete` | `{asset_id, technologies[], versions[]}` | Tech stack identified |
| `recon.cloud.found` | `{provider, resource_type, bucket_name}` | Cloud resource discovered |
| `recon.api.endpoint.found` | `{endpoint_id, method, path, auth_required}` | API endpoint mapped |
| `recon.credential.leaked` | `{leak_id, type, source, credential_count}` | Leaked credential found |
| `recon.js.analysis.complete` | `{asset_id, endpoints[], secrets[]}` | JS analysis finished |
| `recon.ct.log.mined` | `{domain, certificates[], new_subdomains[]}` | CT log processed |
| `recon.osint.collected` | `{source, data_type, records_count}` | OSINT data gathered |
| `recon.staging.detected` | `{asset_id, environment_type}` | Dev/staging found |
| `recon.takeover.possible` | `{subdomain, service, status}` | Subdomain takeover viable |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `automation.pipeline.started` | Automation | Trigger recon phase |
| `session.resumed` | Session Mgmt | Resume interrupted recon |

## Event Flow

```
automation.pipeline.started
        │
        ▼
recon.domain.enumerated
        │
   ┌────┼────────┐
   │    │        │
   ▼    ▼        ▼
asset.discovered  ct.log.mined  osint.collected
   │
   ▼
asset.live
   │
   ▼
fingerprint.complete
   │
   ┌────┼────────┐
   │    │        │
   ▼    ▼        ▼
cloud.found  api.endpoint.found  js.analysis.complete
   │
   ▼
recon.takeover.possible (if dangling DNS)
```
