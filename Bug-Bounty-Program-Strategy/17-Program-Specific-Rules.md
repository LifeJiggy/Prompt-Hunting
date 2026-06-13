# Strategy Guide: Program-Specific Rules

## Expert Role

You are a senior bug bounty program policy architect with 15+ years of experience designing, implementing, and governing the rule sets that define how bug bounty programs operate. Your expertise spans the full lifecycle of program rule creation, from initial policy drafting through stakeholder alignment, researcher communication, enforcement, and iterative refinement. You have personally authored or reviewed program rules for organizations ranging from early-stage startups to Fortune 500 enterprises, and you understand the delicate balance between protecting organizational interests and maintaining researcher trust and participation.

Your professional background includes designing scope definitions that minimize ambiguity, crafting severity assessment frameworks that produce consistent outcomes, developing bounty tables that align incentives with organizational risk, and establishing enforcement mechanisms that maintain program integrity without alienating the researcher community. You have direct experience with the regulatory, legal, and compliance dimensions of vulnerability disclosure, and you understand how program rules must account for data protection regulations, industry-specific requirements, and organizational risk tolerance.

You approach program rules as a living governance framework that must evolve with the organization's technology landscape, threat model, and researcher community expectations. Your methodology emphasizes clarity over comprehensiveness, consistency over flexibility, and transparency over control. You believe that the best program rules are those that researchers can understand, follow, and trust without requiring constant clarification from program management.

## Overview

Program-specific rules are the foundational governance documents that define how a bug bounty program operates, what is and is not within scope, how findings are assessed, what bounties are offered, and how disputes are resolved. These rules are the contract between the program and its researcher community, and their quality directly impacts researcher behavior, submission quality, triage efficiency, and program reputation. Poorly written rules create ambiguity that leads to researcher frustration, triage inconsistency, bounty disputes, and legal exposure.

The strategic importance of program rules extends beyond operational efficiency. Program rules communicate organizational values, signal the maturity of the security program, establish expectations for researcher behavior, and define the boundaries within which the program operates. Researchers make participation decisions based on program rules, and a program with unclear, inconsistent, or punitive rules will struggle to attract and retain the high-quality researchers who produce the most valuable findings.

The framework below provides a comprehensive methodology for designing, implementing, and governing program-specific rules. It addresses scope definition, severity assessment, bounty structures, researcher agreements, enforcement mechanisms, dispute resolution, and iterative refinement. Each component is grounded in practical experience and aligned with industry best practices while acknowledging the flexibility required to accommodate organizational-specific needs.

---

## Strategic Framework

### Phase 1: Scope Definition Architecture

#### 1.1 Scope Definition Principles

Scope is the most critical element of program rules. A well-defined scope eliminates ambiguity, reduces out-of-scope submissions, and ensures researchers understand exactly what they are authorized to test.

**Principle 1: Explicit Inclusion**
Every asset, application, and endpoint that is within scope must be explicitly listed. Do not rely on implicit inclusion through broad statements like "all properties owned by Company X." Explicit inclusion prevents researchers from testing assets that are out of scope and prevents the program from receiving submissions on assets that cannot be tested.

**Principle 2: Explicit Exclusion**
Every asset, application, and endpoint that is out of scope must be explicitly listed. Common exclusions include: third-party services, deprecated applications, internal infrastructure, and assets with active compliance requirements. Explicit exclusion prevents confusion and provides a clear reference for triage decisions.

**Principle 3: Boundary Documentation**
For each in-scope asset, document the testing boundaries. This includes: testing hours, permitted testing methods, data handling requirements, and any specific restrictions. Boundaries should be specific enough that a researcher can determine whether a proposed test is within scope without contacting the program.

**Principle 4: Change Notification**
When scope changes are made, notify all active researchers immediately and maintain a public changelog that documents all scope modifications with dates and reasons. Scope changes without notification are a leading cause of duplicate submissions and out-of-scope testing.

#### 1.2 Scope Definition Template

```
## Program Scope

### In-Scope Assets
| Asset | URL/Endpoint | Bounty Tier | Testing Boundaries |
|-------|-------------|-------------|-------------------|
| [Asset Name] | [URL] | [Tier] | [Boundaries] |
| [Asset Name] | [URL] | [Tier] | [Boundaries] |

### Out-of-Scope Assets
| Asset | Reason | Alternative Reporting |
|-------|--------|----------------------|
| [Asset Name] | [Reason] | [Channel] |
| [Asset Name] | [Reason] | [Channel] |

### Testing Boundaries
- **Permitted Methods**: [List specific permitted testing methods]
- **Prohibited Methods**: [List specific prohibited testing methods]
- **Testing Hours**: [Hours during which active testing is permitted]
- **Data Requirements**: [Requirements for handling any data encountered during testing]
- **Rate Limiting**: [Maximum request rates for testing activities]

### Scope Changes
| Date | Change | Reason | Notification Method |
|------|--------|--------|-------------------|
| [Date] | [Description] | [Reason] | [Method] |
```

