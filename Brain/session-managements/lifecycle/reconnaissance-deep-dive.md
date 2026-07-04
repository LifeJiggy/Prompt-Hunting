# Session Lifecycle: Reconnaissance Deep Dive Domain

> Session lifecycle management for deep reconnaissance, asset discovery, and attack surface mapping across all 50 Reconnaissance-Deep-Dive modules.

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain | `recon-deep-dive` |
| Source Directory | `Reconnaissance-Deep-Dive/` |
| Module Count | 50 |
| Session Type | `recon-session` |
| State Complexity | High — tracks asset discovery, enumeration state, and attack surface |
| Parent System | Session Lifecycle Manager |

## Overview

This document defines the complete session lifecycle for the Reconnaissance Deep Dive domain. Recon sessions manage systematic deep reconnaissance of targets, covering subdomain enumeration, technology fingerprinting, endpoint discovery, cloud resource mapping, and comprehensive attack surface analysis. Each session tracks which recon modules are loaded, the current enumeration phase, assets discovered, and attack surface coverage.

Reconnaissance sessions are foundational — they feed data into hunting, chaining, and persistence sessions. The lifecycle must support extensive enumeration operations that may run for extended periods, producing large volumes of asset data.

## Session State Machine

```
┌─────────┐     activate      ┌──────────┐
│ created │ ─────────────────→│  active   │
└─────────┘                   └────┬─────┘
                                   │
        ┌──────────────────────────┼──────────────────────────┐
        ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │seeding   │              │enumerating│             │fingerprinting│
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       ▼                          ▼                          ▼
  ┌──────────┐              ┌──────────┐              ┌──────────┐
  │discovering│             │enriching │              │mapping   │
  └────┬─────┘              └────┬─────┘              └────┬─────┘
       │                          │                          │
       └──────────────────────────┼──────────────────────────┘
                                  ▼
                           ┌──────────┐
                           │completed │
                           └────┬─────┘
                                │
                                ▼
                           ┌──────────┐
                           │  closed  │
                           └──────────┘
```

### State Definitions

| State | Description |
|-------|-------------|
| `created` | Session initialized; target defined |
| `active` | Session running; recon workflow active |
| `seeding` | Initial seed data being collected (root domains, IPs) |
| `enumerating` | Systematic enumeration in progress (subdomains, ports) |
| `discovering` | New assets being discovered and validated |
| `fingerprinting` | Technology stack and service identification |
| `enriching` | Asset data being enriched with additional metadata |
| `mapping` | Attack surface being mapped and organized |
| `completed` | Recon objectives achieved |
| `closed` | Session terminated and results archived |

## Session Creation

### `create_recon_session()`

Creates a new session for a deep reconnaissance workflow.

**Parameters:**
- `name` (str): Human-readable session identifier
- `target` (str): Primary target for reconnaissance
- `recon_scope` (dict): Scope boundaries for recon
- `modules` (list[str]): Recon modules to load
- `depth` (str): Recon depth (surface, moderate, deep)
- `max_duration` (int): Maximum session lifetime in seconds (default: `28800` — 8 hours)
- `auto_checkpoint` (bool): Enable automatic state checkpointing (default: `True`)

**Returns:** `Session` object with unique ID, target, and recon configuration.

**Validation:**
- Session name must be unique
- Target must be within authorized scope
- Module references must exist in the directory
- Depth must be from recognized set

**Initialization Steps:**
1. Generate session ID: `recon_ses_<40-char-hex>`
2. Validate target and scope
3. Create session directory: `sessions/<session_id>/`
4. Initialize asset tracker with seed data collection
5. Register session in the active recon session registry
6. Emit `session.created` event

## Session Close

### `close_recon_session(session_id)`

Gracefully terminates a recon session.

**Pre-close Checks:**
1. Verify all asset data is saved
2. Check if enumeration is complete
3. Ensure attack surface map is finalized
4. Validate all discovered assets are persisted

**Close Process:**
1. Transition state to `closing`
2. Generate recon summary with asset counts
3. Finalize attack surface map
4. Save all discovered assets to persistent storage
5. Release external service connections (APIs, DNS resolvers)
6. Remove session from active registry
7. Transition state to `closed`
8. Emit `session.closed` event with duration and asset count

## Session Suspend

### `suspend_recon_session(session_id)`

Pauses an active recon session.

**Suspend Process:**
1. Complete current enumeration step
2. Serialize recon state including:
   - Current enumeration phase
   - Assets discovered so far
   - Pending enumeration tasks
   - Attack surface coverage
