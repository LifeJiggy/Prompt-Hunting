# State Persistence: Specialized Targets Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Specialized Targets |
| **Directory** | `Specialized-Targets/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/specialized-targets.md` |
| **Serialization** | JSON (primary), MessagePack (category stream), Protobuf (target archive) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Specialized Targets domain. This domain contains 50 specialized security assessment modules covering unique target categories — IoT devices, mobile applications, cloud infrastructure, blockchain/DeFi, medical devices, industrial control systems, and industry-specific platforms.

Each specialized target category has unique persistence requirements: IoT firmware state, mobile app analysis state, cloud resource inventory, smart contract audit state, and industry compliance state. The persistence layer captures category-specific findings, assessment progress, and cross-category intelligence.

---

## 2. Domain File Registry

All 50 domain files organized by target category:

### IoT and Embedded
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 01 | `01-IoT-Device-Security.md` | IoT devices | Runtime |
| 24 | `24-Connected-Vehicle-Security.md` | Connected vehicles | Runtime |
| 25 | `25-Autonomous-System-Security.md` | Autonomous systems | Runtime |
| 26 | `26-Industrial-Control-System-Security.md` | ICS/SCADA | Runtime |
| 27 | `27-Medical-Device-Security.md` | Medical devices | Runtime |
| 28 | `28-Wearable-Technology-Security.md` | Wearables | Runtime |
| 29 | `29-Smart-Home-Device-Security.md` | Smart home | Runtime |
| 30 | `30-Embedded-System-Security.md` | Embedded systems | Runtime |
| 31 | `31-Real-Time-Operating-System-Security.md` | RTOS | Runtime |
| 32 | `32-Firmware-Security-Analysis.md` | Firmware | Runtime |
| 33 | `33-Network-Device-Security.md` | Network devices | Runtime |
| 34 | `34-Telecommunication-System-Security.md` | Telecom | Runtime |
| 35 | `35-Satellite-Communication-Security.md` | Satellite | Runtime |

### Mobile and Cloud
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 02 | `02-Mobile-Application-Testing.md` | Mobile apps | Runtime |
| 03 | `03-Cloud-Infrastructure-Security.md` | Cloud infra | Runtime |
| 04 | `04-Container-Security.md` | Containers | Runtime |
| 05 | `05-Kubernetes-Cluster-Security.md` | Kubernetes | Runtime |

### Blockchain and Web3
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 06 | `06-Blockchain-Smart-Contracts.md` | Smart contracts | Runtime |
| 07 | `07-DeFi-Protocol-Security.md` | DeFi protocols | Runtime |
| 08 | `08-NFT-Marketplace-Security.md` | NFT marketplaces | Runtime |
| 09 | `09-Web3-Application-Security.md` | Web3 apps | Runtime |
| 10 | `10-Cryptocurrency-Exchange-Security.md` | Crypto exchanges | Runtime |

### Industry-Specific Platforms
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 11 | `11-Traditional-Finance-API-Security.md` | Finance API | Runtime |
| 12 | `12-Healthcare-System-Security.md` | Healthcare | Runtime |
| 13 | `13-Financial-Institution-Security.md` | Financial inst. | Runtime |
| 14 | `14-Government-System-Security.md` | Government | Runtime |
| 15 | `15-Education-Platform-Security.md` | Education | Runtime |
| 16 | `16-E-commerce-Platform-Security.md` | E-commerce | Runtime |
| 17 | `17-Social-Media-Platform-Security.md` | Social media | Runtime |
| 18 | `18-Content-Management-System-Security.md` | CMS | Runtime |
| 19 | `19-Learning-Management-System-Security.md` | LMS | Runtime |
| 20 | `20-Human-Resources-System-Security.md` | HR systems | Runtime |
| 21 | `21-Supply-Chain-Management-Security.md` | Supply chain | Runtime |
| 22 | `22-Manufacturing-Control-System-Security.md` | Manufacturing | Runtime |
| 23 | `23-Smart-Building-Automation.md` | Smart building | Runtime |

### Critical Infrastructure
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 36 | `36-Air-Traffic-Control-System-Security.md` | ATC | Runtime |
| 37 | `37-Power-Grid-Security.md` | Power grid | Runtime |
| 38 | `38-Water-Treatment-Facility-Security.md` | Water treatment | Runtime |
| 39 | `39-Transportation-System-Security.md` | Transportation | Runtime |
| 40 | `40-Energy-Management-System-Security.md` | Energy management | Runtime |

