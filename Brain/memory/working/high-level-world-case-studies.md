# Working Memory: High-Level World Case Studies Domain

## Domain Mapping

| Field | Value |
|-------|-------|
| Domain ID | `CASE-WORLD-001` |
| Root Folder | `High-Level-World-Case-Studies/` |
| Total Files | 46 |
| Memory Type | Short-term / Ephemeral |
| Storage Backend | In-memory dict + pattern index |
| Typical Lifetime | Analysis session (1-3h) |
| Eviction Trigger | Case completion, session end, or 48h TTL |

---

## Overview

Working memory for high-level world case studies captures the analytical state
of studying real-world security incidents and breaches. This spans 46 modules
covering critical infrastructure breaches through post-mortem analysis. Working
memory tracks:

- **Current case**: Which case study is being analyzed and what stage of
  analysis is in progress.
- **Extracted patterns**: Attack patterns, techniques, and procedures (TTPs)
  extracted from each case for application to current targets.
- **MITRE ATT&CK mappings**: Techniques mapped to the MITRE framework for
  systematic tracking and comparison.
- **Timeline reconstruction**: The chronological sequence of events in each
  case, from initial compromise to discovery.
- **Key findings**: Critical lessons learned and actionable insights from
  each case.
- **Cross-case correlations**: Patterns that appear across multiple cases,
  indicating common attack vectors or defensive gaps.
- **Applicability assessment**: How each case's lessons apply to current
  targets and hunting strategies.

This is the "case study brain" that transforms raw case information into
actionable intelligence for security testing.

---

## Data Schema (YAML)

```yaml
working_memory_case_studies:
  version: "1.6"
  scope: "analysis-session"
  ttl_seconds: 172800

  session_state:
    session_id: "string (uuid4)"
    analyst_id: "string"
    started_at: "ISO8601"
    last_activity: "ISO8601"
    status: "enum(active|paused|completed)"
    current_case_id: "string (nullable)"
    cases_analyzed: "integer"
    patterns_extracted: "integer"

  case_analyses:
    case_id: "string (uuid4)"
    case_number: "integer (5-50)"
    case_name: "string"
    case_file: "string (source .md file)"
    category: "enum(critical_infrastructure|data_breach|apt|ransomware|insider|supply_chain|nation_state|financial|healthcare|government)"
    severity: "enum(catastrophic|critical|high|medium)"
    analyzed_at: "ISO8601"
    completed: "boolean"
    analysis_depth: "enum(surface|detailed|comprehensive)"

  attack_patterns:
    pattern_id: "string (uuid4)"
    case_id: "string"
    pattern_name: "string"
    description: "string"
    ttps: "list[string] (MITRE technique IDs)"
    kill_chain_phase: "string"
    difficulty: "enum(easy|medium|hard|advanced)"
    applicability: "enum(highly_applicable|moderately_applicable|low_applicability|not_applicable)"
    detection_difficulty: "enum(trivial|easy|moderate|hard|very_hard)"
    effectiveness_score: "float (0.0-1.0)"

  mitre_mappings:
    mapping_id: "string (uuid4)"
    case_id: "string"
    technique_id: "string (e.g., T1566)"
    technique_name: "string"
    tactic: "string"
    sub_techniques: "list[string]"
    observed: "boolean"
    evidence: "string"
    frequency_across_cases: "integer"

  timeline_events:
    event_id: "string (uuid4)"
    case_id: "string"
    timestamp: "ISO8601 (estimated)"
    event_order: "integer"
    phase: "string (initial_access|execution|persistence|privilege_escalation|defense_evasion|credential_access|discovery|lateral_movement|collection|exfiltration|impact)"
    description: "string"
    actor_action: "string"
    defender_response: "string (nullable)"
    ioc: "list[string]"

  key_findings:
    finding_id: "string (uuid4)"
    case_id: "string"
    category: "enum(prevention_failure|detection_failure|response_failure|architectural_weakness|human_factor|tool_limitation)"
    description: "string"
    lesson_learned: "string"
    actionable_recommendation: "string"
    applicability_to_current: "enum(direct|indirect|limited|none)"

  cross_case_correlations:
    correlation_id: "string (uuid4)"
    pattern_name: "string"
    case_ids: "list[string]"
    common_elements: "list[string]"
    frequency: "integer"
    risk_level: "enum(critical|high|medium|low)"
    hunting_recommendation: "string"

  applicability_assessment:
    target_id: "string"
    case_id: "string"
    relevance_score: "float (0.0-1.0)"
    applicable_techniques: "list[string]"
    applicable_defenses: "list[string]"
    gaps_identified: "list[string]"
```

