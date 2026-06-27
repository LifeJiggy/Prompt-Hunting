# State Persistence: Reconnaissance Deep Dive Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Reconnaissance Deep Dive |
| **Directory** | `Reconnaissance-Deep-Dive/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/reconnaissance-deep-dive.md` |
| **Serialization** | JSON (primary), MessagePack (asset stream), Protobuf (asset archive) |
| **Storage Backend** | Filesystem + SQLite WAL + Graph DB |

---

## 1. Overview

This document defines the **state persistence architecture** for the Reconnaissance Deep Dive domain. This domain encompasses 50 specialized reconnaissance modules covering subdomain enumeration, OSINT, technology fingerprinting, API discovery, cloud resource enumeration, and advanced reconnaissance strategies.

The persistence layer captures the complete asset inventory — discovered subdomains, live hosts, technology stacks, API endpoints, cloud resources, employee information, and the relationships between all discovered assets. Reconnaissance state is foundational — it feeds into all subsequent hunting domains.

---

## 2. Domain File Registry

All 50 domain files organized by recon category:

### Subdomain and DNS Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 01 | `01-Advanced-Subdomain-Enumeration.md` | Subdomain enum | Persistent |
| 16 | `16-DNS-Enumeration-Advanced.md` | DNS enum | Persistent |
| 17 | `17-Certificate-Transparency-Logs.md` | CT logs | Persistent |
| 18 | `18-Historical-Data-Analysis.md` | Historical data | Persistent |
| 32 | `32-Email-Address-Harvesting.md` | Email harvest | Persistent |
| 33 | `33-Phone-Number-Enumeration.md` | Phone enum | Persistent |

### Asset Discovery
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 02 | `02-Passive-OSINT-Collection.md` | OSINT | Persistent |
| 03 | `03-Active-Asset-Discovery.md` | Active discovery | Runtime |
| 04 | `04-Technology-Stack-Fingerprinting.md` | Tech fingerprint | Persistent |
| 05 | `05-Cloud-Resource-Enumeration.md` | Cloud recon | Persistent |
| 06 | `06-API-Endpoint-Discovery.md` | API recon | Runtime |
| 07 | `07-JavaScript-Source-Analysis.md` | JS analysis | Runtime |
| 08 | `08-Configuration-File-Extraction.md` | Config extraction | Runtime |
| 09 | `09-Version-Detection-Techniques.md` | Version detection | Runtime |
| 10 | `10-Content-Discovery-Automation.md` | Content discovery | Runtime |
| 11 | `11-Directory-Brute-Forcing.md` | Directory brute | Runtime |

### File and Source Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 12 | `12-File-Type-Detection.md` | File type enum | Runtime |
| 13 | `13-Backup-File-Discovery.md` | Backup discovery | Runtime |
| 14 | `14-Source-Code-Leak-Detection.md` | Source leak | Persistent |
| 15 | `15-Git-Repository-Analysis.md` | Git analysis | Persistent |

### Human and Social Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 19 | `19-Social-Media-OSINT.md` | Social OSINT | Persistent |
| 20 | `20-Employee-Linked-Assets.md` | Employee assets | Persistent |
| 34 | `34-Physical-Location-Intelligence.md` | Physical recon | Persistent |

### Supply Chain and Partnerships
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 21 | `21-Third-Party-Integration-Discovery.md` | 3P integration | Persistent |
| 22 | `22-Web-Archive-Analysis.md` | Web archive | Persistent |
| 23 | `23-Pastebin-and-Leak-Searching.md` | Leak search | Persistent |
| 24 | `24-Code-Repository-Mining.md` | Code mining | Persistent |
| 35 | `35-Supply-Chain-Asset-Mapping.md` | Supply chain | Persistent |
| 36 | `36-Competitor-Analysis.md` | Competitor recon | Persistent |
| 37 | `37-Partner-Network-Discovery.md` | Partner recon | Persistent |
| 38 | `38-Acquisition-Target-Analysis.md` | Acquisition recon | Persistent |
| 39 | `39-Subsidiary-Asset-Mapping.md` | Subsidiary recon | Persistent |

