# Core-Prompts-hunting State Recovery

## Domain Mapping

- **Domain**: Core-Prompts-hunting
- **Directory**: `Core-Prompts-hunting/`
- **Total Files**: 50
- **Recovery Category**: Test Progress Recovery
- **Session Type**: Active vulnerability hunting sessions
- **Criticality**: HIGH — lost hunting progress means re-testing from scratch
- **Recovery Complexity**: HIGH — hunting state includes target-specific context
- **State Volume**: LARGE — includes test results, payloads, and findings

---

## Overview

Core-Prompts-hunting provides the core vulnerability hunting prompts and methodologies for each vulnerability class. State recovery must preserve testing progress, discovered vulnerabilities, test case results, payload libraries, and hunting session context.

Each vulnerability class has its own testing state that must be independently recoverable. The hunting session state includes target-specific context, authentication state, and accumulated intelligence that cannot be easily regenerated.

### Hunting State Architecture

Each hunting session maintains:

- **Target Context**: Target configuration, scope, and access information
- **Authentication State**: Login credentials, session tokens, and cookies
- **Testing Progress**: Per-vulnerability-class test completion status
- **Findings**: Discovered vulnerabilities with evidence and PoCs
- **Payload Libraries**: Custom payloads and testing scripts
- **Intelligence**: Accumulated target intelligence and notes

### Vulnerability Class Categories

| Category | Classes | Testing Complexity | State Dependency |
|----------|---------|-------------------|------------------|
| Injection | SQLi, XSS, SSRF, XXE, SSTI, Cmdi | HIGH | Target + Auth |
| Authentication | Auth Bypass, Session, JWT, OAuth | MEDIUM | Target + Auth |
| Authorization | IDOR, Privilege Escalation | MEDIUM | Target + Auth |
| Logic | Business Logic, Race Conditions | HIGH | Target + Auth |
| Infrastructure | Misconfig, Info Disclosure, Crypto | LOW-MEDIUM | Target |

---

## Recovery Scenarios

### Scenario 1: Hunting Session Crash During Active Testing

A hunting session crashes while testing for XSS on a target. The session had completed reconnaissance, authentication setup, and was 60% through XSS testing. Test cases completed, payloads tested, and partial results need recovery.

**Recovery Requirements:**
- Recover target context and authentication state
- Restore XSS testing progress (60% complete)
- Preserve discovered XSS reflection points
- Maintain payload library and custom scripts
- Restore testing session cookies and tokens

**Recovery Procedure:**
1. Load hunting session state from checkpoint
2. Validate target context is still accessible
3. Verify authentication tokens are valid
4. Restore XSS testing progress
5. Re-establish browser session with restored cookies
6. Resume XSS testing from last checkpoint

**Estimated Recovery Time:** 3-7 minutes
**Data Loss Risk:** LOW (hunting state is checkpointed frequently)

### Scenario 2: Multi-Vulnerability Class Testing Recovery

Testing across multiple vulnerability classes simultaneously crashes. SQLi testing completed, XSS 50% done, SSRF just started. Cross-class correlations and shared context need recovery.

**Recovery Requirements:**
- Recover per-class testing progress independently
- Preserve cross-class correlations
- Restore shared target context
- Maintain findings from completed classes
- Resume incomplete classes from checkpoints

**Recovery Procedure:**
1. Load per-class testing states from checkpoints
2. Validate completed class findings
3. Restore cross-class correlations
4. Re-establish shared target context
5. Resume incomplete classes from last checkpoint
6. Re-build cross-class intelligence

**Estimated Recovery Time:** 5-15 minutes
**Data Loss Risk:** LOW (per-class checkpoints are independent)

### Scenario 3: Target Context Loss

Target-specific context is lost during long hunting session. Target configuration, authentication state, scope definitions, and discovered endpoints need restoration.

**Recovery Requirements:**
- Recover target configuration and scope
- Restore authentication state and credentials
- Preserve discovered endpoints and parameters
- Maintain testing progress
- Restore target-specific intelligence

**Recovery Procedure:**
1. Load target context from checkpoint
2. Validate target accessibility
3. Restore authentication state
4. Re-establish session with target
5. Verify scope definitions are current
6. Resume testing with restored context

**Estimated Recovery Time:** 3-10 minutes
**Data Loss Risk:** MEDIUM (target context may have changed)

### Scenario 4: Payload Library Corruption

