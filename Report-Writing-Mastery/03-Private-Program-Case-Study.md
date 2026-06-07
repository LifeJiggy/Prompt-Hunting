# Private Bug Bounty Program Strategies

## Expert Role

Private bug bounty programs represent the elite tier of vulnerability disclosure rewarded programs. Unlike public programs accessible to anyone, private programs are invitation-only ecosystems where organizations selectively onboard trusted researchers. Understanding the dynamics of private programs is essential for maximizing earnings, building professional reputation, and accessing higher-value targets. This module covers the complete lifecycle of private program participation from invitation through sustained engagement.

The private program landscape in 2026 includes platforms like HackerOne, Bugcrowd, Intigriti, and Immunefi running invitation-only programs for Fortune 500 companies, major tech firms, financial institutions, and government agencies. These programs typically offer 2-10x higher bounties than their public counterparts, have stricter reporting requirements, and maintain tighter relationships between program managers and researchers.

Private programs exist because organizations want controlled disclosure environments, pre-vetted researchers who understand responsible reporting, reduced noise from low-quality submissions, and direct communication channels with proven talent. For researchers, private programs offer reduced competition, higher payouts, faster response times, and opportunities for long-term engagement with specific targets.

## Core Concepts

### Program Tier Structure

Bug bounty programs generally exist in three tiers:

**Open/Public Programs**: Available to all registered researchers on a platform. Any researcher can submit reports. Competition is high, signal-to-noise ratio is lower, and bounties tend to be modest. Examples include many government VDPs and mid-tier tech company programs.

**Closed/Private Programs**: Invitation-only programs where the organization selects specific researchers based on merit, past performance, or relationship. Bounties are typically 2-5x higher than public programs. Competition is lower and triage is faster.

**Invite-Plus Programs**: Some programs operate semi-privately where existing private researchers can invite peers after meeting certain criteria. These create organic growth of trusted researcher pools.

### Reputation Systems

Every major platform maintains researcher reputation scores:

- **HackerOne**: Signal score based on report quality, severity distribution, and program feedback
- **Bugcrowd**: CrowdRank based on report acceptance rates and severity
- **Intigriti**: Trust score combining submission quality and community standing
- **Immunefi**: Reputation specific to blockchain/Web3 security

Higher reputation unlocks private program invitations, priority triage, and direct communication with program managers.

### Private vs Public Program Economics

| Dimension | Public Programs | Private Programs |
|-----------|----------------|-----------------|
| Average bounty (Critical) | $2,000-$10,000 | $10,000-$50,000+ |
| Average bounty (High) | $500-$3,000 | $3,000-$15,000 |
| Competition level | High | Low to moderate |
| Triage speed | Days to weeks | Hours to days |
| Scope breadth | Often narrow | Often comprehensive |
| Duplicate rate | High | Low |
| Communication | Platform-mediated | Direct Slack/email |

### Invitation Mechanisms

Organizations invite researchers through several channels:

1. **Platform algorithm selection**: Platform recommends researchers based on relevant skills and past performance
2. **Program manager outreach**: Direct invitation from the organization's security team
3. **Peer referrals**: Existing private researchers invite qualified peers
4. **Conference networking**: Meeting security teams at BSides, DEF CON, Black Hat
5. **Public report portfolio**: Demonstrating skill through excellent public program work
6. **Bug bounty leaderboard placement**: Ranking highly on platform leaderboards

### Scope Analysis for Private Programs

Private programs often have broader scope than public counterparts:

- **Full domain coverage**: All subdomains of primary domain included
- **API endpoints**: Both v1 and v2 API endpoints in scope
- **Mobile applications**: iOS and Android apps sometimes included
- **Source code access**: Grey-box programs may provide partial source code
- **Internal tools**: Some programs include staging or internal tools accessible via VPN
- **Third-party integrations**: Partners using the organization's authentication

### Reporting Requirements

Private programs enforce stricter reporting standards:

- Detailed reproduction steps with timestamps
- Impact assessment with business context
- Suggested remediation with code examples
- Proof-of-concept with minimal necessary disclosure
- Compliance with program-specific templates
- Adherence to disclosure timelines
- No public disclosure without written consent

### Relationship Management

Sustained private program participation requires:

- Consistent report quality over time
- Professional communication during triage
- Flexibility on bounty negotiation
- Respect for scope boundaries
- Prompt response to program manager inquiries
- Confidentiality about program details and internal findings

## Prerequisites

### Technical Prerequisites

