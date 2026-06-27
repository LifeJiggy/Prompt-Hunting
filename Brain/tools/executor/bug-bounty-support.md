# Bug Bounty Support — Tool Execution Domain

**Component:** Tool Executor for Support References  
**Domain:** `bug-bounty-support`  
**Registry:** `bug-bounty-support/registry.json`  
**File Count:** 23 prompt files  
**Execution Mode:** Reference lookup and knowledge retrieval execution

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `bug-bounty-support` |
| Domain Path | `bug-bounty-support/` |
| Category | `support` |
| Execution Profile | `reference` |
| Default Timeout | 30s |
| Max Timeout | 120s |
| Default Retries | 1 |
| Concurrency Limit | 10 |
| Stealth Level | `none` |
| Rate Limit | 50 req/s |

---

## Overview

The Bug Bounty Support executor manages tool execution for reference lookups, knowledge retrieval, and support operations. This domain covers 23 prompt files spanning advanced bug bounty prompt engineering, core aspects for bug security hunting, advanced information disclosure analysis, advanced JavaScript vulnerability analysis, advanced techniques, Burp Suite AI integration, chaining strategies, debugging using browser console and VSCode, ethical guidelines, exploitation techniques, JavaScript identification and deobfuscation, manual testing scope, parameters analysis, PoC development, reconnaissance methodology, reporting guidance, specific vulnerabilities hunting, static and dynamic testing, injection point identification, tools integration, user functionality mapping, and vulnerability detection.

This executor provides fast reference lookups, knowledge base queries, and contextual information retrieval for bug bounty operations. It is optimized for low-latency reads with aggressive caching.

---

## Execution Schema

### SupportInvocation (Input)

```json
{
  "tool": "string — reference tool name",
  "lookup_type": "string — reference|guide|technique|template|example",
  "input": {
    "query": "string — search query or topic",
    "context": {
      "vuln_class": "string — vulnerability class filter",
      "platform": "string — target platform",
      "difficulty": "string — beginner|intermediate|advanced"
    },
    "format": "string — full|summary|cheatsheet"
  },
  "config": {
    "timeout": "number",
    "cache": "boolean — use cached results",
    "max_results": "number"
  }
}
```

### SupportResult (Output)

```json
{
  "status": "string",
  "results": [
    {
      "source_file": "string — source file path",
      "title": "string — reference title",
      "content": "string — reference content",
      "relevance_score": "number — 0-1",
      "category": "string"
    }
  ],
  "total_results": "number",
  "duration_ms": "number"
}
```

---

## Run Operations

### Reference Lookup

```python
def run_lookup(
    self,
    tool: str,
    lookup_type: str,
    query: str,
    context: dict = None
) -> SupportResult:
    """
    Execute a reference lookup.
    
    Flow:
    1. Check cache for matching results
    2. Search reference database
    3. Rank results by relevance
    4. Format and return results
    5. Cache results for future lookups
    """
```

### Knowledge Query

```python
def query_knowledge(
    self,
    topic: str,
    depth: str = "summary"
) -> SupportResult:
    """
    Query the knowledge base for topic information.
    Returns relevant references ranked by relevance.
    """
```

### Template Retrieval

```python
def get_template(
    self,
    template_type: str,
    vuln_class: str = None
) -> SupportResult:
    """
    Retrieve a template for vulnerability reporting,
    PoC development, or tool configuration.
    """
```

---

## Stop Operations

### Reference Stop

```python
def stop_lookup(
    self,
    invocation_id: str
) -> StopResult:
    """Stop a running reference lookup."""
```

---

## Retry Operations

### Support Retry Configuration

```python
@dataclass
class SupportRetryConfig:
    max_retries: int = 1
    backoff_base: float = 0.5
    retry_on_cache_miss: bool = True
    retry_on_parse_error: bool = True
```

---

## Timeout Handling

### Support Timeout Configuration

```python
@dataclass
class SupportTimeoutConfig:
    default: int = 30
    overrides: dict[str, int] = field(default_factory=lambda: {
        "reference_lookup": 10,
        "knowledge_query": 30,
        "template_retrieval": 5,
        "guide_fetch": 15,
        "technique_search": 20,
        "example_lookup": 10,
        "full_content_fetch": 60
    })
    hard_maximum: int = 120
```

---

## Output Capture

### Support Output Capture

```python
@dataclass
class SupportCapturedOutput:
    results: list[dict]
    total_count: int
    cache_hit: bool
    search_time_ms: int
    format_time_ms: int
```

---

## Stderr Handling

### Support Stderr Processing

```python
def _process_stderr(self, stderr: str) -> StderrResult:
    """Process support tool stderr."""
    return StderrResult(
        raw=stderr,
        classification=self._classify_support_error(stderr),
        retryable=True
    )
```

---

## Exit Code Handling

### Support Exit Code Processing

```python
def _process_exit_code(self, exit_code: int) -> ExitCodeResult:
    """Process support tool exit code."""
    if exit_code == 0:
        return ExitCodeResult(status="success", action="return_results")
    return ExitCodeResult(status="error", action="retry_with_fallback")
```

---

## Concurrent Execution

