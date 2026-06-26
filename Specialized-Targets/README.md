# Specialized Targets Domain

## Overview

The Specialized Targets domain provides comprehensive security testing methodologies, attack vectors, and defensive strategies for 50 distinct target categories spanning IoT, embedded systems, cloud infrastructure, blockchain, finance, healthcare, government, education, industrial control systems, and emerging technologies. Each file contains domain-specific knowledge, threat models, testing procedures, and real-world case studies tailored to the unique challenges of securing these specialized systems.

This domain differs from standard web application security by addressing the physical, protocol-level, regulatory, and operational constraints that define specialized target environments. Testing in these domains requires specialized tools, certifications, and sometimes physical access that goes beyond traditional penetration testing scopes.

---

## Domain Architecture

The 50 files are organized into 12 logical categories based on technology domain, attack surface similarity, and operational context. Files are numbered sequentially for reference but can be used independently or cross-referenced for chained attack scenarios.

### Category Map

| Category | Files | Focus Area |
|----------|-------|------------|
| IoT & Embedded | 01, 28-32 | Device firmware, embedded OS, wearables |
| Mobile | 02 | Mobile application and platform security |
| Cloud & Containers | 03-05 | Cloud infrastructure, containers, Kubernetes |
| Blockchain & DeFi | 06-10 | Smart contracts, DeFi, NFTs, Web3, exchanges |
| Finance | 11, 13 | Traditional finance APIs, financial institutions |
| Healthcare | 12, 27 | Healthcare systems, medical devices |
| Government & Enterprise | 14, 44-45 | Government systems, corporate, Fortune 500 |
| Education | 15, 19, 47 | Education platforms, LMS, academic research |
| E-commerce & Social | 16-18 | E-commerce, social media, CMS |
| Industrial & ICS | 20-26, 36-40 | Supply chain, manufacturing, ICS, power grid, transportation |
| Emerging Tech | 33-35, 29, 25 | Network devices, telecom, satellite, smart home, autonomous |
| Institutions | 41-43, 46, 48-50 | Research, non-profit, startups, open source, international orgs |

---

## File Index

### 01 - IoT Device Security

Covers the full IoT attack surface from device provisioning through decommissioning. Addresses firmware extraction, hardware debugging interfaces (JTAG, UART, SPI), Zigbee/Z-Wave/Bluetooth Low Energy protocol analysis, MQTT and CoAP broker exploitation, cloud backend API abuse, and device-to-device lateral movement. Includes case studies on Mirai botnet variants, smart camera exploitation, and industrial IoT gateway attacks.

Key topics:
- Firmware analysis and extraction techniques
- Hardware debugging interface exploitation
- IoT protocol fuzzing (MQTT, CoAP, AMQP)
- Device cloud API enumeration and abuse
- OTA update mechanism vulnerabilities
- IoT botnet recruitment and DDoS
- Physical tampering and side-channel attacks
- Supply chain integrity verification

### 02 - Mobile Application Testing

Extends OWASP Mobile Testing Guide with platform-specific attack vectors for iOS and Android. Covers binary analysis, runtime manipulation, certificate pinning bypass, insecure data storage, deeplink and intent exploitation, and mobile API security. Includes coverage of React Native, Flutter, and native hybrid frameworks.

Key topics:
- APK/IPA static and dynamic analysis
- Frida-based runtime instrumentation
- Certificate pinning bypass techniques
- Insecure local storage identification
- Deep link and custom scheme abuse
- Mobile payment integration testing
- Push notification hijacking
- Device jailbreak/root detection bypass

### 03 - Cloud Infrastructure Security

Multi-cloud attack surface coverage across AWS, Azure, and GCP. Addresses IAM misconfiguration, metadata service exploitation, serverless function abuse, storage bucket enumeration, and cross-account privilege escalation. Includes cloud-specific attack chains that combine multiple misconfigurations for high-impact outcomes.