1. **Platform accounts**: Active accounts on HackerOne, Bugcrowd, or Intigriti with verified identity
2. **Portfolio of public reports**: Minimum 3-5 disclosed reports at Medium severity or above
3. **Reputation score**: Platform-specific threshold (typically top 10-20% of researchers)
4. **Specialized tooling**: Burp Suite Professional, advanced scanning capabilities
5. **Communication skills**: Professional email writing and real-time chat proficiency
6. **Time commitment**: Minimum 10-20 hours per week for active private program engagement
7. **Legal authorization**: Understanding of CFAA, DMCA, and platform terms of service
8. **Financial setup**: Platform payment processing configured and verified
9. **OPSEC awareness**: Separation of testing infrastructure from personal systems
10. **Multi-factor authentication**: Secured platform and email accounts

### Soft Skill Prerequisites

1. **Professional etiquette**: Understanding of business communication norms
2. **Conflict resolution**: Handling disagreements over severity or bounty gracefully
3. **Patience**: Private programs may have complex triage processes
4. **Confidentiality**: Not discussing private program findings publicly
5. **Adaptability**: Adjusting to different program requirements and expectations
6. **Networking**: Building relationships at conferences and online communities
7. **Time management**: Balancing multiple private programs simultaneously
8. **Documentation**: Maintaining organized records of all submissions
9. **Feedback receptiveness**: Incorporating program manager feedback constructively
10. **Ethical judgment**: Knowing when to escalate or decline engagement

## Methodology

### Phase 1: Building Invitation Eligibility

#### Step 1: Establish Public Program Track Record

Begin with public programs to build reputation:

```
Target Selection Strategy:
1. Choose 3-5 public programs in your specialization area
2. Focus on programs with consistent triage (< 7 days)
3. Aim for 2-3 valid reports per program
4. Prioritize Critical/High severity findings
5. Document each report with exceptional detail
```

Public program portfolio development timeline:

| Week | Activity | Goal |
|------|----------|------|
| 1-2 | Initial recon on 3 public programs | Identify attack surface |
| 3-4 | First submissions | 2-3 Medium severity reports |
| 5-8 | Deep testing | 1-2 High severity reports |
| 9-12 | Relationship building | Direct communication with PMs |
| 13-16 | Advanced techniques | Critical severity finding |
| 17-20 | Portfolio polish | Refined reporting style |

#### Step 2: Optimize Platform Profile

Your platform profile is your professional resume:

```
Profile Optimization Checklist:
□ Professional display name (real name or consistent handle)
□ Profile photo (professional headshot or consistent avatar)
□ Detailed biography highlighting specializations
□ Skills tags matching your expertise areas
□ Language capabilities listed
□ Location (builds trust with program managers)
□ Active since date (demonstrates longevity)
□ Verified payment method
□ Two-factor authentication enabled
□ Notification preferences configured
```

#### Step 3: Develop Specialization Areas

Program managers invite researchers with specific skills:

**Web Application Security**
- Authentication and authorization bypass
- Business logic flaws
- API security testing
- Input validation and injection attacks

**Mobile Application Security**
- iOS and Android reverse engineering
- Mobile API testing
- Certificate pinning bypass
- Local data storage analysis

**Infrastructure Security**
- Cloud configuration auditing
- Network service enumeration
- Container escape techniques
- Kubernetes security testing

**Cryptocurrency/DeFi**
- Smart contract auditing
- Bridge security analysis
- Wallet integration testing
- Economic attack modeling

### Phase 2: Getting Invited to Private Programs

#### Step 4: Demonstrate Consistent Quality

Program managers monitor public disclosure activity:

```
Quality Signals:
- Detailed reproduction steps (no ambiguity)
- Impact assessment with real-world scenarios
- Suggested remediation with code examples
- Professional communication throughout triage
- No duplicate submissions or noise reports
- Respectful disagreement on severity when warranted
- Follow-up on program manager questions
```

#### Step 5: Network Strategically

Build relationships in the security community:

```
Networking Channels:
- Conference attendance (BSides, DEF CON, Black Hat)
- Security community Slack/Discord channels
- Twitter/X security community engagement
- Bug bounty forums and discussion groups
- CTF participation and team formation
- Open source security tool contributions
- Blog posts and write-ups of disclosed findings
```

#### Step 6: Respond to Platform Signals

Platforms facilitate private program invitations:

```
Platform Invitation Signals:
- Email notification of private program invitation
- Dashboard banner announcing new program access
- Platform algorithm recommendations
- Direct message from program manager
- Peer referral notification
```

