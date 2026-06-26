# Long-Term Memory: Bug Bounty Program Strategy

## Domain Mapping

- **Domain**: Bug Bounty Program Strategy
- **Root Directory**: `Bug-Bounty-Program-Strategy/`
- **Total Files**: 50 (including README.md)
- **Purpose**: Persistent memory for program analysis, bounty tracking, relationship management, and strategic intelligence

---

## Overview

This long-term memory system captures program-specific intelligence, bounty history, relationship dynamics, and strategic insights that persist across hunting sessions. It enables data-driven decisions about which programs to target, when to invest time, and how to maximize returns.

### Memory Categories

1. **Program Profiles** - Comprehensive program intelligence records
2. **Bounty Archive** - Historical bounty data and payout analytics
3. **Relationship Log** - Program contact history and communication patterns
4. **Strategic Insights** - Patterns in program behavior and market trends
5. **Competition Intel** - Researcher activity and competition patterns

---

## Storage Schema

### Program Profile Record

```json
{
  "program_id": "string",
  "platform": "enum: hackerone|bugcrowd|intigriti|yeswehack|custom",
  "program_name": "string",
  "company_name": "string",
  "program_type": "enum: public|private|invitation_only",
  "status": "enum: active|paused|ended|bug_bash",
  "scope": {
    "in_scope": ["array of assets"],
    "out_of_scope": ["array of exclusions"],
    "asset_types": ["web|api|mobile|ios|android|hardware|crypto"],
    "technology_stack": ["detected technologies"]
  },
  "rewards": {
    "currency": "string",
    "min_bounty": "float",
    "max_bounty": "float",
    "avg_bounty": "float",
    "bonus_multiplier": "float",
    "swag": "boolean"
  },
  "metrics": {
    "response_time_hours": "float",
    "triage_time_days": "float",
    "resolution_time_days": "float",
    "avg_severity_bounty": "object mapping severity to avg bounty",
    "total_reports": "integer",
    "accepted_reports": "integer",
    "avg_resubmit_rate": "float"
  },
  "intel": {
    "active_researchers": "integer",
    "competition_level": "enum: low|medium|high|extreme",
    "best_vuln_classes": ["array of high-paying vuln classes"],
    "known_gaps": ["array of uncovered areas"],
    "recent_changes": ["array of scope/reward changes"]
  },
  "discovered_date": "ISO-8601",
  "last_active": "ISO-8601",
  "last_analyzed": "ISO-8601"
}
```

### Bounty Record

```json
{
  "bounty_id": "uuid-v4",
  "program_id": "string",
  "submission_id": "string",
  "finding_title": "string",
  "vuln_class": "string",
  "severity": "enum: critical|high|medium|low|informational",
  "cvss_score": "float",
  "bounty_amount": "float",
  "currency": "string",
  "bonus_amount": "float",
  "status": "enum: submitted|triaged|accepted|rejected|duplicate|informational",
  "submission_date": "ISO-8601",
  "triage_date": "ISO-8601",
  "resolution_date": "ISO-8601",
  "time_to_triage_days": "float",
  "time_to_resolution_days": "float",
  "researcher_notes": "string",
  "program_feedback": "string",
  "resubmit_required": "boolean",
  "resubmit_count": "integer"
}
```

### Relationship Log Record

```json
{
  "interaction_id": "uuid-v4",
  "program_id": "string",
  "interaction_type": "enum: submission|communication|request|feedback|escalation",
  "direction": "enum: inbound|outbound",
  "channel": "enum: email|platform|slack|discord|twitter",
  "summary": "string",
  "sentiment": "enum: positive|neutral|negative",
  "follow_up_required": "boolean",
  "follow_up_date": "ISO-8601",
  "timestamp": "ISO-8601"
}
```

### Strategic Insight Record

```json
{
  "insight_id": "uuid-v4",
  "category": "enum: market_trend|program_pattern|vuln_trend|reward_trend|competition",
  "title": "string",
  "description": "string",
  "evidence": ["array of supporting data"],
  "confidence": "float 0-1",
  "actionable": "boolean",
  "recommended_action": "string",
  "valid_until": "ISO-8601",
  "created": "ISO-8601"
}
```

---

## CRUD Operations

### Create

```
POST /memory/longterm/strategy/programs
POST /memory/longterm/strategy/bounties
POST /memory/longterm/strategy/relationships
POST /memory/longterm/strategy/insights
```

