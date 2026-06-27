# State Persistence: Advanced Chaining Techniques Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Advanced Chaining Techniques |
| **Directory** | `Advanced-Chaining-Techniques/` |
| **File Count** | 49 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/advanced-chaining-techniques.md` |
| **Serialization** | JSON (primary), MessagePack (chain execution), Protobuf (cross-session) |
| **Storage Backend** | Filesystem + SQLite WAL + Graph DB |

---

## 1. Overview

This document defines the **state persistence architecture** for the Advanced Chaining Techniques domain. Vulnerability chaining is inherently stateful — each chain link depends on outputs from previous links, intermediate results feed into subsequent exploit stages, and chain success/failure must be tracked for pattern analysis.

The persistence layer captures the complete lifecycle of each chain: discovery of individual vulnerabilities, linking into attack chains, intermediate exploitation results, final impact assessment, and chain pattern storage for future reference.

---

## 2. Domain File Registry

All 49 domain files are tracked. Each maps to a specific chaining pattern:

### Web Application Chains
| # | File | Chain Category | State Complexity |
|---|------|---------------|-----------------|
| 01 | `01-Basic-Vulnerability-Chaining.md` | Foundation chains | LOW |
| 02 | `02-Information-Disclosure-to-RCE.md` | Info leak → RCE | HIGH |
| 03 | `03-XSS-to-Account-Takeover.md` | XSS → ATO | HIGH |
| 04 | `04-IDOR-to-Mass-Data-Extraction.md` | IDOR → Data theft | MEDIUM |
| 05 | `05-SQL-Injection-to-Shell-Access.md` | SQLi → OS shell | CRITICAL |
| 06 | `06-SSRF-to-Internal-Network-Compromise.md` | SSRF → Internal pivot | CRITICAL |
| 07 | `07-CORS-Misconfiguration-Chains.md` | CORS → Data exfil | MEDIUM |
| 08 | `08-CSRF-to-Privilege-Escalation.md` | CSRF → Privesc | HIGH |
| 09 | `09-File-Upload-to-Web-Shell.md` | Upload → RCE | CRITICAL |
| 10 | `10-XXE-to-Sensitive-Data-Access.md` | XXE → Data theft | HIGH |
| 11 | `11-Deserialization-to-RCE.md` | Deser → RCE | CRITICAL |
| 12 | `12-JWT-Manipulation-Chains.md` | JWT → Auth bypass | HIGH |
| 13 | `13-SSTI-to-Complete-Compromise.md` | SSTI → Full compromise | CRITICAL |
| 15 | `15-NoSQL-Injection-to-Data-Breach.md` | NoSQLi → Data breach | HIGH |

### Advanced Exploitation Chains
| # | File | Chain Category | State Complexity |
|---|------|---------------|-----------------|
| 16 | `16-GraphQL-Abuse-Chains.md` | GraphQL → Multi-vuln | MEDIUM |
| 17 | `17-WebSocket-Security-Chains.md` | WS → Session hijack | MEDIUM |
| 18 | `18-Prototype-Pollution-Exploitation.md` | Proto poll → RCE | HIGH |
| 19 | `19-HTTP-Request-Smuggling-Chains.md` | Smuggling → Cache poison | CRITICAL |
| 20 | `20-Host-Header-Injection-Chains.md` | Host header → Poison | MEDIUM |
| 21 | `21-DNS-Rebinding-Attacks.md` | DNS rebinding → Internal | HIGH |
| 22 | `22-Race-Condition-Exploitation.md` | Race → Double spend | HIGH |
| 23 | `23-Subdomain-Takeover-Chains.md` | Takeover → Cookie theft | HIGH |
| 24 | `24-Open-Redirect-to-Phishing.md` | Redirect → Phishing | MEDIUM |
| 25 | `25-Content-Spoofing-Chains.md` | Spoof → Phishing | MEDIUM |
| 26 | `26-WebCache-Poisoning-Chains.md` | Cache poison → XSS | HIGH |
| 27 | `27-Clickjacking-to-Account-Compromise.md` | Clickjack → ATO | MEDIUM |
| 28 | `28-Parameter-Pollution-Attacks.md` | Param pollution → Auth bypass | MEDIUM |
| 29 | `29-LDAP-Injection-Chains.md` | LDAP → Auth bypass | HIGH |
| 30 | `30-XPath-Injection-Exploitation.md` | XPath → Data theft | MEDIUM |

### Infrastructure and Advanced Chains
| # | File | Chain Category | State Complexity |
|---|------|---------------|-----------------|
| 31 | `31-Session-Puzzling-Techniques.md` | Session confusion → Privilege | MEDIUM |
| 32 | `32-Insecure-File-Handling-Chains.md` | File handling → RCE | HIGH |
| 33 | `33-Cross-Site-Script-Inclusion.md` | XSSI → Data exfil | MEDIUM |
| 34 | `34-HTTP-Response-Splitting.md` | Splitting → XSS | MEDIUM |
| 35 | `35-Client-Side-Storage-Abuse.md` | Storage → Session hijack | MEDIUM |
| 36 | `36-Cryptography-Weakness-Chains.md` | Crypto flaw → Full compromise | HIGH |
| 37 | `37-Third-Party-Component-Chains.md` | 3P vuln → Supply chain | HIGH |
| 38 | `38-Configuration-Misconfiguration-Chains.md` | Config → Full compromise | HIGH |
| 39 | `39-Network-Infrastructure-Chains.md` | Network → Lateral move | CRITICAL |
| 40 | `40-Mobile-API-Chains.md` | Mobile API → Data theft | MEDIUM |
| 41 | `41-Cloud-Misconfiguration-Chains.md` | Cloud misconfig → Full access | CRITICAL |
| 42 | `42-Container-Escape-Chains.md` | Container escape → Host | CRITICAL |
| 43 | `43-Kubernetes-Attack-Chains.md` | K8s → Cluster compromise | CRITICAL |
| 44 | `44-Blockchain-Exploit-Chains.md` | Blockchain → Fund theft | HIGH |
| 45 | `45-IoT-Device-Compromise-Chains.md` → IoT → Network pivot | HIGH |
| 46 | `46-Supply-Chain-Attack-Chains.md` | Supply chain → Mass compromise | CRITICAL |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | 0day chains → Unknown impact | CRITICAL |
| 48 | `48-Multi-Platform-Attack-Chains.md` | Cross-platform → Full scope | CRITICAL |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | APT chains → Long-term access | CRITICAL |
| 50 | `50-Master-Chaining-Framework.md` | Meta-framework → All chains | CRITICAL |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Chain Definition)

```json
{
  "schema_version": "1.3.0",
  "domain": "advanced-chaining-techniques",
  "session_id": "sess_c1d2e3f4g5h6",
  "chain": {
    "chain_id": "chain_001",
    "chain_type": "xss_to_ato",
    "source_file": "03-XSS-to-Account-Takeover.md",
    "status": "in_progress",
    "created_at": "2026-06-26T10:00:00.000Z",
    "updated_at": "2026-06-26T10:15:00.000Z",
    "links": [
      {
        "link_id": "link_001",
        "position": 1,
        "vuln_class": "stored_xss",
        "status": "confirmed",
        "target": "https://example.com/profile",
        "parameter": "bio",
        "evidence": {
          "payload": "<script>...</script>",
          "response_snippet": "...",
          "screenshot_ref": "snap_001.png"
        },
        "output_for_next": {
          "stolen_cookie_name": "session_token",
          "exfil_endpoint": "https://attacker.com/capture"
        }
      },
      {
        "link_id": "link_002",
        "position": 2,
        "vuln_class": "session_hijack",
        "status": "confirmed",
        "depends_on": ["link_001"],
        "evidence": {
          "captured_token": "redacted",
          "account_accessed": "victim@example.com"
        }
      }
    ],
    "final_impact": {
      "severity": "CRITICAL",
      "impact_type": "account_takeover",
      "affected_users": 1
    }
  },
  "intermediate_state": {
    "pending_links": [],
    "failed_links": [],
    "active_exfil": null
  }
}
```

### 3.2 MessagePack (Chain Execution Stream)

Used for high-frequency chain execution where link states change rapidly:

```python
import msgpack

