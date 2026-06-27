# Report Writing Mastery — Tool Registry

**Domain:** `report-writing-mastery`
**Registry Path:** `Brain/tools/registry/report-writing-mastery.md`
**Source Directory:** `Report-Writing-Mastery/`
**File Count:** 54 domain files

---

## Overview

This tool registry manages report generation tools for bug bounty report writing within the Brain system. It provides dynamic registration, discovery, and lifecycle management for tools that generate, format, and optimize vulnerability reports for submission to bug bounty platforms. Every tool registered here maps to files in the `Report-Writing-Mastery/` directory.

---

## Domain Mapping

| Registry Key | Source File | Tool Category | Primary Capability |
|---|---|---|---|
| `report-structure` | `01-Report-Structure-Optimization.md` | structure | report_structure_optimization |
| `tech-writing-standards` | `02-Technical-Writing-Standards.md` | standards | technical_writing_standards |
| `private-program-case` | `03-Private-Program-Case-Study.md` | case_study | private_program_case_study |
| `poc-development` | `04-Proof-of-Concept-Development.md` | poc | poc_development |
| `severity-assessment` | `05-Vulnerability-Severity-Assessment.md` | assessment | severity_assessment |
| `remediation-recs` | `06-Remediation-Recommendations.md` | remediation | remediation_recommendations |
| `exec-summary` | `07-Executive-Summary-Crafting.md` | structure | executive_summary_crafting |
| `tech-detail-balance` | `08-Technical-Detail-Balancing.md` | structure | technical_detail_balancing |
| `visual-aids` | `09-Visual-Aid-Integration.md` | visual | visual_aid_integration |
| `code-formatting` | `10-Code-Sample-Formatting.md` | formatting | code_sample_formatting |
| `timeline-doc` | `11-Timeline-Documentation.md` | documentation | timeline_documentation |
| `collab-crediting` | `12-Collaboration-Crediting.md` | collaboration | collaboration_crediting |
| `program-formatting` | `13-Program-Specific-Formatting.md` | formatting | program_specific_formatting |
| `language-tone` | `14-Language-and-Tone-Optimization.md` | style | language_tone_optimization |
| `attachment-mgmt` | `15-Attachment-Management.md` | management | attachment_management |
| `followup-comm` | `16-Follow-up-Communication.md` | communication | followup_communication |
| `rejection-analysis` | `17-Rejection-Analysis-and-Improvement.md` | analysis | rejection_analysis |
| `reward-negotiation` | `18-Reward-Negotiation-Preparation.md` | negotiation | reward_negotiation_preparation |
| `report-templates` | `19-Report-Template-Development.md` | templates | report_template_development |
| `qa-process` | `20-Quality-Assurance-Process.md` | quality | quality_assurance |
| `grammar-style` | `21-Grammar-and-Style-Standards.md` | standards | grammar_style_standards |
| `tech-accuracy` | `22-Technical-Accuracy-Verification.md` | verification | technical_accuracy_verification |
| `impact-quantification` | `23-Impact-Quantification.md` | impact | impact_quantification |
| `business-context` | `24-Business-Context-Integration.md` | context | business_context_integration |
| `compliance-docs` | `25-Compliance-Documentation.md` | compliance | compliance_documentation |
| `intl-standards` | `26-International-Standard-Adherence.md` | standards | international_standard_adherence |
| `audience-analysis` | `27-Audience-Analysis.md` | analysis | audience_analysis |
| `info-hierarchy` | `28-Information-Hierarchy.md` | structure | information_hierarchy |
| `actionable-recs` | `29-Actionable-Recommendations.md` | remediation | actionable_recommendations |
| `report-review` | `30-Report-Review-Process.md` | quality | report_review_process |
| `common-pitfalls` | `31-Common-Pitfalls-Avoidance.md` | quality | common_pitfalls_avoidance |
| `advanced-formatting` | `32-Advanced-Formatting-Techniques.md` | formatting | advanced_formatting_techniques |
| `multimedia-integration` | `33-Multimedia-Integration.md` | visual | multimedia_integration |
| `interactive-elements` | `34-Interactive-Report-Elements.md` | visual | interactive_report_elements |
| `cross-platform-compat` | `35-Cross-Platform-Compatibility.md` | compatibility | cross_platform_compatibility |
| `version-control-reports` | `36-Version-Control-for-Reports.md` | management | version_control_for_reports |
| `report-analytics` | `37-Report-Analytics-and-Metrics.md` | analytics | report_analytics_metrics |
| `peer-review` | `38-Peer-Review-Optimization.md` | quality | peer_review_optimization |
| `feedback-incorporation` | `39-Program-Feedback-Incorporation.md` | feedback | feedback_incorporation |
| `continuous-improvement` | `40-Continuous-Improvement.md` | quality | continuous_improvement |
| `report-personalization` | `41-Report-Personalization.md` | style | report_personalization |
| `contextual-intelligence` | `42-Contextual-Intelligence.md` | intelligence | contextual_intelligence |
| `tech-depth-calibration` | `43-Technical-Depth-Calibration.md` | style | technical_depth_calibration |
| `impact-visualization` | `44-Impact-Visualization.md` | visual | impact_visualization |
| `report-archiving` | `45-Report-Archiving-Strategy.md` | management | report_archiving_strategy |
| `collab-report-standards` | `46-Collaboration-Report-Standards.md` | standards | collaboration_report_standards |
| `advanced-poc` | `47-Advanced-Proof-of-Concept.md` | poc | advanced_poc_development |
| `report-automation-tools` | `48-Report-Automation-Tools.md` | automation | report_automation_tools |
| `quality-metrics` | `49-Quality-Metrics-Development.md` | quality | quality_metrics_development |
| `master-framework` | `50-Master-Report-Writing-Framework.md` | framework | master_report_writing_framework |
| `bugcrowd-dissection` | `Bugcrowd-Finding-Dissection.md` | platform | bugcrowd_finding_dissection |
| `hackerone-analysis` | `HackerOne-Report-Analysis.md` | platform | hackerone_report_analysis |
| `high-severity-analysis` | `High-Severity-Vulnerability-Analysis.md` | analysis | high_severity_analysis |
| `impact-communication` | `Impact-Communication.md` | communication | impact_communication |

