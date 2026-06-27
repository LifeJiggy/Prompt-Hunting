# Report Writing Mastery — Tool Execution Domain

**Component:** Tool Executor for Report Generation  
**Domain:** `report-writing-mastery`  
**Registry:** `Report-Writing-Mastery/registry.json`  
**File Count:** 54 prompt files  
**Execution Mode:** Report generation tool execution with template processing

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `report-writing-mastery` |
| Domain Path | `Report-Writing-Mastery/` |
| Category | `reports` |
| Execution Profile | `report-generator` |
| Default Timeout | 120s |
| Max Timeout | 600s |
| Default Retries | 2 |
| Concurrency Limit | 5 |
| Stealth Level | `none` |
| Rate Limit | 20 req/s |

---

## Overview

The Report Writing Mastery executor manages tool execution for vulnerability report generation and optimization. This domain covers 54 prompt files spanning report structure optimization, technical writing standards, private program case studies, proof-of-concept development, vulnerability severity assessment, remediation recommendations, executive summary crafting, technical detail balancing, visual aid integration, code sample formatting, timeline documentation, collaboration crediting, program-specific formatting, language and tone optimization, attachment management, follow-up communication, rejection analysis and improvement, reward negotiation preparation, report template development, quality assurance process, grammar and style standards, technical accuracy verification, impact quantification, business context integration, compliance documentation, international standard adherence, audience analysis, information hierarchy, actionable recommendations, report review process, common pitfalls avoidance, advanced formatting techniques, multimedia integration, interactive report elements, cross-platform compatibility, version control for reports, report analytics and metrics, peer review optimization, program feedback incorporation, continuous improvement, report personalization, contextual intelligence, technical depth calibration, impact visualization, report archiving strategy, collaboration report standards, advanced proof-of-concept, report automation tools, quality metrics development, master report writing framework, Bugcrowd finding dissection, HackerOne report analysis, high-severity vulnerability analysis, and impact communication.

This executor runs report generation tools that transform raw findings into structured, high-quality vulnerability reports optimized for program acceptance.

---

## Execution Schema

### ReportInvocation (Input)

```json
{
  "tool": "string — report generation tool",
  "report_type": "string — full|executive|technical|summary",
  "input": {
    "findings": ["object — vulnerability findings"],
    "template": "string — report template name",
    "target_info": {
      "program": "string — program name",
      "platform": "string — platform name",
      "scope": "string — program scope"
    },
    "options": {
      "include_poc": "boolean",
      "include_remediation": "boolean",
      "include_cvss": "boolean",
      "tone": "string — professional|technical|concise"
    }
  },
  "config": {
    "timeout": "number",
    "retries": "number",
    "output_format": "string — markdown|html|pdf"
  }
}
```

### ReportResult (Output)

```json
{
  "status": "string",
  "report": {
    "title": "string",
    "severity": "string",
    "cvss_score": "number",
    "executive_summary": "string",
    "technical_detail": "string",
    "impact_statement": "string",
    "remediation": "string",
    "poc": "string",
    "metadata": "object"
  },
  "quality_score": "number — 0-100",
  "word_count": "number",
  "duration_ms": "number"
}
```

---

## Run Operations

### Report Generation

```python
def run_report_generation(
    self,
    tool: str,
    report_type: str,
    input_data: dict,
    config: dict = None
) -> ReportResult:
    """
    Execute a report generation tool.
    
    Flow:
    1. Load report template
    2. Process findings data
    3. Apply formatting rules
    4. Generate report sections
    5. Calculate quality metrics
    6. Return formatted report
    """
```

### Executive Summary Generation

```python
def generate_executive_summary(
    self,
    findings: list[dict],
    tone: str = "professional"
) -> ReportResult:
    """
    Generate an executive summary from findings.
    Focuses on business impact and high-level overview.
    """
```

### Technical Detail Generation

```python
def generate_technical_detail(
    self,
    findings: list[dict],
    include_poc: bool = True
) -> ReportResult:
    """
    Generate technical details for findings.
    Includes exploitation steps and proof-of-concept.
    """
```

### Quality Assessment

```python
def assess_report_quality(
    self,
    report: dict
) -> ReportResult:
    """
    Assess the quality of a generated report.
    Returns quality score and improvement suggestions.
    """
```

---

## Stop Operations

### Report Stop