3. Save progress to checkpoint
4. Release connections (DNS, HTTP, API)
5. Transition state to `suspended`

**Suspend Reasons:**
| Reason | Description |
|--------|-------------|
| `user_initiated` | User explicitly paused recon |
| `rate_limit` | API rate limit hit |
| `resource_limit` | System resources exhausted |
| `scope_reached` | Scope boundary encountered |
| `checkpoint_required` | State size approaching limit |

## Session Resume

### `resume_recon_session(session_id)`

Restores a suspended recon session.

**Resume Process:**
1. Load serialized recon state from session store
2. Verify state integrity via checksum
3. Reestablish connections (DNS, HTTP, API)
4. Restore enumeration queue from saved state
5. Resume from last enumeration phase
6. Transition state to `active`
7. Emit `session.resumed` event with checkpoint age

**Resume Validation:**
- State must pass checksum verification
- Target must still be accessible
- API credentials must be valid
- Scope boundaries must still be valid

## Session Metadata Schema

### Standard Fields

| Field | Type | Description |
|-------|------|-------------|
| `session_id` | str | Unique session identifier |
| `name` | str | Human-readable name |
| `state` | str | Current lifecycle state |
| `created_at` | ISO 8601 | Creation timestamp |
| `updated_at` | ISO 8601 | Last update timestamp |
| `suspended_at` | ISO 8601 | Last suspension timestamp |
| `closed_at` | ISO 8601 | Closure timestamp |
| `target` | str | Primary recon target |

### Recon-Specific Fields

| Field | Type | Description |
|-------|------|-------------|
| `recon_scope` | dict | Scope boundaries |
| `depth` | str | Recon depth level |
| `modules_loaded` | list[str] | Recon modules loaded |
| `current_phase` | str | Current recon phase |
| `assets_discovered` | dict[str, list] | Assets by type |
| `total_assets` | int | Total asset count |
| `subdomains_found` | int | Subdomains discovered |
| `endpoints_found` | int | Endpoints discovered |
| `technologies_identified` | list[str] | Technologies found |
| `cloud_resources` | list[dict] | Cloud resources mapped |
| `attack_surface_coverage` | dict | Coverage metrics |
| `enumeration_queue` | list[dict] | Pending enumeration tasks |
| `dns_records` | dict | DNS records collected |
| `certificate_data` | list[dict] | TLS certificate data |
| `osint_data` | dict | OSINT intelligence gathered |

## Session Lookup

### `find_recon_sessions()`

Search for recon sessions by criteria.

**Search Parameters:**
- `state` (str): Filter by session state
- `target` (str): Filter by target
- `depth` (str): Filter by recon depth
- `completed` (bool): Filter by completion status
- `min_assets` (int): Filter by minimum asset count

**Examples:**
```python
# Find all active recon sessions
sessions = find_recon_sessions(state="active")

# Find deep recon sessions for a domain
sessions = find_recon_sessions(target="example.com", depth="deep")

# Find completed sessions with many assets
sessions = find_recon_sessions(completed=True, min_assets=1000)
```

**Search Behavior:**
- Filters are AND-ed together
- Results sorted by `created_at` descending
- Default result limit: 100

## Session Limits

### Recon-Specific Limits

| Limit | Default | Description |
|-------|---------|-------------|
| `max_active_recon_sessions` | 3 | Concurrent recon sessions |
| `max_modules_per_session` | 10 | Recon modules per session |
| `max_session_duration` | 28800s (8h) | Maximum recon runtime |
| `max_subdomains_per_session` | 10000 | Subdomains tracked |
| `max_endpoints_per_session` | 50000 | Endpoints tracked |
| `max_assets_per_session` | 100000 | Total assets tracked |
| `max_state_size` | 100MB | Serialized state size limit |
| `max_enumeration_tasks` | 5000 | Pending tasks in queue |
| `max_dns_queries` | 50000 | DNS queries per session |
| `max_http_requests` | 100000 | HTTP requests per session |

### Limit Enforcement

- Asset count checked after each discovery batch
- Enumeration queue size checked before adding tasks
- DNS query count tracked per resolver
- HTTP request count tracked per target
- When limits are hit: pause → checkpoint → notify user

## Session Isolation

### File System Isolation