When you receive an invitation:
1. Read the program brief thoroughly
2. Review scope and rules of engagement
3. Check for program-specific reporting templates
4. Note any special communication requirements
5. Begin reconnaissance within the first week
6. Submit initial findings promptly

### Phase 3: Private Program Engagement

#### Step 7: Initial Reconnaissance

Private programs require methodical scope analysis:

```
Reconnaissance Framework:
1. Subdomain enumeration (full scope mapping)
2. Technology fingerprinting (framework, CMS, dependencies)
3. API endpoint discovery (documentation, Swagger, GraphQL)
4. Authentication mechanism analysis
5. Session management evaluation
6. Business logic flow mapping
7. Third-party integration identification
8. Internal tool discovery (staging, admin panels)
```

#### Step 8: Systematic Testing

Develop a testing roadmap for each private program:

```
Week 1: Surface mapping and quick wins
- Low-hanging fruit identification
- Known vulnerability patterns
- Configuration audit

Week 2-3: Deep dive testing
- Authentication and authorization flows
- Business logic analysis
- API endpoint enumeration

Week 4-5: Advanced techniques
- Race conditions
- Privilege escalation paths
- Cross-service attack chains

Week 6+: Ongoing monitoring
- New feature testing
- Regression checks
- Scope expansion areas
```

#### Step 9: Report Submission

Private program reports require higher standards:

```
Report Structure:
1. Title: Clear, specific, actionable
2. Summary: One-paragraph overview
3. Severity: CVSS 3.1 score with justification
4. Vulnerability Type: CWE classification
5. Affected Component: Exact endpoint/feature
6. Steps to Reproduction: Numbered, unambiguous
7. Impact: Business context and real-world scenarios
8. Remediation: Specific fix recommendations
9. Supporting Materials: PoC, screenshots, videos
10. Timeline: Discovery and disclosure dates
```

#### Step 10: Triage Communication

Maintain professional dialogue during triage:

```
Communication Best Practices:
- Respond to inquiries within 24 hours
- Provide additional information when requested
- Respect triage timelines and escalation procedures
- Document all communications for reference
- Accept feedback constructively
- Disagree professionally with evidence-based reasoning
- Thank program managers for their time
```

### Phase 4: Building Sustained Relationships

#### Step 11: Consistency Over Intensity

Long-term success requires sustained output:

```
Consistency Metrics:
- Minimum 2 valid reports per month per program
- Response time under 24 hours for inquiries
- Zero duplicate submissions
- 80%+ report acceptance rate
- No scope violations
- Professional communication in all interactions
```

#### Step 12: Value-Added Contributions

Go beyond basic reporting:

```
Value-Added Activities:
- Feature-specific security reviews upon request
- Regression testing after remediation
- Security architecture consultation
- Threat modeling assistance
- Security documentation review
- Training material contributions
- Conference co-presentations
```

#### Step 13: Escalation and Negotiation

Handle disputes professionally:

```
Dispute Resolution Framework:
1. Understand the program's position fully
2. Present evidence-based counterarguments
3. Reference industry standards (CVSS, CWE, OWASP)
4. Propose compromise solutions
5. Escalate through platform mechanisms if needed
6. Document resolution for future reference
7. Maintain relationship regardless of outcome
```

## Tool Arsenal

### Essential Tools for Private Programs

#### Reconnaissance Tools

```
Subdomain Enumeration:
- subfinder: Fast passive subdomain enumeration
- amass: Comprehensive asset discovery
- assetfinder: Quick domain relationship mapping
- crt.sh: Certificate transparency monitoring
- SecurityTrails: Historical DNS data

Live Host Discovery:
- httpx: HTTP probing and technology detection
- masscan: Large-scale port scanning
- nmap: Detailed service enumeration
- whatweb: Web technology fingerprinting
- wappalyzer: Technology stack identification

Directory Discovery:
- ffuf: Fast web fuzzer
- gobuster: Directory and DNS brute forcing
- feroxbuster: Recursive content discovery
- dirsearch: Common path scanning
```

#### Testing Tools

```
Web Application Testing:
- Burp Suite Professional: Primary intercepting proxy
- OWASP ZAP: Open-source alternative
- Nuclei: Template-based vulnerability scanning
- sqlmap: Automated SQL injection testing
- XSStrike: Advanced XSS detection
- Arjun: Parameter discovery

API Testing:
- Postman: API exploration and testing
- Insomnia: REST and GraphQL testing
- GraphQL Voyager: Schema visualization
- Swagger/OpenAPI spec analysis

Mobile Testing:
- Frida: Dynamic instrumentation
- Objection: Runtime mobile exploration
- MobSF: Mobile security framework
- jadx: APK decompilation
- Ghidra: Reverse engineering
```