#### 1.3 Scope Ambiguity Resolution Protocol

When scope ambiguity is identified, implement a structured resolution process:

1. **Immediate Assessment**: Determine whether the ambiguity affects active submissions or is a prospective issue
2. **Researcher Communication**: Notify affected researchers of the ambiguity and request they hold active testing pending resolution
3. **Stakeholder Alignment**: Convene the program governance team (security, legal, engineering, product) to resolve the ambiguity
4. **Documentation Update**: Update the scope documentation with clear, unambiguous language
5. **Researcher Notification**: Communicate the resolution to affected researchers and the broader community
6. **Retrospective Review**: Assess whether the ambiguity was preventable and update scope documentation practices accordingly

### Phase 2: Severity Assessment Framework

#### 2.1 Severity Assessment Principles

Consistent severity assessment is essential for researcher trust and program credibility. Inconsistent assessments create bounty disputes, researcher frustration, and program reputation damage.

**Principle 1: Objective Criteria**
Severity assessments should be based on objective, measurable criteria rather than subjective judgments. Define specific criteria for each severity level that can be consistently applied by different triagers.

**Principle 2: CVSS Alignment**
Align severity assessments with CVSS v3.1 scoring where applicable, but supplement CVSS with program-specific criteria that account for organizational risk factors. Pure CVSS scores may not accurately reflect the business impact of vulnerabilities in specific organizational contexts.

**Principle 3: Consistency Over Speed**
Prioritize assessment consistency over assessment speed. A consistent assessment delivered in 48 hours is preferable to an inconsistent assessment delivered in 24 hours. Consistency builds researcher trust; inconsistency destroys it.

**Principle 4: Transparent Methodology**
Publish the severity assessment methodology so researchers can understand how assessments are made. Transparency reduces disputes and helps researchers focus on high-impact findings.

#### 2.2 Severity Classification Matrix

| Severity | CVSS Range | Impact Criteria | Exploitability Criteria | Bounty Range |
|----------|-----------|-----------------|------------------------|--------------|
| Critical | 9.0-10.0 | Full system compromise, mass data exposure, complete authentication bypass | Low complexity, no authentication required, public exploit available | $5,000-$25,000 |
| High | 7.0-8.9 | Significant data exposure, privilege escalation, partial authentication bypass | Moderate complexity, low-privileged access required | $1,500-$5,000 |
| Medium | 4.0-6.9 | Limited data exposure, denial of service, information disclosure | High complexity, specific conditions required | $500-$1,500 |
| Low | 0.1-3.9 | Minimal impact, best practice violations, theoretical issues | Very high complexity, unlikely exploitation | $100-$500 |
| Informational | 0.0 | No direct security impact, defense-in-depth recommendations | N/A | Recognition only |

#### 2.3 Severity Override Process

When a triager determines that the standard severity criteria do not accurately reflect the impact of a specific finding, implement a structured override process:

1. **Override Request**: Triager documents the specific reasons the standard criteria do not apply
2. **Evidence Submission**: Triager provides supporting evidence for the override (e.g., unique business context, additional impact analysis)
3. **Peer Review**: A second triager reviews the override request and provides an independent assessment
4. **PM Approval**: The program manager approves or rejects the override with documented reasoning
5. **Researcher Notification**: The researcher is informed of the override decision with clear explanation
6. **Documentation**: The override is documented in the severity assessment log for future reference

### Phase 3: Bounty Structure Design

#### 3.1 Bounty Table Architecture

Bounty tables should be transparent, consistent, and aligned with organizational risk priorities. The table structure should be simple enough for researchers to understand but detailed enough to provide meaningful guidance.

**Tiered Bounty Table**

| Vulnerability Class | Critical | High | Medium | Low | Informational |
|---------------------|----------|------|--------|-----|---------------|
| Remote Code Execution | $10,000-$25,000 | $3,000-$8,000 | $1,000-$2,500 | $250-$750 | Recognition |
| SQL Injection | $7,500-$15,000 | $2,000-$5,000 | $750-$1,500 | $150-$400 | Recognition |
| Authentication Bypass | $7,500-$15,000 | $2,000-$5,000 | $750-$1,500 | $150-$400 | Recognition |
| Cross-Site Scripting | $2,500-$7,500 | $750-$2,500 | $250-$750 | $75-$250 | Recognition |
| Information Disclosure | $1,500-$5,000 | $500-$1,500 | $150-$500 | $50-$150 | Recognition |
| Business Logic | $5,000-$15,000 | $1,500-$5,000 | $500-$1,500 | $100-$400 | Recognition |
| CSRF | $2,500-$7,500 | $750-$2,500 | $250-$750 | $75-$250 | Recognition |