---

## Read/Write Operations

```python
import uuid
from datetime import datetime, timezone
from typing import Optional
from enum import Enum


class CaseCategory(Enum):
    CRITICAL_INFRASTRUCTURE = "critical_infrastructure"
    DATA_BREACH = "data_breach"
    APT = "apt"
    RANSOMWARE = "ransomware"
    INSIDER = "insider"
    SUPPLY_CHAIN = "supply_chain"
    NATION_STATE = "nation_state"
    FINANCIAL = "financial"
    HEALTHCARE = "healthcare"
    GOVERNMENT = "government"


class AnalysisDepth(Enum):
    SURFACE = "surface"
    DETAILED = "detailed"
    COMPREHENSIVE = "comprehensive"


class CaseStudiesWorkingMemory:
    """
    In-memory working state for high-level case study analysis.
    Covers all 46 modules from Critical Infrastructure through Post-Mortem.
    """

    def __init__(self, analyst_id: str = ""):
        self.session_id = str(uuid.uuid4())
        self.analyst_id = analyst_id
        self.created_at = datetime.now(timezone.utc)

        self.session_state = {
            "session_id": self.session_id,
            "analyst_id": analyst_id,
            "started_at": datetime.now(timezone.utc).isoformat(),
            "last_activity": datetime.now(timezone.utc).isoformat(),
            "status": "active",
            "current_case_id": None,
            "cases_analyzed": 0,
            "patterns_extracted": 0,
        }

        self.case_analyses: dict[str, dict] = {}
        self.attack_patterns: dict[str, dict] = {}
        self.mitre_mappings: dict[str, dict] = {}
        self.timeline_events: dict[str, dict] = {}
        self.key_findings: dict[str, dict] = {}
        self.cross_case_correlations: dict[str, dict] = {}
        self.applicability_assessments: dict[str, dict] = {}

    def register_case(self, case_number: int, case_name: str,
                      case_file: str, category: str = "data_breach",
                      severity: str = "high") -> str:
        """Register a case study for analysis."""
        case_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.case_analyses[case_id] = {
            "case_id": case_id,
            "case_number": case_number,
            "case_name": case_name,
            "case_file": case_file,
            "category": category,
            "severity": severity,
            "analyzed_at": now,
            "completed": False,
            "analysis_depth": AnalysisDepth.SURFACE.value,
        }

        return case_id

    def start_case_analysis(self, case_id: str,
                            depth: str = "detailed") -> None:
        """Begin analyzing a case study."""
        self.case_analyses[case_id]["analysis_depth"] = depth
        self.session_state["current_case_id"] = case_id

    def extract_pattern(self, case_id: str, pattern_name: str,
                        description: str, ttps: Optional[list[str]] = None,
                        kill_chain_phase: str = "unknown",
                        difficulty: str = "medium",
                        applicability: str = "moderately_applicable") -> str:
        """Extract an attack pattern from a case study."""
        pattern_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.attack_patterns[pattern_id] = {
            "pattern_id": pattern_id,
            "case_id": case_id,
            "pattern_name": pattern_name,
            "description": description,
            "ttps": ttps or [],
            "kill_chain_phase": kill_chain_phase,
            "difficulty": difficulty,
            "applicability": applicability,
            "detection_difficulty": "moderate",
            "effectiveness_score": 0.5,
        }

        self.session_state["patterns_extracted"] += 1
        return pattern_id

    def map_mitre_technique(self, case_id: str, technique_id: str,
                            technique_name: str, tactic: str,
                            sub_techniques: Optional[list[str]] = None,
                            evidence: str = "") -> str:
        """Map a case event to a MITRE ATT&CK technique."""
        mapping_id = str(uuid.uuid4())

        self.mitre_mappings[mapping_id] = {
            "mapping_id": mapping_id,
            "case_id": case_id,
            "technique_id": technique_id,
            "technique_name": technique_name,
            "tactic": tactic,
            "sub_techniques": sub_techniques or [],
            "observed": True,
            "evidence": evidence,
            "frequency_across_cases": 1,
        }

        return mapping_id

    def add_timeline_event(self, case_id: str, event_order: int,
                           phase: str, description: str,
                           actor_action: str,
                           defender_response: Optional[str] = None,
                           iocs: Optional[list[str]] = None,
                           timestamp: Optional[str] = None) -> str:
        """Add a timeline event to a case study."""
        event_id = str(uuid.uuid4())
        now = datetime.now(timezone.utc).isoformat()

        self.timeline_events[event_id] = {
            "event_id": event_id,
            "case_id": case_id,
            "timestamp": timestamp or now,
            "event_order": event_order,
            "phase": phase,
            "description": description,
            "actor_action": actor_action,
            "defender_response": defender_response,
            "ioc": iocs or [],
        }

        return event_id

    def record_key_finding(self, case_id: str, category: str,
                           description: str, lesson_learned: str,
                           recommendation: str,
                           applicability: str = "indirect") -> str:
        """Record a key finding from a case study."""
        finding_id = str(uuid.uuid4())

        self.key_findings[finding_id] = {
            "finding_id": finding_id,
            "case_id": case_id,
            "category": category,
            "description": description,
            "lesson_learned": lesson_learned,
            "actionable_recommendation": recommendation,
            "applicability_to_current": applicability,
        }

        return finding_id

    def complete_case_analysis(self, case_id: str) -> None:
        """Mark a case analysis as completed."""
        self.case_analyses[case_id]["completed"] = True
        self.session_state["cases_analyzed"] += 1
        self.session_state["current_case_id"] = None

    def find_cross_case_correlations(self) -> list[dict]:
        """Identify patterns that appear across multiple cases."""
        technique_frequency: dict[str, list[str]] = {}

        for mapping in self.mitre_mappings.values():
            tid = mapping["technique_id"]
            if tid not in technique_frequency:
                technique_frequency[tid] = []
            if mapping["case_id"] not in technique_frequency[tid]:
                technique_frequency[tid].append(mapping["case_id"])

        correlations = []
        for tid, case_ids in technique_frequency.items():
            if len(case_ids) >= 2:
                corr_id = str(uuid.uuid4())
                self.cross_case_correlations[corr_id] = {
                    "correlation_id": corr_id,
                    "pattern_name": f"Technique {tid}",
                    "case_ids": case_ids,
                    "common_elements": [tid],
                    "frequency": len(case_ids),
                    "risk_level": "high" if len(case_ids) >= 4 else "medium",
                    "hunting_recommendation": f"Prioritize testing for {tid}",
                }
                correlations.append(self.cross_case_correlations[corr_id])

        return correlations

    def assess_applicability(self, target_id: str, case_id: str,
                              relevant_techniques: Optional[list[str]] = None) -> str:
        """Assess how applicable a case's lessons are to a current target."""
        assessment_id = str(uuid.uuid4())

        case_patterns = [
            p for p in self.attack_patterns.values()
            if p["case_id"] == case_id
        ]
        high_applicability = sum(1 for p in case_patterns
                                if p["applicability"] == "highly_applicable")

        self.applicability_assessments[assessment_id] = {
            "target_id": target_id,
            "case_id": case_id,
            "relevance_score": min(1.0, high_applicability / max(len(case_patterns), 1)),
            "applicable_techniques": relevant_techniques or [],
            "applicable_defenses": [],
            "gaps_identified": [],
        }

        return assessment_id

    def get_case_summary(self, case_id: str) -> dict:
        """Get comprehensive summary of a case analysis."""
        case = self.case_analyses.get(case_id, {})
        patterns = [p for p in self.attack_patterns.values() if p["case_id"] == case_id]
        mitre = [m for m in self.mitre_mappings.values() if m["case_id"] == case_id]
        timeline = sorted(
            [e for e in self.timeline_events.values() if e["case_id"] == case_id],
            key=lambda e: e["event_order"]
        )
        findings = [f for f in self.key_findings.values() if f["case_id"] == case_id]

        return {
            "case": case,
            "patterns_count": len(patterns),
            "mitre_techniques": len(mitre),
            "timeline_events": len(timeline),
            "key_findings_count": len(findings),
            "tactics_covered": list(set(m["tactic"] for m in mitre)),
        }

    def get_threat_intelligence(self) -> dict:
        """Get aggregated threat intelligence from all analyzed cases."""
        all_techniques = {}
        for mapping in self.mitre_mappings.values():
            tid = mapping["technique_id"]
            if tid not in all_techniques:
                all_techniques[tid] = {
                    "technique_id": tid,
                    "name": mapping["technique_name"],
                    "tactic": mapping["tactic"],
                    "frequency": 0,
                    "cases": [],
                }
            all_techniques[tid]["frequency"] += 1
            if mapping["case_id"] not in all_techniques[tid]["cases"]:
                all_techniques[tid]["cases"].append(mapping["case_id"])

        return {
            "total_cases_analyzed": self.session_state["cases_analyzed"],
            "total_patterns": self.session_state["patterns_extracted"],
            "unique_techniques": len(all_techniques),
            "top_techniques": sorted(
                all_techniques.values(),
                key=lambda t: t["frequency"],
                reverse=True
            )[:10],
            "tactics_distribution": self._get_tactic_distribution(),
        }

    def _get_tactic_distribution(self) -> dict:
        """Get distribution of techniques across MITRE tactics."""
        dist = {}
        for mapping in self.mitre_mappings.values():
            tactic = mapping["tactic"]
            dist[tactic] = dist.get(tactic, 0) + 1
        return dist

    def get_hunting_recommendations(self) -> list[dict]:
        """Generate hunting recommendations based on case analysis."""
        recommendations = []

        correlations = self.find_cross_case_correlations()
        for corr in correlations:
            if corr["risk_level"] in ["critical", "high"]:
                recommendations.append({
                    "type": "technique_priority",
                    "pattern": corr["pattern_name"],
                    "risk_level": corr["risk_level"],
                    "recommendation": corr["hunting_recommendation"],
                    "cases_evidence": len(corr["case_ids"]),
                })

        high_impact_findings = [
            f for f in self.key_findings.values()
            if f["applicability_to_current"] in ["direct", "indirect"]
        ]

        for finding in high_impact_findings[:5]:
            recommendations.append({
                "type": "lesson_application",
                "lesson": finding["lesson_learned"],
                "recommendation": finding["actionable_recommendation"],
            })

        return recommendations

    def export_analysis(self) -> dict:
        """Export all case study analysis data."""
        return {
            "session": self.session_state,
            "cases": list(self.case_analyses.values()),
            "patterns": list(self.attack_patterns.values()),
            "mitre_mappings": list(self.mitre_mappings.values()),
            "timeline_events": list(self.timeline_events.values()),
            "key_findings": list(self.key_findings.values()),
            "correlations": list(self.cross_case_correlations.values()),
            "threat_intelligence": self.get_threat_intelligence(),
            "hunting_recommendations": self.get_hunting_recommendations(),
        }

    def cleanup_expired(self) -> int:
        """Remove session data older than TTL."""
        now = datetime.now(timezone.utc)
        started = datetime.fromisoformat(self.session_state["started_at"])
        if (now - started).total_seconds() > 172800:
            return 1
        return 0
```