Key topics:
- AWS IMDSv1/v2 exploitation via SSRF
- Azure Managed Identity abuse
- GCP service account key recovery
- S3/GCS/Azure Blob public enumeration
- Lambda/Cloud Functions/Cloud Run exploitation
- Cross-account assume-role chaining
- CloudTrail evasion and logging gaps
- Multi-tenant isolation bypass

### 04 - Container Security

Container runtime exploitation covering Docker daemon exposure, container escape techniques, image vulnerability scanning, and registry hardening. Addresses both container-native and orchestrator-aware attack paths.

Key topics:
- Docker daemon 2375/2376 unauthenticated access
- Container escape via kernel vulnerabilities
- Privileged container abuse
- Container image supply chain attacks
- Runtime security monitoring evasion
- Namespaces and cgroups bypass
- Container network policy analysis
- Secret management in containers

### 05 - Kubernetes Cluster Security

Kubernetes-specific attack surface from anonymous API access through etcd exploitation to pod security bypass. Covers RBAC misconfiguration, service account token abuse, and cluster-level privilege escalation chains.

Key topics:
- Kubernetes API anonymous access
- etcd unauthenticated data access
- kubelet 10250 API exploitation
- RBAC privilege escalation patterns
- Service account token theft and reuse
- Pod security policy bypass
- Ingress controller exploitation
- Kubernetes dashboard unauthorized access

### 06 - Blockchain Smart Contracts

Solidity and Rust-based smart contract vulnerability analysis. Covers reentrancy, integer overflow, access control, flash loan attacks, and oracle manipulation. Includes Foundry/Hardhat testing frameworks and real-world exploit analysis.

Key topics:
- Reentrancy attack patterns
- Flash loan exploit chains
- Access control bypass in contracts
- Oracle manipulation techniques
- Proxy upgrade vulnerabilities
- MEV and front-running
- Cross-chain bridge exploits
- Gas limit DoS attacks

### 07 - DeFi Protocol Security

Protocol-level security analysis for decentralized finance applications. Covers automated market makers, lending protocols, yield aggregators, and synthetic asset platforms. Addresses economic attack vectors unique to DeFi.

Key topics:
- AMM price manipulation
- Lending protocol liquidation attacks
- Yield farming exploit chains
- Synthetic asset depegging
- Governance token manipulation
- Flash loan-powered governance attacks
- Cross-protocol composability risks
- Oracle front-running and manipulation

### 08 - NFT Marketplace Security

NFT-specific attack vectors covering marketplace smart contracts, metadata manipulation, royalty enforcement bypass, and auction mechanism exploitation.

Key topics:
- NFT metadata URI manipulation
- Royalty enforcement bypass techniques
- Auction sniping and front-running
- Marketplace listing manipulation
- Cross-marketplace arbitrage exploitation
- NFT lending protocol risks
- Creator royalty manipulation
- Metadata permanence and IPFS pinning attacks

### 09 - Web3 Application Security

Web3 dApp security covering wallet connection vulnerabilities, RPC endpoint abuse, EIP-712 signature manipulation, and frontend-to-contract attack chains.

Key topics:
- Wallet connection hijacking
- RPC endpoint enumeration and abuse
- EIP-712 signature manipulation
- Transaction simulation bypass
- Frontend JavaScript injection for Web3
- Gas price manipulation attacks
- Nonce manipulation and replay
- Cross-chain message validation

### 10 - Cryptocurrency Exchange Security

Exchange-specific attack vectors including API key abuse, withdrawal address manipulation, KYC bypass, and trading engine exploitation.

Key topics:
- Exchange API key enumeration and abuse
- Withdrawal address manipulation
- KYC/AML verification bypass
- Trading engine race conditions
- Hot wallet exploitation
- Deposit/withdrawal race conditions
- Exchange-specific rate limit bypass
- Multi-signature wallet vulnerabilities

### 11 - Traditional Finance API Security

Banking and financial API security covering PSD2/Open Banking interfaces, SWIFT message validation, and legacy financial system integration vulnerabilities.