---

## Tool Registration Schema

```yaml
report_registration:
  name: string
  version: string
  category: string
  source_file: string
  capabilities: list[string]
  config: dict
  metadata: dict
  dependencies: dict
  status: enum
```

---

## Registered Tools

### Report Structure Optimization

```python
registry.register(
    name="report-structure-optimizer",
    tool_class=ReportStructureOptimizerTool,
    config={
        "template_engine": "jinja2",
        "platforms": ["hackerone", "bugcrowd", "intigriti", "immunefi"],
        "auto_format": True
    },
    metadata={
        "category": "structure",
        "capabilities": ["report_structure_optimization", "template_generation", "platform_formatting"],
        "description": "Optimize report structure for maximum clarity and impact",
        "tags": ["structure", "template", "formatting", "report"],
        "source_file": "01-Report-Structure-Optimization.md"
    }
)
```

### Executive Summary Crafting

```python
registry.register(
    name="exec-summary-crafter",
    tool_class=ExecSummaryCrafterTool,
    config={
        "max_length": 200,
        "impact_first": True,
        "auto_generate": True
    },
    metadata={
        "category": "structure",
        "capabilities": ["executive_summary_crafting", "impact_summary", "auto_generation"],
        "description": "Craft compelling executive summaries for vulnerability reports",
        "tags": ["executive", "summary", "impact", "structure"],
        "source_file": "07-Executive-Summary-Crafting.md"
    }
)
```

### Severity Assessment

```python
registry.register(
    name="severity-assessor",
    tool_class=SeverityAssessorTool,
    config={
        "cvss_version": "3.1",
        "auto_calculate": True,
        "platform_defaults": True
    },
    metadata={
        "category": "assessment",
        "capabilities": ["severity_assessment", "cvss_calculation", "platform_severity_mapping"],
        "description": "Assess vulnerability severity using CVSS and platform-specific scoring",
        "tags": ["severity", "cvss", "assessment", "scoring"],
        "source_file": "05-Vulnerability-Severity-Assessment.md"
    }
)
```

### Remediation Recommendations

```python
registry.register(
    name="remediation-recs",
    tool_class=RemediationRecsTool,
    config={
        "code_examples": True,
        "platform_specific": True,
        "priority_ranking": True
    },
    metadata={
        "category": "remediation",
        "capabilities": ["remediation_recommendations", "code_examples", "priority_ranking"],
        "description": "Generate actionable remediation recommendations with code examples",
        "tags": ["remediation", "recommendations", "code", "fix"],
        "source_file": "06-Remediation-Recommendations.md"
    }
)
```

### PoC Development

