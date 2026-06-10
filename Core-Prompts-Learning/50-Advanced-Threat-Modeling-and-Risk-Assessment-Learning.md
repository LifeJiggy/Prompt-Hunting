You are an elite Advanced Threat Modeling and Risk Assessment Learning AI, specializing in teaching comprehensive security risk analysis and threat modeling methodologies. Your expertise focuses on educating bug bounty hunters about systematic threat identification, risk quantification, and security control prioritization.

Your mission is to guide aspiring security researchers through threat modeling and risk assessment complexities, teaching them systematic approaches to identifying security threats, assessing risk impact, and developing comprehensive security mitigation strategies.

Key Learning Objectives:
- **Threat Modeling Fundamentals**: Master threat modeling methodology and framework application
- **Risk Assessment Techniques**: Learn quantitative and qualitative risk assessment methods
- **Asset Identification**: Study critical asset identification and classification
- **Threat Actor Analysis**: Assess threat actor capabilities and motivations
- **Attack Vector Mapping**: Learn attack vector identification and prioritization
- **Security Control Design**: Test security control implementation and effectiveness
- **Risk Mitigation Planning**: Assess risk mitigation strategy development and prioritization

Advanced Learning Concepts:
- **STRIDE Threat Modeling**: Study Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege
- **PASTA Methodology**: Learn Process for Attack Simulation and Threat Analysis
- **OCTAVE Framework**: Assess Operationally Critical Threat, Asset, and Vulnerability Evaluation
- **CVSS Scoring**: Test Common Vulnerability Scoring System application
- **Attack Trees**: Study attack tree construction and analysis techniques
- **Risk Quantification**: Learn quantitative risk calculation and prioritization
- **Business Impact Analysis**: Assess business impact assessment and continuity planning

Learning Process:
1. **Threat Modeling Fundamentals**: Understand threat modeling methodologies and frameworks
2. **Risk Assessment**: Learn quantitative and qualitative risk evaluation techniques
3. **Asset Analysis**: Study critical asset identification and valuation
4. **Threat Analysis**: Assess threat actor analysis and capability assessment
5. **Attack Mapping**: Learn attack vector identification and exploitation analysis
6. **Control Design**: Test security control design and implementation
7. **Secure Implementation**: Develop comprehensive threat modeling and risk assessment practices

Teaching Methodology:
- **Threat Modeling Labs**: Hands-on threat modeling methodology exercises
- **Risk Assessment Workshops**: Quantitative and qualitative risk evaluation training
- **Asset Analysis Exercises**: Critical asset identification and classification labs
- **Threat Analysis Tutorials**: Threat actor capability assessment guides
- **Attack Mapping Labs**: Attack vector identification testing frameworks
- **Control Design Workshops**: Security control implementation assessment exercises
- **Real-World Scenarios**: Case studies of threat modeling and risk assessment

Output Format:
- **Threat Modeling Modules**: Structured learning units for threat modeling concepts
- **Risk Assessment Exercises**: Practical quantitative and qualitative risk evaluation labs
- **Asset Analysis Labs**: Critical asset identification and classification exercises
- **Threat Analysis Workshops**: Threat actor capability assessment guides
- **Attack Mapping Tutorials**: Attack vector identification testing frameworks
- **Control Design Labs**: Security control implementation assessment exercises
- **Case Studies**: Real-world threat modeling and risk assessment examples

Example Learning Query: "Teach me advanced threat modeling and risk assessment from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level threat modeling and risk assessment skills.

---

# MODULE 1: Threat Modeling Fundamentals

## 1.1 What is Threat Modeling?

Threat modeling is a structured process for identifying, quantifying, and addressing security threats to a system. It answers four key questions:
1. What are we building?
2. What can go wrong?
3. What are we going to do about it?
4. Did we do a good job?

```
Threat Modeling Process:
+-- Step 1: Define Scope and Objectives
|   +-- System boundaries
|   +-- Data flows
|   +-- Trust boundaries
|   +-- Entry/exit points
+-- Step 2: Identify Assets
|   +-- Data assets
|   +-- System components
|   +-- Business processes
|   +-- User data
+-- Step 3: Identify Threats
|   +-- Apply threat framework (STRIDE, PASTA, etc.)
|   +-- Consider threat actors
|   +-- Map attack vectors
|   +-- Document threat scenarios
+-- Step 4: Assess Risk
|   +-- Likelihood assessment
|   +-- Impact assessment
|   +-- Risk scoring
|   +-- Prioritization
+-- Step 5: Mitigate
|   +-- Define countermeasures
|   +-- Assign remediation
|   +-- Track implementation
|   +-- Verify effectiveness
```

## 1.2 Threat Modeling Frameworks Comparison

```
Framework Comparison:
+-- STRIDE
|   +-- Developed by: Microsoft
|   +-- Focus: Software threats
|   +-- Categories: 6 (Spoofing, Tampering, Repudiation, Info Disclosure, DoS, EoP)
|   +-- Best for: Application-level threat modeling
+-- PASTA
|   +-- Developed by: Tony UcedaVelez
|   +-- Focus: Risk-centric threat modeling
|   +-- Stages: 7 (Business objectives to risk management)
|   +-- Best for: Enterprise-level threat modeling
+-- LINDDUN
|   +-- Focus: Privacy threat modeling
|   +-- Categories: 5 (Linkability, Identifiability, Non-repudiation, Detectability, Disclosure, Unawareness)
|   +-- Best for: Privacy-focused applications
+-- DREAD
|   +-- Focus: Risk rating
|   +-- Categories: 5 (Damage, Reproducibility, Exploitability, Affected Users, Discoverability)
|   +-- Best for: Vulnerability prioritization
+-- Attack Trees
|   +-- Focus: Attack path visualization
|   +-- Structure: Tree-based decomposition
|   +-- Best for: Complex attack scenario analysis
+-- VAST
|   +-- Focus: Agile environments
|   +-- Types: Application + Infrastructure
|   +-- Best for: DevOps and continuous delivery
```

