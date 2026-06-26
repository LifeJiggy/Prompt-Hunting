# Working Memory: Bug Bounty Program Strategy Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `BB-STRAT-001` |
| Root Folder | `Bug-Bounty-Program-Strategy/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + optional SQLite snapshot |
| Typical Lifetime | Active hunting session (4-8h) |
| Eviction Trigger | Session end, target switch, or 24h TTL |

---

## Overview

Working memory for bug bounty program strategy captures the tactical state of an
active hunting session. This spans 50 modules from program selection criteria
through advanced strategy development. Working memory must support:

- **Program scoring**: Real-time scoring of programs based on bounty rates,
  scope size, response time, and researcher competition.
- **Time allocation**: How much time has been spent on each program and
  what ROI (return on investment) each program is yielding.
- **Target prioritization**: Which subdomains and endpoints to focus on first
  based on historical data, disclosed reports, and reconnaissance.
- **Bounty history**: Tracking submissions, payouts, and rejections to inform
  future strategy.
- **Scope awareness**: Current scope boundaries, assets in scope, and rules
  of engagement for the active program.
- **Competition analysis**: How many researchers are active, what techniques
  are commonly used, and what areas are likely saturated.
- **Session goals**: What the hunter aims to accomplish in the current session
  and how progress is measured.

This is the "strategy brain" that guides where to invest time and effort. It
continuously updates as reconnaissance reveals new information and as vulnerability
hunting produces results.

---

## Data Schema (YAML)

```yaml
working_memory_strategy:
  version: "2.0"
  scope: "hunting-session"
  ttl_seconds: 86400

  session_state:
    session_id: "string (uuid4)"
    hunter_id: "string"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    session_goals: "list[string]"
    time_budget_minutes: "integer (default 480)"
    time_spent_minutes: "float"
    remaining_budget_minutes: "float"

  active_programs:
    program_id: "string"
    platform: "enum(hackerone|bugcrowd|intigriti|self-hosted|other)"
    company: "string"
    program_url: "string"
    scope: "list[string] (in-scope assets)"
    out_of_scope: "list[string]"
    bounty_range:
      critical: "string (e.g., '$5000-$10000')"
      high: "string"
      medium: "string"
      low: "string"
    response_time_days: "float"
    avg_bounty_paid: "float"
    active_researchers_estimate: "integer"
    last_vuln_reported: "ISO8601"
    score: "float (0.0-100.0)"
    time_invested_minutes: "float"
    findings_count: "integer"
    roi_score: "float (findings per hour)"

  target_priorities:
    target: "string (subdomain or URL)"
    priority: "enum(critical|high|medium|low|deferred)"
    reason: "string"
    assigned_to_session: "boolean"
    estimated_value: "float (expected bounty)"
    estimated_effort_hours: "float"
    discovered_at: "ISO8601"
    tested: "boolean"
    findings: "list[string] (finding IDs)"

  bounty_history:
    submission_id: "string"
    program_id: "string"
    platform: "string"
    vuln_class: "string"
    severity: "string"
    title: "string"
    submitted_at: "ISO8601"
    status: "enum(duplicate|informative|triaged|resolved|paid|wont_fix|n/a)"
    bounty_amount: "float (nullable)"
    paid_at: "ISO8601 (nullable)"
    response_time_days: "float"
    researcher_notes: "string"

  competition_landscape:
    program_id: "string"
    last_scan_activity: "ISO8601"
    estimated_active_researchers: "integer"
    recently_disclosed_reports: "list[map]"
    saturated_vuln_classes: "list[string]"
    underserved_areas: "list[string]"
    competitive_advantage: "string"

  scope_awareness:
    program_id: "string"
    wildcards: "list[string]"
    excluded_paths: "list[string]"
    allowed_methods: "list[string]"
    rate_limits: "map[string,int]"
    testing_hours: "string (nullable)"
    requires_approval: "boolean"
    special_rules: "list[string]"

  session_metrics:
    targets_scanned: "integer"
    endpoints_tested: "integer"
    hours_effective: "float"
    hours_wasted: "float"
    findings_this_session: "integer"
    bounty_earned_this_session: "float"
    best_finding_severity: "string"
    technique_effectiveness: "map[string,float]"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone, timedelta