#### Documentation Tools

```
Report Writing:
- Markdown editors (Typora, VS Code)
- Screenshot tools (Greenshot, Snagit)
- Screen recording (OBS Studio, Loom)
- Diagram creation (draw.io, Mermaid)
- Version control for reports (Git)
```

### Tool Configuration Templates

#### Burp Suite Configuration for Private Programs

```
Project Settings:
- Logging: Enable full request/response history
- Proxy: Configure upstream proxy for anonymity
- TLS: Enable certificate pinning bypass
- Extensions: Install Autorize, Logger++, Turbo Intruder

Scanner Configuration:
- Audit checks: All active and passive checks
- Insertion points: All injection points
- Creep scan level: Maximum for thorough analysis
- Scan acceleration: Enable for time-sensitive programs

Session Handling:
- Cookie jar management
- Token refresh macros
- Session rotation rules
- Authentication state management
```

#### Nuclei Template Configuration

```
Template Categories:
- cves: CVE-based vulnerability detection
- vulnerabilities: General vulnerability templates
- misconfigurations: Configuration audit
- exposures: Information disclosure
- default-logins: Default credential detection

Custom Template Development:
- Program-specific detection logic
- Custom severity assignments
- Organized template directories
- Version-controlled template libraries
```

## Case Studies

### Case Study 1: From Public to Private — Building a Reputation

**Researcher Profile**: Mid-level web application security specialist

**Timeline**: 6 months from first public report to private program invitation

**Month 1-2**: Public Program Foundations
- Selected 3 public programs on HackerOne
- Submitted 4 Medium severity reports
- 100% acceptance rate, average triage time 5 days
- Built relationships with 2 program managers through professional communication

**Month 3-4**: Advanced Technique Development
- Focused on business logic vulnerabilities
- Submitted 2 High severity reports
- Developed custom automation scripts for repetitive testing
- Began writing detailed disclosure blog posts

**Month 5-6**: Reputation Acceleration
- Discovered Critical severity authentication bypass on major SaaS platform
- Wrote comprehensive report with detailed remediation
- Received public recognition from program manager
- Achieved top 5% researcher ranking on platform

**Invitation**: Received private program invitation from a Fortune 500 financial services company. First private submission was a Critical severity IDOR vulnerability worth $15,000.

**Key Takeaways**:
- Consistency in report quality matters more than quantity
- Professional communication builds trust
- Specializing in specific vulnerability classes increases success rate
- Public recognition leads to private opportunities

### Case Study 2: Private Program Relationship Management

**Scenario**: Researcher invited to private program for major e-commerce platform

**Initial Engagement**:
- First submission: Critical SQL injection in payment processing
- Bounty: $25,000
- Communication: Professional, detailed, responsive
- Triage: 48 hours from submission to validation

**Ongoing Relationship**:
- Maintained regular testing schedule (20 hours/week)
- Submitted 3-4 valid reports per month
- Zero duplicate submissions
- Responded to all inquiries within 12 hours

**Escalation Event**:
- Submitted Critical severity report for business logic flaw
- Program initially triaged as Medium severity
- Provided additional evidence and impact analysis
- Engaged in professional back-and-forth over 2 weeks
- Final resolution: High severity with $12,000 bounty
- Relationship maintained throughout disagreement

**Long-term Value**:
- 18-month engagement generating $180,000+ in bounties
- Invited to beta test new features before public release
- Provided consultation on security architecture decisions
- Recommended to peer program for similar engagement

**Key Takeaways**:
- Professional disagreement strengthens relationships when handled correctly
- Consistent quality over time builds sustainable income
- Added value beyond basic reporting creates lasting partnerships
- Transparency during disputes preserves trust

### Case Study 3: Multi-Program Portfolio Management

**Challenge**: Managing 5 private programs simultaneously while maintaining quality

**Time Management Framework**:

| Day | Morning (4h) | Afternoon (4h) | Evening (2h) |
|-----|-------------|----------------|--------------|
| Mon | Program A recon | Program B testing | Report writing |
| Tue | Program C testing | Program D analysis | Report writing |
| Wed | Program E recon | Program A testing | Documentation |
| Thu | Program B recon | Program C analysis | Report writing |
| Fri | Program D testing | Program E testing | Week review |

