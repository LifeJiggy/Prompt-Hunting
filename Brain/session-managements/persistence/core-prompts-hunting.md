# State Persistence: Core Prompts Hunting Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Core Prompts Hunting |
| **Directory** | `Core-Prompts-hunting/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/core-prompts-hunting.md` |
| **Serialization** | JSON (primary), MessagePack (finding stream), Protobuf (finding archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Core Prompts Hunting domain. This domain contains 50 specialized hunting prompt modules covering every major web vulnerability class. The persistence layer captures active findings, test state for each vulnerability class, test payloads and their outcomes, and the progression of each hunt session.

Each hunting module generates ephemeral state during testing — payloads sent, responses analyzed, reflections found, and vulnerabilities confirmed. This state must survive interruptions, support incremental progress, and feed into the reporting pipeline.

---

## 2. Domain File Registry

All 50 domain files organized by vulnerability class:

### Reconnaissance and Discovery
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery.md` | Recon/Asset | MEDIUM |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation.md` | JS Analysis | MEDIUM |
| 03 | `3-API-Endpoint-Analysis.md` | API Analysis | HIGH |

### Authentication and Session
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 04 | `4-Authentication-and-Session-Management.md` | Auth Bypass | HIGH |
| 05 | `5-Authorization-and-Access-Control.md` | Authorization | HIGH |

### Input and Logic
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 06 | `6-Input-Validation-and-Sanitization.md` | Input Validation | MEDIUM |
| 07 | `7-Business-Logic-Flaws.md` | Business Logic | HIGH |
| 08 | `8-Client-Side-Storage-Security.md` | Client Storage | LOW |
| 09 | `9-Cryptography-and-Data-Protection.md` | Crypto | MEDIUM |

### Error and Data Handling
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 10 | `10-Error-Handling-and-Information-Disclosure.md` | Info Disclosure | MEDIUM |
| 11 | `11-File-Upload-and-Processing.md` | File Upload | HIGH |

### Server-Side Vulnerabilities
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 12 | `12-Server-Side-Request-Forgery-SSRF.md` | SSRF | HIGH |
| 13 | `13-Cross-Site-Request-Forgery-CSRF.md` | CSRF | MEDIUM |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS.md` | CORS | LOW |
| 15 | `15-Race-Conditions-and-Concurrency-Issues.md` | Race | HIGH |
| 16 | `16-Third-Party-Component-Analysis.md` | 3P Components | MEDIUM |
| 17 | `17-Configuration-and-Misconfiguration-Hunting.md` | Misconfig | MEDIUM |
| 18 | `18-Network-and-Infrastructure-Security.md` | Network | MEDIUM |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API | HIGH |
| 20 | `20-Reporting-and-Proof-of-Concept-Development.md` | Reporting | MEDIUM |

### Advanced Vulnerabilities
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 21 | `21-Web-Application-Firewall-WAF-Bypass.md` | WAF Bypass | HIGH |
| 22 | `22-HTTP-Request-Smuggling.md` | HTTP Smuggling | CRITICAL |
| 23 | `23-Subdomain-Takeover.md` | Subdomain Takeover | MEDIUM |
| 24 | `24-Host-Header-Injection.md` | Host Header | LOW |
| 25 | `25-XML-External-Entity-XXE-Injection.md` | XXE | HIGH |
| 26 | `26-Insecure-Deserialization.md` | Deserialization | CRITICAL |
| 27 | `27-Command-Injection.md` | Command Injection | CRITICAL |
| 28 | `28-NoSQL-Injection.md` | NoSQL Injection | HIGH |
| 29 | `29-GraphQL-Vulnerabilities.md` | GraphQL | MEDIUM |
| 30 | `30-WebSocket-Security.md` | WebSocket | MEDIUM |
| 31 | `31-Server-Side-Template-Injection.md` | SSTI | CRITICAL |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities.md` | JWT | HIGH |
| 33 | `33-Content-Security-Policy-CSP-Bypass.md` | CSP Bypass | MEDIUM |
| 34 | `34-Clickjacking-and-UI-Redressing.md` | Clickjacking | LOW |
| 35 | `35-HTTP-Parameter-Pollution.md` | HPP | LOW |
| 36 | `36-LDAP-Injection.md` | LDAP Injection | HIGH |
| 37 | `37-Session-Puzzling-and-Fixation.md` | Session | HIGH |

### Additional Vulnerability Classes
| # | File | Vuln Class | State Complexity |
|---|------|-----------|-----------------|
| 38 | `38-Insecure-File-Handling.md` | File Handling | MEDIUM |
| 39 | `39-Cross-Site-Script-Inclusion-XSSI.md` | XSSI | LOW |
| 40 | `40-Prototype-Pollution.md` | Prototype Pollution | HIGH |
| 41 | `41-HTTP-Response-Splitting.md` | Response Splitting | LOW |
| 42 | `42-XPath-Injection.md` | XPath Injection | MEDIUM |
| 43 | `43-Cross-Site-Request-Forgery-CSRF.md` | CSRF (Extended) | MEDIUM |
| 44 | `44-Cross-Origin-Resource-Sharing-CORS.md` | CORS (Extended) | LOW |
| 45 | `45-Race-Conditions-and-Concurrency-Issues.md` | Race (Extended) | HIGH |
| 46 | `46-Third-Party-Component-Analysis.md` | 3P (Extended) | MEDIUM |
| 47 | `47-Configuration-and-Misconfiguration-Hunting.md` | Misconfig (Extended) | MEDIUM |
| 48 | `48-Network-and-Infrastructure-Security.md` | Network (Extended) | MEDIUM |
| 49 | `49-Mobile-and-API-Specific-Vulnerabilities.md` | Mobile/API (Extended) | HIGH |
| 50 | `50-Reporting-and-Proof-of-Concept-Development.md` | Reporting (Extended) | MEDIUM |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Finding State)