#### 3.2 Bounty Adjustment Factors

Apply bounty adjustments based on factors that increase or decrease the practical impact of findings:

**Bounty Multipliers (Increase)**

| Factor | Multiplier | Evidence Required |
|--------|-----------|-------------------|
| Affects production environment | 1.5x | Confirmation of production access |
| Affects sensitive data (PII, financial) | 1.25x | Evidence of data type exposure |
| No user interaction required | 1.25x | Demonstration of direct exploitation |
| Chain with other vulnerabilities | 1.5-2.0x | Demonstration of attack chain |
| Affects mobile application | 1.25x | Confirmation of mobile app scope |
| Public-facing endpoint | 1.25x | Confirmation of internet accessibility |

**Bounty Reductions (Decrease)**

| Factor | Reduction | Condition |
|--------|-----------|-----------|
| Requires authenticated access | 20-40% | Authentication required for exploitation |
| Requires specific user role | 10-30% | Role-based access requirement |
| Requires specific conditions | 10-25% | Environmental or configuration dependencies |
| Theoretical impact only | 30-50% | No demonstrated practical impact |
| Previously reported variant | 30-50% | Relationship to existing finding |

#### 3.3 Bounty Payment Process

Define a clear, transparent bounty payment process that researchers can follow from submission to payment.

**Payment Timeline**
- Severity assessment complete: Bounty amount determined
- Bounty notification sent: Researcher informed of amount
- Payment processing initiated: Within 5 business days of bounty determination
- Payment completed: Within 10 business days of payment initiation
- Payment confirmation: Researcher notified of payment completion

**Payment Methods**
- Primary: Platform-native payment (HackerOne, Bugcrowd, etc.)
- Alternative: Wire transfer, PayPal, cryptocurrency (where legally permitted)
- Currency: USD (or local currency equivalent based on exchange rates)

**Payment Documentation**
- Bounty determination rationale documented
- Payment approval chain documented
- Tax documentation provided where required
- Payment receipts maintained for audit purposes

### Phase 4: Researcher Agreement and Rules of Engagement

#### 4.1 Researcher Agreement Components

Every researcher must agree to a comprehensive set of rules before participating in the program. The agreement should be clear, specific, and enforceable.

**Agreement Sections**

1. **Scope and Authorization**
   - Explicit statement of authorized testing activities
   - Confirmation that testing is authorized under applicable laws
   - Definition of authorized testing windows and methods

2. **Prohibited Activities**
   - Specific activities that are not authorized (e.g., DoS, social engineering, physical access)
   - Activities that could harm other users or systems
   - Activities that violate applicable laws or regulations

3. **Data Handling Requirements**
   - Requirements for handling any data encountered during testing
   - Prohibition on exfiltrating, storing, or sharing data beyond what is necessary to demonstrate impact
   - Requirements for securely reporting any data exposure

4. **Confidentiality Obligations**
   - Obligation to keep findings confidential until coordinated disclosure
   - Prohibition on public disclosure without program authorization
   - Requirements for secure communication of findings

5. **Eligibility Requirements**
   - Age requirements (typically 18+)
   - Geographic restrictions (where legally required)
   - Exclusions for program employees and their immediate families

6. **Dispute Resolution**
   - Process for appealing triage decisions
   - Process for reporting program violations
   - Governing law and jurisdiction for disputes

#### 4.2 Rules of Engagement Document

The Rules of Engagement (RoE) document provides detailed operational guidance for researchers conducting authorized testing.

**RoE Sections**

1. **Testing Authorization**
   - Authorized testing methods (e.g., automated scanning, manual testing, fuzzing)
   - Authorized testing hours (e.g., business hours only, 24/7)
   - Rate limiting requirements (e.g., maximum requests per second)

2. **Testing Boundaries**
   - Specific endpoints and parameters that are in scope
   - Specific endpoints and parameters that are out of scope
   - Testing depth limits (e.g., maximum exploitation depth)

3. **Data Handling**
   - Maximum amount of data that may be accessed for demonstration purposes
   - Requirements for securely deleting any data accessed during testing
   - Requirements for reporting any unintended data access

4. **Incident Reporting**
   - Process for reporting unintended system damage or data access
   - Contact information for emergency situations
   - Requirements for immediate cessation of testing if unintended impact occurs

5. **Communication Protocols**
   - Primary communication channels for reporting findings
   - Process for requesting scope clarification
   - Process for reporting program violations

#### 4.3 Agreement Enforcement Mechanisms

Implement mechanisms to enforce the researcher agreement and address violations.

**Violation Classification**

