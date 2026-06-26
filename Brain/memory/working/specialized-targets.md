# Working Memory: Specialized Targets Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `SPEC-TARGET-001` |
| Root Folder | `Specialized-Targets/` |
| Total Files | 50 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + category index |
| Typical Lifetime | Target engagement (2-8h) |
| Eviction Trigger | Target completion, session end, or 24h TTL |

---

## Overview

Working memory for specialized targets captures the state of security assessments
against specific target categories — IoT devices, critical infrastructure, cloud
environments, mobile applications, and more. This spans 50 modules from IoT device
security through global-scale system security. Working memory tracks:

- **Target category**: Which specialized category the target belongs to and the
  specific assessment methodology being applied.
- **Category-specific findings**: Findings that are unique to the target category
  — firmware vulnerabilities for IoT, ICS-specific issues for OT, multi-tenant
  isolation for SaaS, etc.
- **Compliance requirements**: Industry-specific compliance requirements that
  affect the assessment scope — HIPAA for healthcare, PCI-DSS for financial,
  NERC CIP for energy, etc.
- **Specialized tools**: Tools and techniques specific to the target category —
  firmware analyzers for IoT, protocol fuzzers for ICS, cloud CLI tools for
  cloud environments.
- **Target inventory**: Comprehensive inventory of target-specific assets —
  devices, APIs, firmware versions, configurations, network segments.
- **Risk assessment**: Category-specific risk assessment considering the unique
  threat landscape for the target type.
- **Remediation context**: Category-specific remediation guidance that accounts
  for industry constraints, regulatory requirements, and operational limitations.

This is the "specialized brain" that applies category-specific knowledge to
enhance security assessments beyond generic web application testing.

---

## Data Schema (YAML)