### Read

```
GET /memory/longterm/strategy/programs/{program_id}
GET /memory/longterm/strategy/programs?platform={platform}&status={status}
GET /memory/longterm/strategy/bounties?program_id={id}&status={status}
GET /memory/longterm/strategy/bounties?date_range={range}
GET /memory/longterm/strategy/relationships?program_id={id}
GET /memory/longterm/strategy/insights?category={category}
```

### Update

```
PATCH /memory/longterm/strategy/programs/{program_id}/metrics
PUT /memory/longterm/strategy/bounties/{bounty_id}/status
PATCH /memory/longterm/strategy/programs/{program_id}/intel
```

### Delete

```
DELETE /memory/longterm/strategy/programs/{program_id} (soft delete)
DELETE /memory/longterm/strategy/bounties/{bounty_id} (archive)
```

---

## TTL Rules

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Program Profiles | 90 days active, then review | Programs change frequently |
| Bounty Records | 2 years | Historical bounty data valuable |
| Relationship Logs | 365 days | Relationship history matters |
| Strategic Insights | 180 days | Insights age with market |
| Competition Intel | 60 days | Competition patterns shift |

### TTL Enforcement

```python
def enforce_strategy_ttl():
    programs.review_after_days(90)
    bounties.archive_after_days(730)
    relationships.archive_after_days(365)
    insights.expire_after_days(180)
    competition_intel.expire_after_days(60)
```

---

## Compression

### Compression Strategy

- **Program Profiles**: GZIP (JSON with arrays)
- **Bounty Records**: GZIP (historical data)
- **Relationship Logs**: None (small, frequently accessed)
- **Strategic Insights**: None (small, critical data)
- **Competition Intel**: GZIP (text-heavy)

---

## Indexing Strategy

### Primary Indexes

```json
{
  "programs": {
    "program_id": "primary_key",
    "platform": "hash_index",
    "program_type": "hash_index",
    "status": "hash_index",
    "rewards.avg_bounty": "btree_index"
  },
  "bounties": {
    "bounty_id": "primary_key",
    "program_id": "btree_index",
    "vuln_class": "hash_index",
    "severity": "hash_index",
    "bounty_amount": "btree_index",
    "submission_date": "btree_index"
  },
  "relationships": {
    "interaction_id": "primary_key",
    "program_id": "btree_index",
    "interaction_type": "hash_index",
    "timestamp": "btree_index"
  }
}
```

### Composite Indexes

```json
{
  "program_bounties": ["program_id", "bounty_amount"],
  "vuln_class_payouts": ["vuln_class", "severity", "bounty_amount"],
  "temporal_analysis": ["program_id", "submission_date", "status"]
}
```

---

## Retrieval Patterns

### Pattern 1: Program ROI Analysis

```
SELECT p.program_id, p.program_name,
       COUNT(b.bounty_id) as total_submissions,
       SUM(b.bounty_amount) as total_earned,
       AVG(b.bounty_amount) as avg_bounty,
       SUM(b.bounty_amount) / NULLIF(COUNT(b.bounty_id), 0) as bounty_per_submission,
       AVG(b.time_to_triage_days) as avg_triage_time
FROM programs p
JOIN bounties b ON p.program_id = b.program_id
WHERE b.status = 'accepted'
GROUP BY p.program_id, p.program_name
ORDER BY total_earned DESC
```

**Use Case**: Identify highest-ROI programs.

### Pattern 2: Vulnerability Class Payouts

```
SELECT vuln_class, severity,
       COUNT(*) as finding_count,
       AVG(bounty_amount) as avg_bounty,
       MAX(bounty_amount) as max_bounty,
       STDDEV(bounty_amount) as bounty_variance
FROM bounties
WHERE status = 'accepted'
  AND program_id = ?
GROUP BY vuln_class, severity
ORDER BY avg_bounty DESC
```

**Use Case**: Find most profitable vulnerability classes for a program.

### Pattern 3: Competition Analysis

```
SELECT p.program_id, p.program_name,
       p.intel.active_researchers,
       p.intel.competition_level,
       COUNT(b.bounty_id) as recent_submissions,
       AVG(b.bounty_amount) as recent_avg_bounty
FROM programs p
LEFT JOIN bounties b ON p.program_id = b.program_id
  AND b.submission_date > NOW() - INTERVAL '30 days'
WHERE p.status = 'active'
GROUP BY p.program_id, p.program_name, p.intel.active_researchers, p.intel.competition_level
ORDER BY recent_avg_bounty DESC
```

