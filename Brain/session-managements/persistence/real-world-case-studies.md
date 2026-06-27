# State Persistence: Real-World Case Studies Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Real-World Case Studies |
| **Directory** | `Real-World-Case-Studies/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/real-world-case-studies.md` |
| **Serialization** | JSON (primary), MessagePack (pattern stream), Protobuf (disclosure archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Real-World Case Studies domain. This domain contains 50 disclosed vulnerability case studies organized by vulnerability class. Unlike the High-Level Case Studies (which focus on strategic patterns), this domain provides **tactical pattern databases** — specific exploitation techniques, payload patterns, bypass methods, and remediation approaches that can be directly applied to current hunting sessions.

The persistence layer captures pattern extraction, technique applicability tracking, payload effectiveness data, and cross-reference indexing between disclosed vulnerabilities and current targets.

---

## 2. Domain File Registry

All 50 domain files organized by vulnerability class:

### Injection Vulnerabilities
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 01 | `01-IDOR-Account-Takeover-Case-Studies.md` | IDOR → ATO | Exploitation |
| 02 | `02-XSS-Stored-Persistent-Attacks.md` | Stored XSS | Exploitation |
| 03 | `03-SQL-Injection-Data-Breaches.md` | SQLi | Exploitation |
| 04 | `04-SSRF-Internal-Network-Access.md` | SSRF | Exploitation |
| 05 | `05-CSRF-State-Changing-Attacks.md` | CSRF | Exploitation |
| 06 | `06-Command-Injection-RCE.md` | Command Injection | Exploitation |
| 28 | `28-LDAP-Injection-Attacks.md` | LDAP Injection | Exploitation |
| 29 | `29-XPath-Injection-Attacks.md` | XPath Injection | Exploitation |
| 30 | `30-NoSQL-Injection-MongoDB.md` | NoSQL Injection | Exploitation |

### Serialization and Deserialization
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 07 | `07-Deserialization-Remote-Code-Execution.md` | Deserialization → RCE | Exploitation |
| 17 | `17-Deserialization-Java-Deserialization.md` | Java Deserialization | Exploitation |
| 18 | `18-Deserialization-PHP-Unserialize.md` | PHP Unserialize | Exploitation |
| 19 | `19-Deserialization-Python-Pickle.md` | Python Pickle | Exploitation |

### File and Upload Vulnerabilities
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 08 | `08-File-Upload-Arbitrary-Upload.md` | File Upload | Exploitation |
| 43 | `43-Path-Traversal-File-Inclusion.md` | Path Traversal | Exploitation |
| 44 | `44-Local-File-Inclusion-LFI.md` | LFI | Exploitation |
| 45 | `45-Remote-File-Inclusion-RFI.md` | RFI | Exploitation |

### Server-Side Vulnerabilities
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 09 | `09-XXE-XML-External-Entity-Attacks.md` | XXE | Exploitation |
| 10 | `10-SSTI-Server-Side-Template-Injection.md` | SSTI | Exploitation |
| 46 | `46-Server-Side-Request-Forgery.md` | SSRF (Extended) | Exploitation |
| 47 | `47-Client-Side-Request-Forgery.md` | CSRF (Extended) | Exploitation |

### Authentication and Authorization
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 11 | `11-JWT-Token-Manipulation.md` | JWT | Bypass |
| 12 | `12-Authentication-Bypass.md` | Auth Bypass | Bypass |
| 13 | `13-Privilege-Escalation.md` | Privilege Escalation | Escalation |

### Business Logic and Information
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 14 | `14-Business-Logic-Flaws.md` | Business Logic | Logic |
| 15 | `15-Information-Disclosure.md` | Info Disclosure | Disclosure |

### Memory and Low-Level
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 16 | `16-Memory-Corruption-Heap-Overflow.md` | Heap Overflow | Memory |

### Race and Timing
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 20 | `20-Race-Condition-Time-of-Check.md` | Race Condition | Timing |

### Header and Request Manipulation
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 21 | `21-Host-Header-Injection.md` | Host Header | Injection |
| 27 | `27-HTTP-Response-Splitting.md` | Response Splitting | Injection |
| 36 | `36-HTTP-Request-Smuggling.md` | HTTP Smuggling | Smuggling |

### DNS and Network
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 22 | `22-DNS-Rebinding-Attacks.md` | DNS Rebinding | Network |
| 32 | `32-Subdomain-Takeover.md` | Subdomain Takeover | DNS |
| 35 | `35-WebCache-Poisoning.md` | Cache Poisoning | Cache |

### Client-Side Vulnerabilities
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 23 | `23-WebSocket-Security-Issues.md` | WebSocket | Client |
| 24 | `24-GraphQL-Introspection-Attacks.md` | GraphQL | Client |
| 25 | `25-CSP-Bypass-Techniques.md` | CSP Bypass | Client |
| 26 | `26-Clickjacking-UI-Redressing.md` | Clickjacking | Client |
| 31 | `31-Prototype-Pollution-JavaScript.md` | Prototype Pollution | Client |
| 33 | `33-Open-Redirect-Phishing.md` | Open Redirect | Client |
| 34 | `34-Content-Spoofing-Attacks.md` | Content Spoofing | Client |
| 37 | `37-WebSocket-Hijacking.md` | WebSocket Hijacking | Client |
| 38 | `38-CORS-Misconfiguration.md` | CORS | Client |
| 39 | `39-Token-Leakage-URL-Parameters.md` | Token Leakage | Client |

### Cryptography and Data
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 40 | `40-Sensitive-Data-Exposure.md` | Data Exposure | Data |
| 41 | `41-Weak-Encryption-Algorithms.md` | Weak Encryption | Crypto |
| 42 | `42-Insecure-Cryptographic-Storage.md` | Insecure Crypto Storage | Crypto |

### Mobile, Cloud, and API
| # | File | Vuln Class | Pattern Type |
|---|------|-----------|-------------|
| 48 | `48-Mobile-API-Security-Issues.md` | Mobile API | API |
| 49 | `49-Cloud-Misconfiguration-AWS.md` | Cloud (AWS) | Cloud |
| 50 | `50-API-Authentication-Bypass.md` | API Auth Bypass | API |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Pattern Database)