```json
{
  "schema_version": "1.0.0",
  "domain": "core-prompts-hunting",
  "session_id": "sess_h1h2i3j4k5l6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "hunt_state": {
    "hunt_id": "hunt_001",
    "target": "https://example.com",
    "started_at": "2026-06-26T09:00:00.000Z",
    "modules_active": 8,
    "modules_completed": 3,
    "modules_pending": 42
  },
  "findings": [
    {
      "finding_id": "f_001",
      "module_source": "13-XSS-Detection",
      "vuln_class": "stored_xss",
      "severity": "HIGH",
      "title": "Stored XSS in user profile bio field",
      "target_url": "https://example.com/profile/edit",
      "parameter": "bio",
      "evidence": {
        "payload": "<img src=x onerror=alert(1)>",
        "response_contains_payload": true,
        "execution_confirmed": true,
        "context": "HTML body, inside div.bio-content"
      },
      "discovered_at": "2026-06-26T10:30:00.000Z",
      "status": "confirmed",
      "poc_development": {
        "poc_ready": false,
        "poc_steps": ["1. Login as user A", "2. Set bio to payload", "3. User B visits profile"]
      }
    }
  ],
  "test_state": {
    "by_module": {
      "01-Recon": {"status": "completed", "tests_run": 12, "tests_passed": 12},
      "13-XSS": {"status": "in_progress", "tests_run": 45, "findings": 1},
      "12-SSRF": {"status": "pending", "tests_run": 0, "findings": 0}
    },
    "payloads_sent": 234,
    "unique_endpoints_tested": 67,
    "coverage_percent": 23.5
  },
  "test_inventory": {
    "endpoints_discovered": 156,
    "endpoints_tested": 67,
    "parameters_discovered": 234,
    "parameters_tested": 89
  }
}
```

### 3.2 MessagePack (Finding Stream)

```python
import msgpack

# Real-time finding event
finding_event = {
    "event": "finding_discovered",
    "finding_id": "f_002",
    "module": "12-SSRF",
    "severity": "CRITICAL",
    "vuln_class": "ssrf",
    "target": "https://example.com/api/fetch",
    "parameter": "url",
    "timestamp": time.time(),
    "evidence_summary": "Internal metadata endpoint reachable"
}
packed = msgpack.packb(finding_event, use_bin_type=True)
```

### 3.3 Protobuf (Finding Archive Schema)

