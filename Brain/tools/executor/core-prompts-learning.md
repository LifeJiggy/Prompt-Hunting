# Core Prompts Learning — Tool Execution Domain

**Component:** Tool Executor for Security Assessment  
**Domain:** `core-prompts-learning`  
**Registry:** `Core-Prompts-Learning/registry.json`  
**File Count:** 50 prompt files  
**Execution Mode:** Assessment tool execution with learning integration

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `core-prompts-learning` |
| Domain Path | `Core-Prompts-Learning/` |
| Category | `learning` |
| Execution Profile | `assessment` |
| Default Timeout | 300s |
| Max Timeout | 1800s |
| Default Retries | 2 |
| Concurrency Limit | 5 |
| Stealth Level | `low` |
| Rate Limit | 15 req/s |

---

## Overview

The Core Prompts Learning executor manages tool execution for security assessment learning operations. This domain covers 50 prompt files spanning reconnaissance and asset discovery learning, JavaScript analysis and deobfuscation learning, API endpoint analysis learning, authentication and session management learning, authorization and access control learning, input validation and sanitization learning, business logic flaws learning, client-side storage security learning, cryptography and data protection learning, error handling and information disclosure learning, file upload and processing learning, SSRF learning, CSRF learning, CORS learning, race conditions and concurrency issues learning, third-party component analysis learning, configuration and misconfiguration hunting learning, network and infrastructure security learning, mobile and API-specific vulnerabilities learning, reporting and PoC development learning, WAF bypass learning, HTTP request smuggling learning, subdomain takeover learning, host header injection learning, XXE injection learning, insecure deserialization learning, command injection learning, NoSQL injection learning, GraphQL vulnerabilities learning, WebSocket security learning, SSTI learning, JWT vulnerabilities learning, CSP bypass learning, clickjacking and UI redressing learning, HTTP parameter pollution learning, LDAP injection learning, session puzzling and fixation learning, insecure file handling learning, advanced client-side attacks learning, authentication learning (variant), cloud security and misconfigurations learning, third-party integration security learning, mobile application security learning, IoT and embedded device security learning, API security and GraphQL learning, WebAssembly and modern web technologies learning, blockchain and cryptocurrency security learning, automation and tool development learning, advanced reverse engineering learning, compliance and regulatory security learning, and advanced threat modeling and risk assessment learning.

This executor runs assessment tools that help users learn security concepts, practice vulnerability detection, and build expertise through guided exercises.

---

## Execution Schema

### LearningInvocation (Input)

```json
{
  "tool": "string — assessment tool name",
  "assessment_type": "string — exercise|quiz|lab|challenge|review",
  "input": {
    "topic": "string — learning topic",
    "difficulty": "string — beginner|intermediate|advanced|expert",
    "vuln_class": "string — target vulnerability class",
    "context": {
      "target": "string — practice target",
      "hints_enabled": "boolean",
      "solution_visible": "boolean"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "learning_mode": "string — guided|independent|assessment"
  }
}
```

### LearningResult (Output)

```json
{
  "status": "string",
  "assessment": {
    "type": "string",
    "topic": "string",
    "questions": ["object — assessment questions"],
    "hints": ["string — available hints"],
    "solutions": ["object — solutions when visible"],
    "explanation": "string — learning explanation"
  },
  "score": "number — 0-100",
  "duration_ms": "number",
  "learning_objectives": ["string"]
}
```

---

## Run Operations

### Assessment Execution

```python
def run_assessment(
    self,
    tool: str,
    assessment_type: str,
    input_data: dict,
    config: dict = None
) -> LearningResult:
    """
    Execute a learning assessment tool.
    
    Flow:
    1. Load assessment content from reference files
    2. Generate assessment based on topic and difficulty
    3. Execute assessment with user interaction
    4. Evaluate responses
    5. Calculate score and provide feedback
    6. Return learning results
    """
```

### Exercise Execution

```python
def run_exercise(
    self,
    topic: str,
    difficulty: str,
    vuln_class: str = None
) -> LearningResult:
    """
    Run a hands-on exercise for the specified topic.
    Provides guided practice with hints and solutions.
    """
```

### Quiz Execution

```python
def run_quiz(
    self,
    topic: str,
    question_count: int = 10,
    difficulty: str = "intermediate"
) -> LearningResult:
    """
    Run a quiz on the specified topic.
    Returns questions, accepts answers, provides scoring.
    """
```

---

## Stop Operations

### Assessment Stop

```python
def stop_assessment(
    self,
    invocation_id: str
) -> StopResult:
    """Stop a running assessment and return partial results."""
```

---

## Retry Operations

### Learning Retry Configuration

```python
@dataclass
class LearningRetryConfig:
    max_retries: int = 2
    backoff_base: float = 1.0
    retry_on_content_error: bool = True
    retry_on_render_error: bool = True
```

---

## Timeout Handling

### Learning Timeout Configuration