### Container and IoT Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 25 | `25-Container-Registry-Enumeration.md` | Container recon | Persistent |
| 26 | `26-IoT-Device-Discovery.md` | IoT recon | Persistent |
| 27 | `27-Mobile-App-Analysis.md` | Mobile recon | Persistent |

### Advanced Protocol Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 28 | `28-API-Documentation-Extraction.md` | API docs | Runtime |
| 29 | `29-WebSocket-Endpoint-Discovery.md` | WebSocket recon | Runtime |
| 30 | `30-GraphQL-Introspection.md` | GraphQL recon | Runtime |
| 31 | `31-XML-RPC-and-SOAP-Discovery.md` | XML-RPC/SOAP | Runtime |

### Infrastructure Reconnaissance
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 40 | `40-Regional-Infrastructure-Mapping.md` | Regional infra | Persistent |
| 41 | `41-Content-Management-System-Detection.md` | CMS detection | Runtime |
| 42 | `42-Framework-and-Library-Identification.md` | Framework detection | Runtime |
| 43 | `43-Server-Configuration-Analysis.md` | Server config | Runtime |
| 44 | `44-SSL-TLS-Certificate-Analysis.md` | SSL/TLS analysis | Persistent |
| 45 | `45-HTTP-Header-Intelligence.md` | Header analysis | Runtime |
| 46 | `46-Cookie-Analysis-and-Session-Management.md` | Cookie analysis | Runtime |
| 47 | `47-Error-Page-Analysis.md` | Error analysis | Runtime |
| 48 | `48-Debug-Endpoint-Discovery.md` | Debug endpoint | Runtime |
| 49 | `49-Staging-Environment-Detection.md` | Staging detection | Runtime |

### Strategy
| # | File | Recon Category | State Type |
|---|------|---------------|-----------|
| 50 | `50-Advanced-Reconnaissance-Strategy.md` | Strategy | Persistent |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Asset Inventory)

```json
{
  "schema_version": "1.0.0",
  "domain": "reconnaissance-deep-dive",
  "session_id": "sess_recon_001",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "asset_inventory": {
    "total_assets": 1567,
    "by_type": {
      "subdomains": 345,
      "live_hosts": 189,
      "ip_addresses": 156,
      "api_endpoints": 234,
      "cloud_resources": 67,
      "email_addresses": 123,
      "employees": 45,
      "technology_components": 89,
      "certificates": 78,
      "dns_records": 243
    }
  },
  "subdomains": {
    "total_discovered": 345,
    "unique_ips": 89,
    "live_confirmed": 189,
    "by_depth": {
      "level_1": 45,
      "level_2": 156,
      "level_3": 100,
      "level_4_plus": 44
    }
  },
  "technology_stack": {
    "web_servers": ["nginx/1.18", "Apache/2.4.51"],
    "languages": ["PHP 8.1", "JavaScript (ES2022)"],
    "frameworks": ["Laravel 9", "React 18"],
    "databases": ["MySQL 8.0", "Redis 6.2"],
    "cdn": ["Cloudflare"],
    "analytics": ["Google Analytics"],
    "cms": ["WordPress 6.1"]
  },
  "api_endpoints": {
    "total_discovered": 234,
    "by_type": {
      "rest": 189,
      "graphql": 12,
      "websocket": 8,
      "soap": 5,
      "xmlrpc": 20
    },
    "authenticated": 156,
    "unauthenticated": 78
  },
  "cloud_resources": {
    "aws": {"s3_buckets": 12, "ec2_instances": 5, "lambda_functions": 23},
    "gcp": {"gcs_buckets": 3, "cloud_run": 8},
    "azure": {"blob_containers": 2, "functions": 5}
  },
  "employees": {
    "total_found": 45,
    "by_role": {
      "developers": 20,
      "devops": 8,
      "security": 3,
      "management": 5,
      "other": 9
    }
  }
}
```

