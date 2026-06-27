# State Persistence: Bug Bounty Program Strategy Domain

## Domain Identity

| Field | Value |
|-------|-------|
| **Domain** | Bug Bounty Program Strategy |
| **Directory** | `Bug-Bounty-Program-Strategy/` |
| **File Count** | 50 files + README + registry.json |
| **Persistence Layer** | `session-managements/persistence/bug-bounty-program-strategy.md` |
| **Serialization** | JSON (primary), MessagePack (time logs), Protobuf (program profiles) |
| **Storage Backend** | Filesystem + SQLite WAL |

---

## 1. Overview

This document defines the **state persistence architecture** for the Bug Bounty Program Strategy domain. This domain manages program selection intelligence, time investment tracking, ROI analysis, reward optimization, and long-term program relationship data. The persistence layer captures program scores, time logs, reward histories, competitive intelligence, and strategic metrics.

Strategy persistence enables data-driven program selection, historical trend analysis, and optimization of time-to-reward ratios across all target programs.

---

## 2. Domain File Registry

All 50 domain files organized by strategy category:

### Program Selection and Evaluation
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 01 | `01-Program-Selection-Criteria.md` | Selection framework | Persistent |
| 02 | `02-Time-Management-Optimization.md` | Time allocation state | Runtime |
| 03 | `03-ROI-Maximization-Strategies.md` | ROI calculations | Persistent |
| 04 | `04-Program-Reputation-Analysis.md` | Reputation scores | Persistent |
| 05 | `05-Reward-Structure-Evaluation.md` | Reward analysis | Persistent |

### Scope and Response Intelligence
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 06 | `06-Scope-Assessment-Techniques.md` | Scope analysis cache | Persistent |
| 07 | `07-Response-Time-Analysis.md` | Response time DB | Persistent |
| 08 | `08-Collaboration-Opportunities.md` | Collab state | Runtime |
| 09 | `09-Private-vs-Public-Programs.md` | Program type analysis | Persistent |
| 10 | `10-VDI-Program-Strategy.md` | VDI-specific state | Persistent |

### Program Intelligence
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 11 | `11-Seasonal-Program-Analysis.md` | Seasonal patterns | Persistent |
| 12 | `12-Program-Maturity-Assessment.md` | Maturity scores | Persistent |
| 13 | `13-Reward-Trends-Analysis.md` | Reward trend data | Persistent |
| 14 | `14-Program-Scope-Expansion.md` | Scope change tracker | Persistent |
| 15 | `15-Communication-Channel-Optimization.md` | Communication state | Runtime |

### Submission and Deduplication
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 16 | `16-Duplicate-Submission-Avoidance.md` | Dedup index | Persistent |
| 17 | `17-Program-Specific-Rules.md` | Rule cache | Persistent |
| 18 | `18-Reward-Negotiation-Tactics.md` | Negotiation state | Runtime |
| 19 | `19-Program-Health-Monitoring.md` | Health metrics | Runtime |
| 20 | `20-Long-Term-Program-Relationships.md` | Relationship state | Persistent |

### Program Launch and Competition
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 21 | `21-Program-Launch-Strategy.md` | Launch state | Runtime |
| 22 | `22-Competition-Analysis.md` | Competitor intel | Persistent |
| 23 | `23-Program-Specialization.md` | Specialization state | Persistent |
| 24 | `24-Risk-Assessment-Per-Program.md` | Risk scores | Persistent |
| 25 | `25-Time-Zone-Optimization.md` | Timezone scheduling | Runtime |

### Strategic Analysis
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 26 | `26-Program-Diversity-Strategy.md` | Portfolio state | Persistent |
| 27 | `27-Reward-Consistency-Analysis.md` | Consistency metrics | Persistent |
| 28 | `28-Program-Exit-Strategy.md` | Exit criteria state | Persistent |
| 29 | `29-Program-Feedback-Analysis.md` | Feedback DB | Persistent |
| 30 | `30-Advanced-Program-Intelligence.md` | Intelligence cache | Persistent |