### Support Concurrency Configuration

```python
@dataclass
class SupportConcurrencyConfig:
    max_concurrent: int = 10
    max_per_lookup_type: int = 5
    parallel_search: bool = True
```

---

## Execution Logging

### Support Execution Log

```python
@dataclass
class SupportExecutionLog:
    invocation_id: str
    tool: str
    lookup_type: str
    query: str
    results_count: int
    cache_hit: bool
    duration_ms: int
    timestamp: str
```

---

## Full Domain File References

### Category: Core Frameworks

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 01 | `Advanced-Bug-Bounty-Prompt.md` | Advanced Bug Bounty Prompt | guide | prompt-engineering, ai-assisted, workflow |
| 02 | `Core-Aspects-for-Bug-Security-Hunting.md` | Core Aspects for Bug Security Hunting | reference | fundamentals, methodology, mindset |

### Category: Vulnerability Analysis

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 03 | `Advanced-Bug-Security-Hunting-Prompt.md` | Advanced Bug Security Hunting Prompt | technique | advanced, vulnerability-discovery |
| 04 | `Advanced-Information-Disclosure-Analysis-Prompt.md` | Advanced Information Disclosure Analysis Prompt | technique | information-disclosure, error-handling |
| 05 | `Advanced-JavaScript-Vulnerability-Analysis-Prompt.md` | Advanced JavaScript Vulnerability Analysis Prompt | technique | javascript, prototype-pollution, dom-xss |
| 06 | `JavaScript-Identification-Deobfuscation.md` | JavaScript Identification Deobfuscation | technique | javascript, deobfuscation, reverse-engineering |
| 07 | `parameters.md` | Parameters | reference | parameters, idor, injection, mutation |
| 08 | `Specific-Vulnerabilities-Hunting.md` | Specific Vulnerabilities Hunting | technique | xss, sqli, ssrf, xxe, csrf |
| 09 | `to-identify-injection-and-reflected-point-during-testing.md` | Injection Point Identification | technique | injection, reflection, input-analysis |
| 10 | `Vulnerability-Detection.md` | Vulnerability Detection | reference | detection, patterns, signatures |

### Category: Methodology

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 11 | `Advanced-Techniques.md` | Advanced Techniques | technique | advanced, waf-bypass, rate-limit |
| 12 | `Chaining.md` | Chaining | technique | chaining, privilege-escalation |
| 13 | `Exploitation.md` | Exploitation | technique | exploitation, poc, impact-demonstration |
| 14 | `Reconnaissance.md` | Reconnaissance | reference | reconnaissance, asset-discovery |
| 15 | `static-and-dynamic-testing.md` | Static and Dynamic Testing | reference | sast, dast, source-code-review |

### Category: Tools

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 16 | `Burp-AI.md` | Burp AI | reference | burp-suite, ai-integration, scanning |
| 17 | `debuging-using-browser-console-and-vscode-for-hunting.md` | Browser Console and VSCode Debugging | reference | browser-devtools, vscode, debugging |
| 18 | `Tools-Integration.md` | Tools Integration | reference | integration, automation, workflow |

### Category: Reporting

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 19 | `PoC-Development.md` | PoC Development | template | poc, documentation, reproducibility |
| 20 | `Reporting.md` | Reporting | template | reporting, severity, submission |

### Category: Scope and Ethics

| ID | File | Title | Lookup Type | Tags |
|----|------|-------|-------------|------|
| 21 | `Ethical-Guidelines.md` | Ethical Guidelines | reference | ethics, legal, responsible-disclosure |
| 22 | `manual-testing-scope.md` | Manual Testing Scope | reference | scope, authorization, boundaries |
| 23 | `user-functionality.md` | User Functionality | reference | functionality, attack-surface, enumeration |

---

## Usage Patterns

### New Target Engagement

```
1. Ethical-Guidelines.md (load boundaries)
2. Reconnaissance.md (recon methodology)
3. Core-Aspects-for-Bug-Security-Hunting.md (core principles)
4. Specific-Vulnerabilities-Hunting.md (target vulns)
```

### Deep Vulnerability Analysis

```
1. to-identify-injection-and-reflected-point-during-testing.md
2. Specific-Vulnerabilities-Hunting.md (target class)
3. Exploitation.md (exploitation techniques)
4. Reporting.md (report structure)
```

### Tool-Assisted Hunting

```
1. Advanced-Bug-Bounty-Prompt.md (prompt engineering)
2. Burp-AI.md (Burp integration)
3. debuging-using-browser-console-and-vscode-for-hunting.md
4. Tools-Integration.md (workflow optimization)
```

### Report Writing

```
1. PoC-Development.md (PoC templates)
2. Reporting.md (report structure)
3. Advanced-Information-Disclosure-Analysis-Prompt.md (impact framing)
```

---

## Cache Strategy

| Lookup Type | TTL | Max Cache Size |
|-------------|-----|----------------|
| reference_lookup | 24h | 1000 entries |
| knowledge_query | 12h | 500 entries |
| template_retrieval | 48h | 200 entries |
| guide_fetch | 24h | 300 entries |
| technique_search | 6h | 800 entries |

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
