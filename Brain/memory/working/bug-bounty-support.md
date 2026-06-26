# Working Memory: Bug Bounty Support Frameworks Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `BB-SUPPORT-001` |
| Root Folder | `bug-bounty-support/` |
| Total Files | 23 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict |
| Typical Lifetime | Active methodology session (2-6h) |
| Eviction Trigger | Methodology switch, session end, or 12h TTL |

---

## Overview

Working memory for bug bounty support frameworks captures the active state of
methodologies, prompts, and frameworks being applied during a hunting session.
This domain contains 23 specialized support modules — from advanced prompt
engineering for bug bounty through vulnerability detection frameworks.

Unlike the strategy domain (which focuses on where to hunt), this domain focuses
on HOW to hunt. It tracks:

- **Loaded frameworks**: Which methodology frameworks are currently active and
  being applied to the current target.
- **Active methodology**: The specific hunting methodology in use — recon,
  vulnerability scanning, manual testing, or reporting.
- **Current scope**: The precise scope boundaries being enforced by the active
  framework.
- **Prompt templates**: The active prompt templates being used for AI-assisted
  hunting.
- **Detection rules**: Active vulnerability detection rules and their states.
- **Framework state**: Per-framework state machines tracking where in the
  methodology the hunter currently is.
- **Cross-references**: Links between frameworks — e.g., a recon finding that
  triggers a specific vulnerability detection framework.

This is the "methodology brain" that ensures consistent, thorough coverage
of the target by tracking which frameworks have been applied and which remain.

---

## Data Schema (YAML)