### Network and Influence
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 31 | `31-Program-Network-Analysis.md` | Network graph | Persistent |
| 32 | `32-Collaboration-Network-Building.md` | Collab network state | Persistent |
| 33 | `33-Program-Influence-Strategies.md` | Influence state | Persistent |
| 34 | `34-Reward-Prediction-Models.md` | Prediction model state | Persistent |
| 35 | `35-Program-Saturation-Analysis.md` | Saturation metrics | Persistent |

### Advanced Strategy
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 36 | `36-Seasoned-Hunter-Advantages.md` | Advantage tracking | Persistent |
| 37 | `37-Program-Trend-Forecasting.md` | Trend model state | Persistent |
| 38 | `38-Resource-Allocation-Strategy.md` | Resource allocation | Runtime |
| 39 | `39-Program-Success-Metrics.md` | Success metrics | Persistent |
| 40 | `40-Advanced-Program-Selection.md` | Advanced selection model | Persistent |

### Relationship Management
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 41 | `41-Program-Relationship-Management.md` | Relationship state | Persistent |
| 42 | `42-Collaboration-ROI-Analysis.md` | Collab ROI metrics | Persistent |
| 43 | `43-Program-Discovery-Methods.md` | Discovery state | Runtime |
| 44 | `44-Advanced-Scope-Analysis.md` | Scope depth analysis | Persistent |
| 45 | `45-Program-Performance-Tracking.md` | Performance DB | Persistent |

### Framework and Optimization
| # | File | Strategy Category | State Type |
|---|------|------------------|-----------|
| 46 | `46-Reward-Maximization-Framework.md` | Framework state | Persistent |
| 47 | `47-Program-Specialization-Deep-Dive.md` | Deep analysis state | Persistent |
| 48 | `48-Time-Investment-ROI.md` | Time ROI metrics | Persistent |
| 49 | `49-Program-Network-Optimization.md` | Network optimization | Persistent |
| 50 | `50-Advanced-Program-Strategy.md` | Master strategy state | Persistent |

### Meta Files
| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | File index and metadata |

---

## 3. Serialization Formats

### 3.1 JSON (Primary — Program Profiles)

```json
{
  "schema_version": "1.0.0",
  "domain": "bug-bounty-program-strategy",
  "session_id": "sess_s1t2u3v4w5x6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "program_profiles": {
    "program_example": {
      "program_id": "prog_001",
      "name": "Example Corp Bug Bounty",
      "platform": "hackerone",
      "type": "public",
      "status": "active",
      "scores": {
        "overall_score": 8.5,
        "reward_score": 9.0,
        "scope_score": 7.5,
        "response_score": 8.0,
        "reputation_score": 9.0,
        "competition_score": 6.5
      },
      "scope": {
        "domains": ["*.example.com"],
        "wildcard": true,
        "exclusions": ["admin.example.com"],
        "asset_types": ["web", "api", "mobile"]
      },
      "rewards": {
        "critical_range": [2000, 5000],
        "high_range": [500, 1500],
        "medium_range": [100, 500],
        "low_range": [25, 100],
        "avg_paid": 875,
        "total_paid": 45000
      },
      "metrics": {
        "avg_response_time_hours": 48,
        "avg_fix_time_days": 14,
        "submissions_total": 523,
        "my_submissions": 12,
        "my_paid": 8,
        "my_total_reward": 7200,
        "my_avg_reward": 900
      },
      "time_log": {
        "total_hours": 45.5,
        "hours_this_month": 12.0,
        "last_hunted": "2026-06-25T18:00:00.000Z"
      },
      "roi": {
        "reward_per_hour": 158.24,
        "cost_per_finding": 5.69,
        "effective_hourly_rate": 158.24
      }
    }
  },
  "portfolio": {
    "total_programs": 15,
    "active_programs": 12,
    "total_investment_hours": 234.5,
    "total_rewards_earned": 32500,
    "portfolio_hourly_rate": 138.59
  }
}
```