**Outcome**:
- Average 12 valid reports per month across all programs
- 95% acceptance rate
- Zero scope violations
- Total annual earnings: $320,000

**Key Takeaways**:
- Systematic time allocation prevents burnout
- Program-specific knowledge bases reduce context switching
- Regular review cycles catch missed opportunities
- Quality never sacrificed for quantity

## Advanced Topics

### Exclusive Access Programs

Some organizations run ultra-private programs:

**Tier 1 Programs**:
- 50 or fewer researchers worldwide
- $50,000-$500,000 bounty ranges
- Direct Slack channel with security team
- Pre-release access to new features
- Quarterly security reviews with CISO

**Entry Requirements**:
- Demonstrated Critical/High severity track record
- Specific domain expertise (mobile, cloud, blockchain)
- Peer recommendation from existing participants
- Signed NDA and additional legal agreements
- Background check completion

### Program Negotiation Strategies

**Bounty Maximization**:
- Present comprehensive impact analysis with business context
- Reference industry benchmarks for similar vulnerabilities
- Demonstrate exploitability with minimal assumptions
- Chain multiple lower-severity findings for higher impact
- Propose responsible disclosure timeline that benefits both parties

**Scope Expansion**:
- Identify assets not explicitly in scope but potentially vulnerable
- Request clarification through program manager channels
- Propose testing boundaries with clear limitations
- Document any scope changes with written confirmation

**Priority Access**:
- Volunteer for beta testing programs
- Participate in security architecture reviews
- Provide threat modeling assistance
- Contribute to security documentation
- Mentor newer researchers in program channels

### Advanced Reporting Techniques

**Business Impact Quantification**:

```
Impact Framework:
1. Revenue Impact
   - Direct financial loss from exploitation
   - Cost of incident response
   - Regulatory fine potential

2. User Impact
   - Number of affected users
   - Data sensitivity classification
   - Privacy violation implications

3. Operational Impact
   - System downtime costs
   - Engineering remediation effort
   - Reputation damage assessment

4. Compliance Impact
   - Regulatory violation (GDPR, CCPA, HIPAA)
   - Audit findings
   - Certification implications
```

**Severity Justification Matrix**:

| Vulnerability | CVSS Base | Business Multiplier | Final Severity |
|---------------|-----------|---------------------|----------------|
| SQL Injection | 9.8 | 1.0 (standard) | Critical |
| SQL Injection (payment system) | 9.8 | 1.2 (financial) | Critical+ |
| XSS (public forum) | 6.1 | 0.9 (limited scope) | Medium |
| XSS (admin panel) | 6.1 | 1.5 (privileged) | High |
| IDOR (user profiles) | 5.3 | 0.8 (low sensitivity) | Medium |
| IDOR (financial records) | 5.3 | 1.8 (sensitive data) | Critical |

### Private Program Intelligence Gathering

**OSINT for Private Programs**:

```
Information Sources:
1. Job postings (reveal technology stack)
2. Engineering blog posts (architecture details)
3. Conference presentations (security initiatives)
4. Patent filings (product roadmap)
5. GitHub repositories (code patterns)
6. LinkedIn profiles (team structure)
7. Press releases (acquisitions, partnerships)
8. SEC filings (compliance requirements)
9. Security disclosures (past vulnerabilities)
10. Platform-specific intelligence (breach data, service information)
```

**Competitive Analysis**:
- Track other researchers' public disclosures in similar programs
- Identify underserved attack surfaces
- Learn from others' approach patterns
- Avoid duplicate research paths

### Scaling Private Program Operations

**Automation Framework**:

```
Automation Opportunities:
1. Reconnaissance automation (scheduled scans)
2. Report template generation
3. Status tracking and reminders
4. Communication logging
5. Bounty tracking and financial management
6. Performance metrics collection
7. Knowledge base maintenance
8. Tool configuration management
```

**Team Formation**:
- Partner with complementary specialists
- Establish clear collaboration agreements
- Define revenue sharing models
- Maintain individual reputation alongside team contributions
- Coordinate testing to avoid duplicate effort

## Detection

### Invitation Detection Methods

**Platform Notifications**:
- Email alerts for private program invitations
- Dashboard notifications and banners
- Mobile app push notifications
- Real-time Slack/email integration

**Indirect Signals**:
- Increased profile views from organization domains
- Connection requests from security team members
- Conference invitations from program sponsors
- Speaking opportunities at security events

