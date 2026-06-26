# Agent: Core-Prompts-Learning

**Domain Mapping:** `Core-Prompts-Learning/`

## Agent Profile

This agent delivers structured educational content for progressive security skill development. It covers 50 vulnerability classes with learning objectives, prerequisites, concepts, exercises, assessments, and advanced topics. The agent adapts difficulty based on learner progress and ensures concepts build upon each other in a logical sequence.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `curriculum_delivery` | Present learning modules in progressive difficulty order |
| `assessment_generation` | Create exercises and knowledge verification tests |
| `progress_tracking` | Monitor learner advancement across 50 topics |
| `concept_scaffolding` | Build complex topics from foundational knowledge |
| `remediation_guidance` | Provide targeted practice for weak areas |

## Interface

```python
class LearningAgent(BaseAgent):
    name = "core-prompts-learning"
    capabilities = ["curriculum_delivery", "assessment_generation", "progress_tracking"]

    def think(self, context: AgentContext) -> Action:
        """Assess learner level, select appropriate module and difficulty."""

    def act(self, action: Action) ->ActionResult:
        """Deliver learning content with exercises, track completion."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Evaluate assessment scores, adjust difficulty, recommend next module."""
```

## Configuration

```yaml
agent:
  type: "core-prompts-learning"
  total_modules: 50
  difficulty_levels: ["beginner", "intermediate", "advanced", "expert"]
  assessment_threshold: 0.8
  spaced_repetition: true
```

## Domain Files Reference

This agent manages all 50 learning modules in `Core-Prompts-Learning/`:

**Foundational (01-10):** `1-Reconnaissance-and-Asset-Discovery-Learning.md` covers systematic target enumeration and passive/active reconnaissance fundamentals. `2-JavaScript-Analysis-and-Deobfuscation-Learning.md` teaches JS source analysis and deobfuscation techniques. `3-API-Endpoint-Analysis-Learning.md` introduces REST and GraphQL endpoint discovery. `4-Authentication-and-Session-Management-Learning.md` covers session tokens, cookies, and auth flows. `5-Authorization-and-Access-Control-Learning.md` explores role-based and attribute-based access control flaws. `6-Input-Validation-and-Sanitization-Learning.md` teaches input handling vulnerabilities. `7-Business-Logic-Flaws-Learning.md` covers workflow bypass and logic errors. `8-Client-Side-Storage-Security-Learning.md` examines localStorage, sessionStorage, and cookie security. `9-Cryptography-and-Data-Protection-Learning.md` introduces cryptographic weaknesses. `10-Error-Handling-and-Information-Disclosure-Learning.md` covers verbose errors and stack traces.

**Intermediate (11-20):** `11-File-Upload-and-Processing-Learning.md` teaches unrestricted upload exploitation. `12-Server-Side-Request-Forgery-SSRF-Learning.md` covers internal service access via SSRF. `13-Cross-Site-Request-Forgery-CSRF-Learning.md` explores state-changing request forgery. `14-Cross-Origin-Resource-Sharing-CORS-Learning.md` examines origin reflection and null origin abuse. `15-Race-Conditions-and-Concurrency-Issues-Learning.md` covers TOCTOU and double-spending. `16-Third-Party-Component-Analysis-Learning.md` teaches dependency vulnerability research. `17-Configuration-and-Misconfiguration-Hunting-Learning.md` covers default credentials and exposed services. `18-Network-and-Infrastructure-Security-Learning.md` explores network-level attacks. `19-Mobile-and-API-Specific-Vulnerabilities-Learning.md` introduces mobile platform testing. `20-Reporting-and-Proof-of-Concept-Development-Learning.md` covers documentation best practices.

**Advanced (21-32):** `21-Web-Application-Firewall-WAF-Bypass-Learning.md` teaches encoding and fragmentation bypass. `22-HTTP-Request-Smuggling-Learning.md` covers CL.TE and TE.CL attacks. `23-Subdomain-Takeover-Learning.md` explores dangling DNS records. `24-Host-Header-Injection-Learning.md` covers password reset poisoning. `25-XML-External-Entity-XXE-Injection-Learning.md` teaches blind and error-based XXE. `26-Insecure-Deserialization-Learning.md` covers gadget chains across languages. `27-Command-Injection-Learning.md` teaches OS command execution. `28-NoSQL-Injection-Learning.md` covers MongoDB and CouchDB operators. `29-GraphQL-Vulnerabilities-Learning.md` explores introspection and batching attacks. `30-WebSocket-Security-Learning.md` covers cross-site WebSocket hijacking. `31-Server-Side-Template-Injection-SSTI-Learning.md` teaches Jinja2, Twig, and Freemarker exploitation. `32-JSON-Web-Token-JWT-Vulnerabilities-Learning.md` covers algorithm confusion and key attacks.

**Specialized (33-46):** `33-Content-Security-Policy-CSP-Bypass-Learning.md` teaches bypass via script-endorsed payloads. `34-Clickjacking-and-UI-Redressing-Learning.md` covers frame-based attacks. `35-HTTP-Parameter-Pollution-Learning.md` explores parameter duplication. `36-LDAP-Injection-Learning.md` covers directory service manipulation. `37-Session-Puzzling-and-Fixation-Learning.md` teaches session variable overloading. `38-Insecure-File-Handling-Learning.md` covers path traversal and LFI. `39-Advanced-Client-Side-Attacks-Learning.md` explores DOM clobbering and prototype pollution. `40-Cloud-Security-and-Misconfigurations-Learning.md` covers AWS, Azure, GCP misconfigs. `41-Third-Party-Integration-Security-Learning.md` teaches OAuth and SSO vulnerabilities. `42-Mobile-Application-Security-Learning.md` covers iOS and Android testing. `43-IoT-and-Embedded-Device-Security-Learning.md` explores firmware and hardware attacks. `44-API-Security-and-GraphQL-Learning.md` covers BOLA and mass assignment. `45-WebAssembly-and-Modern-Web-Technologies-Learning.md` teaches WASM reverse engineering. `46-Blockchain-and-Cryptocurrency-Security-Learning.md` covers smart contract vulnerabilities.

**Expert (47-50):** `47-Automation-and-Tool-Development-Learning.md` teaches custom scanner development. `48-Advanced-Reverse-Engineering-Learning.md` covers binary analysis and decompilation. `49-Compliance-and-Regulatory-Security-Learning.md` explores GDPR, HIPAA, PCI-DSS implications. `50-Advanced-Threat-Modeling-and-Risk-Assessment-Learning.md` covers STRIDE, DREAD, and attack tree analysis.

## Integration Points

- Stores learner progress in `memory/` persistent storage
- Generates assessments via `executions/` pipeline
- Delivers content through `session-managements/` session context
- Tracks completion events via `core/events/`
