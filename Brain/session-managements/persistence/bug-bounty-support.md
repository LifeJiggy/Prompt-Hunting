# State Persistence: Bug Bounty Support Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Bug Bounty Support |
| **Directory** | `bug-bounty-support/` |
| **File Count** | 23 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/bug-bounty-support.md` |
| **Serialization** | JSON (primary), MessagePack (framework state), Protobuf (cross-session) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Bug Bounty Support domain. This domain provides the foundational framework for bug bounty operations — reconnaissance workflows, exploitation techniques, vulnerability detection, reporting, and tool integration. The persistence layer captures framework execution state, methodology progress, tool configurations, and cross-domain coordination data.

Unlike the specialized domains, the Support domain is a **framework domain** that coordinates and provides context for all other domains. Its persistence state is foundational — other domains reference its state for tool availability, methodology progress, and framework configuration.

---

## 2. Domain File Registry

All 23 domain files organized by support category:

### Core Framework
| # | File | Support Category | State Type |
|---|------|-----------------|-----------|
| 01 | `Advanced-Bug-Bounty-Prompt.md` | Advanced prompt framework | Configuration |
| 02 | `Advanced-Bug-Security-Hunting-Prompt.md` | Security hunting framework | Configuration |
| 03 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | Info disclosure framework | Configuration |
| 04 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | JS vuln analysis framework | Configuration |
| 05 | `Advanced-Techniques.md` | Advanced techniques registry | Reference |
| 06 | `Burp-AI.md` | Burp Suite AI integration | Runtime |

### Hunting Workflow
| # | File | Support Category | State Type |
|---|------|-----------------|-----------|
| 07 | `Chaining.md` | Chaining methodology | Configuration |
| 08 | `Core-Aspects-for-Bug-Security-Hunting.md` | Core hunting framework | Configuration |
| 09 | `debuging-using-browser-console-and-vscode-for-hunting.md` | Debug workflow | Runtime |
| 10 | `Ethical-Guidelines.md` | Ethics compliance state | Persistent |
| 11 | `Exploitation.md` | Exploitation framework | Configuration |

### Analysis and Identification
| # | File | Support Category | State Type |
|---|------|-----------------|-----------|
| 12 | `JavaScript-Identification-Deobfuscation.md` | JS analysis state | Runtime |
| 13 | `manual-testing-scope.md` | Manual testing scope | Runtime |
| 14 | `parameters.md` | Parameter tracking | Runtime |
| 15 | `PoC-Development.md` | PoC development state | Runtime |

### Process and Reporting
| # | File | Support Category | State Type |
|---|------|-----------------|-----------|
| 16 | `Reconnaissance.md` | Recon methodology state | Runtime |
| 17 | `Reporting.md` | Report template state | Runtime |
| 18 | `Specific-Vulnerabilities-Hunting.md` | Vuln-specific hunting state | Runtime |

### Testing Methodology
| # | File | Support Category | State Type |
|---|------|-----------------|-----------|
| 19 | `static-and-dynamic-testing.md` | Testing methodology state | Runtime |
| 20 | `to-identify-injection-and-reflected-point-during-testing.md` | Injection point tracking | Runtime |
| 21 | `Tools-Integration.md` | Tool integration state | Runtime |
| 22 | `user-functionality.md` | User functionality map | Runtime |
| 23 | `Vulnerability-Detection.md` | Vuln detection state | Runtime |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Framework State)

```json
{
  "schema_version": "1.0.0",
  "domain": "bug-bounty-support",
  "session_id": "sess_b1b2c3d4e5f6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "framework_state": {
    "active_frameworks": [
      {
        "framework_id": "fw_hunt_001",
        "source_file": "Core-Aspects-for-Bug-Security-Hunting.md",
        "status": "active",
        "phase": "reconnaissance",
        "started_at": "2026-06-26T09:00:00.000Z",
        "completed_phases": ["scope_validation", "asset_enumeration"],
        "current_phase_progress": 0.65
      }
    ],
    "tool_registry": {
      "nmap": {"version": "7.94", "status": "available", "last_used": "2026-06-26T10:00:00.000Z"},
      "nuclei": {"version": "3.1.0", "status": "available", "last_used": "2026-06-26T10:30:00.000Z"},
      "burpsuite": {"version": "2024.3", "status": "available", "last_used": "2026-06-26T11:00:00.000Z"},
      "subfinder": {"version": "2.6.3", "status": "available", "last_used": "2026-06-26T09:30:00.000Z"}
    },
    "methodology_state": {
      "reconnaissance": {"status": "in_progress", "checklist_complete": 12, "checklist_total": 20},
      "vulnerability_hunting": {"status": "pending", "checklist_complete": 0, "checklist_total": 15},
      "exploitation": {"status": "pending", "checklist_complete": 0, "checklist_total": 10},
      "reporting": {"status": "pending", "checklist_complete": 0, "checklist_total": 8}
    }
  },
  "hunting_state": {
    "injection_points": [
      {
        "point_id": "ip_001",
        "url": "https://example.com/search",
        "parameter": "q",
        "type": "reflected",
        "context": "HTML",
        "tested_payloads": 45,
        "confirmed_vuln": null
      }
    ],
    "parameters_tracked": {
      "total": 234,
      "tested": 89,
      "vulnerable": 3,
      "by_type": {
        "GET": 156,
        "POST": 67,
        "HEADER": 11
      }
    }
  },
  "reporting_state": {
    "findings_to_report": 3,
    "drafts_in_progress": 1,
    "submitted": 0,
    "pending_triage": 0
  }
}
```

### 3.2 MessagePack (Framework Execution Stream)

```python
import msgpack