### 3.2 MessagePack (Time Logs — High-Frequency)

```python
import msgpack

# Time log entry for real-time tracking
time_entry = {
    "program_id": "prog_001",
    "activity": "scanning",
    "target": "*.example.com",
    "start_time": time.time(),
    "end_time": None,
    "findings_discovered": 0,
    "notes": "initial recon"
}
packed = msgpack.packb(time_entry, use_bin_type=True)
```

### 3.3 Protobuf (Program Profile Schema)

```protobuf
syntax = "proto3";
package strategy;

message ProgramProfile {
  string program_id = 1;
  string name = 2;
  string platform = 3;
  ProgramType type = 4;
  ProgramStatus status = 5;
  ProgramScores scores = 6;
  ProgramScope scope = 7;
  RewardStructure rewards = 8;
  ProgramMetrics metrics = 9;
  TimeLog time_log = 10;
  ROIAnalysis roi = 11;
}

enum ProgramType {
  UNKNOWN_TYPE = 0;
  PUBLIC = 1;
  PRIVATE = 2;
  VDP = 3;
}

enum ProgramStatus {
  UNKNOWN_STATUS = 0;
  ACTIVE = 1;
  PAUSED = 2;
  ENDED = 3;
  INVITE_ONLY = 4;
}

message ProgramScores {
  double overall = 1;
  double reward = 2;
  double scope = 3;
  double response = 4;
  double reputation = 5;
  double competition = 6;
}

message ProgramScope {
  repeated string domains = 1;
  bool wildcard = 2;
  repeated string exclusions = 3;
  repeated string asset_types = 4;
}

message RewardStructure {
  int32 critical_min = 1;
  int32 critical_max = 2;
  int32 high_min = 3;
  int32 high_max = 4;
  int32 medium_min = 5;
  int32 medium_max = 6;
  int32 low_min = 7;
  int32 low_max = 8;
  double avg_paid = 9;
  int32 total_paid = 10;
}

message ProgramMetrics {
  int32 avg_response_time_hours = 1;
  int32 avg_fix_time_days = 2;
  int32 submissions_total = 3;
  int32 my_submissions = 4;
  int32 my_paid = 5;
  int32 my_total_reward = 6;
  double my_avg_reward = 7;
}

message TimeLog {
  double total_hours = 1;
  double hours_this_month = 2;
  int64 last_hunted = 3;
}

message ROIAnalysis {
  double reward_per_hour = 1;
  double cost_per_finding = 2;
  double effective_hourly_rate = 3;
}
```

---

## 4. Storage Backends

### 4.1 Filesystem

```
session-managements/
└── state/
    └── bug-bounty-strategy/
        ├── {session_id}/
        │   ├── program_scores.json
        │   ├── time_logs/
        │   │   ├── time_log_2026-06-26.msgpack
        │   │   └── ...
        │   ├── portfolio.json
        │   ├── roi_analysis.json
        │   └── session_notes.json
        └── shared/
            ├── program_registry.json      # All known programs
            ├── reward_history.json        # Historical rewards
            ├── time_investment_db.json    # Cumulative time logs
            ├── competition_intel.json     # Competitor analysis
            ├── trend_data.json            # Trend analysis data
            └── relationship_state.json    # Program relationships
```

### 4.2 SQLite WAL