```
sessions/<session_id>/
├── state/
│   ├── recon-state.json        # Recon phase tracker
│   ├── assets/                 # Discovered assets
│   │   ├── subdomains.json
│   │   ├── endpoints.json
│   │   ├── technologies.json
│   │   ├── cloud-resources.json
│   │   ├── certificates.json
│   │   └── dns-records.json
│   ├── enumeration/            # Enumeration progress
│   │   ├── queue.json
│   │   ├── completed.json
│   │   └── failed.json
│   └── checkpoints/            # Serialized checkpoints
├── output/
│   ├── attack-surface.json     # Complete attack surface map
│   ├── asset-report.md         # Asset discovery report
│   ├── technology-stack.md     # Technology identification
│   ├── dns-analysis.md         # DNS enumeration results
│   ├── certificate-report.md   # Certificate transparency data
│   └── visualizations/         # Attack surface visualizations
├── config/
│   ├── recon-config.json       # Session configuration
│   ├── scope.json              # Scope boundaries
│   ├── modules.json            # Module configuration
│   └── resolvers.json          # DNS resolver configuration
└── metadata.json               # Session metadata
```

### Network Isolation

- Each session maintains its own DNS resolver pool
- HTTP client connections are session-scoped
- API keys and credentials are session-scoped
- Rate limiting is applied per-session

### Memory Isolation

- Asset data is serialized to disk, not held in shared memory
- Enumeration queues are session-scoped
- No cross-session data leakage through shared state

## Asset Tracking

### Asset Types

| Type | Description | Discovery Method |
|------|-------------|------------------|
| `subdomain` | DNS subdomains | DNS enumeration, CT logs |
| `ip_address` | IP addresses | DNS resolution, port scan |
| `endpoint` | HTTP endpoints | Crawling, fuzzing |
| `api` | API endpoints | Swagger/OpenAPI, fuzzing |
| `technology` | Software/technologies | Fingerprinting |
| `cloud_resource` | Cloud assets | Cloud enumeration |
| `certificate` | TLS certificates | CT logs, direct scan |
| `email` | Email addresses | OSINT, DNS MX |
| `repository` | Code repositories | GitHub/GitLab search |
| `service` | Network services | Port scanning |

### Asset Schema

```json
{
  "asset_id": "asset_abc123",
  "type": "subdomain",
  "value": "api.example.com",
  "source": "dns_enumeration",
  "discovered_at": "2025-01-15T10:00:00Z",
  "validated": true,
  "metadata": {
    "ip_addresses": ["10.0.0.1"],
    "technologies": ["nginx", "node.js"],
    "status_code": 200,
    "headers": {"server": "nginx/1.18"}
  },
  "related_assets": ["asset_def456"]
}
```

### Attack Surface Coverage

Coverage is tracked by category:

| Category | Coverage Metric | Target |
|----------|----------------|--------|
| Subdomains | Discovered / Estimated | > 80% |
| Endpoints | Tested / Discovered | > 60% |
| Technologies | Identified / Estimated | > 90% |
| Cloud | Mapped / Estimated | > 70% |
| APIs | Documented / Discovered | > 50% |

## Module References for Reconnaissance Deep Dive

