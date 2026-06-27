# Core Prompts Learning — Schema Validation Reference

**Domain**: Core Prompts Learning (Security Learning Prompts)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define schema validation rules, type validation, range validation, pattern matching, custom validators, sanitization, coercion, and error handling for all learning prompt inputs across the Core-Prompts-Learning domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `core-prompts-learning` |
| Root Directory | `Core-Prompts-Learning/` |
| Total Files | 50 |
| Category | Security Learning, Vulnerability Education, Concept Explanation |
| Input Surface | Learning topic configs, difficulty levels, concept parameters, quiz inputs |

---

## 2. Overview

The Core Prompts Learning validator enforces strict schema validation for all security learning inputs. Each file defines a learning prompt for a specific vulnerability class — from reconnaissance to advanced threat modeling — and accepts structured inputs that must be validated to ensure effective knowledge transfer. This validator ensures:

- Learning topics are valid and properly categorized
- Difficulty levels are appropriate for the content
- Concept parameters match expected formats
- Quiz and assessment inputs are well-structured
- Learning objectives are clearly defined
- Progress tracking parameters are valid

---

## 3. Schema Definition

### 3.1 Master Learning Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CoreLearningInput",
  "type": "object",
  "required": ["domain", "topic", "learning_config"],
  "properties": {
    "domain": { "type": "string", "const": "core-prompts-learning" },
    "topic": { "$ref": "#/definitions/LearningTopic" },
    "learning_config": { "$ref": "#/definitions/LearningConfig" },
    "content": { "$ref": "#/definitions/ContentConfig" },
    "assessment": { "$ref": "#/definitions/AssessmentConfig" },
    "progress": { "$ref": "#/definitions/ProgressConfig" }
  },
  "additionalProperties": false
}
```

### 3.2 LearningTopic Schema

```json
{
  "definitions": {
    "LearningTopic": {
      "type": "object",
      "required": ["name", "category"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "category": {
          "type": "string",
          "enum": [
            "reconnaissance", "javascript_analysis", "api_analysis",
            "authentication", "authorization", "input_validation",
            "cryptography", "client_storage", "business_logic",
            "error_handling", "file_upload", "ssrf", "xss",
            "csrf", "cors", "race_condition", "third_party",
            "config_hunting", "network_security", "mobile_api",
            "reporting", "waf_bypass", "http_smuggling",
            "xxe", "ssti", "command_injection", "nosql_injection",
            "jwt_vulnerabilities", "graphql", "websocket",
            "deserialization", "host_header", "subdomain_takeover",
            "session_puzzling", "clickjacking", "ldap_injection",
            "xpath_injection", "prototype_pollution", "http_response_splitting",
            "parameter_pollution", "csp_bypass", "xssi",
            "insecure_file_handling", "reverse_engineering",
            "threat_modeling", "compliance", "cloud_security",
            "blockchain_security", "iot_security", "webassembly"
          ]
        },
        "difficulty": { "type": "string", "enum": ["beginner", "intermediate", "advanced", "expert"], "default": "intermediate" },
        "tags": { "type": "array", "items": { "type": "string" }, "maxItems": 20 },
        "description": { "type": "string", "maxLength": 4096 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.3 LearningConfig Schema

```json
{
  "definitions": {
    "LearningConfig": {
      "type": "object",
      "properties": {
        "learning_style": { "type": "string", "enum": ["conceptual", "hands_on", "mixed", "theoretical"], "default": "mixed" },
        "estimated_duration_minutes": { "type": "integer", "minimum": 5, "maximum": 480, "default": 60 },
        "prerequisites": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "learning_objectives": {
          "type": "array",
          "items": { "type": "string", "maxLength": 512 },
          "minItems": 1,
          "maxItems": 20
        },
        "include_code_examples": { "type": "boolean", "default": true },
        "include_real_world": { "type": "boolean", "default": true },
        "include防御措施": { "type": "boolean", "default": true },
        "language": { "type": "string", "enum": ["en", "zh", "es", "fr", "de", "ja", "ko", "pt", "ru"], "default": "en" },
        "output_format": { "type": "string", "enum": ["markdown", "html", "plain_text"], "default": "markdown" }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 ContentConfig Schema

```json
{
  "definitions": {
    "ContentConfig": {
      "type": "object",
      "properties": {
        "sections": {
          "type": "array",
          "items": {
            "type": "object",
            "required": ["title", "type"],
            "properties": {
              "title": { "type": "string", "minLength": 1, "maxLength": 256 },
              "type": { "type": "string", "enum": ["explanation", "example", "exercise", "quiz", "case_study", "code_review", "lab"] },
              "content": { "type": "string", "maxLength": 65536 },
              "difficulty": { "type": "string", "enum": ["easy", "medium", "hard"] },
              "time_minutes": { "type": "integer", "minimum": 1, "maximum": 120 }
            }
          },
          "maxItems": 50
        },
        "include_diagrams": { "type": "boolean", "default": false },
        "include_videos": { "type": "boolean", "default": false },
        "max_content_length": { "type": "integer", "minimum": 1000, "maximum": 500000, "default": 50000 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 AssessmentConfig Schema

```json
{
  "definitions": {
    "AssessmentConfig": {
      "type": "object",
      "properties": {
        "enabled": { "type": "boolean", "default": false },
        "type": { "type": "string", "enum": ["quiz", "practical", "essay", "mixed"], "default": "quiz" },
        "passing_score_percent": { "type": "number", "minimum": 0, "maximum": 100, "default": 70 },
        "max_questions": { "type": "integer", "minimum": 1, "maximum": 100, "default": 10 },
        "time_limit_minutes": { "type": "integer", "minimum": 5, "maximum": 180, "default": 30 },
        "allow_retakes": { "type": "boolean", "default": true },
        "max_retakes": { "type": "integer", "minimum": 1, "maximum": 10, "default": 3 },
        "question_types": {
          "type": "array",
          "items": { "type": "string", "enum": ["multiple_choice", "true_false", "fill_blank", "code_review", "short_answer"] },
          "maxItems": 5
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 ProgressConfig Schema

```json
{
  "definitions": {
    "ProgressConfig": {
      "type": "object",
      "properties": {
        "track_progress": { "type": "boolean", "default": true },
        "save_checkpoints": { "type": "boolean", "default": true },
        "checkpoint_interval_minutes": { "type": "integer", "minimum": 5, "maximum": 120, "default": 15 },
        "resume_from_checkpoint": { "type": "boolean", "default": false },
        "checkpoint_id": { "type": "string", "maxLength": 128 }
      },
      "additionalProperties": false
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateLearningTopic(input) → ValidationResult

```python
def validate_learning_topic(input_data):
    errors = []
    topic = input_data.get("topic", {})

    if not topic.get("name"):
        errors.append(ValidationError("TOPIC_NAME_EMPTY", "Topic name is required"))
    if len(topic.get("name", "")) > 256:
        errors.append(ValidationError("TOPIC_NAME_TOO_LONG", "Topic name exceeds 256 characters"))
    if not topic.get("category"):
        errors.append(ValidationError("TOPIC_CATEGORY_MISSING", "Topic category is required"))

    tags = topic.get("tags", [])
    if len(tags) > 20:
        errors.append(ValidationError("TOO_MANY_TAGS", "Topic cannot have more than 20 tags"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateLearningConfig(input) → list

```python
def validate_learning_config(input_data):
    errors = []
    config = input_data.get("learning_config", {})

    duration = config.get("estimated_duration_minutes", 60)
    if duration > 240 and config.get("difficulty") == "beginner":
        errors.append(ValidationError(
            "DURATION_TOO_LONG_BEGINNER",
            "Beginner topics should be <= 240 minutes"
        ))

    objectives = config.get("learning_objectives", [])
    if not objectives:
        errors.append(ValidationError("NO_LEARNING_OBJECTIVES", "At least one learning objective is required"))
    if len(objectives) > 20:
        errors.append(ValidationError("TOO_MANY_OBJECTIVES", "Cannot exceed 20 learning objectives"))

    return errors
```

### 4.3 validateAssessmentConfig(input) → list

```python
def validate_assessment_config(input_data):
    errors = []
    assessment = input_data.get("assessment", {})
    if not assessment or not assessment.get("enabled", False):
        return errors

    passing_score = assessment.get("passing_score_percent", 70)
    if passing_score < 50:
        errors.append(ValidationError(
            "PASSING_SCORE_TOO_LOW",
            "Passing score should be >= 50%"
        ))

    max_questions = assessment.get("max_questions", 10)
    time_limit = assessment.get("time_limit_minutes", 30)
    if max_questions > 50 and time_limit < 15:
        errors.append(ValidationError(
            "INSUFFICIENT_TIME",
            f"Time limit ({time_limit}min) is too short for {max_questions} questions"
        ))

    return errors
```

---

## 5. Sanitize Operations

### 5.1 sanitizeTopicName(name) → string

```python
def sanitize_topic_name(name):
    name = re.sub(r'[<>"\';\\]', '', name)
    return name[:256]
```

### 5.2 sanitizeContent(content) → string

```python
def sanitize_content(content):
    content = re.sub(r'<script[^>]*>.*?</script>', '', content, flags=re.DOTALL)
    content = re.sub(r'javascript:', '', content, flags=re.IGNORECASE)
    content = content[:500000]
    return content
```

---

## 6. Type Coercion

### 6.1 coerceDifficulty(raw_value) → string

```python
def coerce_difficulty(raw_value):
    raw_value = str(raw_value).lower().strip()
    diff_map = {
        "beginner": "beginner", "basic": "beginner", "novice": "beginner",
        "intermediate": "intermediate", "medium": "intermediate", "mid": "intermediate",
        "advanced": "advanced", "hard": "advanced", "expert": "expert",
        "master": "expert", "professional": "expert"
    }
    return diff_map.get(raw_value, "intermediate")
```

### 6.2 coerceLearningStyle(raw_value) → string

```python
def coerce_learning_style(raw_value):
    raw_value = str(raw_value).lower().strip().replace(" ", "_")
    style_map = {
        "conceptual": "conceptual", "theory": "conceptual", "theoretical": "theoretical",
        "hands_on": "hands_on", "practical": "hands_on", "lab": "hands_on",
        "mixed": "mixed", "balanced": "mixed", "hybrid": "mixed"
    }
    return style_map.get(raw_value, "mixed")
```

---

## 7. Custom Validators

### 7.1 validatePrerequisiteChain(config) → list

```python
def validate_prerequisite_chain(config):
    errors = []
    prereqs = config.get("prerequisites", [])
    difficulty = config.get("difficulty", "intermediate")
    diff_order = {"beginner": 0, "intermediate": 1, "advanced": 2, "expert": 3}

    if difficulty == "beginner" and prereqs:
        errors.append(ValidationError(
            "BEGINNER_HAS_PREREQS",
            "Beginner topics should not have prerequisites"
        ))

    if difficulty == "expert" and not prereqs:
        errors.append(ValidationError(
            "EXPERT_NO_PREREQS",
            "Expert topics should have prerequisites"
        ))

    return errors
```

### 7.2 validateContentStructure(content_config) → list

```python
def validate_content_structure(content_config):
    errors = []
    sections = content_config.get("sections", [])

    if not sections:
        errors.append(ValidationError("NO_SECTIONS", "Content must have at least one section"))
        return errors

    section_types = [s.get("type") for s in sections]
    if "explanation" not in section_types and "conceptual" not in str(section_types):
        errors.append(ValidationError(
            "NO_EXPLANATION_SECTION",
            "Content should include at least one explanation section"
        ))

    total_time = sum(s.get("time_minutes", 10) for s in sections)
    if total_time > 480:
        errors.append(ValidationError(
            "EXCESSIVE_TOTAL_TIME",
            f"Total content time ({total_time}min) exceeds 480 minutes"
        ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `TOPIC_NAME_EMPTY` | ERROR | Topic name is required |
| `TOPIC_NAME_TOO_LONG` | ERROR | Topic name exceeds 256 characters |
| `TOPIC_CATEGORY_MISSING` | ERROR | Topic category is required |
| `TOO_MANY_TAGS` | WARNING | Topic has more than 20 tags |
| `DURATION_TOO_LONG_BEGINNER` | WARNING | Beginner topic exceeds 240 minutes |
| `NO_LEARNING_OBJECTIVES` | ERROR | At least one learning objective required |
| `TOO_MANY_OBJECTIVES` | WARNING | Cannot exceed 20 learning objectives |
| `PASSING_SCORE_TOO_LOW` | WARNING | Passing score below 50% |
| `INSUFFICIENT_TIME` | WARNING | Time limit too short for question count |
| `BEGINNER_HAS_PREREQS` | WARNING | Beginner topics should not have prerequisites |
| `EXPERT_NO_PREREQS` | WARNING | Expert topics should have prerequisites |
| `NO_SECTIONS` | ERROR | Content must have at least one section |
| `NO_EXPLANATION_SECTION` | WARNING | Content should include explanation |
| `EXCESSIVE_TOTAL_TIME` | WARNING | Total content time exceeds 480 minutes |

---

## 9. Error Messages

```python
ERROR_MESSAGES = {
    "TOPIC_NAME_EMPTY": "Topic name is required for identification.",
    "TOPIC_NAME_TOO_LONG": "Topic name must be 256 characters or fewer.",
    "TOPIC_CATEGORY_MISSING": "Topic category must be specified.",
    "TOO_MANY_TAGS": "Topic cannot have more than 20 tags.",
    "DURATION_TOO_LONG_BEGINNER": "Beginner topics should not exceed 240 minutes.",
    "NO_LEARNING_OBJECTIVES": "At least one learning objective must be defined.",
    "TOO_MANY_OBJECTIVES": "Cannot define more than 20 learning objectives.",
    "PASSING_SCORE_TOO_LOW": "Passing score should be at least 50%.",
    "INSUFFICIENT_TIME": "Time limit is too short for the number of questions.",
    "BEGINNER_HAS_PREREQS": "Beginner topics should not have prerequisites.",
    "EXPERT_NO_PREREQS": "Expert topics should define prerequisites.",
    "NO_SECTIONS": "Content must contain at least one section.",
    "NO_EXPLANATION_SECTION": "Content should include at least one explanation section.",
    "EXCESSIVE_TOTAL_TIME": "Total content time exceeds 480 minutes.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| R001 | Topic name must not be empty | ERROR | No |
| R002 | Topic category must be in allowed enum | ERROR | No |
| R003 | Difficulty must be in allowed enum | ERROR | No |
| R004 | At least one learning objective required | ERROR | No |
| R005 | Learning objectives <= 20 | WARNING | Truncate |
| R006 | Beginner topics: no prerequisites | WARNING | Clear prereqs |
| R007 | Expert topics: require prerequisites | WARNING | No |
| R008 | Content must have at least one section | ERROR | No |
| R009 | Total content time <= 480 minutes | WARNING | No |
| R010 | Assessment passing score >= 50% | WARNING | Clamp |

---

## 11. Domain File References

All 50 files in `Core-Prompts-Learning/` that this validator covers:

| # | File | Learning Profile |
|---|------|------------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | category: reconnaissance, difficulty: beginner |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | category: javascript_analysis, difficulty: intermediate |
| 03 | `3-API-Endpoint-Analysis-Learning.md` | category: api_analysis, difficulty: intermediate |
| 04 | `4-Authentication-and-Session-Management-Learning.md` | category: authentication, difficulty: intermediate |
| 05 | `5-Authorization-and-Access-Control-Learning.md` | category: authorization, difficulty: intermediate |
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | category: input_validation, difficulty: beginner |
| 07 | `7-Business-Logic-Flaws-Learning.md` | category: business_logic, difficulty: advanced |
| 08 | `8-Client-Side-Storage-Security-Learning.md` | category: client_storage, difficulty: beginner |
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | category: cryptography, difficulty: advanced |
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | category: error_handling, difficulty: beginner |
| 11 | `11-File-Upload-and-Processing-Learning.md` | category: file_upload, difficulty: intermediate |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | category: ssrf, difficulty: advanced |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | category: csrf, difficulty: intermediate |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | category: cors, difficulty: intermediate |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | category: race_condition, difficulty: advanced |
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | category: third_party, difficulty: intermediate |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | category: config_hunting, difficulty: beginner |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | category: network_security, difficulty: advanced |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | category: mobile_api, difficulty: advanced |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | category: reporting, difficulty: intermediate |
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | category: waf_bypass, difficulty: expert |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | category: http_smuggling, difficulty: expert |
| 23 | `23-Subdomain-Takeover-Learning.md` | category: subdomain_takeover, difficulty: intermediate |
| 24 | `24-Host-Header-Injection-Learning.md` | category: host_header, difficulty: intermediate |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | category: xxe, difficulty: intermediate |
| 26 | `26-Insecure-Deserialization-Learning.md` | category: deserialization, difficulty: advanced |
| 27 | `27-Command-Injection-Learning.md` | category: command_injection, difficulty: advanced |
| 28 | `28-NoSQL-Injection-Learning.md` | category: nosql_injection, difficulty: intermediate |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | category: graphql, difficulty: advanced |
| 30 | `30-WebSocket-Security-Learning.md` | category: websocket, difficulty: advanced |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | category: ssti, difficulty: advanced |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | category: jwt_vulnerabilities, difficulty: intermediate |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | category: csp_bypass, difficulty: advanced |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | category: clickjacking, difficulty: intermediate |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | category: parameter_pollution, difficulty: intermediate |
| 36 | `36-LDAP-Injection-Learning.md` | category: ldap_injection, difficulty: advanced |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | category: session_puzzling, difficulty: advanced |
| 38 | `38-Insecure-File-Handling-Learning.md` | category: insecure_file_handling, difficulty: intermediate |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | category: prototype_pollution, difficulty: expert |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | category: cloud_security, difficulty: advanced |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | category: third_party, difficulty: intermediate |
| 42 | `42-Mobile-Application-Security-Learning.md` | category: mobile_api, difficulty: advanced |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | category: iot_security, difficulty: expert |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | category: graphql, difficulty: advanced |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | category: webassembly, difficulty: expert |
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | category: blockchain_security, difficulty: expert |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | category: config_hunting, difficulty: intermediate |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | category: reverse_engineering, difficulty: expert |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | category: compliance, difficulty: intermediate |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | category: threat_modeling, difficulty: expert |

---

## 12. Validation Pipeline

```python
def validate_core_learning_input(input_data):
    results = []
    results.append(("topic", validate_learning_topic(input_data)))
    results.append(("config", validate_learning_config(input_data)))
    results.append(("assessment", validate_assessment_config(input_data)))

    content = input_data.get("content", {})
    if content:
        results.append(("content", validate_content_structure(content)))

    config = input_data.get("learning_config", {})
    results.append(("prereqs", validate_prerequisite_chain(config)))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    all_warnings = []
    for name, result in results:
        all_errors.extend(result.errors)
        all_warnings.extend(result.warnings)

    return ValidationResult(
        valid=all_valid, errors=all_errors, warnings=all_warnings,
        meta={"validated_at": datetime.utcnow().isoformat(), "validator_version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Learning topic validation ensures proper categorization
- Difficulty-appropriate content length is enforced
- Prerequisite chains are validated for consistency
- Assessment configs are validated for reasonable parameters
- Content structure validation ensures educational quality
- All results are logged for learning analytics
- Progress tracking enables resume-from-checkpoint

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial schema validation reference for Core Prompts Learning domain |