---

## Capacity Management

| Resource | Default Limit | Eviction Trigger | Notes |
|----------|---------------|------------------|-------|
| Case analyses | 46 | Module count limit | All available cases |
| Attack patterns per case | 50 | FIFO eviction | Key patterns preserved |
| MITRE mappings | 500 | LRU eviction | Dedup by technique+case |
| Timeline events per case | 100 | FIFO eviction | Critical events preserved |
| Key findings per case | 20 | FIFO eviction | High-impact findings kept |
| Cross-case correlations | 200 | Frequency-based eviction | Keep high-frequency |

---

## Eviction Policy

```
Priority 1: TTL Expiry
  - Session expires after 48h.
  - Export data to Long-Term Memory before eviction.

Priority 2: Low-Applicability Patterns
  - Patterns with applicability="not_applicable" evicted after 7 days.

Priority 3: Single-Case Patterns
  - Patterns appearing in only 1 case evicted when capacity exceeded.
  - Cross-case patterns preserved.

Priority 4: Timeline Event Compression
  - Old timeline events compressed into phase summaries when over limit.
```

---

## Lifecycle

```
1. CASE REGISTRATION
   register_case() × N → case catalog built

2. ACTIVE ANALYSIS
   start_case_analysis() → extract_pattern() × N → map_mitre_technique() × N
   add_timeline_event() × N → record_key_finding() × N
   complete_case_analysis()

3. CROSS-CASE ANALYSIS
   find_cross_case_correlations() → identify common patterns
   assess_applicability() × N → prioritize techniques

4. INTELLIGENCE GENERATION
   get_threat_intelligence() → aggregate patterns
   get_hunting_recommendations() → actionable guidance

5. EXPORT AND CLEANUP
   export_analysis() → save to Long-Term Memory
   cleanup_expired() → session data wiped
```