| Module | File Reference |
|--------|---------------|
| Advanced Subdomain Enumeration | `Reconnaissance-Deep-Dive/01-Advanced-Subdomain-Enumeration.md` |
| Passive OSINT Collection | `Reconnaissance-Deep-Dive/02-Passive-OSINT-Collection.md` |
| Active Asset Discovery | `Reconnaissance-Deep-Dive/03-Active-Asset-Discovery.md` |
| Technology Stack Fingerprinting | `Reconnaissance-Deep-Dive/04-Technology-Stack-Fingerprinting.md` |
| Cloud Resource Enumeration | `Reconnaissance-Deep-Dive/05-Cloud-Resource-Enumeration.md` |
| API Endpoint Discovery | `Reconnaissance-Deep-Dive/06-API-Endpoint-Discovery.md` |
| JavaScript Source Analysis | `Reconnaissance-Deep-Dive/07-JavaScript-Source-Analysis.md` |
| Configuration File Extraction | `Reconnaissance-Deep-Dive/08-Configuration-File-Extraction.md` |
| Version Detection Techniques | `Reconnaissance-Deep-Dive/09-Version-Detection-Techniques.md` |
| Content Discovery Automation | `Reconnaissance-Deep-Dive/10-Content-Discovery-Automation.md` |
| Directory Brute-Forcing | `Reconnaissance-Deep-Dive/11-Directory-Brute-Forcing.md` |
| File Type Detection | `Reconnaissance-Deep-Dive/12-File-Type-Detection.md` |
| Backup File Discovery | `Reconnaissance-Deep-Dive/13-Backup-File-Discovery.md` |
| Source Code Leak Detection | `Reconnaissance-Deep-Dive/14-Source-Code-Leak-Detection.md` |
| Git Repository Analysis | `Reconnaissance-Deep-Dive/15-Git-Repository-Analysis.md` |
| DNS Enumeration Advanced | `Reconnaissance-Deep-Dive/16-DNS-Enumeration-Advanced.md` |
| Certificate Transparency Logs | `Reconnaissance-Deep-Dive/17-Certificate-Transparency-Logs.md` |
| Historical Data Analysis | `Reconnaissance-Deep-Dive/18-Historical-Data-Analysis.md` |
| Social Media OSINT | `Reconnaissance-Deep-Dive/19-Social-Media-OSINT.md` |
| Employee Linked Assets | `Reconnaissance-Deep-Dive/20-Employee-Linked-Assets.md` |
| Third-Party Integration Discovery | `Reconnaissance-Deep-Dive/21-Third-Party-Integration-Discovery.md` |
| Web Archive Analysis | `Reconnaissance-Deep-Dive/22-Web-Archive-Analysis.md` |
| Pastebin and Leak Searching | `Reconnaissance-Deep-Dive/23-Pastebin-and-Leak-Searching.md` |
| Code Repository Mining | `Reconnaissance-Deep-Dive/24-Code-Repository-Mining.md` |
| Container Registry Enumeration | `Reconnaissance-Deep-Dive/25-Container-Registry-Enumeration.md` |
| IoT Device Discovery | `Reconnaissance-Deep-Dive/26-IoT-Device-Discovery.md` |
| Mobile App Analysis | `Reconnaissance-Deep-Dive/27-Mobile-App-Analysis.md` |
| API Documentation Extraction | `Reconnaissance-Deep-Dive/28-API-Documentation-Extraction.md` |
| WebSocket Endpoint Discovery | `Reconnaissance-Deep-Dive/29-WebSocket-Endpoint-Discovery.md` |
| GraphQL Introspection | `Reconnaissance-Deep-Dive/30-GraphQL-Introspection.md` |
| XML-RPC and SOAP Discovery | `Reconnaissance-Deep-Dive/31-XML-RPC-and-SOAP-Discovery.md` |
| Email Address Harvesting | `Reconnaissance-Deep-Dive/32-Email-Address-Harvesting.md` |
| Phone Number Enumeration | `Reconnaissance-Deep-Dive/33-Phone-Number-Enumeration.md` |
| Physical Location Intelligence | `Reconnaissance-Deep-Dive/34-Physical-Location-Intelligence.md` |
| Supply Chain Asset Mapping | `Reconnaissance-Deep-Dive/35-Supply-Chain-Asset-Mapping.md` |
| Competitor Analysis | `Reconnaissance-Deep-Dive/36-Competitor-Analysis.md` |
| Partner Network Discovery | `Reconnaissance-Deep-Dive/37-Partner-Network-Discovery.md` |
| Acquisition Target Analysis | `Reconnaissance-Deep-Dive/38-Acquisition-Target-Analysis.md` |
| Subsidiary Asset Mapping | `Reconnaissance-Deep-Dive/39-Subsidiary-Asset-Mapping.md` |
| Regional Infrastructure Mapping | `Reconnaissance-Deep-Dive/40-Regional-Infrastructure-Mapping.md` |
| Content Management System Detection | `Reconnaissance-Deep-Dive/41-Content-Management-System-Detection.md` |
| Framework and Library Identification | `Reconnaissance-Deep-Dive/42-Framework-and-Library-Identification.md` |
| Server Configuration Analysis | `Reconnaissance-Deep-Dive/43-Server-Configuration-Analysis.md` |
| SSL/TLS Certificate Analysis | `Reconnaissance-Deep-Dive/44-SSL-TLS-Certificate-Analysis.md` |
| HTTP Header Intelligence | `Reconnaissance-Deep-Dive/45-HTTP-Header-Intelligence.md` |
| Cookie Analysis and Session Management | `Reconnaissance-Deep-Dive/46-Cookie-Analysis-and-Session-Management.md` |
| Error Page Analysis | `Reconnaissance-Deep-Dive/47-Error-Page-Analysis.md` |
| Debug Endpoint Discovery | `Reconnaissance-Deep-Dive/48-Debug-Endpoint-Discovery.md` |
| Staging Environment Detection | `Reconnaissance-Deep-Dive/49-Staging-Environment-Detection.md` |
| Advanced Reconnaissance Strategy | `Reconnaissance-Deep-Dive/50-Advanced-Reconnaissance-Strategy.md` |