```json
{
  "schema_version": "1.0.0",
  "domain": "real-world-case-studies",
  "session_id": "sess_r1r2s3t4u5v6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "disclosed_patterns": {
    "pat_idor_ato_001": {
      "source_file": "01-IDOR-Account-Takeover-Case-Studies.md",
      "vuln_class": "idor",
      "technique": "sequential_id_enumeration",
      "payloads": [
        {
          "type": "parameter_tampering",
          "example": "GET /api/users/{victim_id}/profile",
          "variation": "Replace user_id with sequential numbers"
        }
      ],
      "bypasses": [
        "UUID enumeration via API error messages",
        "Indirect reference via /api/user/me endpoint"
      ],
      "impact": "account_takeover",
      "severity_range": ["HIGH", "CRITICAL"],
      "applicable_frameworks": ["express", "django", "rails", "laravel"],
      "times_referenced": 23,
      "effectiveness_score": 0.78
    }
  },
  "technique_index": {
    "total_techniques": 245,
    "by_category": {
      "injection": 89,
      "authentication": 34,
      "authorization": 28,
      "serialization": 18,
      "file_handling": 22,
      "client_side": 34,
      "crypto": 12,
      "network": 8
    }
  },
  "cross_reference_index": {
    "total_references": 567,
    "by_target_pattern": {
      "stored_xss": 45,
      "sqli": 38,
      "idor": 32,
      "ssrf": 28,
      "auth_bypass": 25
    }
  }
}
```

### 3.2 MessagePack (Pattern Stream)

```python
import msgpack

# Pattern reference event
ref_event = {
    "event": "pattern_referenced",
    "pattern_id": "pat_idor_ato_001",
    "current_target": "example.com",
    "applicable": True,
    "confidence": 0.82,
    "timestamp": time.time()
}
packed = msgpack.packb(ref_event, use_bin_type=True)
```

