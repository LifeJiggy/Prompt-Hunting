# Bug Bounty Program Strategy — Tool Execution Domain

**Component:** Tool Executor for Strategy Analysis  
**Domain:** `bug-bounty-program-strategy`  
**Registry:** `Bug-Bounty-Program-Strategy/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Analysis tool execution with data aggregation

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `bug-bounty-program-strategy` |
| Domain Path | `Bug-Bounty-Program-Strategy/` |
| Category | `strategy` |
| Execution Profile | `analysis` |
| Default Timeout | 120s |
| Max Timeout | 600s |
| Default Retries | 2 |
| Concurrency Limit | 10 |
| Stealth Level | `low` |
| Rate Limit | 30 req/s |

---

## Overview

The Bug Bounty Program Strategy executor manages tool execution for program analysis, selection, and optimization workflows. This domain covers 50 prompt files spanning program selection criteria, time management optimization, ROI maximization strategies, program reputation analysis, reward structure evaluation, scope assessment techniques, response time analysis, collaboration opportunities, private vs public programs, VDI program strategy, seasonal program analysis, program maturity assessment, reward trends analysis, program scope expansion, communication channel optimization, duplicate submission avoidance, program-specific rules, reward negotiation tactics, program health monitoring, long-term program relationships, program launch strategy, competition analysis, program specialization, risk assessment per program, time zone optimization, program diversity strategy, reward consistency analysis, program exit strategy, program feedback analysis, advanced program intelligence, program network analysis, collaboration network building, program influence strategies, reward prediction models, program saturation analysis, seasoned hunter advantages, program trend forecasting, resource allocation strategy, program success metrics, advanced program selection, program relationship management, collaboration ROI analysis, program discovery methods, advanced scope analysis, program performance tracking, reward maximization framework, program specialization deep dive, time investment ROI, program network optimization, and advanced program strategy.

This executor runs analysis tools that evaluate bug bounty programs, calculate ROI, track reward trends, and provide strategic recommendations for maximizing hunter productivity and earnings.

---

## Execution Schema

### StrategyInvocation (Input)

```json
{
  "tool": "string — analysis tool name",
  "analysis_type": "string — selection|roi|reputation|reward|scope|intelligence",
  "input": {
    "programs": ["string — program identifiers"],
    "metrics": ["string — metrics to analyze"],
    "time_range": {
      "start": "string — ISO date",
      "end": "string — ISO date"
    },
    "filters": {
      "platform": "string — hackerone|bugcrowd|intigriti",
      "min_reward": "number",
      "max_reward": "number",
      "scope_type": "string — web|api|mobile|ios"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "output_format": "string — json|csv|markdown"
  }
}
```

### StrategyResult (Output)

```json
{
  "status": "string",
  "analysis": {
    "type": "string",
    "findings": ["object — analysis findings"],
    "recommendations": ["string — actionable recommendations"],
    "scores": {
      "roi_score": "number — 0-100",
      "opportunity_score": "number — 0-100",
      "competition_score": "number — 0-100",
      "overall_score": "number — 0-100"
    }
  },
  "duration_ms": "number",
  "data_points_analyzed": "number"
}
```

---

## Run Operations

### Strategy Analysis Execution

```python
def run_analysis(
    self,
    tool: str,
    analysis_type: str,
    input_data: dict,
    config: dict = None
) -> StrategyResult:
    """
    Execute a strategy analysis tool.
    
    Flow:
    1. Validate analysis parameters
    2. Load program data from database
    3. Apply analysis algorithm
    4. Calculate scores and metrics
    5. Generate recommendations
    6. Format and return results
    """
```

### Program Selection Analysis

```python
def analyze_program_selection(
    self,
    programs: list[str],
    criteria: dict
) -> StrategyResult:
    """
    Analyze programs for selection optimization.
    Evaluates ROI, competition, scope, and rewards.
    """
```

### ROI Calculation

```python
def calculate_roi(
    self,
    program_id: str,
    time_spent_hours: float,
    findings: list[dict]
) -> StrategyResult:
    """
    Calculate return on investment for a program.
    Factor in time, rewards, and opportunity cost.
    """
```

---

## Stop Operations

### Analysis Stop

```python
def stop_analysis(
    self,
    invocation_id: str
) -> StopResult:
    """Stop a running analysis and return partial results."""
```

---

## Retry Operations

### Strategy Retry Configuration

```python
@dataclass
class StrategyRetryConfig:
    max_retries: int = 2
    backoff_base: float = 1.0
    retry_on_data_error: bool = True
    retry_on_timeout: bool = True
    fallback_to_cached: bool = True
```

---

## Timeout Handling

### Strategy Timeout Configuration

```python
@dataclass
class StrategyTimeoutConfig:
    default: int = 120
    overrides: dict[str, int] = field(default_factory=lambda: {
        "program_selection": 60,
        "roi_calculation": 30,
        "reputation_analysis": 90,
        "reward_trends": 120,
        "scope_assessment": 180,
        "intelligence_gathering": 300,
        "network_analysis": 240,
        "trend_forecasting": 180,
        "prediction_models": 300
    })
    hard_maximum: int = 600
```

---

## Output Capture

### Strategy Output Capture

```python
@dataclass
class StrategyCapturedOutput:
    analysis_results: dict
    recommendations: list[str]
    scores: dict
    data_points: int
    confidence_level: float
    duration_ms: int
```

---

## Stderr Handling

### Strategy Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process analysis stderr."""
    return StderrResult(
        raw=stderr,
        classification=self._classify_analysis_error(stderr),
        retryable=self._is_retryable(stderr)
    )
```

---

## Exit Code Handling

### Strategy Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process analysis exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="process_results")
    return ExitCodeResult(status="error", action="retry_or_report")
```

---

## Concurrent Execution

### Strategy Concurrency Configuration

```python
@dataclass
class StrategyConcurrencyConfig:
    max_concurrent: int = 10
    max_per_analysis_type: int = 3
    parallel_programs: bool = True
```

---

## Execution Logging

### Strategy Execution Log

```python
@dataclass
class StrategyExecutionLog:
    invocation_id: str
    tool: str
    analysis_type: str
    programs_analyzed: list[str]
    status: str
    duration_ms: int
    data_points: int
    findings_count: int
    timestamp_start: str
    timestamp_end: str
```

---

## Full Domain File References

### Category: Program Selection and Evaluation

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 01 | `01-Program-Selection-Criteria.md` | Program Selection Criteria | selection | high |
| 02 | `02-Time-Management-Optimization.md` | Time Management Optimization | optimization | high |
| 03 | `03-ROI-Maximization-Strategies.md` | ROI Maximization Strategies | roi | high |
| 04 | `04-Program-Reputation-Analysis.md` | Program Reputation Analysis | reputation | medium |
| 05 | `05-Reward-Structure-Evaluation.md` | Reward Structure Evaluation | reward | high |
| 06 | `06-Scope-Assessment-Techniques.md` | Scope Assessment Techniques | scope | medium |
| 07 | `07-Response-Time-Analysis.md` | Response Time Analysis | intelligence | medium |

### Category: Program Types and Structures

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 08 | `08-Collaboration-Opportunities.md` | Collaboration Opportunities | collaboration | medium |
| 09 | `09-Private-vs-Public-Programs.md` | Private vs Public Programs | selection | medium |
| 10 | `10-VDI-Program-Strategy.md` | VDI Program Strategy | strategy | medium |
| 11 | `11-Seasonal-Program-Analysis.md` | Seasonal Program Analysis | intelligence | medium |
| 12 | `12-Program-Maturity-Assessment.md` | Program Maturity Assessment | intelligence | medium |

### Category: Rewards and Economics

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 13 | `13-Reward-Trends-Analysis.md` | Reward Trends Analysis | reward | medium |
| 14 | `14-Program-Scope-Expansion.md` | Program Scope Expansion | scope | medium |
| 15 | `15-Communication-Channel-Optimization.md` | Communication Channel Optimization | optimization | medium |
| 16 | `16-Duplicate-Submission-Avoidance.md` | Duplicate Submission Avoidance | optimization | medium |
| 17 | `17-Program-Specific-Rules.md` | Program Specific Rules | compliance | medium |
| 18 | `18-Reward-Negotiation-Tactics.md` | Reward Negotiation Tactics | reward | medium |

### Category: Program Relationships

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 19 | `19-Program-Health-Monitoring.md` | Program Health Monitoring | intelligence | medium |
| 20 | `20-Long-Term-Program-Relationships.md` | Long-Term Program Relationships | relationship | high |
| 21 | `21-Program-Launch-Strategy.md` | Program Launch Strategy | strategy | medium |
| 22 | `22-Competition-Analysis.md` | Competition Analysis | intelligence | medium |
| 23 | `23-Program-Specialization.md` | Program Specialization | strategy | medium |

### Category: Risk and Intelligence

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 24 | `24-Risk-Assessment-Per-Program.md` | Risk Assessment Per Program | risk | medium |
| 25 | `25-Time-Zone-Optimization.md` | Time Zone Optimization | optimization | medium |
| 26 | `26-Program-Diversity-Strategy.md` | Program Diversity Strategy | strategy | medium |
| 27 | `27-Reward-Consistency-Analysis.md` | Reward Consistency Analysis | reward | medium |
| 28 | `28-Program-Exit-Strategy.md` | Program Exit Strategy | strategy | medium |
| 29 | `29-Program-Feedback-Analysis.md` | Program Feedback Analysis | intelligence | medium |
| 30 | `30-Advanced-Program-Intelligence.md` | Advanced Program Intelligence | intelligence | medium |

### Category: Network and Collaboration

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 31 | `31-Program-Network-Analysis.md` | Program Network Analysis | network | medium |
| 32 | `32-Collaboration-Network-Building.md` | Collaboration Network Building | collaboration | medium |
| 33 | `33-Program-Influence-Strategies.md` | Program Influence Strategies | strategy | medium |
| 34 | `34-Reward-Prediction-Models.md` | Reward Prediction Models | prediction | medium |
| 35 | `35-Program-Saturation-Analysis.md` | Program Saturation Analysis | intelligence | medium |
| 36 | `36-Seasoned-Hunter-Advantages.md` | Seasoned Hunter Advantages | strategy | medium |
| 37 | `37-Program-Trend-Forecasting.md` | Program Trend Forecasting | prediction | medium |

### Category: Advanced Strategy

| ID | File | Title | Analysis Type | Priority |
|----|------|-------|---------------|----------|
| 38 | `38-Resource-Allocation-Strategy.md` | Resource Allocation Strategy | optimization | medium |
| 39 | `39-Program-Success-Metrics.md` | Program Success Metrics | metrics | medium |
| 40 | `40-Advanced-Program-Selection.md` | Advanced Program Selection | selection | high |
| 41 | `41-Program-Relationship-Management.md` | Program Relationship Management | relationship | medium |
| 42 | `42-Collaboration-ROI-Analysis.md` | Collaboration ROI Analysis | roi | medium |
| 43 | `43-Program-Discovery-Methods.md` | Program Discovery Methods | discovery | medium |
| 44 | `44-Advanced-Scope-Analysis.md` | Advanced Scope Analysis | scope | medium |
| 45 | `45-Program-Performance-Tracking.md` | Program Performance Tracking | metrics | medium |
| 46 | `46-Reward-Maximization-Framework.md` | Reward Maximization Framework | reward | high |
| 47 | `47-Program-Specialization-Deep-Dive.md` | Program Specialization Deep Dive | strategy | medium |
| 48 | `48-Time-Investment-ROI.md` | Time Investment ROI | roi | medium |
| 49 | `49-Program-Network-Optimization.md` | Program Network Optimization | network | medium |
| 50 | `50-Advanced-Program-Strategy.md` | Advanced Program Strategy | strategy | high |

---

## Program Health Indicators

| Indicator | Healthy | Warning | Critical |
|-----------|---------|---------|----------|
| Response time | < 7 days | 7-14 days | > 14 days |
| Payment speed | < 30 days | 30-60 days | > 60 days |
| Triage quality | > 80% accepted | 60-80% | < 60% |
| Scope clarity | Clear boundaries | Some ambiguity | Vague scope |
| Communication | Active and helpful | Slow responses | No response |
| Reward consistency | Predictable | Variable | Unpredictable |

---

## Portfolio Diversification Strategy

| Category | Allocation | Risk Level | Expected ROI |
|----------|------------|------------|--------------|
| High-reward programs | 30% | medium | $500-5000/bug |
| Medium-reward programs | 40% | low | $100-500/bug |
| New/launch programs | 20% | high | $200-2000/bug |
| Private/invite programs | 10% | medium | $300-3000/bug |

---

## Time Allocation Model

| Activity | Recommended % | Daily Hours |
|----------|---------------|-------------|
| Reconnaissance | 25% | 2.0h |
| Vulnerability testing | 40% | 3.2h |
| Report writing | 15% | 1.2h |
| Program research | 10% | 0.8h |
| Skill development | 10% | 0.8h |

Based on 8-hour hunting day.

---

## Program Selection Quick Reference

| Signal | Good | Bad |
|--------|------|-----|
| Response time | < 7 days | > 14 days |
| Payment history | On time | Delayed |
| Triage quality | Detailed feedback | Generic rejections |
| Scope definition | Clear boundaries | Vague or changing |
| Reward range | Competitive | Below market |
| Active hunters | Growing | Declining |

---

## Analysis Scoring Model

| Score Component | Weight | Calculation Method |
|----------------|--------|-------------------|
| ROI Score | 30% | (Reward / Time) × Success Rate |
| Opportunity Score | 25% | Scope × Competition⁻¹ × Reward |
| Competition Score | 20% | Active Hunters⁻¹ × Novelty |
| Relationship Score | 15% | Response Time × Payment Speed × Communication |
| Risk Score | 10% | Program Stability × Policy Clarity |

---

## Learning Paths

| Path | Modules | Estimated Time | Skill Level |
|------|---------|----------------|-------------|
| Getting Started | 01, 02, 05, 06, 07, 09, 16, 17 | 3.5 hours | beginner |
| Optimization | 03, 04, 08, 10, 11, 13, 14, 15, 18, 21, 22, 23 | 10 hours | intermediate |
| Mastery | 12, 19, 20, 24, 30, 31, 32, 33, 34, 36, 37, 38, 40, 41, 42, 44, 46, 47, 48, 49, 50 | 12 hours | advanced |
| ROI Maximizer | 01, 02, 03, 05, 20, 40, 46, 48, 50 | 5 hours | advanced |
| Relationship Builder | 04, 08, 09, 15, 19, 20, 21, 31, 32, 33, 41 | 5.5 hours | advanced |

---

## Tool Configuration by Analysis Type

| Analysis Type | Primary Tool | Secondary Tool | Cache TTL | Parallel |
|---------------|-------------|----------------|-----------|----------|
| selection | program-selector | reputation-analyzer | 24h | yes |
| roi | roi-calculator | time-tracker | 1h | no |
| reputation | reputation-analyzer | health-monitor | 12h | yes |
| reward | reward-tracker | prediction-model | 6h | yes |
| scope | scope-analyzer | asset-mapper | 12h | yes |
| intelligence | intelligence-gatherer | trend-forecaster | 4h | yes |
| network | network-analyzer | collaboration-tracker | 24h | yes |
| prediction | prediction-model | trend-forecaster | 12h | no |

---

## Error Recovery Matrix

| Error Source | Recovery Strategy | Max Recovery Time |
|-------------|-------------------|-------------------|
| API rate limit | Wait and retry | 60s |
| Data unavailable | Use cached data | 5s |
| Parse error | Fallback parser | 10s |
| Network timeout | Retry with backoff | 30s |
| Invalid program | Log and skip | 1s |
| Calculation error | Recalculate | 5s |

---

## Integration Points

### With Registry

```python
program_data = self._registry.get_program("h1-target-123")
# Returns: program details, scope, rewards, history
```

### With Session Manager

```python
session = self._session_manager.get(context["session_id"])
# Returns: session context, hunter profile, program history
```

### With Chain Executor

```python
chain_result = self._chain_executor.run_step(
    step_id="strategy_analysis",
    tool="program-selector",
    input={"criteria": selection_criteria}
)
# Returns: StrategyResult for strategy pipeline
```

### With Notification System

```python
self._notification_system.send(
    channel="strategy_alerts",
    message=f"New high-ROI program detected: {program_name}"
)
```

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