```protobuf
syntax = "proto3";
package hunting;

message HuntState {
  string session_id = 1;
  string hunt_id = 2;
  string target = 3;
  int64 started_at = 4;
  repeated Finding findings = 5;
  TestInventory inventory = 6;
  ModuleTestState module_state = 7;
}

message Finding {
  string finding_id = 1;
  string module_source = 2;
  string vuln_class = 3;
  string severity = 4;
  string title = 5;
  string target_url = 6;
  string parameter = 7;
  map<string, string> evidence = 8;
  int64 discovered_at = 9;
  FindingStatus status = 10;
  PoCState poc = 11;
}

enum FindingStatus {
  DISCOVERED = 0;
  CONFIRMED = 1;
  REPORTING = 2;
  SUBMITTED = 3;
  FALSE_POSITIVE = 4;
  DUPLICATE = 5;
  OUT_OF_SCOPE = 6;
}

message PoCState {
  bool poc_ready = 1;
  repeated string steps = 2;
  string poc_url = 3;
  string screenshot_ref = 4;
}

message TestInventory {
  int32 endpoints_discovered = 1;
  int32 endpoints_tested = 2;
  int32 parameters_discovered = 3;
  int32 parameters_tested = 4;
  double coverage_percent = 5;
}

message ModuleTestState {
  map<string, ModuleStatus> by_module = 1;
  int32 payloads_sent = 2;
}

message ModuleStatus {
  string status = 1;
  int32 tests_run = 2;
  int32 findings_count = 3;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── core-prompts-hunting/
        ├── {session_id}/
        │   ├── hunt_state.json
        │   ├── findings/
        │   │   ├── f_001.json
        │   │   ├── f_002.json
        │   │   └── ...
        │   ├── test_state.json
        │   ├── payloads/
        │   │   ├── xss_payloads.json
        │   │   ├── sqli_payloads.json
        │   │   └── ...
        │   ├── evidence/
        │   │   ├── screenshots/
        │   │   └── responses/
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_findings_index.json
            ├── payload_library.json
            ├── endpoint_inventory.json
            └── vuln_class_progress.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE findings (
    finding_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    module_source TEXT NOT NULL,
    vuln_class TEXT NOT NULL,
    severity TEXT NOT NULL,
    title TEXT NOT NULL,
    target_url TEXT NOT NULL,
    parameter TEXT,
    evidence_blob BLOB NOT NULL,
    discovered_at INTEGER NOT NULL,
    status TEXT NOT NULL,
    poc_state BLOB,
    checksum TEXT NOT NULL
);

CREATE TABLE test_results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    module TEXT NOT NULL,
    target_url TEXT NOT NULL,
    parameter TEXT,
    payload TEXT,
    vuln_class TEXT,
    confirmed INTEGER DEFAULT 0,
    response_code INTEGER,
    response_time_ms INTEGER,
    tested_at INTEGER NOT NULL
);

CREATE TABLE test_inventory (
    inventory_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    endpoint_url TEXT NOT NULL,
    discovered_at INTEGER NOT NULL,
    tested INTEGER DEFAULT 0,
    vulnerability_found INTEGER DEFAULT 0
);

CREATE INDEX idx_findings_session ON findings(session_id);
CREATE INDEX idx_findings_severity ON findings(severity);
CREATE INDEX idx_findings_vuln ON findings(vuln_class);
CREATE INDEX idx_test_results_module ON test_results(module);
CREATE INDEX idx_test_results_target ON test_results(target_url);
```

---

## 5. State Snapshot Schema

### 5.1 Finding Snapshot

```json
{
  "snapshot_type": "findings",
  "session_id": "sess_h1h2i3j4k5l6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "summary": {
    "total_findings": 5,
    "by_severity": {
      "CRITICAL": 1,
      "HIGH": 2,
      "MEDIUM": 2,
      "LOW": 0
    },
    "by_status": {
      "confirmed": 4,
      "discovered": 1
    },
    "by_vuln_class": {
      "xss": 2,
      "ssrf": 1,
      "idor": 1,
      "sqli": 1
    }
  },
  "findings_list": [
    {
      "finding_id": "f_001",
      "title": "Stored XSS in profile bio",
      "severity": "HIGH",
      "vuln_class": "xss",
      "status": "confirmed"
    }
  ]
}
```

### 5.2 Test Coverage Snapshot