```python
registry.register(
    name="poc-developer",
    tool_class=PoCDeveloperTool,
    config={
        "screenshot_automation": True,
        "step_by_step": True,
        "multi_format": True
    },
    metadata={
        "category": "poc",
        "capabilities": ["poc_development", "screenshot_automation", "step_by_step_generation"],
        "description": "Develop proof-of-concept demonstrations for vulnerability reports",
        "tags": ["poc", "proof-of-concept", "demonstration", "evidence"],
        "source_file": "04-Proof-of-Concept-Development.md"
    }
)
```

### Report Automation Tools

```python
registry.register(
    name="report-automation",
    tool_class=ReportAutomationTool,
    config={
        "auto_populate": True,
        "screenshot_integration": True,
        "markdown_export": True,
        "html_export": True
    },
    metadata={
        "category": "automation",
        "capabilities": ["report_automation_tools", "auto_population", "multi_format_export"],
        "description": "Automate report generation and formatting workflows",
        "tags": ["automation", "report", "export", "workflow"],
        "source_file": "48-Report-Automation-Tools.md"
    }
)
```

### Master Report Writing Framework

```python
registry.register(
    name="master-report-framework",
    tool_class=MasterReportFrameworkTool,
    config={
        "full_lifecycle": True,
        "platform_adaptation": True,
        "quality_gates": True
    },
    metadata={
        "category": "framework",
        "capabilities": ["master_report_writing_framework", "full_lifecycle_management", "quality_gates"],
        "description": "Comprehensive report writing framework covering all aspects",
        "tags": ["framework", "master", "lifecycle", "quality"],
        "source_file": "50-Master-Report-Writing-Framework.md"
    }
)
```

### Bugcrowd Finding Dissection

```python
registry.register(
    name="bugcrowd-dissector",
    tool_class=BugcrowdDissectorTool,
    config={
        "vrt_category_mapping": True,
        "severity_override": True,
        "oos_rebuttal": True
    },
    metadata={
        "category": "platform",
        "capabilities": ["bugcrowd_finding_dissection", "vrt_category_mapping", "oos_rebuttal"],
        "description": "Dissect findings for Bugcrowd-specific submission requirements",
        "tags": ["bugcrowd", "platform", "vrt", "submission"],
        "source_file": "Bugcrowd-Finding-Dissection.md"
    }
)
```

### HackerOne Report Analysis

```python
registry.register(
    name="h1-report-analyzer",
    tool_class=H1ReportAnalyzerTool,
    config={
        "report_pattern_extraction": True,
        "successful_report_patterns": True,
        "platform_specific_formatting": True
    },
    metadata={
        "category": "platform",
        "capabilities": ["hackerone_report_analysis", "pattern_extraction", "platform_formatting"],
        "description": "Analyze successful HackerOne report patterns",
        "tags": ["hackerone", "platform", "analysis", "patterns"],
        "source_file": "HackerOne-Report-Analysis.md"
    }
)
```

### Impact Communication

```python
registry.register(
    name="impact-comms",
    tool_class=ImpactCommsTool,
    config={
        "business_impact_mapping": True,
        "user_impact_storytelling": True,
        "financial_estimate": True
    },
    metadata={
        "category": "communication",
        "capabilities": ["impact_communication", "business_impact_mapping", "storytelling"],
        "description": "Communicate vulnerability impact effectively in reports",
        "tags": ["impact", "communication", "business", "storytelling"],
        "source_file": "Impact-Communication.md"
    }
)
```

---

## Register / Unregister Operations

```python
def register_report_tool(self, name: str, tool_class: type, config: dict = None, metadata: dict = None) -> ReportRegistration:
    if name in self._tools:
        raise DuplicateToolError(f"Tool '{name}' already registered")
    registration = ReportRegistration(
        id=generate_id(), name=name,
        version=metadata.get("version", "1.0.0"),
        category=metadata.get("category", "reporting"),
        source_file=metadata.get("source_file", ""),
        tool_class=tool_class,
        capabilities=metadata.get("capabilities", []),
        config=config or {}, metadata=metadata or {},
        registered_at=datetime.utcnow(), status="active"
    )
    self._tools[name] = registration
    self._index_category(registration)
    self._event_bus.emit("tool.registered", {"name": name, "domain": "report-writing-mastery"})
    return registration

def unregister_report_tool(self, name: str) -> bool:
    if name not in self._tools:
        return False
    del self._tools[name]
    self._event_bus.emit("tool.unregistered", {"name": name})
    return True
```

---

## Tool Discovery