### Organization-Specific
| # | File | Target Category | State Type |
|---|------|----------------|-----------|
| 41 | `41-Research-Institution-Security.md` | Research inst. | Runtime |
| 42 | `42-Non-Profit-Organization-Security.md` | Non-profit | Runtime |
| 43 | `43-Startup-Company-Security.md` | Startups | Runtime |
| 44 | `44-Enterprise-Corporate-Security.md` | Enterprise | Runtime |
| 45 | `45-Fortune-500-Company-Security.md` | Fortune 500 | Runtime |
| 46 | `46-Open-Source-Project-Security.md` | Open source | Runtime |
| 47 | `47-Academic-Research-Security.md` | Academic | Runtime |
| 48 | `48-International-Organization-Security.md` | Int'l orgs | Runtime |
| 49 | `49-Developing-Country-Infrastructure.md` | Developing infra | Runtime |
| 50 | `50-Global-Scale-System-Security.md` | Global systems | Runtime |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Category Assessment)

```json
{
  "schema_version": "1.0.0",
  "domain": "specialized-targets",
  "session_id": "sess_sp1sp2sp3sp4",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "category_assessments": {
    "iot_devices": {
      "module_source": "01-IoT-Device-Security.md",
      "status": "in_progress",
      "target_count": 5,
      "assessed": 2,
      "findings": [
        {
          "finding_id": "spf_001",
          "target": "Smart Camera Model X",
          "vuln_class": "hardcoded_credentials",
          "severity": "CRITICAL",
          "description": "Default root:root credentials in firmware",
          "evidence": {
            "firmware_version": "2.1.4",
            "credential_location": "/etc/shadow",
            "extraction_method": "firmware_unpack"
          }
        }
      ],
      "assessment_state": {
        "firmware_extracted": 3,
        "firmware_analyzed": 1,
        "network_scanned": 5,
        "protocol_tested": 2
      }
    },
    "cloud_infrastructure": {
      "module_source": "03-Cloud-Infrastructure-Security.md",
      "status": "completed",
      "target_count": 3,
      "assessed": 3,
      "findings": [
        {
          "finding_id": "spf_002",
          "target": "AWS Account",
          "vuln_class": "s3_public_bucket",
          "severity": "HIGH",
          "description": "Public S3 bucket with sensitive data"
        }
      ],
      "resource_inventory": {
        "s3_buckets": 12,
        "ec2_instances": 5,
        "lambda_functions": 23,
        "iam_roles": 15,
        "public_resources": 2
      }
    },
    "smart_contracts": {
      "module_source": "06-Blockchain-Smart-Contracts.md",
      "status": "pending",
      "target_count": 2,
      "assessed": 0,
      "findings": [],
      "audit_state": {
        "contracts_analyzed": 0,
        "functions_tested": 0,
        "tests_written": 0
      }
    }
  },
  "cross_category_intel": {
    "shared_patterns": [
      {
        "pattern": "hardcoded_credentials",
        "found_in_categories": ["iot_devices", "cloud_infrastructure", "industrial_control"],
        "total_instances": 8
      }
    ],
    "category_correlations": [
      {
        "categories": ["iot_devices", "smart_home"],
        "correlation": "shared_firmware_components",
        "strength": 0.85
      }
    ]
  },
  "target_priority": {
    "high_priority": [
      {"target": "Smart Camera Model X", "category": "iot_devices", "reason": "hardcoded_creds_rce_chain"},
      {"target": "AWS Account", "category": "cloud_infrastructure", "reason": "public_data_exposure"}
    ],
    "medium_priority": [
      {"target": "DeFi Protocol Y", "category": "smart_contracts", "reason": "high_tvl_unaudited"}
    ]
  }
}
```

### 3.2 MessagePack (Category Assessment Stream)

```python
import msgpack

# Category assessment event
assessment_event = {
    "event": "target_assessed",
    "category": "iot_devices",
    "target": "Smart Camera Model X",
    "findings_count": 3,
    "severity_max": "CRITICAL",
    "timestamp": time.time()
}
packed = msgpack.packb(assessment_event, use_bin_type=True)
```

### 3.3 Protobuf (Target Archive Schema)