**Use Case**: Assess competition level and opportunity.

### Pattern 4: Program Selection Matrix

```
SELECT program_id, program_name,
       rewards.max_bounty,
       metrics.response_time_hours,
       metrics.avg_severity_bounty->'critical' as critical_avg,
       intel.competition_level,
       (rewards.max_bounty / NULLIF(intel.active_researchers, 0)) as bounty_per_researcher
FROM programs
WHERE status = 'active'
  AND rewards.max_bounty > ?
ORDER BY bounty_per_researcher DESC
```

**Use Case**: Select programs with best effort-to-reward ratio.

### Pattern 5: Seasonal Trend Analysis

```
SELECT DATE_TRUNC('month', submission_date) as month,
       COUNT(*) as submissions,
       SUM(bounty_amount) as total_bounty,
       AVG(bounty_amount) as avg_bounty,
       COUNT(CASE WHEN status = 'accepted' THEN 1 END) as accepted
FROM bounties
WHERE submission_date > NOW() - INTERVAL '12 months'
GROUP BY DATE_TRUNC('month', submission_date)
ORDER BY month
```

**Use Case**: Identify seasonal patterns in bounty payouts.

---

## Consolidation Triggers

### Automatic Consolidation

1. **Weekly**: Update program metrics with new bounty data
2. **Monthly**: Recalculate program ROI rankings
3. **Quarterly**: Archive old bounty records, refresh strategic insights
4. **Daily**: Process new relationship logs

### Event-Triggered Consolidation

1. **New bounty accepted**: Update program metrics
2. **Program scope changes**: Refresh program profile
3. **Competition level shift**: Update strategic insights
4. **Bounty payout received**: Update ROI calculations

### Manual Consolidation

```
POST /memory/longterm/strategy/consolidate
{
  "action": "recalculate_roi|refresh_programs|archive_bounties",
  "program_ids": "optional filter",
  "date_range": "optional"
}
```

---

## Cross-Domain References

### Linked Domains

| Domain | Relationship | Data Shared |
|--------|--------------|-------------|
| Advanced-Automation | Output | Program-specific automation |
| Report-Writing-Mastery | Output | Program formatting requirements |
| Core-Prompts-Hunting | Input | Program vulnerability priorities |
| Bug-Bounty-Support | Input | Program rules and guidelines |

---

## Domain File References

### Program Selection & Analysis (Files 01-10)

1. `01-Program-Selection-Criteria.md` - How to evaluate programs
2. `02-Time-Management-Optimization.md` - Time allocation strategies
3. `03-ROI-Maximization-Strategies.md` - Return on investment tactics
4. `04-Program-Reputation-Analysis.md` - Program reputation assessment
5. `05-Reward-Structure-Evaluation.md` - Bounty structure analysis
6. `06-Scope-Assessment-Techniques.md` - Scope evaluation methods
7. `07-Response-Time-Analysis.md` - Response time patterns
8. `08-Collaboration-Opportunities.md` - Team hunting opportunities
9. `09-Private-vs-Public-Programs.md` - Program type comparison
10. `10-VDI-Program-Strategy.md` - VDI-specific strategies

### Program Intelligence (Files 11-20)

11. `11-Seasonal-Program-Analysis.md` - Seasonal patterns
12. `12-Program-Maturity-Assessment.md` - Maturity evaluation
13. `13-Reward-Trends-Analysis.md` - Bounty trend analysis
14. `14-Program-Scope-Expansion.md` - Scope growth tracking
15. `15-Communication-Channel-Optimization.md` - Communication strategies
16. `16-Duplicate-Submission-Avoidance.md` - Dup prevention
17. `17-Program-Specific-Rules.md` - Custom program rules
18. `18-Reward-Negotiation-Tactics.md` - Bounty negotiation
19. `19-Program-Health-Monitoring.md` - Health tracking
20. `20-Long-Term-Program-Relationships.md` - Relationship building

### Competition & Market Analysis (Files 21-30)

