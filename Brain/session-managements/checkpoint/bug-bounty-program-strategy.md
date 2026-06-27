# CHECKPOINT MANAGEMENT — Bug Bounty Program Strategy

## Title

Checkpoint Management for Bug Bounty Program Strategy Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `bug-bounty-program-strategy` |
| Domain Path | `Bug-Bounty-Program-Strategy/` |
| Checkpoint Store | `Brain/session-managements/checkpoint/bug-bounty-program-strategy/` |
| Session Scope | Strategy state, program analysis, ROI tracking, selection decisions |
| Auto-Checkpoint Interval | Every strategy decision point or 20 minutes |
| Manual Checkpoint Trigger | `/checkpoint save bug-bounty-program-strategy [label]` |
| Max Checkpoints Retained | 15 per session |
| Checkpoint TTL | 120 hours (5 days, configurable) |
| Restore Command | `/checkpoint restore bug-bounty-program-strategy [id]` |

## Overview

This checkpoint management system governs the state of all strategic workflows defined across the 50 files in `Bug-Bounty-Program-Strategy/`. This domain focuses on the meta-level strategy of bug bounty hunting — selecting which programs to target, optimizing time allocation, maximizing ROI, building relationships, and managing a portfolio of programs. Checkpoints here capture strategic analysis state, program evaluation results, time allocation decisions, and historical performance data.

Strategy checkpoints are unique because they accumulate knowledge over time. Unlike technical checkpoints that capture transient scan state, strategy checkpoints capture learnings that compound across sessions. The system must preserve long-term program intelligence, relationship state, and strategic decisions that inform future hunting sessions.

## Auto-Checkpoint Configuration

```
auto_checkpoint:
  enabled: true
  triggers:
    - type: program_selection_made
      description: "Checkpoint when a program is selected or deselected"
      events:
        - program_selected_for_hunting
        - program_deselected
        - program_priority_changed
        - program_scope_changed
    - type: strategy_decision
      description: "Checkpoint on strategic decisions"
      events:
        - time_allocation_adjusted
        - resource_reallocation
        - collaboration_initiated
        - program_exit_decision
        - specialization_shift
    - type: intelligence_update
      description: "Checkpoint when program intelligence is updated"
      events:
        - new_program_discovered
        - program_reputation_changed
        - reward_structure_analyzed
        - scope_assessment_completed
        - competition_analysis_updated
    - type: roi_milestone
      description: "Checkpoint on ROI tracking milestones"
      events:
        - roi_threshold_reached
        - cost_exceeded_budget
        - reward_received
        - reward_negotiation_started
    - type: time_interval
      description: "Checkpoint every 20 minutes during strategy planning"
      interval_minutes: 20
    - type: session_end
      description: "Checkpoint at session end for continuity"
      always_checkpoint: true
```

## Manual Checkpoint

```
manual_checkpoint:
  save_command: "/checkpoint save bug-bounty-program-strategy [label]"
  options:
    - include_program_analytics: true
    - include_roi_data: true
    - include_strategy_decisions: true
    - include_relationship_state: true
    - include_historical_data: true
  special_commands:
    - "/strategy snapshot": "Capture full strategic state"
    - "/strategy roi": "Generate ROI report and checkpoint"
    - "/strategy review": "Review and checkpoint current strategy"
    - "/strategy portfolio": "Checkpoint program portfolio state"
```

## Checkpoint Format Schema

