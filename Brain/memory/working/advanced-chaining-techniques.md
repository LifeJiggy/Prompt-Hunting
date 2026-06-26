# Working Memory: Advanced Chaining Techniques Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `ADV-CHAIN-001` |
| Root Folder | `Advanced-Chaining-Techniques/` |
| Total Files | 49 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory graph + event log |
| Typical Lifetime | Single exploitation chain attempt |
| Eviction Trigger | Chain completion, failure, or 8h TTL |

---

## Overview

Working memory for vulnerability chaining captures the real-time state of multi-step
exploitation chains. When an attacker chains an IDOR into an auth bypass into account
takeover, each intermediate state — discovered primitives, partial access, dependency
graph nodes — must be tracked in working memory.

This domain covers 49 modules spanning the full spectrum of chaining techniques:
basic two-vuln chains through complex multi-step exploitation frameworks. Working
memory must support:

- **Chain graph representation**: DAG (Directed Acyclic Graph) of exploitation
  steps, where each node is a vulnerability primitive and edges represent
  dependencies.
- **Primitive registry**: Catalog of discovered exploitation primitives (XSS,
  SSRF, IDOR, open redirect, etc.) with their current known parameters.
- **Intermediate state tracking**: For each chain attempt, track what access has
  been achieved so far, what credentials have been harvested, and what the next
  step requires.
- **Branching exploration**: When multiple chain paths are possible, working memory
  must support parallel exploration without cross-contamination.
- **Rollback support**: If a chain step fails, roll back to the last known-good
  state and try alternative paths.
- **Evidence collection**: Each chain step generates evidence (requests, responses,
  screenshots) that must be preserved for the final report.
- **Cost accounting**: Track time and resources spent on each chain attempt to
  support prioritization decisions.

The key insight is that chaining is fundamentally a graph traversal problem.
Working memory is the visited-set, the frontier, and the current-path tracker
for this traversal.

---

## Data Schema (YAML)

```yaml
working_memory_chaining:
  version: "1.8"
  scope: "chain-attempt"
  ttl_seconds: 28800

  chain_session:
    session_id: "string (uuid4)"
    target: "string (domain or IP)"
    started_at: "ISO8601"
    status: "enum(exploring|chain_found|exhausted|abandoned)"
    max_depth: "integer (default 5)"
    max_branches: "integer (default 10)"

  primitive_registry:
    primitive_id: "string (uuid4)"
    vuln_class: "enum(xss|ssrf|idor|ssti|lfi|rfi|open_redirect|csrf|auth_bypass|race_condition|file_upload|sql_injection|xxe|template_injection|command_injection)"
    endpoint: "string (URL path)"
    method: "string (HTTP method)"
    parameters: "list[string]"
    evidence_id: "string (uuid4)"
    confidence: "float (0.0-1.0)"
    required_auth: "boolean"
    discovered_at: "ISO8601"

  chain_graph:
    chain_id: "string (uuid4)"
    nodes:
      node_id: "string (uuid4)"
      primitive_id: "string (references primitive_registry)"
      step_number: "integer"
      status: "enum(pending|attempting|succeeded|failed|skipped)"
      input_state: "map (access level, creds, tokens)"
      output_state: "map (new access, new creds)"
      started_at: "ISO8601"
      completed_at: "ISO8601"
      evidence: "list[string] (evidence IDs)"
    edges:
      from_node: "string (node_id)"
      to_node: "string (node_id)"
      dependency_type: "enum(output_of|requires_credential|requires_access_level)"

  exploitation_state:
    current_access:
      level: "enum(unauthenticated|low_priv|authenticated|elevated|admin)"
      session_tokens: "list[string]"
      cookies: "map[string,string]"
      api_keys: "list[string]"
      user_id: "string"
      role: "string"
    harvested_credentials:
      credential_id: "string (uuid4)"
      type: "enum(password|token|cookie|api_key|jwt|session|ssh_key)"
      value: "string (encrypted at rest)"
      source_primitive: "string (primitive_id)"
      captured_at: "ISO8601"
    access_log:
      endpoint: "string"
      method: "string"
      status_code: "integer"
      timestamp: "ISO8601"

  branch_tracker:
    branch_id: "string (uuid4)"
    parent_chain_id: "string (chain_id)"
    branch_point: "string (node_id)"
    alternative_step: "string (primitive_id)"
    probability_of_success: "float (0.0-1.0)"
    estimated_time_seconds: "integer"

  evidence_store:
    evidence_id: "string (uuid4)"
    chain_id: "string (chain_id)"
    node_id: "string (node_id)"
    evidence_type: "enum(request|response|screenshot|header_dump|token_capture)"
    data: "binary or text"
    captured_at: "ISO8601"
```

