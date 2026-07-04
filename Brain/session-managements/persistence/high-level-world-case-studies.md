# State Persistence: High-Level World Case Studies Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | High-Level World Case Studies |
| **Directory** | `High-Level-World-Case-Studies/` |
| **File Count** | 46 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/high-level-world-case-studies.md` |
| **Serialization** | JSON (primary), MessagePack (analysis stream), Protobuf (case archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the High-Level World Case Studies domain. This domain contains 46 real-world case study analyses that provide strategic intelligence for bug bounty hunting. The persistence layer captures analysis state, pattern extraction, strategic insights, and cross-case correlation data.

Each case study analysis generates findings about attack patterns, impact assessments, and strategic lessons. The persistence layer ensures these insights are searchable, cross-referenceable, and available for pattern matching against current targets.

The 46 case studies span critical infrastructure breaches, zero-day exploitation, vulnerability chaining, program dynamics, industry-specific findings, attack technique analysis, and advanced persistent threat patterns. Each generates unique state that must be captured, indexed, and made available for correlation.

---

## 2. Domain File Registry

All 46 domain files organized by case study category:

### Critical Infrastructure Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 05 | `05-Critical-Infrastructure-Breach.md` | Critical infrastructure | DEEP |
| 06 | `06-Zero-Day-Exploitation-Case.md` | Zero-day exploitation | DEEP |
| 07 | `07-Chain-of-Vulnerabilities.md` | Vulnerability chains | DEEP |
| 08 | `08-Real-World-Impact-Assessment.md` | Impact assessment | MODERATE |

### Discovery and Process Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 09 | `09-Timeline-from-Discovery-to-Fix.md` | Timeline analysis | MODERATE |
| 10 | `10-Reward-Maximization-Strategies.md` | Reward optimization | DEEP |
| 11 | `11-Report-Quality-Analysis.md` | Report quality | MODERATE |
| 12 | `12-Triage-Process-Understanding.md` | Triage analysis | MODERATE |
| 13 | `13-Program-Response-Analysis.md` | Program response | MODERATE |
| 14 | `14-Disclosure-Timeline-Study.md` | Disclosure process | MODERATE |
| 15 | `15-Collaborative-Hunting-Case.md` | Collaboration | MODERATE |

### Pattern and Industry Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 16 | `16-Cross-Program-Vulnerability-Patterns.md` | Cross-program patterns | DEEP |
| 17 | `17-Industry-Specific-Findings.md` | Industry analysis | DEEP |
| 18 | `18-Mobile-App-Vulnerability-Case.md` | Mobile vulnerabilities | MODERATE |
| 19 | `19-Web-Application-Security-Case.md` | Web app security | MODERATE |
| 20 | `20-API-Security-Breach-Analysis.md` | API security | DEEP |

### Technology-Specific Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 21 | `21-Cloud-Configuration-Error.md` | Cloud misconfig | DEEP |
| 22 | `22-Container-Escape-Case-Study.md` | Container escape | DEEP |
| 23 | `23-IoT-Device-Compromise.md` | IoT compromise | MODERATE |
| 24 | `24-Blockchain-Smart-Contract-Bug.md` | Blockchain | MODERATE |
| 25 | `25-Cryptocurrency-Exchange-Hack.md` | Crypto exchange | DEEP |

### Social and Physical Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 26 | `26-Social-Engineering-Success.md` | Social engineering | MODERATE |
| 27 | `27-Physical-Security-Bypass.md` | Physical security | MODERATE |

### Network and Data Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 28 | `28-Network-Infrastructure-Attack.md` | Network attack | DEEP |
| 29 | `29-Database-Compromise-Case.md` | Database compromise | DEEP |
| 30 | `30-File-System-Attack-Analysis.md` | File system attack | MODERATE |

### Vulnerability Class Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 31 | `31-Authentication-Bypass-Case.md` | Auth bypass | DEEP |
| 32 | `32-Authorization-Flaw-Study.md` | Authz flaw | DEEP |
| 33 | `33-Session-Management-Issue.md` | Session management | MODERATE |
| 34 | `34-Input-Validation-Failure.md` | Input validation | MODERATE |
| 35 | `35-Business-Logic-Flaw-Analysis.md` | Business logic | DEEP |
| 36 | `36-Information-Disclosure-Case.md` | Info disclosure | MODERATE |
| 37 | `37-Weak-Cryptography-Example.md` | Weak crypto | MODERATE |
| 38 | `38-Insecure-Communication-Study.md` | Insecure comm | MODERATE |

### Supply Chain and Advanced Cases
| # | File | Case Category | Analysis Depth |
|---|------|--------------|---------------|
| 39 | `39-Third-Party-Component-Vulnerability.md` | 3P vulnerability | DEEP |
| 40 | `40-Supply-Chain-Attack-Case.md` | Supply chain | DEEP |
| 41 | `41-Zero-Trust-Bypass-Analysis.md` | Zero trust bypass | DEEP |
| 42 | `42-Multi-Factor-Authentication-Bypass.md` | MFA bypass | DEEP |
| 43 | `43-Privilege-Escalation-Case.md` | Privilege escalation | DEEP |
| 44 | `44-Lateral-Movement-Study.md` | Lateral movement | DEEP |
| 45 | `45-Data-Exfiltration-Method.md` | Data exfiltration | DEEP |
| 46 | `46-Persistence-Mechanism-Analysis.md` | Persistence | DEEP |
| 47 | `47-Anti-Forensic-Technique-Study.md` | Anti-forensics | MODERATE |
| 48 | `48-Incident-Response-Failure.md` | IR failure | MODERATE |
| 49 | `49-Compliance-Violation-Case.md` | Compliance | MODERATE |
| 50 | `50-Post-Mortem-Analysis.md` | Post-mortem | DEEP |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Case Analysis)

```json
{
  "schema_version": "1.0.0",
  "domain": "high-level-world-case-studies",
  "session_id": "sess_c1c2d3e4f5g6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "case_analyses": {
    "case_001": {
      "source_file": "07-Chain-of-Vulnerabilities.md",
      "case_title": "Multi-stage chain exploitation at Fortune 500",
      "analysis_status": "completed",
      "analyzed_at": "2026-06-25T15:00:00.000Z",
      "patterns_extracted": [
        {
          "pattern_id": "pat_chain_xss_sqli",
          "pattern_type": "vulnerability_chain",
          "chain": ["stored_xss", "session_hijack", "sqli_via_session"],
          "severity": "CRITICAL",
          "applicability_score": 0.85
        }
      ],
      "strategic_insights": [
        "Chain exploitation bypasses single-vuln rate limits",
        "Session fixation enables reliable chain initiation"
      ],
      "applicable_to_current_target": true,
      "cross_references": ["case_015", "case_032"]
    }
  },
  "pattern_database": {
    "total_patterns": 127,
    "by_type": {
      "vulnerability_chain": 45,
      "auth_bypass": 23,
      "data_exfiltration": 18,
      "privilege_escalation": 22,
      "persistence": 19
    },
    "high_applicability_count": 34
  },
  "strategic_intel": {
    "cases_analyzed": 28,
    "cases_pending": 18,
    "key_insights_count": 89,
    "cross_case_correlations": 45
  }
}
```

### 3.2 MessagePack (Analysis Stream)

```python
import msgpack

