# Advanced Chaining Techniques — Tool Execution Domain

**Component:** Tool Executor for Vulnerability Chaining  
**Domain:** `advanced-chaining-techniques`  
**Registry:** `Advanced-Chaining-Techniques/registry.json`  
**File Count:** 49 prompt files  
**Execution Mode:** Sequential chain step execution with dependency tracking

---

## Domain Mapping

| Property | Value |
|----------|-------|
| Domain ID | `advanced-chaining-techniques` |
| Domain Path | `Advanced-Chaining-Techniques/` |
| Category | `chaining` |
| Execution Profile | `chain-orchestrator` |
| Default Timeout | 600s |
| Max Timeout | 7200s |
| Default Retries | 2 |
| Concurrency Limit | 3 |
| Stealth Level | `high` |
| Rate Limit | 5 req/s |

---

## Overview

The Advanced Chaining Techniques executor manages tool execution for multi-step vulnerability chains. This domain covers 49 prompt files spanning basic vulnerability chaining, information disclosure to RCE, XSS to account takeover, IDOR to mass data extraction, SQL injection to shell access, SSRF to internal network compromise, CORS misconfiguration chains, CSRF to privilege escalation, file upload to web shell, XXE to sensitive data access, deserialization to RCE, JWT manipulation chains, SSTI to complete compromise, NoSQL injection to data breach, GraphQL abuse chains, WebSocket security chains, prototype pollution exploitation, HTTP request smuggling chains, host header injection chains, DNS rebinding attacks, race condition exploitation, subdomain takeover chains, open redirect to phishing, content spoofing chains, webcache poisoning chains, clickjacking to account compromise, parameter pollution attacks, LDAP injection chains, XPath injection exploitation, session puzzling techniques, insecure file handling chains, cross-site script inclusion, HTTP response splitting, client-side storage abuse, cryptography weakness chains, third-party component chains, configuration misconfiguration chains, network infrastructure chains, mobile API chains, cloud misconfiguration chains, container escape chains, Kubernetes attack chains, blockchain exploit chains, IoT device compromise chains, supply chain attack chains, zero-day chaining strategies, multi-platform attack chains, advanced persistent threat chains, and the master chaining framework.

This executor orchestrates sequential chain execution where each step depends on the output of the previous step. It manages chain state, validates step dependencies, and tracks the overall chain attack path.

---

## Execution Schema

### ChainInvocation (Input)

```json
{
  "chain_id": "string — unique chain identifier",
  "chain_name": "string — human-readable chain name",
  "steps": [
    {
      "step_id": "string — step identifier",
      "tool": "string — tool to execute",
      "input": "object — tool input (may reference prior step outputs)",
      "depends_on": ["string — step IDs this depends on"],
      "condition": "string — optional condition for step execution",
      "timeout": "number — step-specific timeout",
      "retries": "number — step-specific retry count"
    }
  ],
  "initial_context": {
    "target": "string — initial target",
    "session_id": "string — session identifier",
    "agent_id": "string — agent identifier"
  },
  "config": {
    "max_chain_time": "number — total chain timeout",
    "stop_on_failure": "boolean — halt chain on step failure",
    "stealth": "boolean — enable stealth across all steps",
    "log_level": "string — detailed|normal|minimal"
  }
}
```

### ChainResult (Output)

```json
{
  "chain_id": "string",
  "status": "string — completed|failed|partial|aborted",
  "steps_completed": "number",
  "steps_total": "number",
  "step_results": [
    {
      "step_id": "string",
      "status": "string",
      "output": "object",
      "duration_ms": "number"
    }
  ],
  "final_findings": ["object — aggregated findings"],
  "attack_path": ["string — step IDs in execution order"],
  "total_duration_ms": "number",
  "resources": "object"
}
```

---

## Run Operations

### Chain Execution