### Relationship Health Monitoring

**Positive Signals**:
- Faster triage times on submissions
- Direct communication channels
- Beta testing invitations
- References to other programs
- Increased bounty amounts

**Warning Signs**:
- Slower response times
- More questions during triage
- Reduced bounty amounts
- Scope restrictions
- Communication through intermediaries

## Impact

### Financial Impact

Private programs typically offer:

| Severity | Public Avg | Private Avg | Multiplier |
|----------|-----------|-------------|------------|
| Critical | $5,000 | $25,000 | 5x |
| High | $1,500 | $8,000 | 5.3x |
| Medium | $500 | $2,500 | 5x |
| Low | $150 | $750 | 5x |

### Career Impact

Private program participation demonstrates:
- Professional-grade security testing capability
- Business communication skills
- Ethical handling of sensitive information
- Ability to work within organizational constraints
- Long-term relationship management

### Portfolio Impact

Private program track records enhance:
- Resume credibility for security positions
- Conference speaking opportunities
- consulting engagements
- Media appearances and interviews
- Industry recognition and awards

## Pitfalls

### Common Mistakes

1. **Premature private program participation**: Submitting before establishing reputation
2. **Overcommitting**: Accepting more programs than manageable
3. **Neglecting public programs**: Losing reputation base
4. **Poor communication**: Unprofessional interactions with program managers
5. **Scope violations**: Testing outside authorized boundaries
6. **Duplicate submissions**: Wasting program resources
7. **Bounty greed**: Prioritizing payout over relationship
8. **Confidentiality breaches**: Discussing private findings publicly
9. **Inconsistency**: Erratic submission quality or frequency
10. **Burnout**: Pushing too hard without sustainable pace

### Recovery Strategies

**After Reputation Damage**:
- Acknowledge mistakes professionally
- Demonstrate improved quality through public programs
- Request reconsideration after consistent performance
- Seek mentorship from established researchers
- Consider platform migration if necessary

**After Scope Violations**:
- Immediately cease testing
- Report the incident proactively
- Cooperate fully with investigation
- Implement stricter testing controls
- Document lessons learned

### Long-Term Sustainability

**Burnout Prevention**:
- Set realistic weekly hour limits
- Diversify across multiple programs
- Take regular breaks from testing
- Maintain work-life boundaries
- Celebrate successes appropriately

**Skill Maintenance**:
- Continue learning new techniques
- Attend conferences and training
- Participate in CTF competitions
- Contribute to security community
- Stay current with vulnerability trends

## Integration

### Platform Integration

**HackerOne Workflow**:
```
1. Accept private program invitation
2. Review program brief and scope
3. Configure testing environment
4. Begin systematic reconnaissance
5. Submit reports through platform
6. Engage in triage communication
7. Receive bounty and provide feedback
```

**Bugcrowd Workflow**:
```
1. Accept VDP invitation
2. Complete researcher agreement
3. Access program-specific resources
4. Conduct authorized testing
5. Submit through submission form
6. Participate in triage process
7. Collect bounty and provide ratings
```

### Team Integration

**Collaboration Models**:

1. **Individual researcher**: Full control, all revenue
2. **Partnership**: Shared revenue, complementary skills
3. **Team model**: Structured roles, revenue sharing
4. **Consulting firm**: Organizational resources, client management

### Tool Integration

**Integrated Testing Environment**:

```
Reconnaissance → Testing → Documentation → Submission
    ↓              ↓            ↓              ↓
 subfinder     Burp Suite   Markdown      Platform API
 amass         Nuclei       Screenshots   Email
 httpx         Custom       Videos        Slack
 masscan       Scripts      Diagrams      Communication
```

### Workflow Integration

**Daily Routine**:

```
09:00 - Check program notifications and updates
09:15 - Review triage communications
09:30 - Begin testing session
12:00 - Lunch break
13:00 - Continue testing or start report writing
16:00 - Document findings
17:00 - Review and submit reports
18:00 - Update knowledge base
19:00 - Plan next day's activities
```

### Documentation Integration

**Knowledge Management**:

```
Documentation Structure:
├── Program A/
│   ├── Scope analysis
│   ├── Reconnaissance notes
│   ├── Finding history
│   └── Communication log
├── Program B/
│   ├── Scope analysis
│   ├── Reconnaissance notes
│   ├── Finding history
│   └── Communication log
├── Templates/
│   ├── Report templates
│   ├── Checklists
│   └── Response templates
└── Tools/
    ├── Configuration files
    ├── Custom scripts
    └── Automation workflows
```