# Framework execution event
event = {
    "event_type": "phase_transition",
    "framework_id": "fw_hunt_001",
    "from_phase": "reconnaissance",
    "to_phase": "vulnerability_hunting",
    "timestamp": time.time(),
    "duration_ms": 1800000,
    "findings_so_far": 2
}
packed = msgpack.packb(event, use_bin_type=True)
```

### 3.3 Protobuf (Cross-Session Framework Schema)

```protobuf
syntax = "proto3";
package support;

message FrameworkState {
  string session_id = 1;
  repeated ActiveFramework active_frameworks = 2;
  ToolRegistry tool_registry = 3;
  MethodologyState methodology = 4;
  HuntingState hunting = 5;
  ReportingState reporting = 6;
}

message ActiveFramework {
  string framework_id = 1;
  string source_file = 2;
  string status = 3;
  string phase = 4;
  int64 started_at = 5;
  repeated string completed_phases = 6;
  double phase_progress = 7;
}

message ToolRegistry {
  map<string, ToolInfo> tools = 1;
}

message ToolInfo {
  string version = 1;
  string status = 2;
  int64 last_used = 3;
}

message MethodologyState {
  map<string, PhaseState> phases = 1;
}

message PhaseState {
  string status = 1;
  int32 checklist_complete = 2;
  int32 checklist_total = 3;
}

message HuntingState {
  repeated InjectionPoint injection_points = 1;
  ParameterTracker parameters = 2;
}

message InjectionPoint {
  string point_id = 1;
  string url = 2;
  string parameter = 3;
  string type = 4;
  string context = 5;
  int32 tested_payloads = 6;
  string confirmed_vuln = 7;
}

message ParameterTracker {
  int32 total = 1;
  int32 tested = 2;
  int32 vulnerable = 3;
  map<string, int32> by_type = 4;
}