from typing import Optional
from enum import Enum


class ProgramPlatform(Enum):
    HACKERONE = "hackerone"
    BUGCROWD = "bugcrowd"
    INTIGRITI = "intigriti"
    SELF_HOSTED = "self-hosted"
    OTHER = "other"


class SubmissionStatus(Enum):
    DUPLICATE = "duplicate"
    INFORMATIVE = "informative"
    TRIAGED = "triaged"
    RESOLVED = "resolved"
    PAID = "paid"
    WONT_FIX = "wont_fix"
    NA = "n/a"


class BugBountyStrategyWorkingMemory:
    """
    In-memory working state for bug bounty program strategy.
    Covers all 50 modules from Program Selection through Advanced Strategy.
    """

    def __init__(self, hunter_id: str = "", time_budget_minutes: int = 480):
        self.session_id = str(uuid.uuid4())
        self.hunter_id = hunter_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "hunter_id": hunter_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "session_goals": [],
            "time_budget_minutes": time_budget_minutes,
            "time_spent_minutes": 0,
            "remaining_budget_minutes": float(time_budget_minutes),
        }

        self.active_programs: dict[str, dict] = {}
        self.target_priorities: dict[str, dict] = {}
        self.bounty_history: list[dict] = []
        self.competition_landscape: dict[str, dict] = {}
        self.scope_awareness: dict[str, dict] = {}
        self.session_metrics = {
            "targets_scanned": 0,
            "endpoints_tested": 0,
            "hours_effective": 0,
            "hours_wasted": 0,
            "findings_this_session": 0,
            "bounty_earned_this_session": 0.0,
            "best_finding_severity": "none",
            "technique_effectiveness": {},
        }

    def add_program(self, program_id: str, platform: str, company: str,
                    scope: list[str], out_of_scope: Optional[list[str]] = None,
                    bounty_range: Optional[dict] = None) -> dict:
        """Register a program for the current session."""
        now = datetime.now(timezone.utc).isoformat()

        self.active_programs[program_id] = {
            "program_id": program_id,
            "platform": platform,
            "company": company,
            "program_url": "",
            "scope": scope,
            "out_of_scope": out_of_scope or [],
            "bounty_range": bounty_range or {
                "critical": "$0", "high": "$0", "medium": "$0", "low": "$0"
            },
            "response_time_days": 0,
            "avg_bounty_paid": 0,
            "active_researchers_estimate": 0,
            "last_vuln_reported": now,
            "score": 50.0,
            "time_invested_minutes": 0,
            "findings_count": 0,
            "roi_score": 0,
        }

        return self.active_programs[program_id]

    def score_program(self, program_id: str) -> float:
        """Calculate and update program score based on multiple factors."""
        prog = self.active_programs[program_id]
        score = 50.0

        bounty_avg = prog.get("avg_bounty_paid", 0)
        if bounty_avg > 5000:
            score += 20
        elif bounty_avg > 1000:
            score += 10
        elif bounty_avg > 200:
            score += 5

        response_days = prog.get("response_time_days", 30)
        if response_days < 3:
            score += 15
        elif response_days < 7:
            score += 10
        elif response_days < 14:
            score += 5
        elif response_days > 30:
            score -= 10

        researchers = prog.get("active_researchers_estimate", 10)
        if researchers < 5:
            score += 15
        elif researchers < 20:
            score += 5
        elif researchers > 100:
            score -= 10

        last_vuln = datetime.fromisoformat(prog["last_vuln_reported"])
        days_since = (datetime.now(timezone.utc) - last_vuln).days
        if days_since > 90:
            score += 10
        elif days_since > 30:
            score += 5

        score = max(0, min(100, score))
        prog["score"] = score
        return score

    def prioritize_target(self, target: str, priority: str, reason: str,
                          estimated_value: float = 0,
                          estimated_effort: float = 1.0) -> None:
        """Set priority for a target within a program."""
        self.target_priorities[target] = {
            "target": target,
            "priority": priority,
            "reason": reason,
            "assigned_to_session": True,
            "estimated_value": estimated_value,
            "estimated_effort_hours": estimated_effort,
            "discovered_at": datetime.now(timezone.utc).isoformat(),
            "tested": False,
            "findings": [],
        }

    def get_priority_queue(self) -> list[dict]:
        """Get targets sorted by priority and value/effort ratio."""
        priority_order = {"critical": 0, "high": 1, "medium": 2, "low": 3, "deferred": 4}

        targets = [
            t for t in self.target_priorities.values()
            if not t["tested"] and t["assigned_to_session"]
        ]

        return sorted(
            targets,
            key=lambda t: (
                priority_order.get(t["priority"], 5),
                -(t["estimated_value"] / max(t["estimated_effort_hours"], 0.1))
            )
        )

    def record_submission(self, program_id: str, vuln_class: str,
                          severity: str, title: str,
                          bounty_amount: Optional[float] = None) -> str:
        """Record a vulnerability submission."""
        submission_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.bounty_history.append({
            "submission_id": submission_id,
            "program_id": program_id,
            "platform": self.active_programs.get(program_id, {}).get("platform", ""),
            "vuln_class": vuln_class,
            "severity": severity,
            "title": title,
            "submitted_at": now,
            "status": "triaged",
            "bounty_amount": bounty_amount,
            "paid_at": None,
            "response_time_days": 0,
            "researcher_notes": "",
        })

        if program_id in self.active_programs:
            self.active_programs[program_id]["findings_count"] += 1

        self.session_metrics["findings_this_session"] += 1
        severity_order = ["critical", "high", "medium", "low", "informational"]
        current_idx = severity_order.index(self.session_metrics["best_finding_severity"]) \
            if self.session_metrics["best_finding_severity"] in severity_order else len(severity_order)
        new_idx = severity_order.index(severity) if severity in severity_order else len(severity_order)
        if new_idx < current_idx:
            self.session_metrics["best_finding_severity"] = severity

        return submission_id

    def update_submission_status(self, submission_id: str, new_status: str,
                                 bounty_paid: Optional[float] = None) -> None:
        """Update the status of a submission."""
        for sub in self.bounty_history:
            if sub["submission_id"] == submission_id:
                sub["status"] = new_status
                if bounty_paid is not None:
                    sub["bounty_amount"] = bounty_paid
                    sub["paid_at"] = datetime.now(timezone.utc).isoformat()
                    self.session_metrics["bounty_earned_this_session"] += bounty_paid
                break

    def set_scope(self, program_id: str, wildcards: list[str],
                  excluded_paths: Optional[list[str]] = None,
                  rate_limits: Optional[dict] = None,
                  special_rules: Optional[list[str]] = None) -> None:
        """Set scope awareness for a program."""
        self.scope_awareness[program_id] = {
            "program_id": program_id,
            "wildcards": wildcards,
            "excluded_paths": excluded_paths or [],
            "allowed_methods": ["GET", "POST", "PUT", "DELETE"],
            "rate_limits": rate_limits or {},
            "testing_hours": None,
            "requires_approval": False,
            "special_rules": special_rules or [],
        }

    def update_competition(self, program_id: str,
                           estimated_researchers: int = 10,
                           saturated_classes: Optional[list[str]] = None,
                           underserved_areas: Optional[list[str]] = None) -> None:
        """Update competition landscape for a program."""
        self.competition_landscape[program_id] = {
            "program_id": program_id,
            "last_scan_activity": datetime.now(timezone.utc).isoformat(),
            "estimated_active_researchers": estimated_researchers,
            "recently_disclosed_reports": [],
            "saturated_vuln_classes": saturated_classes or [],
            "underserved_areas": underserved_areas or [],
            "competitive_advantage": "",
        }

    def record_time(self, program_id: str, minutes: float, effective: bool = True) -> None:
        """Record time spent on a program."""
        if program_id in self.active_programs:
            self.active_programs[program_id]["time_invested_minutes"] += minutes

        self.session_state["time_spent_minutes"] += minutes
        self.session_state["remaining_budget_minutes"] = max(
            0,
            self.session_state["time_budget_minutes"] - self.session_state["time_spent_minutes"]
        )

        if effective:
            self.session_metrics["hours_effective"] += minutes / 60
        else:
            self.session_metrics["hours_wasted"] += minutes / 60

    def record_technique(self, technique: str, success: bool) -> None:
        """Record technique usage and effectiveness."""
        if technique not in self.session_metrics["technique_effectiveness"]:
            self.session_metrics["technique_effectiveness"][technique] = {
                "attempts": 0, "successes": 0
            }

        stats = self.session_metrics["technique_effectiveness"][technique]
        stats["attempts"] += 1
        if success:
            stats["successes"] += 1

    def get_roi_report(self) -> dict:
        """Generate ROI report across all programs."""
        programs = []
        for pid, prog in self.active_programs.items():
            hours = prog["time_invested_minutes"] / 60
            findings = prog["findings_count"]
            programs.append({
                "program_id": pid,
                "company": prog["company"],
                "score": prog["score"],
                "hours_invested": round(hours, 1),
                "findings": findings,
                "roi": round(findings / max(hours, 0.1), 2),
            })

        return {
            "session_id": self.session_id,
            "total_hours": round(self.session_state["time_spent_minutes"] / 60, 1),
            "total_findings": self.session_metrics["findings_this_session"],
            "total_bounty_earned": self.session_metrics["bounty_earned_this_session"],
            "programs": sorted(programs, key=lambda p: p["roi"], reverse=True),
        }

    def recommend_next_action(self) -> dict:
        """Recommend the next action based on current state."""
        time_left = self.session_state["remaining_budget_minutes"]

        if time_left < 30:
            return {"action": "wrap_up", "reason": "Less than 30 minutes remaining"}

        priority_queue = self.get_priority_queue()
        if priority_queue:
            top = priority_queue[0]
            return {
                "action": "test_target",
                "target": top["target"],
                "priority": top["priority"],
                "estimated_value": top["estimated_value"],
                "reason": top["reason"],
            }

        return {"action": "recon", "reason": "No prioritized targets remaining"}

    def cleanup_expired(self) -> int:
        """Remove programs not accessed in 24h."""
        now = datetime.now(timezone.utc)
        expired = []
        for pid, prog in self.active_programs.items():
            last = datetime.fromisoformat(prog.get("last_vuln_reported", now.isoformat()))
            if (now - last).total_seconds() > 86400:
                expired.append(pid)

        for pid in expired:
            del self.active_programs[pid]

        return len(expired)
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Active programs | 20 | LRU eviction when full | Focus on top scorers |
| Target priorities | 500 | LRU eviction | Per-session focus |
| Bounty history | 1,000 | FIFO eviction | Long-term reference |
| Competition entries | 50 | TTL-based (7d) | Market intelligence |
| Scope entries | 20 | Program eviction | Per-program scope |
| Technique stats | 100 | LRU eviction | Effectiveness tracking |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Program entries expire after 24h of inactivity.
  - Session state preserved but program data evicted.