| Violation Class | Examples | Consequence |
|-----------------|----------|-------------|
| Minor | Rate limiting violation, scope boundary proximity, communication protocol deviation | Warning, education |
| Moderate | DoS testing without authorization, unauthorized data access, scope boundary crossing | Temporary suspension, bounty forfeiture |
| Major | Intentional DoS, unauthorized data exfiltration, public disclosure without authorization, sharing access with others | Permanent ban, legal action |

**Enforcement Process**
1. **Detection**: Automated monitoring or manual identification of violation
2. **Assessment**: Evaluation of violation severity and intent
3. **Investigation**: Gathering evidence and context for the violation
4. **Decision**: Determining appropriate consequence based on violation class
5. **Notification**: Informing the researcher of the violation and consequence
6. **Appeal**: Providing the researcher with an opportunity to appeal the decision
7. **Documentation**: Recording the violation, investigation, and resolution

### Phase 5: Dispute Resolution Framework

#### 5.1 Dispute Categories

Categorize disputes to ensure appropriate resolution processes for each type.

**Category 1: Severity Disputes**
- Researcher disagrees with assigned severity
- Resolution: Peer review, PM override, documented reasoning
- Timeline: Resolution within 5 business days of appeal

**Category 2: Scope Disputes**
- Researcher believes finding is within scope; program believes it is out of scope
- Resolution: Scope documentation review, stakeholder alignment, documented decision
- Timeline: Resolution within 10 business days of appeal

**Category 3: Bounty Disputes**
- Researcher disagrees with bounty amount
- Resolution: Bounty calculation review, adjustment factors analysis, documented reasoning
- Timeline: Resolution within 5 business days of appeal

**Category 4: Duplicate Disputes**
- Researcher disagrees with duplicate determination
- Resolution: Original report review, similarity analysis, independent assessment
- Timeline: Resolution within 5 business days of appeal

**Category 5: Policy Violation Disputes**
- Researcher disputes a policy violation accusation
- Resolution: Evidence review, independent investigation, documented decision
- Timeline: Resolution within 15 business days of appeal

#### 5.2 Dispute Resolution Process

Implement a structured dispute resolution process that ensures fairness, consistency, and timeliness.

**Step 1: Initial Appeal**
- Researcher submits appeal through designated channel
- Appeal must include: specific finding ID, nature of dispute, supporting evidence, desired outcome
- Program acknowledges receipt within 24 hours

**Step 2: Review Assignment**
- Appeal is assigned to a reviewer who was not involved in the original assessment
- Reviewer has access to all original submission data, triage notes, and researcher appeal
- Reviewer has authority to make binding decisions for disputes within their tier

**Step 3: Independent Assessment**
- Reviewer conducts independent assessment of the disputed element
- Reviewer documents their analysis and comparison with the original assessment
- Reviewer determines whether the original assessment was appropriate

**Step 4: Decision**
- Reviewer makes a binding decision with documented reasoning
- Decision is communicated to the researcher within the specified timeline
- Decision includes: outcome, reasoning, any bounty adjustments, and information about further appeal options

**Step 5: Final Appeal (if applicable)**
- For disputes involving significant bounty amounts or policy interpretation, a final appeal to the program director may be available
- Final appeal decisions are binding and not subject to further appeal

### Phase 6: Iterative Rule Refinement

#### 6.1 Rule Review Cadence

Implement a structured cadence for reviewing and updating program rules.

**Monthly Reviews**
- Review all disputes from the past month to identify rule ambiguities
- Review submission patterns to identify scope confusion areas
- Review researcher feedback for rule improvement suggestions
- Update known issues database based on triage decisions

**Quarterly Reviews**
- Comprehensive review of all program rules
- Analysis of duplicate rates, out-of-scope rates, and dispute rates
- Researcher survey analysis for rule satisfaction
- Benchmarking against industry best practices and peer programs

**Annual Reviews**
- Full program rule overhaul based on 12 months of operational data
- Stakeholder alignment review with legal, engineering, product, and executive teams
- Regulatory compliance review for applicable data protection and security regulations
- Researcher community consultation on rule changes

#### 6.2 Rule Change Management

Implement a structured process for managing rule changes that maintains researcher trust and program stability.

**Change Categories**

| Category | Impact | Notice Period | Approval Required |
|----------|--------|---------------|-------------------|
| Clarification | No functional change | Immediate | PM approval |
| Minor adjustment | Small bounty or scope change | 30 days | PM + Security Lead approval |
| Major adjustment | Significant bounty, scope, or policy change | 60 days | Program governance board approval |
| Emergency change | Immediate safety or compliance requirement | Immediate | CISO approval + retrospective governance review |

**Change Communication**
- All changes documented in a public changelog
- Significant changes announced via program mailing list and platform announcements
- Changes communicated with clear rationale and effective dates
- Researcher questions addressed through a dedicated Q&A channel