Custom payload library becomes corrupted. Custom payloads, effectiveness records, and payload configurations need restoration.

**Recovery Requirements:**
- Recover custom payload library
- Restore payload effectiveness records
- Re-establish payload configurations
- Preserve payload testing history
- Restore payload generation scripts

**Recovery Procedure:**
1. Load payload library from checkpoint
2. Validate payload integrity
3. Restore effectiveness records
4. Re-establish payload configurations
5. Verify payload functionality
6. Resume testing with restored payloads

**Estimated Recovery Time:** 3-7 minutes
**Data Loss Risk:** LOW (payload library is checkpointed)

### Scenario 5: Cross-Session Hunting Continuity

Hunting session needs to continue across multiple days. Daily progress, accumulated findings, and strategic context need preservation and restoration.

**Recovery Requirements:**
- Recover daily progress and findings
- Preserve accumulated intelligence
- Restore strategic context and priorities
- Maintain session continuity across days
- Restore target-specific notes

**Recovery Procedure:**
1. Load session state from latest checkpoint
2. Validate accumulated findings
3. Restore strategic context
4. Re-establish target access
5. Verify findings currency
6. Resume hunting from strategic priorities

**Estimated Recovery Time:** 5-10 minutes
**Data Loss Risk:** LOW (daily checkpoints preserve all data)

---

## Recovery Strategies

### Full Hunting Recovery

Full recovery reconstructs complete hunting state from all 50 module checkpoints. This preserves all testing progress, discovered vulnerabilities, and hunting context.

**Full Recovery Procedure:**
1. Load all 50 hunting module checkpoints
2. Validate each module's testing progress
3. Restore all discovered vulnerabilities
4. Re-establish target context and authentication
5. Reload payload libraries
6. Restore cross-class correlations
7. Validate complete hunting state
8. Resume from last validated test point

**Recovery Time:** 10-20 minutes
**Success Rate:** >95% when checkpoints are intact

### Partial Hunting Recovery

Partial recovery restores completed vulnerability class tests only and re-runs incomplete tests.

**Partial Recovery Procedure:**
1. Identify completed vulnerability class tests
2. Validate completed test results
3. Preserve confirmed findings
4. Identify incomplete test classes
5. Re-run incomplete tests from last checkpoint
6. Validate combined test results

**Recovery Time:** 5-15 minutes
**Success Rate:** >90% for partial failures

### Selective Class Recovery

Selective recovery prioritizes specific vulnerability classes based on hunting priority.

**Class Priority Categories:**

**High Priority (Recover First):**
- Reconnaissance and Asset Discovery (1)
- Authentication and Session Management (4)
- SQL Injection (12)
- XSS Detection (13)
- SSRF Testing (14)

**Medium Priority (Recover Second):**
- API Endpoint Analysis (3)
- Authorization and Access Control (5)
- File Upload Testing (11)
- CSRF Testing (13)
- Command Injection (27)

**Low Priority (Recover Last):**
- WebSocket Security (30)
- GraphQL Vulnerabilities (29)
- HTTP Parameter Pollution (35)
- LDAP Injection (36)
- XPath Injection (42)

### Quick Resume Recovery

For rapid restart: load target context, identify last completed test point, skip verified negative results.

**Quick Resume Procedure:**
1. Load target context from checkpoint
2. Identify last completed test point
3. Skip verified negative results
4. Resume from first untested case
5. Re-enable continuous checkpointing

**Recovery Time:** 2-5 minutes
**Success Rate:** >90% (may skip some context)

---

## Recovery Validation

### Progress Validation

1. Verify testing progress counters are accurate
2. Validate test case completion status
3. Confirm testing order is preserved
4. Check for skipped or incomplete tests
5. Verify progress percentages are correct

### Finding Validation

1. Validate discovered vulnerabilities are preserved
2. Confirm finding severity assessments are intact
3. Check finding evidence is complete
4. Verify PoC data is preserved
5. Confirm finding classifications are correct

### Context Validation

1. Verify target context is current and accessible
2. Validate authentication state is valid
3. Confirm scope definitions are accurate
4. Check discovered endpoints are preserved
5. Verify target intelligence is current

### Payload Validation

1. Confirm payload libraries are intact
2. Validate payload effectiveness records
3. Check custom payloads are functional
4. Verify payload configurations are correct
5. Confirm payload testing history is preserved

---

## Recovery Testing

### Session Recovery Tests