```python
def stop_report_generation(
    self,
    invocation_id: str
) -> StopResult:
    """Stop a running report generation."""
```

---

## Retry Operations

### Report Retry Configuration

```python
@dataclass
class ReportRetryConfig:
    max_retries: int = 2
    backoff_base: float = 1.0
    retry_on_template_error: bool = True
    retry_on_format_error: bool = True
```

---

## Timeout Handling

### Report Timeout Configuration

```python
@dataclass
class ReportTimeoutConfig:
    default: int = 120
    overrides: dict[str, int] = field(default_factory=lambda: {
        "full_report": 300,
        "executive_summary": 60,
        "technical_detail": 180,
        "quality_assessment": 30,
        "template_processing": 15,
        "format_conversion": 60,
        "cvss_calculation": 10,
        "screenshot_processing": 120,
        "pdf_generation": 180
    })
    hard_maximum: int = 600
```

---

## Output Capture

### Report Output Capture

```python
@dataclass
class ReportCapturedOutput:
    report: dict
    quality_score: float
    word_count: int
    sections_generated: int
    duration_ms: int
    output_path: str
```

---

## Stderr Handling

### Report Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process report generation stderr."""
    return StderrResult(
        raw=stderr,
        classification="report_error",
        retryable=True
    )
```

---

## Exit Code Handling

### Report Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process report exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="return_report")
    return ExitCodeResult(status="error", action="retry")
```

---

## Concurrent Execution

### Report Concurrency Configuration

```python
@dataclass
class ReportConcurrencyConfig:
    max_concurrent: int = 5
    max_per_report_type: int = 3
    parallel_sections: bool = True
```

---

## Execution Logging

### Report Execution Log

```python
@dataclass
class ReportExecutionLog:
    invocation_id: str
    tool: str
    report_type: str
    findings_count: int
    quality_score: float
    word_count: int
    duration_ms: int
    timestamp: str
```

---

## Full Domain File References

### Category: Structure and Format

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 01 | `01-Report-Structure-Optimization.md` | Report Structure Optimization | template | high |
| 02 | `02-Technical-Writing-Standards.md` | Technical Writing Standards | reference | high |
| 08 | `08-Technical-Detail-Balancing.md` | Technical Detail Balancing | technique | medium |
| 10 | `10-Code-Sample-Formatting.md` | Code Sample Formatting | formatting | medium |
| 13 | `13-Program-Specific-Formatting.md` | Program Specific Formatting | template | medium |
| 19 | `19-Report-Template-Development.md` | Report Template Development | template | high |
| 32 | `32-Advanced-Formatting-Techniques.md` | Advanced Formatting Techniques | technique | medium |
| 35 | `35-Cross-Platform-Compatibility.md` | Cross Platform Compatibility | reference | medium |

### Category: Content Writing

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 07 | `07-Executive-Summary-Crafting.md` | Executive Summary Crafting | section | high |
| 14 | `14-Language-and-Tone-Optimization.md` | Language and Tone Optimization | technique | medium |
| 21 | `21-Grammar-and-Style-Standards.md` | Grammar and Style Standards | reference | medium |
| 27 | `27-Audience-Analysis.md` | Audience Analysis | technique | medium |
| 28 | `28-Information-Hierarchy.md` | Information Hierarchy | technique | medium |
| 29 | `29-Actionable-Recommendations.md` | Actionable Recommendations | section | high |
| 41 | `41-Report-Personalization.md` | Report Personalization | technique | medium |
| 42 | `42-Contextual-Intelligence.md` | Contextual Intelligence | technique | medium |
| 43 | `43-Technical-Depth-Calibration.md` | Technical Depth Calibration | technique | medium |

### Category: Technical Depth

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 04 | `04-Proof-of-Concept-Development.md` | Proof of Concept Development | section | high |
| 22 | `22-Technical-Accuracy-Verification.md` | Technical Accuracy Verification | quality | high |
| 47 | `47-Advanced-Proof-of-Concept.md` | Advanced Proof of Concept | section | high |