```
strategy_checkpoint:
  envelope:
    magic: "CHKP-STRATEGY-V1"
    version: "1.0"
    domain: "bug-bounty-program-strategy"
  sections:
    - section_id: "program_portfolio"
      description: "Current program portfolio state"
      fields:
        - active_programs:
          - program_id: "identifier"
            program_name: "string"
            platform: "hackerone | bugcrowd | intigriti | immunefi | custom"
            priority: "high | medium | low"
            status: "active | paused | monitoring | exited"
            scope_assets: "count of in-scope assets"
            reward_range: "min-max payout"
            average_reward: "float"
            historical_payouts: "list of past rewards"
            hunter_count: "estimated active hunters"
            competition_level: "low | medium | high | saturated"
            last_activity: "ISO-8601"
            notes: "strategic notes"
        - candidate_programs:
          - program_id: "identifier"
            program_name: "string"
            platform: "string"
            evaluation_score: "float 0-100"
            evaluation_date: "ISO-8601"
            recommendation: "pursue | monitor | skip"
            reasoning: "why this recommendation"
        - exited_programs:
          - program_id: "identifier"
            program_name: "string"
            exit_reason: "string"
            total_earned: "float"
            findings_submitted: "integer"
            exit_date: "ISO-8601"
    - section_id: "strategy_decisions"
      description: "Record of strategic decisions"
      fields:
        - decisions:
          - decision_id: "identifier"
            decision_type: "program_selection | time_allocation | resource_reallocation | collaboration | specialization"
            description: "what was decided"
            rationale: "why it was decided"
            expected_impact: "what outcome was expected"
            actual_impact: "what actually happened"
            decision_date: "ISO-8601"
            review_date: "ISO-8601 for review"
            status: "active | reviewed | superseded"
    - section_id: "time_allocation"
      description: "Current time allocation strategy"
      fields:
        - total_hours_per_week: "float"
        - allocation:
          - category: "string"
            hours_per_week: "float"
            percentage: "float"
            programs: "list of program_ids"
            roi_per_hour: "float"
        - historical_allocation:
          - week: "ISO-8601 week"
            actual_hours: "float"
            distribution: "actual time distribution"
            findings_per_hour: "float"
            earnings_per_hour: "float"
    - section_id: "roi_tracking"
      description: "ROI calculation and tracking"
      fields:
        - overall_roi:
          - total_investment_hours: "float"
          - total_investment_cost: "float"
          - total_earnings: "float"
          - roi_percentage: "float"
          - earnings_per_hour: "float"
          - findings_per_hour: "float"
        - program_roi:
          - program_id: "string"
            investment_hours: "float"
            investment_cost: "float"
            earnings: "float"
            roi_percentage: "float"
            earnings_per_hour: "float"
            findings_count: "integer"
            accepted_count: "integer"
            acceptance_rate: "float"
        - roi_trend:
          - month: "string"
            monthly_roi: "float"
            trend: "improving | stable | declining"
    - section_id: "relationship_state"
      description: "Program relationship and reputation state"
      fields:
        - program_relationships:
          - program_id: "string"
            trust_level: "new | established | trusted | preferred"
            communication_quality: "string"
            response_time_avg_hours: "float"
            triager_notes: "list of triager interaction notes"
            reputation_score: "float"
            last_interaction: "ISO-8601"
        - collaboration_state:
          - partners: "list of collaboration partners"
            active_collaborations: "integer"
            completed_collaborations: "integer"
            shared_findings: "integer"
            total_earnings_shared: "float"
    - section_id: "checksum"
      fields:
        - payload_hash: "SHA-256"
        - section_hashes: "per-section SHA-256"
```

## Validation

```
validation_rules:
  pre_checkpoint:
    - rule: "program_data_current"
      description: "Program portfolio data is up-to-date"
      action_on_fail: "refresh_program_data"
    - rule: "roi_calculations_valid"
      description: "ROI calculations are mathematically correct"
      action_on_fail: "recalculate_roi"
    - rule: "strategy_decisions_documented"
      description: "All recent decisions have rationale documented"
      action_on_fail: "prompt_for_rationale"
    - rule: "time_allocation_sum_correct"
      description: "Time allocation percentages sum to 100%"
      action_on_fail: "rebalance_allocation"
  post_restore:
    - rule: "program_still_active"
      description: "Programs in portfolio are still active"
      action_on_fail: "refresh_program_status"
    - rule: "strategy_relevant"
      description: "Restored strategy decisions are still applicable"
      action_on_fail: "flag_outdated_decisions"
    - rule: "roi_baseline_valid"
      description: "ROI baseline metrics are reproducible"
      action_on_fail: "recalculate_baseline_roi"
```

## Pruning Strategy

```
pruning_strategy:
  retention_policy:
    max_checkpoints: 15
    ttl_hours: 120
    preserve_strategy_milestones: true
    preserve_roi_records: true
    preserve_program_relationships: true
  pruning_priority:
    1: "duplicate_strategy_snapshots — prune first"
    2: "time_interval_checkpoints — routine saves"
    3: "intelligence_update_checkpoints — data refreshes"
    4: "strategy_decision_checkpoints — decision records"
    5: "roi_milestone_checkpoints — financial records"
    6: "session_end_checkpoints — continuity saves"
  special_rules:
    - "Never prune ROI records older than 30 days"
    - "Archive program relationship data permanently"
    - "Keep strategy decision history for full TTL"
```