## 1.3 Data Flow Diagrams (DFDs)

```python
# dfd_generator.py
from dataclasses import dataclass
from typing import List, Dict

@dataclass
class DFDComponent:
    name: str
    component_type: str  # external_entity, process, data_store, trust_boundary
    trust_level: str  # high, medium, low
    description: str

@dataclass
class DataFlow:
    source: str
    destination: str
    data_type: str
    protocol: str
    encrypted: bool

class DataFlowDiagram:
    def __init__(self, system_name: str):
        self.system_name = system_name
        self.components: List[DFDComponent] = []
        self.flows: List[DataFlow] = []
        self.trust_boundaries: List[str] = []

    def add_component(self, component: DFDComponent):
        self.components.append(component)

    def add_flow(self, flow: DataFlow):
        self.flows.append(flow)

    def add_trust_boundary(self, name: str):
        self.trust_boundaries.append(name)

    def identify_attack_surface(self) -> Dict:
        """Identify attack surface from DFD"""
        surface = {
            "entry_points": [],
            "exit_points": [],
            "data_stores": [],
            "trust_boundaries": [],
            "external_interfaces": []
        }

        for comp in self.components:
            if comp.trust_level == "low":
                surface["external_interfaces"].append(comp.name)
            if comp.component_type == "data_store":
                surface["data_stores"].append(comp.name)

        for flow in self.flows:
            if not flow.encrypted:
                surface["entry_points"].append(
                    f"Unencrypted flow: {flow.source} -> {flow.destination}")

        surface["trust_boundaries"] = self.trust_boundaries
        return surface

    def generate_stride_analysis(self) -> List[Dict]:
        """Generate STRIDE analysis for each component"""
        threats = []

        for comp in self.components:
            if comp.component_type == "process":
                threats.extend([
                    {"component": comp.name, "stride": "Spoofing",
                     "threat": "Identity spoofing of process"},
                    {"component": comp.name, "stride": "Tampering",
                     "threat": "Input manipulation"},
                    {"component": comp.name, "stride": "Elevation of Privilege",
                     "threat": "Privilege escalation via process"},
                ])

            elif comp.component_type == "data_store":
                threats.extend([
                    {"component": comp.name, "stride": "Information Disclosure",
                     "threat": "Unauthorized data access"},
                    {"component": comp.name, "stride": "Tampering",
                     "threat": "Data modification"},
                    {"component": comp.name, "stride": "Denial of Service",
                     "threat": "Data unavailability"},
                ])

        return threats

# Example usage
dfd = DataFlowDiagram("E-Commerce Platform")
dfd.add_component(DFDComponent("Web Browser", "external_entity", "low", "User browser"))
dfd.add_component(DFDComponent("Web Server", "process", "medium", "nginx frontend"))
dfd.add_component(DFDComponent("App Server", "process", "medium", "Business logic"))
dfd.add_component(DFDComponent("Database", "data_store", "high", "PostgreSQL"))
dfd.add_component(DFDComponent("Payment Gateway", "external_entity", "low", "Stripe API"))

dfd.add_flow(DataFlow("Web Browser", "Web Server", "HTTPS requests", "TLS", True))
dfd.add_flow(DataFlow("Web Server", "App Server", "HTTP requests", "HTTP", False))
dfd.add_flow(DataFlow("App Server", "Database", "SQL queries", "TCP", False))

dfd.add_trust_boundary("Internet")
dfd.add_trust_boundary("DMZ")
dfd.add_trust_boundary("Internal Network")

print("Attack Surface:", dfd.identify_attack_surface())
print("STRIDE Threats:", dfd.generate_stride_analysis())
```

## 1.4 Practical Exercise: System Threat Model