Key topics:
- Open Banking API authorization bypass
- PSD2 SCA implementation flaws
- SWIFT message validation weaknesses
- Financial data aggregation API abuse
- Payment gateway integration vulnerabilities
- Tokenization implementation flaws
- Financial reporting API exposure
- Real-time gross settlement system risks

### 12 - Healthcare System Security

HIPAA-covered system testing including EHR platform exploitation, DICOM protocol analysis, HL7/FHIR interface abuse, and medical device network segmentation failures.

Key topics:
- Electronic Health Record system exploitation
- DICOM medical imaging protocol analysis
- HL7/FHIR interface vulnerability assessment
- Medical device network segmentation testing
- PHI (Protected Health Information) exposure
- Healthcare cloud migration risks
- Telehealth platform security
- Medical IoT device exploitation

### 13 - Financial Institution Security

Banking-specific attack surface covering core banking systems, ATM security, SWIFT infrastructure, and payment processing networks.

Key topics:
- Core banking system API testing
- ATM jackpotting and logical attacks
- SWIFT infrastructure hardening
- Payment card processing security
- Fraud detection system testing
- Regulatory compliance verification
- Banking trojan analysis
- Financial malware reverse engineering

### 14 - Government System Security

Government-specific security testing addressing classification handling, government cloud (GovCloud) configurations, and citizen data protection.

Key topics:
- Government cloud (GovCloud) security
- Classified information handling systems
- Citizen data protection verification
- Government identity verification systems
- Cross-agency data sharing security
- Government procurement system testing
- Public key infrastructure (PKI) for government
- Government-specific compliance frameworks

### 15 - Education Platform Security

K-12 and higher education platform security covering LMS exploitation, student data protection, and research data management.

Key topics:
- Learning Management System exploitation
- Student information system security
- Research data management platform testing
- Virtual classroom platform vulnerabilities
- Student identity and authentication
- Education-specific API security
- FERPA compliance verification
- Academic integrity system testing

### 16 - E-commerce Platform Security

E-commerce specific attack vectors including payment processing, inventory management, pricing manipulation, and supply chain integration vulnerabilities.

Key topics:
- Payment gateway integration testing
- Inventory management system exploitation
- Pricing algorithm manipulation
- Shopping cart manipulation attacks
- Order processing logic flaws
- E-commerce API security
- Multi-vendor marketplace vulnerabilities
- Shipping and logistics system security

### 17 - Social Media Platform Security

Social media attack surface covering content moderation bypass, user enumeration, social graph analysis, and platform API abuse.

Key topics:
- Content moderation system bypass
- User enumeration and scraping
- Social graph analysis and exploitation
- Platform API rate limit bypass
- Account recovery mechanism abuse
- Content injection and manipulation
- Third-party application integration risks
- Privacy setting bypass techniques

### 18 - Content Management System Security

CMS-specific vulnerability assessment covering WordPress, Drupal, Joomla, and headless CMS platforms.

Key topics:
- WordPress plugin and theme exploitation
- Drupal module vulnerability assessment
- Joomla component security testing
- Headless CMS API security
- CMS configuration hardening
- User role and permission bypass
- Media upload exploitation
- CMS migration and upgrade security

### 19 - Learning Management System Security

LMS-specific security covering Moodle, Canvas, Blackboard, and custom LMS platforms.

Key topics:
- Moodle security configuration assessment
- Canvas LMS API exploitation
- Blackboard Learn vulnerability testing
- Custom LMS authentication bypass
- Course content manipulation
- Assessment and grading system tampering
- Student data export vulnerabilities
- LMS plugin and extension security

### 20 - Human Resources System Security

HR system security covering employee data protection, payroll system integrity, and benefits administration platform security.

Key topics:
- Employee PII protection verification
- Payroll system manipulation prevention
- Benefits administration platform testing
- Performance review system integrity
- Recruitment platform security
- HRIS (Human Resource Information System) security
- Background check system vulnerabilities
- Time and attendance system integrity