- Test hunting session recovery after crash
- Validate session state restoration
- Test target context recovery
- Verify authentication state restoration

### Multi-Class Tests

- Test multi-class testing state recovery
- Validate per-class progress preservation
- Test cross-class correlation recovery
- Verify shared context restoration

### Context Tests

- Test target context preservation across sessions
- Validate authentication state recovery
- Test scope definition restoration
- Verify endpoint discovery preservation

### Payload Tests

- Test payload library recovery
- Validate custom payload restoration
- Test payload effectiveness recovery
- Verify payload configuration restoration

---

## Recovery Metrics

| Metric | Target | Critical | Measurement |
|--------|--------|----------|-------------|
| Hunting progress recovery | >95% | YES | Progress recovered / total progress |
| Recovery time objective | <5 min | YES | Average time from crash to hunting resume |
| Finding preservation rate | 100% | YES | Findings preserved / total findings |
| Test case accuracy | >98% | YES | Accurate test results / total test results |
| Checkpoint frequency | Every 10 min | YES | Time between automatic hunting checkpoints |
| Max state size | 100MB | NO | Maximum serialized hunting state size |
| Context preservation | >95% | YES | Context preserved / total context |
| Payload integrity | >99% | YES | Payloads intact / total payloads |

---

## Full Domain File References

### Foundation Modules (01-10)

- `1-Reconnaissance-and-Asset-Discovery.md` — Recon state covering target discovery, asset enumeration, scope mapping, and attack surface analysis progress. Includes recon methodologies, asset inventory, and discovery tracking.

- `2-JavaScript-Analysis-and-Deobfuscation.md` — JS analysis state covering endpoint extraction, secret discovery, API mapping, and deobfuscation progress. Includes JS analysis frameworks and extraction tracking.

- `3-API-Endpoint-Analysis.md` — API analysis state covering endpoint discovery, parameter mapping, authentication testing, and vulnerability assessment. Includes API analysis frameworks and endpoint tracking.

- `4-Authentication-and-Session-Management.md` — Auth testing state covering login mechanisms, session handling, token analysis, and authentication bypass attempts. Includes auth testing frameworks and bypass tracking.

- `5-Authorization-and-Access-Control.md` — Authorization state covering access control testing, privilege boundary mapping, and authorization bypass attempts. Includes authorization frameworks and boundary tracking.

- `6-Input-Validation-and-Sanitization.md` — Input validation state covering input point mapping, filter analysis, bypass attempts, and sanitization effectiveness. Includes validation frameworks and filter tracking.

- `7-Business-Logic-Flaws.md` — Business logic state covering workflow analysis, logic flaw identification, and exploitation progress. Includes logic analysis frameworks and flaw tracking.

- `8-Client-Side-Storage-Security.md` — Client storage state covering localStorage/sessionStorage analysis, cookie security, and client-side data protection testing. Includes storage analysis frameworks and security tracking.

- `9-Cryptography-and-Data-Protection.md` — Crypto testing state covering algorithm identification, key management testing, and cryptographic weakness detection. Includes crypto analysis frameworks and weakness tracking.

- `10-Error-Handling-and-Information-Disclosure.md` — Error handling state covering error trigger testing, information leakage detection, and disclosure mapping. Includes error analysis frameworks and disclosure tracking.

### Injection Classes (11-20)

- `11-File-Upload-and-Processing.md` — File upload state covering upload endpoint discovery, bypass attempts, and file processing vulnerability testing. Includes upload analysis frameworks and bypass tracking.

- `12-Server-Side-Request-Forgery-SSRF.md` — SSRF testing state covering URL parameter mapping, internal network probing, and cloud metadata access testing. Includes SSRF analysis frameworks and probing tracking.

- `13-Cross-Site-Request-Forgery-CSRF.md` — CSRF testing state covering token analysis, cross-origin testing, and state-changing operation mapping. Includes CSRF analysis frameworks and token tracking.

- `14-Cross-Origin-Resource-Sharing-CORS.md` — CORS testing state covering origin policy analysis, preflight testing, and misconfiguration detection. Includes CORS analysis frameworks and origin tracking.

- `15-Race-Conditions-and-Concurrency-Issues.md` — Race condition state covering concurrency testing, timing manipulation, and state inconsistency detection. Includes race analysis frameworks and timing tracking.

- `16-Third-Party-Component-Analysis.md` — Third-party state covering component enumeration, vulnerability research, and exploitation testing. Includes component analysis frameworks and vulnerability tracking.