```sql
CREATE TABLE program_profiles (
    program_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    platform TEXT NOT NULL,
    type TEXT NOT NULL,
    status TEXT NOT NULL,
    scores_blob BLOB NOT NULL,
    scope_blob BLOB NOT NULL,
    rewards_blob BLOB NOT NULL,
    updated_at INTEGER NOT NULL,
    checksum TEXT NOT NULL
);

CREATE TABLE time_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    program_id TEXT NOT NULL,
    session_id TEXT NOT NULL,
    activity TEXT NOT NULL,
    target TEXT,
    start_time INTEGER NOT NULL,
    end_time INTEGER,
    duration_minutes REAL,
    findings_discovered INTEGER DEFAULT 0,
    notes TEXT,
    FOREIGN KEY (program_id) REFERENCES program_profiles(program_id)
);

CREATE TABLE reward_history (
    reward_id INTEGER PRIMARY KEY AUTOINCREMENT,
    program_id TEXT NOT NULL,
    finding_id TEXT,
    amount REAL NOT NULL,
    currency TEXT NOT NULL DEFAULT 'USD',
    severity TEXT NOT NULL,
    paid_at INTEGER NOT NULL,
    submission_date INTEGER NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program_profiles(program_id)
);

CREATE TABLE program_snapshots (
    snapshot_id INTEGER PRIMARY KEY AUTOINCREMENT,
    program_id TEXT NOT NULL,
    session_id TEXT NOT NULL,
    timestamp INTEGER NOT NULL,
    snapshot_data BLOB NOT NULL,
    FOREIGN KEY (program_id) REFERENCES program_profiles(program_id)
);

CREATE INDEX idx_time_logs_program ON time_logs(program_id);
CREATE INDEX idx_time_logs_session ON time_logs(session_id);
CREATE INDEX idx_rewards_program ON reward_history(program_id);
CREATE INDEX idx_rewards_date ON reward_history(paid_at);
```

---

## 5. State Snapshot Schema

### 5.1 Program Score Snapshot

```json
{
  "snapshot_type": "program_scores",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "programs_ranked": [
    {
      "rank": 1,
      "program_id": "prog_001",
      "overall_score": 8.5,
      "trend": "stable",
      "recommendation": "high_priority"
    },
    {
      "rank": 2,
      "program_id": "prog_003",
      "overall_score": 8.2,
      "trend": "improving",
      "recommendation": "increasing_investment"
    }
  ],
  "score_changes": [
    {
      "program_id": "prog_002",
      "old_score": 7.8,
      "new_score": 8.0,
      "reason": "scope_expansion"
    }
  ]
}
```

### 5.2 Time Investment Snapshot

```json
{
  "snapshot_type": "time_investment",
  "session_id": "sess_s1t2u3v4w5x6",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "session_time": {
    "total_minutes": 345,
    "by_activity": {
      "scanning": 180,
      "analysis": 90,
      "report_writing": 45,
      "recon": 30
    },
    "by_program": {
      "prog_001": 200,
      "prog_003": 145
    }
  },
  "cumulative_time": {
    "total_hours": 234.5,
    "by_program": {
      "prog_001": 45.5,
      "prog_003": 38.2,
      "prog_005": 22.0
    },
    "by_month": {
      "2026-06": 120.5,
      "2026-05": 114.0
    }
  }
}
```

### 5.3 ROI Analysis Snapshot

```json
{
  "snapshot_type": "roi_analysis",
  "timestamp": "2026-06-26T12:00:00.000Z",
  "portfolio_roi": {
    "total_investment_hours": 234.5,
    "total_rewards": 32500,
    "effective_hourly_rate": 138.59,
    "cost_per_finding": 4.36,
    "findings_per_hour": 0.052
  },
  "program_roi_ranked": [
    {
      "program_id": "prog_001",
      "hourly_rate": 158.24,
      "findings_count": 8,
      "total_reward": 7200,
      "trend": "stable"
    },
    {
      "program_id": "prog_003",
      "hourly_rate": 142.86,
      "findings_count": 5,
      "total_reward": 4000,
      "trend": "improving"
    }
  ],
  "recommendations": [
    {
      "action": "increase_time",
      "program_id": "prog_003",
      "reason": "improving_roi_with_low_saturation"
    }
  ]
}
```

---

## 6. Persistence Triggers

| Trigger Event | Snapshot Type | Priority |
|---------------|--------------|----------|
| Program score update | program_scores | MEDIUM |
| Time log entry | time_investment | LOW (batched) |
| Reward received | reward_history | HIGH |
| Session time summary | time_investment | HIGH |
| ROI recalculation | roi_analysis | MEDIUM |
| Program scope change | program_scores | HIGH |
| Program status change | program_scores | HIGH |
| New program discovered | program_scores | MEDIUM |
| Competition intel update | competition_intel | LOW |
| Session end | All state | HIGH |