---

## Integration with Other Memory Components

| Component | Direction | Data Exchanged |
|-----------|-----------|----------------|
| Advanced Chaining | Read | Attack patterns for chain construction |
| Core Prompts Hunting | Read | MITRE mappings for test prioritization |
| Recon Deep Dive | Read | Target info for applicability assessment |
| Report Writing | Write | Case-derived lessons for report context |

---

## Domain File References (High-Level-World-Case-Studies/)

### 05-Critical-Infrastructure-Breach
Analysis of critical infrastructure security breaches.
Working memory stores: ICS/SCADA attack patterns, OT-specific TTPs, defense gaps.

### 06-Large-Scale-Data-Breach
Analysis of large-scale data breach incidents.
Working memory stores: data exfiltration methods, detection failures, impact scope.

### 07-Advanced-Persistent-Threat
Analysis of APT group operations and campaigns.
Working memory stores: APT TTPs, tooling, infrastructure, targeting patterns.

### 08-Ransomware-Attack-Analysis
Analysis of major ransomware attacks.
Working memory stores: initial access, lateral movement, encryption methods, negotiation.

### 09-Insider-Threat-Incident
Analysis of insider threat incidents.
Working memory stores: motivation patterns, detection methods, prevention gaps.

### 10-Supply-Chain-Attack
Analysis of supply chain compromise incidents.
Working memory stores: compromise vectors, distribution methods, detection challenges.