### 3.3 Protobuf (Disclosure Archive Schema)

```protobuf
syntax = "proto3";
package real_cases;

message DisclosedPattern {
  string pattern_id = 1;
  string source_file = 2;
  string vuln_class = 3;
  string technique = 4;
  repeated Payload payloads = 5;
  repeated string bypasses = 6;
  string impact = 7;
  repeated string severity_range = 8;
  repeated string applicable_frameworks = 9;
  int32 times_referenced = 10;
  double effectiveness_score = 11;
}

message Payload {
  string type = 1;
  string example = 2;
  string variation = 3;
}

message TechniqueIndex {
  int32 total_techniques = 1;
  map<string, int32> by_category = 2;
}

message CrossReferenceIndex {
  int32 total_references = 1;
  map<string, int32> by_target_pattern = 2;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── real-world-cases/
        ├── {session_id}/
        │   ├── disclosed_patterns.json
        │   ├── technique_index.json
        │   ├── cross_reference_index.json
        │   ├── applied_patterns/
        │   │   ├── app_001.json
        │   │   └── ...
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_pattern_db.json
            ├── technique_catalog.json
            ├── framework_compatibility.json
            └── effectiveness_scores.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE disclosed_patterns (
    pattern_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    source_file TEXT NOT NULL,
    vuln_class TEXT NOT NULL,
    technique TEXT NOT NULL,
    payloads_json TEXT NOT NULL,
    bypasses_json TEXT NOT NULL,
    impact TEXT NOT NULL,
    effectiveness_score REAL NOT NULL,
    times_referenced INTEGER DEFAULT 0,
    pattern_blob BLOB NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE pattern_applications (
    application_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern_id TEXT NOT NULL,
    session_id TEXT NOT NULL,
    target TEXT NOT NULL,
    applicable INTEGER NOT NULL,
    confidence REAL,
    applied_at INTEGER NOT NULL,
    result TEXT,
    FOREIGN KEY (pattern_id) REFERENCES disclosed_patterns(pattern_id)
);

CREATE TABLE technique_references (
    reference_id INTEGER PRIMARY KEY AUTOINCREMENT,
    pattern_id TEXT NOT NULL,
    reference_type TEXT NOT NULL,
    target_pattern TEXT NOT NULL,
    strength REAL NOT NULL,
    FOREIGN KEY (pattern_id) REFERENCES disclosed_patterns(pattern_id)
);

CREATE INDEX idx_patterns_vuln ON disclosed_patterns(vuln_class);
CREATE INDEX idx_patterns_score ON disclosed_patterns(effectiveness_score);
CREATE INDEX idx_applications_target ON pattern_applications(target);
```

---

## 5. State Snapshot Schema

### 5.1 Pattern Database Snapshot

```json
{
  "snapshot_type": "pattern_database",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "database_stats": {
    "total_patterns": 245,
    "total_references": 567,
    "avg_effectiveness": 0.72,
    "patterns_this_session": 12,
    "references_this_session": 34
  },
  "top_patterns": [
    {"pattern_id": "pat_idor_ato_001", "effectiveness": 0.78, "references": 23},
    {"pattern_id": "pat_xss_stored_003", "effectiveness": 0.82, "references": 19},
    {"pattern_id": "pat_sqli_union_002", "effectiveness": 0.75, "references": 17}
  ]
}
```

### 5.2 Applied Patterns Snapshot

```json
{
  "snapshot_type": "applied_patterns",
  "session_id": "sess_r1r2s3t4u5v6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "applications": [
    {
      "pattern_id": "pat_idor_ato_001",
      "target": "example.com",
      "applicable": true,
      "confidence": 0.82,
      "result": "found_similar_endpoint"
    }
  ],
  "summary": {
    "total_applied": 34,
    "applicable": 23,
    "found_vulns": 5,
    "effectiveness_rate": 0.68
  }
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Pattern extracted from case | disclosed_patterns | HIGH |
| Pattern applied to target | pattern_applications | MEDIUM |
| Pattern effectiveness updated | effectiveness_scores | MEDIUM |
| New technique indexed | technique_index | MEDIUM |
| Cross-reference created | cross_reference_index | LOW |
| Session end | All state | HIGH |

---

## 7. Restore Operations

```python
def restore_pattern_database(session_id=None):
    if session_id:
        return load_latest_snapshot(session_id, "disclosed_patterns")
    return load_shared("global_pattern_db.json")