```python
def discover_by_category(self, category: str) -> list[ReportRegistration]:
    names = self._categories.get(category, set())
    return [self._tools[n] for n in names if self._tools[n].status == "active"]

def discover_by_capability(self, capability: str) -> list[ReportRegistration]:
    return [t for t in self._tools.values() if capability in t.capabilities and t.status == "active"]

def discover_by_platform(self, platform: str) -> list[ReportRegistration]:
    """Discover tools specific to a bug bounty platform."""
    return [t for t in self._tools.values() if platform in t.metadata.get("tags", []) and t.status == "active"]

def discover_quality_tools(self) -> list[ReportRegistration]:
    """Discover all quality assurance tools."""
    return [t for t in self._tools.values() if t.category in ("quality", "verification") and t.status == "active"]

def discover_structure_tools(self) -> list[ReportRegistration]:
    """Discover all report structure tools."""
    return [t for t in self._tools.values() if t.category == "structure" and t.status == "active"]
```

---

## Tool Listing

```python
def list_all_tools(self, sort_by: str = "name") -> list[ReportRegistration]:
    tools = list(self._tools.values())
    tools.sort(key=lambda t: getattr(t, sort_by, t.name))
    return tools

def list_categories(self) -> dict[str, list[str]]:
    return {cat: sorted(list(names)) for cat, names in sorted(self._categories.items())}

def list_by_platform(self) -> dict[str, list[str]]:
    platform_map = {}
    for t in self._tools.values():
        for tag in t.metadata.get("tags", []):
            if tag in ("hackerone", "bugcrowd", "intigriti", "immunefi"):
                platform_map.setdefault(tag, []).append(t.name)
    return {k: sorted(v) for k, v in sorted(platform_map.items())}
```

---

## Tool Metadata

```yaml
report_metadata:
  name: string
  version: string
  category: string
  source_file: string
  description: string
  tags: list[string]
  capabilities: list[string]
  platforms: list[string]        # Supported bug bounty platforms
  report_types: list[string]     # vulnerability_report | disclosure | advisory
  target_audience: list[string]  # triager | developer | manager
  config_schema: dict
  author: string
  license: string
```

---

## Tool Versioning

```python
class ReportVersionManager:
    def check_compatibility(self, name: str, min_version: str) -> bool:
        tool = self._tools.get(name)
        return tool and semver.compare(tool.version, min_version) >= 0

    def upgrade(self, name: str, new_version: str) -> ReportRegistration:
        tool = self._tools[name]
        tool.version = new_version
        return tool
```

---

## Tool Dependencies

```python
class ReportDependencyManager:
    def resolve_dependencies(self, name: str) -> list[str]:
        tool = self._tools[name]
        return [d["name"] for d in tool.metadata.get("dependencies", {}).get("tool_dependencies", [])]
```

---

## Full Domain File References