Priority 2: Low ROI Programs
  - Programs with ROI < 0.1 findings/hour are deprioritized.
  - If time budget < 20%, low-ROI programs evicted first.

Priority 3: Saturated Programs
  - Programs marked as "saturated" in competition analysis
    are evicted if alternatives exist.

Priority 4: Target Priority Decay
  - Targets not tested within 48h decay one priority level.
  - "deferred" targets evicted after 7 days.
```

---

## Lifecycle

```
1. SESSION START
   Initialize session state → set goals → set time budget

2. PROGRAM SELECTION
   add_program() × N → score_program() → rank by score

3. TARGET DISCOVERY
   prioritize_target() × N → get_priority_queue()

4. HUNTING LOOP
   recommend_next_action() → test → record_time() → record_technique()
   record_submission() if finding → update_submission_status() on resolution

5. ADAPTIVE REBALANCING
   Re-score programs → reprioritize targets → adjust time allocation

6. SESSION END
   get_roi_report() → export findings → cleanup_expired()
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Read | Automated scan results for target prioritization |
| Recon Deep Dive | Read | Reconnaissance data for scope awareness |
| Real-World Case Studies | Read | Disclosed report patterns for competition analysis |
| Report Writing | Write | Findings for report generation |

---

## Domain File References (Bug-Bounty-Program-Strategy/)