```json
{
  "snapshot_type": "test_coverage",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "coverage": {
    "overall_percent": 23.5,
    "by_module": {
      "recon": {"percent": 100.0, "endpoints": 156},
      "xss": {"percent": 45.0, "endpoints": 30},
      "sqli": {"percent": 30.0, "endpoints": 20},
      "ssrf": {"percent": 15.0, "endpoints": 10},
      "idor": {"percent": 10.0, "endpoints": 7},
      "csrf": {"percent": 0.0, "endpoints": 0}
    },
    "untested_endpoints": [
      "https://example.com/api/admin/*",
      "https://example.com/api/v2/*"
    ]
  }
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Finding discovered | findings | CRITICAL |
| Finding status changed | findings | HIGH |
| Module test started | test_coverage | MEDIUM |
| Module test completed | test_coverage | HIGH |
| Payload tested (batch) | test_results | LOW |
| PoC developed | findings | HIGH |
| New endpoint discovered | test_inventory | MEDIUM |
| Session end | All state | HIGH |
| 50 payloads tested | test_results | LOW |

---

## 7. Restore Operations

### 7.1 Finding Restore

```python
def restore_findings(session_id):
    findings = query_db(
        "SELECT * FROM findings WHERE session_id = ? ORDER BY discovered_at",
        (session_id,)
    )
    for f in findings:
        f["evidence"] = deserialize(f["evidence_blob"])
        f["poc_state"] = deserialize(f.get("poc_state"))
    return findings
```

### 7.2 Test State Restore

```python
def restore_test_state(session_id):
    test_state = load_latest_snapshot(session_id, "test_state")
    
    # Rebuild from DB
    results = query_db(
        "SELECT module, COUNT(*) as tests, SUM(confirmed) as findings "
        "FROM test_results WHERE session_id = ? GROUP BY module",
        (session_id,)
    )
    
    for r in results:
        test_state["by_module"][r["module"]]["tests_run"] = r["tests"]
        test_state["by_module"][r["module"]]["findings"] = r["findings"]
    
    return test_state
```

### 7.3 Crash Recovery

```python
def hunting_crash_recovery(session_id):
    last_snapshot = find_latest_snapshot(session_id, "hunt_state")
    state = restore_hunt_state_from(last_snapshot)
    
    # Find incomplete modules
    incomplete = [
        m for m, s in state["test_state"]["by_module"].items()
        if s["status"] == "in_progress"
    ]
    
    # Find unconfirmed findings
    unconfirmed = [
        f for f in state["findings"]
        if f["status"] == "discovered"
    ]
    
    state["recovery"] = {
        "incomplete_modules": incomplete,
        "unconfirmed_findings": unconfirmed
    }
    
    return state
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Finding JSON | None | N/A |
| Test results batch | LZ4 | > 50KB |
| Response evidence | gzip | > 100KB |
| Screenshots | None | Already compressed (PNG/JPG) |
| Checkpoint blobs | LZ4 | > 10KB |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Finding details | Optional (contains vuln details) |
| Test payloads | No |
| Response evidence | Optional |
| Screenshots | No |
| Endpoint inventory | No |

---

## 10. Module Progression Engine

### 10.1 Module Ordering

```python
class ModuleProgressionEngine:
    MODULE_ORDER = [
        "01-Recon",
        "02-JS-Analysis",
        "03-API-Discovery",
        "04-Auth-Testing",
        "05-Authorization",
        "06-Input-Validation",
        "07-Business-Logic",
        "12-SSRF",
        "13-XSS",
        "25-XXE",
        "27-Command-Injection",
        "31-SSTI",
        "32-JWT",
        # ... remaining modules
    ]
    
    def get_next_module(self, completed_modules):
        for module in self.MODULE_ORDER:
            if module not in completed_modules:
                return module
        return None
```

### 10.2 Parallel Module Support

