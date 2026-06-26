# Events: Core-Prompts-Hunting

**Domain Mapping:** `Core-Prompts-hunting/`

## Event Definitions

Events for the core vulnerability hunting methodology — systematic testing across 50 vulnerability classes with exploitation, bypass, and documentation.

## Emitted Events

| Event | Payload | Description |
|-------|---------|-------------|
| `hunt.class.selected` | `{vuln_class, target, methodology}` | Vuln class chosen for testing |
| `hunt.test.started` | `{vuln_class, endpoint, tool}` | Testing began on endpoint |
| `hunt.test.completed` | `{vuln_class, endpoint, result}` | Testing finished |
| `hunt.vuln.confirmed` | `{vuln_id, vuln_class, severity, endpoint}` | Vulnerability confirmed |
| `hunt.vuln.false_positive` | `{vuln_class, endpoint, reason}` | Finding was FP |
| `hunt.bypass.applied` | `{bypass_type, original_defense}` | WAF/control bypass used |
| `hunt.exploitation.succeeded` | `{vuln_id, technique, impact}` | Exploitation demonstrated |
| `hunt.exploitation.failed` | `{vuln_id, reason}` | Exploitation unsuccessful |
| `hunt.methodology.exhausted` | `{vuln_class, tests_run}` | All tests for class complete |

## Consumed Events

| Event | Source | Action |
|-------|--------|--------|
| `recon.asset.discovered` | Reconnaissance | Queue for vulnerability testing |
| `support.methodology.suggested` | Support | Load hunting methodology |
| `tool.available` | Tool Registry | Register scanning tool |

## Vulnerability Class Coverage

Events are emitted for all 50 hunting classes:
1. Reconnaissance and Asset Discovery (01)
2. JavaScript Analysis and Deobfuscation (02)
3. API Endpoint Analysis (03)
4. Authentication and Session Management (04)
5. Authorization and Access Control (05)
6. Input Validation and Sanitization (06)
7. Business Logic Flaws (07)
8. Client-Side Storage Security (08)
9. Cryptography and Data Protection (09)
10. Error Handling and Information Disclosure (10)
11. File Upload and Processing (11)
12. SSRF (12), CSRF (13), CORS (14), Race Conditions (15)
13. Third-Party Components (16), Configuration (17), Network (18), Mobile/API (19)
14. Reporting (20), WAF Bypass (21), HTTP Smuggling (22), Subdomain Takeover (23)
15. Host Header Injection (24), XXE (25), Deserialization (26), Command Injection (27)
16. NoSQL (28), GraphQL (29), WebSocket (30), SSTI (31), JWT (32)
17. CSP Bypass (33), Clickjacking (34), HPP (35), LDAP (36), Session Puzzling (37)
18. File Handling (38), XSSI (39), Prototype Pollution (40), Response Splitting (41)
19. XPath (42), CSRF dup (43), CORS dup (44), Race dup (45), Third-Party dup (46)
20. Config dup (47), Network dup (48), Mobile dup (49), Reporting dup (50)

## Event Flow

```
recon.asset.discovered
        │
        ▼
hunt.class.selected (for each vuln class)
        │
        ▼
hunt.test.started
        │
   ┌────┴────┐
   │         │
hunt.vuln.confirmed  hunt.vuln.false_positive
   │
   ▼
hunt.bypass.applied (if WAF detected)
   │
   ▼
hunt.exploitation.succeeded
   │
   ▼
hunt.methodology.exhausted
```