# Chain execution event
event = {
    "event_type": "link_result",
    "chain_id": "chain_001",
    "link_id": "link_001",
    "timestamp": time.time(),
    "success": True,
    "output": {"captured_data": "..."},
    "duration_ms": 2340
}
packed = msgpack.packb(event, use_bin_type=True)
```

### 3.3 Protobuf (Cross-Session Chain Archive)

```protobuf
syntax = "proto3";
package chaining;

message AttackChain {
  string chain_id = 1;
  string chain_type = 2;
  string source_file = 3;
  ChainStatus status = 4;
  int64 created_at = 5;
  int64 updated_at = 6;
  repeated ChainLink links = 7;
  FinalImpact final_impact = 8;
  IntermediateState intermediate = 9;
}

enum ChainStatus {
  DISCOVERED = 0;
  IN_PROGRESS = 1;
  CONFIRMED = 2;
  FAILED = 3;
  ARCHIVED = 4;
}

message ChainLink {
  string link_id = 1;
  int32 position = 2;
  string vuln_class = 3;
  LinkStatus status = 4;
  string target = 5;
  string parameter = 6;
  map<string, string> evidence = 7;
  map<string, string> output_for_next = 8;
  repeated string depends_on = 9;
}

enum LinkStatus {
  PENDING = 0;
  TESTING = 1;
  CONFIRMED = 2;
  FAILED = 3;
  SKIPPED = 4;
}