# Case analysis event
analysis_event = {
    "event": "pattern_extracted",
    "case_id": "case_001",
    "pattern_id": "pat_chain_xss_sqli",
    "pattern_type": "vulnerability_chain",
    "timestamp": time.time(),
    "applicability_score": 0.85
}
packed = msgpack.packb(analysis_event, use_bin_type=True)
```

### 3.3 Protobuf (Case Archive Schema)

```protobuf
syntax = "proto3";
package cases;

message CaseAnalysis {
  string case_id = 1;
  string source_file = 2;
  string case_title = 3;
  string analysis_status = 4;
  int64 analyzed_at = 5;
  repeated ExtractedPattern patterns = 6;
  repeated string strategic_insights = 7;
  bool applicable_to_current = 8;
  repeated string cross_references = 9;
}

message ExtractedPattern {
  string pattern_id = 1;
  string pattern_type = 2;
  repeated string chain = 3;
  string severity = 4;
  double applicability_score = 5;
  map<string, string> metadata = 6;
}

message PatternDatabase {
  int32 total_patterns = 1;
  map<string, int32> by_type = 2;
  int32 high_applicability_count = 3;
  repeated PatternEntry entries = 4;
}

message PatternEntry {
  string pattern_id = 1;
  string pattern_type = 2;
  string source_case = 3;
  double applicability_score = 4;
  int64 last_used = 5;
  int32 times_applied = 6;
}

