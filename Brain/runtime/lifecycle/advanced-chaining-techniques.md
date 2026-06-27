# Advanced Chaining Techniques — Process Lifecycle Management

## Domain Mapping

| Attribute | Value |
|-----------|-------|
| Domain ID | `advanced-chaining-techniques` |
| Domain Path | `Advanced-Chaining-Techniques/` |
| File Count | 50 prompt files |
| Registry | `Advanced-Chaining-Techniques/registry.json` |
| Category | Chain Execution and State Management |
| Lifecycle Scope | Chain runners, state managers, dependency resolvers, result aggregators |

## Overview

This document defines the complete process lifecycle management for the Advanced Chaining Techniques domain. The domain encompasses 50 prompt files that define multi-stage vulnerability chaining strategies, from basic vulnerability chains to advanced persistent threat chains. The lifecycle manages the execution of chain processes that link individual vulnerabilities into exploit sequences.

Chain execution requires careful state management because each chain step depends on the output of previous steps. The lifecycle ensures state consistency, handles rollback on chain failure, and manages the complex dependency graphs between chain stages.

## Process State Machine

```
                    +------------------+
                    |                  |
            +------>|    CREATED       |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+
            |       |                  |
            |       |   INITIALIZING   |
            |       |                  |
            |       +--------+---------+
            |                |
            |                v
            |       +--------+---------+    timeout/error    +-----------+
            |       |                  +-------------------->|           |
            |       |    STARTING      |                     |  FAILED   |
            |       |                  |<----+               |           |
            |       +--------+---------+     |               +-----------+
            |                |               |                     |
            |                v               |  retry              |
            |       +--------+---------+     |                     |
            |       |                  +-----+                     |
            +-------+    RUNNING       |                           |
            |       |                  |    +---------+            |
            |       +--+----+----+-----+    | ROLLING |            |
            |          |    |    |          |  BACK   |            |
            |    pause |    |    | complete +---------+            |
            |          v    |    v             ^   |               |
            |    +-----+--+ |  +-----------+  |   | error         |
            |    |        | |  |           |  |   | during        |
            |    |PAUSED  | |  |COMPLETED  |  |   | chain         |
            |    |        | |  |           |  |   |               |
            |    +---+----+ |  +-----------+  |   |               |
            |        |      |       |        |   |               |
            | resume |      |       v        |   |               |
            |        v      |  +----+----+   |   |               |
            |       +------+  | CHAIN     |  |   |               |
            |       |         | COMPLETED |  |   |               |
            |       |         +----+------+  |   |               |
            |       |              |         |   |               |
            |       |    +---------+---------+---+               |
            |       |    |                                       |
            |       +----+--- STOPPING --------------------------+
            |              |                                     |
            |              v                                     |
            +--------+------+------+                              |
                     |             |                              |
                     |   STOPPED   |<-----------------------------+
                     |             |
                     +-------------+
```

## State Definitions

### CREATED

Process entry allocated. Chain execution plan loaded from `Advanced-Chaining-Techniques/registry.json`.