```python
class ParallelHuntingManager:
    MAX_PARALLEL_MODULES = 4
    
    def get_parallel_modules(self, completed, in_progress):
        next_modules = []
        for module in self.engine.MODULE_ORDER:
            if module not in completed and module not in in_progress:
                next_modules.append(module)
            if len(next_modules) >= self.MAX_PARALLEL_MODULES - len(in_progress):
                break
        return next_modules
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `findings_count` | Gauge | N/A (audit) |
| `findings_by_severity` | Gauge | CRITICAL > 0 (immediate review) |
| `test_coverage_percent` | Gauge | < 20% after 2h |
| `modules_completed` | Gauge | Stalled > 30min |
| `payloads_sent_total` | Counter | N/A (audit) |
| `endpoints_tested` | Gauge | < 50% of discovered |
| `poc_readiness` | Gauge | findings with no PoC > 3 |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `1-Reconnaissance-and-Asset-Discovery.md` → Recon state, asset inventory, discovery progress
2. `2-JavaScript-Analysis-and-Deobfuscation.md` → JS analysis state, endpoint extraction
3. `3-API-Endpoint-Analysis.md` → API catalog, endpoint testing state
4. `4-Authentication-and-Session-Management.md` → Auth test state, session analysis
5. `5-Authorization-and-Access-Control.md` → Authz test state, access matrix
6. `6-Input-Validation-and-Sanitization.md` → Input validation state, filter bypass state
7. `7-Business-Logic-Flaws.md` → Business logic test state, flow map
8. `8-Client-Side-Storage-Security.md` → Storage analysis state, cookie/localStorage audit
9. `9-Cryptography-and-Data-Protection.md` → Crypto analysis state, algorithm inventory
10. `10-Error-Handling-and-Information-Disclosure.md` → Info disclosure state, error map
11. `11-File-Upload-and-Processing.md` → Upload test state, file type analysis
12. `12-Server-Side-Request-Forgery-SSRF.md` → SSRF test state, callback state
13. `13-Cross-Site-Request-Forgery-CSRF.md` → CSRF test state, token inventory
14. `14-Cross-Origin-Resource-Sharing-CORS.md` → CORS analysis state, origin map
15. `15-Race-Conditions-and-Concurrency-Issues.md` → Race test state, timing analysis
16. `16-Third-Party-Component-Analysis.md` → 3P analysis state, dependency inventory
17. `17-Configuration-and-Misconfiguration-Hunting.md` → Config analysis state, misconfig list
18. `18-Network-and-Infrastructure-Security.md` → Network test state, port/service map
19. `19-Mobile-and-API-Specific-Vulnerabilities.md` → Mobile/API test state, API inventory
20. `20-Reporting-and-Proof-of-Concept-Development.md` → Reporting state, PoC draft state
21. `21-Web-Application-Firewall-WAF-Bypass.md` → WAF bypass state, filter analysis
22. `22-HTTP-Request-Smuggling.md` → Smuggling test state, TE/CL analysis
23. `23-Subdomain-Takeover.md` → Takeover analysis state, CNAME inventory
24. `24-Host-Header-Injection.md` → Host header test state, injection points
25. `25-XML-External-Entity-XXE-Injection.md` → XXE test state, parser analysis
26. `26-Insecure-Deserialization.md` → Deser test state, gadget chain analysis
27. `27-Command-Injection.md` → Command injection test state, filter analysis
28. `28-NoSQL-Injection.md` → NoSQLi test state, operator analysis
29. `29-GraphQL-Vulnerabilities.md` → GraphQL test state, schema analysis
30. `30-WebSocket-Security.md` → WebSocket test state, message analysis
31. `31-Server-Side-Template-Injection.md` → SSTI test state, engine detection
32. `32-JSON-Web-Token-JWT-Vulnerabilities.md` → JWT test state, algorithm analysis
33. `33-Content-Security-Policy-CSP-Bypass.md` → CSP analysis state, bypass attempts
34. `34-Clickjacking-and-UI-Redressing.md` → Clickjacking test state, frame analysis
35. `35-HTTP-Parameter-Pollution.md` → HPP test state, parameter behavior
36. `36-LDAP-Injection.md` → LDAP injection test state, query analysis
37. `37-Session-Puzzling-and-Fixation.md` → Session test state, session flow analysis
38. `38-Insecure-File-Handling.md` → File handling test state, path analysis
39. `39-Cross-Site-Script-Inclusion-XSSI.md` → XSSI test state, script source analysis
40. `40-Prototype-Pollution.md` → Prototype pollution test state, sink analysis
41. `41-HTTP-Response-Splitting.md` → Response splitting test state, header injection
42. `42-XPath-Injection.md` → XPath injection test state, query analysis
43. `43-Cross-Site-Request-Forgery-CSRF.md` → CSRF extended test state
44. `44-Cross-Origin-Resource-Sharing-CORS.md` → CORS extended analysis state
45. `45-Race-Conditions-and-Concurrency-Issues.md` → Race extended test state
46. `46-Third-Party-Component-Analysis.md` → 3P extended analysis state
47. `47-Configuration-and-Misconfiguration-Hunting.md` → Config extended analysis state
48. `48-Network-and-Infrastructure-Security.md` → Network extended test state
49. `49-Mobile-and-API-Specific-Vulnerabilities.md` → Mobile/API extended test state
50. `50-Reporting-and-Proof-of-Concept-Development.md` → Reporting extended state