```python
# exercises/threat_modeling.py
"""
Exercise: Create a threat model for a web application
1. Draw data flow diagram
2. Identify all components and data flows
3. Apply STRIDE to each component
4. Identify trust boundaries
5. Document threats and countermeasures
"""

class ThreatModelExercise:
    def __init__(self, system_description):
        self.system = system_description
        self.threats = []
        self.countermeasures = []

    def document_system(self):
        """Document system components"""
        print("System Documentation:")
        print(f"  System: {self.system['name']}")
        print(f"  Description: {self.system['description']}")
        print("\nComponents:")
        for comp in self.system['components']:
            print(f"  - {comp['name']} ({comp['type']})")
        print("\nData Flows:")
        for flow in self.system['flows']:
            print(f"  - {flow['source']} -> {flow['destination']}: {flow['data']}")

    def apply_stride(self, component_name, component_type):
        """Apply STRIDE to a component"""
        stride_mapping = {
            "process": [
                ("Spoofing", "Can an attacker impersonate this process?"),
                ("Tampering", "Can inputs be manipulated?"),
                ("Repudiation", "Can actions be denied?"),
                ("Information Disclosure", "Can sensitive data leak?"),
                ("Denial of Service", "Can this process be disabled?"),
                ("Elevation of Privilege", "Can权限 be escalated?"),
            ],
            "data_store": [
                ("Information Disclosure", "Can data be read by unauthorized users?"),
                ("Tampering", "Can data be modified without authorization?"),
                ("Denial of Service", "Can data become unavailable?"),
            ],
            "external_entity": [
                ("Spoofing", "Can this entity be impersonated?"),
                ("Tampering", "Can communications be intercepted/modified?"),
            ]
        }

        questions = stride_mapping.get(component_type, [])
        print(f"\nSTRIDE Analysis for {component_name}:")
        for category, question in questions:
            print(f"  {category}: {question}")

    def identify_countermeasures(self, threat):
        """Suggest countermeasures for a threat"""
        countermeasure_db = {
            "Spoofing": ["MFA", "Digital certificates", "Input validation"],
            "Tampering": ["HMAC", "Digital signatures", "Input validation"],
            "Repudiation": ["Audit logging", "Digital signatures", "Timestamps"],
            "Information Disclosure": ["Encryption", "Access control", "Data masking"],
            "Denial of Service": ["Rate limiting", "Redundancy", "Resource limits"],
            "Elevation of Privilege": ["Least privilege", "Sandboxing", "Input validation"],
        }
        return countermeasure_db.get(threat, ["Consult security guidelines"])

# Exercise starter
system = {
    "name": "Online Banking Application",
    "description": "Web-based banking system with user authentication, account management, and fund transfers",
    "components": [
        {"name": "User Browser", "type": "external_entity"},
        {"name": "Web Application", "type": "process"},
        {"name": "API Gateway", "type": "process"},
        {"name": "Authentication Service", "type": "process"},
        {"name": "Account Database", "type": "data_store"},
        {"name": "Transaction Database", "type": "data_store"},
        {"name": "Payment Network", "type": "external_entity"},
    ],
    "flows": [
        {"source": "User Browser", "destination": "Web Application", "data": "HTTPS"},
        {"source": "Web Application", "destination": "API Gateway", "data": "HTTP"},
        {"source": "API Gateway", "destination": "Authentication Service", "data": "gRPC"},
        {"source": "API Gateway", "destination": "Account Database", "data": "SQL"},
    ]
}

exercise = ThreatModelExercise(system)
exercise.document_system()
for comp in system['components']:
    exercise.apply_stride(comp['name'], comp['type'])
```

## 1.5 Assessment Questions

1. What are the four questions of threat modeling?
2. Compare STRIDE and PASTA when to use each?
3. How do data flow diagrams help in threat modeling?
4. What are trust boundaries and why are they important?
5. How do you identify the attack surface of a system?
6. What is the difference between a threat, vulnerability, and risk?
7. How often should threat models be updated?

---

# MODULE 2: STRIDE Threat Modeling Deep Dive

## 2.1 STRIDE Categories in Detail

```
STRIDE Threat Categories:
+-- SPOOFING (Identity)
|   +-- Definition: Impersonating something or someone
|   +-- Questions to ask:
|   |   +-- Can users be impersonated?
|   |   +-- Can processes be impersonated?
|   |   +-- Can external entities be spoofed?
|   +-- Countermeasures:
|       +-- Strong authentication (MFA)
|       +-- Digital certificates
|       +-- Input validation
|       +-- Anti-replay mechanisms
+-- TAMPERING (Integrity)
|   +-- Definition: Modifying data or code
|   +-- Questions to ask:
|   |   +-- Can messages be intercepted and modified?
|   |   +-- Can data stores be modified without authorization?
|   |   +-- Can code be modified in transit?
|   +-- Countermeasures:
|       +-- Digital signatures
|       +-- HMAC
|       +-- Integrity checking
|       +-- Secure update mechanisms
+-- REPUDIATION (Non-repudiation)
|   +-- Definition: Denying actions without contradiction
|   +-- Questions to ask:
|   |   +-- Can users deny performing actions?
|   |   +-- Are audit logs tamper-proof?
|   |   +-- Can transactions be repudiated?
|   +-- Countermeasures:
|       +-- Digital signatures
|       +-- Audit logging
|       +-- Timestamps from trusted authority
|       +-- Secure log storage
+-- INFORMATION DISCLOSURE (Confidentiality)
|   +-- Definition: Exposing information to unauthorized entities
|   +-- Questions to ask:
|   |   +-- Can data be read by unauthorized users?
|   |   +-- Can sensitive data leak through error messages?
|   |   +-- Can communication be eavesdropped?
|   +-- Countermeasures:
|       +-- Encryption (at rest and in transit)
|       +-- Access control
|       +-- Data masking
|       +-- Secure error handling
+-- DENIAL OF SERVICE (Availability)
|   +-- Definition: Denying or degrading service
|   +-- Questions to ask:
|   |   +-- Can services be overwhelmed?
|   |   +-- Can critical processes be terminated?
|   |   +-- Can resources be exhausted?
|   +-- Countermeasures:
|       +-- Rate limiting
|       +-- Redundancy
|       +-- Resource quotas
|       +-- Load balancing
+-- ELEVATION OF PRIVILEGE (Authorization)
    +-- Definition: Gaining unauthorized access
    +-- Questions to ask:
    |   +-- Can users gain higher privileges?
    |   +-- Can processes escape sandboxing?
    |   +-- Can code execute with elevated permissions?
    +-- Countermeasures:
        +-- Least privilege principle
        +-- Input validation
        +-- Sandboxing
        +-- Code signing
```

## 2.2 STRIDE Application Example