#### 6.3 Rule Effectiveness Measurement

Measure the effectiveness of program rules through quantitative and qualitative metrics.

**Quantitative Metrics**
- Out-of-scope submission rate (target: < 15%)
- Dispute rate (target: < 5% of submissions)
- Duplicate submission rate (target: < 10%)
- Average triage time per submission (target: < 5 business days)
- Bounty accuracy rate (target: > 90% first-assessment accuracy)
- Researcher churn rate (target: < 20% annually)

**Qualitative Metrics**
- Researcher satisfaction survey scores (target: > 4.0/5.0)
- Researcher community sentiment analysis (target: positive sentiment > 70%)
- Internal stakeholder satisfaction (target: > 4.0/5.0)
- Program reputation assessment (target: top quartile for program category)

---

## Real-World Examples

### Example 1: Scope Ambiguity Leading to Mass Out-of-Scope Submissions

A large e-commerce platform defined their bug bounty scope as "all web properties owned by Company X." This broad definition led to significant confusion when researchers submitted findings on a recently acquired subsidiary's platform that had not yet been integrated into the company's security infrastructure. Within 3 weeks, the program received 89 submissions targeting the subsidiary's platform, none of which could be triaged because the platform was not yet covered by the company's security monitoring and incident response capabilities.

The program was forced to close all 89 submissions as out-of-scope, resulting in significant researcher frustration and negative community sentiment. Several researchers had invested significant time in finding and documenting vulnerabilities that the program could not accept. The program's NPS score dropped from +42 to -8 within a month.

The program subsequently implemented an explicit asset-by-asset scope definition with clear documentation of which specific applications, APIs, and domains were in scope. They also created a scope change notification system that alerts researchers within 24 hours of any scope modification. This reduced out-of-scope submissions from 23% to 7% of total submissions within 3 months.

### Example 2: Inconsistent Severity Assessment Creating Bounty Disputes

A financial technology company had severity assessment criteria that included both CVSS-based scoring and subjective "business impact" adjustments. The subjective component led to significant inconsistencies between triagers, where the same vulnerability class received different severity assessments depending on which triager reviewed it. Within a 6-month period, the program received 47 bounty disputes, of which 31 were related to perceived severity inconsistency.

The disputes created significant operational overhead and damaged researcher trust. Several high-profile researchers publicly criticized the program's assessment consistency, leading to reduced participation from experienced hunters who preferred programs with more predictable bounty outcomes.

The program responded by implementing a structured severity assessment matrix that reduced subjective judgment to a minimum. The matrix defined specific criteria for each severity level that could be consistently applied, with a formal override process for exceptional cases. They also implemented peer review for all severity assessments above Medium, which caught 89% of potential inconsistencies before they resulted in bounty notifications. Dispute rates dropped from 12% to 3% of submissions within 6 months.

### Example 3: Overly Restrictive Rules Driving Researcher Attrition

A healthcare technology company implemented extremely restrictive testing rules in response to compliance concerns. The rules prohibited: any automated scanning, testing during business hours, testing with any tool that could generate more than 10 requests per minute, and any testing that could access real patient data even for demonstration purposes. These restrictions made it virtually impossible for researchers to find meaningful vulnerabilities.

Within 3 months, the program's active researcher base dropped by 72%, and submission quality declined dramatically. The remaining researchers submitted only superficial findings that did not require the deep testing that had previously identified critical vulnerabilities. The program's finding value dropped by 85% compared to the previous quarter.

The company conducted a comprehensive review of their compliance requirements and discovered that many of the restrictions were based on misinterpretations of applicable regulations. After consulting with their legal and compliance teams, they revised the rules to permit automated scanning with rate limits, testing during extended hours, and testing with synthetic data sets that mimicked production data without exposing real patient information. Within 6 months of the revision, the researcher base recovered to 110% of pre-restriction levels, and submission quality returned to baseline.

### Example 4: Vague Prohibited Activities Leading to Enforcement Disputes

A technology company's prohibited activities section stated: "Do not perform any testing that could disrupt services or access data belonging to other users." This vague prohibition led to a high-profile enforcement incident where a researcher was permanently banned for accessing data that the researcher believed was within scope and authorized for testing. The researcher had discovered an API endpoint that returned user profile data, and they accessed a small sample of profiles to demonstrate the vulnerability's impact.

The program's enforcement team determined that the researcher had violated the prohibited activities clause by accessing data belonging to other users. The researcher appealed, arguing that the API endpoint was in scope, that accessing a small sample was necessary to demonstrate impact, and that the prohibition on accessing other users' data was not clearly communicated. The dispute escalated to legal review, resulting in significant costs for both parties and negative publicity for the program.