### 3.2 MessagePack (Asset Stream)

```python
import msgpack

# Asset discovery event
asset_event = {
    "event": "asset_discovered",
    "asset_type": "subdomain",
    "value": "api.example.com",
    "source": "subfinder",
    "timestamp": time.time(),
    "metadata": {"ip": "1.2.3.4", "status": "live"}
}
packed = msgpack.packb(asset_event, use_bin_type=True)
```

### 3.3 Protobuf (Asset Archive Schema)

```protobuf
syntax = "proto3";
package recon;

message AssetInventory {
  string session_id = 1;
  int64 timestamp = 2;
  repeated Subdomain subdomains = 3;
  repeated TechnologyStack tech_stacks = 4;
  repeated APIEndpoint api_endpoints = 5;
  CloudResources cloud = 6;
  EmployeeInventory employees = 7;
  DNSInventory dns = 8;
  CertificateInventory certs = 9;
}

message Subdomain {
  string hostname = 1;
  repeated string ip_addresses = 2;
  bool is_live = 3;
  int32 depth = 4;
  string discovery_source = 5;
  int64 first_seen = 6;
  int64 last_verified = 7;
}

message TechnologyStack {
  string hostname = 1;
  repeated string web_servers = 2;
  repeated string languages = 3;
  repeated string frameworks = 4;
  repeated string databases = 5;
  repeated string cms = 6;
  map<string, string> metadata = 7;
}

message APIEndpoint {
  string url = 1;
  string method = 2;
  string api_type = 3;
  bool requires_auth = 4;
  repeated string parameters = 5;
  string discovered_from = 6;
}

message CloudResources {
  map<string, S3Resources> aws = 1;
  map<string, GCSResources> gcp = 2;
  map<string, AzureResources> azure = 3;
}

message S3Resources {
  repeated string buckets = 1;
  repeated string ec2_instances = 2;
  repeated string lambda_functions = 3;
}

message GCSResources {
  repeated string buckets = 1;
  repeated string cloud_run_services = 2;
}

message AzureResources {
  repeated string blob_containers = 1;
  repeated string function_apps = 2;
}

message EmployeeInventory {
  int32 total = 1;
  map<string, int32> by_role = 2;
  repeated EmployeeProfile profiles = 3;
}

message EmployeeProfile {
  string name = 1;
  string role = 2;
  string email = 3;
  repeated string social_profiles = 4;
  repeated string linked_assets = 5;
}

message DNSInventory {
  repeated DNSRecord records = 1;
  int32 total = 2;
}

message DNSRecord {
  string hostname = 1;
  string record_type = 2;
  string value = 3;
  int32 ttl = 4;
}

message CertificateInventory {
  repeated Certificate certs = 1;
  int32 total = 2;
}

message Certificate {
  string domain = 1;
  string issuer = 2;
  int64 not_before = 3;
  int64 not_after = 4;
  repeated string san = 5;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── recon-deep-dive/
        ├── {session_id}/
        │   ├── asset_inventory.json
        │   ├── subdomains.json
        │   ├── tech_stacks.json
        │   ├── api_endpoints.json
        │   ├── cloud_resources.json
        │   ├── employees.json
        │   ├── dns_records.json
        │   ├── certificates.json
        │   ├── recon_progress.json
        │   ├── checkpoints/
        │   │   ├── cp_001.msgpack
        │   │   └── cp_latest.msgpack
        │   └── raw_data/
        │       ├── subfinder_output.txt
        │       ├── nuclei_output.json
        │       └── ...
        └── shared/
            ├── global_asset_index.json
            ├── tech_fingerprint_db.json
            ├── cloud_resource_registry.json
            └── recon_strategy_state.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE subdomains (
    hostname TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    ip_addresses TEXT NOT NULL,
    is_live INTEGER NOT NULL DEFAULT 0,
    depth INTEGER NOT NULL,
    discovery_source TEXT NOT NULL,
    first_seen INTEGER NOT NULL,
    last_verified INTEGER,
    checksum TEXT NOT NULL
);

CREATE TABLE tech_stacks (
    hostname TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    web_servers TEXT,
    languages TEXT,
    frameworks TEXT,
    databases TEXT,
    cms TEXT,
    metadata TEXT,
    detected_at INTEGER NOT NULL
);

CREATE TABLE api_endpoints (
    endpoint_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    url TEXT NOT NULL,
    method TEXT NOT NULL,
    api_type TEXT NOT NULL,
    requires_auth INTEGER NOT NULL,
    parameters TEXT,
    discovered_from TEXT,
    discovered_at INTEGER NOT NULL
);

CREATE TABLE recon_progress (
    module TEXT NOT NULL,
    session_id TEXT NOT NULL,
    status TEXT NOT NULL,
    assets_discovered INTEGER DEFAULT 0,
    started_at INTEGER,
    completed_at INTEGER,
    PRIMARY KEY (module, session_id)
);

CREATE INDEX idx_subdomains_live ON subdomains(is_live);
CREATE INDEX idx_subdomains_depth ON subdomains(depth);
CREATE INDEX idx_api_type ON api_endpoints(api_type);
CREATE INDEX idx_api_auth ON api_endpoints(requires_auth);
CREATE INDEX idx_recon_status ON recon_progress(status);
```

