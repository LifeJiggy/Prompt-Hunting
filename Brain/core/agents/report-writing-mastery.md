# Agent: Report-Writing-Mastery

**Domain Mapping:** `Report-Writing-Mastery/`

## Agent Profile

This agent crafts high-acceptance vulnerability reports across all major bug bounty platforms. It handles report structure optimization, impact framing, severity assessment, PoC development, triage psychology, and platform-specific formatting. The agent ensures every submission maximizes acceptance probability and bounty value.

## Capabilities

| Capability | Description |
|-----------|-------------|
| `report_structuring` | Optimize report anatomy for triage efficiency |
| `impact_framing` | Translate technical findings into business risk language |
| `severity_assessment` | Accurate CVSS 3.1 scoring with justification |
| `poc_development` | Create reproducible proof-of-concept demonstrations |
| `platform_formatting` | Adapt reports for HackerOne, Bugcrowd, Intigriti |

## Interface

```python
class ReportAgent(BaseAgent):
    name = "report-writing-mastery"
    capabilities = ["report_structuring", "impact_framing", "severity_assessment"]

    def think(self, context: AgentContext) -> Action:
        """Analyze finding details, select report template and severity."""

    def act(self, action: Action) -> ActionResult:
        """Generate report with structure, impact, PoC, and remediation."""

    def reflect(self, result: ActionResult) -> StateUpdate:
        """Review report quality, verify accuracy, check against rejection patterns."""
```

## Configuration

```yaml
agent:
  type: "report-writing-mastery"
  platforms: ["hackerone", "bugcrowd", "intigriti", "immunefi"]
  severity_model: "cvss_3.1"
  quality_check: true
  template_library: "./report_templates"
```

## Domain Files Reference

This agent manages all 54 report writing resources in `Report-Writing-Mastery/`:

**Report Structure (01, 02, 08, 10, 13, 19, 32, 35):** `01-Report-Structure-Optimization.md` covers core anatomy — title, summary, severity, description, impact, steps to reproduce, remediation, and supporting material. `02-Technical-Writing-Standards.md` examines clarity, precision, and conciseness in security writing. `08-Technical-Detail-Balancing.md` explores appropriate detail levels for different audiences. `10-Code-Sample-Formatting.md` covers syntax highlighting and request/response pair presentation. `13-Program-Specific-Formatting.md` adapts structure for HackerOne, Bugcrowd, and Intigriti. `19-Report-Template-Development.md` builds reusable templates for vulnerability classes. `32-Advanced-Formatting-Techniques.md` covers markdown mastery and visual hierarchy. `35-Cross-Platform-Compatibility.md` ensures format portability across platforms.

**Content Writing (07, 14, 21, 27-29, 41-43):** `07-Executive-Summary-Crafting.md` leads with what, where, and impact in the first sentences. `14-Language-and-Tone-Optimization.md` maintains professional tone without aggression. `21-Grammar-and-Style-Standards.md` eliminates common errors that undermine credibility. `27-Audience-Analysis.md` addresses triagers, program owners, and developers differently. `28-Information-Hierarchy.md` uses inverted pyramid approach for progressive disclosure. `29-Actionable-Recommendations.md` provides SMART remediation advice. `41-Report-Personalization.md` adapts to program culture and triager preferences. `42-Contextual-Intelligence.md` adds threat landscape and comparable incident context. `43-Technical-Depth-Calibration.md` adjusts detail for audience expertise.

**Technical Depth (04, 22, 47):** `04-Proof-of-Concept-Development.md` builds HTTP request construction, browser automation, and reproducible scripts. `22-Technical-Accuracy-Verification.md` ensures every statement is factually correct. `47-Advanced-Proof-of-Concept.md` covers multi-step chain demonstrations and automated PoC scripts.

**Impact and Severity (05, 23-24, 44, High-Severity-Vulnerability-Analysis, Impact-Communication):** `05-Vulnerability-Severity-Assessment.md` covers CVSS 3.1 vector calculation and justification. `23-Impact-Quantification.md` measures user exposure, data sensitivity, and financial impact. `24-Business-Context-Integration.md` connects findings to business model and regulatory implications. `44-Impact-Visualization.md` creates impact diagrams and flow charts. `High-Severity-Vulnerability-Analysis.md` presents critical findings with composure and severity defense. `Impact-Communication.md` translates technical findings into business risk language.

**Proof of Concept (09, 33-34):** `09-Visual-Aid-Integration.md` covers annotated screenshot capture and diagram creation. `33-Multimedia-Integration.md` handles video recording, GIF creation, and interactive elements. `34-Interactive-Report-Elements.md` adds collapsible sections and clickable references.

**Triage Optimization (03, 16-18, 31, 39):** `03-Private-Program-Case-Study.md` addresses higher expectations in private programs. `16-Follow-up-Communication.md` covers professional status checks without pushiness. `17-Rejection-Analysis-and-Improvement.md` learns from N/A decisions and builds appeal strategies. `18-Reward-Negotiation-Preparation.md` prepares severity defense with comparable references. `31-Common-Pitfalls-Avoidance.md` prevents information overload and missing context. `39-Program-Feedback-Incorporation.md` adapts to triager comments and evolving standards.

**Quality Assurance (20, 30, 37-38, 40, 49-50):** `20-Quality-Assurance-Process.md` builds checklist-based pre-submission review. `30-Report-Review-Process.md` implements systematic quality gates. `37-Report-Analytics-and-Metrics.md` tracks acceptance rates and triage times. `38-Peer-Review-Optimization.md` structures collaborative feedback. `40-Continuous-Improvement.md` analyzes outcomes for systematic quality improvement. `49-Quality-Metrics-Development.md` defines KPIs for report quality. `50-Master-Report-Writing-Framework.md` integrates the complete end-to-end methodology.

**Platform-Specific (HackerOne-Report-Analysis, Bugcrowd-Finding-Dissection):** `HackerOne-Report-Analysis.md` examines platform-specific patterns and triage workflow. `Bugcrowd-Finding-Dissection.md` aligns reports with VRT categories and severity expectations.

**Operations (06, 11-12, 15, 25-26, 36, 45-46, 48):** `06-Remediation-Recommendations.md` provides implementable fix guidance. `11-Timeline-Documentation.md` tracks discovery-to-fix timelines. `12-Collaboration-Crediting.md` handles co-author credit and split bounties. `15-Attachment-Management.md` organizes file naming and size optimization. `25-Compliance-Documentation.md` maps findings to GDPR, HIPAA, PCI-DSS. `26-International-Standard-Adherence.md` follows OWASP and CERT guidelines. `36-Version-Control-for-Reports.md` tracks revisions and resubmissions. `45-Report-Archiving-Strategy.md` builds personal report libraries. `46-Collaboration-Report-Standards.md` formats multi-author submissions. `48-Report-Automation-Tools.md` automates screenshot and template generation.

## Integration Points

- Receives findings from `Core-Prompts-hunting/` and `Advanced-Chaining-Techniques/`
- References real reports from `Real-World-Case-Studies/`
- Informs program selection via `Bug-Bounty-Program-Strategy/`
- Uses `memory/` for report history and pattern tracking