**Internal data:**
- Process ID assigned
- Chain execution graph constructed
- All 50 file references loaded:
  - `01-Basic-Vulnerability-Chaining.md`
  - `02-Information-Disclosure-to-RCE.md`
  - `03-XSS-to-Account-Takeover.md`
  - `04-IDOR-to-Mass-Data-Extraction.md`
  - `05-SQL-Injection-to-Shell-Access.md`
  - `06-SSRF-to-Internal-Network-Compromise.md`
  - `07-CORS-Misconfiguration-Chains.md`
  - `08-CSRF-to-Privilege-Escalation.md`
  - `09-File-Upload-to-Web-Shell.md`
  - `10-XXE-to-Sensitive-Data-Access.md`
  - `11-Deserialization-to-RCE.md`
  - `12-JWT-Manipulation-Chains.md`
  - `13-SSTI-to-Complete-Compromise.md`
  - `15-NoSQL-Injection-to-Data-Breach.md`
  - `16-GraphQL-Abuse-Chains.md`
  - `17-WebSocket-Security-Chains.md`
  - `18-Prototype-Pollution-Exploitation.md`
  - `19-HTTP-Request-Smuggling-Chains.md`
  - `20-Host-Header-Injection-Chains.md`
  - `21-DNS-Rebinding-Attacks.md`
  - `22-Race-Condition-Exploitation.md`
  - `23-Subdomain-Takeover-Chains.md`
  - `24-Open-Redirect-to-Phishing.md`
  - `25-Content-Spoofing-Chains.md`
  - `26-WebCache-Poisoning-Chains.md`
  - `27-Clickjacking-to-Account-Compromise.md`
  - `28-Parameter-Pollution-Attacks.md`
  - `29-LDAP-Injection-Chains.md`
  - `30-XPath-Injection-Exploitation.md`
  - `31-Session-Puzzling-Techniques.md`
  - `32-Insecure-File-Handling-Chains.md`
  - `33-Cross-Site-Script-Inclusion.md`
  - `34-HTTP-Response-Splitting.md`
  - `35-Client-Side-Storage-Abuse.md`
  - `36-Cryptography-Weakness-Chains.md`
  - `37-Third-Party-Component-Chains.md`
  - `38-Configuration-Misconfiguration-Chains.md`
  - `39-Network-Infrastructure-Chains.md`
  - `40-Mobile-API-Chains.md`
  - `41-Cloud-Misconfiguration-Chains.md`
  - `42-Container-Escape-Chains.md`
  - `43-Kubernetes-Attack-Chains.md`
  - `44-Blockchain-Exploit-Chains.md`
  - `45-IoT-Device-Compromise-Chains.md`
  - `46-Supply-Chain-Attack-Chains.md`
  - `47-Zero-Day-Chaining-Strategies.md`
  - `48-Multi-Platform-Attack-Chains.md`
  - `49-Advanced-Persistent-Threat-Chains.md`
  - `50-Master-Chaining-Framework.md`
  - `README.md`

**Exit:** CREATED -> INITIALIZING

### INITIALIZING

Loading chain configuration, validating dependency graph acyclicity, initializing state manager.

**Sub-steps:**
1. Load `Advanced-Chaining-Techniques/registry.json`
2. Validate chain dependency graph (must be DAG)
3. Initialize state manager for chain variables
4. Allocate chain step execution contexts
5. Load chain templates from prompt files
6. Establish inter-step communication channels

**Exit:** INITIALIZING -> STARTING | INITIALIZING -> FAILED

### STARTING

Launching chain execution workers and state management processes.

**Sub-states:**
- `STARTING_STATE_MANAGER` — initializing variable store, checkpoint system
- `STARTING_CHAIN_WORKERS` — spawning step executor processes
- `STARTING_AGGREGATORS` — spawning result collection processes

**Exit:** STARTING -> RUNNING | STARTING -> FAILED

### RUNNING

Chain execution active. State manager tracking variables across chain steps. Workers executing individual chain steps.

**Chain execution model:**
- Steps execute in dependency order (topological sort of DAG)
- Each step reads state from state manager, executes, writes results back
- State manager persists state at each step boundary (checkpoint)
- Failed steps trigger rollback to last successful checkpoint

**Exit:** RUNNING -> STOPPING | RUNNING -> PAUSED | RUNNING -> ROLLING_BACK | RUNNING -> FAILED

### PAUSED

Chain execution suspended. Current step allowed to complete; no new steps started.

**Exit:** PAUSED -> RUNNING | PAUSED -> STOPPING

### ROLLING_BACK

A chain step failed or produced unexpected results. The state manager is reverting to the last successful checkpoint.

**Rollback procedure:**
1. Identify last successful checkpoint
2. Revert state variables to checkpoint values
3. Release resources allocated by failed step
4. Notify dependent steps of rollback
5. Decide: retry failed step or abort chain