```python
def run_chain(
    self,
    chain_id: str,
    steps: list[ChainStep],
    initial_context: dict,
    config: dict = None
) -> ChainResult:
    """
    Execute a complete vulnerability chain.
    
    Flow:
    1. Validate chain definition (no circular deps)
    2. Build execution DAG from step dependencies
    3. Execute steps in topological order
    4. Pass step outputs to dependent steps
    5. Track overall chain state
    6. Aggregate findings from all steps
    7. Return ChainResult with full execution trace
    """
```

### Single Chain Step

```python
def run_chain_step(
    self,
    chain_id: str,
    step: ChainStep,
    prior_outputs: dict[str, ToolResult]
) -> ToolResult:
    """
    Execute a single step within a chain.
    
    Substitutes prior step outputs into input template,
    executes the tool, and returns the result.
    """
```

### Chain Step Resolution

```python
def _resolve_step_input(
    self,
    step: ChainStep,
    prior_outputs: dict[str, ToolResult]
) -> dict:
    """
    Resolve input template by substituting prior step outputs.
    
    Supports template variables:
      {{step.step_01.findings[0].url}}
      {{step.step_02.stdout}}
      {{step.step_01.exit_code}}
      {{context.target}}
    """
    resolved = {}
    for key, value in step.input.items():
        if isinstance(value, str) and value.startswith("{{"):
            resolved[key] = self._template_resolve(value, prior_outputs)
        else:
            resolved[key] = value
    return resolved
```

---

## Stop Operations

### Chain Stop

```python
def stop_chain(
    self,
    chain_id: str,
    reason: str = "user_request"
) -> ChainStopResult:
    """
    Stop a running chain execution.
    Completes current step, then halts remaining steps.
    Returns partial results for completed steps.
    """
```

### Step Stop

```python
def stop_step(
    self,
    chain_id: str,
    step_id: str,
    reason: str = "user_request"
) -> StepStopResult:
    """
    Stop the current step in a chain.
    Sends SIGTERM to the tool process.
    """
```

### Chain Abort

```python
def abort_chain(
    self,
    chain_id: str,
    reason: str = "critical_failure"
) -> ChainAbortResult:
    """
    Immediately abort all chain execution.
    Sends SIGKILL to current step process.
    Returns all partial results.
    """
```

---

## Retry Operations

### Chain Retry Configuration

```python
@dataclass
class ChainRetryConfig:
    max_step_retries: int = 2
    max_chain_retries: int = 1
    backoff_base: float = 5.0
    backoff_multiplier: float = 2.0
    retry_on_step_failure: bool = True
    retry_failed_step_only: bool = True
    skip_step_on_failure: bool = False
```

### Chain-Level Retry

When a step fails after all retries:

1. **Evaluate Chain Config**: Check `stop_on_failure` setting
2. **If stop_on_failure=True**: Abort entire chain, return partial results
3. **If stop_on_failure=False**: Skip failed step, attempt next steps with degraded context
4. **Log Decision**: Record retry/skip decision in chain log

### Retry Decision Matrix

| Condition | Step Retry? | Chain Abort? |
|-----------|-------------|--------------|
| Step exit code non-zero | Yes | No |
| Step timeout | Yes | No |
| Step validation error | No | If stop_on_failure |
| Step policy denied | No | If stop_on_failure |
| All retries exhausted | — | If stop_on_failure |
| Critical step failure | No | Yes |

---

## Timeout Handling

### Chain Timeout Configuration

```python
@dataclass
class ChainTimeoutConfig:
    default_step_timeout: int = 600
    default_chain_timeout: int = 7200
    step_overrides: dict[str, int] = field(default_factory=lambda: {
        "nuclei": 1800,
        "sqlmap": 3600,
        "nmap": 600,
        "subfinder": 120,
        "ffuf": 600,
        "katana": 600
    })
    chain_overrides: dict[str, int] = field(default_factory=lambda: {
        "xss_to_ato": 3600,
        "sqli_to_shell": 7200,
        "ssrf_to_internal": 3600,
        "deserialization_to_rce": 3600
    })
```