```yaml
working_memory_support:
  version: "1.5"
  scope: "methodology-session"
  ttl_seconds: 43200

  loaded_frameworks:
    framework_id: "string (uuid4)"
    framework_name: "string"
    framework_file: "string (source .md file)"
    loaded_at: "ISO8601"
    status: "enum(loaded|active|paused|completed|failed)"
    current_step: "integer"
    total_steps: "integer"
    completion_pct: "float (0.0-100.0)"

  active_methodology:
    methodology_id: "string (uuid4)"
    name: "enum(recon|vuln_scan|manual_test|reporting|retest)"
    phase: "string"
    started_at: "ISO8601"
    target: "string"
    scope_enforced: "list[string]"
    findings_produced: "list[string]"

  scope_enforcement:
    scope_id: "string (uuid4)"
    program_id: "string"
    allowed_targets: "list[string]"
    excluded_targets: "list[string]"
    allowed_methods: "list[string]"
    rate_limits: "map[string,int]"
    active: "boolean"

  prompt_templates:
    template_id: "string (uuid4)"
    name: "string"
    template_content: "string (truncated at 4KB)"
    variables: "map[string,string]"
    last_used_at: "ISO8601"
    usage_count: "integer"
    effectiveness_score: "float (0.0-1.0)"

  detection_rules:
    rule_id: "string (uuid4)"
    rule_name: "string"
    vuln_class: "string"
    rule_type: "enum(pattern|behavior|anomaly|signature)"
    pattern: "string"
    severity_hint: "string"
    enabled: "boolean"
    last_triggered: "ISO8601"
    trigger_count: "integer"

  framework_state_machines:
    framework_id: "string"
    current_state: "string"
    transitions:
      from_state: "string"
      to_state: "string"
      trigger: "string"
      condition: "string"
    history: "list[map] (state, timestamp, trigger)"

  cross_references:
    source_framework: "string (framework_id)"
    target_framework: "string (framework_id)"
    trigger_finding: "string (finding description)"
    auto_activate: "boolean"
    activated: "boolean"

  session_checklist:
    checklist_id: "string (uuid4)"
    framework_name: "string"
    items:
      item_id: "string"
      description: "string"
      completed: "boolean"
      completed_at: "ISO8601 (nullable)"
      notes: "string"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone
from typing import Optional
from enum import Enum


class FrameworkStatus(Enum):
    LOADED = "loaded"
    ACTIVE = "active"
    PAUSED = "paused"
    COMPLETED = "completed"
    FAILED = "failed"


class MethodologyPhase(Enum):
    RECON = "recon"
    VULN_SCAN = "vuln_scan"
    MANUAL_TEST = "manual_test"
    REPORTING = "reporting"
    RETEST = "retest"


class BugBountySupportWorkingMemory:
    """
    In-memory working state for bug bounty support frameworks.
    Covers all 23 files in bug-bounty-support/.
    """

    def __init__(self):
        self.created_at = datetime.now(timezone.utc)

        self.loaded_frameworks: dict[str, dict] = {}
        self.active_methodology: dict[str, dict] = {}
        self.scope_enforcement: dict[str, dict] = {}
        self.prompt_templates: dict[str, dict] = {}
        self.detection_rules: dict[str, dict] = {}
        self.state_machines: dict[str, dict] = {}
        self.cross_references: list[dict] = []
        self.session_checklists: dict[str, dict] = {}

    def load_framework(self, framework_name: str, framework_file: str,
                       total_steps: int = 10) -> str:
        """Load a methodology framework into working memory."""
        framework_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.loaded_frameworks[framework_id] = {
            "framework_id": framework_id,
            "framework_name": framework_name,
            "framework_file": framework_file,
            "loaded_at": now,
            "status": FrameworkStatus.LOADED.value,
            "current_step": 0,
            "total_steps": total_steps,
            "completion_pct": 0.0,
        }

        self.state_machines[framework_id] = {
            "framework_id": framework_id,
            "current_state": "idle",
            "transitions": [],
            "history": [{"state": "idle", "timestamp": now, "trigger": "load"}],
        }

        return framework_id

    def activate_framework(self, framework_id: str) -> None:
        """Activate a loaded framework."""
        self.loaded_frameworks[framework_id]["status"] = FrameworkStatus.ACTIVE.value
        self._transition_state(framework_id, "active", "activate")

    def advance_framework(self, framework_id: str,
                          step_result: str = "success") -> dict:
        """Advance a framework to the next step."""
        fw = self.loaded_frameworks[framework_id]
        fw["current_step"] += 1
        fw["completion_pct"] = (fw["current_step"] / fw["total_steps"]) * 100

        if fw["current_step"] >= fw["total_steps"]:
            fw["status"] = FrameworkStatus.COMPLETED.value
            self._transition_state(framework_id, "completed", "final_step")

        return {
            "step": fw["current_step"],
            "total": fw["total_steps"],
            "completion": fw["completion_pct"],
            "status": fw["status"],
        }

    def pause_framework(self, framework_id: str) -> None:
        """Pause an active framework."""
        self.loaded_frameworks[framework_id]["status"] = FrameworkStatus.PAUSED.value
        self._transition_state(framework_id, "paused", "pause")

    def resume_framework(self, framework_id: str) -> None:
        """Resume a paused framework."""
        self.loaded_frameworks[framework_id]["status"] = FrameworkStatus.ACTIVE.value
        self._transition_state(framework_id, "active", "resume")

    def set_methodology(self, methodology_name: str, target: str,
                        scope: list[str]) -> str:
        """Set the active methodology for the current session."""
        methodology_id = str(uuid.uuid4())

        self.active_methodology = {
            "methodology_id": methodology_id,
            "name": methodology_name,
            "phase": "start",
            "started_at": datetime.now(timezone.utc).isoformat(),
            "target": target,
            "scope_enforced": scope,
            "findings_produced": [],
        }

        return methodology_id

    def set_scope(self, program_id: str, allowed: list[str],
                  excluded: Optional[list[str]] = None,
                  rate_limits: Optional[dict] = None) -> str:
        """Set scope enforcement rules."""
        scope_id = str(uuid.uuid4())

        self.scope_enforcement[scope_id] = {
            "scope_id": scope_id,
            "program_id": program_id,
            "allowed_targets": allowed,
            "excluded_targets": excluded or [],
            "allowed_methods": ["GET", "POST", "PUT", "DELETE"],
            "rate_limits": rate_limits or {},
            "active": True,
        }

        return scope_id

    def check_scope(self, target: str) -> bool:
        """Check if a target is within the active scope."""
        for scope in self.scope_enforcement.values():
            if not scope["active"]:
                continue

            for excluded in scope["excluded_targets"]:
                if target.startswith(excluded) or target == excluded:
                    return False

            for allowed in scope["allowed_targets"]:
                if allowed.startswith("*."):
                    base = allowed[2:]
                    if target.endswith(base) or target == base:
                        return True
                elif target == allowed or target.startswith(allowed):
                    return True

        return False

    def register_prompt_template(self, name: str, content: str,
                                  variables: Optional[dict] = None) -> str:
        """Register a prompt template for AI-assisted hunting."""
        template_id = str(uuid.uuid4())

        self.prompt_templates[template_id] = {
            "template_id": template_id,
            "name": name,
            "template_content": content[:4096],
            "variables": variables or {},
            "last_used_at": None,
            "usage_count": 0,
            "effectiveness_score": 0.5,
        }

        return template_id

    def use_prompt_template(self, template_id: str,
                            variables: Optional[dict] = None) -> str:
        """Use a prompt template, returning the filled template."""
        tpl = self.prompt_templates[template_id]
        tpl["usage_count"] += 1
        tpl["last_used_at"] = datetime.now(timezone.utc).isoformat()

        content = tpl["template_content"]
        filled_vars = {**tpl["variables"], **(variables or {})}

        for key, value in filled_vars.items():
            content = content.replace(f"{{{key}}}", value)

        return content

    def register_detection_rule(self, rule_name: str, vuln_class: str,
                                 rule_type: str, pattern: str,
                                 severity_hint: str = "medium") -> str:
        """Register a vulnerability detection rule."""
        rule_id = str(uuid.uuid4())

        self.detection_rules[rule_id] = {
            "rule_id": rule_id,
            "rule_name": rule_name,
            "vuln_class": vuln_class,
            "rule_type": rule_type,
            "pattern": pattern,
            "severity_hint": severity_hint,
            "enabled": True,
            "last_triggered": None,
            "trigger_count": 0,
        }

        return rule_id

    def evaluate_detection_rules(self, content: str) -> list[dict]:
        """Evaluate all enabled detection rules against content."""
        import re
        triggered = []

        for rule in self.detection_rules.values():
            if not rule["enabled"]:
                continue

            if rule["rule_type"] == "pattern":
                if re.search(rule["pattern"], content):
                    rule["last_triggered"] = datetime.now(timezone.utc).isoformat()
                    rule["trigger_count"] += 1
                    triggered.append({
                        "rule_id": rule["rule_id"],
                        "rule_name": rule["rule_name"],
                        "vuln_class": rule["vuln_class"],
                        "severity_hint": rule["severity_hint"],
                    })

        return triggered

    def add_cross_reference(self, source_framework: str,
                            target_framework: str,
                            trigger_finding: str,
                            auto_activate: bool = True) -> None:
        """Add a cross-reference between frameworks."""
        self.cross_references.append({
            "source_framework": source_framework,
            "target_framework": target_framework,
            "trigger_finding": trigger_finding,
            "auto_activate": auto_activate,
            "activated": False,
        })

    def check_cross_references(self, finding: str) -> list[str]:
        """Check if a finding triggers any framework cross-references."""
        activated = []
        for ref in self.cross_references:
            if not ref["activated"] and ref["trigger_finding"] in finding:
                ref["activated"] = True
                activated.append(ref["target_framework"])
        return activated

    def create_checklist(self, framework_name: str,
                         items: list[str]) -> str:
        """Create a session checklist from framework steps."""
        checklist_id = str(uuid.uuid4())

        self.session_checklists[checklist_id] = {
            "checklist_id": checklist_id,
            "framework_name": framework_name,
            "items": [
                {
                    "item_id": str(uuid.uuid4()),
                    "description": item,
                    "completed": False,
                    "completed_at": None,
                    "notes": "",
                }
                for item in items
            ],
        }

        return checklist_id

    def complete_checklist_item(self, checklist_id: str,
                                item_id: str, notes: str = "") -> None:
        """Mark a checklist item as completed."""
        checklist = self.session_checklists[checklist_id]
        for item in checklist["items"]:
            if item["item_id"] == item_id:
                item["completed"] = True
                item["completed_at"] = datetime.now(timezone.utc).isoformat()
                item["notes"] = notes
                break

    def get_checklist_progress(self, checklist_id: str) -> dict:
        """Get progress on a checklist."""
        checklist = self.session_checklists[checklist_id]
        total = len(checklist["items"])
        completed = sum(1 for i in checklist["items"] if i["completed"])

        return {
            "checklist_id": checklist_id,
            "framework": checklist["framework_name"],
            "total_items": total,
            "completed_items": completed,
            "completion_pct": (completed / max(total, 1)) * 100,
        }

    def get_framework_summary(self) -> dict:
        """Get summary of all loaded frameworks."""
        frameworks = []
        for fw in self.loaded_frameworks.values():
            frameworks.append({
                "name": fw["framework_name"],
                "status": fw["status"],
                "progress": fw["completion_pct"],
                "step": f"{fw['current_step']}/{fw['total_steps']}",
            })

        return {
            "total_frameworks": len(frameworks),
            "active": sum(1 for f in frameworks if f["status"] == "active"),
            "completed": sum(1 for f in frameworks if f["status"] == "completed"),
            "frameworks": frameworks,
        }

    def _transition_state(self, framework_id: str, new_state: str,
                          trigger: str) -> None:
        """Transition a framework's state machine."""
        sm = self.state_machines[framework_id]
        old_state = sm["current_state"]
        sm["current_state"] = new_state
        sm["history"].append({
            "state": new_state,
            "timestamp": datetime.now(timezone.utc).isoformat(),
            "trigger": trigger,
        })

    def cleanup_expired(self) -> int:
        """Remove frameworks not accessed in 12h."""
        now = datetime.now(timezone.utc)
        expired = []
        for fid, fw in self.loaded_frameworks.items():
            loaded = datetime.fromisoformat(fw["loaded_at"])
            if (now - loaded).total_seconds() > 43200:
                expired.append(fid)

        for fid in expired:
            del self.loaded_frameworks[fid]
            self.state_machines.pop(fid, None)

        return len(expired)
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Loaded frameworks | 10 | LRU eviction when full | Focus on active methodologies |
| Prompt templates | 50 | LRU eviction | Most-used preserved |
| Detection rules | 200 | TTL-based (7d) | Auto-disable unused rules |
| Cross-references | 100 | Cascade eviction | Remove with framework |
| Checklists | 20 | LRU eviction | Completed checklists removed first |
| State machine history | 100 per framework | FIFO truncation | Keep last 100 transitions |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Frameworks expire after 12h of inactivity.
  - Associated checklists and cross-references removed.

Priority 2: Completed Frameworks
  - Frameworks with status=completed are evicted after 30 min.
  - Their detection rules persist if still useful.

Priority 3: Low-Usage Templates
  - Prompt templates with usage_count < 3 after 7 days evicted.
  - High-effectiveness templates preserved regardless.

Priority 4: Inactive Detection Rules
  - Rules with trigger_count == 0 after 7 days disabled.
  - Disabled rules evicted after 14 more days.
```