**Exit:** ROLLING_BACK -> RUNNING (retry) | ROLLING_BACK -> STOPPING (abort)

### COMPLETED

All chain steps executed successfully. Final state aggregated and available.

**Exit:** COMPLETED -> STOPPED

### STOPPING

Graceful shutdown. Chain runner waiting for current step, releasing state manager, persisting final state.

**Exit:** STOPPING -> STOPPED

### STOPPED

Terminal state. All chain processes terminated, state persisted.

### FAILED

Chain execution failed irrecoverably. Error context preserved for analysis.

## Start Operations

### Chain Start Sequence

```
1. Receive start command with chain specification
2. Transition: CREATED -> INITIALIZING
3. Load chain graph from one of:
   - 01-Basic-Vulnerability-Chaining.md (simple linear chain)
   - 50-Master-Chaining-Framework.md (complex DAG chain)
   - 49-Advanced-Persistent-Threat-Chains.md (APT-style chain)
4. Validate graph acyclicity and dependency order
5. Transition: INITIALIZING -> STARTING
6. Spawn state manager process
7. Spawn chain step workers per step type:
   - Vulnerability assessors
   - Exploit developers
   - Result validators
   - State checkpoint writers
8. Transition: STARTING -> RUNNING
9. Begin executing chain steps in topological order
```

### Step Worker Start

Each chain step worker:
1. Load its chain step definition from the relevant prompt file
2. Connect to state manager
3. Register dependency constraints
4. Signal ready when all prerequisites met
5. Begin execution when state manager dispatches

## Stop Operations

### Graceful Stop

```
1. Pipeline runner receives stop signal
2. Transition: RUNNING -> STOPPING
3. Stop accepting new chain steps
4. Wait for current step to complete
5. Persist current chain state to checkpoint
6. Release state manager resources
7. Terminate step workers
8. Write chain execution summary
9. Transition: STOPPING -> STOPPED
```

### Rollback and Stop

```
1. Step failure detected
2. Transition: RUNNING -> ROLLING_BACK
3. State manager reverts to last checkpoint
4. If retry limit exceeded:
   a. Transition: ROLLING_BACK -> STOPPING
   b. Log failure details
   c. Clean up resources
5. If retry permitted:
   a. Transition: ROLLING_BACK -> RUNNING
   b. Retry failed step
```

## Graceful Shutdown Protocol

### Phase 1: Chain State Snapshot (0-5s)
- Current chain state serialized
- Partial results captured
- Step progress recorded

### Phase 2: Step Drain (5-30s)
- Current step allowed to finish
- No new steps dispatched
- Workers drain their task queues

### Phase 3: State Persistence (30-45s)
- Final checkpoint written
- State variables persisted
- Chain execution log flushed

### Phase 4: Resource Release (45-60s)
- Step workers terminated
- State manager process exited
- Communication channels closed
- Temp files cleaned

## Signal Handling

| Signal | Handler | Action |
|--------|---------|--------|
| `SIGTERM` | `handle_graceful_shutdown()` | Drain chain, persist state, shutdown |
| `SIGINT` | `handle_graceful_shutdown()` | Same as SIGTERM |
| `SIGHUP` | `handle_chain_reload()` | Reload chain graph, re-plan execution |
| `SIGUSR1` | `handle_state_dump()` | Dump current chain state to file |
| `SIGUSR2` | `handle_step_skip()` | Skip current step (debug/force) |
| `SIGKILL` | (OS default) | Immediate termination |

## Health Monitoring

### Chain-Specific Health Metrics

| Metric | Description | Alert |
|--------|-------------|-------|
| `chain_steps_completed` | Steps finished | N/A (info) |
| `chain_steps_remaining` | Steps pending | N/A (info) |
| `chain_step_duration_ms` | Current step time | > 60s |
| `chain_state_size_bytes` | State manager memory | > 100MB |
| `chain_rollback_count` | Rollbacks performed | > 3 |
| `chain_step_failure_rate` | Failed steps / total | > 20% |
| `chain_worker_count` | Active step workers | < expected |