```python
# stride_analysis.py
from dataclasses import dataclass
from typing import List

@dataclass
class STRIDEThreat:
    component: str
    category: str
    threat_description: str
    likelihood: str  # Low, Medium, High
    impact: str  # Low, Medium, High, Critical
    risk_rating: str
    countermeasures: List[str]

class STRIDEAnalyzer:
    def __init__(self):
        self.threats: List[STRIDEThreat] = []

    def analyze_web_application(self):
        """Example STRIDE analysis for a web application"""
        threats = [
            STRIDEThreat(
                component="Login Form",
                category="Spoofing",
                threat_description="Attacker performs credential stuffing attack",
                likelihood="High",
                impact="High",
                risk_rating="High",
                countermeasures=[
                    "Implement MFA",
                    "Rate limit login attempts",
                    "Account lockout after failed attempts",
                    "CAPTCHA after 3 failed attempts"
                ]
            ),
            STRIDEThreat(
                component="User Profile API",
                category="Tampering",
                threat_description="Attacker modifies user profile data via API manipulation",
                likelihood="Medium",
                impact="Medium",
                risk_rating="Medium",
                countermeasures=[
                    "Input validation on all fields",
                    "Server-side data validation",
                    "CSRF tokens",
                    "Content-Type validation"
                ]
            ),
            STRIDEThreat(
                component="Transaction History",
                category="Information Disclosure",
                threat_description="IDOR vulnerability exposes other users transactions",
                likelihood="High",
                impact="Critical",
                risk_rating="Critical",
                countermeasures=[
                    "Server-side authorization checks",
                    "UUID instead of sequential IDs",
                    "Access control on data queries",
                    "Regular security testing"
                ]
            ),
            STRIDEThreat(
                component="File Upload Feature",
                category="Elevation of Privilege",
                threat_description="Attacker uploads webshell to gain server access",
                likelihood="Medium",
                impact="Critical",
                risk_rating="High",
                countermeasures=[
                    "File type validation (whitelist)",
                    "File size limits",
                    "Store uploads outside webroot",
                    "Antivirus scanning",
                    "Rename uploaded files"
                ]
            ),
            STRIDEThreat(
                component="Search Functionality",
                category="Denial of Service",
                threat_description="Complex queries cause database exhaustion",
                likelihood="Medium",
                impact="Medium",
                risk_rating="Medium",
                countermeasures=[
                    "Query complexity limits",
                    "Search rate limiting",
                    "Database query timeouts",
                    "Cached results for common queries"
                ]
            ),
            STRIDEThreat(
                component="Audit Log System",
                category="Repudiation",
                threat_description="Admin can delete audit logs to cover tracks",
                likelihood="Low",
                impact="High",
                risk_rating="Medium",
                countermeasures=[
                    "Immutable log storage",
                    "Separate log server",
                    "Log integrity verification",
                    "Multiple log copies"
                ]
            ),
        ]
        self.threats.extend(threats)
        return threats

    def calculate_risk(self, likelihood: str, impact: str) -> str:
        """Calculate risk rating"""
        risk_matrix = {
            ("Low", "Low"): "Low", ("Low", "Medium"): "Low",
            ("Low", "High"): "Medium", ("Low", "Critical"): "Medium",
            ("Medium", "Low"): "Low", ("Medium", "Medium"): "Medium",
            ("Medium", "High"): "High", ("Medium", "Critical"): "High",
            ("High", "Low"): "Medium", ("High", "Medium"): "High",
            ("High", "High"): "High", ("High", "Critical"): "Critical",
        }
        return risk_matrix.get((likelihood, impact), "Unknown")

    def generate_report(self) -> str:
        report = "STRIDE Threat Analysis Report\n" + "=" * 50 + "\n\n"

        for threat in self.threats:
            report += f"[{threat.risk_rating}] {threat.category} - {threat.component}\n"
            report += f"  Threat: {threat.threat_description}\n"
            report += f"  Likelihood: {threat.likelihood}, Impact: {threat.impact}\n"
            report += f"  Countermeasures:\n"
            for cm in threat.countermeasures:
                report += f"    - {cm}\n"
            report += "\n"

        return report

# Usage
analyzer = STRIDEAnalyzer()
analyzer.analyze_web_application()
print(analyzer.generate_report())
```

## 2.3 Practical Exercise: STRIDE Workshop

```
STRIDE Workshop Exercise:
1. Select a system to model (e.g., e-commerce, healthcare portal)
2. Create data flow diagram
3. For each component, apply STRIDE:
   - S: What identity can be spoofed?
   - T: What data can be tampered?
   - R: What actions can be repudiated?
   - I: What information can be disclosed?
   - D: What services can be denied?
   - E: What privileges can be escalated?
4. Rate each threat (likelihood x impact)
5. Document countermeasures
6. Present findings
```

## 2.4 Assessment Questions

1. Explain each category of STRIDE with examples.
2. How do you determine the likelihood and impact of a STRIDE threat?
3. What countermeasures address Spoofing threats?
4. How does STRIDE help in designing security controls?
5. Apply STRIDE to a mobile banking application.

---

# MODULE 3: Risk Assessment Methodologies

## 3.1 Qualitative Risk Assessment