```protobuf
syntax = "proto3";
package specialized;

message CategoryAssessment {
  string category = 1;
  string module_source = 2;
  string status = 3;
  int32 target_count = 4;
  int32 assessed = 5;
  repeated TargetFinding findings = 6;
  map<string, int32> assessment_state = 7;
  ResourceInventory resources = 8;
}

message TargetFinding {
  string finding_id = 1;
  string target = 2;
  string vuln_class = 3;
  string severity = 4;
  string description = 5;
  map<string, string> evidence = 6;
  int64 discovered_at = 7;
}

message ResourceInventory {
  map<string, int32> counts = 1;
  int32 public_resources = 2;
  int32 total_resources = 3;
}

message CrossCategoryIntel {
  repeated SharedPattern patterns = 1;
  repeated CategoryCorrelation correlations = 2;
}

message SharedPattern {
  string pattern = 1;
  repeated string found_in_categories = 2;
  int32 total_instances = 3;
}

message CategoryCorrelation {
  repeated string categories = 1;
  string correlation = 2;
  double strength = 3;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── specialized-targets/
        ├── {session_id}/
        │   ├── category_assessments.json
        │   ├── cross_category_intel.json
        │   ├── target_priority.json
        │   ├── by_category/
        │   │   ├── iot_devices.json
        │   │   ├── cloud_infrastructure.json
        │   │   ├── smart_contracts.json
        │   │   └── ...
        │   ├── findings/
        │   │   ├── spf_001.json
        │   │   ├── spf_002.json
        │   │   └── ...
        │   ├── artifacts/
        │   │   ├── firmware_dumps/
        │   │   ├── contract_code/
        │   │   ├── screenshots/
        │   │   └── ...
        │   └── checkpoints/
        │       ├── cp_001.msgpack
        │       └── cp_latest.msgpack
        └── shared/
            ├── global_category_index.json
            ├── cross_category_patterns.json
            ├── compliance_requirements.json
            └── industry_benchmarks.json
```

### 4.2 SQLite WAL

```sql
CREATE TABLE category_assessments (
    category TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    module_source TEXT NOT NULL,
    status TEXT NOT NULL,
    target_count INTEGER NOT NULL,
    assessed INTEGER NOT NULL,
    findings_count INTEGER DEFAULT 0,
    assessment_state BLOB,
    updated_at INTEGER NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE specialized_findings (
    finding_id TEXT PRIMARY KEY,
    session_id TEXT NOT NULL,
    category TEXT NOT NULL,
    target TEXT NOT NULL,
    vuln_class TEXT NOT NULL,
    severity TEXT NOT NULL,
    description TEXT NOT NULL,
    evidence_blob BLOB,
    discovered_at INTEGER NOT NULL,
    status TEXT NOT NULL DEFAULT 'discovered',
    FOREIGN KEY (category) REFERENCES category_assessments(category)
);

CREATE TABLE target_profiles (
    target_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id TEXT NOT NULL,
    category TEXT NOT NULL,
    target_name TEXT NOT NULL,
    target_type TEXT,
    ip_address TEXT,
    url TEXT,
    firmware_version TEXT,
    cloud_provider TEXT,
    contract_address TEXT,
    profile_blob BLOB NOT NULL,
    discovered_at INTEGER NOT NULL
);

CREATE INDEX idx_findings_category ON specialized_findings(category);
CREATE INDEX idx_findings_severity ON specialized_findings(severity);
CREATE INDEX idx_targets_category ON target_profiles(category);
```

---

## 5. State Snapshot Schema

### 5.1 Category Assessment Snapshot

```json
{
  "snapshot_type": "category_assessment",
  "session_id": "sess_sp1sp2sp3sp4",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "categories_active": 5,
  "categories_completed": 2,
  "categories_pending": 43,
  "total_targets": 15,
  "targets_assessed": 5,
  "total_findings": 12,
  "findings_by_severity": {
    "CRITICAL": 2,
    "HIGH": 5,
    "MEDIUM": 4,
    "LOW": 1
  },
  "top_findings": [
    {"finding_id": "spf_001", "category": "iot_devices", "severity": "CRITICAL", "title": "Hardcoded root credentials in firmware"}
  ]
}
```

### 5.2 Cross-Category Intelligence Snapshot

