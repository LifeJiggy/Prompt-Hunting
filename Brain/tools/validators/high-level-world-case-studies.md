# High-Level World Case Studies — Input Validation Reference

**Domain**: High-Level World Case Studies (Critical Impact Analysis)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all analysis inputs across the High-Level-World-Case-Studies domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `high-level-world-case-studies` |
| Root Directory | `High-Level-World-Case-Studies/` |
| Total Files | 46 (+ README.md, registry.json) |
| Category | Critical Impact Assessment, Case Analysis, Disclosure Timelines |
| Input Surface | Case study parameters, impact assessments, analysis configs |

---

## 2. Overview

The High-Level World Case Studies validator enforces strict input validation for every case study analysis in the `High-Level-World-Case-Studies/` directory. Each file defines a critical impact analysis technique — from infrastructure breach to post-mortem analysis — and accepts structured inputs that must be validated before execution. This validator ensures:

- Case study parameters are properly structured
- Impact assessments use valid severity and impact metrics
- Timeline data is chronologically consistent
- Disclosure parameters follow responsible disclosure practices
- Reward analysis uses accurate financial data
- Collaboration parameters are properly configured
- All analysis inputs are within expected ranges

---

## 3. Schema Definition

### 3.1 Master Case Study Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "HighLevelCaseStudyInput",
  "type": "object",
  "required": ["domain", "analysis_type", "case_study"],
  "properties": {
    "domain": { "type": "string", "const": "high-level-world-case-studies" },
    "analysis_type": { "$ref": "#/definitions/AnalysisType" },
    "case_study": { "$ref": "#/definitions/CaseStudyConfig" },
    "impact": { "$ref": "#/definitions/ImpactAssessment" },
    "timeline": { "$ref": "#/definitions/TimelineConfig" },
    "disclosure": { "$ref": "#/definitions/DisclosureConfig" },
    "output": { "$ref": "#/definitions/AnalysisOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 AnalysisType Schema

```json
{
  "definitions": {
    "AnalysisType": {
      "type": "string",
      "enum": [
        "critical_infrastructure", "zero_day", "chain_analysis",
        "real_world_impact", "discovery_timeline", "reward_maximization",
        "report_quality", "triage_process", "program_response",
        "disclosure_timeline", "collaborative_hunting", "cross_program_patterns",
        "industry_specific", "mobile_vulnerability", "web_application",
        "api_security_breach", "cloud_configuration", "container_escape",
        "iot_compromise", "blockchain_bug", "cryptocurrency_exchange",
        "social_engineering", "physical_security", "network_infrastructure",
        "database_compromise", "file_system_attack", "authentication_bypass",
        "authorization_flaw", "session_management", "input_validation_failure",
        "business_logic_flaw", "information_disclosure", "weak_cryptography",
        "insecure_communication", "third_party_component", "supply_chain_attack",
        "zero_trust_bypass", "mfa_bypass", "privilege_escalation",
        "lateral_movement", "data_exfiltration", "persistence_mechanism",
        "anti_forensic", "incident_response_failure", "compliance_violation",
        "post_mortem"
      ]
    }
  }
}
```

### 3.3 CaseStudyConfig Schema

```json
{
  "definitions": {
    "CaseStudyConfig": {
      "type": "object",
      "required": ["name", "category"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "category": { "type": "string", "maxLength": 128 },
        "description": { "type": "string", "maxLength": 8192 },
        "target": { "type": "string", "maxLength": 1024 },
        "industry": { "type": "string", "maxLength": 128 },
        "date_discovered": { "type": "string", "format": "date" },
        "date_disclosed": { "type": "string", "format": "date" },
        "date_fixed": { "type": "string", "format": "date" },
        "researcher": { "type": "string", "maxLength": 256 },
        "program": { "type": "string", "maxLength": 256 },
        "platform": {
          "type": "string",
          "enum": ["hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "external", "internal"]
        },
        "cve": { "type": "string", "pattern": "^CVE-\\d{4}-\\d{4,}$" },
        "references": {
          "type": "array",
          "items": { "type": "string", "format": "uri" },
          "maxItems": 20
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ImpactAssessment Schema

```json
{
  "definitions": {
    "ImpactAssessment": {
      "type": "object",
      "properties": {
        "severity": {
          "type": "string",
          "enum": ["low", "medium", "high", "critical"]
        },
        "cvss_score": { "type": "number", "minimum": 0, "maximum": 10 },
        "cvss_vector": { "type": "string", "maxLength": 256 },
        "affected_users": { "type": "integer", "minimum": 0, "maximum": 10000000000 },
        "financial_impact_usd": { "type": "number", "minimum": 0, "maximum": 10000000000 },
        "data_exposed": {
          "type": "array",
          "items": {
            "type": "string",
            "enum": ["pii", "financial", "health", "credentials", "session", "internal", "source_code", "secrets"]
          },
          "maxItems": 10
        },
        "attack_vector": {
          "type": "string",
          "enum": ["network", "adjacent", "local", "physical"]
        },
        "attack_complexity": {
          "type": "string",
          "enum": ["low", "high"]
        },
        "confidentiality_impact": { "type": "string", "enum": ["none", "low", "high"] },
        "integrity_impact": { "type": "string", "enum": ["none", "low", "high"] },
        "availability_impact": { "type": "string", "enum": ["none", "low", "high"] },
        "blast_radius": { "type": "string", "enum": ["single_user", "multi_user", "organization", "industry", "global"] },
        "recoverability": { "type": "string", "enum": ["immediate", "hours", "days", "weeks", "irreversible"] }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 TimelineConfig Schema

```json
{
  "definitions": {
    "TimelineConfig": {
      "type": "object",
      "properties": {
        "events": {
          "type": "array",
          "items": { "$ref": "#/definitions/TimelineEvent" },
          "minItems": 1,
          "maxItems": 100
        },
        "total_duration_days": { "type": "integer", "minimum": 0, "maximum": 3650 },
        "disclosure_type": {
          "type": "string",
          "enum": ["coordinated", "full_disclosure", "limited", "zero_day", "unintended"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 TimelineEvent Schema

```json
{
  "definitions": {
    "TimelineEvent": {
      "type": "object",
      "required": ["date", "event"],
      "properties": {
        "date": { "type": "string", "format": "date" },
        "event": { "type": "string", "minLength": 5, "maxLength": 512 },
        "actor": { "type": "string", "maxLength": 128 },
        "action": {
          "type": "string",
          "enum": ["discovery", "reporting", "acknowledgment", "triage", "fix", "disclosure", "exploitation", "detection", "response"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 DisclosureConfig Schema

```json
{
  "definitions": {
    "DisclosureConfig": {
      "type": "object",
      "properties": {
        "policy": {
          "type": "string",
          "enum": ["responsible", "coordinated", "full_disclosure", "limited"]
        },
        "embargo_days": { "type": "integer", "minimum": 0, "maximum": 365, "default": 90 },
        "notification_channels": {
          "type": "array",
          "items": { "type": "string", "enum": ["email", "portal", "phone", "in_person"] },
          "maxItems": 5
        },
        "stakeholders": {
          "type": "array",
          "items": { "type": "string", "maxLength": 256 },
          "maxItems": 20
        },
        "legal_review_required": { "type": "boolean", "default": false },
        "public_disclosure_date": { "type": "string", "format": "date" }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.8 AnalysisOutput Schema

```json
{
  "definitions": {
    "AnalysisOutput": {
      "type": "object",
      "properties": {
        "format": { "type": "string", "enum": ["json", "markdown", "html", "pdf"] },
        "detail_level": { "type": "string", "enum": ["summary", "detailed", "comprehensive"], "default": "detailed" },
        "include_metrics": { "type": "boolean", "default": true },
        "include_charts": { "type": "boolean", "default": false },
        "destination": { "type": "string", "maxLength": 4096 }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateAnalysisType(input) → ValidationResult

```python
def validate_analysis_type(input_data):
    errors = []
    analysis_type = input_data.get("analysis_type", "")
    valid_types = [
        "critical_infrastructure", "zero_day", "chain_analysis",
        "real_world_impact", "discovery_timeline", "reward_maximization",
        "report_quality", "triage_process", "program_response",
        "disclosure_timeline", "collaborative_hunting", "cross_program_patterns",
        "industry_specific", "mobile_vulnerability", "web_application",
        "api_security_breach", "cloud_configuration", "container_escape",
        "iot_compromise", "blockchain_bug", "cryptocurrency_exchange",
        "social_engineering", "physical_security", "network_infrastructure",
        "database_compromise", "file_system_attack", "authentication_bypass",
        "authorization_flaw", "session_management", "input_validation_failure",
        "business_logic_flaw", "information_disclosure", "weak_cryptography",
        "insecure_communication", "third_party_component", "supply_chain_attack",
        "zero_trust_bypass", "mfa_bypass", "privilege_escalation",
        "lateral_movement", "data_exfiltration", "persistence_mechanism",
        "anti_forensic", "incident_response_failure", "compliance_violation",
        "post_mortem"
    ]
    if analysis_type not in valid_types:
        errors.append(ValidationError("INVALID_ANALYSIS_TYPE", f"Unknown analysis type: {analysis_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateCaseStudyConfig(input) → ValidationResult

```python
def validate_case_study_config(input_data):
    errors = []
    case = input_data.get("case_study", {})

    name = case.get("name", "")
    if not name:
        errors.append(ValidationError("CASE_NAME_EMPTY", "Case study name is required"))
    if len(name) > 256:
        errors.append(ValidationError("CASE_NAME_TOO_LONG", "Case study name exceeds 256 characters"))

    category = case.get("category", "")
    if not category:
        errors.append(ValidationError("CASE_CATEGORY_EMPTY", "Case study category is required"))
    if len(category) > 128:
        errors.append(ValidationError("CASE_CATEGORY_TOO_LONG", "Category exceeds 128 characters"))

    description = case.get("description", "")
    if len(description) > 8192:
        errors.append(ValidationError("DESCRIPTION_TOO_LONG", "Description exceeds 8192 characters"))

    target = case.get("target", "")
    if len(target) > 1024:
        errors.append(ValidationError("TARGET_TOO_LONG", "Target exceeds 1024 characters"))

    platform = case.get("platform", "")
    if platform and platform not in ("hackerone", "bugcrowd", "intigriti", "immunefi", "yeswehack", "external", "internal"):
        errors.append(ValidationError("INVALID_PLATFORM", f"Invalid platform: {platform}"))

    cve = case.get("cve", "")
    if cve and not re.match(r'^CVE-\d{4}-\d{4,}$', cve):
        errors.append(ValidationError("INVALID_CVE", f"Invalid CVE format: {cve}"))

    references = case.get("references", [])
    if len(references) > 20:
        errors.append(ValidationError("TOO_MANY_REFERENCES", "Cannot have more than 20 references"))

    date_discovered = case.get("date_discovered", "")
    date_disclosed = case.get("date_disclosed", "")
    date_fixed = case.get("date_fixed", "")

    if date_discovered and date_disclosed:
        if date_disclosed < date_discovered:
            errors.append(ValidationError("DISCLOSURE_BEFORE_DISCOVERY", "Disclosure date before discovery date"))
    if date_discovered and date_fixed:
        if date_fixed < date_discovered:
            errors.append(ValidationError("FIX_BEFORE_DISCOVERY", "Fix date before discovery date"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateImpactAssessment(input) → ValidationResult

```python
def validate_impact_assessment(input_data):
    errors = []
    impact = input_data.get("impact", {})
    if not impact:
        return ValidationResult(valid=True, errors=[])

    severity = impact.get("severity", "")
    if severity and severity not in ("low", "medium", "high", "critical"):
        errors.append(ValidationError("INVALID_SEVERITY", f"Invalid severity: {severity}"))

    cvss = impact.get("cvss_score", -1)
    if cvss != -1 and (cvss < 0 or cvss > 10):
        errors.append(ValidationError("CVSS_OUT_OF_RANGE", "CVSS score must be 0-10"))

    affected = impact.get("affected_users", 0)
    if affected < 0 or affected > 10000000000:
        errors.append(ValidationError("AFFECTED_USERS_INVALID", "Affected users must be 0-10 billion"))

    financial = impact.get("financial_impact_usd", 0)
    if financial < 0 or financial > 10000000000:
        errors.append(ValidationError("FINANCIAL_IMPACT_INVALID", "Financial impact must be 0-10 billion USD"))

    data_exposed = impact.get("data_exposed", [])
    valid_data_types = ["pii", "financial", "health", "credentials", "session", "internal", "source_code", "secrets"]
    for dt in data_exposed:
        if dt not in valid_data_types:
            errors.append(ValidationError("INVALID_DATA_TYPE", f"Invalid data type exposed: {dt}"))
    if len(data_exposed) > 10:
        errors.append(ValidationError("TOO_MANY_DATA_TYPES", "Cannot expose more than 10 data types"))

    attack_vector = impact.get("attack_vector", "")
    if attack_vector and attack_vector not in ("network", "adjacent", "local", "physical"):
        errors.append(ValidationError("INVALID_ATTACK_VECTOR", f"Invalid attack vector: {attack_vector}"))

    blast_radius = impact.get("blast_radius", "")
    if blast_radius and blast_radius not in ("single_user", "multi_user", "organization", "industry", "global"):
        errors.append(ValidationError("INVALID_BLAST_RADIUS", f"Invalid blast radius: {blast_radius}"))

    recoverability = impact.get("recoverability", "")
    if recoverability and recoverability not in ("immediate", "hours", "days", "weeks", "irreversible"):
        errors.append(ValidationError("INVALID_RECOVERABILITY", f"Invalid recoverability: {recoverability}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateTimelineConfig(input) → ValidationResult

```python
def validate_timeline_config(input_data):
    errors = []
    timeline = input_data.get("timeline", {})
    if not timeline:
        return ValidationResult(valid=True, errors=[])

    events = timeline.get("events", [])
    if not events:
        errors.append(ValidationError("NO_TIMELINE_EVENTS", "Timeline must have at least 1 event"))
    if len(events) > 100:
        errors.append(ValidationError("TOO_MANY_EVENTS", "Timeline cannot have more than 100 events"))

    dates = []
    for i, event in enumerate(events):
        event_date = event.get("date", "")
        if not event_date:
            errors.append(ValidationError("EVENT_DATE_EMPTY", f"Event {i} has no date"))
        else:
            dates.append(event_date)

        event_text = event.get("event", "")
        if not event_text:
            errors.append(ValidationError("EVENT_TEXT_EMPTY", f"Event {i} has no description"))
        if len(event_text) > 512:
            errors.append(ValidationError("EVENT_TEXT_TOO_LONG", f"Event {i} description exceeds 512 chars"))

        action = event.get("action", "")
        valid_actions = ["discovery", "reporting", "acknowledgment", "triage", "fix", "disclosure", "exploitation", "detection", "response"]
        if action and action not in valid_actions:
            errors.append(ValidationError("INVALID_EVENT_ACTION", f"Event {i} has invalid action: {action}"))

    if len(dates) > 1:
        sorted_dates = sorted(dates)
        if dates != sorted_dates:
            errors.append(ValidationWarning(
                "TIMELINE_NOT_CHRONOLOGICAL",
                "Timeline events are not in chronological order"
            ))

    disclosure_type = timeline.get("disclosure_type", "")
    if disclosure_type and disclosure_type not in ("coordinated", "full_disclosure", "limited", "zero_day", "unintended"):
        errors.append(ValidationError("INVALID_DISCLOSURE_TYPE", f"Invalid disclosure type: {disclosure_type}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeCaseName(name) → str

```python
def sanitize_case_name(name):
    name = name.strip()
    name = re.sub(r'[<>"\';\\]', '', name)
    return name[:256]
```

### 5.2 sanitizeCaseDescription(description) → str

```python
def sanitize_case_description(description):
    description = description.strip()
    description = description[:8192]
    description = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', description)
    return description
```

### 5.3 sanitizeTimelineEvents(events) → list

```python
def sanitize_timeline_events(events):
    sanitized = []
    for event in events[:100]:
        if not isinstance(event, dict):
            continue
        event["event"] = str(event.get("event", ""))[:512].strip()
        event["event"] = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', event["event"])
        event["actor"] = str(event.get("actor", ""))[:128].strip()
        event["date"] = str(event.get("date", ""))[:10]
        sanitized.append(event)
    return sanitized
```

### 5.4 sanitizeDisclosureConfig(disclosure) → dict

```python
def sanitize_disclosure_config(disclosure):
    disclosure["policy"] = disclosure.get("policy", "responsible")
    if disclosure["policy"] not in ("responsible", "coordinated", "full_disclosure", "limited"):
        disclosure["policy"] = "responsible"
    disclosure["embargo_days"] = max(0, min(365, disclosure.get("embargo_days", 90)))
    channels = disclosure.get("notification_channels", [])
    valid_channels = ["email", "portal", "phone", "in_person"]
    disclosure["notification_channels"] = [c for c in channels if c in valid_channels][:5]
    stakeholders = disclosure.get("stakeholders", [])
    disclosure["stakeholders"] = [re.sub(r'[<>"\';\\]', '', str(s))[:256] for s in stakeholders[:20]]
    return disclosure
```

---

## 6. Type Coercion

### 6.1 coerceAnalysisType(raw_type) → str

```python
ANALYSIS_TYPE_MAP = {
    "infrastructure": "critical_infrastructure",
    "zero_day": "zero_day", "0day": "zero_day",
    "chain": "chain_analysis", "chaining": "chain_analysis",
    "impact": "real_world_impact",
    "timeline": "discovery_timeline",
    "reward": "reward_maximization", "bounty": "reward_maximization",
    "report": "report_quality",
    "triage": "triage_process",
    "program": "program_response",
    "disclosure": "disclosure_timeline",
    "collab": "collaborative_hunting",
    "cross_program": "cross_program_patterns",
    "industry": "industry_specific",
    "mobile": "mobile_vulnerability",
    "web": "web_application",
    "api": "api_security_breach",
    "cloud": "cloud_configuration",
    "container": "container_escape",
    "iot": "iot_compromise",
    "blockchain": "blockchain_bug",
    "crypto_exchange": "cryptocurrency_exchange",
    "social": "social_engineering",
    "physical": "physical_security",
    "network": "network_infrastructure",
    "database": "database_compromise",
    "file": "file_system_attack",
    "auth_bypass": "authentication_bypass",
    "authz": "authorization_flaw",
    "session": "session_management",
    "input": "input_validation_failure",
    "logic": "business_logic_flaw",
    "info_disc": "information_disclosure",
    "crypto_weak": "weak_cryptography",
    "insecure_comm": "insecure_communication",
    "third_party": "third_party_component",
    "supply_chain": "supply_chain_attack",
    "zero_trust": "zero_trust_bypass",
    "mfa": "mfa_bypass",
    "privesc": "privilege_escalation",
    "lateral": "lateral_movement",
    "exfil": "data_exfiltration",
    "persist": "persistence_mechanism",
    "anti_forensic": "anti_forensic",
    "ir_failure": "incident_response_failure",
    "compliance": "compliance_violation",
    "postmortem": "post_mortem"
}

def coerce_analysis_type(raw_type):
    return ANALYSIS_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceCVSSScore(score) → float

```python
def coerce_cvss_score(score):
    try:
        score = float(score)
    except (ValueError, TypeError):
        return 0.0
    return max(0.0, min(10.0, score))
```

### 6.3 coerceFinancialImpact(impact) → float

```python
def coerce_financial_impact(impact):
    try:
        impact = float(impact)
    except (ValueError, TypeError):
        return 0.0
    return max(0.0, min(10000000000.0, impact))
```

### 6.4 coerceBooleanFields(params, fields) → dict

```python
def coerce_boolean_fields(params, fields):
    true_vals = {"true", "1", "yes", "on"}
    for field in fields:
        if field in params:
            val = params[field]
            if not isinstance(val, bool):
                params[field] = str(val).lower().strip() in true_vals
    return params
```

---

## 7. Custom Validators

### 7.1 validateCVSSSeverityConsistency(impact) → list

```python
CVSS_SEVERITY_RANGES = {
    "low": (0.1, 3.9),
    "medium": (4.0, 6.9),
    "high": (7.0, 8.9),
    "critical": (9.0, 10.0)
}

def validate_cvss_severity_consistency(impact):
    errors = []
    severity = impact.get("severity", "")
    cvss = impact.get("cvss_score", -1)

    if severity and cvss >= 0:
        expected_range = CVSS_SEVERITY_RANGES.get(severity, (0, 10))
        if cvss < expected_range[0] or cvss > expected_range[1]:
            errors.append(ValidationWarning(
                "CVSS_SEVERITY_MISMATCH",
                f"CVSS score {cvss} does not match severity '{severity}'"
            ))
    return errors
```

### 7.2 validateTimelineChronology(timeline) → list

```python
def validate_timeline_chronology(timeline):
    errors = []
    events = timeline.get("events", [])

    if len(events) < 2:
        return errors

    dates = []
    for event in events:
        date_str = event.get("date", "")
        if date_str:
            try:
                date_obj = datetime.strptime(date_str, "%Y-%m-%d")
                dates.append((date_obj, event.get("event", "")))
            except ValueError:
                errors.append(ValidationError("INVALID_DATE_FORMAT", f"Invalid date: {date_str}"))

    if len(dates) >= 2:
        for i in range(1, len(dates)):
            if dates[i][0] < dates[i-1][0]:
                errors.append(ValidationWarning(
                    "OUT_OF_ORDER_EVENT",
                    f"Event '{dates[i][1]}' occurs before '{dates[i-1][1]}'"
                ))

    return errors
```

### 7.3 validateImpactSeverityReasonableness(impact) → list

```python
def validate_impact_severity_reasonableness(impact):
    errors = []
    affected = impact.get("affected_users", 0)
    financial = impact.get("financial_impact_usd", 0)
    severity = impact.get("severity", "")
    blast_radius = impact.get("blast_radius", "")

    if severity == "critical" and blast_radius == "single_user" and affected < 100:
        errors.append(ValidationWarning(
            "CRITICAL_SINGLE_USER",
            "Critical severity for single-user impact seems excessive"
        ))

    if severity == "low" and financial > 1000000:
        errors.append(ValidationWarning(
            "LOW_SEVERITY_HIGH_FINANCIAL",
            "Low severity with high financial impact seems inconsistent"
        ))

    if blast_radius == "global" and severity not in ("high", "critical"):
        errors.append(ValidationWarning(
            "GLOBAL_LOW_SEVERITY",
            "Global blast radius should typically be high or critical severity"
        ))

    return errors
```

### 7.4 validateDisclosureResponsibility(disclosure) → list

```python
def validate_disclosure_responsibility(disclosure):
    errors = []
    if not disclosure:
        return errors

    policy = disclosure.get("policy", "responsible")
    embargo = disclosure.get("embargo_days", 90)
    legal_review = disclosure.get("legal_review_required", False)

    if policy == "full_disclosure" and not legal_review:
        errors.append(ValidationWarning(
            "FULL_DISCLOSURE_NO_LEGAL",
            "Full disclosure without legal review is risky"
        ))

    if embargo < 30 and policy != "full_disclosure":
        errors.append(ValidationWarning(
            "SHORT_EMBARGO",
            f"Embargo of {embargo} days may be insufficient for vendor remediation"
        ))

    stakeholders = disclosure.get("stakeholders", [])
    if not stakeholders:
        errors.append(ValidationWarning(
            "NO_STAKEHOLDERS",
            "No stakeholders defined for disclosure"
        ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_ANALYSIS_TYPE` | ERROR | Analysis type not recognized |
| `CASE_NAME_EMPTY` | ERROR | Case study name is required |
| `CASE_NAME_TOO_LONG` | ERROR | Case name exceeds 256 characters |
| `CASE_CATEGORY_EMPTY` | ERROR | Case category is required |
| `CASE_CATEGORY_TOO_LONG` | ERROR | Category exceeds 128 characters |
| `DESCRIPTION_TOO_LONG` | ERROR | Description exceeds 8192 characters |
| `TARGET_TOO_LONG` | ERROR | Target exceeds 1024 characters |
| `INVALID_PLATFORM` | ERROR | Platform not recognized |
| `INVALID_CVE` | ERROR | CVE format invalid |
| `TOO_MANY_REFERENCES` | ERROR | More than 20 references |
| `DISCLOSURE_BEFORE_DISCOVERY` | ERROR | Disclosure date before discovery |
| `FIX_BEFORE_DISCOVERY` | ERROR | Fix date before discovery |
| `INVALID_SEVERITY` | ERROR | Severity not recognized |
| `CVSS_OUT_OF_RANGE` | ERROR | CVSS score outside 0-10 |
| `AFFECTED_USERS_INVALID` | ERROR | Affected users outside valid range |
| `FINANCIAL_IMPACT_INVALID` | ERROR | Financial impact outside valid range |
| `INVALID_DATA_TYPE` | ERROR | Data type not recognized |
| `TOO_MANY_DATA_TYPES` | ERROR | More than 10 data types |
| `INVALID_ATTACK_VECTOR` | ERROR | Attack vector not recognized |
| `INVALID_BLAST_RADIUS` | ERROR | Blast radius not recognized |
| `INVALID_RECOVERABILITY` | ERROR | Recoverability not recognized |
| `NO_TIMELINE_EVENTS` | ERROR | Timeline must have at least 1 event |
| `TOO_MANY_EVENTS` | ERROR | Timeline cannot have more than 100 events |
| `EVENT_DATE_EMPTY` | ERROR | Event has no date |
| `EVENT_TEXT_EMPTY` | ERROR | Event has no description |
| `EVENT_TEXT_TOO_LONG` | ERROR | Event description exceeds 512 chars |
| `INVALID_EVENT_ACTION` | ERROR | Event action not recognized |
| `INVALID_DISCLOSURE_TYPE` | ERROR | Disclosure type not recognized |
| `CVSS_SEVERITY_MISMATCH` | WARNING | CVSS score doesn't match severity |
| `TIMELINE_NOT_CHRONOLOGICAL` | WARNING | Events not in chronological order |
| `OUT_OF_ORDER_EVENT` | WARNING | Event occurs before previous event |
| `CRITICAL_SINGLE_USER` | WARNING | Critical severity for single-user impact |
| `LOW_SEVERITY_HIGH_FINANCIAL` | WARNING | Low severity with high financial impact |
| `GLOBAL_LOW_SEVERITY` | WARNING | Global blast radius with low severity |
| `FULL_DISCLOSURE_NO_LEGAL` | WARNING | Full disclosure without legal review |
| `SHORT_EMBARGO` | WARNING | Embargo may be insufficient |
| `NO_STAKEHOLDERS` | WARNING | No stakeholders defined |

---

## 9. Error Messages

```python
CASE_STUDY_ERROR_MESSAGES = {
    "INVALID_ANALYSIS_TYPE": "Analysis type not recognized. Check the supported types list.",
    "CASE_NAME_EMPTY": "Case study name is required.",
    "CASE_NAME_TOO_LONG": "Case study name must be 256 characters or fewer.",
    "CASE_CATEGORY_EMPTY": "Case study category is required.",
    "CASE_CATEGORY_TOO_LONG": "Category must be 128 characters or fewer.",
    "DESCRIPTION_TOO_LONG": "Description must be 8192 characters or fewer.",
    "TARGET_TOO_LONG": "Target must be 1024 characters or fewer.",
    "INVALID_PLATFORM": "Platform not recognized.",
    "INVALID_CVE": "CVE format must be CVE-YYYY-NNNNN.",
    "TOO_MANY_REFERENCES": "Cannot have more than 20 references.",
    "DISCLOSURE_BEFORE_DISCOVERY": "Disclosure date cannot be before discovery date.",
    "FIX_BEFORE_DISCOVERY": "Fix date cannot be before discovery date.",
    "INVALID_SEVERITY": "Severity must be: low, medium, high, or critical.",
    "CVSS_OUT_OF_RANGE": "CVSS score must be between 0 and 10.",
    "AFFECTED_USERS_INVALID": "Affected users must be between 0 and 10 billion.",
    "FINANCIAL_IMPACT_INVALID": "Financial impact must be between 0 and 10 billion USD.",
    "INVALID_DATA_TYPE": "Data type not recognized.",
    "TOO_MANY_DATA_TYPES": "Cannot expose more than 10 data types.",
    "INVALID_ATTACK_VECTOR": "Attack vector must be: network, adjacent, local, or physical.",
    "INVALID_BLAST_RADIUS": "Blast radius not recognized.",
    "INVALID_RECOVERABILITY": "Recoverability not recognized.",
    "NO_TIMELINE_EVENTS": "Timeline must have at least 1 event.",
    "TOO_MANY_EVENTS": "Timeline cannot have more than 100 events.",
    "EVENT_DATE_EMPTY": "Each event must have a date.",
    "EVENT_TEXT_EMPTY": "Each event must have a description.",
    "EVENT_TEXT_TOO_LONG": "Event description must be 512 characters or fewer.",
    "INVALID_EVENT_ACTION": "Event action not recognized.",
    "INVALID_DISCLOSURE_TYPE": "Disclosure type not recognized.",
    "CVSS_SEVERITY_MISMATCH": "CVSS score does not match the assigned severity.",
    "TIMELINE_NOT_CHRONOLOGICAL": "Timeline events are not in chronological order.",
    "OUT_OF_ORDER_EVENT": "Event occurs before the previous event.",
    "CRITICAL_SINGLE_USER": "Critical severity for single-user impact seems excessive.",
    "LOW_SEVERITY_HIGH_FINANCIAL": "Low severity with high financial impact is inconsistent.",
    "GLOBAL_LOW_SEVERITY": "Global blast radius should typically be high or critical severity.",
    "FULL_DISCLOSURE_NO_LEGAL": "Full disclosure without legal review is risky.",
    "SHORT_EMBARGO": "Embargo may be insufficient for vendor remediation.",
    "NO_STAKEHOLDERS": "No stakeholders defined for disclosure.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| CS001 | Analysis type must be valid | ERROR | No |
| CS002 | Case name must be 1-256 chars | ERROR | Truncate |
| CS003 | Case category is required | ERROR | No |
| CS004 | Description max 8192 chars | ERROR | Truncate |
| CS005 | CVE format must be valid | ERROR | No |
| CS006 | References max 20 | ERROR | Truncate |
| CS007 | Dates must be chronological | WARNING | No |
| CS008 | Severity must be valid | ERROR | No |
| CS009 | CVSS must be 0-10 | ERROR | Clamp |
| CS010 | Financial impact must be 0-10B | ERROR | Clamp |
| CS011 | Data types max 10 | ERROR | Truncate |
| CS012 | Timeline events max 100 | ERROR | Truncate |
| CS013 | Events must have date and text | ERROR | No |
| CS014 | Event actions must be valid | ERROR | No |
| CS015 | CVSS should match severity | WARNING | No |
| CS016 | Impact severity should be reasonable | WARNING | No |
| CS017 | Disclosure should be responsible | WARNING | No |
| CS018 | Embargo should be >= 30 days | WARNING | No |
| CS019 | Stakeholders should be defined | WARNING | No |
| CS020 | Full disclosure needs legal review | WARNING | No |

---

## 11. Domain File References

All 46 files in `High-Level-World-Case-Studies/` that this validator covers:

| # | File | Analysis Type | Key Validation |
|---|------|---------------|----------------|
| 05 | `05-Critical-Infrastructure-Breach.md` | critical_infrastructure | impact, timeline |
| 06 | `06-Zero-Day-Exploitation-Case.md` | zero_day | impact, disclosure |
| 07 | `07-Chain-of-Vulnerabilities.md` | chain_analysis | case_study |
| 08 | `08-Real-World-Impact-Assessment.md` | real_world_impact | impact |
| 09 | `09-Timeline-from-Discovery-to-Fix.md` | discovery_timeline | timeline |
| 10 | `10-Reward-Maximization-Strategies.md` | reward_maximization | case_study |
| 11 | `11-Report-Quality-Analysis.md` | report_quality | case_study |
| 12 | `12-Triage-Process-Understanding.md` | triage_process | case_study |
| 13 | `13-Program-Response-Analysis.md` | program_response | case_study |
| 14 | `14-Disclosure-Timeline-Study.md` | disclosure_timeline | disclosure, timeline |
| 15 | `15-Collaborative-Hunting-Case.md` | collaborative_hunting | case_study |
| 16 | `16-Cross-Program-Vulnerability-Patterns.md` | cross_program_patterns | case_study |
| 17 | `17-Industry-Specific-Findings.md` | industry_specific | case_study.industry |
| 18 | `18-Mobile-App-Vulnerability-Case.md` | mobile_vulnerability | case_study |
| 19 | `19-Web-Application-Security-Case.md` | web_application | case_study |
| 20 | `20-API-Security-Breach-Analysis.md` | api_security_breach | impact |
| 21 | `21-Cloud-Configuration-Error.md` | cloud_configuration | impact |
| 22 | `22-Container-Escape-Case-Study.md` | container_escape | impact |
| 23 | `23-IoT-Device-Compromise.md` | iot_compromise | case_study |
| 24 | `24-Blockchain-Smart-Contract-Bug.md` | blockchain_bug | impact |
| 25 | `25-Cryptocurrency-Exchange-Hack.md` | cryptocurrency_exchange | impact |
| 26 | `26-Social-Engineering-Success.md` | social_engineering | case_study |
| 27 | `27-Physical-Security-Bypass.md` | physical_security | case_study |
| 28 | `28-Network-Infrastructure-Attack.md` | network_infrastructure | impact |
| 29 | `29-Database-Compromise-Case.md` | database_compromise | impact |
| 30 | `30-File-System-Attack-Analysis.md` | file_system_attack | case_study |
| 31 | `31-Authentication-Bypass-Case.md` | authentication_bypass | impact |
| 32 | `32-Authorization-Flaw-Study.md` | authorization_flaw | impact |
| 33 | `33-Session-Management-Issue.md` | session_management | case_study |
| 34 | `34-Input-Validation-Failure.md` | input_validation_failure | case_study |
| 35 | `35-Business-Logic-Flaw-Analysis.md` | business_logic_flaw | case_study |
| 36 | `36-Information-Disclosure-Case.md` | information_disclosure | impact |
| 37 | `37-Weak-Cryptography-Example.md` | weak_cryptography | case_study |
| 38 | `38-Insecure-Communication-Study.md` | insecure_communication | case_study |
| 39 | `39-Third-Party-Component-Vulnerability.md` | third_party_component | case_study |
| 40 | `40-Supply-Chain-Attack-Case.md` | supply_chain_attack | impact |
| 41 | `41-Zero-Trust-Bypass-Analysis.md` | zero_trust_bypass | impact |
| 42 | `42-Multi-Factor-Authentication-Bypass.md` | mfa_bypass | impact |
| 43 | `43-Privilege-Escalation-Case.md` | privilege_escalation | impact |
| 44 | `44-Lateral-Movement-Study.md` | lateral_movement | timeline |
| 45 | `45-Data-Exfiltration-Method.md` | data_exfiltration | impact |
| 46 | `46-Persistence-Mechanism-Analysis.md` | persistence_mechanism | case_study |
| 47 | `47-Anti-Forensic-Technique-Study.md` | anti_forensic | case_study |
| 48 | `48-Incident-Response-Failure.md` | incident_response_failure | timeline |
| 49 | `49-Compliance-Violation-Case.md` | compliance_violation | case_study |
| 50 | `50-Post-Mortem-Analysis.md` | post_mortem | timeline, impact |

---

## 12. Validation Pipeline

```python
def validate_high_level_case_study_input(input_data):
    results = []
    results.append(("analysis_type", validate_analysis_type(input_data)))
    results.append(("case_study", validate_case_study_config(input_data)))
    results.append(("impact", validate_impact_assessment(input_data)))
    results.append(("timeline", validate_timeline_config(input_data)))

    impact = input_data.get("impact", {})
    results.append(("cvss_consistency", ValidationResult(
        valid=True, errors=validate_cvss_severity_consistency(impact)
    )))

    results.append(("severity_reasonableness", ValidationResult(
        valid=True, errors=validate_impact_severity_reasonableness(impact)
    )))

    timeline = input_data.get("timeline", {})
    results.append(("timeline_chronology", ValidationResult(
        valid=True, errors=validate_timeline_chronology(timeline)
    )))

    disclosure = input_data.get("disclosure", {})
    results.append(("disclosure_responsibility", ValidationResult(
        valid=True, errors=validate_disclosure_responsibility(disclosure)
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "high-level-world-case-studies", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Case study validation runs before any analysis workflow
- CVSS-severity consistency checks detect scoring errors
- Timeline chronology validation detects out-of-order events
- Impact reasonableness checks warn about inconsistent assessments
- Disclosure responsibility checks ensure responsible practices
- All date fields are validated for chronological consistency
- Financial impact is clamped to prevent overflow
- All validation results are logged for analysis audit trail

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for High-Level World Case Studies domain |