---

## 7. Restore Operations

### 7.1 Program Profile Restore

```python
def restore_program_profiles(session_id=None):
    if session_id:
        snapshot = load_latest_snapshot(session_id, "program_scores")
        return snapshot["programs_ranked"]
    
    # Restore all program profiles from shared state
    profiles = load_json("shared/program_registry.json")
    for pid, profile in profiles.items():
        profile["scores"] = recalculate_scores(profile)
    return profiles
```

### 7.2 Time Log Restore

```python
def restore_time_logs(session_id):
    log_files = glob(f"state/bug-bounty-strategy/{session_id}/time_logs/*.msgpack")
    logs = []
    for f in log_files:
        with open(f, 'rb') as fh:
            logs.extend(msgpack.unpack(fh, raw=False))
    return TimeLogCollection(logs)
```

### 7.3 ROI Restore

```python
def restore_roi_analysis(session_id=None):
    if session_id:
        return load_latest_snapshot(session_id, "roi_analysis")
    
    # Recalculate from cumulative data
    time_data = load_json("shared/time_investment_db.json")
    reward_data = load_json("shared/reward_history.json")
    return calculate_roi(time_data, reward_data)
```

---

## 8. Compression

| Data Type | Algorithm | Threshold | Rationale |
|-----------|-----------|-----------|-----------|
| Program profiles | None | N/A | Small, hot data |
| Time logs (archive) | gzip | > 100KB | Historical logs |
| Reward history | None | N/A | Small, critical |
| Trend data | zlib | > 50KB | Large datasets |
| Competition intel | None | N/A | Small, reference |

---

## 9. Encryption

| Data Classification | Required | Algorithm |
|--------------------|----------|-----------|
| Program profiles | No | None |
| Time logs | No | None |
| Reward history | Optional (contains financial data) | AES-256-GCM |
| Competition intel | Optional | AES-256-GCM |
| Strategy notes | Optional | AES-256-GCM |

---

## 10. Score Calculation Engine

### 10.1 Composite Score Formula

```python
class ProgramScorer:
    WEIGHTS = {
        "reward": 0.25,
        "scope": 0.20,
        "response": 0.15,
        "reputation": 0.20,
        "competition": 0.10,
        "roi_history": 0.10
    }

    def calculate_composite_score(self, program):
        scores = {
            "reward": self.score_reward(program),
            "scope": self.score_scope(program),
            "response": self.score_response(program),
            "reputation": self.score_reputation(program),
            "competition": self.score_competition(program),
            "roi_history": self.score_roi_history(program)
        }
        
        composite = sum(
            scores[k] * self.WEIGHTS[k] for k in self.WEIGHTS
        )
        return composite, scores
```

### 10.2 Trend Detection

```python
class TrendDetector:
    def detect_trend(self, program_id, metric_name, window_days=30):
        history = load_metric_history(program_id, metric_name, window_days)
        if len(history) < 5:
            return "insufficient_data"
        
        slope = calculate_linear_slope(history)
        
        if slope > 0.1:
            return "improving"
        elif slope < -0.1:
            return "declining"
        return "stable"
```

---

## 11. Monitoring

| Metric | Type | Alert |
|--------|------|-------|
| `portfolio_hourly_rate` | Gauge | < $50 |
| `active_programs_count` | Gauge | < 3 |
| `time_utilization_percent` | Gauge | > 100% of target |
| `program_score_changes` | Counter | N/A (audit) |
| `reward_received` | Counter | N/A (audit) |
| `roi_trend_direction` | Gauge | declining |

---

## Appendix A: Complete File Reference

All 50 domain files:

1. `01-Program-Selection-Criteria.md` → Selection framework state, scoring weights
2. `02-Time-Management-Optimization.md` → Time allocation state, schedule state
3. `03-ROI-Maximization-Strategies.md` → ROI calculations, optimization state
4. `04-Program-Reputation-Analysis.md` → Reputation scores, trend data
5. `05-Reward-Structure-Evaluation.md` → Reward analysis, payment history
6. `06-Scope-Assessment-Techniques.md` → Scope analysis cache, asset counts
7. `07-Response-Time-Analysis.md` → Response time database, averages
8. `08-Collaboration-Opportunities.md` → Collab state, partner list
9. `09-Private-vs-Public-Programs.md` → Program type analysis, comparison state
10. `10-VDI-Program-Strategy.md` → VDI-specific analysis state
11. `11-Seasonal-Program-Analysis.md` → Seasonal pattern data, calendar state
12. `12-Program-Maturity-Assessment.md` → Maturity scores, lifecycle state
13. `13-Reward-Trends-Analysis.md` → Reward trend data, prediction state
14. `14-Program-Scope-Expansion.md` → Scope change tracker, delta state
15. `15-Communication-Channel-Optimization.md` → Communication state, response tracking
16. `16-Duplicate-Submission-Avoidance.md` → Dedup index, overlap detection state
17. `17-Program-Specific-Rules.md` → Rule cache, compliance state
18. `18-Reward-Negotiation-Tactics.md` → Negotiation state, offer history
19. `19-Program-Health-Monitoring.md` → Health metrics, alert state
20. `20-Long-Term-Program-Relationships.md` → Relationship state, interaction history
21. `21-Program-Launch-Strategy.md` → Launch state, first-mover advantage
22. `22-Competition-Analysis.md` → Competitor intel, saturation data
23. `23-Program-Specialization.md` → Specialization state, expertise mapping
24. `24-Risk-Assessment-Per-Program.md` → Risk scores, risk trend data
25. `25-Time-Zone-Optimization.md` → Timezone scheduling, peak hours state
26. `26-Program-Diversity-Strategy.md` → Portfolio state, diversification metrics
27. `27-Reward-Consistency-Analysis.md` → Consistency metrics, variance state
28. `28-Program-Exit-Strategy.md` → Exit criteria state, migration plans
29. `29-Program-Feedback-Analysis.md` → Feedback database, sentiment state
30. `30-Advanced-Program-Intelligence.md` → Intelligence cache, insight state
31. `31-Program-Network-Analysis.md` → Network graph, relationship metrics
32. `32-Collaboration-Network-Building.md` → Collab network state, partner map
33. `33-Program-Influence-Strategies.md` → Influence state, impact metrics
34. `34-Reward-Prediction-Models.md` → Prediction model state, accuracy metrics
35. `35-Program-Saturation-Analysis.md` → Saturation metrics, competition density
36. `36-Seasoned-Hunter-Advantages.md` → Advantage tracking, seniority state
37. `37-Program-Trend-Forecasting.md` → Trend model state, forecast data
38. `38-Resource-Allocation-Strategy.md` → Resource allocation, optimization state
39. `39-Program-Success-Metrics.md` → Success metrics, milestone tracking
40. `40-Advanced-Program-Selection.md` → Advanced selection model, ML state
41. `41-Program-Relationship-Management.md` → Relationship state, engagement log
42. `42-Collaboration-ROI-Analysis.md` → Collab ROI metrics, partnership state
43. `43-Program-Discovery-Methods.md` → Discovery state, search history
44. `44-Advanced-Scope-Analysis.md` → Scope depth analysis, attack surface
45. `45-Program-Performance-Tracking.md` → Performance database, ranking state
46. `46-Reward-Maximization-Framework.md` → Framework state, optimization engine
47. `47-Program-Specialization-Deep-Dive.md` → Deep analysis state, niche mapping
48. `48-Time-Investment-ROI.md` → Time ROI metrics, hourly tracking
49. `49-Program-Network-Optimization.md` → Network optimization, portfolio balance
50. `50-Advanced-Program-Strategy.md` → Master strategy state, all frameworks