## Checkpoint Index

```
checkpoint_index:
  file: "checkpoint-index.json"
  structure:
    domain: "bug-bounty-program-strategy"
    checkpoints:
      - checkpoint_id: "uuid"
        created_at: "ISO-8601"
        label: "user label"
        active_programs: "integer"
        overall_roi: "float"
        strategy_version: "integer"
        file_path: "relative path"
        checksum: "SHA-256 prefix"
    program_history:
      - program_id: "string"
        program_name: "string"
        first_tracked: "ISO-8601"
        last_activity: "ISO-8601"
        total_earnings: "float"
        total_findings: "integer"
        status: "active | exited"
    roi_history:
      - period: "string"
        roi: "float"
        earnings: "float"
        investment: "float"
```

## Restore from Checkpoint

```
restore_procedure:
  steps:
    1: "Load checkpoint index"
    2: "Select target checkpoint"
    3: "Validate program portfolio currency"
    4: "Restore program portfolio state"
    5: "Restore strategy decisions"
    6: "Restore time allocation configuration"
    7: "Restore ROI tracking data"
    8: "Restore relationship state"
    9: "Re-validate program status"
    10: "Update ROI baseline with current data"
    11: "Resume strategy execution"
    12: "Log restoration event"
  restore_modes:
    - full: "Restore complete strategy state"
    - portfolio_only: "Restore program portfolio only"
    - roi_only: "Restore ROI data for analysis"
    - decisions_only: "Restore strategy decisions for review"
```

## Domain File References

### Program Selection and Analysis (01-10)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 01 | `01-Program-Selection-Criteria.md` | Stores selection criteria, scoring model, weights |
| 02 | `02-Time-Management-Optimization.md` | Stores time allocation strategy, productivity metrics |
| 03 | `03-ROI-Maximization-Strategies.md` | Stores ROI strategies, optimization parameters |
| 04 | `04-Program-Reputation-Analysis.md` | Stores reputation data, platform credibility |
| 05 | `05-Reward-Structure-Evaluation.md` | Stores reward analysis, bounty structure data |
| 06 | `06-Scope-Assessment-Techniques.md` | Stores scope assessment results, asset mapping |
| 07 | `07-Response-Time-Analysis.md` | Stores response time data, triage metrics |
| 08 | `08-Collaboration-Opportunities.md` | Stores collaboration opportunities, partner data |
| 09 | `09-Private-vs-Public-Programs.md` | Stores program type analysis, access data |
| 10 | `10-VDI-Program-Strategy.md` | Stores VDI-specific strategy, virtual asset data |

### Intelligence and Trends (11-20)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 11 | `11-Seasonal-Program-Analysis.md` | Stores seasonal patterns, timing optimization |
| 12 | `12-Program-Maturity-Assessment.md` | Stores maturity analysis, program lifecycle data |
| 13 | `13-Reward-Trends-Analysis.md` | Stores reward trend data, payout forecasting |
| 14 | `14-Program-Scope-Expansion.md` | Stores scope expansion tracking, new asset data |
| 15 | `15-Communication-Channel-Optimization.md` | Stores communication strategies, channel data |
| 16 | `16-Duplicate-Submission-Avoidance.md` | Stores duplicate detection rules, history |
| 17 | `17-Program-Specific-Rules.md` | Stores program rules, compliance state |
| 18 | `18-Reward-Negotiation-Tactics.md` | Stores negotiation strategies, past outcomes |
| 19 | `19-Program-Health-Monitoring.md` | Stores health metrics, alert thresholds |
| 20 | `20-Long-Term-Program-Relationships.md` | Stores relationship state, trust metrics |

### Advanced Strategy (21-30)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 21 | `21-Program-Launch-Strategy.md` | Stores launch strategy, early-mover advantage data |
| 22 | `22-Competition-Analysis.md` | Stores competition data, hunter density analysis |
| 23 | `23-Program-Specialization.md` | Stores specialization strategy, expertise areas |
| 24 | `24-Risk-Assessment-Per-Program.md` | Stores risk analysis, risk-reward assessment |
| 25 | `25-Time-Zone-Optimization.md` | Stores timezone strategy, global hunt scheduling |
| 26 | `26-Program-Diversity-Strategy.md` | Stores diversity strategy, portfolio balance |
| 27 | `27-Reward-Consistency-Analysis.md` | Stores consistency metrics, reliability data |
| 28 | `28-Program-Exit-Strategy.md` | Stores exit criteria, exit decision history |
| 29 | `29-Program-Feedback-Analysis.md` | Stores feedback data, improvement tracking |
| 30 | `30-Advanced-Program-Intelligence.md` | Stores intelligence operations, data sources |