### 21 - Supply Chain Management Security

Supply chain system security covering procurement, logistics, inventory, and vendor management platforms.

Key topics:
- Procurement system manipulation
- Logistics tracking system exploitation
- Inventory management system tampering
- Vendor management platform security
- Bill of materials integrity verification
- Supply chain data integrity
- Third-party integration security
- Warehouse management system testing

### 22 - Manufacturing Control System Security

Manufacturing-specific ICS security covering SCADA, DCS, and PLC systems in production environments.

Key topics:
- SCADA system vulnerability assessment
- DCS (Distributed Control System) security
- PLC programming and exploitation
- Manufacturing execution system (MES) security
- Industrial protocol analysis (Modbus, DNP3, OPC)
- Safety system integrity verification
- Manufacturing IT/OT convergence security
- Industrial network segmentation

### 23 - Smart Building Automation

Building automation system security covering HVAC, lighting, access control, and fire safety systems.

Key topics:
- BACnet protocol exploitation
- HVAC system manipulation
- Lighting control system security
- Access control system bypass
- Fire safety system integrity
- Building Management System (BMS) security
- IoT sensor network exploitation
- Building automation API security

### 24 - Connected Vehicle Security

Automotive cybersecurity covering V2X communication, infotainment systems, CAN bus exploitation, and over-the-air update security.

Key topics:
- CAN bus message injection
- V2X (Vehicle-to-Everything) communication security
- Infotainment system exploitation
- OBD-II port attack vectors
- Over-the-air (OTA) update security
- Telematics system vulnerability assessment
- Autonomous driving sensor manipulation
- Automotive network segmentation

### 25 - Autonomous System Security

Autonomous vehicle and drone security covering perception system manipulation, decision-making algorithm attacks, and communication security.

Key topics:
- LiDAR/Radar sensor spoofing
- GPS/GNSS spoofing and jamming
- Autonomous decision-making algorithm attacks
- Drone communication protocol exploitation
- UAV (Unmanned Aerial Vehicle) security
- Autonomous vehicle network security
- Perception system adversarial attacks
- Fleet management system security

### 26 - Industrial Control System Security

ICS/SCADA security covering power generation, water treatment, and critical infrastructure systems.

Key topics:
- SCADA protocol exploitation (Modbus, DNP3, IEC 61850)
- PLC logic manipulation
- HMI (Human-Machine Interface) exploitation
- Industrial network protocol analysis
- Safety Instrumented System (SIS) security
- Industrial DMZ configuration
- Legacy ICS system hardening
- Industrial incident response

### 27 - Medical Device Security

FDA-regulated medical device security covering infusion pumps, pacemakers, imaging systems, and connected health devices.

Key topics:
- Infusion pump firmware exploitation
- Pacemaker and implantable device security
- Medical imaging system vulnerabilities
- Connected health device security
- Medical device authentication bypass
- Medical device data exfiltration
- FDA premarket cybersecurity requirements
- Medical device patch management

### 28 - Wearable Technology Security

Wearable device security covering fitness trackers, smartwatches, and biometric monitoring devices.

Key topics:
- Fitness tracker data extraction
- Smartwatch application security
- Biometric data protection verification
- Wearable device Bluetooth exploitation
- Wearable cloud API security
- Health data privacy compliance
- Wearable firmware update security
- Cross-device synchronization vulnerabilities

### 29 - Smart Home Device Security

Smart home ecosystem security covering voice assistants, cameras, thermostats, and home automation hubs.

Key topics:
- Voice assistant exploitation (Alexa, Google Home, Siri)
- Smart camera live feed access
- Thermostat manipulation
- Home automation hub security
- Smart lock bypass techniques
- Zigbee/Z-Wave network exploitation
- Smart home cloud API abuse
- Home network segmentation for IoT

### 30 - Embedded System Security

General embedded system security covering microcontrollers, RTOS, and embedded Linux systems.