message FinalImpact {
  string severity = 1;
  string impact_type = 2;
  int32 affected_users = 3;
  string description = 4;
}

message IntermediateState {
  repeated string pending_links = 1;
  repeated string failed_links = 2;
  string active_exfil = 3;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── advanced-chaining/
        ├── {session_id}/
        │   ├── chains/
        │   │   ├── chain_001.json
        │   │   ├── chain_002.json
        │   │   └── ...
        │   ├── execution/
        │   │   ├── exec_001.msgpack
        │   │   └── exec_002.msgpack
        │   ├── checkpoints/
        │   │   ├── cp_chain_001_001.json
        │   │   └── cp_latest.json
        │   └── evidence/
        │       ├── snap_001.png
        │       └── HAR_001.har
        └── shared/
            ├── chain_patterns.json     # Successful chain patterns
            ├── vuln_graph.json         # Vulnerability relationship graph
            └── link_dependencies.json  # Cross-chain dependency map
```

### 4.2 SQLite WAL

```sql
CREATE TABLE chains (
    chain_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    chain_type TEXT NOT NULL,
    source_file TEXT NOT NULL,
    status TEXT NOT NULL,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    link_count INTEGER NOT NULL,
    final_severity TEXT,
    chain_blob BLOB NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE chain_links (
    link_id TEXT PRIMARY KEY,
    chain_id TEXT NOT NULL,
    position INTEGER NOT NULL,
    vuln_class TEXT NOT NULL,
    status TEXT NOT NULL,
    target TEXT,
    depends_on TEXT,
    evidence_blob BLOB,
    FOREIGN KEY (chain_id) REFERENCES chains(chain_id)
);

CREATE TABLE chain_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    chain_id TEXT NOT NULL,
    link_id TEXT,
    event_type TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    payload BLOB NOT NULL,
    FOREIGN KEY (chain_id) REFERENCES chains(chain_id)
);

CREATE INDEX idx_chains_type ON chains(chain_type);
CREATE INDEX idx_chains_status ON chains(status);
CREATE INDEX idx_links_chain ON chain_links(chain_id);
CREATE INDEX idx_events_chain ON chain_events(chain_id);
```

### 4.3 Graph Database (Chain Relationships)

```json
{
  "nodes": [
    {"id": "chain_001", "type": "chain", "status": "confirmed"},
    {"id": "link_001", "type": "vuln", "vuln_class": "xss"},
    {"id": "link_002", "type": "vuln", "vuln_class": "session_hijack"},
    {"id": "target_a", "type": "asset", "domain": "example.com"}
  ],
  "edges": [
    {"source": "chain_001", "target": "link_001", "type": "contains"},
    {"source": "chain_001", "target": "link_002", "type": "contains"},
    {"source": "link_001", "target": "link_002", "type": "leads_to"},
    {"source": "link_001", "target": "target_a", "type": "targets"},
    {"source": "link_002", "target": "target_a", "type": "targets"}
  ]
}
```

---

## 5. State Snapshot Schema

### 5.1 Chain Discovery Snapshot

```json
{
  "snapshot_type": "chain_discovery",
  "session_id": "sess_c1d2e3f4g5h6",
  "timestamp": "2026-06-26T10:00:00.000Z",
  "discovered_chains": [
    {
      "chain_id": "chain_001",
      "chain_type": "xss_to_ato",
      "source_file": "03-XSS-to-Account-Takeover.md",
      "candidate_links": ["link_001", "link_002"],
      "confidence": 0.85,
      "priority": "HIGH"
    }
  ],
  "vulnerability_inventory": {
    "total_vulns": 23,
    "chained_vulns": 5,
    "standalone_vulns": 18
  }
}
```

### 5.2 Chain Execution Snapshot

```json
{
  "snapshot_type": "chain_execution",
  "session_id": "sess_c1d2e3f4g5h6",
  "timestamp": "2026-06-26T10:15:00.000Z",
  "active_chains": {
    "chain_001": {
      "current_link": "link_002",
      "links_completed": 1,
      "links_total": 2,
      "progress_percent": 50.0
    }
  },
  "completed_chains": [],
  "failed_chains": [],
  "resource_usage": {
    "concurrent_chains": 1,
    "memory_mb": 128,
    "network_connections": 3
  }
}
```

### 5.3 Chain Pattern Snapshot (Archived)

```json
{
  "snapshot_type": "chain_pattern",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "patterns": [
    {
      "pattern_id": "pat_xss_session_cookie",
      "pattern_type": "xss_to_session_hijack",
      "success_rate": 0.73,
      "average_links": 2.4,
      "example_chains": ["chain_001", "chain_015", "chain_042"],
      "common_preconditions": [
        "stored_xss_on_authenticated_page",
        "no_http_only_cookie_flag",
        "session_token_in_cookie"
      ],
      "discovery_count": 47,
      "last_used": "2026-06-26T10:15:00.000Z"
    }
  ]
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Chain pattern discovered | chain_discovery | HIGH |
| Link added to chain | chain_execution | HIGH |
| Link result confirmed/failed | chain_execution | CRITICAL |
| Chain completed successfully | chain_pattern | CRITICAL |
| Chain failed at link N | chain_execution | HIGH |
| Intermediate result captured | chain_execution | MEDIUM |
| Evidence captured (screenshot/HAR) | chain_execution | MEDIUM |
| New vuln discovered that could extend chain | chain_discovery | MEDIUM |
| Session end | All active chains | CRITICAL |
| Memory threshold exceeded | chain_execution | HIGH |

### 6.1 Trigger Implementation

```python
class ChainPersistenceManager:
    def on_link_result(self, chain_id, link_id, success, evidence):
        self.save_link_state(chain_id, link_id, success, evidence)
        self.update_chain_progress(chain_id)
        
        if success:
            self.check_chain_completion(chain_id)
        else:
            self.log_chain_failure(chain_id, link_id)
            self.save_chain_for_retry(chain_id)

    def on_chain_completed(self, chain_id):
        chain = self.load_chain(chain_id)
        pattern = self.extract_pattern(chain)
        self.save_chain_pattern(pattern)
        self.update_pattern_statistics(pattern)

    def on_intermediate_result(self, chain_id, link_id, result):
        self.save_intermediate(chain_id, link_id, result)
        self.update_chain_state(chain_id, {"last_intermediate": result})
```

---

## 7. Restore Operations

### 7.1 Chain State Restore

```python
def restore_chain_state(session_id, chain_id=None):
    if chain_id:
        return load_chain(session_id, chain_id)
    
    all_chains = load_all_chains(session_id)
    return ChainState(
        active=[c for c in all_chains if c.status == "in_progress"],
        completed=[c for c in all_chains if c.status == "confirmed"],
        failed=[c for c in all_chains if c.status == "failed"]
    )
```

### 7.2 Chain Pattern Restore

```python
def restore_chain_patterns(session_id=None):
    if session_id:
        return load_session_patterns(session_id)
    return load_global_patterns()
```

### 7.3 Dependency Graph Restore

```python
def restore_dependency_graph(session_id):
    chains = load_all_chains(session_id)
    graph = DependencyGraph()
    
    for chain in chains:
        graph.add_chain(chain)
        for link in chain.links:
            graph.add_link(link)
            for dep in link.depends_on:
                graph.add_dependency(link.link_id, dep)
    
    return graph
```

### 7.4 Crash Recovery

```python
def chain_crash_recovery(session_id):
    last_snapshot = find_latest_chain_snapshot(session_id)
    state = restore_chain_state_from(last_snapshot)
    
    # Find chains that were in_progress at crash
    interrupted = [c for c in state.active if c.needs_resume()]
    
    for chain in interrupted:
        # Find last successful link
        last_success = chain.last_confirmed_link()
        chain.resume_from = last_success
        chain.status = "pending_resume"
    
    return state
```

---

## 8. Compression

| Data Type | Algorithm | Threshold | Rationale |
|-----------|-----------|-----------|-----------|
| Chain definitions | zlib | > 5KB | Multi-link chains are verbose |
| Execution streams | LZ4 | > 20KB | High throughput, fast decompression needed |
| Evidence blobs | zstd | > 50KB | Screenshots, HAR files are large |
| Pattern archives | zlib | > 10KB | Long-term storage, size matters |
| Dependency graph | None | N/A | Small, fast lookup needed |

---

## 9. Encryption

| Data Classification | Required | Algorithm |
|--------------------|----------|-----------|
| Chain exploit details | Optional | AES-256-GCM |
| Captured credentials/tokens | Required | AES-256-GCM |
| Evidence files | Optional | AES-256-GCM |
| Chain patterns | No | None |
| Session state | Optional | AES-256-GCM |

---

## 10. Cross-Chain Correlation

### 10.1 Shared State Between Chains

Chains often share vulnerabilities. The persistence layer tracks these relationships:

```json
{
  "shared_vulnerabilities": {
    "vuln_xss_profile": {
      "chains": ["chain_001", "chain_003", "chain_007"],
      "total_chains_using": 3,
      "best_chain": "chain_001",
      "best_chain_impact": "CRITICAL"
    }
  },
  "chain_dependencies": {
    "chain_003": {
      "depends_on_chains": ["chain_001"],
      "reason": "chain_001 confirmed xss on profile endpoint"
    }
  }
}
```

---

## 11. Performance Considerations

### 11.1 Write Performance

| Operation | Max Latency | Notes |
|-----------|------------|-------|
| Link state update | 30ms | Hot path during chain execution |
| Chain completion | 100ms | Includes pattern extraction |
| Evidence capture | 200ms | May include large files |
| Pattern update | 150ms | Statistical recalculation |

### 11.2 Read Performance

| Operation | Max Latency | Cache |
|-----------|------------|-------|
| Chain status query | 10ms | In-memory |
| Pattern lookup | 20ms | LRU cache |
| Dependency graph traversal | 50ms | Pre-computed |
| Full session restore | 1000ms | Snapshot + deltas |

---

## 12. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `chain_completion_rate` | Gauge | < 10% |
| `chain_execution_duration_ms` | Histogram | p99 > 30000 |
| `chain_link_failure_rate` | Gauge | > 50% |
| `pattern_discovery_rate` | Counter | N/A (audit) |
| `active_chains_count` | Gauge | > 10 |
| `persistence_write_latency_ms` | Histogram | p99 > 200ms |
| `evidence_capture_latency_ms` | Histogram | p99 > 1000ms |

---

## Appendix A: Complete File Reference

All 49 domain files and their state persistence mapping:

1. `01-Basic-Vulnerability-Chaining.md` → Foundation chain template, 2-link state
2. `02-Information-Disclosure-to-RCE.md` → Info leak chain state, severity escalation map
3. `03-XSS-to-Account-Takeover.md` → XSS → cookie theft chain, exfil state
4. `04-IDOR-to-Mass-Data-Extraction.md` → IDOR enumeration state, data volume tracker
5. `05-SQL-Injection-to-Shell-Access.md` → SQLi → OS shell chain, database state
6. `06-SSRF-to-Internal-Network-Compromise.md` → SSRF pivot chain, internal map
7. `07-CORS-Misconfiguration-Chains.md` → CORS abuse chain, origin validation state
8. `08-CSRF-to-Privilege-Escalation.md` → CSRF → privesc chain, token state
9. `09-File-Upload-to-Web-Shell.md` → Upload → RCE chain, file system state
10. `10-XXE-to-Sensitive-Data-Access.md` → XXE data extraction chain, parser state
11. `11-Deserialization-to-RCE.md` → Deser → RCE chain, gadget chain state
12. `12-JWT-Manipulation-Chains.md` → JWT abuse chain, algorithm state
13. `13-SSTI-to-Complete-Compromise.md` → SSTI → full compromise chain, template state
14. `15-NoSQL-Injection-to-Data-Breach.md` → NoSQLi chain, document extraction state
15. `16-GraphQL-Abuse-Chains.md` → GraphQL chain, schema abuse state
16. `17-WebSocket-Security-Chains.md` → WS chain, session hijack state
17. `18-Prototype-Pollution-Exploitation.md` → Proto poll chain, sink tracking state
18. `19-HTTP-Request-Smuggling-Chains.md` → Smuggling chain, cache state
19. `20-Host-Header-Injection-Chains.md` → Host header chain, routing state
20. `21-DNS-Rebinding-Attacks.md` → DNS rebinding chain, DNS state
21. `22-Race-Condition-Exploitation.md` → Race chain, timing state
22. `23-Subdomain-Takeover-Chains.md` → Takeover chain, CNAME state
23. `24-Open-Redirect-to-Phishing.md` → Redirect chain, URL state
24. `25-Content-Spoofing-Chains.md` → Spoof chain, template state
25. `26-WebCache-Poisoning-Chains.md` → Cache poison chain, header state
26. `27-Clickjacking-to-Account-Compromise.md` → Clickjack chain, frame state
27. `28-Parameter-Pollution-Attacks.md` → Param pollution chain, param state
28. `29-LDAP-Injection-Chains.md` → LDAP chain, query state
29. `30-XPath-Injection-Exploitation.md` → XPath chain, query state
30. `31-Session-Puzzling-Techniques.md` → Session puzzling chain, session state
31. `32-Insecure-File-Handling-Chains.md` → File handling chain, path state
32. `33-Cross-Site-Script-Inclusion.md` → XSSI chain, script src state
33. `34-HTTP-Response-Splitting.md` → Response splitting chain, header state
34. `35-Client-Side-Storage-Abuse.md` → Storage abuse chain, storage state
35. `36-Cryptography-Weakness-Chains.md` → Crypto chain, key state
36. `37-Third-Party-Component-Chains.md` → 3P chain, dependency state
37. `38-Configuration-Misconfiguration-Chains.md` → Config chain, config state
38. `39-Network-Infrastructure-Chains.md` → Network chain, topology state
39. `40-Mobile-API-Chains.md` → Mobile API chain, token state
40. `41-Cloud-Misconfiguration-Chains.md` → Cloud chain, IAM state
41. `42-Container-Escape-Chains.md` → Container chain, namespace state
42. `43-Kubernetes-Attack-Chains.md` → K8s chain, RBAC state
43. `44-Blockchain-Exploit-Chains.md` → Blockchain chain, contract state
44. `45-IoT-Device-Compromise-Chains.md` → IoT chain, firmware state
45. `46-Supply-Chain-Attack-Chains.md` → Supply chain, package state
46. `47-Zero-Day-Chaining-Strategies.md` → 0day chain, unknown state
47. `48-Multi-Platform-Attack-Chains.md` → Cross-platform chain, platform state
48. `49-Advanced-Persistent-Threat-Chains.md` → APT chain, persistence state
49. `50-Master-Chaining-Framework.md` → Master framework state, all chain registry
50. `README.md` → Documentation
51. `registry.json` → File index