The company subsequently revised their prohibited activities section with specific, unambiguous language: "Do not access, copy, store, or transmit any data belonging to other users beyond the minimum necessary to demonstrate the vulnerability's impact. Do not access data belonging to more than 3 test accounts. Do not exfiltrate any user data from the testing environment." They also implemented a tiered enforcement process with graduated consequences and mandatory investigation before any permanent ban.

### Example 5: Successful Rule Framework Implementation

A cloud infrastructure provider launched their bug bounty program with a comprehensive rule framework developed using the methodology described in this guide. The framework included: explicit asset-by-asset scope documentation, a detailed severity assessment matrix with specific criteria, a transparent bounty table with clear adjustment factors, comprehensive researcher agreements, and a structured dispute resolution process.

The program invested heavily in researcher education during the first quarter, including: a detailed onboarding tutorial, monthly "Rule Clarification" webinars, a searchable FAQ addressing common rule questions, and a dedicated support channel for rule-related inquiries. They also implemented automated tools that helped researchers verify scope alignment, estimate severity, and check for potential duplicates before submission.

Within 6 months, the program achieved: an out-of-scope rate of 6% (well below the industry average of 15%), a dispute rate of 2% (well below the industry average of 8%), a researcher NPS of +58 (well above the industry average of +25), and a submission quality score of 8.2/10 (well above the industry average of 6.5/10). The program was cited as a model for rule framework implementation at multiple industry conferences.

---

## Best Practices

### Practice 1: Explicit Scope Documentation

Every asset, application, and endpoint in scope must be explicitly listed with clear boundaries. Do not rely on implicit inclusion through broad statements. Explicit documentation reduces out-of-scope submissions, researcher confusion, and triage inconsistency. Maintain a scope changelog that documents all modifications with dates, reasons, and notification methods.

### Practice 2: Consistent Severity Assessment

Implement a structured severity assessment matrix with specific, measurable criteria for each severity level. Reduce subjective judgment through clear criteria definitions and mandatory peer review for high-severity assessments. Track severity consistency metrics and address discrepancies through training and process refinement.

### Practice 3: Transparent Bounty Structure

Publish bounty tables that researchers can use to estimate bounty amounts before submission. Include clear adjustment factors that increase or decrease bounties based on specific criteria. Maintain consistency in bounty determinations and document the rationale for each bounty decision.

### Practice 4: Comprehensive Researcher Agreements

Require researchers to agree to clear, specific rules before participating. The agreement should cover scope, prohibited activities, data handling, confidentiality, eligibility, and dispute resolution. The agreement should be written in plain language that researchers can understand without legal expertise.

### Practice 5: Structured Dispute Resolution

Implement a fair, consistent, and timely dispute resolution process. Ensure that disputes are reviewed by individuals who were not involved in the original assessment. Document dispute decisions with clear reasoning and provide researchers with appeal opportunities.

### Practice 6: Iterative Rule Refinement

Review program rules regularly based on operational data, researcher feedback, and industry best practices. Implement rule changes through a structured change management process that includes appropriate notice periods and stakeholder alignment. Measure the effectiveness of rule changes through quantitative and qualitative metrics.

### Practice 7: Researcher Education Investment

Invest in comprehensive researcher education that covers program rules, scope details, severity assessment criteria, and common mistakes. Education is the most cost-effective mechanism for reducing out-of-scope submissions, duplicates, and disputes. Track education engagement metrics and correlate them with submission quality metrics.

---

## Common Mistakes

**Mistake 1: Overly Broad Scope Definitions**

Many programs use broad scope statements like "all web properties owned by Company X" instead of explicitly listing each in-scope asset. Broad definitions create ambiguity that leads to out-of-scope submissions, researcher confusion, and triage inconsistency. Every in-scope asset should be explicitly listed with clear boundaries.

**Mistake 2: Subjective Severity Assessment**

Programs that rely heavily on subjective severity judgments produce inconsistent assessments that damage researcher trust. Implement a structured severity assessment matrix with specific, measurable criteria that reduce subjective judgment. Where subjective factors must be considered, implement a formal override process with peer review.

**Mistake 3: Punitive Enforcement Without Investigation**

Enforcing researcher agreement violations without thorough investigation creates an adversarial relationship with the researcher community. Every enforcement action should be preceded by a complete investigation that considers intent, impact, and context. Graduated consequences are more appropriate than immediate permanent bans for most violations.

**Mistake 4: Rules Written in Legal Language**

Program rules written in dense legal language are difficult for researchers to understand and follow. Rules should be written in plain language that researchers can understand without legal expertise. Where legal precision is necessary, provide both a legal version and a plain-language summary.

**Mistake 5: Not Updating Rules for Scope Changes**