def restore_applied_patterns(session_id):
    apps = query_db(
        "SELECT * FROM pattern_applications WHERE session_id = ? ORDER BY applied_at",
        (session_id,)
    )
    return apps

def restore_for_target(target, session_id=None):
    patterns = restore_pattern_database(session_id)
    applicable = [
        p for p in patterns.values()
        if target_matches_pattern(target, p)
    ]
    return sorted(applicable, key=lambda p: p["effectiveness_score"], reverse=True)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Pattern database | zlib | > 100KB |
| Applied patterns | None | N/A |
| Technique index | None | N/A |
| Cross-reference index | gzip | > 50KB |
| Checkpoint blobs | LZ4 | > 10KB |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Pattern database | No |
| Applied patterns | No |
| Technique index | No |
| Cross-reference index | No |

---

## 10. Pattern Matching Engine

### 10.1 Target-Pattern Matching

```python
class PatternMatcher:
    def match_patterns(self, target_profile, pattern_db):
        matches = []
        for pattern_id, pattern in pattern_db.items():
            score = self.calculate_match_score(target_profile, pattern)
            if score > 0.5:
                matches.append(PatternMatch(
                    pattern_id=pattern_id,
                    score=score,
                    applicable_vuln_classes=[pattern["vuln_class"]],
                    recommended_payloads=pattern["payloads"][:3]
                ))
        return sorted(matches, key=lambda m: m.score, reverse=True)

    def calculate_match_score(self, target, pattern):
        score = 0.0
        if target.framework in pattern.get("applicable_frameworks", []):
            score += 0.4
        if pattern["vuln_class"] in target.potential_vuln_classes:
            score += 0.3
        score += pattern["effectiveness_score"] * 0.3
        return min(score, 1.0)
```

### 10.2 Effectiveness Tracking