## Reporting

### Report Quality Standards

**Private Program Report Checklist**:

```
Pre-Submission:
□ All reproduction steps tested and verified
□ Screenshots captured and annotated
□ Video PoC recorded if applicable
□ Impact assessment completed
□ Remediation recommendations prepared
□ Severity justification documented
□ Program-specific template followed

Post-Submission:
□ Confirmation received from platform
□ Timeline for triage noted
□ Follow-up questions prepared
□ Additional evidence ready if needed
□ Communication logged
```

### Report Templates

**Critical Severity Template**:

```markdown
# [CRITICAL] [Vulnerability Type] in [Component]

## Summary
[One-paragraph overview of the vulnerability]

## Severity
CVSS 3.1: [Score] ([Rating])
Justification: [Why this severity]

## Vulnerability Details
- **Type**: [CWE classification]
- **Location**: [Exact endpoint/feature]
- **Attack Vector**: [Network/Adjacent/Local]
- **Authentication Required**: [Yes/No]

## Steps to Reproduce
1. [Step 1]
2. [Step 2]
3. [Step 3]
...

## Impact
[Business context and real-world exploitation scenarios]

## Remediation
[Specific fix recommendations with code examples]

## Supporting Materials
- PoC: [curl command/code snippet]
- Screenshots: [Attached]
- Video: [Link if applicable]
```

### Communication Templates

**Initial Report Acknowledgment**:

```
Subject: Re: [Report ID] - [Report Title]

Hi [Program Manager],

Thank you for acknowledging receipt of my report. I'm available for any
questions or additional information needed during triage.

I'll monitor the ticket for updates and respond within 24 hours to any
inquiries.

Best regards,
[Your Name]
```

**Severity Disagreement Response**:

```
Subject: Re: [Report ID] - Severity Discussion

Hi [Program Manager],

I appreciate your team's assessment. I'd like to provide additional
context regarding the severity rating:

[Technical evidence supporting your position]

I understand your perspective and am open to discussion. Please let me
know if there's additional information I can provide.

Best regards,
[Your Name]
```

## Labs

### Lab 1: Public Program Portfolio Development

**Objective**: Build a public program portfolio that attracts private invitations

**Duration**: 12 weeks

**Weekly Goals**:
- Week 1-2: Select 3 target programs, begin reconnaissance
- Week 3-4: Submit first 2 reports
- Week 5-6: Analyze results, refine approach
- Week 7-8: Submit 2 more reports with improved quality
- Week 9-10: Pursue High severity finding
- Week 11-12: Document lessons, prepare for private engagement

**Success Metrics**:
- 4+ valid reports submitted
- 80%+ acceptance rate
- 1+ High severity finding
- Positive program manager feedback

### Lab 2: Private Program Reconnaissance

**Objective**: Complete comprehensive reconnaissance for a private program scope

**Duration**: 1 week

**Daily Tasks**:

```
Day 1: Subdomain enumeration (100+ subdomains)
Day 2: Live host discovery and technology fingerprinting
Day 3: API endpoint discovery and documentation
Day 4: Authentication mechanism analysis
Day 5: Business logic flow mapping
Day 6: Third-party integration identification
Day 7: Attack surface prioritization and testing plan
```

**Deliverables**:
- Complete asset inventory
- Technology stack documentation
- API endpoint catalog
- Testing roadmap

### Lab 3: Report Quality Workshop

**Objective**: Write and refine a report that meets private program standards

**Duration**: 3 days

**Day 1**: Draft initial report
- Write reproduction steps
- Capture screenshots
- Document impact

**Day 2**: Refinement
- Peer review (if possible)
- Clarity improvements
- Evidence organization

**Day 3**: Finalization
- Professional formatting
- Proofreading
- Final verification

**Quality Checklist**:
- No ambiguity in reproduction steps
- All screenshots annotated
- Impact quantified where possible
- Remediation specific and actionable

## Ethics

### Ethical Guidelines for Private Programs

**Confidentiality Obligations**:

1. **Program details**: Never disclose program existence, scope, or specific requirements without written consent
2. **Vulnerability information**: Keep findings confidential until coordinated disclosure
3. **Internal information**: Respect organizational sensitivity around business processes and data
4. **Communication privacy**: Don't share private communications with third parties
5. **Competitive intelligence**: Don't use testing access for competitive advantage

**Responsible Testing Practices**:

1. **Scope adherence**: Test only within explicitly authorized boundaries
2. **Data handling**: Don't access, exfiltrate, or retain actual user data
3. **Service impact**: Minimize disruption to production systems
4. **Testing timing**: Avoid testing during critical business periods
5. **Escalation**: Report any accidental exposure immediately

**Professional Ethics**:

1. **Transparency**: Be honest about findings and testing methodology
2. **Integrity**: Don't fabricate or exaggerate vulnerabilities
3. **Fairness**: Accept fair bounty decisions gracefully
4. **Respect**: Treat program managers as professional partners
5. **Accountability**: Take responsibility for testing impact

### Legal Considerations

**Authorization Framework**:

```
Authorized Activities:
- Testing within defined scope
- Using provided credentials/access
- Submitting reports through platform
- Communicating with program managers
- Documenting findings for reports

Prohibited Activities:
- Accessing data beyond scope
- Sharing access credentials
- Modifying production data
- Disrupting service availability
- Reverse engineering proprietary code (unless explicitly authorized)
```

### Community Responsibility

**Positive Community Impact**:

1. **Mentoring**: Help newer researchers improve their skills
2. **Knowledge sharing**: Contribute to security community resources
3. **Standards promotion**: Advocate for fair bounty practices
4. **Ethical leadership**: Demonstrate responsible disclosure
5. **Inclusion**: Welcome diverse perspectives in security

## Cheat Sheet

### Private Program Quick Reference

**Getting Invited**:
1. Build strong public program portfolio (3-5 quality reports)
2. Achieve top 10-20% researcher ranking
3. Network at conferences and online communities
4. Demonstrate specialization in specific vulnerability classes
5. Maintain professional communication throughout

**First 30 Days**:
1. Day 1-3: Complete scope analysis and reconnaissance
2. Day 4-7: Identify quick wins and low-hanging fruit
3. Day 8-14: Deep dive testing on priority areas
4. Day 15-21: Submit first 2-3 reports
5. Day 22-30: Follow up on triage, adjust approach

**Communication Templates**:

```
Initial Contact:
"Hi [Name], I'm [Your Name], a security researcher invited to
your private program. I've begun testing and wanted to introduce
myself. I'll submit any findings through the platform and am
available for questions."

Report Submission:
"Hi [Name], I've submitted report #[ID] regarding [Vulnerability].
Please let me know if you need additional information or clarification
during triage."

Follow-up:
"Hi [Name], I wanted to follow up on my recent submission. I'm
available for any questions and can provide additional testing if
needed."
```

**Bounty Negotiation**:

```
Opening Position:
- Reference industry benchmarks
- Quantify business impact
- Document exploitability
- Present chain potential

Response to Lower Offer:
- Acknowledge their position
- Provide additional evidence
- Propose compromise
- Maintain professionalism

Acceptance:
- Thank program team
- Confirm receipt
- Maintain relationship
```

**Relationship Maintenance**:

```
Weekly:
- Test consistently
- Submit quality reports
- Respond promptly to inquiries
- Document findings thoroughly

Monthly:
- Review submission metrics
- Analyze triage feedback
- Adjust testing strategy
- Update knowledge base

Quarterly:
- Assess relationship health
- Discuss scope expansion
- Plan advanced testing
- Set performance goals
```

### Severity Quick Reference

| Finding | Base CVSS | Adjustment | Final |
|---------|-----------|------------|-------|
| RCE | 10.0 | +0.0 | Critical |
| SQLi (auth bypass) | 9.8 | +0.0 | Critical |
| SQLi (data extraction) | 9.8 | -0.5 | High+ |
| SSRF (internal access) | 8.6 | +0.0 | High |
| XSS (stored, admin) | 8.7 | +0.0 | High |
| XSS (reflected) | 6.1 | -0.5 | Medium |
| IDOR (sensitive data) | 5.3 | +1.0 | High |
| IDOR (public data) | 5.3 | -1.0 | Low+ |
| CSRF (account takeover) | 8.8 | +0.0 | High |
| CSRF (minor action) | 4.3 | -1.0 | Low |

### Communication Cheat Sheet

**DO**:
- Respond within 24 hours
- Use professional tone
- Provide evidence-based arguments
- Thank program managers
- Document everything

**DON'T**:
- Be aggressive or demanding
- Discuss bounties publicly
- Share program details
- Submit duplicates
- Ghost after submission

**Escalation Path**:
1. Direct communication with program manager
2. Platform support ticket
3. Platform mediation
4. Community manager involvement
5. Legal review (rare)