### Category: Impact and Severity

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 05 | `05-Vulnerability-Severity-Assessment.md` | Vulnerability Severity Assessment | section | high |
| 23 | `23-Impact-Quantification.md` | Impact Quantification | technique | high |
| 24 | `24-Business-Context-Integration.md` | Business Context Integration | technique | medium |
| 44 | `44-Impact-Visualization.md` | Impact Visualization | technique | medium |
| 53 | `High-Severity-Vulnerability-Analysis.md` | High Severity Vulnerability Analysis | analysis | high |
| 54 | `Impact-Communication.md` | Impact Communication | technique | high |

### Category: Proof of Concept

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 09 | `09-Visual-Aid-Integration.md` | Visual Aid Integration | section | medium |
| 33 | `33-Multimedia-Integration.md` | Multimedia Integration | section | medium |
| 34 | `34-Interactive-Report-Elements.md` | Interactive Report Elements | section | medium |

### Category: Triage Optimization

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 03 | `03-Private-Program-Case-Study.md` | Private Program Case Study | case-study | medium |
| 16 | `16-Follow-up-Communication.md` | Follow-up Communication | communication | medium |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | Rejection Analysis and Improvement | analysis | medium |
| 18 | `18-Reward-Negotiation-Preparation.md` | Reward Negotiation Preparation | technique | medium |
| 31 | `31-Common-Pitfalls-Avoidance.md` | Common Pitfalls Avoidance | reference | high |
| 39 | `39-Program-Feedback-Incorporation.md` | Program Feedback Incorporation | technique | medium |

### Category: Quality Assurance

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 20 | `20-Quality-Assurance-Process.md` | Quality Assurance Process | quality | high |
| 30 | `30-Report-Review-Process.md` | Report Review Process | quality | medium |
| 37 | `37-Report-Analytics-and-Metrics.md` | Report Analytics and Metrics | analytics | medium |
| 38 | `38-Peer-Review-Optimization.md` | Peer Review Optimization | quality | medium |
| 40 | `40-Continuous-Improvement.md` | Continuous Improvement | quality | medium |
| 49 | `49-Quality-Metrics-Development.md` | Quality Metrics Development | analytics | medium |
| 50 | `50-Master-Report-Writing-Framework.md` | Master Report Writing Framework | framework | high |

### Category: Platform Specific

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 51 | `Bugcrowd-Finding-Dissection.md` | Bugcrowd Finding Dissection | platform | medium |
| 52 | `HackerOne-Report-Analysis.md` | HackerOne Report Analysis | platform | medium |

### Category: Operations

| ID | File | Title | Report Type | Priority |
|----|------|-------|-------------|----------|
| 06 | `06-Remediation-Recommendations.md` | Remediation Recommendations | section | high |
| 11 | `11-Timeline-Documentation.md` | Timeline Documentation | section | medium |
| 12 | `12-Collaboration-Crediting.md` | Collaboration Crediting | section | medium |
| 15 | `15-Attachment-Management.md` | Attachment Management | operations | medium |
| 25 | `25-Compliance-Documentation.md` | Compliance Documentation | reference | medium |
| 26 | `26-International-Standard-Adherence.md` | International Standard Adherence | reference | medium |
| 36 | `36-Version-Control-for-Reports.md` | Version Control for Reports | operations | medium |
| 45 | `45-Report-Archiving-Strategy.md` | Report Archiving Strategy | operations | medium |
| 46 | `46-Collaboration-Report-Standards.md` | Collaboration Report Standards | reference | medium |
| 48 | `48-Report-Automation-Tools.md` | Report Automation Tools | tools | medium |

---

## Report Quality Metrics

| Metric | Target | Description |
|--------|--------|-------------|
| Clarity Score | > 85/100 | Readability and comprehension |
| Technical Accuracy | > 95/100 | Factual correctness |
| Impact Framing | > 80/100 | Business impact clarity |
| PoC Completeness | > 90/100 | Reproducibility evidence |
| Format Compliance | > 95/100 | Platform-specific formatting |
| Grammar/Style | > 90/100 | Writing quality |
| Overall Quality | > 85/100 | Combined assessment |

---

## Report Templates

| Template | Sections | Use Case |
|----------|----------|----------|
| Full Vulnerability | 8 sections | Complete report for submission |
| Executive Summary | 3 sections | Quick overview for management |
| Technical Detail | 5 sections | In-depth technical analysis |
| PoC Focused | 4 sections | Emphasis on exploitation |
| Remediation Focused | 4 sections | Emphasis on fix guidance |
| Collaboration | 6 sections | Multi-researcher reports |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