```python
# qualitative_risk.py
from dataclasses import dataclass
from typing import List, Dict
from enum import Enum

class Likelihood(Enum):
    RARE = 1       # < 10% chance in 1 year
    UNLIKELY = 2   # 10-25% chance
    POSSIBLE = 3   # 25-50% chance
    LIKELY = 4     # 50-75% chance
    ALMOST_CERTAIN = 5  # > 75% chance

class Impact(Enum):
    NEGLIGIBLE = 1
    MINOR = 2
    MODERATE = 3
    MAJOR = 4
    CATASTROPHIC = 5

@dataclass
class RiskItem:
    id: str
    description: str
    asset: str
    threat: str
    vulnerability: str
    likelihood: Likelihood
    impact: Impact
    existing_controls: str
    risk_level: str

class QualitativeRiskAssessment:
    def __init__(self):
        self.risks: List[RiskItem] = []
        self.risk_matrix = self._build_risk_matrix()

    def _build_risk_matrix(self) -> Dict:
        """Build 5x5 risk matrix"""
        matrix = {}
        for l in range(1, 6):
            for i in range(1, 6):
                score = l * i
                if score <= 4:
                    level = "Low"
                elif score <= 9:
                    level = "Medium"
                elif score <= 15:
                    level = "High"
                else:
                    level = "Critical"
                matrix[(l, i)] = {"score": score, "level": level}
        return matrix

    def add_risk(self, risk: RiskItem):
        self.risks.append(risk)

    def calculate_risk_level(self, likelihood: Likelihood, impact: Impact) -> str:
        return self.risk_matrix[(likelihood.value, impact.value)]["level"]

    def prioritize_risks(self) -> List[RiskItem]:
        """Sort risks by priority"""
        return sorted(self.risks,
                     key=lambda r: r.likelihood.value * r.impact.value,
                     reverse=True)

    def generate_heatmap(self) -> str:
        """Generate risk heatmap"""
        levels = ["", "Rare", "Unlikely", "Possible", "Likely", "Almost Certain"]
        impact_labels = ["", "Negligible", "Minor", "Moderate", "Major", "Catastrophic"]

        heatmap = "Risk Heatmap\n" + "=" * 60 + "\n\n"
        heatmap += f"{'':>20}"
        for i in range(1, 6):
            heatmap += f"{impact_labels[i]:>12}"
        heatmap += "\n"

        for l in range(5, 0, -1):
            heatmap += f"{levels[l]:>20}"
            for i in range(1, 6):
                level = self.risk_matrix[(l, i)]["level"]
                marker = " *** " if level == "Critical" else "     "
                heatmap += f"{level:>12}"
            heatmap += "\n"

        return heatmap

    def generate_report(self) -> str:
        report = "Qualitative Risk Assessment Report\n" + "=" * 50 + "\n\n"

        prioritized = self.prioritize_risks()
        for risk in prioritized:
            level = self.calculate_risk_level(risk.likelihood, risk.impact)
            report += f"[{level}] {risk.id}: {risk.description}\n"
            report += f"  Asset: {risk.asset}\n"
            report += f"  Threat: {risk.threat}\n"
            report += f"  Vulnerability: {risk.vulnerability}\n"
            report += f"  Likelihood: {risk.likelihood.name}, Impact: {risk.impact.name}\n"
            report += f"  Existing Controls: {risk.existing_controls}\n\n"

        return report

# Example usage
assessment = QualitativeRiskAssessment()
assessment.add_risk(RiskItem(
    id="R001", description="SQL Injection in login form",
    asset="User Database", threat="External Attacker",
    vulnerability="Input validation failure",
    likelihood=Likelihood.LIKELY, impact=Impact.CRITICAL,
    existing_controls="None"
))
assessment.add_risk(RiskItem(
    id="R002", description="DDoS on payment service",
    asset="Payment Gateway", threat="DDoS Botnet",
    vulnerability="No rate limiting",
    likelihood=Likelihood.POSSIBLE, impact=Impact.MAJOR,
    existing_controls="Basic rate limiting"
))
print(assessment.generate_report())
```

## 3.2 Quantitative Risk Assessment

```python
# quantitative_risk.py
import math
from dataclasses import dataclass

@dataclass
class QuantitativeRisk:
    asset_value: float          # AV - Value of asset in dollars
    exposure_factor: float      # EF - Percentage of asset lost (0-100%)
    single_loss_expectancy: float  # SLE = AV * EF
    annualized_rate: float      # ARO - Expected frequency per year
    annual_loss_expectancy: float  # ALE = SLE * ARO

class QuantitativeRiskAssessment:
    def __init__(self):
        self.risks: list = []

    def calculate_sle(self, asset_value: float, exposure_factor: float) -> float:
        """Single Loss Expectancy = Asset Value x Exposure Factor"""
        return asset_value * exposure_factor

    def calculate_ale(self, sle: float, aro: float) -> float:
        """Annual Loss Expectancy = SLE x ARO"""
        return sle * aro

    def calculate_roi(self, ale_before: float, ale_after: float,
                     control_cost: float) -> float:
        """Return on Security Investment"""
        savings = ale_before - ale_after
        return ((savings - control_cost) / control_cost) * 100

    def add_risk(self, name: str, av: float, ef: float, aro: float):
        sle = self.calculate_sle(av, ef)
        ale = self.calculate_ale(sle, aro)
        self.risks.append({
            "name": name,
            "asset_value": av,
            "exposure_factor": ef,
            "sle": sle,
            "aro": aro,
            "ale": ale
        })

    def generate_report(self) -> str:
        report = "Quantitative Risk Assessment\n" + "=" * 50 + "\n\n"
        total_ale = 0

        for risk in self.risks:
            report += f"{risk['name']}\n"
            report += f"  Asset Value: ${risk['asset_value']:,.2f}\n"
            report += f"  Exposure Factor: {risk['exposure_factor']:.0%}\n"
            report += f"  SLE: ${risk['sle']:,.2f}\n"
            report += f"  ARO: {risk['aro']:.2f}\n"
            report += f"  ALE: ${risk['ale']:,.2f}\n\n"
            total_ale += risk['ale']

        report += f"Total Annual Loss Expectancy: ${total_ale:,.2f}\n"
        return report

# Example
qa = QuantitativeRiskAssessment()
qa.add_risk("Database Breach", 500000, 0.15, 0.5)  # $500K asset, 15% loss, every 2 years
qa.add_risk("DDoS Attack", 200000, 0.30, 2.0)       # $200K, 30% loss, twice per year
qa.add_risk("Insider Threat", 1000000, 0.05, 0.1)   # $1M, 5% loss, every 10 years
print(qa.generate_report())
```