### 01-Program-Selection-Criteria
Criteria for selecting which bug bounty programs to focus on.
Working memory stores: scoring criteria, selection weights, decision history.

### 02-Scope-Analysis
Analyzing program scope to identify testing boundaries.
Working memory stores: scope maps, exclusion lists, edge cases.

### 03-Bounty-Optimization
Strategies for maximizing bounty payouts.
Working memory stores: severity mappings, impact calculations, negotiation history.

### 04-Time-Management
Time management strategies for bug bounty hunting.
Working memory stores: time allocations, productivity metrics, session plans.

### 05-Risk-Assessment
Risk assessment for bug bounty participation.
Working memory stores: legal considerations, scope boundaries, compliance requirements.

### 06-Competition-Analysis
Analyzing competition landscape across programs.
Working memory stores: researcher counts, saturation metrics, opportunity gaps.

### 07-Disclosed-Report-Analysis
Analyzing disclosed reports to find patterns and gaps.
Working memory stores: report patterns, technique frequency, coverage gaps.

### 08-Program-Reputation-Tracking
Tracking program reputation and response quality.
Working memory stores: response times, payment reliability, communication quality.

### 09-Severity-Mapping
Mapping vulnerability severity to bounty tiers.
Working memory stores: severity definitions, bounty correlations, override cases.