- `17-Configuration-and-Misconfiguration-Hunting.md` — Config hunting state covering configuration extraction, security assessment, and misconfiguration exploitation. Includes config analysis frameworks and misconfig tracking.

- `18-Network-and-Infrastructure-Security.md` — Network security state covering network scanning, service enumeration, and infrastructure vulnerability testing. Includes network analysis frameworks and service tracking.

- `19-Mobile-and-API-Specific-Vulnerabilities.md` — Mobile/API state covering mobile-specific testing, API vulnerability assessment, and platform-specific attacks. Includes mobile analysis frameworks and API tracking.

- `20-Reporting-and-Proof-of-Concept-Development.md` — Reporting state covering finding documentation, PoC development, and report preparation progress. Includes reporting frameworks and PoC tracking.

### Advanced Injection Classes (21-30)

- `21-Web-Application-Firewall-WAF-Bypass.md` — WAF bypass state covering WAF detection, bypass technique testing, and payload optimization. Includes WAF analysis frameworks and bypass tracking.

- `22-HTTP-Request-Smuggling.md` — HTTP smuggling state covering CL.TE/TE.CL testing, cache poisoning, and smuggling verification. Includes smuggling analysis frameworks and verification tracking.

- `23-Subdomain-Takeover.md` — Subdomain takeover state covering CNAME analysis, service verification, and takeover execution progress. Includes takeover analysis frameworks and execution tracking.

- `24-Host-Header-Injection.md` — Host header state covering header manipulation, password reset poisoning, and cache poisoning testing. Includes host header frameworks and poisoning tracking.

- `25-XML-External-Entity-XXE-Injection.md` — XXE state covering XML endpoint discovery, entity injection testing, and file read exploitation. Includes XXE analysis frameworks and exploitation tracking.

- `26-Insecure-Deserialization.md` — Deserialization state covering gadget chain identification, payload generation, and execution testing. Includes deserialization frameworks and gadget tracking.

- `27-Command-Injection.md` — Command injection state covering injection point testing, OS command execution, and blind injection detection. Includes command injection frameworks and detection tracking.

- `28-NoSQL-Injection.md` — NoSQLi state covering injection testing, database enumeration, and operator injection exploitation. Includes NoSQLi analysis frameworks and operator tracking.

- `29-GraphQL-Vulnerabilities.md` — GraphQL state covering introspection, query abuse, authorization testing, and complexity analysis. Includes GraphQL analysis frameworks and abuse tracking.

- `30-WebSocket-Security.md` — WebSocket state covering connection testing, message interception, and cross-site hijacking testing. Includes WebSocket analysis frameworks and hijacking tracking.

### Specialized Classes (31-40)

- `31-Server-Side-Template-Injection.md` — SSTI state covering template engine detection, injection testing, and sandbox escape attempts. Includes SSTI analysis frameworks and escape tracking.

- `32-JSON-Web-Token-JWT-Vulnerabilities.md` — JWT state covering token analysis, algorithm manipulation, and key testing. Includes JWT analysis frameworks and manipulation tracking.

- `33-Content-Security-Policy-CSP-Bypass.md` — CSP bypass state covering CSP analysis, bypass technique testing, and policy weakness identification. Includes CSP analysis frameworks and weakness tracking.

- `34-Clickjacking-and-UI-Redressing.md` — Clickjacking state covering framebusting analysis, UI manipulation testing, and clickjacking verification. Includes clickjacking frameworks and verification tracking.

- `35-HTTP-Parameter-Pollution.md` — HPP state covering parameter pollution testing, backend confusion detection, and exploitation progress. Includes HPP analysis frameworks and confusion tracking.

- `36-LDAP-Injection.md` — LDAP state covering injection testing, directory enumeration, and authentication bypass attempts. Includes LDAP analysis frameworks and bypass tracking.

- `37-Session-Puzzling-and-Fixation.md` — Session puzzling state covering session variable manipulation, type juggling, and fixation testing. Includes session analysis frameworks and fixation tracking.

- `38-Insecure-File-Handling.md` — File handling state covering path traversal, file manipulation, and code execution testing. Includes file analysis frameworks and execution tracking.

- `39-Cross-Site-Script-Inclusion-XSSI.md` — XSSI state covering JSON endpoint discovery, script inclusion testing, and data extraction. Includes XSSI analysis frameworks and extraction tracking.