### 11-Nation-State-Cyber-Operation
Analysis of nation-state cyber operations.
Working memory stores: state-sponsored TTPs, infrastructure, targeting, attribution.

### 12-Financial-Sector-Breach
Analysis of financial sector security incidents.
Working memory stores: financial attack vectors, fraud patterns, regulatory implications.

### 13-Healthcare-Security-Incident
Analysis of healthcare sector security incidents.
Working memory stores: medical device attacks, PHI exposure, HIPAA implications.

### 14-Government-Security-Breach
Analysis of government sector security incidents.
Working memory stores: government-specific vectors, classification impacts, nation-state targeting.

### 15-Cloud-Infrastructure-Breach
Analysis of cloud infrastructure security incidents.
Working memory stores: cloud misconfigurations, shared responsibility gaps, lateral movement.

### 16-Mobile-Platform-Attack
Analysis of mobile platform security attacks.
Working memory stores: mobile malware, zero-days, app store compromise, spyware.

### 17-IoT-Botnet-Attack
Analysis of IoT botnet attacks (Mirai and variants).
Working memory stores: default credential exploitation, DDoS methods, propagation.

### 18-DNS-Hijacking-Campaign
Analysis of DNS hijacking campaigns.
Working memory stores: DNS manipulation techniques, persistence methods, detection.

### 19-SSL-TLS-Exploitation
Analysis of SSL/TLS exploitation incidents.
Working memory stores: certificate attacks, downgrade attacks, implementation flaws.

### 20-WAF-Bypass-Campaigns
Analysis of WAF bypass campaigns.
Working memory stores: bypass techniques, WAF weaknesses, evasion methods.