```yaml
working_memory_specialized:
  version: "1.8"
  scope: "target-engagement"
  ttl_seconds: 86400

  session_state:
    session_id: "string (uuid4)"
    assessor_id: "string"
    target_name: "string"
    target_category: "enum(iot|critical_infrastructure|cloud|mobile|blockchain|ai_ml|api|enterprise|healthcare|financial|government|telecom|automotive|aerospace|energy|manufacturing|education|retail|media|global_scale)"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    methodology_applied: "list[string]"

  target_inventory:
    asset_id: "string (uuid4)"
    asset_type: "string (category-specific)"
    name: "string"
    version: "string (nullable)"
    firmware: "string (nullable)"
    configuration: "map[string,string]"
    network_segment: "string (nullable)"
    protocols: "list[string]"
    ports: "list[integer]"
    status: "enum(active|inactive|unknown)"
    criticality: "enum(critical|high|medium|low)"
    first_discovered: "ISO8601"
    last_verified: "ISO8601"

  category_findings:
    finding_id: "string (uuid4)"
    finding_type: "string (category-specific)"
    title: "string"
    severity: "string"
    category: "string"
    affected_asset: "string (asset_id)"
    description: "string"
    impact: "string"
    remediation: "string"
    compliance_impact: "list[string]"
    cvss_estimate: "float"
    evidence_ids: "list[string]"
    status: "enum(draft|validated|ready_to_submit|submitted)"

  compliance_requirements:
    compliance_id: "string (uuid4)"
    framework: "enum(hipaa|pci_dss|gdpr|soc2|iso27001|nerc_cip|fedramp|fisma|sox|cis|nist|owasp)"
    requirement_id: "string"
    requirement_description: "string"
    assessment_status: "enum(not_assessed|compliant|non_compliant|partial)"
    evidence: "list[string]"
    remediation_priority: "enum(immediate|high|medium|low)"

  specialized_tools:
    tool_id: "string (uuid4)"
    tool_name: "string"
    tool_category: "string"
    purpose: "string"
    target_category: "string"
    configuration: "map[string,string]"
    last_used: "ISO8601"
    findings_generated: "integer"

  risk_assessment:
    assessment_id: "string (uuid4)"
    risk_category: "string"
    likelihood: "enum(very_high|high|medium|low|very_low)"
    impact: "enum(catastrophic|critical|high|medium|low)"
    risk_level: "enum(critical|high|medium|low)"
    mitigation: "string"
    residual_risk: "string"
    assessment_date: "ISO8601"

  remediation_plan:
    remediation_id: "string (uuid4)"
    finding_id: "string"
    remediation_type: "enum(immediate|short_term|long_term|strategic)"
    description: "string"
    prerequisites: "list[string]"
    estimated_effort: "string"
    priority: "integer (1=highest)"
    deadline: "ISO8601 (nullable)"
    status: "enum(proposed|approved|in_progress|completed|deferred)"

  category_knowledge:
    knowledge_id: "string (uuid4)"
    category: "string"
    topic: "string"
    content: "string"
    source: "string"
    applicability: "float (0.0-1.0)"
    last_updated: "ISO8601"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone
from typing import Optional
from enum import Enum


class TargetCategory(Enum):
    IOT = "iot"
    CRITICAL_INFRASTRUCTURE = "critical_infrastructure"
    CLOUD = "cloud"
    MOBILE = "mobile"
    BLOCKCHAIN = "blockchain"
    AI_ML = "ai_ml"
    API = "api"
    ENTERPRISE = "enterprise"
    HEALTHCARE = "healthcare"
    FINANCIAL = "financial"
    GOVERNMENT = "government"
    TELECOM = "telecom"
    AUTOMOTIVE = "automotive"
    AEROSPACE = "aerospace"
    ENERGY = "energy"
    MANUFACTURING = "manufacturing"
    EDUCATION = "education"
    RETAIL = "retail"
    MEDIA = "media"
    GLOBAL_SCALE = "global_scale"


class SpecializedTargetsWorkingMemory:
    """
    In-memory working state for specialized target assessments.
    Covers all 50 modules from IoT Security through Global Scale Security.
    """

    def __init__(self, assessor_id: str = "", target_name: str = "",
                 target_category: str = "enterprise"):
        self.session_id = str(uuid.uuid4())
        self.assessor_id = assessor_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "assessor_id": assessor_id,
            "target_name": target_name,
            "target_category": target_category,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "methodology_applied": [],
        }

        self.target_inventory: dict[str, dict] = {}
        self.category_findings: dict[str, dict] = {}
        self.compliance_requirements: dict[str, dict] = {}
        self.specialized_tools: dict[str, dict] = {}
        self.risk_assessments: dict[str, dict] = {}
        self.remediation_plan: dict[str, dict] = {}
        self.category_knowledge: dict[str, dict] = {}

    def register_asset(self, asset_type: str, name: str,
                       version: Optional[str] = None,
                       firmware: Optional[str] = None,
                       protocols: Optional[list[str]] = None,
                       ports: Optional[list[int]] = None,
                       criticality: str = "medium",
                       network_segment: Optional[str] = None) -> str:
        """Register a target-specific asset."""
        asset_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.target_inventory[asset_id] = {
            "asset_id": asset_id,
            "asset_type": asset_type,
            "name": name,
            "version": version,
            "firmware": firmware,
            "configuration": {},
            "network_segment": network_segment,
            "protocols": protocols or [],
            "ports": ports or [],
            "status": "active",
            "criticality": criticality,
            "first_discovered": now,
            "last_verified": now,
        }

        return asset_id

    def update_asset_config(self, asset_id: str, config: dict) -> None:
        """Update asset configuration."""
        if asset_id in self.target_inventory:
            self.target_inventory[asset_id]["configuration"].update(config)

    def create_finding(self, finding_type: str, title: str, severity: str,
                       affected_asset: str, description: str = "",
                       impact: str = "", remediation: str = "",
                       compliance_impact: Optional[list[str]] = None,
                       cvss_estimate: float = 0) -> str:
        """Create a category-specific finding."""
        finding_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.category_findings[finding_id] = {
            "finding_id": finding_id,
            "finding_type": finding_type,
            "title": title,
            "severity": severity,
            "category": self.session_state["target_category"],
            "affected_asset": affected_asset,
            "description": description,
            "impact": impact,
            "remediation": remediation,
            "compliance_impact": compliance_impact or [],
            "cvss_estimate": cvss_estimate,
            "evidence_ids": [],
            "status": "draft",
        }

        return finding_id

    def add_compliance_requirement(self, framework: str,
                                    requirement_id: str,
                                    description: str) -> str:
        """Add a compliance requirement to track."""
        comp_id = str(uuid.uuid4())

        self.compliance_requirements[comp_id] = {
            "compliance_id": comp_id,
            "framework": framework,
            "requirement_id": requirement_id,
            "requirement_description": description,
            "assessment_status": "not_assessed",
            "evidence": [],
            "remediation_priority": "medium",
        }

        return comp_id

    def assess_compliance(self, compliance_id: str, status: str,
                          evidence: Optional[list[str]] = None) -> None:
        """Assess a compliance requirement."""
        self.compliance_requirements[compliance_id]["assessment_status"] = status
        if evidence:
            self.compliance_requirements[compliance_id]["evidence"] = evidence

    def register_tool(self, tool_name: str, tool_category: str,
                      purpose: str, configuration: Optional[dict] = None) -> str:
        """Register a specialized tool."""
        tool_id = str(uuid.uuid4())

        self.specialized_tools[tool_id] = {
            "tool_id": tool_id,
            "tool_name": tool_name,
            "tool_category": tool_category,
            "purpose": purpose,
            "target_category": self.session_state["target_category"],
            "configuration": configuration or {},
            "last_used": datetime.now(timezone.utc).isoformat(),
            "findings_generated": 0,
        }

        return tool_id

    def create_risk_assessment(self, risk_category: str,
                                likelihood: str, impact_level: str,
                                mitigation: str = "",
                                residual_risk: str = "") -> str:
        """Create a risk assessment entry."""
        assessment_id = str(uuid.uuid4())
        risk_level = self._calculate_risk_level(likelihood, impact_level)

        self.risk_assessments[assessment_id] = {
            "assessment_id": assessment_id,
            "risk_category": risk_category,
            "likelihood": likelihood,
            "impact": impact_level,
            "risk_level": risk_level,
            "mitigation": mitigation,
            "residual_risk": residual_risk,
            "assessment_date": datetime.now(timezone.utc).isoformat(),
        }

        return assessment_id

    def create_remediation(self, finding_id: str, remediation_type: str,
                            description: str, priority: int = 3,
                            estimated_effort: str = "unknown",
                            deadline: Optional[str] = None) -> str:
        """Create a remediation plan entry."""
        remediation_id = str(uuid.uuid4())

        self.remediation_plan[remediation_id] = {
            "remediation_id": remediation_id,
            "finding_id": finding_id,
            "remediation_type": remediation_type,
            "description": description,
            "prerequisites": [],
            "estimated_effort": estimated_effort,
            "priority": priority,
            "deadline": deadline,
            "status": "proposed",
        }

        return remediation_id

    def add_category_knowledge(self, topic: str, content: str,
                                source: str = "",
                                applicability: float = 0.8) -> str:
        """Add category-specific knowledge."""
        knowledge_id = str(uuid.uuid4())

        self.category_knowledge[knowledge_id] = {
            "knowledge_id": knowledge_id,
            "category": self.session_state["target_category"],
            "topic": topic,
            "content": content,
            "source": source,
            "applicability": applicability,
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }

        return knowledge_id

    def apply_methodology(self, methodology_name: str) -> None:
        """Record that a methodology has been applied."""
        if methodology_name not in self.session_state["methodology_applied"]:
            self.session_state["methodology_applied"].append(methodology_name)

    def get_target_summary(self) -> dict:
        """Get comprehensive summary of the specialized target assessment."""
        criticality_counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
        for asset in self.target_inventory.values():
            crit = asset["criticality"]
            if crit in criticality_counts:
                criticality_counts[crit] += 1

        severity_counts = {"critical": 0, "high": 0, "medium": 0, "low": 0}
        for finding in self.category_findings.values():
            sev = finding["severity"]
            if sev in severity_counts:
                severity_counts[sev] += 1

        compliance_summary = {"compliant": 0, "non_compliant": 0, "partial": 0, "not_assessed": 0}
        for comp in self.compliance_requirements.values():
            status = comp["assessment_status"]
            if status in compliance_summary:
                compliance_summary[status] += 1

        return {
            "session_id": self.session_id,
            "target_name": self.session_state["target_name"],
            "category": self.session_state["target_category"],
            "total_assets": len(self.target_inventory),
            "assets_by_criticality": criticality_counts,
            "total_findings": len(self.category_findings),
            "findings_by_severity": severity_counts,
            "compliance_requirements": len(self.compliance_requirements),
            "compliance_summary": compliance_summary,
            "tools_used": len(self.specialized_tools),
            "risk_assessments": len(self.risk_assessments),
            "methodologies_applied": self.session_state["methodology_applied"],
        }

    def get_compliance_report(self) -> dict:
        """Get compliance assessment report."""
        by_framework = {}
        for comp in self.compliance_requirements.values():
            fw = comp["framework"]
            if fw not in by_framework:
                by_framework[fw] = {"total": 0, "compliant": 0, "non_compliant": 0, "partial": 0}
            by_framework[fw]["total"] += 1
            status = comp["assessment_status"]
            if status in ["compliant", "non_compliant", "partial"]:
                by_framework[fw][status] += 1

        return {
            "frameworks_assessed": len(by_framework),
            "by_framework": by_framework,
            "overall_compliance": self._calculate_overall_compliance(),
        }

    def get_remediation_priority_list(self) -> list[dict]:
        """Get remediation items sorted by priority."""
        items = list(self.remediation_plan.values())
        return sorted(items, key=lambda x: x["priority"])

    def get_risk_matrix(self) -> dict:
        """Get risk assessment matrix."""
        matrix = {}
        for assessment in self.risk_assessments.values():
            likelihood = assessment["likelihood"]
            impact = assessment["impact"]
            key = f"{likelihood}:{impact}"
            matrix[key] = matrix.get(key, 0) + 1

        return {
            "total_risks": len(self.risk_assessments),
            "critical_risks": sum(1 for a in self.risk_assessments.values()
                                 if a["risk_level"] == "critical"),
            "high_risks": sum(1 for a in self.risk_assessments.values()
                             if a["risk_level"] == "high"),
            "matrix": matrix,
        }

    def export_assessment(self) -> dict:
        """Export all specialized assessment data."""
        return {
            "session": self.session_state,
            "inventory": list(self.target_inventory.values()),
            "findings": list(self.category_findings.values()),
            "compliance": list(self.compliance_requirements.values()),
            "tools": list(self.specialized_tools.values()),
            "risks": list(self.risk_assessments.values()),
            "remediation": list(self.remediation_plan.values()),
            "knowledge": list(self.category_knowledge.values()),
            "summary": self.get_target_summary(),
        }

    def _calculate_risk_level(self, likelihood: str, impact: str) -> str:
        """Calculate risk level from likelihood and impact."""
        likelihood_order = {"very_high": 5, "high": 4, "medium": 3, "low": 2, "very_low": 1}
        impact_order = {"catastrophic": 5, "critical": 4, "high": 3, "medium": 2, "low": 1}

        l_score = likelihood_order.get(likelihood, 3)
        i_score = impact_order.get(impact, 3)
        combined = l_score * i_score

        if combined >= 20:
            return "critical"
        elif combined >= 12:
            return "high"
        elif combined >= 6:
            return "medium"
        else:
            return "low"

    def _calculate_overall_compliance(self) -> float:
        """Calculate overall compliance percentage."""
        total = len(self.compliance_requirements)
        if total == 0:
            return 100.0

        compliant = sum(1 for c in self.compliance_requirements.values()
                       if c["assessment_status"] == "compliant")
        partial = sum(1 for c in self.compliance_requirements.values()
                     if c["assessment_status"] == "partial")

        return ((compliant + partial * 0.5) / total) * 100

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 86400:
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Target assets | 500 | LRU eviction | Category-specific asset types |
| Category findings | 200 | LRU eviction | Keep highest severity |
| Compliance requirements | 200 | Framework-based eviction | All tracked frameworks |
| Specialized tools | 50 | LRU eviction | Most-used preserved |
| Risk assessments | 100 | LRU eviction | Critical risks preserved |
| Remediation plans | 200 | Priority-based eviction | Keep high-priority |
| Knowledge entries | 300 | LRU eviction | High-applicability kept |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 24h.
  - Export to Long-Term Memory before eviction.

Priority 2: Low-Criticality Assets
  - Assets with criticality="low" evicted first when at capacity.
  - Critical and high assets preserved.

Priority 3: Resolved Findings
  - Findings with status="submitted" evicted after 7 days.

Priority 4: Low-Applicability Knowledge
  - Knowledge entries with applicability < 0.3 evicted after 14 days.
```