### 4.3 Graph Database (Asset Relationships)

```json
{
  "nodes": [
    {"id": "example.com", "type": "domain"},
    {"id": "api.example.com", "type": "subdomain", "ip": "1.2.3.4"},
    {"id": "admin.example.com", "type": "subdomain", "ip": "1.2.3.5"},
    {"id": "1.2.3.4", "type": "ip_address"},
    {"id": "AWS-S3-bucket-001", "type": "cloud_resource"},
    {"id": "john.doe@example.com", "type": "employee"},
    {"id": "Laravel 9", "type": "technology"}
  ],
  "edges": [
    {"source": "example.com", "target": "api.example.com", "type": "subdomain_of"},
    {"source": "api.example.com", "target": "1.2.3.4", "type": "resolves_to"},
    {"source": "api.example.com", "target": "Laravel 9", "type": "uses_technology"},
    {"source": "john.doe@example.com", "target": "api.example.com", "type": "manages"},
    {"source": "example.com", "target": "AWS-S3-bucket-001", "type": "owns_cloud_resource"}
  ]
}
```

---

## 5. State Snapshot Schema

### 5.1 Recon Progress Snapshot

```json
{
  "snapshot_type": "recon_progress",
  "session_id": "sess_recon_001",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "modules": {
    "01-Subdomain-Enum": {"status": "completed", "assets": 345, "duration_min": 15},
    "04-Tech-Fingerprint": {"status": "completed", "assets": 89, "duration_min": 10},
    "06-API-Discovery": {"status": "in_progress", "assets": 178, "duration_min": 25},
    "11-Directory-Brute": {"status": "pending", "assets": 0}
  },
  "overall": {
    "modules_completed": 8,
    "modules_in_progress": 3,
    "modules_pending": 39,
    "total_assets": 1567,
    "elapsed_minutes": 120
  }
}
```

### 5.2 Asset Quality Snapshot