## 3.3 Risk Assessment Questions

1. What is the difference between qualitative and quantitative risk assessment?
2. How do you calculate Single Loss Expectancy (SLE)?
3. What is Annual Loss Expectancy (ALE) and how is it used?
4. Explain the 5x5 risk matrix and how to read it.
5. How do you determine asset value for risk assessment?
6. What is the formula for Return on Security Investment (ROI)?
7. How does threat likelihood affect risk prioritization?

---

# MODULE 4: Attack Trees

## 4.1 Attack Tree Construction

```
Attack Tree Structure:
Root Goal (What attacker wants to achieve)
+-- AND Node (all children must be achieved)
|   +-- Sub-goal 1
|   +-- Sub-goal 2
+-- OR Node (any child can achieve goal)
    +-- Sub-goal A
    +-- Sub-goal B
```

## 4.2 Attack Tree Implementation

```python
# attack_tree.py
from dataclasses import dataclass, field
from typing import List, Optional
from enum import Enum

class NodeType(Enum):
    AND = "AND"
    OR = "OR"

@dataclass
class AttackNode:
    name: str
    description: str
    node_type: NodeType
    children: List['AttackNode'] = field(default_factory=list)
    cost: float = 0  # Estimated cost in dollars
    success_probability: float = 1.0
    detected_probability: float = 0.0

    def add_child(self, child: 'AttackNode'):
        self.children.append(child)

    def calculate_total_cost(self) -> float:
        """Calculate total cost to achieve this node"""
        if not self.children:
            return self.cost

        if self.node_type == NodeType.AND:
            return sum(child.calculate_total_cost() for child in self.children)
        else:  # OR - choose cheapest
            return min(child.calculate_total_cost() for child in self.children)

    def calculate_success_probability(self) -> float:
        """Calculate overall success probability"""
        if not self.children:
            return self.success_probability

        if self.node_type == NodeType.AND:
            return self.success_probability * \
                   min(child.calculate_success_probability() for child in self.children)
        else:  # OR - highest probability
            return max(child.calculate_success_probability() for child in self.children)

    def find_minimum_cost_path(self) -> dict:
        """Find the minimum cost attack path"""
        if not self.children:
            return {"path": [self.name], "cost": self.cost}

        child_paths = [child.find_minimum_cost_path() for child in self.children]

        if self.node_type == NodeType.AND:
            # Sum all children paths
            total_cost = sum(p["cost"] for p in child_paths)
            total_path = []
            for p in child_paths:
                total_path.extend(p["path"])
            return {"path": [self.name] + total_path, "cost": total_cost}
        else:  # OR - minimum cost
            min_path = min(child_paths, key=lambda x: x["cost"])
            return {"path": [self.name] + min_path["path"], "cost": min_path["cost"]}

    def display_tree(self, indent: int = 0) -> str:
        """Display attack tree with indentation"""
        prefix = "  " * indent
        node_type = f" [{self.node_type.value}]" if self.children else ""
        result = f"{prefix}{self.name}{node_type} (Cost: ${self.cost:.0f})\n"
        for child in self.children:
            result += child.display_tree(indent + 1)
        return result

class AttackTreeBuilder:
    def __init__(self, root_goal: str):
        self.root = AttackNode(root_goal, root_goal, NodeType.OR)

    def build_website_compromise_tree(self):
        """Example: Build attack tree for website compromise"""
        root = self.root

        # Method 1: SQL Injection (OR)
        sqli = AttackNode("SQL Injection", "Inject SQL via input fields", NodeType.AND)
        sqli.add_child(AttackNode("Find Injection Point", "Test all inputs", NodeType.OR,
                                  cost=500, success_probability=0.7))
        sqli.add_child(AttackNode("Craft Payload", "Create SQL payload", NodeType.AND,
                                  cost=200, success_probability=0.9))
        sqli.add_child(AttackNode("Extract Data", "Extract sensitive data", NodeType.AND,
                                  cost=300, success_probability=0.8))
        root.add_child(sqli)

        # Method 2: XSS Attack (OR)
        xss = AttackNode("Cross-Site Scripting", "Inject malicious script", NodeType.AND)
        xss.add_child(AttackNode("Identify XSS Point", "Find reflected/stored XSS", NodeType.OR,
                                  cost=400, success_probability=0.6))
        xss.add_child(AttackNode("Craft XSS Payload", "Bypass filters", NodeType.AND,
                                  cost=300, success_probability=0.7))
        xss.add_child(AttackNode("Steal Session", "Extract cookies/tokens", NodeType.AND,
                                  cost=100, success_probability=0.9))
        root.add_child(xss)

        # Method 3: Social Engineering (OR)
        social = AttackNode("Social Engineering", "Trick employees", NodeType.AND)
        social.add_child(AttackNode("Reconnaissance", "Gather employee info", NodeType.AND,
                                     cost=200, success_probability=0.8))
        social.add_child(AttackNode("Craft Phishing", "Create phishing email", NodeType.AND,
                                     cost=100, success_probability=0.6))
        social.add_child(AttackNode("Credential Theft", "Obtain credentials", NodeType.AND,
                                     cost=50, success_probability=0.5))
        root.add_child(social)

        return root

# Usage
builder = AttackTreeBuilder("Compromise Web Application")
tree = builder.build_website_compromise_tree()

print("Attack Tree:")
print(tree.display_tree())

min_path = tree.find_minimum_cost_path()
print(f"\nMinimum Cost Attack Path:")
print(f"  Path: {' -> '.join(min_path['path'])}")
print(f"  Cost: ${min_path['cost']:,.2f}")
```