```python
class EffectivenessTracker:
    def update_effectiveness(self, pattern_id, applied, found_vuln):
        pattern = load_pattern(pattern_id)
        total = pattern["times_referenced"] + 1
        successes = pattern.get("successful_applications", 0) + (1 if found_vuln else 0)
        pattern["effectiveness_score"] = successes / total
        pattern["times_referenced"] = total
        save_pattern(pattern_id, pattern)
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `pattern_count_total` | Gauge | N/A (audit) |
| `pattern_match_rate` | Gauge | < 30% |
| `pattern_effectiveness_avg` | Gauge | < 0.5 |
| `pattern_applications_count` | Counter | N/A (audit) |
| `technique_index_size` | Gauge | N/A (audit) |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `01-IDOR-Account-Takeover-Case-Studies.md` → IDOR exploitation patterns, sequential ID, UUID analysis
2. `02-XSS-Stored-Persistent-Attacks.md` → Stored XSS patterns, payload evolution, filter bypass
3. `03-SQL-Injection-Data-Breaches.md` → SQLi patterns, union-based, blind, time-based
4. `04-SSRF-Internal-Network-Access.md` → SSRF patterns, protocol smuggling, cloud metadata
5. `05-CSRF-State-Changing-Attacks.md` → CSRF patterns, token bypass, same-site cookie bypass
6. `06-Command-Injection-RCE.md` → Command injection patterns, filter bypass, encoding
7. `07-Deserialization-Remote-Code-Execution.md` → Deserialization RCE patterns, gadget chains
8. `08-File-Upload-Arbitrary-Upload.md` → File upload patterns, extension bypass, content-type
9. `09-XXE-XML-External-Entity-Attacks.md` → XXE patterns, OOB exfil, parameter entities
10. `10-SSTI-Server-Side-Template-Injection.md` → SSTI patterns, engine detection, RCE payloads
11. `11-JWT-Token-Manipulation.md` → JWT patterns, alg:none, key confusion, claim tampering
12. `12-Authentication-Bypass.md` → Auth bypass patterns, default creds, logic flaws
13. `13-Privilege-Escalation.md` → Privesc patterns, IDOR, role manipulation, token upgrade
14. `14-Business-Logic-Flaws.md` → Business logic patterns, price manipulation, quantity abuse
15. `15-Information-Disclosure.md` → Info disclosure patterns, error messages, debug endpoints
16. `16-Memory-Corruption-Heap-Overflow.md` → Heap overflow patterns, exploitation techniques
17. `17-Deserialization-Java-Deserialization.md` → Java deser patterns, ysoserial gadgets
18. `18-Deserialization-PHP-Unserialize.md` → PHP unserialize patterns, magic methods
19. `19-Deserialization-Python-Pickle.md` → Python pickle patterns, __reduce__ exploitation
20. `20-Race-Condition-Time-of-Check.md` → Race condition patterns, TOCTOU, parallel requests
21. `21-Host-Header-Injection.md` → Host header patterns, password reset poisoning
22. `22-DNS-Rebinding-Attacks.md` → DNS rebinding patterns, TTL manipulation
23. `23-WebSocket-Security-Issues.md` → WebSocket patterns, cross-site WebSocket hijacking
24. `24-GraphQL-Introspection-Attacks.md` → GraphQL patterns, introspection, batching attacks
25. `25-CSP-Bypass-Techniques.md` → CSP bypass patterns, script-src, nonce bypass
26. `26-Clickjacking-UI-Redressing.md` → Clickjacking patterns, frame busting bypass
27. `27-HTTP-Response-Splitting.md` → Response splitting patterns, header injection
28. `28-LDAP-Injection-Attacks.md` → LDAP injection patterns, filter bypass
29. `29-XPath-Injection-Attacks.md` → XPath injection patterns, boolean-based
30. `30-NoSQL-Injection-MongoDB.md` → NoSQLi patterns, operator injection, JavaScript injection
31. `31-Prototype-Pollution-JavaScript.md` → Prototype pollution patterns, __proto__, constructor
32. `32-Subdomain-Takeover.md` → Subdomain takeover patterns, CNAME dangling, service detection
33. `33-Open-Redirect-Phishing.md` → Open redirect patterns, parameter manipulation
34. `34-Content-Spoofing-Attacks.md` → Content spoofing patterns, text injection
35. `35-WebCache-Poisoning.md` → Cache poisoning patterns, unkeyed headers, parameter cloak
36. `36-HTTP-Request-Smuggling.md` → HTTP smuggling patterns, CL.TE, TE.CL, H2.CL
37. `37-WebSocket-Hijacking.md` → WebSocket hijacking patterns, origin bypass
38. `38-CORS-Misconfiguration.md` → CORS patterns, null origin, regex bypass
39. `39-Token-Leakage-URL-Parameters.md` → Token leakage patterns, referer, logging
40. `40-Sensitive-Data-Exposure.md` → Data exposure patterns, API response over-sharing
41. `41-Weak-Encryption-Algorithms.md` → Weak crypto patterns, DES, MD5, RC4
42. `42-Insecure-Cryptographic-Storage.md` → Crypto storage patterns, key management
43. `43-Path-Traversal-File-Inclusion.md` → Path traversal patterns, encoding bypass, null byte
44. `44-Local-File-Inclusion-LFI.md` → LFI patterns, filter wrappers, PHP sessions
45. `45-Remote-File-Inclusion-RFI.md` → RFI patterns, protocol wrappers, shell injection
46. `46-Server-Side-Request-Forgery.md` → SSRF patterns (extended), internal port scanning
47. `47-Client-Side-Request-Forgery.md` → CSRF patterns (extended), method override
48. `48-Mobile-API-Security-Issues.md` → Mobile API patterns, certificate pinning bypass
49. `49-Cloud-Misconfiguration-AWS.md` → AWS misconfig patterns, IMDS, S3, IAM
50. `50-API-Authentication-Bypass.md` → API auth bypass patterns, mass assignment, type confusion