### Chain Time Budget

```python
def _check_chain_time_budget(
    self,
    chain_start: float,
    chain_timeout: int
) -> bool:
    """Check if chain has remaining time budget."""
    elapsed = time.time() - chain_start
    remaining = chain_timeout - elapsed
    return remaining > 30  # At least 30s remaining
```

---

## Output Capture

### Chain Output Management

```python
@dataclass
class ChainCapturedOutput:
    step_id: str
    stdout: str
    stderr: str
    exit_code: int
    findings: list[dict]
    duration_ms: int
    partial: bool
```

### Output Passing Between Steps

```python
def _pass_output_to_step(
    self,
    prior_result: ToolResult,
    next_step: ChainStep
) -> dict:
    """
    Format prior step output for consumption by next step.
    Extracts relevant fields based on step input schema.
    """
    return {
        "findings": prior_result.findings,
        "stdout": prior_result.stdout,
        "targets": self._extract_targets(prior_result),
        "parameters": self._extract_parameters(prior_result)
    }
```

---

## Stderr Handling

### Chain Stderr Processing

```python
def _process_chain_stderr(
    self,
    step_id: str,
    stderr: str,
    chain_config: dict
) -> ChainStderrResult:
    """
    Process stderr within chain context.
    Distinguishes between step-level errors and chain-level errors.
    """
    # Classify error
    classification = self._classify_stderr(stderr)
    
    # Determine chain impact
    if classification.severity == "critical":
        return ChainStderrResult(
            action="abort_chain",
            reason=f"Critical error in step {step_id}"
        )
    elif classification.retryable:
        return ChainStderrResult(
            action="retry_step",
            reason=f"Retryable error in step {step_id}"
        )
    else:
        return ChainStderrResult(
            action="skip_step",
            reason=f"Non-retryable error in step {step_id}"
        )
```

---

## Exit Code Handling

### Chain Exit Code Processing

```python
def _process_chain_exit_code(
    self,
    step_id: str,
    exit_code: int,
    chain_config: dict
) -> ChainExitResult:
    """Process exit code within chain context."""
    if exit_code == 0:
        return ChainExitResult(status="step_success", continue_chain=True)
    
    if exit_code in self._retry_config.retry_on_exit_codes:
        return ChainExitResult(status="retry_step", continue_chain=False)
    
    if chain_config.get("stop_on_failure", True):
        return ChainExitResult(status="abort_chain", continue_chain=False)
    else:
        return ChainExitResult(status="skip_step", continue_chain=True)
```

---

## Concurrent Execution

### Chain Concurrency Configuration

```python
@dataclass
class ChainConcurrencyConfig:
    max_concurrent_chains: int = 3
    max_steps_per_chain: int = 1  # Steps are sequential
    parallel_independent_steps: bool = True
    max_parallel_steps: int = 3
```

### Independent Step Parallelization

When multiple steps have no dependencies on each other, they can execute in parallel:

```python
async def _execute_parallel_steps(
    self,
    parallel_group: list[ChainStep],
    prior_outputs: dict
) -> list[ToolResult]:
    """Execute independent steps in parallel."""
    tasks = []
    for step in parallel_group:
        resolved_input = self._resolve_step_input(step, prior_outputs)
        tasks.append(self._run_tool_async(step.tool, resolved_input))
    
    return await asyncio.gather(*tasks)
```

---

## Execution Logging

### Chain Execution Log

```python
@dataclass
class ChainExecutionLog:
    chain_id: str
    chain_name: str
    agent_id: str
    session_id: str
    timestamp_start: str
    timestamp_end: str
    total_duration_ms: int
    status: str
    steps_completed: int
    steps_total: int
    step_logs: list[StepExecutionLog]
    attack_path: list[str]
    findings_total: int
    findings_by_severity: dict[str, int]
    resources: ResourceUsage
```

