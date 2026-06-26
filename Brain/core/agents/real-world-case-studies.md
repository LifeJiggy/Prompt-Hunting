# Agent: Real-World-Case-Studies

**Domain Mapping:** `Real-World-Case-Studies/`

## Agent Profile

This agent analyzes disclosed vulnerability reports from HackerOne, Bugcrowd, and other platforms. It extracts hunting patterns from 50 real-world findings across injection, authentication, serialization, and logic vulnerability classes. Each case study provides root cause analysis, exploitation technique, and reusable detection patterns.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `pattern_extraction` | Derive hunting patterns from disclosed reports |
| `technique_cataloging` | Build reusable exploitation technique library |
| `severity_analysis` | Understand bounty-to-severity correlation |
| `platform_comparison` | Compare reporting across platforms |
| `methodology_refinement` | Improve hunting based on disclosed findings |

## Interface

```python
class RealWorldAgent(BaseAgent):
    name = "real-world-case-studies"
    capabilities = ["pattern_extraction", "technique_cataloging", "severity_analysis"]

    def think(self, context: AgentContext) -> Action:
        """Select case studies relevant to current target or vulnerability class."""

    def act(self, action: Action) -> ActionResult:
        """Analyze disclosed report, extract pattern, generate hunting prompt."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Validate pattern applicability, update technique database."""
```

## Configuration

```yaml
agent:
  type: "real-world-case-studies"
  pattern_database: "./disclosed_patterns"
  min_bounty: 100
  platforms: ["hackerone", "bugcrowd", "intigriti"]
  auto_hunt_generation: true
```

## Domain Files Reference

This agent manages all 50 disclosed report analyses in `Real-World-Case-Studies/`:

**Injection Attacks (01, 03, 06, 09-10, 28-29):** `01-IDOR-Account-Takeover-Case-Studies.md` analyzes IDOR findings leading to account takeover across multiple programs. `03-SQL-Injection-Data-Breaches.md` covers error-based, blind, and time-based SQLi with data extraction techniques. `06-Command-Injection-RCE.md` examines OS command injection leading to remote code execution. `09-XXE-XML-External-Entity-Attacks.md` covers blind XXE via out-of-band channels and file read exploitation. `10-SSTI-Server-Side-Template-Injection.md` analyzes Jinja2, Twig, and Freemarker template injection to RCE. `28-LDAP-Injection-Attacks.md` covers directory service manipulation for authentication bypass. `29-XPath-Injection-Attacks.md` examines XML query injection for data extraction.

**XSS and Client-Side (02, 25-26, 31, 38):** `02-XSS-Stored-Persistent-Attacks.md` covers stored XSS leading to session hijacking and defacement. `25-CSP-Bypass-Techniques.md` analyzes Content Security Policy bypass via script endorser and base URI manipulation. `26-Clickjacking-UI-Redressing.md` examines frame-based attacks for unintended actions. `31-Prototype-Pollution-JavaScript.md` covers `__proto__` injection leading to RCE in Node.js. `38-CORS-Misconfiguration.md` analyzes origin reflection and null origin abuse for data theft.

**Authentication and Session (05, 11-12, 21, 33, 37, 39, 50):** `05-CSRF-State-Changing-Attacks.md` covers cross-site request forgery for password changes and account modifications. `11-JWT-Token-Manipulation.md` examines algorithm confusion, key injection, and signature stripping. `12-Authentication-Bypass.md` analyzes authentication mechanism flaws across multiple platforms. `21-Host-Header-Injection.md` covers password reset poisoning via host header manipulation. `33-Open-Redirect-Phishing.md` examines redirect chains for credential theft. `37-WebSocket-Hijacking.md` covers cross-site WebSocket hijacking for session theft. `39-Token-Leakage-URL-Parameters.md` analyzes token exposure in URLs and referer headers. `50-API-Authentication-Bypass.md` covers API key and token bypass techniques.

**Deserialization (07, 16-19):** `07-Deserialization-Remote-Code-Execution.md` covers general deserialization RCE patterns. `16-Memory-Corruption-Heap-Overflow.md` examines heap-based buffer overflow exploitation. `17-Deserialization-Java-Deserialization.md` covers Commons Collections gadget chains and ysoserial. `18-Deserialization-PHP-Unserialize.md` analyzes PHP object injection and magic method abuse. `19-Deserialization-Python-Pickle.md` covers pickle deserialization leading to code execution.

**SSRF and Network (04, 22, 27, 36, 46-47):** `04-SSRF-Internal-Network-Access.md` covers SSRF to cloud metadata and internal services. `22-DNS-Rebinding-Attacks.md` examines TTL manipulation for internal network access. `27-HTTP-Response-Splitting.md` covers CRLF injection for cache poisoning and XSS. `36-HTTP-Request-Smuggling.md` analyzes CL.TE and TE.CL request smuggling. `46-Server-Side-Request-Forgery.md` covers SSRF bypass techniques including IP filtering evasion. `47-Client-Side-Request-Forgery.md` examines CSRF-based SSRF from the client side.

**Logic and Access (13-14, 20, 32, 34):** `13-Privilege-Escalation.md` covers horizontal and vertical privilege escalation paths. `14-Business-Logic-Flaws.md` analyzes workflow bypass and price manipulation. `20-Race-Condition-Time-of-Check.md` examines TOCTOU and double-spending vulnerabilities. `32-Subdomain-Takeover.md` covers dangling DNS record exploitation. `34-Content-Spoofing-Attacks.md` examines MIME sniffing and content injection.

**Information Disclosure (15, 40-42):** `15-Information-Disclosure.md` covers verbose errors, directory listing, and source code exposure. `40-Sensitive-Data-Exposure.md` analyzes PII leakage through API responses. `41-Weak-Encryption-Algorithms.md` examines use of deprecated ciphers. `42-Insecure-Cryptographic-Storage.md` covers hardcoded keys and weak hashing.

**File Inclusion (08, 43-45):** `08-File-Upload-Arbitrary-Upload.md` covers unrestricted file upload to webshell. `43-Path-Traversal-File-Inclusion.md` examines directory traversal for file read. `44-Local-File-Inclusion-LFI.md` covers PHP wrappers and filter chains. `45-Remote-File-Inclusion-RFI.md` analyzes remote inclusion for code execution.

**Advanced (23-24, 35, 48-49):** `23-WebSocket-Security-Issues.md` covers WebSocket upgrade hijacking. `24-GraphQL-Introspection-Attacks.md` examines schema disclosure and batching attacks. `35-WebCache-Poisoning.md` analyzes cache key manipulation for victim redirection. `48-Mobile-API-Security-Issues.md` covers mobile-specific API vulnerabilities. `49-Cloud-Misconfiguration-AWS.md` examines S3 bucket and IAM misconfigurations.

## Integration Points

- Stores extracted patterns in `memory/` knowledge graph
- Feeds hunting methodologies to `Core-Prompts-hunting/`
- Provides real-world examples to `Report-Writing-Mastery/`
- Informs severity assessment in `Bug-Bounty-Program-Strategy/`