Key topics:
- Microcontroller firmware extraction
- Embedded Linux system hardening
- Real-time operating system security
- Embedded debugging interface exploitation
- Memory corruption in embedded systems
- Embedded cryptographic implementation flaws
- Embedded system update mechanisms
- Side-channel attacks on embedded systems

### 31 - Real-Time Operating System Security

RTOS-specific security covering FreeRTOS, VxWorks, QNX, and other real-time platforms.

Key topics:
- FreeRTOS security configuration
- VxWorks vulnerability assessment
- QNX security hardening
- RTOS kernel exploitation techniques
- Inter-task communication security
- Real-time constraint bypass attacks
- RTOS memory protection mechanisms
- Legacy RTOS migration security

### 32 - Firmware Security Analysis

Firmware-level security analysis covering extraction, reverse engineering, vulnerability identification, and exploitation.

Key topics:
- Firmware image extraction techniques
- Firmware filesystem analysis
- Firmware reverse engineering
- Firmware vulnerability identification
- Secure boot bypass techniques
- Firmware update mechanism exploitation
- Firmware integrity verification
- Supply chain firmware verification

### 33 - Network Device Security

Network infrastructure device security covering routers, switches, firewalls, and load balancers.

Key topics:
- Router exploitation and hardening
- Switch security configuration
- Firewall bypass techniques
- Load balancer vulnerability assessment
- Network device firmware analysis
- SNMP and management interface security
- Network protocol exploitation (BGP, OSPF, STP)
- Network device access control bypass

### 34 - Telecommunication System Security

Telecom infrastructure security covering 4G/5G networks, IMS, and carrier infrastructure.

Key topics:
- 4G/5G network protocol exploitation
- IMS (IP Multimedia Subsystem) security
- SS7 protocol attack vectors
- Diameter protocol exploitation
- Telecom API security
- SIM card cloning and exploitation
- Base station security assessment
- Carrier infrastructure hardening

### 35 - Satellite Communication Security

Satellite and space communication security covering ground stations, satellite protocols, and space-to-ground links.

Key topics:
- Satellite ground station exploitation
- Satellite communication protocol analysis
- GPS/GNSS spoofing techniques
- Satellite link hijacking
- Ground control system security
- Satellite firmware exploitation
- Space communication encryption
- Satellite constellation security

### 36 - Air Traffic Control System Security

ATC system security covering radar systems, communication networks, and flight data processing.

Key topics:
- ATC radar system security
- Communication network exploitation
- Flight data processing system integrity
- ADS-B (Automatic Dependent Surveillance-Broadcast) security
- ATC protocol analysis
- Flight plan manipulation prevention
- Air traffic management system hardening
- ATC cybersecurity compliance

### 37 - Power Grid Security

Electrical grid security covering generation, transmission, and distribution systems.

Key topics:
- SCADA system exploitation for power grid
- Substation automation security
- Power generation control system security
- Transmission line monitoring security
- Distribution automation system security
- Smart grid communication protocol analysis
- Advanced Metering Infrastructure (AMI) security
- Power grid incident response

### 38 - Water Treatment Facility Security

Water treatment and distribution system security covering treatment plant controls and distribution monitoring.

Key topics:
- Water treatment SCADA exploitation
- Chemical dosing system manipulation
- Water quality monitoring system security
- Distribution network pressure manipulation
- Water treatment plant network segmentation
- IoT sensor security in water systems
- Water treatment regulatory compliance
- Emergency response system integrity

### 39 - Transportation System Security

Transportation infrastructure security covering rail, aviation, maritime, and road systems.

Key topics:
- Rail signaling system security
- Aviation ground system security
- Maritime navigation system exploitation
- Intelligent Transportation System (ITS) security
- Traffic management system manipulation
- Public transit system security
- Port operations system security
- Transportation data integrity

### 40 - Energy Management System Security

Energy management covering smart grids, renewable energy systems, and energy trading platforms.