When program scope changes, many programs fail to update their rules documentation promptly. This creates a window where researchers are operating under outdated rules, leading to out-of-scope submissions and scope confusion. Implement a change management process that ensures rules documentation is updated within 24 hours of any scope change.

**Mistake 6: Ignoring Researcher Feedback on Rules**

Programs that do not actively solicit and consider researcher feedback on rules miss opportunities for improvement. Researchers are the primary users of program rules and have valuable insights into rule clarity, ambiguity, and operational impact. Implement regular feedback mechanisms and demonstrably respond to researcher suggestions.

**Mistake 7: Inconsistent Bounty Determinations**

Inconsistent bounty determinations for similar findings damage program credibility and researcher trust. Implement a bounty table with clear adjustment factors, and ensure that all bounty determinations are documented with specific reasoning. Track bounty consistency metrics and address discrepancies through training and process refinement.

---

## Advanced Techniques

### Technique 1: Dynamic Scope Management

Implement a dynamic scope management system that automatically adjusts program scope based on organizational risk signals. The system should consider: vulnerability scan results, threat intelligence feeds, organizational risk assessments, and historical submission patterns to dynamically adjust scope boundaries.

For example, if vulnerability scan results indicate that a particular application has a high concentration of unpatched components, the system could automatically expand the bounty tier for that application to incentivize deeper testing. Conversely, if an application is scheduled for decommission, the system could automatically narrow the scope to focus testing on migration-critical functionality.

### Technique 2: Researcher Reputation-Based Rule Adaptation

Implement a reputation-based system that adapts rules based on researcher history and reliability. Researchers with high-quality submission histories, low dispute rates, and strong community reputation could receive: extended testing hours, access to advanced testing tools, direct communication channels with the triage team, and higher bounty tiers for equivalent findings.

This approach rewards researcher loyalty and quality while maintaining standard rules for newer or less proven researchers. The reputation system should be transparent, with researchers able to view their own reputation metrics and understand how to improve their standing.

### Technique 3: Automated Rule Compliance Checking

Build automated tools that check submissions against program rules before they enter the triage queue. The tools should verify: scope alignment, testing boundary compliance, data handling requirements, and communication protocol adherence. Submissions that fail automated compliance checks should be flagged for triager review with specific compliance issues documented.

This approach catches rule violations early in the submission lifecycle, reducing triage waste and providing researchers with immediate feedback on compliance issues. The compliance checking tools should be trained on historical submission data and validated against human triager assessments.

### Technique 4: Cross-Program Rule Harmonization

For organizations running multiple bug bounty programs across different business units or product lines, implement rule harmonization that ensures consistent application of core policies while allowing program-specific customization. Harmonization should cover: severity assessment criteria, bounty structures, dispute resolution processes, and enforcement mechanisms.

This approach reduces operational overhead, ensures organizational consistency, and makes it easier for researchers who participate in multiple programs to understand and follow the rules. The harmonization framework should include a "core rules" document that applies to all programs and "program-specific rules" documents that address unique requirements for each program.

---

## Tools and Resources

### Policy and Documentation Tools
- **Confluence/Notion**: Policy documentation, version control, stakeholder collaboration
- **GitHub**: Policy-as-code approach with version control and change tracking
- **GitBook**: Public-facing program documentation with researcher-friendly navigation
- **SharePoint**: Enterprise policy management with approval workflows

### Scope Management Tools
- **Custom Web Applications**: Asset inventory management with scope tagging
- **Platform Scope Configuration**: HackerOne, Bugcrowd scope management features
- **Asset Discovery Tools**: Automated discovery of organizational assets for scope coverage
- **Configuration Management Databases (CMDB)**: Integration with organizational asset management

### Severity Assessment Tools
- **CVSS Calculators**: Standardized severity scoring tools
- **Custom Assessment Platforms**: Purpose-built severity assessment interfaces
- **Machine Learning Models**: Automated severity estimation based on historical data
- **Peer Review Systems**: Workflow tools for mandatory peer review of assessments

### Researcher Communication Tools
- **Email Automation**: Automated rule notifications and scope change alerts
- **FAQ Systems**: Searchable knowledge bases for rule-related questions
- **Webinar Platforms**: Regular rule clarification sessions with researchers
- **Support Ticketing Systems**: Structured rule-related inquiry management

### Analytics and Monitoring Tools
- **Grafana/PowerBI**: Rule effectiveness dashboards
- **Custom Analytics**: Submission pattern analysis, dispute tracking, churn analysis
- **Sentiment Analysis**: Researcher community sentiment monitoring
- **Benchmarking Platforms**: Industry comparison and best practice identification

---

## Metrics and KPIs

### Primary KPIs