```json
{
  "snapshot_type": "cross_category_intel",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "shared_patterns_count": 8,
  "category_correlations_count": 5,
  "top_shared_patterns": [
    {"pattern": "hardcoded_credentials", "categories": 3, "instances": 8},
    {"pattern": "default_config", "categories": 4, "instances": 12},
    {"pattern": "insecure_update_mechanism", "categories": 2, "instances": 4}
  ],
  "target_priority_changes": [
    {"target": "Smart Camera Model X", "priority_change": "increased", "reason": "rce_chain_confirmed"}
  ]
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Category assessment started | category_assessment | MEDIUM |
| Category assessment completed | category_assessment | HIGH |
| Target profile created | target_profiles | MEDIUM |
| Finding discovered | specialized_findings | CRITICAL |
| Cross-category pattern identified | cross_category_intel | HIGH |
| Firmware extracted | category_assessment | MEDIUM |
| Smart contract audited | category_assessment | HIGH |
| Resource inventory updated | category_assessment | MEDIUM |
| Target priority changed | target_priority | HIGH |
| Session end | All state | HIGH |

---

## 7. Restore Operations

```python
def restore_specialized_state(session_id):
    assessments = load_latest_snapshot(session_id, "category_assessments")
    intel = load_latest_snapshot(session_id, "cross_category_intel")
    
    # Restore category-specific state
    for category in assessments:
        category_state = load_json(f"state/specialized-targets/{session_id}/by_category/{category}.json")
        assessments[category]["detailed_state"] = category_state
    
    # Restore findings
    findings = query_db(
        "SELECT * FROM specialized_findings WHERE session_id = ? ORDER BY discovered_at",
        (session_id,)
    )
    
    return SpecializedState(
        assessments=assessments,
        intel=intel,
        findings=findings
    )

def restore_for_category(session_id, category):
    assessment = query_db(
        "SELECT * FROM category_assessments WHERE category = ? AND session_id = ?",
        (category, session_id)
    )
    findings = query_db(
        "SELECT * FROM specialized_findings WHERE category = ? AND session_id = ?",
        (category, session_id)
    )
    return CategoryState(assessment=assessment, findings=findings)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold |
|-----------|-----------|-----------|
| Category assessments | None | N/A |
| Firmware dumps | xz | Always (very large) |
| Smart contract code | None | N/A |
| Screenshots | None | Already compressed |
| Resource inventories | None | N/A |
| Checkpoint blobs | LZ4 | > 10KB |

---

## 9. Encryption

| Data Classification | Required | Notes |
|--------------------|----------|-------|
| IoT firmware data | Optional | May contain proprietary info |
| Cloud resource data | Optional | Contains infrastructure details |
| Smart contract audits | Optional | May reveal pre-disclosure vulns |
| Healthcare data | Required | HIPAA compliance |
| Financial data | Required | PCI-DSS compliance |
| Government data | Required | Classification requirements |

---

## 10. Category-Specific State Management

### 10.1 IoT Firmware State

```python
class IoTState:
    def track_firmware(self, target, firmware_path, extraction_method):
        state = {
            "target": target,
            "firmware_path": firmware_path,
            "extraction_method": extraction_method,
            "extracted_at": datetime.utcnow().isoformat(),
            "filesystem_extracted": False,
            "credentials_found": [],
            "hardcoded_urls": [],
            "vulnerable_services": []
        }
        self.save_iot_state(target, state)
```

### 10.2 Smart Contract Audit State

```python
class SmartContractState:
    def track_audit(self, contract_address, network):
        state = {
            "contract_address": contract_address,
            "network": network,
            "source_code_retrieved": False,
            "compiler_version": None,
            "functions_total": 0,
            "functions_audited": 0,
            "tests_written": 0,
            "tests_passing": 0,
            "findings": [],
            "slither_report": None,
            "mythril_report": None
        }
        self.save_contract_state(contract_address, state)
```

### 10.3 Cloud Resource State