Key topics:
- Smart grid energy management systems
- Renewable energy system security (solar, wind)
- Energy trading platform exploitation
- Demand response system manipulation
- Energy storage system security
- Building energy management systems
- Energy market data integrity
- Distributed energy resource security

### 41 - Research Institution Security

Academic and research institution security covering research data, intellectual property, and collaboration platforms.

Key topics:
- Research data protection verification
- Intellectual property security assessment
- Collaboration platform security
- High-Performance Computing (HPC) security
- Research grant management system security
- Academic publication system security
- Research institution compliance verification
- Collaboration across international borders

### 42 - Non-Profit Organization Security

Non-profit organization security covering donor data, program management, and volunteer systems.

Key topics:
- Donor data protection verification
- Fundraising platform security
- Program management system security
- Volunteer management platform security
- Grant reporting system integrity
- Non-profit-specific compliance verification
- Cloud service cost optimization security
- Third-party integration security for non-profits

### 43 - Startup Company Security

Startup-specific security covering rapid development practices, shared infrastructure, and early-stage risk management.

Key topics:
- Rapid development security practices
- Shared infrastructure isolation
- Seed funding data protection
- Startup-specific compliance (pre-revenue)
- Developer environment security
- Cloud cost optimization security
- Third-party API security for startups
- Intellectual property protection for startups

### 44 - Enterprise Corporate Security

Large enterprise security covering Active Directory, enterprise applications, and corporate network security.

Key topics:
- Active Directory exploitation and hardening
- Enterprise application security testing
- Corporate network segmentation verification
- Enterprise mobility management (EMM) security
- Enterprise cloud migration security
- Enterprise compliance verification
- Enterprise incident response planning
- Enterprise security architecture review

### 45 - Fortune 500 Company Security

Fortune 500-specific security covering complex organizational structures, global operations, and regulatory requirements.

Key topics:
- Global operations security coordination
- Complex regulatory compliance verification
- Multi-division security architecture
- Executive protection digital security
- Global supply chain security
- M&A security due diligence
- Global incident response coordination
- Enterprise risk management verification

### 46 - Open Source Project Security

Open source project security covering code repository security, contributor authentication, and release integrity.

Key topics:
- Repository access control verification
- Contributor authentication and authorization
- Release signing and verification
- Dependency management security
- Open source license compliance
- Community vulnerability disclosure
- CI/CD pipeline security for open source
- Open source governance and security

### 47 - Academic Research Security

Academic research-specific security covering research integrity, data sharing, and collaboration across institutions.

Key topics:
- Research integrity verification systems
- Data sharing platform security
- Cross-institutional collaboration security
- Research participant data protection
- Academic publishing security
- Research grant data integrity
- Laboratory network security
- Research data retention security

### 48 - International Organization Security

International organization security covering multi-jurisdictional compliance, diplomatic communications, and cross-border data sharing.

Key topics:
- Multi-jurisdictional compliance verification
- Diplomatic communication security
- Cross-border data sharing security
- International treaty compliance verification
- Multi-language system security
- International identity verification
- Diplomatic network security
- International incident response coordination

### 49 - Developing Country Infrastructure Security

Infrastructure security in developing nations covering legacy systems, resource constraints, and emerging technology adoption.

Key topics:
- Legacy system security in developing nations
- Resource-constrained security implementation
- Emerging technology adoption security
- International aid system security
- Telecommunications infrastructure security
- Financial inclusion system security
- Healthcare system security in developing nations
- Education technology security in developing nations

### 50 - Global Scale System Security

Massive-scale system security covering global CDN, distributed databases, and planet-scale infrastructure.

Key topics:
- Global CDN security and edge exploitation
- Distributed database security
- Planet-scale infrastructure security
- Global load balancing security
- Cross-region data replication security
- Global incident response coordination
- Massive-scale DDoS protection
- Global compliance and data residency

---

## Usage Guidelines

### Prerequisites