### 10-Impact-Assessment
Assessing real-world impact for higher severity ratings.
Working memory stores: impact scenarios, data sensitivity, user exposure.

### 11-Chained-Finding-Strategy
Strategy for chaining findings into higher-severity reports.
Working memory stores: chain opportunities, severity upgrades, dependency maps.

### 12-Multi-Program-Management
Managing participation across multiple programs simultaneously.
Working memory stores: program priorities, resource allocation, scheduling.

### 13-Program-Timing
Optimal timing for program engagement.
Working memory stores: new program launches, scope changes, disclosure timelines.

### 14-Researcher-Networking
Building networks with other researchers for intelligence sharing.
Working memory stores: contacts, shared findings, collaboration opportunities.

### 15-Vendor-Relationship-Management
Building positive relationships with program operators.
Working memory stores: communication history, reputation, negotiation outcomes.

### 16-Submission-Quality-Optimization
Optimizing report quality for higher acceptance rates.
Working memory stores: report templates, common rejection reasons, quality metrics.

### 17-Severity-Negotiation
Strategies for negotiating severity with triagers.
Working memory stores: negotiation arguments, successful precedents, escalation paths.

### 18-Duplicate-Management
Managing and avoiding duplicate submissions.
Working memory stores: duplicate patterns, search strategies, differentiation tactics.

### 19-Payment-Tracking
Tracking payments and financial outcomes.
Working memory stores: payment history, pending payments, average bounties.

### 20-Tax-and-Financial-Planning
Financial planning for bug bounty income.
Working memory stores: income tracking, tax obligations, reporting requirements.

### 21-Program-Tier-Analysis
Analyzing different program tiers (private vs public).
Working memory stores: tier requirements, invite criteria, tier benefits.

### 22-Geographic-Targeting
Targeting programs based on geographic considerations.
Working memory stores: regional programs, timezone considerations, legal jurisdictions.