- `40-Prototype-Pollution.md` — Prototype pollution state covering pollution testing, gadget discovery, and exploitation progress. Includes pollution analysis frameworks and gadget tracking.

### Advanced Modules (41-50)

- `41-HTTP-Response-Splitting.md` — Response splitting state covering header injection, cache poisoning, and XSS exploitation testing. Includes splitting analysis frameworks and exploitation tracking.

- `42-XPath-Injection.md` — XPath state covering injection testing, document enumeration, and data extraction progress. Includes XPath analysis frameworks and extraction tracking.

- `43-Cross-Site-Request-Forgery-CSRF.md` — Advanced CSRF state covering complex CSRF scenarios, SameSite bypass, and CSRF chain exploitation. Includes advanced CSRF frameworks and chain tracking.

- `44-Cross-Origin-Resource-Sharing-CORS.md` — Advanced CORS state covering regex bypass, null origin exploitation, and CORS chain attacks. Includes advanced CORS frameworks and chain tracking.

- `45-Race-Conditions-and-Concurrency-Issues.md` — Advanced race state covering parallel request exploitation, TOCTOU vulnerabilities, and atomic operation bypass. Includes advanced race frameworks and bypass tracking.

- `46-Third-Party-Component-Analysis.md` — Advanced third-party state covering supply chain analysis, component vulnerability chaining, and dependency exploitation. Includes supply chain frameworks and dependency tracking.

- `47-Configuration-and-Misconfiguration-Hunting.md` — Advanced config state covering deep configuration analysis, hidden settings discovery, and config-based exploitation. Includes advanced config frameworks and discovery tracking.

- `48-Network-and-Infrastructure-Security.md` — Advanced network state covering network protocol exploitation, infrastructure chaining, and network-level attacks. Includes advanced network frameworks and attack tracking.

- `49-Mobile-and-API-Specific-Vulnerabilities.md` — Advanced mobile/API state covering mobile-specific exploitation, API chaining, and platform abuse. Includes advanced mobile frameworks and abuse tracking.

- `50-Reporting-and-Proof-of-Concept-Development.md` — Advanced reporting state covering complex finding documentation, multi-step PoC development, and advanced report techniques. Includes advanced reporting frameworks and documentation tracking.

---

## State Serialization Format

```json
{
  "domain": "core-prompts-hunting",
  "session_id": "hunt-001",
  "target": "example.com",
  "scope": {
    "in_scope": [],
    "out_of_scope": [],
    "rules": []
  },
  "auth_state": {
    "credentials": {},
    "session_tokens": {},
    "cookies": {},
    "auth_method": ""
  },
  "vulnerability_classes": {
    "xss": {
      "progress": 0.7,
      "test_cases": [],
      "completed_cases": [],
      "findings": [],
      "payloads_tested": []
    },
    "sqli": {
      "progress": 1.0,
      "test_cases": [],
      "completed_cases": [],
      "findings": [],
      "payloads_tested": []
    }
  },
  "payload_library": {
    "custom_payloads": [],
    "effectiveness_records": {},
    "payload_configs": {}
  },
  "discovered_endpoints": [],
  "hunting_strategy": {
    "priority_classes": [],
    "approach": "",
    "notes": ""
  },
  "findings": [],
  "intelligence": {
    "target_info": {},
    "technology_stack": {},
    "employee_data": {}
  }
}
```

---

## Recovery Checkpoint Protocol

### Phase 1: Pre-flight Validation
1. Validate target accessibility from current position
2. Check authentication token validity
3. Verify scope definitions are current
4. Confirm tool availability for testing
5. Validate checkpoint file integrity

### Phase 2: State Loading
1. Load hunting state from checkpoint
2. Deserialize vulnerability class progress
3. Restore authentication state
4. Load payload libraries
5. Restore findings and intelligence

### Phase 3: Progress Verification
1. Verify testing progress counters
2. Validate completed test case results
3. Check for missing or corrupted test data
4. Confirm finding completeness
5. Verify payload library integrity

### Phase 4: Context Restoration
1. Restore target context
2. Re-establish authentication
3. Reload scope definitions
4. Restore discovered endpoints
5. Verify target accessibility

### Phase 5: Hunting Resume
1. Resume from last validated test point
2. Re-enable continuous checkpointing
3. Validate hunting progress
4. Log recovery metrics
5. Return to normal operations after stability confirmed