### Step Execution Log

```python
@dataclass
class StepExecutionLog:
    step_id: str
    tool: str
    status: str
    duration_ms: int
    exit_code: int
    findings_count: int
    retry_count: int
    error_message: str = None
```

---

## Full Domain File References

### Category: Foundational

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 1 | `01-Basic-Vulnerability-Chaining.md` | Basic Vulnerability Chaining | 600s | 2 |

### Category: Information to RCE

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 2 | `02-Information-Disclosure-to-RCE.md` | Information Disclosure to RCE | 1200s | 2 |

### Category: Client-Side Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 3 | `03-XSS-to-Account-Takeover.md` | XSS to Account Takeover | 1200s | 2 |
| 4 | `07-CORS-Misconfiguration-Chains.md` | CORS Misconfiguration Chains | 600s | 2 |
| 5 | `08-CSRF-to-Privilege-Escalation.md` | CSRF to Privilege Escalation | 600s | 2 |
| 6 | `24-Open-Redirect-to-Phishing.md` | Open Redirect to Phishing | 300s | 2 |
| 7 | `25-Content-Spoofing-Chains.md` | Content Spoofing Chains | 300s | 2 |
| 8 | `27-Clickjacking-to-Account-Compromise.md` | Clickjacking to Account Compromise | 300s | 2 |
| 9 | `33-Cross-Site-Script-Inclusion.md` | Cross-Site Script Inclusion | 300s | 2 |
| 10 | `35-Client-Side-Storage-Abuse.md` | Client-Side Storage Abuse | 300s | 2 |

### Category: Injection Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 11 | `05-SQL-Injection-to-Shell-Access.md` | SQL Injection to Shell Access | 3600s | 3 |
| 12 | `10-XXE-to-Sensitive-Data-Access.md` | XXE to Sensitive Data Access | 600s | 2 |
| 13 | `15-NoSQL-Injection-to-Data-Breach.md` | NoSQL Injection to Data Breach | 1200s | 2 |
| 14 | `29-LDAP-Injection-Chains.md` | LDAP Injection Chains | 600s | 2 |
| 15 | `30-XPath-Injection-Exploitation.md` | XPath Injection Exploitation | 600s | 2 |

### Category: Server-Side Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 16 | `04-IDOR-to-Mass-Data-Extraction.md` | IDOR to Mass Data Extraction | 1200s | 3 |
| 17 | `06-SSRF-to-Internal-Network-Compromise.md` | SSRF to Internal Network Compromise | 1800s | 2 |
| 18 | `09-File-Upload-to-Web-Shell.md` | File Upload to Web Shell | 600s | 2 |
| 19 | `11-Deserialization-to-RCE.md` | Deserialization to RCE | 1200s | 2 |
| 20 | `13-SSTI-to-Complete-Compromise.md` | SSTI to Complete Compromise | 1200s | 2 |
| 21 | `32-Insecure-File-Handling-Chains.md` | Insecure File Handling Chains | 600s | 2 |

### Category: Authentication and Session Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 22 | `12-JWT-Manipulation-Chains.md` | JWT Manipulation Chains | 600s | 2 |
| 23 | `31-Session-Puzzling-Techniques.md` | Session Puzzling Techniques | 600s | 2 |

### Category: API and Modern Architecture Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 24 | `16-GraphQL-Abuse-Chains.md` | GraphQL Abuse Chains | 600s | 2 |
| 25 | `17-WebSocket-Security-Chains.md` | WebSocket Security Chains | 600s | 2 |
| 26 | `40-Mobile-API-Chains.md` | Mobile API Chains | 1200s | 2 |