### 23-Industry-Focus
Focusing on specific industries for expertise building.
Working memory stores: industry verticals, sector-specific patterns, compliance needs.

### 24-Technology-Specialization
Specializing in specific technology stacks.
Working memory stores: tech stack expertise, tool proficiency, pattern knowledge.

### 25-Vulnerability-Class-Focus
Focusing on specific vulnerability classes for depth.
Working memory stores: class expertise, technique libraries, bypass knowledge.

### 26-Tool-Stack-Optimization
Optimizing the tool stack for maximum efficiency.
Working memory stores: tool performance, configuration optimizations, automation scripts.

### 27-Workflow-Standardization
Standardizing hunting workflows for consistency.
Working memory stores: workflow templates, checklists, quality gates.

### 28-Knowledge-Base-Building
Building a personal knowledge base for bug bounty.
Working memory stores: technique notes, lesson learned, reference materials.

### 29-Mentorship-and-Learning
Continuous learning and mentorship in bug bounty.
Working memory stores: learning goals, mentor relationships, skill gaps.

### 30-Mental-Health-and-Sustainability
Maintaining mental health and sustainable hunting practices.
Working memory stores: burnout indicators, rest schedules, motivation tracking.

### 31-Program-Discovery
Discovering new bug bounty programs.
Working memory stores: discovery sources, new programs, evaluation results.

### 32-Scope-Creep-Detection
Detecting and managing scope creep in testing.
Working memory stores: scope boundaries, testing logs, deviation alerts.

### 33-Resource-Optimization
Optimizing computing and network resources.
Working memory stores: resource usage, cost tracking, optimization opportunities.

### 34-Risk-Mitigation
Mitigating risks during bug bounty testing.
Working memory stores: risk assessments, mitigation strategies, incident history.

### 35-Compliance-Management
Ensuring compliance with program rules and regulations.
Working memory stores: compliance checklists, violation history, remediation steps.

### 36-Communication-Strategy
Effective communication with program operators.
Working memory stores: communication templates, response patterns, escalation protocols.

### 37-Report-Follow-Up
Following up on submitted reports.
Working memory stores: follow-up schedules, status checks, negotiation points.

### 38-Public-Disclosure-Management
Managing public disclosure of findings.
Working memory stores: disclosure timelines, publication plans, media contacts.

### 39-Portfolio-Building
Building a professional portfolio of bug bounty work.
Working memory stores: portfolio items, presentation materials, achievement records.

### 40-Career-Development
Career development through bug bounty.
Working memory stores: career goals, skill certifications, professional connections.

### 41-Team-Collaboration
Collaborating with other researchers in teams.
Working memory stores: team roles, collaboration tools, work distribution.

### 42-Automated-Recon-Integration
Integrating automated reconnaissance into strategy.
Working memory stores: recon automation configs, result processing, alert rules.

### 43-Continuous-Monitoring
Continuous monitoring of programs and scope changes.
Working memory stores: monitoring rules, change detection, notification channels.

### 44-Intel-Driven-Hunting
Using threat intelligence to guide hunting strategy.
Working memory stores: threat intel feeds, vulnerability trends, exploitation patterns.

### 45-Program-Exit-Strategy
Strategy for exiting low-value programs.
Working memory stores: exit criteria, transition plans, final assessments.

### 46-Seasonal-Strategy
Adjusting strategy based on seasonal patterns.
Working memory stores: seasonal trends, holiday schedules, budget cycles.

### 47-Market-Analysis
Analyzing the bug bounty market landscape.
Working memory stores: market trends, platform comparisons, industry reports.

### 48-Competitive-Intelligence
Gathering competitive intelligence for strategic advantage.
Working memory stores: competitor profiles, technique databases, opportunity maps.

### 49-Long-Term-Planning
Long-term strategic planning for bug bounty career.
Working memory stores: annual goals, skill development plans, financial projections.

### 50-Advanced-Program-Strategy
Advanced strategies for maximizing bug bounty success.
Working memory stores: advanced techniques, optimization frameworks, decision models.