```json
{
  "snapshot_type": "asset_quality",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "quality_metrics": {
    "subdomain_live_rate": 0.548,
    "api_endpoint_coverage": 0.67,
    "tech_detection_rate": 0.89,
    "cloud_resource_completeness": 0.75,
    "employee_data_completeness": 0.45
  },
  "data_freshness": {
    "newest_asset": "2026-06-26T11:55:00.000Z",
    "oldest_unverified": "2026-06-20T00:00:00.000Z",
    "stale_subdomains": 23
  }
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Recon module started | recon_progress | MEDIUM |
| Recon module completed | recon_progress | HIGH |
| Asset batch discovered (>10) | asset_inventory | HIGH |
| Live host confirmed | subdomains | HIGH |
| Technology detected | tech_stacks | MEDIUM |
| API endpoint found | api_endpoints | HIGH |
| Cloud resource discovered | cloud_resources | HIGH |
| Employee profile found | employees | MEDIUM |
| Session end | All state | HIGH |
| 500 new assets | asset_inventory | HIGH |

---

## 7. Restore Operations

```python
def restore_recon_state(session_id):
    state = load_latest_snapshot(session_id, "recon_progress")
    inventory = load_json(f"state/recon-deep-dive/{session_id}/asset_inventory.json")
    
    # Rebuild from DB
    subdomains = query_db("SELECT * FROM subdomains WHERE session_id = ?", (session_id,))
    tech_stacks = query_db("SELECT * FROM tech_stacks WHERE session_id = ?", (session_id,))
    api_endpoints = query_db("SELECT * FROM api_endpoints WHERE session_id = ?", (session_id,))
    
    return ReconState(
        progress=state,
        inventory=inventory,
        subdomains=subdomains,
        tech_stacks=tech_stacks,
        api_endpoints=api_endpoints
    )

def restore_asset_graph(session_id):
    assets = query_db("SELECT * FROM subdomains WHERE session_id = ? AND is_live = 1", (session_id,))
    return build_asset_graph(assets)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Subdomains list | gzip | > 50KB |
| Tech stacks | None | N/A |
| API endpoints | None | N/A |
| Raw recon output | gzip | > 100KB |
| Checkpoint blobs | LZ4 | > 10KB |
| Asset graph | None | N/A |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Subdomain inventory | No |
| Tech stacks | No |
| API endpoints | No |
| Employee data | Optional (contains PII) |
| Cloud resources | No |
| DNS records | No |

---

## 10. Reconnaissance Deduplication

### 10.1 Asset Dedup

```python
class ReconDeduplication:
    def deduplicate_assets(self, new_assets, existing_inventory):
        unique = []
        for asset in new_assets:
            if not self.exists_in_inventory(asset, existing_inventory):
                unique.append(asset)
                self.add_to_inventory(asset, existing_inventory)
        return unique

    def exists_in_inventory(self, asset, inventory):
        if asset.type == "subdomain":
            return asset.hostname in inventory.subdomains
        elif asset.type == "api_endpoint":
            return self.api_endpoint_exists(asset, inventory.api_endpoints)
        return False
```

### 10.2 Cross-Session Dedup