### Category: Protocol-Level Attack Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 27 | `19-HTTP-Request-Smuggling-Chains.md` | HTTP Request Smuggling Chains | 600s | 2 |
| 28 | `20-Host-Header-Injection-Chains.md` | Host Header Injection Chains | 300s | 2 |
| 29 | `26-WebCache-Poisoning-Chains.md` | WebCache Poisoning Chains | 600s | 2 |
| 30 | `28-Parameter-Pollution-Attacks.md` | Parameter Pollution Attacks | 300s | 2 |
| 31 | `34-HTTP-Response-Splitting.md` | HTTP Response Splitting | 300s | 2 |

### Category: Advanced Exploitation Techniques

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 32 | `14-Open-Redirect-Chains.md` | Open Redirect Chains | 300s | 2 |
| 33 | `18-Prototype-Pollution-Exploitation.md` | Prototype Pollution Exploitation | 600s | 2 |
| 34 | `21-DNS-Rebinding-Attacks.md` | DNS Rebinding Attacks | 1200s | 2 |
| 35 | `22-Race-Condition-Exploitation.md` | Race Condition Exploitation | 600s | 3 |
| 36 | `23-Subdomain-Takeover-Chains.md` | Subdomain Takeover Chains | 600s | 2 |

### Category: Cryptography Weakness Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 37 | `36-Cryptography-Weakness-Chains.md` | Cryptography Weakness Chains | 600s | 2 |

### Category: Infrastructure Attack Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 38 | `37-Third-Party-Component-Chains.md` | Third-Party Component Chains | 600s | 2 |
| 39 | `38-Configuration-Misconfiguration-Chains.md` | Configuration Misconfiguration Chains | 600s | 2 |
| 40 | `39-Network-Infrastructure-Chains.md` | Network Infrastructure Chains | 1200s | 2 |

### Category: Cloud and Container Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 41 | `41-Cloud-Misconfiguration-Chains.md` | Cloud Misconfiguration Chains | 1200s | 2 |
| 42 | `42-Container-Escape-Chains.md` | Container Escape Chains | 1200s | 2 |
| 43 | `43-Kubernetes-Attack-Chains.md` | Kubernetes Attack Chains | 1800s | 2 |

### Category: Specialized Attack Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 44 | `44-Blockchain-Exploit-Chains.md` | Blockchain Exploit Chains | 1800s | 2 |
| 45 | `45-IoT-Device-Compromise-Chains.md` | IoT Device Compromise Chains | 1200s | 2 |

### Category: Advanced Persistent Threat Chains

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 46 | `46-Supply-Chain-Attack-Chains.md` | Supply Chain Attack Chains | 3600s | 2 |
| 47 | `47-Zero-Day-Chaining-Strategies.md` | Zero-Day Chaining Strategies | 3600s | 2 |
| 48 | `48-Multi-Platform-Attack-Chains.md` | Multi-Platform Attack Chains | 3600s | 2 |
| 49 | `49-Advanced-Persistent-Threat-Chains.md` | Advanced Persistent Threat Chains | 7200s | 2 |

### Category: Master Framework

| ID | File | Title | Timeout | Retries |
|----|------|-------|---------|---------|
| 50 | `50-Master-Chaining-Framework.md` | Master Chaining Framework | 7200s | 3 |

---

## Chain State Management

### State Transitions

```
CREATED → VALIDATING → EXECUTING → COMPLETED
                                  → FAILED
                                  → ABORTED
                                  → PARTIAL (stop_on_failure=false)
```

### State Persistence

```python
def _persist_chain_state(self, chain_id: str, state: ChainState) -> None:
    """
    Persist chain state to disk for crash recovery.
    Enables resuming interrupted chains.
    """
    state_path = self._state_dir / f"{chain_id}.state.json"
    with open(state_path, "w") as f:
        json.dump(state.to_dict(), f)
```

### Chain Resume

```python
def resume_chain(self, chain_id: str) -> ChainResult:
    """
    Resume an interrupted chain from persisted state.
    Skips completed steps, resumes from last incomplete step.
    """
    state = self._load_chain_state(chain_id)
    return self._execute_chain_from_state(state)
```

---

*Part of the Brain tools executor subsystem — Prompt-Hunting.*
