# Bug Bounty Program Strategy — Input Validation Reference

**Domain**: Bug Bounty Program Strategy (Program Selection & Strategy)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all strategy-related inputs across the Bug-Bounty-Program-Strategy domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `bug-bounty-program-strategy` |
| Root Directory | `Bug-Bounty-Program-Strategy/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Program Selection, Strategy, ROI, Collaboration, Intelligence |
| Input Surface | Program targets, strategy params, ROI configs, collaboration settings |

---

## 2. Overview

The Bug Bounty Program Strategy validator enforces strict input validation for every strategy workflow in the `Bug-Bounty-Program-Strategy/` directory. Each file defines a strategy technique — from program selection criteria to advanced program strategy — and accepts structured inputs that must be validated before execution. This validator ensures:

- Program identifiers are valid and properly formatted
- Strategy parameters are within actionable ranges
- ROI calculations use valid input data
- Collaboration settings are properly configured
- Time management parameters are realistic
- Scope assessments use valid scope definitions
- Reward analysis uses accurate reward structures
- Communication channels are valid and accessible
- Program health metrics are within measurable ranges

---

## 3. Schema Definition

### 3.1 Master Strategy Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "BugBountyStrategyInput",
  "type": "object",
  "required": ["domain", "strategy_type", "program"],
  "properties": {
    "domain": { "type": "string", "const": "bug-bounty-program-strategy" },
    "strategy_type": { "$ref": "#/definitions/StrategyType" },
    "program": { "$ref": "#/definitions/ProgramConfig" },
    "strategy": { "$ref": "#/definitions/StrategyParams" },
    "roi": { "$ref": "#/definitions/ROIConfig" },
    "collaboration": { "$ref": "#/definitions/CollaborationConfig" },
    "output": { "$ref": "#/definitions/StrategyOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 StrategyType Schema

```json
{
  "definitions": {
    "StrategyType": {
      "type": "string",
      "enum": [
        "program_selection", "time_management", "roi_maximization",
        "reputation_analysis", "reward_structure", "scope_assessment",
        "response_time", "collaboration", "private_vs_public",
        "vdi_program", "seasonal_analysis", "maturity_assessment",
        "reward_trends", "scope_expansion", "communication_optimization",
        "duplicate_avoidance", "program_rules", "reward_negotiation",
        "health_monitoring", "long_term_relationships", "program_launch",
        "competition_analysis", "program_specialization", "risk_assessment",
        "time_zone_optimization", "program_diversity", "reward_consistency",
        "exit_strategy", "feedback_analysis", "advanced_intelligence",
        "network_analysis", "collaboration_network", "program_influence",
        "reward_prediction", "saturation_analysis", "seasoned_hunter",
        "trend_forecasting", "resource_allocation", "success_metrics",
        "advanced_selection", "relationship_management", "collaboration_roi",
        "discovery_methods", "advanced_scope", "performance_tracking",
        "reward_maximization", "specialization_deep_dive", "time_investment_roi",
        "network_optimization", "advanced_strategy"
      ]
    }
  }
}
```

### 3.3 ProgramConfig Schema

```json
{
  "definitions": {
    "ProgramConfig": {
      "type": "object",
      "required": ["platform", "name"],
      "properties": {
        "platform": {
          "type": "string",
          "enum": ["hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "custom"]
        },
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "url": { "type": "string", "format": "uri", "maxLength": 2048 },
        "program_type": {
          "type": "string",
          "enum": ["public", "private", "vdp", "invite_only", "response"]
        },
        "scope": {
          "type": "array",
          "items": { "$ref": "#/definitions/ScopeEntry" },
          "maxItems": 500
        },
        "rewards": { "$ref": "#/definitions/RewardStructure" },
        "rules": { "type": "string", "maxLength": 16384 },
        "response_time_days": { "type": "integer", "minimum": 1, "maximum": 365 },
        "last_updated": { "type": "string", "format": "date" }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ScopeEntry Schema

```json
{
  "definitions": {
    "ScopeEntry": {
      "type": "object",
      "required": ["asset", "type", "severity"],
      "properties": {
        "asset": { "type": "string", "maxLength": 1024 },
        "type": {
          "type": "string",
          "enum": ["url", "domain", "api", "mobile", "android", "ios", "source_code", "other"]
        },
        "severity": {
          "type": "string",
          "enum": ["none", "low", "medium", "high", "critical"]
        },
        "in_scope": { "type": "boolean", "default": true },
        "notes": { "type": "string", "maxLength": 1024 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 RewardStructure Schema

```json
{
  "definitions": {
    "RewardStructure": {
      "type": "object",
      "properties": {
        "critical": { "$ref": "#/definitions/RewardRange" },
        "high": { "$ref": "#/definitions/RewardRange" },
        "medium": { "$ref": "#/definitions/RewardRange" },
        "low": { "$ref": "#/definitions/RewardRange" },
        "info": { "$ref": "#/definitions/RewardRange" },
        "currency": { "type": "string", "enum": ["USD", "EUR", "GBP", "BTC", "ETH"], "default": "USD" },
        "bonus_multiplier": { "type": "number", "minimum": 1, "maximum": 10, "default": 1 }
      }
    }
  }
}
```

### 3.6 RewardRange Schema

```json
{
  "definitions": {
    "RewardRange": {
      "type": "object",
      "properties": {
        "min": { "type": "number", "minimum": 0, "maximum": 1000000 },
        "max": { "type": "number", "minimum": 0, "maximum": 1000000 },
        "avg": { "type": "number", "minimum": 0, "maximum": 1000000 }
      }
    }
  }
}
```

### 3.7 StrategyParams Schema

```json
{
  "definitions": {
    "StrategyParams": {
      "type": "object",
      "properties": {
        "time_budget_hours": { "type": "number", "minimum": 0.5, "maximum": 720, "default": 40 },
        "target_severity": {
          "type": "array",
          "items": { "type": "string", "enum": ["low", "medium", "high", "critical"] },
          "maxItems": 4
        },
        "focus_areas": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "excluded_vulns": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 50
        },
        "max_concurrent_programs": { "type": "integer", "minimum": 1, "maximum": 50, "default": 5 },
        "risk_tolerance": {
          "type": "string",
          "enum": ["conservative", "moderate", "aggressive"],
          "default": "moderate"
        },
        "experience_level": {
          "type": "string",
          "enum": ["beginner", "intermediate", "advanced", "expert"],
          "default": "intermediate"
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.8 ROIConfig Schema

```json
{
  "definitions": {
    "ROIConfig": {
      "type": "object",
      "properties": {
        "time_investment_hours": { "type": "number", "minimum": 0.5, "maximum": 720 },
        "expected_bounty_min": { "type": "number", "minimum": 0, "maximum": 1000000 },
        "expected_bounty_max": { "type": "number", "minimum": 0, "maximum": 1000000 },
        "probability_of_success": { "type": "number", "minimum": 0, "maximum": 100 },
        "competition_level": {
          "type": "string",
          "enum": ["low", "medium", "high", "very_high"]
        },
        "program_age_months": { "type": "integer", "minimum": 0, "maximum": 240 },
        "historical_payouts": {
          "type": "array",
          "items": { "type": "number" },
          "maxItems": 100
        }
      }
    }
  }
}
```

### 3.9 CollaborationConfig Schema

```json
{
  "definitions": {
    "CollaborationConfig": {
      "type": "object",
      "properties": {
        "collaborators": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["name", "role"],
            "properties": {
              "name": { "type": "string", "maxLength": 128 },
              "role": { "type": "string", "enum": ["lead", "researcher", "reviewer", "reporter"] },
              "specialization": { "type": "string", "maxLength": 256 }
            }
          },
          "maxItems": 20
        },
        "split_method": {
          "type": "string",
          "enum": ["equal", "weighted", "contribution", "negotiated"],
          "default": "equal"
        },
        "communication_channel": {
          "type": "string",
          "enum": ["slack", "discord", "telegram", "email", "signal", "custom"]
        },
        "nda_required": { "type": "boolean", "default": false }
      }
    }
  }
}
```

### 3.10 StrategyOutput Schema

```json
{
  "definitions": {
    "StrategyOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "csv", "html"] },
        "include_charts": { "type": "boolean", "default": false },
        "detail_level": { "type": "string", "enum": ["summary", "detailed", "comprehensive"], "default": "detailed" },
        "export_path": { "type": "string", "maxLength": 4096 }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateStrategyType(input) → ValidationResult

```python
def validate_strategy_type(input_data):
    errors = []
    strategy_type = input_data.get("strategy_type", "")
    valid_types = [
        "program_selection", "time_management", "roi_maximization",
        "reputation_analysis", "reward_structure", "scope_assessment",
        "response_time", "collaboration", "private_vs_public",
        "vdi_program", "seasonal_analysis", "maturity_assessment",
        "reward_trends", "scope_expansion", "communication_optimization",
        "duplicate_avoidance", "program_rules", "reward_negotiation",
        "health_monitoring", "long_term_relationships", "program_launch",
        "competition_analysis", "program_specialization", "risk_assessment",
        "time_zone_optimization", "program_diversity", "reward_consistency",
        "exit_strategy", "feedback_analysis", "advanced_intelligence",
        "network_analysis", "collaboration_network", "program_influence",
        "reward_prediction", "saturation_analysis", "seasoned_hunter",
        "trend_forecasting", "resource_allocation", "success_metrics",
        "advanced_selection", "relationship_management", "collaboration_roi",
        "discovery_methods", "advanced_scope", "performance_tracking",
        "reward_maximization", "specialization_deep_dive", "time_investment_roi",
        "network_optimization", "advanced_strategy"
    ]
    if strategy_type not in valid_types:
        errors.append(ValidationError("INVALID_STRATEGY_TYPE", f"Unknown strategy type: {strategy_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateProgramConfig(input) → ValidationResult

```python
def validate_program_config(input_data):
    errors = []
    program = input_data.get("program", {})

    platform = program.get("platform", "")
    if platform not in ("hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "custom"):
        errors.append(ValidationError("INVALID_PLATFORM", f"Unknown platform: {platform}"))

    name = program.get("name", "")
    if not name:
        errors.append(ValidationError("PROGRAM_NAME_EMPTY", "Program name is required"))
    if len(name) > 256:
        errors.append(ValidationError("PROGRAM_NAME_TOO_LONG", "Program name exceeds 256 characters"))

    program_type = program.get("program_type", "")
    if program_type and program_type not in ("public", "private", "vdp", "invite_only", "response"):
        errors.append(ValidationError("INVALID_PROGRAM_TYPE", f"Invalid program type: {program_type}"))

    scope = program.get("scope", [])
    if len(scope) > 500:
        errors.append(ValidationError("SCOPE_TOO_LARGE", "Scope cannot have more than 500 entries"))

    response_time = program.get("response_time_days", 0)
    if response_time and (response_time < 1 or response_time > 365):
        errors.append(ValidationError("INVALID_RESPONSE_TIME", "Response time must be 1-365 days"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateRewardStructure(input) → ValidationResult

```python
def validate_reward_structure(input_data):
    errors = []
    rewards = input_data.get("program", {}).get("rewards", {})
    if not rewards:
        return ValidationResult(valid=True, errors=[])

    currency = rewards.get("currency", "USD")
    if currency not in ("USD", "EUR", "GBP", "BTC", "ETH"):
        errors.append(ValidationError("INVALID_CURRENCY", f"Invalid currency: {currency}"))

    bonus = rewards.get("bonus_multiplier", 1)
    if bonus < 1 or bonus > 10:
        errors.append(ValidationError("INVALID_BONUS_MULTIPLIER", "Bonus multiplier must be 1-10"))

    for severity in ("critical", "high", "medium", "low", "info"):
        range_data = rewards.get(severity, {})
        if range_data:
            min_val = range_data.get("min", 0)
            max_val = range_data.get("max", 0)
            avg_val = range_data.get("avg", 0)
            if min_val < 0 or min_val > 1000000:
                errors.append(ValidationError("REWARD_MIN_INVALID", f"{severity} min reward invalid"))
            if max_val < 0 or max_val > 1000000:
                errors.append(ValidationError("REWARD_MAX_INVALID", f"{severity} max reward invalid"))
            if avg_val < 0 or avg_val > 1000000:
                errors.append(ValidationError("REWARD_AVG_INVALID", f"{severity} avg reward invalid"))
            if min_val > max_val and max_val > 0:
                errors.append(ValidationError("REWARD_MIN_GT_MAX", f"{severity} min > max"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateStrategyParams(input) → ValidationResult

```python
def validate_strategy_params(input_data):
    errors = []
    strategy = input_data.get("strategy", {})
    if not strategy:
        return ValidationResult(valid=True, errors=[])

    time_budget = strategy.get("time_budget_hours", 40)
    if time_budget < 0.5 or time_budget > 720:
        errors.append(ValidationError("TIME_BUDGET_OUT_OF_RANGE", "Time budget must be 0.5-720 hours"))

    target_sev = strategy.get("target_severity", [])
    valid_sev = ("low", "medium", "high", "critical")
    for s in target_sev:
        if s not in valid_sev:
            errors.append(ValidationError("INVALID_TARGET_SEVERITY", f"Invalid target severity: {s}"))

    focus = strategy.get("focus_areas", [])
    if len(focus) > 20:
        errors.append(ValidationError("TOO_MANY_FOCUS_AREAS", "Cannot have more than 20 focus areas"))

    excluded = strategy.get("excluded_vulns", [])
    if len(excluded) > 50:
        errors.append(ValidationError("TOO_MANY_EXCLUSIONS", "Cannot exclude more than 50 vuln types"))

    concurrent = strategy.get("max_concurrent_programs", 5)
    if concurrent < 1 or concurrent > 50:
        errors.append(ValidationError("CONCURRENT_OUT_OF_RANGE", "Concurrent programs must be 1-50"))

    risk = strategy.get("risk_tolerance", "moderate")
    if risk not in ("conservative", "moderate", "aggressive"):
        errors.append(ValidationError("INVALID_RISK_TOLERANCE", f"Invalid risk tolerance: {risk}"))

    experience = strategy.get("experience_level", "intermediate")
    if experience not in ("beginner", "intermediate", "advanced", "expert"):
        errors.append(ValidationError("INVALID_EXPERIENCE_LEVEL", f"Invalid experience level: {experience}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.5 validateROIConfig(input) → ValidationResult

```python
def validate_roi_config(input_data):
    errors = []
    roi = input_data.get("roi", {})
    if not roi:
        return ValidationResult(valid=True, errors=[])

    hours = roi.get("time_investment_hours", 0)
    if hours < 0.5 or hours > 720:
        errors.append(ValidationError("ROI_HOURS_OUT_OF_RANGE", "Time investment must be 0.5-720 hours"))

    min_bounty = roi.get("expected_bounty_min", 0)
    max_bounty = roi.get("expected_bounty_max", 0)
    if min_bounty < 0 or min_bounty > 1000000:
        errors.append(ValidationError("MIN_BOUNTY_INVALID", "Min bounty must be 0-1000000"))
    if max_bounty < 0 or max_bounty > 1000000:
        errors.append(ValidationError("MAX_BOUNTY_INVALID", "Max bounty must be 0-1000000"))
    if min_bounty > max_bounty and max_bounty > 0:
        errors.append(ValidationError("BOUNTY_MIN_GT_MAX", "Min bounty exceeds max bounty"))

    prob = roi.get("probability_of_success", 0)
    if prob < 0 or prob > 100:
        errors.append(ValidationError("PROBABILITY_INVALID", "Probability must be 0-100%"))

    competition = roi.get("competition_level", "")
    if competition and competition not in ("low", "medium", "high", "very_high"):
        errors.append(ValidationError("INVALID_COMPETITION", f"Invalid competition level: {competition}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeProgramName(name) → str

```python
def sanitize_program_name(name):
    name = name.strip()
    name = re.sub(r'[<>"\';\\]', '', name)
    return name[:256]
```

### 5.2 sanitizeScopeEntries(scope) → list

```python
def sanitize_scope_entries(scope):
    sanitized = []
    for entry in scope[:500]:
        if not isinstance(entry, dict):
            continue
        entry["asset"] = str(entry.get("asset", ""))[:1024].strip()
        entry["asset"] = re.sub(r'[<>"\';\\]', '', entry["asset"])
        entry["notes"] = str(entry.get("notes", ""))[:1024].strip()
        sanitized.append(entry)
    return sanitized
```

### 5.3 sanitizeCollaborators(collaborators) → list

```python
def sanitize_collaborators(collaborators):
    sanitized = []
    for collab in collaborators[:20]:
        if not isinstance(collab, dict):
            continue
        collab["name"] = re.sub(r'[<>"\';\\]', '', str(collab.get("name", "")))[:128]
        collab["specialization"] = re.sub(r'[<>"\';\\]', '', str(collab.get("specialization", "")))[:256]
        sanitized.append(collab)
    return sanitized
```

### 5.4 sanitizeStrategyOutput(output) → dict

```python
def sanitize_strategy_output(output):
    output["format"] = output.get("format", "json")
    if output["format"] not in ("json", "markdown", "csv", "html"):
        output["format"] = "json"
    output["detail_level"] = output.get("detail_level", "detailed")
    if output["detail_level"] not in ("summary", "detailed", "comprehensive"):
        output["detail_level"] = "detailed"
    if "export_path" in output:
        output["export_path"] = re.sub(r'[^\w\-\/\.\~]', '', output["export_path"])[:4096]
    return output
```

---

## 6. Type Coercion

### 6.1 coerceRewardValues(rewards) → dict

```python
def coerce_reward_values(rewards):
    for severity in ("critical", "high", "medium", "low", "info"):
        if severity in rewards:
            range_data = rewards[severity]
            for field in ("min", "max", "avg"):
                if field in range_data:
                    try:
                        range_data[field] = float(range_data[field])
                    except (ValueError, TypeError):
                        range_data[field] = 0.0
    if "bonus_multiplier" in rewards:
        try:
            rewards["bonus_multiplier"] = float(rewards["bonus_multiplier"])
        except (ValueError, TypeError):
            rewards["bonus_multiplier"] = 1.0
    return rewards
```

### 6.2 coerceStrategyParams(strategy) → dict

```python
def coerce_strategy_params(strategy):
    if "time_budget_hours" in strategy:
        try:
            strategy["time_budget_hours"] = float(strategy["time_budget_hours"])
        except (ValueError, TypeError):
            strategy["time_budget_hours"] = 40.0
    if "max_concurrent_programs" in strategy:
        try:
            strategy["max_concurrent_programs"] = int(strategy["max_concurrent_programs"])
        except (ValueError, TypeError):
            strategy["max_concurrent_programs"] = 5
    if "target_severity" in strategy and isinstance(strategy["target_severity"], str):
        strategy["target_severity"] = [s.strip() for s in strategy["target_severity"].split(",")]
    if "focus_areas" in strategy and isinstance(strategy["focus_areas"], str):
        strategy["focus_areas"] = [f.strip() for f in strategy["focus_areas"].split(",")]
    return strategy
```

### 6.3 coerceROIConfig(roi) → dict

```python
def coerce_roi_config(roi):
    float_fields = ["time_investment_hours", "expected_bounty_min", "expected_bounty_max", "probability_of_success"]
    for field in float_fields:
        if field in roi:
            try:
                roi[field] = float(roi[field])
            except (ValueError, TypeError):
                roi[field] = 0.0
    if "historical_payouts" in roi and isinstance(roi["historical_payouts"], str):
        roi["historical_payouts"] = [float(x) for x in roi["historical_payouts"].split(",") if x.strip()]
    return roi
```

### 6.4 coercePlatform(platform) → str

```python
PLATFORM_MAP = {
    "hackerone": "hackerone", "h1": "hackerone",
    "bugcrowd": "bugcrowd", "bc": "bugcrowd",
    "intigriti": "intigriti", "iti": "intigriti",
    "immunefi": "immunefi", "imf": "immunefi",
    "yeswehack": "yeswehack", "ywh": "yeswehack",
    "custom": "custom"
}

def coerce_platform(platform):
    return PLATFORM_MAP.get(str(platform).lower().strip(), "custom")
```

---

## 7. Custom Validators

### 7.1 validateROIAnalysis(roi, strategy) → list

```python
def validate_roi_analysis(roi, strategy):
    errors = []
    if not roi:
        return errors

    hours = roi.get("time_investment_hours", 0)
    min_bounty = roi.get("expected_bounty_min", 0)
    prob = roi.get("probability_of_success", 0)

    if hours > 0 and min_bounty > 0 and prob > 0:
        expected_return = min_bounty * (prob / 100)
        hourly_rate = expected_return / hours
        if hourly_rate < 10:
            errors.append(ValidationWarning(
                "LOW_EXPECTED_RATE",
                f"Expected hourly rate (${hourly_rate:.2f}) is very low"
            ))
        if hourly_rate > 1000:
            errors.append(ValidationWarning(
                "HIGH_EXPECTED_RATE",
                f"Expected hourly rate (${hourly_rate:.2f}) seems unrealistically high"
            ))

    time_budget = strategy.get("time_budget_hours", 40) if strategy else 40
    if hours > time_budget:
        errors.append(ValidationError(
            "EXCEEDS_TIME_BUDGET",
            "Time investment exceeds allocated time budget"
        ))

    return errors
```

### 7.2 validateScopeCompleteness(scope) → list

```python
def validate_scope_completeness(scope):
    errors = []
    if not scope:
        errors.append(ValidationWarning("EMPTY_SCOPE", "Program scope is empty"))
        return errors

    types_seen = set()
    for entry in scope:
        entry_type = entry.get("type", "")
        types_seen.add(entry_type)

    if "url" not in types_seen and "domain" not in types_seen:
        errors.append(ValidationWarning("NO_WEB_ASSETS", "Scope has no web assets (URLs or domains)"))

    in_scope = [e for e in scope if e.get("in_scope", True)]
    out_scope = [e for e in scope if not e.get("in_scope", True)]
    if len(out_scope) > len(in_scope):
        errors.append(ValidationWarning(
            "MOSTLY_OUT_OF_SCOPE",
            "More assets are out-of-scope than in-scope"
        ))

    return errors
```

### 7.3 validateCollaborationFeasibility(collab) → list

```python
def validate_collaboration_feasibility(collab):
    errors = []
    if not collab:
        return errors

    collaborators = collab.get("collaborators", [])
    if len(collaborators) > 20:
        errors.append(ValidationError("TOO_MANY_COLLABORATORS", "Cannot collaborate with more than 20 people"))

    roles = [c.get("role", "") for c in collaborators]
    leads = roles.count("lead")
    if leads > 1:
        errors.append(ValidationError("MULTIPLE_LEADS", "Collaboration can have at most one lead"))

    if leads == 0 and len(collaborators) > 1:
        errors.append(ValidationWarning("NO_LEAD", "No lead role assigned in collaboration"))

    names = [c.get("name", "") for c in collaborators]
    if len(names) != len(set(names)):
        errors.append(ValidationError("DUPLICATE_COLLABORATORS", "Duplicate collaborators detected"))

    return errors
```

### 7.4 validateProgramHealthMetrics(program) → list

```python
def validate_program_health_metrics(program):
    errors = []
    if not program:
        return errors

    response_time = program.get("response_time_days", 0)
    if response_time > 30:
        errors.append(ValidationWarning(
            "SLOW_RESPONSE_TIME",
            f"Program response time ({response_time} days) is above average"
        ))

    scope = program.get("scope", [])
    if len(scope) == 0:
        errors.append(ValidationWarning("NO_SCOPE", "Program has no defined scope"))

    rewards = program.get("rewards", {})
    if not rewards:
        errors.append(ValidationWarning("NO_REWARDS", "Program has no defined reward structure"))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_STRATEGY_TYPE` | ERROR | Strategy type not recognized |
| `INVALID_PLATFORM` | ERROR | Platform not recognized |
| `PROGRAM_NAME_EMPTY` | ERROR | Program name is required |
| `PROGRAM_NAME_TOO_LONG` | ERROR | Program name exceeds 256 characters |
| `INVALID_PROGRAM_TYPE` | ERROR | Program type not recognized |
| `SCOPE_TOO_LARGE` | ERROR | Scope exceeds 500 entries |
| `INVALID_RESPONSE_TIME` | ERROR | Response time outside valid range |
| `INVALID_CURRENCY` | ERROR | Currency not recognized |
| `INVALID_BONUS_MULTIPLIER` | ERROR | Bonus multiplier outside valid range |
| `REWARD_MIN_INVALID` | ERROR | Minimum reward value invalid |
| `REWARD_MAX_INVALID` | ERROR | Maximum reward value invalid |
| `REWARD_AVG_INVALID` | ERROR | Average reward value invalid |
| `REWARD_MIN_GT_MAX` | ERROR | Minimum reward exceeds maximum |
| `TIME_BUDGET_OUT_OF_RANGE` | ERROR | Time budget outside valid range |
| `INVALID_TARGET_SEVERITY` | ERROR | Target severity not recognized |
| `TOO_MANY_FOCUS_AREAS` | ERROR | More than 20 focus areas |
| `TOO_MANY_EXCLUSIONS` | ERROR | More than 50 exclusions |
| `CONCURRENT_OUT_OF_RANGE` | ERROR | Concurrent programs outside valid range |
| `INVALID_RISK_TOLERANCE` | ERROR | Risk tolerance not recognized |
| `INVALID_EXPERIENCE_LEVEL` | ERROR | Experience level not recognized |
| `ROI_HOURS_OUT_OF_RANGE` | ERROR | ROI hours outside valid range |
| `MIN_BOUNTY_INVALID` | ERROR | Min bounty value invalid |
| `MAX_BOUNTY_INVALID` | ERROR | Max bounty value invalid |
| `BOUNTY_MIN_GT_MAX` | ERROR | Min bounty exceeds max bounty |
| `PROBABILITY_INVALID` | ERROR | Probability outside valid range |
| `INVALID_COMPETITION` | ERROR | Competition level not recognized |
| `LOW_EXPECTED_RATE` | WARNING | Expected hourly rate is very low |
| `HIGH_EXPECTED_RATE` | WARNING | Expected hourly rate unrealistically high |
| `EXCEEDS_TIME_BUDGET` | ERROR | Time investment exceeds budget |
| `EMPTY_SCOPE` | WARNING | Program scope is empty |
| `NO_WEB_ASSETS` | WARNING | No web assets in scope |
| `MOSTLY_OUT_OF_SCOPE` | WARNING | Most assets are out-of-scope |
| `TOO_MANY_COLLABORATORS` | ERROR | More than 20 collaborators |
| `MULTIPLE_LEADS` | ERROR | Multiple lead roles assigned |
| `NO_LEAD` | WARNING | No lead role assigned |
| `DUPLICATE_COLLABORATORS` | ERROR | Duplicate collaborators detected |
| `SLOW_RESPONSE_TIME` | WARNING | Response time above average |
| `NO_SCOPE` | WARNING | No scope defined |
| `NO_REWARDS` | WARNING | No reward structure defined |

---

## 9. Error Messages

```python
STRATEGY_ERROR_MESSAGES = {
    "INVALID_STRATEGY_TYPE": "Strategy type not recognized. Check the supported types list.",
    "INVALID_PLATFORM": "Platform not recognized. Supported: hackerone, bugcrowd, intigriti, immunefi, yeswehack, custom.",
    "PROGRAM_NAME_EMPTY": "Program name is required for identification.",
    "PROGRAM_NAME_TOO_LONG": "Program name must be 256 characters or fewer.",
    "INVALID_PROGRAM_TYPE": "Program type must be: public, private, vdp, invite_only, or response.",
    "SCOPE_TOO_LARGE": "Program scope cannot exceed 500 entries.",
    "INVALID_RESPONSE_TIME": "Response time must be between 1 and 365 days.",
    "INVALID_CURRENCY": "Currency must be: USD, EUR, GBP, BTC, or ETH.",
    "INVALID_BONUS_MULTIPLIER": "Bonus multiplier must be between 1 and 10.",
    "REWARD_MIN_INVALID": "Minimum reward must be between 0 and 1000000.",
    "REWARD_MAX_INVALID": "Maximum reward must be between 0 and 1000000.",
    "REWARD_AVG_INVALID": "Average reward must be between 0 and 1000000.",
    "REWARD_MIN_GT_MAX": "Minimum reward cannot exceed maximum reward.",
    "TIME_BUDGET_OUT_OF_RANGE": "Time budget must be between 0.5 and 720 hours.",
    "INVALID_TARGET_SEVERITY": "Target severity must be: low, medium, high, or critical.",
    "TOO_MANY_FOCUS_AREAS": "Cannot have more than 20 focus areas.",
    "TOO_MANY_EXCLUSIONS": "Cannot exclude more than 50 vulnerability types.",
    "CONCURRENT_OUT_OF_RANGE": "Concurrent programs must be between 1 and 50.",
    "INVALID_RISK_TOLERANCE": "Risk tolerance must be: conservative, moderate, or aggressive.",
    "INVALID_EXPERIENCE_LEVEL": "Experience level must be: beginner, intermediate, advanced, or expert.",
    "ROI_HOURS_OUT_OF_RANGE": "Time investment must be between 0.5 and 720 hours.",
    "MIN_BOUNTY_INVALID": "Minimum bounty must be between 0 and 1000000.",
    "MAX_BOUNTY_INVALID": "Maximum bounty must be between 0 and 1000000.",
    "BOUNTY_MIN_GT_MAX": "Minimum bounty cannot exceed maximum bounty.",
    "PROBABILITY_INVALID": "Probability of success must be between 0% and 100%.",
    "INVALID_COMPETITION": "Competition level must be: low, medium, high, or very_high.",
    "LOW_EXPECTED_RATE": "Expected hourly rate is very low. Consider alternative programs.",
    "HIGH_EXPECTED_RATE": "Expected hourly rate seems unrealistically high.",
    "EXCEEDS_TIME_BUDGET": "Time investment exceeds the allocated time budget.",
    "EMPTY_SCOPE": "Program scope is empty. Define in-scope assets.",
    "NO_WEB_ASSETS": "Scope has no web assets. Verify scope definition.",
    "MOSTLY_OUT_OF_SCOPE": "More assets are out-of-scope than in-scope.",
    "TOO_MANY_COLLABORATORS": "Cannot collaborate with more than 20 people.",
    "MULTIPLE_LEADS": "A collaboration can have at most one lead.",
    "NO_LEAD": "No lead role assigned. Consider assigning a lead.",
    "DUPLICATE_COLLABORATORS": "Duplicate collaborators detected. Remove duplicates.",
    "SLOW_RESPONSE_TIME": "Program response time is above average.",
    "NO_SCOPE": "No scope defined for this program.",
    "NO_REWARDS": "No reward structure defined for this program.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| S001 | Strategy type must be valid | ERROR | No |
| S002 | Platform must be recognized | ERROR | No |
| S003 | Program name must be 1-256 chars | ERROR | Truncate |
| S004 | Program type must be valid | ERROR | No |
| S005 | Scope must not exceed 500 entries | ERROR | Truncate |
| S006 | Response time must be 1-365 days | ERROR | No |
| S007 | Currency must be valid | ERROR | Default to USD |
| S008 | Bonus multiplier must be 1-10 | ERROR | Clamp |
| S009 | Reward ranges must be valid numbers | ERROR | No |
| S010 | Min reward must not exceed max | ERROR | Swap |
| S011 | Time budget must be 0.5-720 hours | ERROR | Clamp |
| S012 | Target severity values must be valid | ERROR | No |
| S013 | Focus areas max 20 | ERROR | Truncate |
| S014 | Exclusions max 50 | ERROR | Truncate |
| S015 | Concurrent programs must be 1-50 | ERROR | Clamp |
| S016 | Risk tolerance must be valid | ERROR | Default to moderate |
| S017 | Experience level must be valid | ERROR | Default to intermediate |
| S018 | ROI hours must be 0.5-720 | ERROR | Clamp |
| S019 | Probability must be 0-100% | ERROR | Clamp |
| S020 | Collaboration must have at most 1 lead | ERROR | No |

---

## 11. Domain File References

All 50 files in `Bug-Bounty-Program-Strategy/` that this validator covers:

| # | File | Strategy Type | Key Validation |
|---|------|---------------|----------------|
| 01 | `01-Program-Selection-Criteria.md` | program_selection | program, strategy |
| 02 | `02-Time-Management-Optimization.md` | time_management | strategy.time_budget |
| 03 | `03-ROI-Maximization-Strategies.md` | roi_maximization | roi config |
| 04 | `04-Program-Reputation-Analysis.md` | reputation_analysis | program.platform |
| 05 | `05-Reward-Structure-Evaluation.md` | reward_structure | program.rewards |
| 06 | `06-Scope-Assessment-Techniques.md` | scope_assessment | program.scope |
| 07 | `07-Response-Time-Analysis.md` | response_time | program.response_time |
| 08 | `08-Collaboration-Opportunities.md` | collaboration | collaboration config |
| 09 | `09-Private-vs-Public-Programs.md` | private_vs_public | program.program_type |
| 10 | `10-VDI-Program-Strategy.md` | vdi_program | program.program_type |
| 11 | `11-Seasonal-Program-Analysis.md` | seasonal_analysis | strategy params |
| 12 | `12-Program-Maturity-Assessment.md` | maturity_assessment | program.last_updated |
| 13 | `13-Reward-Trends-Analysis.md` | reward_trends | roi.historical_payouts |
| 14 | `14-Program-Scope-Expansion.md` | scope_expansion | program.scope |
| 15 | `15-Communication-Channel-Optimization.md` | communication_optimization | collaboration.channel |
| 16 | `16-Duplicate-Submission-Avoidance.md` | duplicate_avoidance | program, strategy |
| 17 | `17-Program-Specific-Rules.md` | program_rules | program.rules |
| 18 | `18-Reward-Negotiation-Tactics.md` | reward_negotiation | program.rewards |
| 19 | `19-Program-Health-Monitoring.md` | health_monitoring | program metrics |
| 20 | `20-Long-Term-Program-Relationships.md` | long_term_relationships | program history |
| 21 | `21-Program-Launch-Strategy.md` | program_launch | program config |
| 22 | `22-Competition-Analysis.md` | competition_analysis | roi.competition |
| 23 | `23-Program-Specialization.md` | program_specialization | strategy.focus |
| 24 | `24-Risk-Assessment-Per-Program.md` | risk_assessment | strategy.risk_tolerance |
| 25 | `25-Time-Zone-Optimization.md` | time_zone_optimization | strategy params |
| 26 | `26-Program-Diversity-Strategy.md` | program_diversity | strategy.concurrent |
| 27 | `27-Reward-Consistency-Analysis.md` | reward_consistency | roi.historical |
| 28 | `28-Program-Exit-Strategy.md` | exit_strategy | program health |
| 29 | `29-Program-Feedback-Analysis.md` | feedback_analysis | program feedback |
| 30 | `30-Advanced-Program-Intelligence.md` | advanced_intelligence | program intel |
| 31 | `31-Program-Network-Analysis.md` | network_analysis | program connections |
| 32 | `32-Collaboration-Network-Building.md` | collaboration_network | collaboration |
| 33 | `33-Program-Influence-Strategies.md` | program_influence | strategy influence |
| 34 | `34-Reward-Prediction-Models.md` | reward_prediction | roi predictions |
| 35 | `35-Program-Saturation-Analysis.md` | saturation_analysis | competition level |
| 36 | `36-Seasoned-Hunter-Advantages.md` | seasoned_hunter | experience_level |
| 37 | `37-Program-Trend-Forecasting.md` | trend_forecasting | roi trends |
| 38 | `38-Resource-Allocation-Strategy.md` | resource_allocation | strategy budget |
| 39 | `39-Program-Success-Metrics.md` | success_metrics | output metrics |
| 40 | `40-Advanced-Program-Selection.md` | advanced_selection | program selection |
| 41 | `41-Program-Relationship-Management.md` | relationship_management | program relation |
| 42 | `42-Collaboration-ROI-Analysis.md` | collaboration_roi | roi + collab |
| 43 | `43-Program-Discovery-Methods.md` | discovery_methods | program discovery |
| 44 | `44-Advanced-Scope-Analysis.md` | advanced_scope | program.scope |
| 45 | `45-Program-Performance-Tracking.md` | performance_tracking | program metrics |
| 46 | `46-Reward-Maximization-Framework.md` | reward_maximization | roi + rewards |
| 47 | `47-Program-Specialization-Deep-Dive.md` | specialization_deep_dive | strategy focus |
| 48 | `48-Time-Investment-ROI.md` | time_investment_roi | roi hours |
| 49 | `49-Program-Network-Optimization.md` | network_optimization | network config |
| 50 | `50-Advanced-Program-Strategy.md` | advanced_strategy | full config |

---

## 12. Validation Pipeline

```python
def validate_strategy_input(input_data):
    results = []
    results.append(("type", validate_strategy_type(input_data)))
    results.append(("program", validate_program_config(input_data)))
    results.append(("rewards", validate_reward_structure(input_data)))
    results.append(("strategy", validate_strategy_params(input_data)))
    results.append(("roi", validate_roi_config(input_data)))

    roi = input_data.get("roi", {})
    strategy = input_data.get("strategy", {})
    results.append(("roi_analysis", ValidationResult(
        valid=True, errors=validate_roi_analysis(roi, strategy)
    )))

    program = input_data.get("program", {})
    results.append(("scope", ValidationResult(
        valid=True, errors=validate_scope_completeness(program.get("scope", []))
    )))

    results.append(("program_health", ValidationResult(
        valid=True, errors=validate_program_health_metrics(program)
    )))

    collab = input_data.get("collaboration", {})
    results.append(("collaboration", ValidationResult(
        valid=True, errors=validate_collaboration_feasibility(collab)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "bug-bounty-program-strategy", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Strategy validation runs before any program analysis workflow
- ROI analysis provides real-time feasibility feedback
- Scope completeness checks warn about empty or limited scopes
- Collaboration feasibility checks ensure proper role assignment
- Program health metrics provide early warning indicators
- All validation results feed into the strategy recommendation engine
- Historical payout data is validated for statistical significance
- Time budget validation prevents over-commitment

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Bug Bounty Program Strategy domain |