### Portfolio Management (31-40)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 31 | `31-Program-Network-Analysis.md` | Stores program network graph, relationship mapping |
| 32 | `32-Collaboration-Network-Building.md` | Stores collaboration network, partner profiles |
| 33 | `33-Program-Influence-Strategies.md` | Stores influence strategies, impact data |
| 34 | `34-Reward-Prediction-Models.md` | Stores prediction models, forecast accuracy |
| 35 | `35-Program-Saturation-Analysis.md` | Stores saturation data, competition metrics |
| 36 | `36-Seasoned-Hunter-Advantages.md` | Stores advantage tracking, experience leverage |
| 37 | `37-Program-Trend-Forecasting.md` | Stores trend forecasts, prediction state |
| 38 | `38-Resource-Allocation-Strategy.md` | Stores resource allocation, budget state |
| 39 | `39-Program-Success-Metrics.md` | Stores success metrics, KPI tracking |
| 40 | `40-Advanced-Program-Selection.md` | Stores advanced selection models, decision trees |

### Mastery and Optimization (41-50)

| # | File | Checkpoint Relevance |
|---|------|---------------------|
| 41 | `41-Program-Relationship-Management.md` | Stores relationship management state, CRM data |
| 42 | `42-Collaboration-ROI-Analysis.md` | Stores collaboration ROI, shared earnings data |
| 43 | `43-Program-Discovery-Methods.md` | Stores discovery methods, new program sources |
| 44 | `44-Advanced-Scope-Analysis.md` | Stores advanced scope analysis, attack surface |
| 45 | `45-Program-Performance-Tracking.md` | Stores performance tracking, trend data |
| 46 | `46-Reward-Maximization-Framework.md` | Stores maximization framework, optimization rules |
| 47 | `47-Program-Specialization-Deep-Dive.md` | Stores deep-dive analysis, niche expertise |
| 48 | `48-Time-Investment-ROI.md` | Stores time investment data, hourly rate tracking |
| 49 | `49-Program-Network-Optimization.md` | Stores network optimization, relationship leverage |
| 50 | `50-Advanced-Program-Strategy.md` | Stores advanced strategy state, meta-decisions |

## Strategic State Machine

```
strategy_states:
  - RESEARCHING: "Gathering program intelligence"
  - EVALUATING: "Evaluating program fit"
  - SELECTING: "Making program selection decision"
  - HUNTING: "Actively hunting on selected programs"
  - OPTIMIZING: "Optimizing strategy based on results"
  - REBALANCING: "Adjusting program portfolio"
  - COLLABORATING: "Working with other hunters"
  - NEGOTIATING: "Negotiating rewards or terms"
  - EXITING: "Transitioning away from program"
  - ARCHIVING: "Archiving program data"

state_transitions:
  RESEARCHING -> EVALUATING: "sufficient_data_collected"
  EVALUATING -> SELECTING: "evaluation_complete"
  SELECTING -> HUNTING: "program_selected"
  HUNTING -> OPTIMIZING: "results_analyzed"
  OPTIMIZING -> HUNTING: "optimization_applied"
  OPTIMIZING -> REBALANCING: "portfolio_review_needed"
  REBALANCING -> HUNTING: "reallocation_complete"
  HUNTING -> COLLABORATING: "collaboration_opportunity"
  COLLABORATING -> HUNTING: "collaboration_ended"
  HUNTING -> NEGOTIATING: "negotiation_needed"
  NEGOTIATING -> HUNTING: "negotiation_complete"
  HUNTING -> EXITING: "exit_criteria_met"
  EXITING -> ARCHIVING: "exit_complete"
```

## Cross-Domain Dependencies

| Related Domain | Shared Checkpoint Data |
|---------------|----------------------|
| `advanced-automation` | Tool efficiency data informs resource allocation |
| `automation-efficiency` | Performance metrics inform ROI calculations |
| `bug-bounty-support` | Support framework data informs strategy |
| `core-prompts-hunting` | Hunting results feed program evaluation |
| `real-world-case-studies` | Case study data informs strategy decisions |
