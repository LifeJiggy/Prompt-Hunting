# Memory Index: High-Level-World-Case-Studies

**Domain Mapping:** `High-Level-World-Case-Studies/`

## Overview

The memory index for high-level case studies enables fast retrieval of analyzed incidents by category, attack vector, severity, MITRE technique, and target similarity. With 46 documented case studies spanning critical infrastructure, zero-days, supply chain attacks, and multi-stage chains, an efficient index is essential for finding relevant historical precedents during active hunting.

The index supports multiple query patterns: finding cases similar to a current target, searching by attack technique, filtering by impact severity, and discovering cases that share common patterns with a new finding. Each indexed entry includes metadata extracted during case analysis — attack vectors, TTPs, impact assessment, and defensive recommendations.

## Index Schema

```yaml
index_entry:
  case_id: "case_{file_number}"
  filename: "05-Critical-Infrastructure-Breach.md"
  title: "Critical Infrastructure Breach"

  # Categorization
  categories:
    - "critical_infrastructure"
    - "ransomware"
    - "scada"
  subcategories: ["power_grid", "water_treatment"]

  # Attack Vectors
  attack_vectors:
    - technique: "phishing"
      mitre_id: "T1566"
    - technique: "lateral_movement"
      mitre_id: "T1021"
    - technique: "ransomware_deployment"
      mitre_id: "T1486"

  # Severity
  severity: "critical"
  impact_score: 9.5
  financial_impact: "$4.4M ransom"
  affected_users: "millions"

  # Target Similarity
  target_profiles: ["energy", "utilities", "government", "healthcare"]
  technology_overlap: ["scada", "modbus", "dnp3", "windows"]

  # Temporal
  incident_date: "2021-05"
  analysis_date: "2025-01"
  disclosure_status: "public"

  # Cross-references
  related_cases: ["case_21", "case_37"]
  related_vulns: ["ransomware", "phishing", "lateral_movement"]
```

## Index Types

| Index | Structure | Query Pattern |
|-------|----------|---------------|
| **Category** | Inverted index | Find cases by category (e.g., all cloud cases) |
| **MITRE** | Technique → cases | Find cases using specific ATT&CK technique |
| **Severity** | Sorted list | Find highest-impact cases |
| **Target Profile** | Profile → cases | Find cases similar to current target |
| **Temporal** | Time-sorted | Find recent or historical cases |
| **Cross-reference** | Graph edges | Find related cases |

## Query API

```python
def find_cases_by_category(index, category):
    """Find all cases in a specific category."""
    return index.query(category_index, category)

def find_cases_by_mitre(index, technique_id):
    """Find cases using a specific MITRE ATT&CK technique."""
    return index.query(mitre_index, technique_id)

def find_similar_cases(index, target_profile):
    """Find cases similar to the current target."""
    return index.query(target_profile_index, target_profile, top_k=5)

def find_cases_by_severity(index, min_severity="high"):
    """Find cases above a severity threshold."""
    severity_order = {"info": 0, "low": 1, "medium": 2, "high": 3, "critical": 4}
    return index.query_sorted(severity_index, min_value=severity_order[min_severity])

def find_related_cases(index, case_id):
    """Find cases related to a specific case."""
    return index.query_graph(cross_reference_index, case_id)
```

## Domain File References

All 46 files in `High-Level-World-Case-Studies/` are indexed:

**Critical Infrastructure (05, 21-23, 28-29):** `05-Critical-Infrastructure-Breach.md` indexed under critical_infrastructure, ransomware, scada. `21-Cloud-Configuration-Error.md` indexed under cloud, misconfiguration, iam. `22-Container-Escape-Case-Study.md` indexed under container, escape, docker, kubernetes. `23-IoT-Device-Compromise.md` indexed under iot, botnet, firmware. `28-Network-Infrastructure-Attack.md` indexed under network, router, backbone. `29-Database-Compromise-Case.md` indexed under database, sqli, nosql.