### Health Check Response

```json
{
  "process_id": "chain-exec-001",
  "state": "RUNNING",
  "current_step": "06-SSRF-to-Internal-Network-Compromise",
  "steps_completed": 4,
  "steps_remaining": 8,
  "state_manager_memory_mb": 64,
  "last_checkpoint": "step-04-complete",
  "worker_health": "HEALTHY"
}
```

## Resource Limits

| Resource | Limit | Action |
|----------|-------|--------|
| State manager memory | 512 MB | Flush state to disk |
| Step worker memory | 256 MB per worker | Restart worker |
| Chain execution timeout | 3600s | Abort chain |
| Step execution timeout | 300s | Skip/rollback step |
| Checkpoint file size | 50 MB | Rotate checkpoints |
| Total chain disk usage | 1 GB | Archive old chains |

## Cleanup Procedures

### Normal Cleanup

```
1. Archive chain state to persistent storage
2. Remove checkpoint files older than 7 days
3. Clean step worker temp directories
4. Release state manager connections
5. Update chain execution log
```

### Rollback Cleanup

```
1. Remove partial step output files
2. Revert state variables
3. Release step-specific resources
4. Log rollback reason and extent
```

## Domain File References

### Core Chaining Framework

| File | Purpose | Process Role |
|------|---------|--------------|
| `01-Basic-Vulnerability-Chaining.md` | Foundation chain patterns | Chain Template |
| `50-Master-Chaining-Framework.md` | Master chaining orchestrator | Pipeline Runner |
| `47-Zero-Day-Chaining-Strategies.md` | Zero-day chain strategies | Chain Planner |
| `49-Advanced-Persistent-Threat-Chains.md` | APT chain patterns | Chain Planner |
| `48-Multi-Platform-Attack-Chains.md` | Cross-platform chains | Chain Planner |

### Web Application Chains

| File | Purpose | Process Role |
|------|---------|--------------|
| `02-Information-Disclosure-to-RCE.md` | Info disclosure -> RCE chain | Step Worker |
| `03-XSS-to-Account-Takeover.md` | XSS -> ATO chain | Step Worker |
| `04-IDOR-to-Mass-Data-Extraction.md` | IDOR -> data exfil chain | Step Worker |
| `05-SQL-Injection-to-Shell-Access.md` | SQLi -> shell chain | Step Worker |
| `06-SSRF-to-Internal-Network-Compromise.md` | SSRF -> internal network | Step Worker |
| `07-CORS-Misconfiguration-Chains.md` | CORS abuse chains | Step Worker |
| `08-CSRF-to-Privilege-Escalation.md` | CSRF -> privesc chain | Step Worker |
| `09-File-Upload-to-Web-Shell.md` | Upload -> webshell chain | Step Worker |
| `10-XXE-to-Sensitive-Data-Access.md` | XXE -> data access chain | Step Worker |
| `11-Deserialization-to-RCE.md` | Deser -> RCE chain | Step Worker |
| `12-JWT-Manipulation-Chains.md` | JWT abuse chains | Step Worker |
| `13-SSTI-to-Complete-Compromise.md` | SSTI -> full compromise | Step Worker |
| `15-NoSQL-Injection-to-Data-Breach.md` | NoSQLi -> data breach | Step Worker |
| `16-GraphQL-Abuse-Chains.md` | GraphQL abuse chains | Step Worker |
| `17-WebSocket-Security-Chains.md` | WebSocket attack chains | Step Worker |
| `18-Prototype-Pollution-Exploitation.md` | Prototype pollution chains | Step Worker |

### Advanced Attack Chains