---

## Read/Write Operations

```python
import uuid
import hashlib
import time
from datetime import datetime, timezone, timedelta
from typing import Optional
from enum import Enum


class ChainStatus(Enum):
    EXPLORING = "exploring"
    CHAIN_FOUND = "chain_found"
    EXHAUSTED = "exhausted"
    ABANDONED = "abandoned"


class NodeStatus(Enum):
    PENDING = "pending"
    ATTEMPTING = "attempting"
    SUCCEEDED = "succeeded"
    FAILED = "failed"
    SKIPPED = "skipped"


class AccessLevel(Enum):
    UNAUTHENTICATED = "unauthenticated"
    LOW_PRIV = "low_priv"
    AUTHENTICATED = "authenticated"
    ELEVATED = "elevated"
    ADMIN = "admin"


class ChainingWorkingMemory:
    """
    In-memory working state for vulnerability chaining.
    Covers all 49 modules from Basic Chaining through Master Framework.
    """

    def __init__(self, session_id: Optional[str] = None, ttl_seconds: int = 28800):
        self.session_id = session_id or str(uuid.uuid4())
        self.ttl_seconds = ttl_seconds
        self.created_at = datetime.now(timezone.utc)

        self.primitive_registry: dict[str, dict] = {}
        self.chain_graphs: dict[str, dict] = {}
        self.exploitation_state: dict = {
            "current_access": {
                "level": AccessLevel.UNAUTHENTICATED.value,
                "session_tokens": [],
                "cookies": {},
                "api_keys": [],
                "user_id": "",
                "role": "",
            },
            "harvested_credentials": [],
            "access_log": [],
        }
        self.branch_tracker: dict[str, dict] = {}
        self.evidence_store: dict[str, dict] = {}
        self.cost_accounting: dict[str, dict] = {}

    def register_primitive(self, vuln_class: str, endpoint: str, method: str,
                           parameters: list[str], required_auth: bool = False,
                           confidence: float = 0.5) -> str:
        """Register a discovered vulnerability primitive."""
        primitive_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.primitive_registry[primitive_id] = {
            "primitive_id": primitive_id,
            "vuln_class": vuln_class,
            "endpoint": endpoint,
            "method": method,
            "parameters": parameters,
            "evidence_id": None,
            "confidence": confidence,
            "required_auth": required_auth,
            "discovered_at": now,
        }

        return primitive_id

    def create_chain(self, target: str, max_depth: int = 5,
                     max_branches: int = 10) -> str:
        """Create a new chain exploration session."""
        chain_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.chain_graphs[chain_id] = {
            "chain_id": chain_id,
            "target": target,
            "started_at": now,
            "status": ChainStatus.EXPLORING.value,
            "max_depth": max_depth,
            "max_branches": max_branches,
            "nodes": {},
            "edges": [],
        }

        self.cost_accounting[chain_id] = {
            "total_time_seconds": 0,
            "steps_attempted": 0,
            "steps_succeeded": 0,
            "branches_explored": 0,
        }

        return chain_id

    def add_chain_node(self, chain_id: str, primitive_id: str,
                       step_number: int, input_state: Optional[dict] = None) -> str:
        """Add a node to the chain graph."""
        node_id = str(uuid.uuid4())
        chain = self.chain_graphs[chain_id]

        chain["nodes"][node_id] = {
            "node_id": node_id,
            "primitive_id": primitive_id,
            "step_number": step_number,
            "status": NodeStatus.PENDING.value,
            "input_state": input_state or self._snapshot_access(),
            "output_state": {},
            "started_at": None,
            "completed_at": None,
            "evidence": [],
        }

        if step_number > 1:
            prev_nodes = [
                nid for nid, n in chain["nodes"].items()
                if n["step_number"] == step_number - 1
            ]
            for prev_id in prev_nodes:
                chain["edges"].append({
                    "from_node": prev_id,
                    "to_node": node_id,
                    "dependency_type": "output_of",
                })

        return node_id

    def attempt_node(self, chain_id: str, node_id: str) -> None:
        """Mark a chain node as being attempted."""
        self.chain_graphs[chain_id]["nodes"][node_id]["status"] = NodeStatus.ATTEMPTING.value
        self.chain_graphs[chain_id]["nodes"][node_id]["started_at"] = (
            datetime.now(timezone.utc).isoformat()
        )
        self.cost_accounting[chain_id]["steps_attempted"] += 1

    def succeed_node(self, chain_id: str, node_id: str,
                     output_state: Optional[dict] = None,
                     evidence_ids: Optional[list[str]] = None) -> None:
        """Mark a chain node as succeeded and update access state."""
        now = datetime.now(timezone.utc).isoformat()
        node = self.chain_graphs[chain_id]["nodes"][node_id]
        node["status"] = NodeStatus.SUCCEEDED.value
        node["completed_at"] = now
        node["output_state"] = output_state or {}
        node["evidence"] = evidence_ids or []

        if output_state:
            self._merge_access(output_state)

        self.cost_accounting[chain_id]["steps_succeeded"] += 1

    def fail_node(self, chain_id: str, node_id: str) -> None:
        """Mark a chain node as failed."""
        now = datetime.now(timezone.utc).isoformat()
        node = self.chain_graphs[chain_id]["nodes"][node_id]
        node["status"] = NodeStatus.FAILED.value
        node["completed_at"] = now

    def create_branch(self, chain_id: str, branch_point_node_id: str,
                      alternative_primitive_id: str,
                      probability: float = 0.5,
                      estimated_time: int = 300) -> str:
        """Create a branching exploration from a failed node."""
        branch_id = str(uuid.uuid4())
        chain = self.chain_graphs[chain_id]

        if len(self.branch_tracker) >= chain["max_branches"]:
            raise ValueError(f"Max branches ({chain['max_branches']}) reached")

        self.branch_tracker[branch_id] = {
            "branch_id": branch_id,
            "parent_chain_id": chain_id,
            "branch_point": branch_point_node_id,
            "alternative_step": alternative_primitive_id,
            "probability_of_success": probability,
            "estimated_time_seconds": estimated_time,
        }

        self.cost_accounting[chain_id]["branches_explored"] += 1
        return branch_id

    def rollback_to_node(self, chain_id: str, target_node_id: str) -> dict:
        """Roll back exploitation state to a previous node's input state."""
        node = self.chain_graphs[chain_id]["nodes"][target_node_id]
        rollback_state = node["input_state"].copy()
        self.exploitation_state["current_access"] = rollback_state.get("current_access", {})
        return rollback_state

    def store_evidence(self, chain_id: str, node_id: str, evidence_type: str,
                       data: str) -> str:
        """Store evidence for a chain step."""
        evidence_id = str(uuid.uuid4())
        self.evidence_store[evidence_id] = {
            "evidence_id": evidence_id,
            "chain_id": chain_id,
            "node_id": node_id,
            "evidence_type": evidence_type,
            "data": data[:1_048_576],
            "captured_at": datetime.now(timezone.utc).isoformat(),
        }
        self.chain_graphs[chain_id]["nodes"][node_id]["evidence"].append(evidence_id)
        return evidence_id

    def record_credential(self, cred_type: str, value: str,
                          source_primitive: str) -> str:
        """Record a harvested credential."""
        cred_id = str(uuid.uuid4())
        self.exploitation_state["harvested_credentials"].append({
            "credential_id": cred_id,
            "type": cred_type,
            "value": value,
            "source_primitive": source_primitive,
            "captured_at": datetime.now(timezone.utc).isoformat(),
        })
        return cred_id

    def log_access(self, endpoint: str, method: str, status_code: int) -> None:
        """Log an access attempt for cost accounting."""
        self.exploitation_state["access_log"].append({
            "endpoint": endpoint,
            "method": method,
            "status_code": status_code,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        })

    def get_chain_summary(self, chain_id: str) -> dict:
        """Get summary of current chain state."""
        chain = self.chain_graphs[chain_id]
        nodes = chain["nodes"]

        return {
            "chain_id": chain_id,
            "target": chain["target"],
            "status": chain["status"],
            "total_nodes": len(nodes),
            "succeeded": sum(1 for n in nodes.values() if n["status"] == NodeStatus.SUCCEEDED.value),
            "failed": sum(1 for n in nodes.values() if n["status"] == NodeStatus.FAILED.value),
            "current_access_level": self.exploitation_state["current_access"]["level"],
            "credentials_harvested": len(self.exploitation_state["harvested_credentials"]),
            "evidence_count": len(self.evidence_store),
            "cost": self.cost_accounting.get(chain_id, {}),
        }

    def find_completable_chains(self) -> list[dict]:
        """Find chains where all terminal nodes succeeded (complete chains)."""
        completable = []
        for chain_id, chain in self.chain_graphs.items():
            terminal_nodes = [
                n for n in chain["nodes"].values()
                if not any(e["from_node"] == n["node_id"] for e in chain["edges"])
            ]
            if terminal_nodes and all(n["status"] == NodeStatus.SUCCEEDED.value for n in terminal_nodes):
                chain["status"] = ChainStatus.CHAIN_FOUND.value
                completable.append(self.get_chain_summary(chain_id))
        return completable

    def get_viable_primitives(self, required_access: str = "unauthenticated") -> list[dict]:
        """Get primitives that can be used at the current access level."""
        level_order = [l.value for l in AccessLevel]
        current_idx = level_order.index(self.exploitation_state["current_access"]["level"])
        required_idx = level_order.index(required_access)

        if current_idx < required_idx:
            return []

        return [
            p for p in self.primitive_registry.values()
            if not p["required_auth"] or current_idx > 0
        ]

    def cleanup_expired(self) -> int:
        """Remove expired chain sessions."""
        now = datetime.now(timezone.utc)
        expired = []
        for chain_id, chain in self.chain_graphs.items():
            started = datetime.fromisoformat(chain["started_at"])
            if (now - started).total_seconds() > self.ttl_seconds:
                expired.append(chain_id)

        for cid in expired:
            del self.chain_graphs[cid]
            self.cost_accounting.pop(cid, None)
            self.branch_tracker = {
                k: v for k, v in self.branch_tracker.items()
                if v["parent_chain_id"] != cid
            }

        return len(expired)

    def _snapshot_access(self) -> dict:
        return {"current_access": self.exploitation_state["current_access"].copy()}

    def _merge_access(self, output_state: dict) -> None:
        access = self.exploitation_state["current_access"]
        for key in ["session_tokens", "api_keys"]:
            if key in output_state:
                access[key].extend(output_state[key])
        if "cookies" in output_state:
            access["cookies"].update(output_state["cookies"])
        if "level" in output_state:
            level_order = [l.value for l in AccessLevel]
            new_idx = level_order.index(output_state["level"])
            curr_idx = level_order.index(access["level"])
            if new_idx > curr_idx:
                access["level"] = output_state["level"]
        if "user_id" in output_state:
            access["user_id"] = output_state["user_id"]
        if "role" in output_state:
            access["role"] = output_state["role"]
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Active chain sessions | 8 | LRU eviction when full | Parallel chain exploration |
| Primitives per session | 200 | FIFO eviction | Prevents registry bloat |
| Chain depth per chain | 5 | Hard limit | Prevents infinite loops |
| Branches per chain | 10 | Hard limit | Resource containment |
| Evidence items per chain | 500 | LRU eviction | Memory management |
| Credentials per session | 100 | FIFO eviction | Security — minimize exposure |
| Access log entries | 10,000 | FIFO eviction | Audit trail |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Chain sessions expire after 8h by default.
  - All associated nodes, edges, and evidence are removed.

Priority 2: Max Branch Limit
  - When branches exceed limit, lowest-probability branches are abandoned.
  - Their nodes are marked as skipped.

Priority 3: Evidence Size Cap
  - Individual evidence items capped at 1 MB.
  - Excess data truncated with warning.

Priority 4: Credential Rotation
  - Harvested credentials older than TTL are zeroed (not deleted).
  - Prevents stale credential use while preserving audit trail.
```