Before testing specialized targets, ensure:
1. **Authorization**: Written authorization from system owners with clear scope definitions
2. **Certification**: Relevant certifications (OSCP, OSCE, GICSP, GPEN, etc.) for the target domain
3. **Insurance**: Professional liability insurance covering the specific target type
4. **Compliance**: Understanding of regulatory requirements (HIPAA, PCI-DSS, NERC CIP, FDA, etc.)
5. **Physical Access**: Where required, physical access authorization and safety training

### Testing Methodology

Each file follows a consistent methodology:
1. **Reconnaissance**: Passive and active information gathering specific to the target domain
2. **Vulnerability Assessment**: Domain-specific vulnerability scanning and identification
3. **Exploitation**: Controlled exploitation with safety considerations for the target type
4. **Post-Exploitation**: Impact assessment and lateral movement within the target domain
5. **Remediation**: Domain-specific hardening recommendations and security controls

### Cross-Domain Attack Chains

Many files in this domain can be chained for multi-stage attack scenarios:
- **IoT to Enterprise**: 01 → 03 → 44 (IoT device → Cloud backend → Enterprise network)
- **Mobile to Financial**: 02 → 11 → 13 (Mobile app → Finance API → Banking system)
- **Supply Chain to ICS**: 21 → 22 → 26 (Supply chain → Manufacturing → ICS)
- **Cloud to Blockchain**: 03 → 06 → 10 (Cloud → Smart contract → Exchange)
- **Medical to Healthcare**: 27 → 12 (Medical device → Healthcare system)
- **Smart Home to Critical Infrastructure**: 29 → 37 (Smart home → Power grid)

---

## Regulatory Compliance Cross-Reference

| Domain | Primary Regulations | Compliance Files |
|--------|-------------------|------------------|
| Healthcare | HIPAA, HITECH, FDA 21 CFR Part 11 | 12, 27 |
| Finance | PCI-DSS, SOX, PSD2, Basel III | 11, 13, 10 |
| Government | FISMA, FedRAMP, NIST 800-53 | 14, 15 |
| Industrial | NERC CIP, IEC 62443, NIST CSF | 22, 26, 37, 38 |
| Education | FERPA, COPPA, GLBA | 15, 19, 47 |
| International | GDPR, LGPD, POPIA | 48, 49, 50 |

---

## Tool Requirements by Domain

| Domain | Primary Tools | Secondary Tools |
|--------|--------------|-----------------|
| IoT/Embedded | Binwalk, Ghidra, JTAG explorers | Logic analyzer, oscilloscope |
| Mobile | Frida, Objection, JADX | MobSF, apktool |
| Cloud | Prowler, ScoutSuite, CloudMapper | Pacu, Enumerate-iam |
| Blockchain | Slither, Mythril, Foundry | Echidna, Manticore |
| ICS/SCADA | CODESYS, Modbus tools, Wireshark | PLC-specific IDEs |
| Medical | Custom firmware tools, DICOM viewers | Medical device analyzers |

---

## Contributing

When adding new specialized target files:
1. Follow the established file naming convention: `XX-Category-Name.md`
2. Include all standard sections: Overview, Attack Surface, Testing Methodology, Tools, Case Studies, Remediation
3. Update this README's file index and category map
4. Update registry.json with the new file entry
5. Cross-reference with existing files where attack chains exist

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-01-15 | Initial release with 50 specialized target files |
| 1.1.0 | 2024-03-20 | Added cross-domain attack chain documentation |
| 1.2.0 | 2024-06-10 | Updated regulatory compliance cross-reference |
| 1.3.0 | 2024-09-01 | Added tool requirements by domain matrix |
| 1.4.0 | 2025-01-15 | Expanded IoT and blockchain sections |
| 1.5.0 | 2025-06-01 | Added emerging technology categories |

---

## License

This knowledge base is provided for authorized security testing and educational purposes only. Always obtain proper authorization before testing specialized targets. The authors assume no liability for misuse of this information.