21. `21-Program-Launch-Strategy.md` - New program tactics
22. `22-Competition-Analysis.md` - Competitor analysis
23. `23-Program-Specialization.md` - Niche selection
24. `24-Risk-Assessment-Per-Program.md` - Risk evaluation
25. `25-Time-Zone-Optimization.md` - Global timing strategies
26. `26-Program-Diversity-Strategy.md` - Portfolio approach
27. `27-Reward-Consistency-Analysis.md` - Payout consistency
28. `28-Program-Exit-Strategy.md` - When to leave programs
29. `29-Program-Feedback-Analysis.md` - Feedback patterns
30. `30-Advanced-Program-Intelligence.md` - Advanced analytics

### Strategic Planning (Files 31-40)

31. `31-Program-Network-Analysis.md` - Program ecosystem mapping
32. `32-Collaboration-Network-Building.md` - Network development
33. `33-Program-Influence-Strategies.md` - Influence tactics
34. `34-Reward-Prediction-Models.md` - Bounty prediction
35. `35-Program-Saturation-Analysis.md` - Saturation assessment
36. `36-Seasoned-Hunter-Advantages.md` - Experience leverage
37. `37-Program-Trend-Forecasting.md` - Trend prediction
38. `38-Resource-Allocation-Strategy.md` - Resource planning
39. `39-Program-Success-Metrics.md` - Success measurement
40. `40-Advanced-Program-Selection.md` - Advanced selection

### Advanced Strategy (Files 41-50)

41. `41-Program-Relationship-Management.md` - Relationship management
42. `42-Collaboration-ROI-Analysis.md` - Collaboration returns
43. `43-Program-Discovery-Methods.md` - Finding new programs
44. `44-Advanced-Scope-Analysis.md` - Deep scope analysis
45. `45-Program-Performance-Tracking.md` - Performance tracking
46. `46-Reward-Maximization-Framework.md` - Maximize returns
47. `47-Program-Specialization-Deep-Dive.md` - Deep specialization
48. `48-Time-Investment-ROI.md` - Time investment returns
49. `49-Program-Network-Optimization.md` - Network optimization
50. `50-Advanced-Program-Strategy.md` - Master strategy

---

## Bounty Analytics Benchmarks

### By Platform

| Platform | Avg Bounty | Median Bounty | Response Time |
|----------|-----------|---------------|---------------|
| HackerOne | $500-$2000 | $300-$800 | 2-5 days |
| Bugcrowd | $400-$1500 | $250-$600 | 3-7 days |
| Intigriti | $300-$1200 | $200-$500 | 2-4 days |
| YesWeHack | $200-$800 | $150-$400 | 3-5 days |

### By Vulnerability Class

| Vuln Class | Avg Bounty | Max Bounty | Frequency |
|------------|-----------|-----------|-----------|
| RCE | $2000-$10000 | $50000+ | Rare |
| SQL Injection | $1000-$5000 | $25000 | Low |
| XSS (Stored) | $500-$2000 | $10000 | Medium |
| IDOR | $300-$1500 | $5000 | High |
| Information Disclosure | $100-$500 | $2000 | Very High |

---

## Strategic Decision Framework

### Program Selection Matrix

| Factor | Weight | High Score | Low Score |
|--------|--------|------------|-----------|
| Max Bounty | 25% | > $5000 | < $500 |
| Competition | 20% | < 10 researchers | > 100 researchers |
| Response Time | 20% | < 3 days | > 14 days |
| Acceptance Rate | 20% | > 60% | < 30% |
| Scope Size | 15% | > 50 assets | < 10 assets |

### Time Allocation Strategy

| Program Type | Time Allocation | Expected Return |
|--------------|-----------------|-----------------|
| High-value private | 40% of time | 60% of bounty |
| Medium-value public | 35% of time | 30% of bounty |
| Low-value/high-volume | 25% of time | 10% of bounty |

---

## Security Considerations

### Data Sensitivity

- **Program Profiles**: Internal - team use only
- **Bounty Records**: Confidential - personal financial data
- **Relationship Logs**: Confidential - personal communications
- **Strategic Insights**: Internal - team use only

### Data Protection

- Anonymize program IDs in shared reports
- Encrypt bounty records with personal financial data
- Restrict relationship log access to team members
- Secure strategic insights from competitive intelligence

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-05-01 | Initial strategy schema |
| 1.1.0 | 2024-08-01 | Added relationship tracking |
| 1.2.0 | 2024-11-01 | Added strategic insights |
| 1.3.0 | 2025-02-01 | Enhanced competition intel |
| 2.0.0 | 2025-05-01 | Complete schema redesign |