## Events

### Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `recon.session.created` | session_id, target | New recon session created |
| `recon.seed.collected` | session_id, seed_type | Seed data collected |
| `recon.subdomain.discovered` | session_id, subdomain | New subdomain found |
| `recon.endpoint.discovered` | session_id, endpoint | New endpoint found |
| `recon.technology.identified` | session_id, technology | Technology identified |
| `recon.cloud.resource.found` | session_id, resource | Cloud resource discovered |
| `recon.dns.record.found` | session_id, record_type | DNS record discovered |
| `recon.certificate.found` | session_id, domain | Certificate discovered |
| `recon.enrichment.completed` | session_id, asset_type | Enrichment completed |
| `recon.surface.mapped` | session_id, coverage | Attack surface updated |
| `recon.rate_limit.hit` | session_id, service | Rate limit encountered |
| `recon.session.suspended` | session_id, reason | Session suspended |
| `recon.session.resumed` | session_id | Session resumed |
| `recon.session.completed` | session_id, assets_count | Recon completed |
| `recon.session.closed` | session_id | Session closed |

### Event Subscription

```python
subscribe("recon.subdomain.discovered", on_subdomain_found)
subscribe("recon.cloud.resource.found", on_cloud_found)
subscribe("recon.rate_limit.hit", on_rate_limit)
```

## Error Recovery

### Error Categories

| Category | Examples | Recovery Strategy |
|----------|----------|-------------------|
| DNS Failure | Resolution timeout | Retry with alternative resolver |
| Rate Limit | API rate limited | Backoff and retry; rotate API key |
| Connection Loss | Network interruption | Reconnect; resume enumeration |
| State Corruption | Checksum mismatch | Restore from checkpoint |
| Scope Violation | Target out of scope | Stop; remove out-of-scope assets |
| Tool Failure | Scanner crash | Restart tool; retry last task |

### Recovery Flow

```
error detected → classify → if dns_failure:
    try_alternative_resolver → if success: continue
    → if exhausted: pause enumeration
→ if rate_limit:
    calculate_backoff → wait → retry
    → if max_retries: suspend and notify
→ if connection_loss:
    reconnect → verify → resume
    → if persistent: suspend and notify
→ if state_corruption:
    restore_from_checkpoint → validate → resume
```

## Integration Points

### With Hunting Sessions

- Recon sessions provide asset lists to hunting sessions
- Technology stack data guides vulnerability selection
- Endpoint lists feed into testing workflows

### With Chaining Sessions

- Recon sessions identify potential chain entry points
- Cloud resources are mapped for chaining opportunities
- Third-party integrations are flagged for chain analysis

### With Automation Sessions

- Recon modules can be orchestrated by automation sessions
- Results are shared via the session store
- Pipeline execution tracks recon phase completion

### With Memory System

- Discovered assets are stored in persistent memory
- Cross-session asset deduplication is supported
- Historical recon data is available for trend analysis

## Usage Examples

### Creating a Deep Recon Session

```python
session = create_recon_session(
    name="deep-recon-example.com",
    target="example.com",
    recon_scope={"domains": ["*.example.com"], "ip_ranges": ["10.0.0.0/8"]},
    modules=[
        "01-Advanced-Subdomain-Enumeration.md",
        "04-Technology-Stack-Fingerprinting.md",
        "06-API-Endpoint-Discovery.md",
        "16-DNS-Enumeration-Advanced.md"
    ],
    depth="deep"
)
```

### Suspending and Resuming

```python
# Suspend mid-recon
suspend_recon_session(session.session_id)

# Resume later
resume_recon_session(session.session_id)
# Recon continues from last enumeration phase
```

### Querying Recon Results

```python
sessions = find_recon_sessions(
    completed=True,
    target="example.com"
)
for s in sessions:
    print(f"Subdomains: {s.subdomains_found}, "
          f"Endpoints: {s.endpoints_found}, "
          f"Technologies: {len(s.technologies_identified)}")
```

### Tracking Asset Discovery

```python
# Subscribe to asset discovery events
def on_asset_discovered(event):
    print(f"New {event.asset_type}: {event.value}")

subscribe("recon.subdomain.discovered", on_asset_discovered)
subscribe("recon.endpoint.discovered", on_asset_discovered)
```