| # | File | Registered Tool |
|---|---|---|
| 1 | `01-Report-Structure-Optimization.md` | report-structure-optimizer |
| 2 | `02-Technical-Writing-Standards.md` | tech-writing-standards |
| 3 | `03-Private-Program-Case-Study.md` | private-program-case |
| 4 | `04-Proof-of-Concept-Development.md` | poc-developer |
| 5 | `05-Vulnerability-Severity-Assessment.md` | severity-assessor |
| 6 | `06-Remediation-Recommendations.md` | remediation-recs |
| 7 | `07-Executive-Summary-Crafting.md` | exec-summary-crafter |
| 8 | `08-Technical-Detail-Balancing.md` | tech-detail-balance |
| 9 | `09-Visual-Aid-Integration.md` | visual-aids |
| 10 | `10-Code-Sample-Formatting.md` | code-formatting |
| 11 | `11-Timeline-Documentation.md` | timeline-doc |
| 12 | `12-Collaboration-Crediting.md` | collab-crediting |
| 13 | `13-Program-Specific-Formatting.md` | program-formatting |
| 14 | `14-Language-and-Tone-Optimization.md` | language-tone |
| 15 | `15-Attachment-Management.md` | attachment-mgmt |
| 16 | `16-Follow-up-Communication.md` | followup-comm |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | rejection-analysis |
| 18 | `18-Reward-Negotiation-Preparation.md` | reward-negotiation |
| 19 | `19-Report-Template-Development.md` | report-templates |
| 20 | `20-Quality-Assurance-Process.md` | qa-process |
| 21 | `21-Grammar-and-Style-Standards.md` | grammar-style |
| 22 | `22-Technical-Accuracy-Verification.md` | tech-accuracy |
| 23 | `23-Impact-Quantification.md` | impact-quantification |
| 24 | `24-Business-Context-Integration.md` | business-context |
| 25 | `25-Compliance-Documentation.md` | compliance-docs |
| 26 | `26-International-Standard-Adherence.md` | intl-standards |
| 27 | `27-Audience-Analysis.md` | audience-analysis |
| 28 | `28-Information-Hierarchy.md` | info-hierarchy |
| 29 | `29-Actionable-Recommendations.md` | actionable-recs |
| 30 | `30-Report-Review-Process.md` | report-review |
| 31 | `31-Common-Pitfalls-Avoidance.md` | common-pitfalls |
| 32 | `32-Advanced-Formatting-Techniques.md` | advanced-formatting |
| 33 | `33-Multimedia-Integration.md` | multimedia-integration |
| 34 | `34-Interactive-Report-Elements.md` | interactive-elements |
| 35 | `35-Cross-Platform-Compatibility.md` | cross-platform-compat |
| 36 | `36-Version-Control-for-Reports.md` | version-control-reports |
| 37 | `37-Report-Analytics-and-Metrics.md` | report-analytics |
| 38 | `38-Peer-Review-Optimization.md` | peer-review |
| 39 | `39-Program-Feedback-Incorporation.md` | feedback-incorporation |
| 40 | `40-Continuous-Improvement.md` | continuous-improvement |
| 41 | `41-Report-Personalization.md` | report-personalization |
| 42 | `42-Contextual-Intelligence.md` | contextual-intelligence |
| 43 | `43-Technical-Depth-Calibration.md` | tech-depth-calibration |
| 44 | `44-Impact-Visualization.md` | impact-visualization |
| 45 | `45-Report-Archiving-Strategy.md` | report-archiving |
| 46 | `46-Collaboration-Report-Standards.md` | collab-report-standards |
| 47 | `47-Advanced-Proof-of-Concept.md` | advanced-poc |
| 48 | `48-Report-Automation-Tools.md` | report-automation |
| 49 | `49-Quality-Metrics-Development.md` | quality-metrics |
| 50 | `50-Master-Report-Writing-Framework.md` | master-report-framework |
| 51 | `Bugcrowd-Finding-Dissection.md` | bugcrowd-dissector |
| 52 | `HackerOne-Report-Analysis.md` | h1-report-analyzer |
| 53 | `High-Severity-Vulnerability-Analysis.md` | high-severity-analysis |
| 54 | `Impact-Communication.md` | impact-comms |
| 55 | `README.md` | (documentation) |

---

## Categories Index

| Category | Count | Tools |
|---|---|---|
| `structure` | 4 | report-structure-optimizer, exec-summary-crafter, info-hierarchy |
| `standards` | 3 | tech-writing-standards, grammar-style, intl-standards, collab-report-standards |
| `case_study` | 1 | private-program-case |
| `poc` | 2 | poc-developer, advanced-poc |
| `assessment` | 1 | severity-assessor |
| `remediation` | 2 | remediation-recs, actionable-recs |
| `visual` | 3 | visual-aids, multimedia-integration, interactive-elements, impact-visualization |
| `formatting` | 3 | code-formatting, program-formatting, advanced-formatting |
| `documentation` | 1 | timeline-doc |
| `collaboration` | 1 | collab-crediting |
| `style` | 3 | language-tone, report-personalization, tech-depth-calibration |
| `management` | 3 | attachment-mgmt, version-control-reports, report-archiving |
| `communication` | 2 | followup-comm, impact-comms |
| `analysis` | 3 | rejection-analysis, audience-analysis, high-severity-analysis |
| `negotiation` | 1 | reward-negotiation |
| `templates` | 1 | report-templates |
| `quality` | 5 | qa-process, tech-accuracy, report-review, common-pitfalls, peer-review, quality-metrics, continuous-improvement |
| `impact` | 1 | impact-quantification |
| `context` | 1 | business-context, contextual-intelligence |
| `compliance` | 1 | compliance-docs |
| `feedback` | 1 | feedback-incorporation |
| `platform` | 2 | bugcrowd-dissector, h1-report-analyzer |
| `automation` | 1 | report-automation |
| `framework` | 1 | master-report-framework |
| `compatibility` | 1 | cross-platform-compat |
| `analytics` | 1 | report-analytics |
| `intelligence` | 1 | contextual-intelligence |

---

*Part of the Brain tools subsystem — Report Writing Mastery Domain Registry.*