**Vulnerability Research (06-07):** `06-Zero-Day-Exploitation-Case.md` indexed under zero_day, unknown_cve, APT. `07-Chain-of-Vulnerabilities.md` indexed under chaining, multi_step, amplification.

**Impact and Timeline (08-09, 14, 50):** `08-Real-World-Impact-Assessment.md` indexed under impact, financial, reputational. `09-Timeline-from-Discovery-to-Fix.md` indexed under timeline, patch_management, disclosure. `14-Disclosure-Timeline-Study.md` indexed under disclosure, responsible, coordinated. `50-Post-Mortem-Analysis.md` indexed under post_mortem, lessons_learned, review.

**Program Dynamics (10-13, 15-16):** `10-Reward-Maximization-Strategies.md` indexed under bounty, reward, strategy. `11-Report-Quality-Analysis.md` indexed under report, quality, acceptance. `12-Triage-Process-Understanding.md` indexed under triage, process, evaluation. `13-Program-Response-Analysis.md` indexed under program, response, behavior. `15-Collaborative-Hunting-Case.md` indexed under collaboration, team, partnership. `16-Cross-Program-Vulnerability-Patterns.md` indexed under patterns, recurring, cross_program.

**Industry Cases (17-20, 24-25):** `17-Industry-Specific-Findings.md` indexed under healthcare, finance, government. `18-Mobile-App-Vulnerability-Case.md` indexed under mobile, ios, android. `19-Web-Application-Security-Case.md` indexed under web, application, xss, sqli. `20-API-Security-Breach-Analysis.md` indexed under api, rest, graphql. `24-Blockchain-Smart-Contract-Bug.md` indexed under blockchain, solidity, reentrancy. `25-Cryptocurrency-Exchange-Hack.md` indexed under cryptocurrency, exchange, wallet.

**Attack Techniques (26-27, 30-38):** `26-Social-Engineering-Success.md` indexed under social_engineering, phishing, pretexting. `27-Physical-Security-Bypass.md` indexed under physical, access_control, tailgating. `30-File-System-Attack-Analysis.md` indexed under file_system, traversal, inclusion. `31-Authentication-Bypass-Case.md` indexed under authentication, bypass, session. `32-Authorization-Flaw-Study.md` indexed under authorization, idor, privilege_escalation. `33-Session-Management-Issue.md` indexed under session, fixation, hijacking. `34-Input-Validation-Failure.md` indexed under input_validation, injection. `35-Business-Logic-Flaw-Analysis.md` indexed under business_logic, workflow, price. `36-Information-Disclosure-Case.md` indexed under information_disclosure, leak. `37-Weak-Cryptography-Example.md` indexed under cryptography, weak_hash, deprecated. `38-Insecure-Communication-Study.md` indexed under communication, mitm, downgrade.

**Advanced Attacks (39-49):** `39-Third-Party-Component-Vulnerability.md` indexed under supply_chain, dependency, third_party. `40-Supply-Chain-Attack-Case.md` indexed under supply_chain, solarwinds, compromise. `41-Zero-Trust-Bypass-Analysis.md` indexed under zero_trust, bypass, architecture. `42-Multi-Factor-Authentication-Bypass.md` indexed under mfa, bypass, 2fa. `43-Privilege-Escalation-Case.md` indexed under privilege_escalation, kernel, service. `44-Lateral-Movement-Study.md` indexed under lateral_movement, pivot, network. `45-Data-Exfiltration-Method.md` indexed under exfiltration, data_theft, theft. `46-Persistence-Mechanism-Analysis.md` indexed under persistence, backdoor, rootkit. `47-Anti-Forensic-Technique-Study.md` indexed under anti_forensic, evasion, cleanup. `48-Incident-Response-Failure.md` indexed under incident_response, IR, response. `49-Compliance-Violation-Case.md` indexed under compliance, violation, regulatory.

## Integration

- **Working memory** loads relevant cases based on target similarity
- **Long-term storage** persists case analyses and extracted patterns
- **Consolidation** merges related cases and updates cross-references
