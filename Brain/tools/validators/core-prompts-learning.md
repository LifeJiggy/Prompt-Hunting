# Core Prompts Learning — Input Validation Reference

**Domain**: Core Prompts Learning (Assessment & Knowledge Validation)
**Validator Version**: 1.0.0
**Last Updated**: 2026-06-26
**Purpose**: Define input validation rules, JSON schemas, sanitization routines, type coercion, custom validators, and error handling for all assessment and learning inputs across the Core-Prompts-Learning domain.

---

## 1. Domain Mapping

| Key | Value |
|-----|-------|
| Domain Name | `core-prompts-learning` |
| Root Directory | `Core-Prompts-Learning/` |
| Total Files | 50 (+ README.md, registry.json) |
| Category | Assessment, Learning, Knowledge Validation, Skill Evaluation |
| Input Surface | Assessment answers, quiz inputs, knowledge checks, skill evaluations |

---

## 2. Overview

The Core Prompts Learning validator enforces strict input validation for every learning prompt in the `Core-Prompts-Learning/` directory. Each file defines a learning module — from reconnaissance to threat modeling — and accepts structured inputs including assessment answers, quiz responses, and knowledge validation data. This validator ensures:

- Assessment answers are properly formatted and complete
- Quiz responses are within valid option ranges
- Knowledge checks reference correct vulnerability classes
- Skill evaluations use consistent rating scales
- Learning progress data is valid and trackable
- All inputs are type-coerced and normalized
- Assessment integrity is maintained

---

## 3. Schema Definition