```python
class CloudState:
    def track_resources(self, provider, session_id):
        if provider == "aws":
            return self.track_aws_resources(session_id)
        elif provider == "gcp":
            return self.track_gcp_resources(session_id)
        elif provider == "azure":
            return self.track_azure_resources(session_id)
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `categories_assessed_count` | Gauge | N/A (audit) |
| `total_specialized_findings` | Gauge | N/A (audit) |
| `critical_findings_unreported` | Gauge | > 0 (immediate) |
| `firmware_analysis_duration_min` | Histogram | > 60min |
| `contract_audit_coverage` | Gauge | < 50% |
| `cloud_resource_public_count` | Gauge | > 0 (alert) |
| `cross_category_pattern_count` | Counter | N/A (audit) |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `01-IoT-Device-Security.md` → IoT assessment state, firmware analysis, device inventory
2. `02-Mobile-Application-Testing.md` → Mobile assessment state, app analysis, API inventory
3. `03-Cloud-Infrastructure-Security.md` → Cloud assessment state, resource inventory, IAM state
4. `04-Container-Security.md` → Container assessment state, image inventory, runtime state
5. `05-Kubernetes-Cluster-Security.md` → K8s assessment state, cluster inventory, RBAC state
6. `06-Blockchain-Smart-Contracts.md` → Smart contract audit state, contract inventory
7. `07-DeFi-Protocol-Security.md` → DeFi audit state, protocol inventory, TVL tracking
8. `08-NFT-Marketplace-Security.md` → NFT marketplace assessment, contract state
9. `09-Web3-Application-Security.md` → Web3 app assessment, dApp state
10. `10-Cryptocurrency-Exchange-Security.md` → Exchange assessment state, wallet inventory
11. `11-Traditional-Finance-API-Security.md` → Finance API assessment, endpoint inventory
12. `12-Healthcare-System-Security.md` → Healthcare assessment state, PHI handling state
13. `13-Financial-Institution-Security.md` → Financial assessment state, compliance state
14. `14-Government-System-Security.md` → Government assessment state, classification state
15. `15-Education-Platform-Security.md` → Education platform assessment, student data state
16. `16-E-commerce-Platform-Security.md` → E-commerce assessment, payment state, cart state
17. `17-Social-Media-Platform-Security.md` → Social media assessment, privacy state
18. `18-Content-Management-System-Security.md` → CMS assessment, plugin state, theme state
19. `19-Learning-Management-System-Security.md` → LMS assessment, course data state
20. `20-Human-Resources-System-Security.md` → HR system assessment, PII state
21. `21-Supply-Chain-Management-Security.md` → Supply chain assessment, vendor state
22. `22-Manufacturing-Control-System-Security.md` → Manufacturing assessment, PLC state
23. `23-Smart-Building-Automation.md` → Smart building assessment, BMS state
24. `24-Connected-Vehicle-Security.md` → Vehicle assessment, CAN bus state, telematics state
25. `25-Autonomous-System-Security.md` → Autonomous system assessment, sensor state
26. `26-Industrial-Control-System-Security.md` → ICS assessment, SCADA state, protocol state
27. `27-Medical-Device-Security.md` → Medical device assessment, FDA compliance state
28. `28-Wearable-Technology-Security.md` → Wearable assessment, BLE state, sensor state
29. `29-Smart-Home-Device-Security.md` → Smart home assessment, hub state, device mesh
30. `30-Embedded-System-Security.md` → Embedded assessment, JTAG state, debug state
31. `31-Real-Time-Operating-System-Security.md` → RTOS assessment, task state, memory state
32. `32-Firmware-Security-Analysis.md` → Firmware analysis state, unpack state, binary state
33. `33-Network-Device-Security.md` → Network device assessment, config state, firmware state
34. `34-Telecommunication-System-Security.md` → Telecom assessment, signaling state
35. `35-Satellite-Communication-Security.md` → Satellite assessment, ground station state
36. `36-Air-Traffic-Control-System-Security.md` → ATC assessment, protocol state
37. `37-Power-Grid-Security.md` → Power grid assessment, SCADA state, relay state
38. `38-Water-Treatment-Facility-Security.md` → Water treatment assessment, PLC state
39. `39-Transportation-System-Security.md` → Transportation assessment, traffic state
40. `40-Energy-Management-System-Security.md` → Energy management assessment, grid state
41. `41-Research-Institution-Security.md` → Research assessment, data state, compliance state
42. `42-Non-Profit-Organization-Security.md` → Non-profit assessment, donor state
43. `43-Startup-Company-Security.md` → Startup assessment, growth state, tech debt state
44. `44-Enterprise-Corporate-Security.md` → Enterprise assessment, AD state, compliance state
45. `45-Fortune-500-Company-Security.md` → Fortune 500 assessment, global state
46. `46-Open-Source-Project-Security.md` → OSS assessment, dependency state, maintainer state
47. `47-Academic-Research-Security.md` → Academic assessment, IRB state, data state
48. `48-International-Organization-Security.md` → Int'l org assessment, multi-jurisdiction state
49. `49-Developing-Country-Infrastructure.md` → Developing infra assessment, resource state
50. `50-Global-Scale-System-Security.md` → Global system assessment, distributed state