---

## Lifecycle

```
1. DISCOVERY PHASE
   register_primitive() × N → primitive registry populated

2. CHAIN CONSTRUCTION
   create_chain() → add_chain_node() × depth → chain graph built

3. CHAIN EXECUTION
   attempt_node() → execute exploit → succeed_node() or fail_node()
   On success: update access state, check for completable chains
   On failure: create_branch() or rollback_to_node()

4. BRANCH EXPLORATION
   create_branch() → new chain node → attempt_node() → ...

5. COMPLETION
   find_completable_chains() → chain found → evidence assembled
   Or: all branches exhausted → chain_status = exhausted

6. CLEANUP
   cleanup_expired() removes expired sessions
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Read | Tool outputs feeding primitive discovery |
| Recon Deep Dive | Read | Target information for chain construction |
| Report Writing | Write | Complete chains with evidence for report |
| Real-World Case Studies | Read | Known chain patterns from disclosed reports |

---

## Domain File References (Advanced-Chaining-Techniques/)

### 01-Basic-Vulnerability-Chaining
Foundation of chaining two vulnerabilities into a higher-impact chain.
Working memory stores: primitive pairs, dependency validation, chain feasibility.

### 02-SSRF-to-Internal-Network-Chaining
Chaining SSRF into internal network access and lateral movement.
Working memory stores: SSRF endpoints, internal host discoveries, pivot state.

### 03-XSS-to-Account-Takeover-Chaining
Chaining stored XSS into session hijacking and full account takeover.
Working memory stores: XSS injection points, cookie capture state, session tokens.

### 04-Open-Redirect-to-OAuth-Theft-Chaining
Chaining open redirects into OAuth authorization code theft.
Working memory stores: redirect chains, OAuth endpoints, captured auth codes.

### 05-IDOR-to-Privilege-Escalation-Chaining
Chaining IDOR into vertical privilege escalation.
Working memory stores: IDOR endpoints, ID sequences, privilege boundaries.

### 06-File-Upload-to-RCE-Chaining
Chaining unrestricted file upload into remote code execution.
Working memory stores: upload endpoints, webshell paths, execution state.

### 07-SQL-Injection-to-Authentication-Bypass-Chaining
Chaining SQL injection into authentication bypass.
Working memory stores: injectable parameters, database type, bypass queries.

### 08-CSRF-to-Account-Takeover-Chaining
Chaining CSRF into email/password change and account takeover.
Working memory stores: CSRF tokens, action endpoints, state-changing requests.

### 09-Race-Condition-to-Double-Spend-Chaining
Chaining race conditions into financial exploitation.
Working memory stores: timing windows, concurrent request counts, balance changes.

### 10-LFI-to-RCE-Chaining
Chaining local file inclusion into remote code execution.
Working memory stores: LFI paths, log file locations, injection vectors.

### 11-XXE-to-SSRF-Chaining
Chaining XXE into server-side request forgery.
Working memory stores: XXE endpoints, internal URL discovery, response channels.

### 12-SSTI-to-RCE-Chaining
Chaining server-side template injection into code execution.
Working memory stores: template engines, sandbox escape paths, payload state.

### 13-GraphQL-to-IDOR-Chaining
Chaining GraphQL introspection into IDOR exploitation.
Working memory stores: schema, mutation arguments, authorization gaps.

### 14-CORS-to-XSS-Chaining
Chaining CORS misconfiguration into cross-site scripting.
Working memory stores: origin reflections, credentialed requests, script execution.

### 15-Cache-Poisoning-to-XSS-Chaining
Chaining cache poisoning into stored XSS via CDN caches.
Working memory stores: poisonable headers, cache keys, victim request patterns.

### 16-Subdomain-Takeover-to-Session-Hijacking
Chaining subdomain takeover into session token theft.
Working memory stores: dangling CNAMEs, cookie scopes, takeover services.

### 17-Password-Reset-to-ATO-Chaining
Chaining password reset flaws into account takeover.
Working memory stores: reset tokens, host header injection points, email patterns.

### 18-MFA-Bypass-to-Full-Access-Chaining
Chaining MFA bypass techniques into full account access.
Working memory stores: MFA factors, bypass vectors, recovery codes.

### 19-API-Key-Leak-to-Lateral-Movement
Chaining API key discovery into lateral movement across services.
Working memory stores: leaked keys, service mappings, permission boundaries.

### 20-WebSocket-to-XSS-Chaining
Chaining WebSocket message injection into XSS.
Working memory stores: WS endpoints, message handlers, sanitization gaps.

### 21-HTTP-Smuggling-to-Request-Smuggling
Chaining HTTP parser differences into request smuggling.
Working memory stores: parser discrepancies, smuggling payloads, victim routing.

### 22-DNS-Rebinding-to-Internal-Access
Chaining DNS rebinding into internal service access.
Working memory stores: rebinding domains, TTL strategies, internal endpoints.

### 23-JWT-Weakness-to-Privilege-Escalationation
Chaining JWT vulnerabilities into privilege escalation.
Working memory stores: JWT algorithms, key material, claim manipulation state.

### 24-SAML-Bypass-to-Identity-Spoofing
Chaining SAML vulnerabilities into identity spoofing.
Working memory stores: assertion templates, signature bypass methods, nameID values.

### 25-OAuth-State-Bypass-to-Token-Theft
Chaining OAuth state parameter bypass into token theft.
Working memory stores: state values, redirect_uri patterns, token endpoints.

### 26-Cookie-Tossing-to-Session-Hijacking
Chaining cookie tossing on subdomains into session hijacking.
Working memory stores: domain scope, cookie attributes, tossable subdomains.

### 27-Prototype-Pollution-to-XSS
Chaining JavaScript prototype pollution into XSS.
Working memory stores: merge sinks, gadget chains, DOM execution paths.

### 28-HTTP-Host-Header-Injection
Chaining host header injection into cache poisoning or password reset abuse.
Working memory stores: injectable headers, backend parsing, downstream effects.

### 29-Content-Security-Policy-Bypass-Chaining
Chaining CSP bypass techniques into script execution.
Working memory stores: CSP directives, bypass techniques, script sources.

### 30-WAF-Bypass-Chaining
Chaining multiple WAF bypass techniques into payload delivery.
Working memory stores: WAF signatures, encoding chains, payload transformations.

### 31-Mass-Assignment-to-Privilege-Escalation
Chaining mass assignment into privilege escalation.
Working memory stores: overwritable fields, role parameters, admin endpoints.

### 32-Server-Side-Gadget-Chaining
Chaining deserialization gadgets into code execution.
Working memory stores: gadget chains, serialization formats, class paths.

### 33-Blind-SQL-Injection-to-Data-Extraction
Chaining blind SQL injection into full data extraction.
Working memory stores: injection points, extraction channels, boolean/time patterns.

### 34-XPath-Injection-to-Authentication-Bypass
Chaining XPath injection into authentication bypass.
Working memory stores: XML inputs, query construction, authentication logic.

### 35-LDAP-Injection-to-Access-Control-Bypass
Chaining LDAP injection into access control bypass.
Working memory stores: LDAP queries, filter construction, bind operations.

### 36-NoSQL-Injection-to-Data-Extraction
Chaining NoSQL injection into data extraction.
Working memory stores: MongoDB queries, operator injection, document paths.

### 37-Template-Injection-to-File-Read
Chaining template injection into arbitrary file read.
Working memory stores: template engines, file read gadgets, path traversal.

### 38-Log-Injection-to-XSS
Chaining log injection into stored XSS via log viewers.
Working memory stores: injectable log fields, log viewer endpoints, sanitization gaps.

### 39-HTTP-Parameter-Pollution
Chaining parameter pollution into security bypass.
Working memory stores: parameter handling quirks, backend parsing, duplicate params.

### 40-JSONP-to-CORS-Bypass
Chaining JSONP endpoints into CORS policy bypass.
Working memory stores: JSONP endpoints, callback functions, origin restrictions.

###  41-Cookie-Injection-to-Session-Fixation
Chaining cookie injection into session fixation attacks.
Working memory stores: injectable cookies, session creation logic, fixation vectors.

### 42-Host-Header-to-Password-Reset-Poisoning
Chaining host header manipulation into password reset poisoning.
Working memory stores: host header handling, reset URL construction, email templates.

### 43-Redirect-Chains-to-Auth-Bypass
Chaining redirect chains into authentication boundary bypass.
Working memory stores: redirect sequences, auth checkpoints, final destinations.

### 44-Information-Disclosure-to-Exploit-Development
Chaining info disclosure into targeted exploit development.
Working memory stores: leaked paths, version info, config structures.

### 45-Cross-Tenant-Data-Access-Chaining
Chaining tenant isolation flaws into cross-tenant data access.
Working memory stores: tenant identifiers, isolation boundaries, data paths.

### 46-WebSocket-Cross-Site-Hijacking
Chaining WebSocket vulnerabilities into cross-site hijacking.
Working memory stores: WS handshake, origin checks, message authentication.

### 47-Second-Order-Injection-Chaining
Chaining second-order injection flaws into exploitation.
Working memory stores: injection points, storage locations, trigger points.

### 48-Multi-Stage-APT-Chaining
Advanced persistent threat-style multi-stage chaining.
Working memory stores: stage progression, persistence mechanisms, C2 channels.

### 49-Master-Chaining-Framework
Meta-framework for combining all chaining techniques systematically.
Working memory stores: technique selection, chain optimization, success metrics.
