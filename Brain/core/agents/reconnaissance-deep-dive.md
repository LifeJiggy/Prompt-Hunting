# Agent: Reconnaissance-Deep-Dive

**Domain Mapping:** `Reconnaissance-Deep-Dive/`

## Agent Profile

This agent performs exhaustive attack surface mapping through advanced reconnaissance techniques. It discovers subdomains, OSINT intelligence, cloud resources, API endpoints, leaked credentials, and technology fingerprints across 50 specialized recon methodologies. The agent builds comprehensive asset graphs that reveal hidden attack surface most hunters miss.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `subdomain_enumeration` | Multi-source subdomain discovery with takeover detection |
| `osint_collection` | Passive intelligence gathering from public sources |
| `asset_discovery` | Live host detection and service fingerprinting |
| `cloud_enumeration` | S3, GCS, Azure Blob and serverless discovery |
| `credential_harvesting` | Leaked credential and API key discovery |

## Interface

```python
class ReconAgent(BaseAgent):
    name = "reconnaissance-deep-dive"
    capabilities = ["subdomain_enumeration", "osint_collection", "asset_discovery"]

    def think(self, context: AgentContext) -> Action:
        """Determine recon phase based on current asset coverage gaps."""

    def act(self, action: Action) -> ActionResult:
        """Execute recon technique — query sources, enumerate assets, fingerprint."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Update asset graph, identify new attack surface, prioritize targets."""
```

## Configuration

```yaml
agent:
  type: "reconnaissance-deep-dive"
  passive_first: true
  rate_limit_rps: 10
  asset_graph_format: "directed"
  takeover_check: true
  cloud_enum_enabled: true
```

## Domain Files Reference

This agent covers all 50 reconnaissance methodologies in `Reconnaissance-Deep-Dive/`:

**Subdomain and DNS (01, 16-17):** `01-Advanced-Subdomain-Enumeration.md` covers multi-source enumeration using subfinder, amass, massdns with certificate transparency mining. `16-DNS-Enumeration-Advanced.md` examines zone transfers, DNS record analysis, and DNS-based subdomain discovery. `17-Certificate-Transparency-Logs.md` analyzes CT log mining for comprehensive domain discovery.

**OSINT and Passive (02, 18-20, 22-23):** `02-Passive-OSINT-Collection.md` covers search engine dorking, WHOIS analysis, and public record enumeration. `18-Historical-Data-Analysis.md` examines Wayback Machine and historical DNS data. `19-Social-Media-OSINT.md` covers profile discovery and social graph analysis. `20-Employee-Linked-Assets.md` maps assets through employee profiles and job postings. `22-Web-Archive-Analysis.md` examines archived pages for leaked endpoints. `23-Pastebin-and-Leak-Searching.md` covers paste site monitoring for credential leaks.

**Active Discovery (03, 10-11):** `03-Active-Asset-Discovery.md` covers live host detection with httpx and port scanning. `10-Content-Discovery-Automation.md` examines hidden file and directory discovery. `11-Directory-Brute-Forcing.md` covers recursive enumeration with custom wordlists.

**Fingerprinting (04, 09, 12, 41-45):** `04-Technology-Stack-Fingerprinting.md` covers CMS detection, framework identification, and backend technology profiling. `09-Version-Detection-Techniques.md` examines software version extraction and CVE correlation. `12-File-Type-Detection.md` covers MIME type analysis and file format identification. `41-Content-Management-System-Detection.md` analyzes WordPress, Drupal, Joomla fingerprinting. `42-Framework-and-Library-Identification.md` covers JavaScript library and server framework detection. `43-Server-Configuration-Analysis.md` examines server config disclosure. `44-SSL-TLS-Certificate-Analysis.md` covers certificate intelligence and TLS fingerprinting. `45-HTTP-Header-Intelligence.md` analyzes response headers for technology disclosure.

**Cloud Resources (05, 25):** `05-Cloud-Resource-Enumeration.md` covers AWS, Azure, GCP resource discovery. `25-Container-Registry-Enumeration.md` examines Docker Hub and container registry exposure.

**API Discovery (06, 28-31):** `06-API-Endpoint-Discovery.md` covers Swagger/OpenAPI enumeration and GraphQL introspection. `28-API-Documentation-Extraction.md` examines API doc scraping for endpoint discovery. `29-WebSocket-Endpoint-Discovery.md` covers WebSocket upgrade endpoint finding. `30-GraphQL-Introspection.md` analyzes schema disclosure and resolver mapping. `31-XML-RPC-and-SOAP-Discovery.md` covers legacy API endpoint discovery.

**Code Analysis (07, 14-15, 24):** `07-JavaScript-Source-Analysis.md` covers LinkFinder, SecretFinder, and custom endpoint extraction. `14-Source-Code-Leak-Detection.md` examines exposed source code and repository leaks. `15-Git-Repository-Analysis.md` covers .git exposure and commit history mining. `24-Code-Repository-Mining.md` examines GitHub, GitLab, Bitbucket for secrets and internal URLs.

**Configuration Files (08, 13):** `08-Configuration-File-Extraction.md` covers .env, config.json, and backup file discovery. `13-Backup-File-Discovery.md` examines common backup file patterns and locations.

**Enterprise Recon (21, 26-27, 32-40):** `21-Third-Party-Integration-Discovery.md` covers external service dependency mapping. `26-IoT-Device-Discovery.md` examines connected device enumeration. `27-Mobile-App-Analysis.md` covers app store and APK analysis. `32-Email-Address-Harvesting.md` examines email collection and validation. `33-Phone-Number-Enumeration.md` covers phone number discovery for social engineering. `34-Physical-Location-Intelligence.md` examines geolocation and physical asset mapping. `35-Supply-Chain-Asset-Mapping.md` covers vendor and partner asset discovery. `36-Competitor-Analysis.md` examines competitive intelligence gathering. `37-Partner-Network-Discovery.md` covers partner infrastructure mapping. `38-Acquisition-Target-Analysis.md` examines M&A target reconnaissance. `39-Subsidiary-Asset-Mapping.md` covers subsidiary and division asset discovery. `40-Regional-Infrastructure-Mapping.md` examines geographic infrastructure distribution.

**Advanced (46-50):** `46-Cookie-Analysis-and-Session-Management.md` covers cookie structure analysis. `47-Error-Page-Analysis.md` examines error pages for information disclosure. `48-Debug-Endpoint-Discovery.md` covers debug and admin endpoint finding. `49-Staging-Environment-Detection.md` examines dev/staging/qa environment discovery. `50-Advanced-Reconnaissance-Strategy.md` covers comprehensive recon methodology integration.

## Integration Points

- Stores discovered assets in `memory/` persistent storage
- Feeds targets to `Core-Prompts-hunting/` for vulnerability testing
- Informs `Advanced-Automation/` pipeline configuration
- Provides asset context to `Report-Writing-Mastery/`