| File | Purpose | Process Role |
|------|---------|--------------|
| `19-HTTP-Request-Smuggling-Chains.md` | HTTP smuggling chains | Step Worker |
| `20-Host-Header-Injection-Chains.md` | Host header injection | Step Worker |
| `21-DNS-Rebinding-Attacks.md` | DNS rebinding chains | Step Worker |
| `22-Race-Condition-Exploitation.md` | Race condition chains | Step Worker |
| `23-Subdomain-Takeover-Chains.md` | Subdomain takeover chains | Step Worker |
| `24-Open-Redirect-to-Phishing.md` | Open redirect chains | Step Worker |
| `25-Content-Spoofing-Chains.md` | Content spoofing chains | Step Worker |
| `26-WebCache-Poisoning-Chains.md` | Cache poisoning chains | Step Worker |
| `27-Clickjacking-to-Account-Compromise.md` | Clickjacking chains | Step Worker |
| `28-Parameter-Pollution-Attacks.md` | Parameter pollution | Step Worker |
| `29-LDAP-Injection-Chains.md` | LDAP injection chains | Step Worker |
| `30-XPath-Injection-Exploitation.md` | XPath injection chains | Step Worker |
| `31-Session-Puzzling-Techniques.md` | Session puzzling chains | Step Worker |
| `32-Insecure-File-Handling-Chains.md` | File handling chains | Step Worker |
| `33-Cross-Site-Script-Inclusion.md` | XSSI chains | Step Worker |
| `34-HTTP-Response-Splitting.md` | Response splitting chains | Step Worker |
| `35-Client-Side-Storage-Abuse.md` | Client storage chains | Step Worker |
| `36-Cryptography-Weakness-Chains.md` | Crypto weakness chains | Step Worker |
| `37-Third-Party-Component-Chains.md` | 3rd party component chains | Step Worker |
| `38-Configuration-Misconfiguration-Chains.md` | Config misconfig chains | Step Worker |

### Infrastructure and Platform Chains

| File | Purpose | Process Role |
|------|---------|--------------|
| `39-Network-Infrastructure-Chains.md` | Network infrastructure chains | Step Worker |
| `40-Mobile-API-Chains.md` | Mobile API attack chains | Step Worker |
| `41-Cloud-Misconfiguration-Chains.md` | Cloud misconfig chains | Step Worker |
| `42-Container-Escape-Chains.md` | Container escape chains | Step Worker |
| `43-Kubernetes-Attack-Chains.md` | Kubernetes attack chains | Step Worker |
| `44-Blockchain-Exploit-Chains.md` | Blockchain exploit chains | Step Worker |
| `45-IoT-Device-Compromise-Chains.md` | IoT compromise chains | Step Worker |
| `46-Supply-Chain-Attack-Chains.md` | Supply chain attack chains | Step Worker |

### Supporting Files

| File | Purpose |
|------|---------|
| `README.md` | Domain documentation |
| `registry.json` | Domain registry and metadata |

## Process Relationships

```
Orchestrator (parent)
  |
  +-- Chain Runner (Advanced-Chaining-Techniques)
        |
        +-- State Manager
        |     |
        |     +-- Checkpoint Writer
        |     +-- Variable Store
        |     +-- Rollback Controller
        |
        +-- Step Workers (one per chain step)
        |     |
        |     +-- Vulnerability Assessor
        |     +-- Exploit Developer
        |     +-- Result Validator
        |
        +-- Result Aggregator
        |
        +-- Chain Monitor
```

## Configuration Reference

| Config Key | Default | Description |
|-----------|---------|-------------|
| `chain.max_concurrent_steps` | 4 | Max parallel steps |
| `chain.step_timeout` | 300 | Seconds per step |
| `chain.total_timeout` | 3600 | Total chain timeout |
| `chain.max_retries` | 3 | Retries per failed step |
| `chain.checkpoint_interval` | 1 | Checkpoints per step |
| `chain.state_memory_limit_mb` | 512 | State manager memory |
| `chain.rollback_enabled` | true | Allow rollback on failure |
| `chain.partial_results` | true | Keep partial on failure |