```python
@dataclass
class LearningTimeoutConfig:
    default: int = 300
    overrides: dict[str, int] = field(default_factory=lambda: {
        "exercise": 600,
        "quiz": 300,
        "lab": 1800,
        "challenge": 900,
        "review": 120,
        "content_load": 30,
        "scoring": 10
    })
    hard_maximum: int = 1800
```

---

## Output Capture

### Learning Output Capture

```python
@dataclass
class LearningCapturedOutput:
    assessment_content: dict
    user_responses: list[dict]
    score: float
    feedback: list[str]
    duration_ms: int
```

---

## Stderr Handling

### Learning Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process learning tool stderr."""
    return StderrResult(
        raw=stderr,
        classification="learning_error",
        retryable=True
    )
```

---

## Exit Code Handling

### Learning Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process learning tool exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="return_assessment")
    return ExitCodeResult(status="error", action="retry_with_fallback")
```

---

## Concurrent Execution

### Learning Concurrency Configuration

```python
@dataclass
class LearningConcurrencyConfig:
    max_concurrent: int = 5
    max_per_assessment_type: int = 3
    parallel_assessments: bool = True
```

---

## Execution Logging

### Learning Execution Log

```python
@dataclass
class LearningExecutionLog:
    invocation_id: str
    tool: str
    assessment_type: str
    topic: str
    difficulty: str
    score: float
    duration_ms: int
    timestamp: str
```

---

## Full Domain File References

### Category: Reconnaissance and Discovery

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 01 | `1-Reconnaissance-and-Asset-Discovery-Learning.md` | Reconnaissance and Asset Discovery Learning | exercise | beginner-intermediate |

### Category: Client-Side Analysis

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 02 | `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` | JavaScript Analysis and Deobfuscation Learning | exercise | intermediate |

### Category: API Analysis

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 03 | `3-API-Endpoint-Analysis-Learning.md` | API Endpoint Analysis Learning | exercise | intermediate |

### Category: Authentication

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 04 | `4-Authentication-and-Session-Management-Learning.md` | Authentication and Session Management Learning | exercise | intermediate |

### Category: Authorization

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 05 | `5-Authorization-and-Access-Control-Learning.md` | Authorization and Access Control Learning | exercise | intermediate |

### Category: Input Validation

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 06 | `6-Input-Validation-and-Sanitization-Learning.md` | Input Validation and Sanitization Learning | exercise | beginner-intermediate |

### Category: Business Logic

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 07 | `7-Business-Logic-Flaws-Learning.md` | Business Logic Flaws Learning | exercise | intermediate-advanced |

### Category: Client-Side Storage

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 08 | `8-Client-Side-Storage-Security-Learning.md` | Client-Side Storage Security Learning | exercise | beginner-intermediate |

### Category: Cryptography

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 09 | `9-Cryptography-and-Data-Protection-Learning.md` | Cryptography and Data Protection Learning | exercise | intermediate |

### Category: Error Handling

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 10 | `10-Error-Handling-and-Information-Disclosure-Learning.md` | Error Handling and Information Disclosure Learning | exercise | beginner |

### Category: File Upload

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 11 | `11-File-Upload-and-Processing-Learning.md` | File Upload and Processing Learning | exercise | intermediate |

### Category: SSRF

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 12 | `12-Server-Side-Request-Forgery-SSRF-Learning.md` | Server-Side Request Forgery (SSRF) Learning | exercise | intermediate |

### Category: CSRF

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 13 | `13-Cross-Site-Request-Forgery-CSRF-Learning.md` | Cross-Site Request Forgery (CSRF) Learning | exercise | beginner-intermediate |

### Category: CORS

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 14 | `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` | Cross-Origin Resource Sharing (CORS) Learning | exercise | intermediate |

### Category: Race Conditions

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 15 | `15-Race-Conditions-and-Concurrency-Issues-Learning.md` | Race Conditions and Concurrency Issues Learning | exercise | advanced |

### Category: Third-Party Components

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 16 | `16-Third-Party-Component-Analysis-Learning.md` | Third-Party Component Analysis Learning | exercise | intermediate |

### Category: Configuration

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 17 | `17-Configuration-and-Misconfiguration-Hunting-Learning.md` | Configuration and Misconfiguration Hunting Learning | exercise | beginner-intermediate |

### Category: Network Security

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 18 | `18-Network-and-Infrastructure-Security-Learning.md` | Network and Infrastructure Security Learning | exercise | intermediate |

### Category: Mobile and API

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 19 | `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` | Mobile and API-Specific Vulnerabilities Learning | exercise | intermediate |

### Category: Reporting

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 20 | `20-Reporting-and-Proof-of-Concept-Development-Learning.md` | Reporting and Proof-of-Concept Development Learning | exercise | beginner |

### Category: WAF Bypass

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 21 | `21-Web-Application-Firewall-WAF-Bypass-Learning.md` | Web Application Firewall (WAF) Bypass Learning | exercise | advanced |

### Category: HTTP Smuggling

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 22 | `22-HTTP-Request-Smuggling-Learning.md` | HTTP Request Smuggling Learning | exercise | advanced |