### 3.1 Master Learning Input Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "CorePromptsLearningInput",
  "type": "object",
  "required": ["domain", "learning_type"],
  "properties": {
    "domain": { "type": "string", "const": "core-prompts-learning" },
    "learning_type": { "$ref": "#/definitions/LearningType" },
    "assessment": { "$ref": "#/definitions/AssessmentConfig" },
    "quiz": { "$ref": "#/definitions/QuizConfig" },
    "knowledge_check": { "$ref": "#/definitions/KnowledgeCheckConfig" },
    "skill_eval": { "$ref": "#/definitions/SkillEvalConfig" },
    "output": { "$ref": "#/definitions/LearningOutput" }
  },
  "additionalProperties": false
}
```

### 3.2 LearningType Schema

```json
{
  "definitions": {
    "LearningType": {
      "type": "string",
      "enum": [
        "reconnaissance_learning", "javascript_learning", "api_learning",
        "authentication_learning", "authorization_learning", "input_validation_learning",
        "business_logic_learning", "client_storage_learning", "cryptography_learning",
        "error_handling_learning", "file_upload_learning", "ssrf_learning",
        "csrf_learning", "cors_learning", "race_conditions_learning",
        "third_party_learning", "configuration_learning",
        "network_infrastructure_learning", "mobile_api_learning",
        "reporting_learning", "waf_bypass_learning", "request_smuggling_learning",
        "subdomain_takeover_learning", "host_header_learning", "xxe_learning",
        "deserialization_learning", "command_injection_learning",
        "nosql_injection_learning", "graphql_learning", "websocket_learning",
        "ssti_learning", "jwt_learning", "csp_bypass_learning",
        "clickjacking_learning", "parameter_pollution_learning",
        "ldap_injection_learning", "session_puzzling_learning",
        "file_handling_learning", "advanced_client_side_learning",
        "cloud_security_learning", "third_party_integration_learning",
        "mobile_application_learning", "iot_embedded_learning",
        "api_security_graphql_learning", "webassembly_learning",
        "blockchain_learning", "automation_tool_learning",
        "reverse_engineering_learning", "compliance_learning",
        "threat_modeling_learning"
      ]
    }
  }
}
```

### 3.3 AssessmentConfig Schema

```json
{
  "definitions": {
    "AssessmentConfig": {
      "type": "object",
      "required": ["questions"],
      "properties": {
        "questions": {
          "type": "array",
          "items": { "$ref": "#/definitions/AssessmentQuestion" },
          "minItems": 1,
          "maxItems": 200
        },
        "time_limit_minutes": { "type": "integer", "minimum": 5, "maximum": 480, "default": 60 },
        "passing_score": { "type": "number", "minimum": 0, "maximum": 100, "default": 70 },
        "allow_skip": { "type": "boolean", "default": true },
        "randomize_order": { "type": "boolean", "default": false }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.4 AssessmentQuestion Schema

```json
{
  "definitions": {
    "AssessmentQuestion": {
      "type": "object",
      "required": ["id", "type", "question"],
      "properties": {
        "id": { "type": "string", "minLength": 1, "maxLength": 64 },
        "type": {
          "type": "string",
          "enum": ["multiple_choice", "true_false", "fill_blank", "code_review", "scenario", "practical"]
        },
        "question": { "type": "string", "minLength": 10, "maxLength": 4096 },
        "options": {
          "type": "array",
          "items": { "type": "string" },
          "minItems": 2,
          "maxItems": 10
        },
        "correct_answer": { "type": "string" },
        "explanation": { "type": "string", "maxLength": 4096 },
        "difficulty": {
          "type": "string",
          "enum": ["beginner", "intermediate", "advanced", "expert"]
        },
        "points": { "type": "integer", "minimum": 1, "maximum": 100, "default": 1 },
        "tags": { "type": "array", "items": { "type": "string" }, "maxItems": 10 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.5 QuizConfig Schema

```json
{
  "definitions": {
    "QuizConfig": {
      "type": "object",
      "required": ["questions"],
      "properties": {
        "questions": {
          "type": "array",
          "items": { "$ref": "#/definitions/QuizQuestion" },
          "minItems": 1,
          "maxItems": 100
        },
        "mode": {
          "type": "string",
          "enum": ["practice", "graded", "timed", "adaptive"]
        },
        "difficulty": {
          "type": "string",
          "enum": ["easy", "medium", "hard", "mixed"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.6 QuizQuestion Schema

```json
{
  "definitions": {
    "QuizQuestion": {
      "type": "object",
      "required": ["id", "question", "answer"],
      "properties": {
        "id": { "type": "string", "minLength": 1, "maxLength": 64 },
        "question": { "type": "string", "minLength": 5, "maxLength": 2048 },
        "answer": { "type": "string", "maxLength": 4096 },
        "options": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10
        },
        "correct_index": { "type": "integer", "minimum": 0 },
        "explanation": { "type": "string", "maxLength": 2048 },
        "category": { "type": "string", "maxLength": 128 }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.7 KnowledgeCheckConfig Schema

```json
{
  "definitions": {
    "KnowledgeCheckConfig": {
      "type": "object",
      "properties": {
        "topic": { "type": "string", "minLength": 1, "maxLength": 256 },
        "subtopics": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "responses": {
          "type": "array",
          "items": { "$ref": "#/definitions/KnowledgeResponse" },
          "maxItems": 100
        },
        "depth": {
          "type": "string",
          "enum": ["surface", "intermediate", "deep", "expert"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.8 KnowledgeResponse Schema

```json
{
  "definitions": {
    "KnowledgeResponse": {
      "type": "object",
      "required": ["question_id", "response"],
      "properties": {
        "question_id": { "type": "string", "minLength": 1, "maxLength": 64 },
        "response": { "type": "string", "minLength": 1, "maxLength": 4096 },
        "confidence": { "type": "number", "minimum": 0, "maximum": 1, "default": 0.5 },
        "reasoning": { "type": "string", "maxLength": 2048 }
      }
    }
  }
}
```

### 3.9 SkillEvalConfig Schema

```json
{
  "definitions": {
    "SkillEvalConfig": {
      "type": "object",
      "properties": {
        "skills": {
          "type": "array",
          "items": { "$ref": "#/definitions/SkillEntry" },
          "maxItems": 50
        },
        "evaluator": { "type": "string", "maxLength": 128 },
        "criteria": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 20
        },
        "rating_scale": {
          "type": "string",
          "enum": ["1-5", "1-10", "beginner_expert", "letter_grade"]
        }
      },
      "additionalProperties": false
    }
  }
}
```

### 3.10 SkillEntry Schema

```json
{
  "definitions": {
    "SkillEntry": {
      "type": "object",
      "required": ["name", "rating"],
      "properties": {
        "name": { "type": "string", "minLength": 1, "maxLength": 256 },
        "rating": { "type": "number", "minimum": 0, "maximum": 10 },
        "evidence": { "type": "string", "maxLength": 2048 },
        "category": { "type": "string", "maxLength": 128 },
        "improvement_areas": {
          "type": "array",
          "items": { "type": "string" },
          "maxItems": 10
        }
      }
    }
  }
}
```

---

## 4. Validate Operations

### 4.1 validateLearningType(input) → ValidationResult

```python
def validate_learning_type(input_data):
    errors = []
    learning_type = input_data.get("learning_type", "")
    valid_types = [
        "reconnaissance_learning", "javascript_learning", "api_learning",
        "authentication_learning", "authorization_learning", "input_validation_learning",
        "business_logic_learning", "client_storage_learning", "cryptography_learning",
        "error_handling_learning", "file_upload_learning", "ssrf_learning",
        "csrf_learning", "cors_learning", "race_conditions_learning",
        "third_party_learning", "configuration_learning",
        "network_infrastructure_learning", "mobile_api_learning",
        "reporting_learning", "waf_bypass_learning", "request_smuggling_learning",
        "subdomain_takeover_learning", "host_header_learning", "xxe_learning",
        "deserialization_learning", "command_injection_learning",
        "nosql_injection_learning", "graphql_learning", "websocket_learning",
        "ssti_learning", "jwt_learning", "csp_bypass_learning",
        "clickjacking_learning", "parameter_pollution_learning",
        "ldap_injection_learning", "session_puzzling_learning",
        "file_handling_learning", "advanced_client_side_learning",
        "cloud_security_learning", "third_party_integration_learning",
        "mobile_application_learning", "iot_embedded_learning",
        "api_security_graphql_learning", "webassembly_learning",
        "blockchain_learning", "automation_tool_learning",
        "reverse_engineering_learning", "compliance_learning",
        "threat_modeling_learning"
    ]
    if learning_type not in valid_types:
        errors.append(ValidationError("INVALID_LEARNING_TYPE", f"Unknown learning type: {learning_type}"))
    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.2 validateAssessmentConfig(input) → ValidationResult

```python
def validate_assessment_config(input_data):
    errors = []
    assessment = input_data.get("assessment", {})
    if not assessment:
        return ValidationResult(valid=True, errors=[])

    questions = assessment.get("questions", [])
    if not questions:
        errors.append(ValidationError("NO_QUESTIONS", "Assessment must have at least 1 question"))
    if len(questions) > 200:
        errors.append(ValidationError("TOO_MANY_QUESTIONS", "Assessment cannot have more than 200 questions"))

    question_ids = set()
    for q in questions:
        qid = q.get("id", "")
        if qid in question_ids:
            errors.append(ValidationError("DUPLICATE_QUESTION_ID", f"Duplicate question ID: {qid}"))
        question_ids.add(qid)

        if not qid:
            errors.append(ValidationError("QUESTION_ID_EMPTY", "Question ID cannot be empty"))
        if len(qid) > 64:
            errors.append(ValidationError("QUESTION_ID_TOO_LONG", f"Question ID '{qid}' exceeds 64 chars"))

        qtype = q.get("type", "")
        if qtype not in ("multiple_choice", "true_false", "fill_blank", "code_review", "scenario", "practical"):
            errors.append(ValidationError("INVALID_QUESTION_TYPE", f"Invalid question type: {qtype}"))

        question_text = q.get("question", "")
        if len(question_text) < 10:
            errors.append(ValidationError("QUESTION_TOO_SHORT", f"Question '{qid}' is too short (< 10 chars)"))
        if len(question_text) > 4096:
            errors.append(ValidationError("QUESTION_TOO_LONG", f"Question '{qid}' exceeds 4096 chars"))

        if qtype == "multiple_choice":
            options = q.get("options", [])
            if len(options) < 2:
                errors.append(ValidationError("NOT_ENOUGH_OPTIONS", f"Question '{qid}' needs at least 2 options"))
            if len(options) > 10:
                errors.append(ValidationError("TOO_MANY_OPTIONS", f"Question '{qid}' has more than 10 options"))

        difficulty = q.get("difficulty", "")
        if difficulty and difficulty not in ("beginner", "intermediate", "advanced", "expert"):
            errors.append(ValidationError("INVALID_DIFFICULTY", f"Invalid difficulty: {difficulty}"))

        points = q.get("points", 1)
        if not isinstance(points, int) or points < 1 or points > 100:
            errors.append(ValidationError("INVALID_POINTS", f"Question '{qid}' points must be 1-100"))

    time_limit = assessment.get("time_limit_minutes", 60)
    if time_limit < 5 or time_limit > 480:
        errors.append(ValidationError("TIME_LIMIT_OUT_OF_RANGE", "Time limit must be 5-480 minutes"))

    passing_score = assessment.get("passing_score", 70)
    if passing_score < 0 or passing_score > 100:
        errors.append(ValidationError("PASSING_SCORE_INVALID", "Passing score must be 0-100"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.3 validateQuizConfig(input) → ValidationResult

```python
def validate_quiz_config(input_data):
    errors = []
    quiz = input_data.get("quiz", {})
    if not quiz:
        return ValidationResult(valid=True, errors=[])

    questions = quiz.get("questions", [])
    if not questions:
        errors.append(ValidationError("NO_QUIZ_QUESTIONS", "Quiz must have at least 1 question"))
    if len(questions) > 100:
        errors.append(ValidationError("TOO_MANY_QUIZ_QUESTIONS", "Quiz cannot have more than 100 questions"))

    for q in questions:
        qid = q.get("id", "")
        if not qid:
            errors.append(ValidationError("QUIZ_Q_ID_EMPTY", "Quiz question ID cannot be empty"))

        question_text = q.get("question", "")
        if len(question_text) < 5:
            errors.append(ValidationError("QUIZ_Q_TOO_SHORT", f"Quiz question '{qid}' is too short"))
        if len(question_text) > 2048:
            errors.append(ValidationError("QUIZ_Q_TOO_LONG", f"Quiz question '{qid}' exceeds 2048 chars"))

        answer = q.get("answer", "")
        if not answer:
            errors.append(ValidationError("QUIZ_Q_NO_ANSWER", f"Quiz question '{qid}' has no answer"))
        if len(answer) > 4096:
            errors.append(ValidationError("QUIZ_Q_ANSWER_TOO_LONG", f"Answer for '{qid}' exceeds 4096 chars"))

        options = q.get("options", [])
        if len(options) > 10:
            errors.append(ValidationError("QUIZ_TOO_MANY_OPTIONS", f"Question '{qid}' has more than 10 options"))

        correct_index = q.get("correct_index", -1)
        if correct_index >= 0 and correct_index >= len(options):
            errors.append(ValidationError("INVALID_CORRECT_INDEX", f"Question '{qid}' correct_index out of range"))

    mode = quiz.get("mode", "practice")
    if mode not in ("practice", "graded", "timed", "adaptive"):
        errors.append(ValidationError("INVALID_QUIZ_MODE", f"Invalid quiz mode: {mode}"))

    difficulty = quiz.get("difficulty", "medium")
    if difficulty not in ("easy", "medium", "hard", "mixed"):
        errors.append(ValidationError("INVALID_QUIZ_DIFFICULTY", f"Invalid quiz difficulty: {difficulty}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.4 validateKnowledgeCheckConfig(input) → ValidationResult

```python
def validate_knowledge_check_config(input_data):
    errors = []
    kc = input_data.get("knowledge_check", {})
    if not kc:
        return ValidationResult(valid=True, errors=[])

    topic = kc.get("topic", "")
    if not topic:
        errors.append(ValidationError("TOPIC_EMPTY", "Knowledge check topic is required"))
    if len(topic) > 256:
        errors.append(ValidationError("TOPIC_TOO_LONG", "Topic exceeds 256 characters"))

    subtopics = kc.get("subtopics", [])
    if len(subtopics) > 20:
        errors.append(ValidationError("TOO_MANY_SUBTOPICS", "Cannot have more than 20 subtopics"))

    responses = kc.get("responses", [])
    if len(responses) > 100:
        errors.append(ValidationError("TOO_MANY_RESPONSES", "Cannot have more than 100 responses"))

    response_ids = set()
    for resp in responses:
        rid = resp.get("question_id", "")
        if rid in response_ids:
            errors.append(ValidationError("DUPLICATE_RESPONSE_ID", f"Duplicate response ID: {rid}"))
        response_ids.add(rid)

        if not rid:
            errors.append(ValidationError("RESPONSE_ID_EMPTY", "Response question_id cannot be empty"))

        response_text = resp.get("response", "")
        if not response_text:
            errors.append(ValidationError("RESPONSE_EMPTY", f"Response for '{rid}' cannot be empty"))
        if len(response_text) > 4096:
            errors.append(ValidationError("RESPONSE_TOO_LONG", f"Response for '{rid}' exceeds 4096 chars"))

        confidence = resp.get("confidence", 0.5)
        if confidence < 0 or confidence > 1:
            errors.append(ValidationError("CONFIDENCE_OUT_OF_RANGE", f"Confidence for '{rid}' must be 0-1"))

    depth = kc.get("depth", "intermediate")
    if depth not in ("surface", "intermediate", "deep", "expert"):
        errors.append(ValidationError("INVALID_DEPTH", f"Invalid knowledge depth: {depth}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

### 4.5 validateSkillEvalConfig(input) → ValidationResult

```python
def validate_skill_eval_config(input_data):
    errors = []
    se = input_data.get("skill_eval", {})
    if not se:
        return ValidationResult(valid=True, errors=[])

    skills = se.get("skills", [])
    if len(skills) > 50:
        errors.append(ValidationError("TOO_MANY_SKILLS", "Cannot evaluate more than 50 skills"))

    skill_names = set()
    for skill in skills:
        name = skill.get("name", "")
        if name in skill_names:
            errors.append(ValidationError("DUPLICATE_SKILL", f"Duplicate skill: {name}"))
        skill_names.add(name)

        if not name:
            errors.append(ValidationError("SKILL_NAME_EMPTY", "Skill name cannot be empty"))
        if len(name) > 256:
            errors.append(ValidationError("SKILL_NAME_TOO_LONG", f"Skill name '{name}' exceeds 256 chars"))

        rating = skill.get("rating", 0)
        if not isinstance(rating, (int, float)) or rating < 0 or rating > 10:
            errors.append(ValidationError("SKILL_RATING_INVALID", f"Rating for '{name}' must be 0-10"))

        evidence = skill.get("evidence", "")
        if len(evidence) > 2048:
            errors.append(ValidationError("EVIDENCE_TOO_LONG", f"Evidence for '{name}' exceeds 2048 chars"))

        areas = skill.get("improvement_areas", [])
        if len(areas) > 10:
            errors.append(ValidationError("TOO_MANY_IMPROVEMENT_AREAS", f"Too many improvement areas for '{name}'"))

    evaluator = se.get("evaluator", "")
    if evaluator and len(evaluator) > 128:
        errors.append(ValidationError("EVALUATOR_TOO_LONG", "Evaluator name exceeds 128 characters"))

    criteria = se.get("criteria", [])
    if len(criteria) > 20:
        errors.append(ValidationError("TOO_MANY_CRITERIA", "Cannot have more than 20 evaluation criteria"))

    scale = se.get("rating_scale", "1-10")
    if scale and scale not in ("1-5", "1-10", "beginner_expert", "letter_grade"):
        errors.append(ValidationError("INVALID_RATING_SCALE", f"Invalid rating scale: {scale}"))

    return ValidationResult(valid=len(errors) == 0, errors=errors)
```

---

## 5. Sanitize Operations

### 5.1 sanitizeQuestionText(text) → str

```python
def sanitize_question_text(text):
    text = text.strip()
    text = text[:4096]
    text = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', text)
    return text
```

### 5.2 sanitizeAnswer(answer) → str

```python
def sanitize_answer(answer):
    answer = answer.strip()
    answer = answer[:4096]
    answer = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', answer)
    return answer
```

### 5.3 sanitizeOptions(options) → list

```python
def sanitize_options(options):
    sanitized = []
    for opt in options[:10]:
        opt = str(opt).strip()[:1024]
        opt = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', opt)
        if opt:
            sanitized.append(opt)
    return sanitized
```

### 5.4 sanitizeSkillEvidence(evidence) → str

```python
def sanitize_skill_evidence(evidence):
    evidence = evidence.strip()
    evidence = evidence[:2048]
    evidence = re.sub(r'[\x00-\x08\x0b\x0c\x0e-\x1f\x7f]', '', evidence)
    return evidence
```

---

## 6. Type Coercion

### 6.1 coerceLearningType(raw_type) → str

```python
LEARNING_TYPE_MAP = {
    "recon": "reconnaissance_learning",
    "js": "javascript_learning", "javascript": "javascript_learning",
    "api": "api_learning",
    "auth": "authentication_learning",
    "authz": "authorization_learning",
    "input": "input_validation_learning",
    "logic": "business_logic_learning",
    "storage": "client_storage_learning",
    "crypto": "cryptography_learning",
    "error": "error_handling_learning",
    "upload": "file_upload_learning",
    "ssrf": "ssrf_learning", "csrf": "csrf_learning", "cors": "cors_learning",
    "race": "race_conditions_learning",
    "3rd_party": "third_party_learning",
    "config": "configuration_learning",
    "network": "network_infrastructure_learning",
    "mobile": "mobile_api_learning",
    "report": "reporting_learning",
    "waf": "waf_bypass_learning",
    "smuggle": "request_smuggling_learning",
    "subdomain": "subdomain_takeover_learning",
    "host": "host_header_learning",
    "xxe": "xxe_learning",
    "deser": "deserialization_learning",
    "cmdi": "command_injection_learning",
    "nosql": "nosql_injection_learning",
    "gql": "graphql_learning",
    "ws": "websocket_learning",
    "ssti": "ssti_learning",
    "jwt": "jwt_learning",
    "csp": "csp_bypass_learning",
    "clickjack": "clickjacking_learning",
    "hpp": "parameter_pollution_learning",
    "ldap": "ldap_injection_learning",
    "session": "session_puzzling_learning",
    "file": "file_handling_learning",
    "cloud": "cloud_security_learning",
    "iot": "iot_embedded_learning",
    "blockchain": "blockchain_learning",
    "automation": "automation_tool_learning",
    "re": "reverse_engineering_learning",
    "compliance": "compliance_learning",
    "threat": "threat_modeling_learning"
}

def coerce_learning_type(raw_type):
    return LEARNING_TYPE_MAP.get(str(raw_type).lower().strip(), raw_type)
```

### 6.2 coerceDifficulty(raw_difficulty) → str

```python
DIFFICULTY_MAP = {
    "easy": "beginner", "beginner": "beginner", "basic": "beginner",
    "medium": "intermediate", "intermediate": "intermediate", "moderate": "intermediate",
    "hard": "advanced", "advanced": "advanced", "difficult": "advanced",
    "expert": "expert", "master": "expert", "extreme": "expert"
}

def coerce_difficulty(raw_difficulty):
    return DIFFICULTY_MAP.get(str(raw_difficulty).lower().strip(), "intermediate")
```

### 6.3 coerceRating(rating, scale) → float

```python
def coerce_rating(rating, scale="1-10"):
    try:
        rating = float(rating)
    except (ValueError, TypeError):
        return 0.0

    if scale == "1-5":
        rating = max(1, min(5, rating))
    elif scale == "1-10":
        rating = max(0, min(10, rating))
    elif scale == "beginner_expert":
        rating = max(0, min(10, rating))
    elif scale == "letter_grade":
        grade_map = {"A": 9, "B": 7, "C": 5, "D": 3, "F": 1}
        if isinstance(rating, str):
            rating = grade_map.get(rating.upper(), 0)
    return rating
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

### 7.1 validateAssessmentIntegrity(assessment) → list

```python
def validate_assessment_integrity(assessment):
    errors = []
    questions = assessment.get("questions", [])

    total_points = sum(q.get("points", 1) for q in questions)
    if total_points == 0:
        errors.append(ValidationWarning("ZERO_TOTAL_POINTS", "Total assessment points is 0"))

    difficulties = [q.get("difficulty", "intermediate") for q in questions]
    if len(set(difficulties)) == 1 and len(questions) > 5:
        errors.append(ValidationWarning(
            "MONO_DIFFICULTY",
            "All questions have the same difficulty. Consider varying difficulty levels."
        ))

    types = [q.get("type", "") for q in questions]
    if len(set(types)) == 1 and len(questions) > 10:
        errors.append(ValidationWarning(
            "MONO_TYPE",
            "All questions are the same type. Consider mixing question types."
        ))

    return errors
```

### 7.2 validateQuizAnswerConsistency(quiz) → list

```python
def validate_quiz_answer_consistency(quiz):
    errors = []
    questions = quiz.get("questions", [])

    for q in questions:
        qid = q.get("id", "")
        options = q.get("options", [])
        correct_index = q.get("correct_index", -1)

        if correct_index >= 0 and options:
            if correct_index >= len(options):
                errors.append(ValidationError(
                    "INDEX_OUT_OF_RANGE",
                    f"Question '{qid}' correct_index {correct_index} exceeds options count {len(options)}"
                ))

        if not options and q.get("type") == "multiple_choice":
            errors.append(ValidationError(
                "MC_NO_OPTIONS",
                f"Multiple choice question '{qid}' has no options"
            ))

    return errors
```

### 7.3 validateKnowledgeResponseCompleteness(kc) → list

```python
def validate_knowledge_response_completeness(kc):
    errors = []
    responses = kc.get("responses", [])

    low_confidence = [r for r in responses if r.get("confidence", 0.5) < 0.3]
    if low_confidence:
        errors.append(ValidationWarning(
            "LOW_CONFIDENCE_RESPONSES",
            f"{len(low_confidence)} responses have confidence below 0.3"
        ))

    short_responses = [r for r in responses if len(r.get("response", "")) < 20]
    if short_responses:
        errors.append(ValidationWarning(
            "SHORT_RESPONSES",
            f"{len(short_responses)} responses are very short (< 20 chars)"
        ))

    return errors
```

### 7.4 validateSkillRatingDistribution(skills) → list

```python
def validate_skill_rating_distribution(skills):
    errors = []
    if not skills:
        return errors

    ratings = [s.get("rating", 0) for s in skills]
    avg_rating = sum(ratings) / len(ratings) if ratings else 0

    if avg_rating > 9:
        errors.append(ValidationWarning(
            "HIGH_AVERAGE_RATING",
            f"Average skill rating ({avg_rating:.1f}) is very high. Consider calibrating."
        ))
    if avg_rating < 2:
        errors.append(ValidationWarning(
            "LOW_AVERAGE_RATING",
            f"Average skill rating ({avg_rating:.1f}) is very low."
        ))

    if len(set(ratings)) == 1 and len(skills) > 3:
        errors.append(ValidationWarning(
            "UNIFORM_RATINGS",
            "All skills have the same rating. Consider more nuanced evaluation."
        ))

    return errors
```

---

## 8. Validation Error Types

| Error Code | Severity | Description |
|------------|----------|-------------|
| `INVALID_LEARNING_TYPE` | ERROR | Learning type not recognized |
| `NO_QUESTIONS` | ERROR | Assessment must have at least 1 question |
| `TOO_MANY_QUESTIONS` | ERROR | Assessment cannot have more than 200 questions |
| `DUPLICATE_QUESTION_ID` | ERROR | Two questions share the same ID |
| `QUESTION_ID_EMPTY` | ERROR | Question ID cannot be empty |
| `QUESTION_ID_TOO_LONG` | ERROR | Question ID exceeds 64 characters |
| `INVALID_QUESTION_TYPE` | ERROR | Question type not recognized |
| `QUESTION_TOO_SHORT` | ERROR | Question text is too short |
| `QUESTION_TOO_LONG` | ERROR | Question text exceeds 4096 characters |
| `NOT_ENOUGH_OPTIONS` | ERROR | Multiple choice needs at least 2 options |
| `TOO_MANY_OPTIONS` | ERROR | Question has more than 10 options |
| `INVALID_DIFFICULTY` | ERROR | Difficulty level not recognized |
| `INVALID_POINTS` | ERROR | Points must be 1-100 |
| `TIME_LIMIT_OUT_OF_RANGE` | ERROR | Time limit must be 5-480 minutes |
| `PASSING_SCORE_INVALID` | ERROR | Passing score must be 0-100 |
| `NO_QUIZ_QUESTIONS` | ERROR | Quiz must have at least 1 question |
| `TOO_MANY_QUIZ_QUESTIONS` | ERROR | Quiz cannot have more than 100 questions |
| `QUIZ_Q_ID_EMPTY` | ERROR | Quiz question ID cannot be empty |
| `QUIZ_Q_TOO_SHORT` | ERROR | Quiz question is too short |
| `QUIZ_Q_TOO_LONG` | ERROR | Quiz question exceeds 2048 characters |
| `QUIZ_Q_NO_ANSWER` | ERROR | Quiz question has no answer |
| `QUIZ_Q_ANSWER_TOO_LONG` | ERROR | Quiz answer exceeds 4096 characters |
| `QUIZ_TOO_MANY_OPTIONS` | ERROR | Quiz question has more than 10 options |
| `INVALID_CORRECT_INDEX` | ERROR | correct_index out of range |
| `INVALID_QUIZ_MODE` | ERROR | Quiz mode not recognized |
| `INVALID_QUIZ_DIFFICULTY` | ERROR | Quiz difficulty not recognized |
| `TOPIC_EMPTY` | ERROR | Knowledge check topic is required |
| `TOPIC_TOO_LONG` | ERROR | Topic exceeds 256 characters |
| `TOO_MANY_SUBTOPICS` | ERROR | Cannot have more than 20 subtopics |
| `TOO_MANY_RESPONSES` | ERROR | Cannot have more than 100 responses |
| `DUPLICATE_RESPONSE_ID` | ERROR | Duplicate response ID |
| `RESPONSE_ID_EMPTY` | ERROR | Response question_id cannot be empty |
| `RESPONSE_EMPTY` | ERROR | Response text cannot be empty |
| `RESPONSE_TOO_LONG` | ERROR | Response exceeds 4096 characters |
| `CONFIDENCE_OUT_OF_RANGE` | ERROR | Confidence must be 0-1 |
| `INVALID_DEPTH` | ERROR | Knowledge depth not recognized |
| `TOO_MANY_SKILLS` | ERROR | Cannot evaluate more than 50 skills |
| `DUPLICATE_SKILL` | ERROR | Duplicate skill name |
| `SKILL_NAME_EMPTY` | ERROR | Skill name cannot be empty |
| `SKILL_NAME_TOO_LONG` | ERROR | Skill name exceeds 256 characters |
| `SKILL_RATING_INVALID` | ERROR | Skill rating must be 0-10 |
| `EVIDENCE_TOO_LONG` | ERROR | Evidence exceeds 2048 characters |
| `TOO_MANY_IMPROVEMENT_AREAS` | ERROR | Too many improvement areas |
| `EVALUATOR_TOO_LONG` | ERROR | Evaluator name exceeds 128 characters |
| `TOO_MANY_CRITERIA` | ERROR | Cannot have more than 20 criteria |
| `INVALID_RATING_SCALE` | ERROR | Rating scale not recognized |
| `ZERO_TOTAL_POINTS` | WARNING | Total assessment points is 0 |
| `MONO_DIFFICULTY` | WARNING | All questions have same difficulty |
| `MONO_TYPE` | WARNING | All questions are same type |
| `INDEX_OUT_OF_RANGE` | ERROR | correct_index exceeds options count |
| `MC_NO_OPTIONS` | ERROR | Multiple choice has no options |
| `LOW_CONFIDENCE_RESPONSES` | WARNING | Some responses have low confidence |
| `SHORT_RESPONSES` | WARNING | Some responses are very short |
| `HIGH_AVERAGE_RATING` | WARNING | Average skill rating is very high |
| `LOW_AVERAGE_RATING` | WARNING | Average skill rating is very low |
| `UNIFORM_RATINGS` | WARNING | All skills have same rating |

---

## 9. Error Messages

```python
LEARNING_ERROR_MESSAGES = {
    "INVALID_LEARNING_TYPE": "Learning type not recognized. Check the supported learning modules.",
    "NO_QUESTIONS": "Assessment must have at least 1 question.",
    "TOO_MANY_QUESTIONS": "Assessment cannot have more than 200 questions.",
    "DUPLICATE_QUESTION_ID": "Each question must have a unique ID.",
    "QUESTION_ID_EMPTY": "Question ID cannot be empty.",
    "QUESTION_ID_TOO_LONG": "Question ID must be 64 characters or fewer.",
    "INVALID_QUESTION_TYPE": "Question type not recognized.",
    "QUESTION_TOO_SHORT": "Question text must be at least 10 characters.",
    "QUESTION_TOO_LONG": "Question text must be 4096 characters or fewer.",
    "NOT_ENOUGH_OPTIONS": "Multiple choice questions need at least 2 options.",
    "TOO_MANY_OPTIONS": "Questions cannot have more than 10 options.",
    "INVALID_DIFFICULTY": "Difficulty must be: beginner, intermediate, advanced, or expert.",
    "INVALID_POINTS": "Points must be between 1 and 100.",
    "TIME_LIMIT_OUT_OF_RANGE": "Time limit must be between 5 and 480 minutes.",
    "PASSING_SCORE_INVALID": "Passing score must be between 0 and 100.",
    "NO_QUIZ_QUESTIONS": "Quiz must have at least 1 question.",
    "TOO_MANY_QUIZ_QUESTIONS": "Quiz cannot have more than 100 questions.",
    "QUIZ_Q_ID_EMPTY": "Quiz question ID cannot be empty.",
    "QUIZ_Q_TOO_SHORT": "Quiz question must be at least 5 characters.",
    "QUIZ_Q_TOO_LONG": "Quiz question must be 2048 characters or fewer.",
    "QUIZ_Q_NO_ANSWER": "Quiz question must have an answer.",
    "QUIZ_Q_ANSWER_TOO_LONG": "Quiz answer must be 4096 characters or fewer.",
    "QUIZ_TOO_MANY_OPTIONS": "Quiz questions cannot have more than 10 options.",
    "INVALID_CORRECT_INDEX": "correct_index is out of the valid options range.",
    "INVALID_QUIZ_MODE": "Quiz mode must be: practice, graded, timed, or adaptive.",
    "INVALID_QUIZ_DIFFICULTY": "Quiz difficulty must be: easy, medium, hard, or mixed.",
    "TOPIC_EMPTY": "Knowledge check topic is required.",
    "TOPIC_TOO_LONG": "Topic must be 256 characters or fewer.",
    "TOO_MANY_SUBTOPICS": "Cannot have more than 20 subtopics.",
    "TOO_MANY_RESPONSES": "Cannot have more than 100 responses.",
    "DUPLICATE_RESPONSE_ID": "Each response must have a unique question_id.",
    "RESPONSE_ID_EMPTY": "Response question_id cannot be empty.",
    "RESPONSE_EMPTY": "Response text cannot be empty.",
    "RESPONSE_TOO_LONG": "Response must be 4096 characters or fewer.",
    "CONFIDENCE_OUT_OF_RANGE": "Confidence must be between 0 and 1.",
    "INVALID_DEPTH": "Knowledge depth must be: surface, intermediate, deep, or expert.",
    "TOO_MANY_SKILLS": "Cannot evaluate more than 50 skills.",
    "DUPLICATE_SKILL": "Each skill must have a unique name.",
    "SKILL_NAME_EMPTY": "Skill name cannot be empty.",
    "SKILL_NAME_TOO_LONG": "Skill name must be 256 characters or fewer.",
    "SKILL_RATING_INVALID": "Skill rating must be between 0 and 10.",
    "EVIDENCE_TOO_LONG": "Evidence must be 2048 characters or fewer.",
    "TOO_MANY_IMPROVEMENT_AREAS": "Cannot have more than 10 improvement areas per skill.",
    "EVALUATOR_TOO_LONG": "Evaluator name must be 128 characters or fewer.",
    "TOO_MANY_CRITERIA": "Cannot have more than 20 evaluation criteria.",
    "INVALID_RATING_SCALE": "Rating scale must be: 1-5, 1-10, beginner_expert, or letter_grade.",
    "ZERO_TOTAL_POINTS": "Total assessment points is 0.",
    "MONO_DIFFICULTY": "All questions have the same difficulty. Consider varying levels.",
    "MONO_TYPE": "All questions are the same type. Consider mixing types.",
    "INDEX_OUT_OF_RANGE": "correct_index exceeds the number of available options.",
    "MC_NO_OPTIONS": "Multiple choice question has no options defined.",
    "LOW_CONFIDENCE_RESPONSES": "Some responses have very low confidence.",
    "SHORT_RESPONSES": "Some responses are very short and may not demonstrate understanding.",
    "HIGH_AVERAGE_RATING": "Average skill rating is very high. Consider calibrating the scale.",
    "LOW_AVERAGE_RATING": "Average skill rating is very low.",
    "UNIFORM_RATINGS": "All skills have the same rating. Consider more nuanced evaluation.",
}
```

---

## 10. Validation Rules

| Rule ID | Rule | Severity | Auto-Fix |
|---------|------|----------|----------|
| L001 | Learning type must be valid | ERROR | No |
| L002 | Assessment must have 1-200 questions | ERROR | No |
| L003 | Question IDs must be unique | ERROR | Append suffix |
| L004 | Question IDs must be 1-64 chars | ERROR | Truncate |
| L005 | Question type must be valid | ERROR | No |
| L006 | Question text must be 10-4096 chars | ERROR | Truncate/Pad |
| L007 | Multiple choice needs 2-10 options | ERROR | No |
| L008 | Difficulty must be valid | ERROR | Default to intermediate |
| L009 | Points must be 1-100 | ERROR | Clamp |
| L010 | Time limit must be 5-480 minutes | ERROR | Clamp |
| L011 | Passing score must be 0-100 | ERROR | Clamp |
| L012 | Quiz must have 1-100 questions | ERROR | No |
| L013 | Quiz answers must not be empty | ERROR | No |
| L014 | correct_index must be in range | ERROR | No |
| L015 | Quiz mode must be valid | ERROR | Default to practice |
| L016 | Knowledge topic must be 1-256 chars | ERROR | Truncate |
| L017 | Responses max 100 | ERROR | Truncate |
| L018 | Confidence must be 0-1 | ERROR | Clamp |
| L019 | Skills max 50 | ERROR | Truncate |
| L020 | Skill rating must be 0-10 | ERROR | Clamp |

---

## 11. Domain File References

All 50 files in `Core-Prompts-Learning/` that this validator covers:

| # | File | Learning Type | Assessment Focus |
|---|------|---------------|------------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | reconnaissance_learning | recon techniques |
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | javascript_learning | JS analysis |
| 03 | `3-API-Endpoint-Analysis-Learning.md` | api_learning | API testing |
| 04 | `4-Authentication-and-Session-Management-Learning.md` | authentication_learning | auth flows |
| 05 | `5-Authorization-and-Access-Control-Learning.md` | authorization_learning | access control |
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | input_validation_learning | input handling |
| 07 | `7-Business-Logic-Flaws-Learning.md` | business_logic_learning | logic testing |
| 08 | `8-Client-Side-Storage-Security-Learning.md` | client_storage_learning | storage security |
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | cryptography_learning | crypto analysis |
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | error_handling_learning | error analysis |
| 11 | `11-File-Upload-and-Processing-Learning.md` | file_upload_learning | upload testing |
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | ssrf_learning | SSRF testing |
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | csrf_learning | CSRF testing |
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | cors_learning | CORS analysis |
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | race_conditions_learning | race testing |
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | third_party_learning | 3rd party |
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | configuration_learning | config review |
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | network_infrastructure_learning | network security |
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | mobile_api_learning | mobile testing |
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | reporting_learning | report writing |
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | waf_bypass_learning | WAF bypass |
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | request_smuggling_learning | smuggling |
| 23 | `23-Subdomain-Takeover-Learning.md` | subdomain_takeover_learning | subdomain takeover |
| 24 | `24-Host-Header-Injection-Learning.md` | host_header_learning | host header |
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | xxe_learning | XXE testing |
| 26 | `26-Insecure-Deserialization-Learning.md` | deserialization_learning | deser testing |
| 27 | `27-Command-Injection-Learning.md` | command_injection_learning | cmdi testing |
| 28 | `28-NoSQL-Injection-Learning.md` | nosql_injection_learning | NoSQLi testing |
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | graphql_learning | GraphQL testing |
| 30 | `30-WebSocket-Security-Learning.md` | websocket_learning | WebSocket testing |
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | ssti_learning | SSTI testing |
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | jwt_learning | JWT testing |
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | csp_bypass_learning | CSP bypass |
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | clickjacking_learning | clickjacking |
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | parameter_pollution_learning | HPP testing |
| 36 | `36-LDAP-Injection-Learning.md` | ldap_injection_learning | LDAP testing |
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | session_puzzling_learning | session testing |
| 38 | `38-Insecure-File-Handling-Learning.md` | file_handling_learning | file handling |
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | advanced_client_side_learning | client-side |
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | cloud_security_learning | cloud security |
| 41 | `41-Third-Party-Integration-Security-Learning.md` | third_party_integration_learning | 3rd party |
| 42 | `42-Mobile-Application-Security-Learning.md` | mobile_application_learning | mobile security |
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | iot_embedded_learning | IoT security |
| 44 | `44-API-Security-and-GraphQL-Learning.md` | api_security_graphql_learning | API+GraphQL |
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | webassembly_learning | WebAssembly |
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | blockchain_learning | blockchain |
| 47 | `47-Automation-and-Tool-Development-Learning.md` | automation_tool_learning | automation |
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | reverse_engineering_learning | reverse eng |
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | compliance_learning | compliance |
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | threat_modeling_learning | threat modeling |

---

## 12. Validation Pipeline

```python
def validate_core_prompts_learning_input(input_data):
    results = []
    results.append(("learning_type", validate_learning_type(input_data)))
    results.append(("assessment", validate_assessment_config(input_data)))
    results.append(("quiz", validate_quiz_config(input_data)))
    results.append(("knowledge_check", validate_knowledge_check_config(input_data)))
    results.append(("skill_eval", validate_skill_eval_config(input_data)))

    assessment = input_data.get("assessment", {})
    results.append(("assessment_integrity", ValidationResult(
        valid=True, errors=validate_assessment_integrity(assessment)
    )))

    quiz = input_data.get("quiz", {})
    results.append(("quiz_consistency", ValidationResult(
        valid=True, errors=validate_quiz_answer_consistency(quiz)
    )))

    kc = input_data.get("knowledge_check", {})
    results.append(("kc_completeness", ValidationResult(
        valid=True, errors=validate_knowledge_response_completeness(kc)
    )))

    se = input_data.get("skill_eval", {})
    results.append(("skill_distribution", ValidationResult(
        valid=True, errors=validate_skill_rating_distribution(se.get("skills", []))
    )))

    all_valid = all(r[1].valid for r in results)
    all_errors = []
    for name, result in results:
        all_errors.extend(result.errors)

    return ValidationResult(
        valid=all_valid, errors=all_errors,
        meta={"validator": "core-prompts-learning", "version": "1.0.0"}
    )
```

---

## 13. Integration Notes

- Learning validation runs before any assessment or quiz is generated
- Assessment integrity checks ensure balanced difficulty and question types
- Quiz answer consistency checks verify correct_index validity
- Knowledge response completeness warns about low-quality responses
- Skill rating distribution checks detect calibration issues
- All validation results feed into the learning progress tracker
- Type coercion normalizes difficulty levels and rating scales
- Question ID uniqueness is enforced across the entire assessment

---

## 14. Change Log

| Version | Date | Change |
|---------|------|--------|
| 1.0.0 | 2026-06-26 | Initial validation reference for Core Prompts Learning domain |