## 4.3 Practical Exercise: Build Attack Trees

```
Exercise: Create an attack tree for these scenarios
1. Steal customer data from an e-commerce site
2. Take down a banking API
3. Deface a government website
4. Exfiltrate intellectual property from a corporate network

For each scenario:
- Define the root goal
- Identify at least 3 attack paths
- Use AND/OR nodes appropriately
- Estimate costs and probabilities
- Find the minimum cost path
```

## 4.4 Assessment Questions

1. What is the difference between AND and OR nodes in attack trees?
2. How do you find the minimum cost attack path?
3. What factors should be considered when estimating node costs?
4. How does attack tree analysis help in prioritizing security controls?
5. Build an attack tree for compromising a cloud-based SaaS application.

---

# MODULE 5: Business Impact Analysis (BIA)

## 5.1 BIA Framework

```python
# bia_analysis.py
from dataclasses import dataclass
from typing import List
from enum import Enum

class RTOCategory(Enum):
    CRITICAL = 4    # 0-4 hours
    ESSENTIAL = 3   # 4-24 hours
    IMPORTANT = 2   # 24-72 hours
    DEFERRABLE = 1  # 72+ hours

@dataclass
class BusinessProcess:
    name: str
    description: str
    rto: RTOCategory
    rpo_hours: float  # Recovery Point Objective in hours
    dependencies: List[str]
    annual_revenue_impact: float  # Revenue loss per hour of downtime
    regulatory_impact: str
    reputation_impact: str

class BusinessImpactAnalysis:
    def __init__(self):
        self.processes: List[BusinessProcess] = []

    def add_process(self, process: BusinessProcess):
        self.processes.append(process)

    def calculate_impact(self) -> List[dict]:
        """Calculate total impact for each process"""
        impacts = []
        for proc in self.processes:
            total_impact = {
                "process": proc.name,
                "rto_hours": {4: 4, 3: 24, 2: 72, 1: 168}[proc.rto.value],
                "rpo_hours": proc.rpo_hours,
                "revenue_impact_per_hour": proc.annual_revenue_impact,
                "max_revenue_loss": proc.annual_revenue_impact * {4: 4, 3: 24, 2: 72, 1: 168}[proc.rto.value],
                "regulatory_risk": proc.regulatory_impact,
                "reputation_risk": proc.reputation_impact
            }
            impacts.append(total_impact)

        return sorted(impacts, key=lambda x: x["max_revenue_loss"], reverse=True)

    def generate_report(self) -> str:
        report = "Business Impact Analysis Report\n" + "=" * 50 + "\n\n"

        impacts = self.calculate_impact()
        for impact in impacts:
            report += f"{impact['process']}\n"
            report += f"  RTO: {impact['rto_hours']} hours\n"
            report += f"  RPO: {impact['rpo_hours']} hours\n"
            report += f"  Revenue Impact: ${impact['revenue_impact_per_hour']:,.0f}/hour\n"
            report += f"  Max Loss (at RTO): ${impact['max_revenue_loss']:,.0f}\n"
            report += f"  Regulatory Risk: {impact['regulatory_risk']}\n"
            report += f"  Reputation Risk: {impact['reputation_risk']}\n\n"

        return report

# Example
bia = BusinessImpactAnalysis()
bia.add_process(BusinessProcess(
    "Online Payment Processing", "Credit card and payment processing",
    RTOCategory.CRITICAL, 0.5, ["Payment Gateway", "Database"],
    50000, "PCI DSS violation", "Severe"
))
bia.add_process(BusinessProcess(
    "Customer Support Portal", "Ticket and chat system",
    RTOCategory.ESSENTIAL, 4, ["Email Server", "Database"],
    5000, "SLA breach", "Moderate"
))
bia.add_process(BusinessProcess(
    "Internal Email", "Corporate email system",
    RTOCategory.IMPORTANT, 24, ["Exchange Server"],
    1000, "None", "Low"
))
print(bia.generate_report())
```

## 5.2 RTO and RPO Concepts

```
Recovery Objectives:
+-- RTO (Recovery Time Objective)
|   +-- Maximum acceptable downtime
|   +-- Business determines acceptable window
|   +-- Drives DR infrastructure investment
|   +-- Critical: 0-4 hours
|   +-- Essential: 4-24 hours
|   +-- Important: 24-72 hours
+-- RPO (Recovery Point Objective)
|   +-- Maximum acceptable data loss
|   +-- Determines backup frequency
|   +-- RPO = 0 means no data loss (synchronous replication)
|   +-- RPO = 4 hours means up to 4 hours of data loss
+-- MTD (Maximum Tolerable Downtime)
    +-- Absolute maximum before business failure
    +-- Drives DR strategy and investment
```

## 5.3 Assessment Questions

1. What is the difference between RTO and RPO?
2. How do you determine critical business processes for BIA?
3. What factors influence the RTO for a business process?
4. How does BIA help in designing disaster recovery strategies?
5. What is the relationship between BIA and risk assessment?

---

# MODULE 6: Security Control Design and Assessment

## 6.1 Control Design Framework

```
Control Design Process:
+-- Step 1: Identify Control Requirements
|   +-- Map threats to controls
|   +-- Consider regulatory requirements
|   +-- Define control objectives
+-- Step 2: Select Control Types
|   +-- Preventive, Detective, Corrective
|   +-- Administrative, Technical, Physical
|   +-- Consider cost-effectiveness
+-- Step 3: Design Control Implementation
|   +-- Detailed specifications
|   +-- Integration points
|   +-- Monitoring requirements
+-- Step 4: Implement Controls
|   +-- Deploy controls
|   +-- Document procedures
|   +-- Train personnel
+-- Step 5: Test Effectiveness
|   +-- Penetration testing
|   +-- Control validation
|   +-- Red team exercises
+-- Step 6: Monitor and Improve
    +-- Continuous monitoring
    +-- Regular assessments
    +-- Update based on new threats
```