### Category: Subdomain Takeover

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 23 | `23-Subdomain-Takeover-Learning.md` | Subdomain Takeover Learning | exercise | intermediate |

### Category: Host Header Injection

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 24 | `24-Host-Header-Injection-Learning.md` | Host Header Injection Learning | exercise | intermediate |

### Category: XXE

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 25 | `25-XML-External-Entity-XXE-Injection-Learning.md` | XML External Entity (XXE) Injection Learning | exercise | intermediate |

### Category: Deserialization

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 26 | `26-Insecure-Deserialization-Learning.md` | Insecure Deserialization Learning | exercise | advanced |

### Category: Command Injection

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 27 | `27-Command-Injection-Learning.md` | Command Injection Learning | exercise | intermediate |

### Category: NoSQL Injection

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 28 | `28-NoSQL-Injection-Learning.md` | NoSQL Injection Learning | exercise | intermediate |

### Category: GraphQL

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 29 | `29-GraphQL-Vulnerabilities-Learning.md` | GraphQL Vulnerabilities Learning | exercise | intermediate |

### Category: WebSocket

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 30 | `30-WebSocket-Security-Learning.md` | WebSocket Security Learning | exercise | intermediate |

### Category: SSTI

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 31 | `31-Server-Side-Template-Injection-SSTI-Learning.md` | Server-Side Template Injection (SSTI) Learning | exercise | intermediate |

### Category: JWT

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 32 | `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` | JSON Web Token (JWT) Vulnerabilities Learning | exercise | intermediate |

### Category: CSP Bypass

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 33 | `33-Content-Security-Policy-CSP-Bypass-Learning.md` | Content Security Policy (CSP) Bypass Learning | exercise | advanced |

### Category: Clickjacking

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 34 | `34-Clickjacking-and-UI-Redressing-Learning.md` | Clickjacking and UI Redressing Learning | exercise | beginner |

### Category: HTTP Parameter Pollution

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 35 | `35-HTTP-Parameter-Pollution-Learning.md` | HTTP Parameter Pollution Learning | exercise | intermediate |

### Category: LDAP Injection

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 36 | `36-LDAP-Injection-Learning.md` | LDAP Injection Learning | exercise | intermediate |

### Category: Session Puzzling

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 37 | `37-Session-Puzzling-and-Fixation-Learning.md` | Session Puzzling and Fixation Learning | exercise | intermediate |

### Category: File Handling

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 38 | `38-Insecure-File-Handling-Learning.md` | Insecure File Handling Learning | exercise | beginner-intermediate |

### Category: Advanced Client-Side

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 39 | `39-Advanced-Client-Side-Attacks-Learning.md` | Advanced Client-Side Attacks Learning | exercise | advanced |

### Category: Authentication Variant

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 40 | `40-Cloud-Security-and-Misconfigurations-Learning.md` | Cloud Security and Misconfigurations Learning | exercise | intermediate |

### Category: Third-Party Integration

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 41 | `41-Third-Party-Integration-Security-Learning.md` | Third-Party Integration Security Learning | exercise | intermediate |

### Category: Mobile Application

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 42 | `42-Mobile-Application-Security-Learning.md` | Mobile Application Security Learning | exercise | intermediate |

### Category: IoT and Embedded

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 43 | `43-IoT-and-Embedded-Device-Security-Learning.md` | IoT and Embedded Device Security Learning | exercise | advanced |

### Category: API Security

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 44 | `44-API-Security-and-GraphQL-Learning.md` | API Security and GraphQL Learning | exercise | intermediate |

### Category: WebAssembly

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 45 | `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` | WebAssembly and Modern Web Technologies Learning | exercise | advanced |

### Category: Blockchain

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 46 | `46-Blockchain-and-Cryptocurrency-Security-Learning.md` | Blockchain and Cryptocurrency Security Learning | exercise | advanced |

### Category: Automation

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 47 | `47-Automation-and-Tool-Development-Learning.md` | Automation and Tool Development Learning | exercise | intermediate |

### Category: Reverse Engineering

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 48 | `48-Advanced-Reverse-Engineering-Learning.md` | Advanced Reverse Engineering Learning | exercise | expert |

### Category: Compliance

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 49 | `49-Compliance-and-Regulatory-Security-Learning.md` | Compliance and Regulatory Security Learning | exercise | intermediate |

### Category: Threat Modeling

| ID | File | Title | Assessment Type | Difficulty |
|----|------|-------|-----------------|------------|
| 50 | `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` | Advanced Threat Modeling and Risk Assessment Learning | exercise | expert |

---

## Learning Pathways

| Pathway | Files | Estimated Time |
|---------|-------|----------------|
| Web Security Fundamentals | 01-20 | 10 hours |
| Advanced Web Exploitation | 21-38 | 8 hours |
| Specialized Technologies | 39-50 | 6 hours |
| Complete Curriculum | 01-50 | 24 hours |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