```python
def cross_session_asset_dedup(session_id, previous_session_id=None):
    if not previous_session_id:
        return
    
    current = load_assets(session_id)
    previous = load_assets(previous_session_id)
    
    new_assets = [a for a in current if not asset_in_list(a, previous)]
    
    log_new_assets(session_id, new_assets)
    log_asset_delta(session_id, len(current), len(previous), len(new_assets))
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `assets_discovered_total` | Gauge | N/A (audit) |
| `subdomains_live_rate` | Gauge | < 30% |
| `recon_module_duration_avg_min` | Histogram | > 30min |
| `api_endpoints_found` | Gauge | N/A (audit) |
| `cloud_resources_found` | Gauge | N/A (audit) |
| `data_staleness_hours` | Gauge | > 168h (7 days) |
| `dedup_rate` | Gauge | < 5% (low novelty) |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `01-Advanced-Subdomain-Enumeration.md` → Subdomain enum state, enumeration sources
2. `02-Passive-OSINT-Collection.md` → OSINT state, collected intelligence
3. `03-Active-Asset-Discovery.md` → Active discovery state, probe results
4. `04-Technology-Stack-Fingerprinting.md` → Tech fingerprint state, detection results
5. `05-Cloud-Resource-Enumeration.md` → Cloud recon state, resource inventory
6. `06-API-Endpoint-Discovery.md` → API discovery state, endpoint catalog
7. `07-JavaScript-Source-Analysis.md` → JS analysis state, endpoint extraction
8. `08-Configuration-File-Extraction.md` → Config extraction state, file inventory
9. `09-Version-Detection-Techniques.md` → Version detection state, version map
10. `10-Content-Discovery-Automation.md` → Content discovery state, found paths
11. `11-Directory-Brute-Forcing.md` → Directory brute state, discovery progress
12. `12-File-Type-Detection.md` → File type state, type inventory
13. `13-Backup-File-Discovery.md` → Backup discovery state, found backups
14. `14-Source-Code-Leak-Detection.md` → Source leak state, leaked files
15. `15-Git-Repository-Analysis.md` → Git analysis state, commit history
16. `16-DNS-Enumeration-Advanced.md` → DNS enum state, record inventory
17. `17-Certificate-Transparency-Logs.md` → CT log state, certificate inventory
18. `18-Historical-Data-Analysis.md` → Historical data state, trend analysis
19. `19-Social-Media-OSINT.md` → Social OSINT state, profile inventory
20. `20-Employee-Linked-Assets.md` → Employee asset state, link inventory
21. `21-Third-Party-Integration-Discovery.md` → 3P integration state, service map
22. `22-Web-Archive-Analysis.md` → Web archive state, historical snapshots
23. `23-Pastebin-and-Leak-Searching.md` → Leak search state, found leaks
24. `24-Code-Repository-Mining.md` → Code mining state, repository inventory
25. `25-Container-Registry-Enumeration.md` → Container recon state, image inventory
26. `26-IoT-Device-Discovery.md` → IoT recon state, device inventory
27. `27-Mobile-App-Analysis.md` → Mobile recon state, app inventory
28. `28-API-Documentation-Extraction.md` → API docs state, documentation inventory
29. `29-WebSocket-Endpoint-Discovery.md` → WebSocket recon state, endpoint inventory
30. `30-GraphQL-Introspection.md` → GraphQL recon state, schema inventory
31. `31-XML-RPC-and-SOAP-Discovery.md` → XML-RPC/SOAP state, service inventory
32. `32-Email-Address-Harvesting.md` → Email harvest state, address inventory
33. `33-Phone-Number-Enumeration.md` → Phone enum state, number inventory
34. `34-Physical-Location-Intelligence.md` → Physical recon state, location data
35. `35-Supply-Chain-Asset-Mapping.md` → Supply chain state, partner map
36. `36-Competitor-Analysis.md` → Competitor recon state, competitor profiles
37. `37-Partner-Network-Discovery.md` → Partner recon state, partner map
38. `38-Acquisition-Target-Analysis.md` → Acquisition recon state, target profile
39. `39-Subsidiary-Asset-Mapping.md` → Subsidiary recon state, subsidiary map
40. `40-Regional-Infrastructure-Mapping.md` → Regional infra state, region map
41. `41-Content-Management-System-Detection.md` → CMS detection state, CMS map
42. `42-Framework-and-Library-Identification.md` → Framework detection state
43. `43-Server-Configuration-Analysis.md` → Server config state, config map
44. `44-SSL-TLS-Certificate-Analysis.md` → SSL/TLS state, cert inventory
45. `45-HTTP-Header-Intelligence.md` → Header analysis state, header map
46. `46-Cookie-Analysis-and-Session-Management.md` → Cookie analysis state
47. `47-Error-Page-Analysis.md` → Error analysis state, error map
48. `48-Debug-Endpoint-Discovery.md` → Debug endpoint state, debug inventory
49. `49-Staging-Environment-Detection.md` → Staging detection state, staging map
50. `50-Advanced-Reconnaissance-Strategy.md` → Strategy state, recon plan