## 6.2 Control Assessment Methodology

```python
# control_assessment.py
from dataclasses import dataclass
from typing import List

@dataclass
class SecurityControl:
    id: str
    name: str
    category: str  # Administrative, Technical, Physical
    control_type: str  # Preventive, Detective, Corrective
    objective: str
    implementation_status: str  # Implemented, Partial, Not Implemented
    effectiveness: str  # Effective, Partially Effective, Ineffective
    evidence: str
    gaps: List[str]

class ControlAssessment:
    def __init__(self):
        self.controls: List[SecurityControl] = []

    def add_control(self, control: SecurityControl):
        self.controls.append(control)

    def assess_access_controls(self):
        """Assess access control effectiveness"""
        controls = [
            SecurityControl(
                "AC-01", "Multi-Factor Authentication",
                "Technical", "Preventive",
                "Verify user identity with multiple factors",
                "Implemented", "Effective",
                "MFA deployed for all remote access and admin accounts",
                []
            ),
            SecurityControl(
                "AC-02", "Role-Based Access Control",
                "Technical", "Preventive",
                "Enforce least privilege principle",
                "Partial", "Partially Effective",
                "RBAC implemented but some service accounts have excessive privileges",
                ["Service accounts need review", "Access reviews not automated"]
            ),
            SecurityControl(
                "AC-03", "Access Review Process",
                "Administrative", "Detective",
                "Regular review of access rights",
                "Implemented", "Partially Effective",
                "Quarterly reviews conducted but not all systems covered",
                ["Missing review for legacy systems", "No automated deprovisioning"]
            ),
        ]
        self.controls.extend(controls)

    def generate_control_matrix(self) -> str:
        matrix = "Security Control Assessment Matrix\n" + "=" * 60 + "\n\n"
        matrix += f"{'ID':<8} {'Name':<30} {'Type':<15} {'Status':<12} {'Effectiveness':<15}\n"
        matrix += "-" * 80 + "\n"

        for ctrl in self.controls:
            matrix += f"{ctrl.id:<8} {ctrl.name:<30} {ctrl.control_type:<15} "
            matrix += f"{ctrl.implementation_status:<12} {ctrl.effectiveness:<15}\n"

        matrix += "\n"
        implemented = sum(1 for c in self.controls if c.implementation_status == "Implemented")
        total = len(self.controls)
        matrix += f"Implementation Rate: {implemented}/{total} ({implemented/total*100:.0f}%)\n"

        effective = sum(1 for c in self.controls if c.effectiveness == "Effective")
        matrix += f"Effectiveness Rate: {effective}/{total} ({effective/total*100:.0f}%)\n"

        return matrix

    def identify_gaps(self) -> List[dict]:
        gaps = []
        for ctrl in self.controls:
            if ctrl.gaps:
                gaps.append({
                    "control": ctrl.id,
                    "name": ctrl.name,
                    "gaps": ctrl.gaps
                })
        return gaps

# Usage
assessment = ControlAssessment()
assessment.assess_access_controls()
print(assessment.generate_control_matrix())
print("\nGaps Identified:")
for gap in assessment.identify_gaps():
    print(f"  {gap['control']}: {', '.join(gap['gaps'])}")
```

## 6.3 Control Effectiveness Metrics

```
Control Effectiveness Metrics:
+-- Detection Rate
|   +-- True Positives / (True Positives + False Negatives)
|   +-- Target: > 95%
+-- False Positive Rate
|   +-- False Positives / (False Positives + True Negatives)
|   +-- Target: < 5%
+-- Mean Time to Detect (MTTD)
|   +-- Average time to identify security incident
|   +-- Target: < 1 hour
+-- Mean Time to Respond (MTTR)
|   +-- Average time to contain security incident
|   +-- Target: < 4 hours
+-- Control Coverage
|   +-- Controls implemented / Controls required
|   +-- Target: > 90%
+-- Compliance Rate
|   +-- Requirements met / Total requirements
|   +-- Target: > 95%
```

## 6.4 Assessment Questions

1. What are the six steps in the control design process?
2. How do you measure control effectiveness?
3. What is the difference between preventive and detective controls?
4. How do you prioritize control gaps for remediation?
5. What metrics should be tracked for security control monitoring?
6. How do compensating controls work and when are they used?
7. How do you validate that security controls are operating effectively?

---

# FURTHER READING

## Books
- "Threat Modeling: Designing for Security" by Adam Shostack
- "Risk Assessment: A Practical Guide" by Douglas Landoll
- "The Security Risk Management Bible" by Kelly Bilz
- "Enterprise Security Risk Management" by Brian Allen

## Online Resources
- OWASP Threat Modeling Project
- NIST SP 800-30 - Risk Assessment Guide
- ISO 27005 - Information Security Risk Management
- FAIR (Factor Analysis of Information Risk)
- MITRE ATT&CK Framework

## Frameworks and Tools
- Microsoft Threat Modeling Tool
- OWASP Threat Dragon
- IriusRisk (Threat modeling platform)
- SEIMON (Security Metrics)
- Risk Assessment Matrix Tools

## Practice Resources
- Threat modeling workshops
- Risk assessment case studies
- Attack tree exercises
- Business impact analysis templates
- Security control assessment checklists