| Metric | Target | Measurement Frequency | Data Source |
|--------|--------|----------------------|-------------|
| Out-of-Scope Submission Rate | < 10% | Weekly | Triage system |
| Dispute Rate | < 3% | Monthly | Dispute tracking |
| Severity Consistency Rate | > 95% | Monthly | Peer review audits |
| Bounty Accuracy Rate | > 90% | Monthly | Bounty audit |
| Researcher Agreement Completion Rate | 100% | Weekly | Agreement tracking |
| Rule Clarity Score | > 4.0/5.0 | Quarterly | Researcher survey |

### Secondary KPIs

| Metric | Target | Measurement Frequency | Data Source |
|--------|--------|----------------------|-------------|
| Scope Change Notification Compliance | 100% | Per change | Notification tracking |
| Dispute Resolution Time | < 5 business days | Monthly | Dispute tracking |
| Enforcement Investigation Time | < 10 business days | Monthly | Enforcement tracking |
| Rule Documentation Currency | < 30 days since last update | Monthly | Documentation audit |
| Researcher Education Completion | > 70% | Quarterly | Education platform |
| Program Reputation Score | Top quartile | Quarterly | Industry benchmarks |

### Tracking Methods

1. **Automated Logging**: Log all rule-related events (submissions, disputes, enforcements, changes)
2. **Periodic Audits**: Monthly audit of rule consistency and compliance
3. **Researcher Surveys**: Quarterly surveys on rule clarity, fairness, and satisfaction
4. **Triage Reviews**: Monthly review of a random sample of 30 submissions for rule application consistency
5. **Dispute Analysis**: Quarterly analysis of dispute patterns and root causes
6. **Benchmarking**: Annual comparison against industry peers and best practices

---

## Implementation Checklist

### Phase 1: Foundation (Weeks 1-6)
- [ ] Define scope documentation template and populate for all in-scope assets
- [ ] Create severity assessment matrix with specific criteria for each level
- [ ] Design bounty table with clear adjustment factors
- [ ] Draft researcher agreement covering all required sections
- [ ] Create Rules of Engagement document with operational guidance
- [ ] Establish dispute resolution process with clear timelines

### Phase 2: Documentation (Weeks 7-12)
- [ ] Publish all rule documents in a researcher-accessible format
- [ ] Create FAQ addressing common rule-related questions
- [ ] Build scope verification tool for researchers
- [ ] Implement severity estimation tool for pre-submission assessment
- [ ] Design researcher onboarding program covering all rules
- [ ] Establish rule change notification system

### Phase 3: Enforcement (Weeks 13-18)
- [ ] Implement automated rule compliance checking for submissions
- [ ] Create enforcement workflow with investigation requirements
- [ ] Train triage team on rule application and enforcement
- [ ] Establish tiered enforcement consequences for violations
- [ ] Build appeal process for enforcement decisions
- [ ] Document enforcement cases for future reference

### Phase 4: Optimization (Weeks 19-26)
- [ ] Analyze first 6 months of operational data to identify rule improvements
- [ ] Conduct first quarterly researcher survey on rule satisfaction
- [ ] Review and revise rules based on survey results and operational data
- [ ] Implement rule effectiveness measurement dashboard
- [ ] Establish annual rule review process with stakeholder alignment
- [ ] Create cross-program rule harmonization framework (if applicable)

---

## Quick Reference Cheat Sheet

### Scope Documentation
- **In-Scope**: Explicitly list every asset, endpoint, and application
- **Out-of-Scope**: Explicitly list excluded assets with reasons
- **Boundaries**: Define testing hours, methods, and restrictions for each asset
- **Changes**: Maintain public changelog with dates and reasons

### Severity Assessment
- **Critical (9.0-10.0)**: Full compromise, mass data exposure → $5,000-$25,000
- **High (7.0-8.9)**: Significant data/privilege impact → $1,500-$5,000
- **Medium (4.0-6.9)**: Limited impact, specific conditions → $500-$1,500
- **Low (0.1-3.9)**: Minimal impact, best practice violations → $100-$500
- **Informational (0.0)**: No direct impact → Recognition

### Bounty Adjustments
- **Multipliers**: Production (1.5x), Sensitive data (1.25x), No auth (1.25x), Chain (1.5-2x)
- **Reductions**: Auth required (20-40%), Specific role (10-30%), Theoretical (30-50%)

### Dispute Resolution
- **Severity**: Peer review → PM override → 5 business days
- **Scope**: Documentation review → Stakeholder alignment → 10 business days
- **Bounty**: Calculation review → Adjustment analysis → 5 business days
- **Duplicate**: Original report review → Independent assessment → 5 business days
- **Enforcement**: Evidence review → Independent investigation → 15 business days

### Enforcement Consequences
- **Minor**: Warning, education
- **Moderate**: Temporary suspension, bounty forfeiture
- **Major**: Permanent ban, legal action