### 21-API-Security-Breach
Analysis of API security breaches.
Working memory stores: API attack vectors, authentication flaws, data exposure.

### 22-Container-Escape-Incident
Analysis of container escape incidents.
Working memory stores: container vulnerabilities, escape techniques, Kubernetes attacks.

### 23-Serverless-Function-Abuse
Analysis of serverless function abuse incidents.
Working memory stores: serverless attack vectors, cold start exploitation, event injection.

### 24-Machine-Learning-Model-Theft
Analysis of machine learning model theft incidents.
Working memory stores: model extraction techniques, intellectual property theft.

### 25-Artificial-Intelligence-System-Compromise
Analysis of AI system compromise incidents.
Working memory stores: adversarial ML, data poisoning, model manipulation.

### 26-Blockchain-Smart-Contract-Exploit
Analysis of blockchain smart contract exploits.
Working memory stores: reentrancy, flash loans, oracle manipulation, governance attacks.

### 27-Cryptocurrency-Exchange-Breach
Analysis of cryptocurrency exchange breaches.
Working memory stores: hot wallet theft, social engineering, insider threats.

### 28-Social-Engineering-Campaign
Analysis of social engineering campaigns.
Working memory stores: pretexting techniques, psychological vectors, bypass methods.

### 29-Phishing-Infrastructure-Analysis
Analysis of phishing infrastructure operations.
Working memory stores: phishing kit patterns, infrastructure management, evasion.

### 30-Spear-Phishing-Attack-Chain
Analysis of spear phishing attack chains.
Working memory stores: targeting methods, payload delivery, post-exploitation.

### 31-CEO-Fraud-Incident
Analysis of CEO fraud / BEC incidents.
Working memory stores: impersonation techniques, wire fraud patterns, prevention.

### 32-Credential-Stuffing-Campaign
Analysis of credential stuffing campaigns.
Working memory stores: credential sources, automation methods, detection evasion.

### 33-Password-Spraying-Attack
Analysis of password spraying attacks.
Working memory stores: password lists, targeting methods, lockout evasion.

### 34-MFA-Bypass-Incident
Analysis of MFA bypass incidents.
Working memory stores: bypass techniques, MFA weaknesses, phishing MFA.

### 35-Session-Hijacking-Attack
Analysis of session hijacking attacks.
Working memory stores: session theft methods, fixation, token manipulation.

### 36-Subdomain-Takeover-Campaign
Analysis of subdomain takeover campaigns.
Working memory stores: CNAME abuse, service migration gaps, takeover methods.

### 37-Domain-Fronting-Campaign
Analysis of domain fronting campaigns.
Working memory stores: CDN abuse, traffic laundering, detection methods.

### 38-CDN-Abuse-Incident
Analysis of CDN abuse incidents.
Working memory stores: CDN vulnerabilities, abuse patterns, mitigation.

### 39-Cloud-Metadata-Exploitation
Analysis of cloud metadata service exploitation.
Working memory stores: SSRF to metadata, credential theft, IMDSv2 bypass.

### 40-Kubernetes-Cluster-Breach
Analysis of Kubernetes cluster breaches.
Working memory stores: API server exposure, pod escape, RBAC bypass.

### 41-Docker-Daemon-Exploitation
Analysis of Docker daemon exploitation.
Working memory stores: exposed daemon attacks, container escape, resource abuse.

### 42-Server-Side-Request-Forgery-Campaign
Analysis of SSRF exploitation campaigns.
Working memory stores: SSRF vectors, internal network access, cloud metadata.

### 43-XML-External-Entity-Campaign
Analysis of XXE exploitation campaigns.
Working memory stores: XXE vectors, file read, SSRF escalation, blind extraction.

### 44-Deserialization-Attack-Campaign
Analysis of insecure deserialization campaigns.
Working memory stores: deserialization gadgets, RCE chains, framework-specific.

### 45-HTTP-Request-Smuggling-Campaign
Analysis of HTTP request smuggling campaigns.
Working memory stores: smuggling techniques, cache poisoning, credential theft.

### 46-Post-Mortem-Analysis
Post-mortem analysis methodology and frameworks.
Working memory stores: incident analysis frameworks, root cause analysis, lessons learned.