---

## Lifecycle

```
1. TARGET INITIALIZATION
   Register target category → register_asset() × N → build inventory

2. ASSESSMENT
   apply_methodology() → register_tool() × N → assess target
   create_finding() × N → add_compliance_requirement() × N

3. RISK ASSESSMENT
   create_risk_assessment() × N → build risk matrix
   assess_compliance() × N → compliance report

4. REMEDIATION PLANNING
   create_remediation() × N → get_remediation_priority_list()

5. EXPORT
   export_assessment() → save to Long-Term Memory
   cleanup_expired() → session data wiped
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Automation | Write | Asset lists for specialized scanning |
| Core Prompts Hunting | Read | Category-specific test guidance |
| Advanced Chaining | Read | Target inventory for chain construction |
| Report Writing | Write | Category findings for report content |

---

## Domain File References (Specialized-Targets/)

### 01-IoT-Device-Security
IoT device security assessment methodology.
Working memory stores: device inventory, firmware analysis, protocol testing.

### 02-ICS-SCADA-Security
Industrial Control Systems security assessment.
Working memory stores: OT network mapping, protocol analysis, safety implications.

### 03-Cloud-Infrastructure-Security
Cloud infrastructure security assessment methodology.
Working memory stores: cloud resources, IAM analysis, misconfiguration detection.

### 04-Mobile-Application-Security
Mobile application security assessment methodology.
Working memory stores: app analysis, API endpoints, platform-specific flaws.

### 05-Blockchain-Smart-Contract-Security
Blockchain smart contract security assessment.
Working memory stores: contract analysis, vulnerability patterns, exploit paths.

### 06-AI-ML-System-Security
AI/ML system security assessment methodology.
Working memory stores: model analysis, adversarial testing, data pipeline security.

### 07-API-Platform-Security
API platform security assessment methodology.
Working memory stores: API endpoints, authentication, rate limiting, data exposure.

### 08-Enterprise-Network-Security
Enterprise network security assessment methodology.
Working memory stores: network segments, access controls, monitoring gaps.

### 09-Healthcare-System-Security
Healthcare system security assessment methodology.
Working memory stores: HIPAA requirements, medical devices, PHI protection.

### 10-Financial-System-Security
Financial system security assessment methodology.
Working memory stores: PCI-DSS requirements, transaction security, fraud vectors.

### 11-Government-System-Security
Government system security assessment methodology.
Working memory stores: FedRAMP/FISMA requirements, classified data, insider threats.

### 12-Telecom-Infrastructure-Security
Telecom infrastructure security assessment methodology.
Working memory stores: telecom protocols, SS7/Diameter, signaling security.

### 13-Automotive-System-Security
Automotive system security assessment methodology.
Working memory stores: CAN bus, OBD-II, infotainment, V2X communication.

### 14-Aerospace-System-Security
Aerospace system security assessment methodology.
Working memory stores: avionics, ground systems, communication links.

### 15-Energy-Grid-Security
Energy grid security assessment methodology.
Working memory stores: SCADA/ICS, NERC CIP, power grid components.

### 16-Manufacturing-Security
Manufacturing system security assessment methodology.
Working memory stores: OT/IT convergence, production systems, supply chain.

### 17-Education-Platform-Security
Education platform security assessment methodology.
Working memory stores: student data, LMS systems, research data.

### 18-Retail-System-Security
Retail system security assessment methodology.
Working memory stores: POS systems, e-commerce, customer data, PCI compliance.

### 19-Media-Platform-Security
Media platform security assessment methodology.
Working memory stores: content delivery, DRM, user-generated content.

### 20-Global-Scale-System-Security
Global-scale system security assessment methodology.
Working memory stores: CDN, multi-region, global compliance, scale considerations.

### 21-Container-Orchestration-Security
Container orchestration (Kubernetes/Docker) security assessment.
Working memory stores: container configs, RBAC, network policies, secrets management.

### 22-Serverless-Architecture-Security
Serverless architecture security assessment methodology.
Working memory stores: function configs, event triggers, IAM roles, cold starts.

### 23-Microservices-Security
Microservices architecture security assessment.
Working memory stores: service mesh, inter-service auth, API gateways.

### 24-Data-Lake-Security
Data lake security assessment methodology.
Working memory stores: data classification, access controls, encryption.

### 25-Data-Warehouse-Security
Data warehouse security assessment methodology.
Working memory stores: query patterns, access controls, data masking.

### 26-Identity-and-Access-Management-Security
IAM system security assessment methodology.
Working memory stores: identity providers, SSO, MFA, privilege management.

### 26-Identity-and-Access-Management-Security
IAM system security assessment methodology.
Working memory stores: identity providers, SSO, MFA, privilege management.

### 27-Security-Operations-Center-Security
SOC security assessment methodology.
Working memory stores: SIEM configs, detection rules, response procedures.

### 28-Disaster-Recovery-Security
Disaster recovery security assessment methodology.
Working memory stores: backup systems, failover, RTO/RPO.

### 29-Physical-Security-Integration
Physical security integration with cybersecurity assessment.
Working memory stores: physical access controls, badge systems, surveillance.

### 30-Supply-Chain-Security
Supply chain security assessment methodology.
Working memory stores: vendor assessments, SBOM analysis, dependency risks.

### 31-Third-Party-Integration-Security
Third-party integration security assessment.
Working memory stores: API integrations, OAuth scopes, data sharing.

### 32-Legacy-System-Security
Legacy system security assessment methodology.
Working memory stores: legacy protocols, compatibility risks, migration paths.

### 33-Embedded-System-Security
Embedded system security assessment methodology.
Working memory stores: firmware analysis, hardware interfaces, debug ports.

### 34-Wireless-Network-Security
Wireless network security assessment methodology.
Working memory stores: WiFi configs, Bluetooth, Zigbee, LoRa.

### 35-Satellite-Communication-Security
Satellite communication security assessment.
Working memory stores: satellite protocols, ground stations, link security.

### 36-Maritime-System-Security
Maritime system security assessment methodology.
Working memory stores: ship systems, navigation, communication.

### 37-Rail-System-Security
Rail system security assessment methodology.
Working memory stores: signaling systems, train control, passenger systems.

### 38-Water-Treatment-Security
Water treatment facility security assessment.
Working memory stores: SCADA systems, chemical controls, safety systems.

### 39-Nuclear-Facility-Security
Nuclear facility security assessment methodology.
Working memory stores: safety systems, access controls, regulatory compliance.

### 40-Defense-System-Security
Defense system security assessment methodology.
Working memory stores: classified systems, COMSEC, TEMPEST.

### 41-Broadcast-System-Security
Broadcast system security assessment methodology.
Working memory stores: broadcast infrastructure, content delivery, DRM.

### 42-Streaming-Platform-Security
Streaming platform security assessment methodology.
Working memory stores: CDN, DRM, content protection, account security.

### 43-Gaming-Platform-Security
Gaming platform security assessment methodology.
Working memory stores: game servers, anti-cheat, in-game economy.

### 44-Social-Platform-Security
Social platform security assessment methodology.
Working memory stores: user data, content moderation, API access.

### 45-Messaging-Platform-Security
Messaging platform security assessment methodology.
Working memory stores: E2E encryption, metadata, group management.

### 46-E-Commerce-Platform-Security
E-commerce platform security assessment methodology.
Working memory stores: payment processing, inventory, customer data.

### 47-SaaS-Platform-Security
SaaS platform security assessment methodology.
Working memory stores: multi-tenancy, data isolation, tenant management.

### 48-VPN-and-Remote-Access-Security
VPN and remote access security assessment methodology.
Working memory stores: VPN configs, authentication, tunnel security.

### 49-DNS-and-Infrastructure-Security
DNS and core infrastructure security assessment.
Working memory stores: DNS configs, BGP, peering, DDoS protection.

### 50-Global-Scale-System-Security (Duplicate reference for 50th file)
Global-scale distributed system security assessment.
Working memory stores: global architecture, consistency models, failure modes.