message ReportingState {
  int32 findings_to_report = 1;
  int32 drafts_in_progress = 2;
  int32 submitted = 3;
  int32 pending_triage = 4;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── bug-bounty-support/
        ├── {session_id}/
        │   ├── framework_state.json
        │   ├── hunting_state.json
        │   ├── reporting_state.json
        │   ├── tool_states/
        │   │   ├── burp_state.json
        │   │   ├── nuclei_state.json
        │   │   └── ...
        │   ├── methodology/
        │   │   ├── recon_checklist.json
        │   │   ├── hunting_checklist.json
        │   │   └── ...
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── tool_availability.json
            ├── methodology_templates.json
            ├── global_checklist_state.json
            └── framework_registry.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE framework_sessions (
    session_id TEXT NOT NULL,
    framework_id TEXT NOT NULL,
    source_file TEXT NOT NULL,
    status TEXT NOT NULL,
    current_phase TEXT NOT NULL,
    started_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL,
    state_blob BLOB NOT NULL,
    PRIMARY KEY (session_id, framework_id)
) WITHOUT ROWID;

CREATE TABLE hunting_results (
    result_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    point_id TEXT NOT NULL,
    url TEXT NOT NULL,
    parameter TEXT NOT NULL,
    vuln_type TEXT,
    confirmed INTEGER DEFAULT 0,
    payload_used TEXT,
    evidence TEXT,
    created_at INTEGER NOT NULL
);

CREATE TABLE methodology_checkpoints (
    checkpoint_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    methodology TEXT NOT NULL,
    phase TEXT NOT NULL,
    checklist_state BLOB NOT NULL,
    timestamp INTEGER NOT NULL,
    checksum TEXT NOT NULL
);

CREATE INDEX idx_framework_status ON framework_sessions(status);
CREATE INDEX idx_hunting_session ON hunting_results(session_id);
CREATE INDEX idx_hunting_vuln ON hunting_results(vuln_type);
```

---

## 5. State Snapshot Schema

### 5.1 Framework State Snapshot

```json
{
  "snapshot_type": "framework_state",
  "session_id": "sess_b1b2c3d4e5f6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "active_frameworks": 1,
  "methodology_progress": {
    "overall_percent": 35.0,
    "phases_completed": 2,
    "phases_total": 4,
    "current_phase": "vulnerability_hunting"
  },
  "tool_usage_summary": {
    "tools_used": 4,
    "total_executions": 45,
    "avg_execution_ms": 12000
  },
  "hunting_progress": {
    "injection_points_found": 15,
    "payloads_tested": 234,
    "vulns_confirmed": 3,
    "vulns_by_severity": {"HIGH": 1, "MEDIUM": 2, "LOW": 0}
  }
}
```

### 5.2 Hunting State Snapshot

```json
{
  "snapshot_type": "hunting_state",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "injection_points": {
    "total": 15,
    "by_type": {
      "reflected": 8,
      "stored": 3,
      "dom_based": 4
    },
    "tested": 12,
    "vulnerable": 3
  },
  "vuln_categories_hunted": {
    "xss": {"tested": 45, "found": 2},
    "sqli": {"tested": 30, "found": 1},
    "ssrf": {"tested": 20, "found": 0},
    "idor": {"tested": 25, "found": 0},
    "ssrf": {"tested": 15, "found": 0},
    "xxe": {"tested": 10, "found": 0},
    "ssti": {"tested": 8, "found": 0},
    "rce": {"tested": 5, "found": 0}
  }
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Framework phase transition | framework_state | HIGH |
| Methodology checkpoint | methodology_checkpoint | MEDIUM |
| Injection point discovered | hunting_state | MEDIUM |
| Vulnerability confirmed | hunting_state | HIGH |
| Tool execution complete | framework_state | LOW |
| Parameter tested | hunting_state | LOW |
| Finding ready for report | reporting_state | HIGH |
| Session end | All state | HIGH |
| Framework configuration change | framework_state | MEDIUM |

---

## 7. Restore Operations

### 7.1 Framework Restore

```python
def restore_framework_state(session_id):
    state = load_latest_snapshot(session_id, "framework_state")
    
    # Restore tool availability
    tool_state = load_shared("tool_availability.json")
    state["tool_registry"] = tool_state
    
    # Restore methodology progress
    checkpoints = load_checkpoints(session_id)
    for cp in checkpoints:
        state["methodology_state"][cp["methodology"]]["checklist_complete"] = cp["checklist_state"]["complete"]
    
    return state
```

### 7.2 Hunting State Restore

```python
def restore_hunting_state(session_id):
    state = load_latest_snapshot(session_id, "hunting_state")
    
    # Rebuild injection point list from DB
    points = query_db(
        "SELECT * FROM hunting_results WHERE session_id = ?",
        (session_id,)
    )
    state["injection_points"] = points
    
    return state
```

### 7.3 Cross-Domain State Restore

```python
def restore_support_for_domain(session_id, target_domain):
    support_state = restore_framework_state(session_id)
    
    # Provide tool availability to target domain
    available_tools = [
        t for t, info in support_state["tool_registry"].items()
        if info["status"] == "available"
    ]
    
    # Provide methodology context
    current_phase = support_state["methodology_state"]["current_phase"]
    
    return {
        "available_tools": available_tools,
        "current_phase": current_phase,
        "framework_context": support_state
    }
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Framework state | None | N/A |
| Hunting state | None | N/A |
| Checkpoint blobs | LZ4 | > 10KB |
| Tool state files | None | N/A |
| Methodology templates | None | N/A |

---

## 9. Encryption

| Data Classification | Required |
|--------------------|----------|
| Framework state | No |
| Hunting state | No |
| Tool configurations | No |
| Methodology templates | No |
| Reporting drafts | Optional (contains findings) |

---

## 10. Cross-Domain Coordination

### 10.1 State Sharing Protocol

The Support domain provides state to all other domains:

```python
class SupportDomainCoordinator:
    def provide_to_domain(self, target_domain, session_id):
        support_state = restore_framework_state(session_id)
        
        return {
            "tool_availability": support_state["tool_registry"],
            "methodology_phase": support_state["methodology_state"]["current_phase"],
            "hunting_context": restore_hunting_state(session_id),
            "reporting_context": support_state["reporting_state"],
            "ethical_guidelines": load_shared("ethical_guidelines.json")
        }
```

### 10.2 State Reception Protocol

The Support domain receives state from other domains:

```python
class SupportDomainReceiver:
    def receive_from_domain(self, source_domain, domain_state):
        if "findings" in domain_state:
            self.update_reporting_state(domain_state["findings"])
        
        if "tool_executions" in domain_state:
            self.update_tool_usage(domain_state["tool_executions"])
        
        if "new_injection_points" in domain_state:
            self.update_hunting_state(domain_state["new_injection_points"])
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `active_frameworks_count` | Gauge | > 3 |
| `methodology_progress_percent` | Gauge | Stalled > 2h |
| `tools_available_count` | Gauge | < 3 |
| `injection_points_found` | Counter | N/A (audit) |
| `vulns_confirmed_count` | Counter | N/A (audit) |
| `reporting_backlog` | Gauge | > 5 |

---

## Appendix A: Complete File Reference

All 23 domain files:

1. `Advanced-Bug-Bounty-Prompt.md` → Advanced prompt framework state, configuration
2. `Advanced-Bug-Security-Hunting-Prompt.md` → Security hunting framework state
3. `Advanced-Information-Disclosure-Analysis-Prompt.md` → Info disclosure analysis state
4. `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` → JS vulnerability analysis state
5. `Advanced-Techniques.md` → Advanced techniques registry, technique availability
6. `Burp-AI.md` → Burp Suite AI integration state, session state
7. `Chaining.md` → Chaining methodology state, chain templates
8. `Core-Aspects-for-Bug-Security-Hunting.md` → Core hunting framework, methodology state
9. `debuging-using-browser-console-and-vscode-for-hunting.md` → Debug workflow state, breakpoints
10. `Ethical-Guidelines.md` → Ethics compliance state, scope boundaries
11. `Exploitation.md` → Exploitation framework state, exploit inventory
12. `JavaScript-Identification-Deobfuscation.md` → JS analysis state, deobfuscation progress
13. `manual-testing-scope.md` → Manual testing scope, test plan state
14. `parameters.md` → Parameter tracking state, parameter inventory
15. `PoC-Development.md` → PoC development state, draft progress
16. `Reconnaissance.md` → Recon methodology state, recon progress
17. `Reporting.md` → Report template state, report drafts
18. `Specific-Vulnerabilities-Hunting.md` → Vuln-specific hunting state, hunt progress
19. `static-and-dynamic-testing.md` → Testing methodology state, test execution state
20. `to-identify-injection-and-reflected-point-during-testing.md` → Injection point tracking state
21. `Tools-Integration.md` → Tool integration state, tool availability
22. `user-functionality.md` → User functionality map, feature coverage state
23. `Vulnerability-Detection.md` → Vuln detection state, detection progress