message StrategicIntel {
  int32 cases_analyzed = 1;
  int32 cases_pending = 2;
  int32 key_insights_count = 3;
  int32 cross_case_correlations = 4;
  repeated Insight insights = 5;
}

message Insight {
  string insight_id = 1;
  string source_case = 2;
  string category = 3;
  string description = 4;
  double confidence = 5;
  repeated string supporting_cases = 6;
}

message CrossCaseCorrelation {
  string correlation_id = 1;
  string case_id_1 = 2;
  string case_id_2 = 3;
  string correlation_type = 4;
  double strength = 5;
  string shared_element = 6;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── high-level-cases/
        ├── {session_id}/
        │   ├── case_analyses.json
        │   ├── pattern_database.json
        │   ├── strategic_intel.json
        │   ├── analysis_notes/
        │   │   ├── case_001_notes.json
        │   │   ├── case_002_notes.json
        │   │   └── ...
        │   ├── extracted_patterns/
        │   │   ├── pat_chain_xss_sqli.json
        │   │   └── ...
        │   ├── cross_references/
        │   │   ├── xref_001.json
        │   │   └── ...
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_pattern_db.json
            ├── cross_case_index.json
            ├── industry_patterns.json
            ├── applicability_matrix.json
            └── insight_registry.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE case_analyses (
    case_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    source_file TEXT NOT NULL,
    case_title TEXT NOT NULL,
    analysis_status TEXT NOT NULL,
    analyzed_at INTEGER,
    patterns_extracted INTEGER DEFAULT 0,
    insights_count INTEGER DEFAULT 0,
    applicable_to_current INTEGER DEFAULT 0,
    analysis_blob BLOB NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE extracted_patterns (
    pattern_id TEXT PRIMARY KEY,
    case_id TEXT NOT NULL,
    pattern_type TEXT NOT NULL,
    chain_json TEXT NOT NULL,
    severity TEXT NOT NULL,
    applicability_score REAL NOT NULL,
    times_applied INTEGER DEFAULT 0,
    last_applied INTEGER,
    FOREIGN KEY (case_id) REFERENCES case_analyses(case_id)
);

CREATE TABLE strategic_insights (
    insight_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    source_case TEXT NOT NULL,
    category TEXT NOT NULL,
    description TEXT NOT NULL,
    confidence REAL NOT NULL,
    created_at INTEGER NOT NULL,
    FOREIGN KEY (source_case) REFERENCES case_analyses(case_id)
);

CREATE TABLE cross_case_correlations (
    correlation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    case_id_1 TEXT NOT NULL,
    case_id_2 TEXT NOT NULL,
    correlation_type TEXT NOT NULL,
    strength REAL NOT NULL,
    shared_element TEXT,
    notes TEXT
);

CREATE INDEX idx_patterns_type ON extracted_patterns(pattern_type);
CREATE INDEX idx_patterns_score ON extracted_patterns(applicability_score);
CREATE INDEX idx_insights_category ON strategic_insights(category);
CREATE INDEX idx_correlations_case ON cross_case_correlations(case_id_1);
```

---

## 5. State Snapshot Schema

### 5.1 Analysis Progress Snapshot

```json
{
  "snapshot_type": "analysis_progress",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "progress": {
    "total_cases": 46,
    "completed": 28,
    "in_progress": 3,
    "pending": 15,
    "completion_percent": 60.9
  },
  "by_category": {
    "critical_infrastructure": {"total": 4, "completed": 3},
    "vulnerability_class": {"total": 10, "completed": 6},
    "technology_specific": {"total": 5, "completed": 3},
    "social_physical": {"total": 2, "completed": 1},
    "network_data": {"total": 3, "completed": 2},
    "supply_chain_advanced": {"total": 12, "completed": 8},
    "discovery_process": {"total": 7, "completed": 4},
    "pattern_industry": {"total": 3, "completed": 1}
  },
  "durations": {
    "avg_analysis_minutes": 35,
    "total_analysis_minutes": 980,
    "longest_analysis_minutes": 75,
    "shortest_analysis_minutes": 12
  }
}
```

### 5.2 Pattern Matching Snapshot

```json
{
  "snapshot_type": "pattern_matching",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "current_target": "example.com",
  "applicable_patterns": [
    {
      "pattern_id": "pat_chain_xss_sqli",
      "applicability": 0.85,
      "source_cases": ["case_001", "case_015"],
      "recommended_action": "Test for stored XSS on input fields that feed SQL queries"
    },
    {
      "pattern_id": "pat_auth_bypass_host",
      "applicability": 0.72,
      "source_cases": ["case_031"],
      "recommended_action": "Test host header injection for password reset poisoning"
    }
  ],
  "total_applicable": 34,
  "top_3_recommendations": [
    "Focus on stored XSS vectors on authenticated pages",
    "Test for session fixation before XSS exploitation",
    "Chain SSRF with internal service discovery"
  ]
}
```

### 5.3 Strategic Intelligence Snapshot

```json
{
  "snapshot_type": "strategic_intel",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "insights_summary": {
    "total_insights": 89,
    "high_confidence": 45,
    "medium_confidence": 34,
    "low_confidence": 10,
    "by_category": {
      "exploitation_technique": 32,
      "defense_bypass": 28,
      "impact_maximization": 15,
      "stealth_evasion": 14
    }
  },
  "cross_case_correlations": {
    "total_correlations": 45,
    "strong_correlations": 18,
    "top_correlated_pairs": [
      {"case_1": "case_007", "case_2": "case_040", "type": "supply_chain", "strength": 0.92},
      {"case_1": "case_031", "case_2": "case_042", "type": "auth_bypass", "strength": 0.88}
    ]
  },
  "actionable_intelligence": [
    {
      "insight": "Chain exploitation bypasses single-vuln rate limits",
      "cases": ["case_007", "case_015", "case_043"],
      "action": "Always attempt to chain multiple low-severity findings"
    }
  ]
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Case analysis started | analysis_progress | MEDIUM |
| Case analysis completed | case_analyses | HIGH |
| Pattern extracted | pattern_database | HIGH |
| Pattern applied to target | pattern_database | MEDIUM |
| Cross-case correlation found | cross_case_index | MEDIUM |
| Strategic insight generated | strategic_intel | HIGH |
| Applicability score updated | applicability_matrix | MEDIUM |
| Insight confidence upgraded | strategic_intel | LOW |
| Session end | All state | HIGH |

---

## 7. Restore Operations

### 7.1 Full Case State Restore

```python
def restore_case_state(session_id):
    state = load_latest_snapshot(session_id, "case_analyses")
    patterns = load_shared("global_pattern_db.json")
    correlations = query_db(
        "SELECT * FROM cross_case_correlations WHERE case_id_1 IN "
        "(SELECT case_id FROM case_analyses WHERE session_id = ?)",
        (session_id,)
    )
    
    # Rebuild analysis notes
    for case_id in state.get("case_analyses", {}):
        notes_path = f"state/high-level-cases/{session_id}/analysis_notes/{case_id}_notes.json"
        if file_exists(notes_path):
            state["case_analyses"][case_id]["notes"] = load_json(notes_path)
    
    return CaseState(analyses=state, patterns=patterns, correlations=correlations)
```

### 7.2 Pattern Database Restore

```python
def restore_pattern_database(session_id=None):
    if session_id:
        return load_latest_snapshot(session_id, "pattern_database")
    return load_shared("global_pattern_db.json")

def restore_applicable_patterns(target_profile):
    pattern_db = load_shared("global_pattern_db.json")
    applicable = []
    
    for pattern_id, pattern in pattern_db.items():
        score = calculate_applicability(pattern, target_profile)
        if score > 0.5:
            applicable.append({"pattern": pattern, "score": score})
    
    return sorted(applicable, key=lambda x: x["score"], reverse=True)
```

### 7.3 Strategic Intelligence Restore

```python
def restore_strategic_intel(session_id=None):
    if session_id:
        return load_latest_snapshot(session_id, "strategic_intel")
    
    # Rebuild from all analyzed cases
    all_cases = query_db("SELECT * FROM case_analyses WHERE analysis_status = 'completed'")
    insights = []
    for case in all_cases:
        case_insights = query_db(
            "SELECT * FROM strategic_insights WHERE source_case = ?",
            (case["case_id"],)
        )
        insights.extend(case_insights)
    
    return build_strategic_intel(insights)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold | Rationale |
|-----------|-----------|-----------|-----------|
| Case analyses | zlib | > 50KB | Multi-field analysis objects |
| Pattern database | zlib | > 100KB | Large indexed dataset |
| Analysis notes | gzip | > 20KB | Free-text content |
| Strategic insights | None | N/A | Small, reference data |
| Cross-reference index | gzip | > 50KB | Relationship graph data |
| Checkpoint blobs | LZ4 | > 10KB | Fast decompression for recovery |
| Insight archives | gzip | > 30KB | Long-term storage |

### 8.1 Compression Implementation

```python
import zlib
import gzip
import lz4.frame

class CaseStudyCompression:
    ALGORITHMS = {
        "zlib": lambda d: zlib.compress(d, 6),
        "gzip": lambda d: gzip.compress(d, 6),
        "lz4": lambda d: lz4.frame.compress(d),
        "none": lambda d: d
    }
    
    DECOMPRESSORS = {
        "zlib": lambda d: zlib.decompress(d),
        "gzip": lambda d: gzip.decompress(d),
        "lz4": lambda d: lz4.frame.decompress(d),
        "none": lambda d: d
    }
    
    def compress(self, data: bytes, data_type: str) -> tuple:
        if data_type == "pattern_database" and len(data) > 100000:
            return self.ALGORITHMS["zlib"](data), "zlib"
        elif data_type == "analysis_notes" and len(data) > 20000:
            return self.ALGORITHMS["gzip"](data), "gzip"
        elif data_type == "checkpoint" and len(data) > 10000:
            return self.ALGORITHMS["lz4"](data), "lz4"
        return data, "none"
    
    def decompress(self, data: bytes, algorithm: str) -> bytes:
        return self.DECOMPRESSORS[algorithm](data)
```

---

## 9. Encryption

| Data Classification | Required | Algorithm | Key Management |
|--------------------|----------|-----------|----------------|
| Case analyses | No | None | N/A |
| Pattern database | No | None | N/A |
| Strategic insights | No | None | N/A |
| Cross-case correlations | No | None | N/A |
| Pre-disclosure patterns | Optional | AES-256-GCM | Per-session key |
| Sensitive case details | Optional | AES-256-GCM | Per-session key |

### 9.1 Pre-Disclosure Encryption

For case studies involving vulnerabilities that have not yet been fully disclosed:

```python
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os

class PreDisclosureEncryption:
    def encrypt_case(self, case_data: dict, session_id: str) -> dict:
        key = self.derive_key(session_id, "case_data")
        nonce = os.urandom(12)
        aesgcm = AESGCM(key)
        
        plaintext = json.dumps(case_data).encode()
        ciphertext = aesgcm.encrypt(nonce, plaintext, None)
        
        return {
            "ciphertext": ciphertext.hex(),
            "nonce": nonce.hex(),
            "algorithm": "AES-256-GCM",
            "classification": "pre_disclosure"
        }
```

---

## 10. Pattern Applicability Engine

### 10.1 Applicability Scoring

```python
class ApplicabilityScorer:
    WEIGHTS = {
        "tech_stack_overlap": 0.25,
        "vuln_class_relevance": 0.30,
        "scope_type_match": 0.15,
        "industry_match": 0.10,
        "historical_success": 0.20
    }

    def score_pattern(self, pattern, target_profile):
        scores = {
            "tech_stack_overlap": self.tech_overlap(pattern, target_profile),
            "vuln_class_relevance": self.vuln_relevance(pattern, target_profile),
            "scope_type_match": self.scope_match(pattern, target_profile),
            "industry_match": self.industry_match(pattern, target_profile),
            "historical_success": pattern.get("effectiveness_score", 0.5)
        }
        
        return sum(scores[k] * self.WEIGHTS[k] for k in self.WEIGHTS)
    
    def tech_overlap(self, pattern, target):
        pattern_techs = set(pattern.get("applicable_frameworks", []))
        target_techs = set(target.get("technologies", []))
        if not pattern_techs:
            return 0.5
        return len(pattern_techs & target_techs) / len(pattern_techs)
    
    def vuln_relevance(self, pattern, target):
        pattern_vulns = set(pattern.get("vuln_classes", []))
        target_potential = set(target.get("potential_vuln_classes", []))
        if not pattern_vulns:
            return 0.3
        return len(pattern_vulns & target_potential) / len(pattern_vulns)
```

### 10.2 Pattern Recommendation Engine

```python
class PatternRecommender:
    def recommend_for_target(self, target_profile, limit=10):
        all_patterns = self.load_pattern_database()
        
        scored_patterns = []
        for pattern_id, pattern in all_patterns.items():
            score = self.scorer.score_pattern(pattern, target_profile)
            if score > 0.4:
                scored_patterns.append({
                    "pattern_id": pattern_id,
                    "pattern": pattern,
                    "applicability_score": score,
                    "source_cases": pattern.get("source_cases", []),
                    "recommended_action": self.generate_recommendation(pattern, target_profile)
                })
        
        scored_patterns.sort(key=lambda x: x["applicability_score"], reverse=True)
        return scored_patterns[:limit]
    
    def generate_recommendation(self, pattern, target):
        vuln_class = pattern.get("primary_vuln_class", "unknown")
        technique = pattern.get("technique", "general testing")
        return f"Test for {vuln_class} using {technique} on {target.get('primary_domain', 'target')}"
```

### 10.3 Cross-Case Correlation

```python
class CrossCaseCorrelator:
    def find_correlations(self, case_analyses):
        correlations = []
        
        for i, case_1 in enumerate(case_analyses):
            for case_2 in case_analyses[i+1:]:
                strength = self.calculate_correlation(case_1, case_2)
                if strength > 0.6:
                    shared = self.find_shared_elements(case_1, case_2)
                    correlations.append({
                        "case_id_1": case_1["case_id"],
                        "case_id_2": case_2["case_id"],
                        "correlation_type": self.classify_correlation(shared),
                        "strength": strength,
                        "shared_element": shared
                    })
        
        return sorted(correlations, key=lambda c: c["strength"], reverse=True)
    
    def calculate_correlation(self, case_1, case_2):
        shared_patterns = set(case_1.get("patterns", [])) & set(case_2.get("patterns", []))
        shared_ttps = set(case_1.get("ttps", [])) & set(case_2.get("ttps", []))
        
        total_elements = max(
            len(case_1.get("patterns", [])) + len(case_1.get("ttps", [])),
            len(case_2.get("patterns", [])) + len(case_2.get("ttps", [])),
            1
        )
        
        return (len(shared_patterns) + len(shared_ttps)) / total_elements
```

---

## 11. Monitoring

| Metric | Type | Alert | Threshold |
|--------|------|-------|-----------|
| `cases_analyzed_count` | Gauge | N/A (audit) | — |
| `cases_pending_count` | Gauge | Stalled | > 10 for 7d |
| `pattern_extraction_rate` | Gauge | Low output | < 2 per case |
| `pattern_applicability_rate` | Gauge | Low relevance | < 30% |
| `cross_case_correlations` | Gauge | N/A (audit) | — |
| `strategic_insights_count` | Gauge | N/A (audit) | — |
| `insight_confidence_avg` | Gauge | Low quality | < 0.6 |
| `pattern_effectiveness_avg` | Gauge | Low impact | < 0.5 |

### 11.1 Audit Trail

```json
{
  "audit_event": "case_analysis_completed",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "session_id": "sess_c1c2d3e4f5g6",
  "case_id": "case_007",
  "source_file": "07-Chain-of-Vulnerabilities.md",
  "patterns_extracted": 5,
  "insights_generated": 8,
  "duration_minutes": 35,
  "applicable_to_target": true,
  "cross_references_found": 3
}
```

---

## 12. Integration Points

### 12.1 Downstream Consumers

| Consumer | Data Consumed | Protocol |
|----------|--------------|----------|
| Hunting Domains | Applicable patterns | File read |
| Strategy Domain | Strategic insights | File read |
| Reporting Domain | Case references | SQLite query |
| Pattern Matcher | Pattern database | File read + scoring |

### 12.2 Upstream Producers

| Producer | Data Produced | Protocol |
|----------|--------------|----------|
| Case Analysis Engine | Case analyses, patterns | File write |
| Insight Extractor | Strategic insights | SQLite write |
| Correlation Engine | Cross-case correlations | SQLite write |
| Applicability Scorer | Applicability scores | File write |

---

## 13. Case Study Lifecycle

### 13.1 Analysis Pipeline

```python
class CaseStudyPipeline:
    def analyze_case(self, case_id, source_file):
        # Phase 1: Source gathering
        sources = self.gather_sources(source_file)
        self.save_checkpoint(case_id, "sources_gathered", sources)
        
        # Phase 2: Timeline reconstruction
        timeline = self.reconstruct_timeline(sources)
        self.save_checkpoint(case_id, "timeline_complete", timeline)
        
        # Phase 3: TTP extraction
        ttps = self.extract_ttps(timeline)
        self.save_checkpoint(case_id, "ttps_extracted", ttps)
        
        # Phase 4: Pattern extraction
        patterns = self.extract_patterns(ttps, timeline)
        self.save_checkpoint(case_id, "patterns_extracted", patterns)
        
        # Phase 5: Strategic insight generation
        insights = self.generate_insights(patterns, ttps)
        self.save_checkpoint(case_id, "insights_generated", insights)
        
        # Phase 6: Cross-reference indexing
        cross_refs = self.find_cross_references(case_id, patterns)
        self.save_checkpoint(case_id, "cross_refs_complete", cross_refs)
        
        # Phase 7: Applicability scoring
        self.update_applicability_scores(patterns)
        
        # Phase 8: Final case archive
        self.archive_case(case_id, {
            "sources": sources,
            "timeline": timeline,
            "ttps": ttps,
            "patterns": patterns,
            "insights": insights,
            "cross_references": cross_refs
        })
        
        return {
            "case_id": case_id,
            "status": "completed",
            "patterns_count": len(patterns),
            "insights_count": len(insights),
            "cross_refs_count": len(cross_refs)
        }
```

### 13.2 Checkpoint Protocol

```python
class CaseCheckpointManager:
    def save_checkpoint(self, case_id, phase, data):
        checkpoint = {
            "case_id": case_id,
            "phase": phase,
            "timestamp": time.time(),
            "data": data,
            "checksum": compute_checksum(data)
        }
        
        # Save to filesystem
        path = f"checkpoints/{case_id}_{phase}.json"
        write_json(path, checkpoint)
        
        # Save to MessagePack for fast restore
        packed = msgpack.packb(checkpoint, use_bin_type=True)
        write_binary(f"checkpoints/{case_id}_{phase}.msgpack", packed)
        
        return checkpoint
    
    def restore_from_checkpoint(self, case_id, phase=None):
        if phase:
            return self.load_checkpoint(case_id, phase)
        
        # Find latest checkpoint
        checkpoints = glob(f"checkpoints/{case_id}_*.json")
        if not checkpoints:
            return None
        
        latest = max(checkpoints, key=os.path.getmtime)
        return load_json(latest)
```

---

## Appendix A: Complete File Reference

All 46 domain files with persistence state mapping:

1. `05-Critical-Infrastructure-Breach.md` → Critical infra attack patterns, breach timeline, impact data, defensive gaps
2. `06-Zero-Day-Exploitation-Case.md` → 0day discovery methodology, exploitation chain, disclosure timeline
3. `07-Chain-of-Vulnerabilities.md` → Chain exploitation patterns, multi-stage attack flow, intermediate states
4. `08-Real-World-Impact-Assessment.md` → Impact quantification patterns, financial/user/downtime metrics
5. `09-Timeline-from-Discovery-to-Fix.md` → Timeline patterns, fix velocity data, program response metrics
6. `10-Reward-Maximization-Strategies.md` → Reward optimization patterns, negotiation data, severity-to-reward mapping
7. `11-Report-Quality-Analysis.md` → Report quality patterns, acceptance criteria, common improvements
8. `12-Triage-Process-Understanding.md` → Triage patterns, triage decision data, status progression
9. `13-Program-Response-Analysis.md` → Response patterns, response time data, communication quality
10. `14-Disclosure-Timeline-Study.md` → Disclosure patterns, timeline data, coordination metrics
11. `15-Collaborative-Hunting-Case.md` → Collaboration patterns, team dynamics, credit distribution
12. `16-Cross-Program-Vulnerability-Patterns.md` → Cross-program patterns, recurrence data, universal findings
13. `17-Industry-Specific-Findings.md` → Industry patterns, sector analysis, compliance implications
14. `18-Mobile-App-Vulnerability-Case.md` → Mobile vuln patterns, platform analysis, API inventory
15. `19-Web-Application-Security-Case.md` → Web app patterns, framework analysis, tech stack data
16. `20-API-Security-Breach-Analysis.md` → API breach patterns, endpoint analysis, authentication data
17. `21-Cloud-Configuration-Error.md` → Cloud misconfig patterns, provider analysis, resource inventory
18. `22-Container-Escape-Case-Study.md` → Container escape patterns, runtime analysis, namespace data
19. `23-IoT-Device-Compromise.md` → IoT compromise patterns, firmware analysis, device inventory
20. `24-Blockchain-Smart-Contract-Bug.md` → Blockchain patterns, contract analysis, vulnerability mapping
21. `25-Cryptocurrency-Exchange-Hack.md` → Crypto exchange patterns, DeFi analysis, fund flow data
22. `26-Social-Engineering-Success.md` → Social engineering patterns, pretext analysis, psychological data
23. `27-Physical-Security-Bypass.md` → Physical security patterns, bypass analysis, facility data
24. `28-Network-Infrastructure-Attack.md` → Network attack patterns, topology analysis, protocol data
25. `29-Database-Compromise-Case.md` → Database compromise patterns, data classification, exfil methods
26. `30-File-System-Attack-Analysis.md` → File system patterns, path analysis, permission data
27. `31-Authentication-Bypass-Case.md` → Auth bypass patterns, mechanism analysis, credential data
28. `32-Authorization-Flaw-Study.md` → Authz flaw patterns, access analysis, role data
29. `33-Session-Management-Issue.md` → Session patterns, token analysis, lifecycle data
30. `34-Input-Validation-Failure.md` → Input validation patterns, filter analysis, encoding data
31. `35-Business-Logic-Flaw-Analysis.md` → Business logic patterns, flow analysis, state machine data
32. `36-Information-Disclosure-Case.md` → Info disclosure patterns, leak analysis, error data
33. `37-Weak-Cryptography-Example.md` → Weak crypto patterns, algorithm analysis, key data
34. `38-Insecure-Communication-Study.md` → Insecure comm patterns, protocol analysis, encryption data
35. `39-Third-Party-Component-Vulnerability.md` → 3P vuln patterns, dependency analysis, version data
36. `40-Supply-Chain-Attack-Case.md` → Supply chain patterns, pipeline analysis, trust data
37. `41-Zero-Trust-Bypass-Analysis.md` → Zero trust bypass patterns, architecture analysis, segment data
38. `42-Multi-Factor-Authentication-Bypass.md` → MFA bypass patterns, factor analysis, bypass methods
39. `43-Privilege-Escalation-Case.md` → Privesc patterns, mechanism analysis, access level data
40. `44-Lateral-Movement-Study.md` → Lateral movement patterns, pivot analysis, network path data
41. `45-Data-Exfiltration-Method.md` → Exfiltration patterns, channel analysis, volume data
42. `46-Persistence-Mechanism-Analysis.md` → Persistence patterns, mechanism analysis, detection data
43. `47-Anti-Forensic-Technique-Study.md` → Anti-forensic patterns, evasion analysis, detection gaps
44. `48-Incident-Response-Failure.md` → IR failure patterns, response analysis, timeline gaps
45. `49-Compliance-Violation-Case.md` → Compliance patterns, regulation analysis, violation data
46. `50-Post-Mortem-Analysis.md` → Post-mortem patterns, lessons learned, improvement data