---

## Lifecycle

```
1. FRAMEWORK LOADING
   load_framework() × N → frameworks available
   register_detection_rule() × N → detection active
   register_prompt_template() × N → prompts ready

2. METHODOLOGY ACTIVATION
   set_methodology() → set_scope() → create_checklist()
   activate_framework() → begin hunting

3. ACTIVE HUNTING
   advance_framework() → check_scope() → evaluate_detection_rules()
   use_prompt_template() → check_cross_references() → complete_checklist_item()

4. FRAMEWORK TRANSITIONS
   pause_framework() / resume_framework() as needed
   Framework completion → activate next framework via cross-reference

5. SESSION END
   get_framework_summary() → export results → cleanup_expired()
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Read | Pipeline outputs feeding detection rules |
| Advanced Chaining | Read/Write | Chain primitives triggering cross-references |
| Bug Bounty Strategy | Read | Program scope for scope enforcement |
| Report Writing | Write | Framework-completed findings for reports |

---

## Domain File References (bug-bounty-support/)

### Advanced-Bug-Bounty-Prompt
Advanced prompt engineering for bug bounty methodology.
Working memory stores: prompt templates, variable bindings, effectiveness metrics.

### Automated-Reconnaissance
Automated reconnaissance workflow prompts and templates.
Working memory stores: recon workflows, tool configurations, output parsers.

### Content-Security-Policy-Analysis
CSP analysis methodology and bypass detection.
Working memory stores: CSP directives, bypass techniques, policy weaknesses.

### CSRF-Testing-Prompts
CSRF vulnerability testing methodology prompts.
Working memory stores: CSRF test cases, token analysis, state-change detection.

### Custom-Wordlist-Generation
Custom wordlist generation methodology for target-specific fuzzing.
Working memory stores: wordlist templates, target-specific patterns, generation rules.

### GraphQL-Testing-Prompts
GraphQL API security testing methodology.
Working memory stores: introspection results, query templates, authorization tests.

### IDOR-Testing-Prompts
IDOR vulnerability testing methodology prompts.
Working memory stores: ID enumeration patterns, access control tests, data extraction.

### JWT-Attack-Prompts
JWT vulnerability testing and exploitation prompts.
Working memory stores: JWT analysis, algorithm confusion tests, key extraction.

### OAuth-Testing-Prompts
OAuth/OIDC flow testing methodology.
Working memory stores: redirect_uri tests, state parameter analysis, token exchange.

### Reconnaissance-Prompts
Reconnaissance methodology prompts and workflows.
Working memory stores: recon phases, tool selections, output processing.

### Reporting-Prompts
Report writing methodology prompts and templates.
Working memory stores: report templates, severity calculations, impact framing.

### SSRF-Testing-Prompts
SSRF vulnerability testing methodology.
Working memory stores: SSRF payloads, filter bypasses, internal target discovery.

### SQL-Injection-Prompts
SQL injection testing methodology prompts.
Working memory stores: injection points, database fingerprinting, extraction methods.

### Subdomain-Takeover-Prompts
Subdomain takeover testing methodology.
Working memory stores: CNAME analysis, service fingerprinting, takeover verification.

### Vulnerability-Detection
General vulnerability detection methodology.
Working memory stores: detection rules, pattern libraries, severity mappings.

### XSS-Testing-Prompts
XSS vulnerability testing methodology prompts.
Working memory stores: injection contexts, filter bypasses, payload libraries.

### XXE-Testing-Prompts
XXE vulnerability testing methodology.
Working memory stores: XML injection points, file read payloads, SSRF escalation.

### API-Security-Prompts
API security testing methodology.
Working memory stores: API patterns, authentication tests, mass assignment checks.

### Authentication-Bypass-Prompts
Authentication bypass testing methodology.
Working memory stores: auth flow analysis, bypass techniques, session management.

### Cloud-Security-Prompts
Cloud security assessment methodology.
Working memory stores: cloud configurations, misconfiguration patterns, IAM analysis.

### File-Upload-Prompts
File upload vulnerability testing methodology.
Working memory stores: upload restrictions, bypass techniques, RCE vectors.

### Race-Condition-Prompts
Race condition testing methodology.
Working memory stores: timing analysis, concurrency tests, state manipulation.

### WebSocket-Testing-Prompts
WebSocket security testing methodology.
Working memory stores: WS endpoints, message injection, authentication gaps.
