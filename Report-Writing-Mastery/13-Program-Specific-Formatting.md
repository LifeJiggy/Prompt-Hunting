# Chapter 13: Program-Specific Formatting

## Expert Role (15)

Every bug bounty platform has its own submission standards, triage expectations, and reporting conventions. A report that excels on HackerOne may fail on Bugcrowd if the researcher doesn't adapt to the platform's specific requirements. The expert researcher maintains a mental library of platform-specific formatting rules and adjusts every submission accordingly.

Understanding program-specific formatting isn't just about compliance—it's about communication efficiency. Triage teams process hundreds of reports weekly. When your report follows their expected format, they can focus on the vulnerability rather than decoding your structure. This reduces triage time, increases acceptance rates, and often leads to faster bounty payments.

The seasoned researcher also understands that individual programs within a platform may have additional requirements. A program's vulnerability disclosure policy (VDP) may specify preferred report structures, required fields, or documentation standards. Ignoring these program-specific requirements—even when the platform technically accepts other formats—signals carelessness and can lead to slower triage or lower severity assessments.

This chapter provides comprehensive guidance for adapting reports to HackerOne, Bugcrowd, Intigriti, and Immunefi, including platform-specific templates, VRT mapping strategies, and program-specific customization techniques.

## Core Concepts (40)

### 13.1 HackerOne Report Formatting

HackerOne is the largest bug bounty platform with standardized submission requirements. Understanding its structure is essential for every researcher.

**Required fields**:
- **Title**: Concise, descriptive vulnerability title
- **Vulnerability Type**: Select from HackerOne's taxonomy
- **Severity**: Self-assessed severity (CVSS recommended)
- **Weakness**: CWE classification
- **Impact**: Clear description of business impact
- **Step-by-step Instructions**: Detailed reproduction steps
- **Supporting Material**: Screenshots, videos, code snippets

**HackerOne-specific conventions**:
- Use the structured report template provided
- Include CVSS vector string for severity justification
- Reference CWE IDs for weakness classification
- Provide complete HTTP requests (not truncated)
- Include response snippets that demonstrate the vulnerability

**Program-specific variations**:
- Some programs require specific templates
- Asset scope is clearly defined in the program policy
- Bounty ranges are published for different severity levels
- Disclosure timelines are specified in the program policy

### 13.2 Bugcrowd Report Formatting

Bugcrowd uses its own Vulnerability Rating Taxonomy (VRT) for classification, which differs from CWE-based systems.

**Required fields**:
- **Vulnerability Title**: Clear, descriptive title
- **VRT Category**: Classification using Bugcrowd's VRT
- **Impact**: Detailed impact description
- **Detailed Description**: Complete vulnerability explanation
- **Remediation Recommendation**: Suggested fixes
- **Supporting Information**: Evidence and reproduction steps

**Bugcrowd-specific conventions**:
- Map findings to VRT categories (not CWE)
- Include severity override justification if VRT default doesn't match your assessment
- Provide clear, actionable remediation recommendations
- Use the Bugcrowd report template when available

**VRT mapping strategy**:
- Identify the closest VRT category
- If no exact match exists, use the most relevant category
- Document why the VRT default severity may need adjustment
- Reference supporting evidence for severity justification

### 13.3 Intigriti Report Formatting

Intigriti provides flexible report submission with an emphasis on quality over rigid structure.

**Required fields**:
- **Title**: Descriptive vulnerability title
- **Severity**: Self-assessed severity with justification
- **Type**: Vulnerability classification
- **Description**: Complete vulnerability explanation
- **Steps to Reproduce**: Detailed reproduction instructions
- **Impact**: Business and technical impact

**Intigriti-specific conventions**:
- Emphasis on clear, well-structured reports
- Support for markdown formatting in reports
- Flexible evidence attachment options
- Program-specific requirements vary significantly

**Intigriti best practices**:
- Follow the program's specific instructions when provided
- Use markdown formatting for readability
- Include both technical and business impact
- Provide clear, actionable remediation guidance

### 13.4 Immunefi Report Formatting

Immunefi focuses on web3 and DeFi bug bounty programs, with specific requirements for smart contract and blockchain vulnerabilities.

**Required fields**:
- **Title**: Descriptive vulnerability title
- **Severity**: CVSS-based severity with justification
- **Vulnerability Type**: Classification (reentrancy, access control, etc.)
- **Impact**: Financial impact quantification
- **Root Cause**: Technical explanation of the vulnerability
- **Attack Path**: Step-by-step exploitation guide
- **Code Snippets**: Relevant vulnerable code
- **Recommended Fix**: Specific remediation guidance

**Immunefi-specific conventions**:
- Emphasis on financial impact quantification
- Detailed attack path documentation
- Code-level vulnerability explanation
- Smart contract-specific vulnerability classifications
- On-chain and off-chain vulnerability distinction

**DeFi-specific considerations**:
- Economic impact calculation (TVL at risk, exploit value)
- Flash loan attack scenarios
- Oracle manipulation vectors
- Governance attack vectors
- Cross-chain vulnerability implications

### 13.5 Cross-Platform Adaptation Principles

**Universal formatting elements**:
1. Clear, descriptive titles that convey the vulnerability class
2. Detailed reproduction steps that enable independent verification
3. Complete technical evidence (HTTP requests, responses, screenshots)
4. Impact assessment that quantifies business risk
5. Remediation recommendations that are actionable

**Platform-specific adjustments**:
1. Classification taxonomy (CWE vs. VRT vs. platform-specific)
2. Severity assessment methodology (CVSS vs. platform-specific)
3. Evidence format preferences (screenshots, videos, code snippets)
4. Report structure requirements (fixed template vs. flexible)
5. Communication conventions (formal vs. conversational)

### 13.6 VRT Mapping Strategies

When mapping to Bugcrowd's VRT:
1. Identify the core vulnerability class
2. Find the most specific VRT category
3. If no exact match exists, use the parent category
4. Document the mapping rationale in the report
5. Justify severity override if the default doesn't match impact

**Common VRT mapping challenges**:
- Business logic vulnerabilities may not have exact VRT matches
- Chain attacks may span multiple VRT categories
- Novel vulnerability classes may require creative mapping
- Severity defaults may not reflect specific program impact

### 13.7 Program-Specific Template Customization

Even within a platform, individual programs may have custom requirements:

**Identifying program requirements**:
- Read the program's vulnerability disclosure policy thoroughly
- Review the program's FAQ and submission guidelines
- Check for program-specific templates or forms
- Note any required fields or documentation
- Understand the program's preferred communication channels

**Adapting to program requirements**:
- Use program-provided templates when available
- Follow program-specific severity guidelines
- Include program-requested documentation
- Adhere to program-specific evidence requirements
- Respect program-specific disclosure timelines

## Prerequisites (20)

Before adapting reports to specific programs, ensure you have:

1. **Platform account setup**: Active accounts on target platforms (HackerOne, Bugcrowd, Intigriti, Immunefi)
2. **Platform familiarization**: Review 20+ accepted reports on each platform to understand formatting conventions
3. **VRT taxonomy knowledge**: Understand Bugcrowd's Vulnerability Rating Taxonomy
4. **CWE familiarity**: Know common CWE classifications used in vulnerability reporting
5. **CVSS competency**: Ability to calculate and justify CVSS scores
6. **Markdown proficiency**: Ability to format reports using markdown syntax
7. **HTTP request documentation**: Ability to capture and format complete HTTP requests
8. **Screenshot capture skills**: Ability to capture and annotate relevant screenshots
9. **Video recording capability**: Ability to record PoC demonstrations when required
10. **Code snippet formatting**: Ability to include code snippets with proper syntax highlighting
11. **Report template awareness**: Knowledge of platform-provided report templates
12. **Program policy review habits**: Regular review of program-specific requirements
13. **Severity justification skills**: Ability to justify severity assessments with evidence
14. **Impact quantification ability**: Ability to quantify business impact of vulnerabilities
15. **Remediation recommendation skills**: Ability to provide actionable fix recommendations
16. **Evidence organization skills**: Ability to organize evidence logically
17. **Technical writing clarity**: Ability to explain complex vulnerabilities clearly
18. **Platform-specific submission process knowledge**: Understanding of each platform's submission workflow
19. **Triage process understanding**: Knowledge of how each platform's triage process works
20. **Bounty calculation awareness**: Understanding of bounty structures on different platforms

## Methodology (60)

### Phase 1: Platform Analysis

**Step 1: Review platform documentation**
Before submitting to any platform, thoroughly review:
- Platform submission guidelines
- Report structure requirements
- Classification taxonomies
- Severity assessment methodology
- Evidence requirements
- Communication protocols

**Step 2: Study accepted reports**
Analyze 20+ accepted reports on each target platform to understand:
- Formatting conventions
- Evidence presentation styles
- Severity assessment patterns
- Impact documentation approaches
- Remediation recommendation formats

**Step 3: Identify platform-specific requirements**
Document platform-specific requirements for:
- Required fields and sections
- Classification systems (CWE, VRT, platform-specific)
- Severity assessment methodology
- Evidence format preferences
- Report structure templates

### Phase 2: Program Analysis

**Step 4: Read the program's vulnerability disclosure policy**
Before testing any program, thoroughly review:
- Scope definition (in-scope and out-of-scope assets)
- Vulnerability types accepted
- Severity guidelines and bounty ranges
- Submission instructions
- Disclosure timelines
- Legal terms and conditions

**Step 5: Identify program-specific templates**
Check if the program provides:
- Custom report templates
- Required documentation checklists
- Severity classification guidelines
- Evidence format requirements
- Communication preferences

**Step 6: Analyze program history**
Review the program's history to understand:
- Common vulnerability types accepted
- Typical severity distribution
- Bounty payment patterns
- Triage process timelines
- Communication style preferences

### Phase 3: Report Adaptation

**Step 7: Select appropriate template**
Based on platform and program analysis:
- Use platform-provided template when available
- Adapt standard template to program requirements
- Ensure all required fields are included
- Follow program-specific formatting guidelines

**Step 8: Map vulnerability classification**
Correctly classify the vulnerability:
- Map to appropriate CWE (HackerOne)
- Map to appropriate VRT category (Bugcrowd)
- Use program-specific classifications when provided
- Document mapping rationale when classification is ambiguous

**Step 9: Assess severity using platform methodology**
Calculate severity using the appropriate methodology:
- CVSS 3.1 scoring (HackerOne, Immunefi)
- VRT default severity (Bugcrowd)
- Program-specific severity guidelines
- Justify severity assessment with evidence

**Step 10: Structure reproduction steps**
Format reproduction steps according to platform conventions:
- Use numbered steps for sequential actions
- Include complete HTTP requests and responses
- Note expected vs. actual behavior
- Include all necessary context for independent reproduction

### Phase 4: Evidence Preparation

**Step 11: Capture and format evidence**
Prepare evidence according to platform preferences:
- Screenshots with clear annotations
- Video demonstrations for complex exploitation paths
- Code snippets with syntax highlighting
- HTTP request/response pairs with headers
- Database query results when relevant

**Step 12: Organize evidence logically**
Structure evidence to support the report narrative:
- Evidence should follow the reproduction steps
- Each evidence item should be clearly labeled
- Evidence should be sufficient for independent verification
- Include both positive and negative evidence where relevant

### Phase 5: Quality Assurance

**Step 13: Platform compliance check**
Verify the report meets platform requirements:
- All required fields are completed
- Classification is correct and justified
- Severity assessment is supported by evidence
- Evidence meets platform format requirements
- Report follows platform-specific conventions

**Step 14: Program compliance check**
Verify the report meets program requirements:
- Vulnerability is within program scope
- Report follows program-specific instructions
- Severity aligns with program guidelines
- Evidence meets program-specific requirements
- Disclosure timeline is respected

**Step 15: Technical accuracy verification**
Before submission, verify:
- All reproduction steps are accurate
- All technical claims are verifiable
- All evidence is genuine and unaltered
- All code snippets are correct
- All screenshots are current and relevant

### Phase 6: Submission

**Step 16: Submit through the correct channel**
Use the platform's official submission process:
- Submit through the platform's web interface
- Use the program's designated submission channel
- Include all required information
- Follow program-specific submission instructions

**Step 17: Document submission details**
Record submission details for tracking:
- Submission timestamp
- Report ID or reference number
- Platform and program names
- Vulnerability classification
- Severity assessment
- Any program-specific requirements noted

## Tool Arsenal (40)

### Platform-Specific Tools

1. **HackerOne API**: Programmatic access to HackerOne data and submission
2. **Bugcrowd API**: Programmatic access to Bugcrowd features
3. **Intigriti API**: Programmatic access to Intigriti platform
4. **Immunefi API**: Programmatic access to Immunefi submissions

### Report Formatting Tools

5. **Markdown editors**: VS Code, Typora, Obsidian for report writing
6. **LaTeX editors**: Overleaf for formal report formatting
7. **HTML editors**: For web-based report submissions
8. **Rich text editors**: For platform-specific formatting requirements

### Evidence Capture Tools

9. **Snagit**: Professional screenshot capture and annotation
10. **Greenshot**: Open-source screenshot capture
11. **OBS Studio**: Video recording for PoC demonstrations
12. **LICEcap**: Animated GIF creation for step-by-step demonstrations
13. **ShareX**: Screen capture with annotation capabilities

### HTTP Documentation Tools

14. **Burp Suite**: HTTP request capture and documentation
15. **Postman**: API request documentation and sharing
16. **HTTPie**: Command-line HTTP client with documentation features
17. **curl**: HTTP request documentation with verbose output

### Code Documentation Tools

18. **Syntax highlighting editors**: For code snippet documentation
19. **GitHub Gists**: For sharing code snippets with proper formatting
20. **Pastebin**: For temporary code sharing
21. **Carbon**: For creating beautiful code screenshots

### Classification and Severity Tools

22. **CVSS calculators**: Online CVSS 3.1 score calculators
23. **CWE database**: Reference for CWE classification
24. **VRT reference**: Bugcrowd's Vulnerability Rating Taxonomy
25. **NIST NVD**: National Vulnerability Database reference

### Report Quality Tools

26. **Grammar checkers**: Grammarly, LanguageTool for report quality
27. **Spell checkers**: Built-in browser and editor spell check
28. **Readability analyzers**: For report clarity assessment
29. **Plagiarism checkers**: For report originality verification

### Version Control and Collaboration

30. **Git**: Version control for report drafts
31. **GitHub**: Collaborative report development
32. **Google Docs**: Real-time collaborative editing
33. **Notion**: Structured report documentation

### Submission Tracking

34. **Spreadsheet tools**: Excel, Google Sheets for tracking submissions
35. **Project management tools**: Trello, Asana for submission tracking
36. **Calendar tools**: For tracking disclosure timelines
37. **Notification tools**: For tracking program responses

### Platform-Specific Templates

38. **HackerOne templates**: Platform-provided report templates
39. **Bugcrowd templates**: VRT-aligned report templates
40. **Intigriti templates**: Flexible report templates

## Case Studies (50)

### Case Study 1: HackerOne Submission — XSS in Search Function

A researcher discovered a reflected XSS vulnerability in a HackerOne program's search functionality. The report was formatted according to HackerOne conventions with clear reproduction steps and CVSS scoring.

**Formatting approach**:
- Title: "Reflected XSS in search parameter allows JavaScript execution"
- Vulnerability Type: XSS (Cross-site Scripting)
- Weakness: CWE-79
- CVSS 3.1 Score: 6.1 (Medium)
- CVSS Vector: CVSS:3.1/AV:N/AC:L/PR:N/UI:R/S:C/C:L/I:L/A:N

**Report structure**:
1. Summary of the vulnerability
2. Affected endpoint and parameter
3. Step-by-step reproduction with HTTP requests
4. Impact demonstration with screenshots
5. CVSS justification
6. Remediation recommendation

**Result**: Accepted within 24 hours, bounty paid within 48 hours. The clear formatting and complete evidence facilitated rapid triage.

### Case Study 2: Bugcrowd Submission — Business Logic Flaw

A researcher discovered a business logic flaw that allowed users to purchase items at discounted prices. The report had to be mapped to Bugcrowd's VRT, which doesn't have an exact category for business logic flaws.

**VRT mapping challenge**:
- No exact VRT category for "business logic flaw"
- Mapped to "P5: Business Logic" as closest match
- Documented the mapping rationale in the report
- Provided detailed justification for severity assessment

**Report adaptation**:
- Used Bugcrowd's report template
- Mapped to VRT category P5: Business Logic
- Provided detailed impact quantification
- Included code-level analysis of the logic flaw
- Suggested specific remediation approaches

**Result**: Accepted after triage review. The clear VRT mapping and detailed justification facilitated acceptance despite the non-standard vulnerability class.

### Case Study 3: Intigriti Submission — API Vulnerability Chain

A researcher discovered a chain of API vulnerabilities including IDOR, mass assignment, and information disclosure. The report had to clearly document the chain and demonstrate cumulative impact.

**Chain documentation approach**:
- Individual vulnerability description for each component
- Clear explanation of how vulnerabilities chain together
- Demonstration of cumulative impact exceeding individual findings
- Severity assessment based on chain impact, not individual components

**Intigriti-specific formatting**:
- Used markdown formatting for readability
- Included both technical and business impact
- Provided complete API request/response documentation
- Suggested comprehensive remediation approach

**Result**: Accepted as a single finding with severity based on the complete chain. The clear chain documentation demonstrated the cumulative impact effectively.

### Case Study 4: Immunefi Submission — Smart Contract Reentrancy

A researcher discovered a reentrancy vulnerability in a DeFi protocol's smart contract. The report required detailed technical analysis and financial impact quantification.

**Immunefi-specific formatting**:
- Detailed vulnerability explanation with code analysis
- Step-by-step attack path with transaction examples
- Financial impact calculation (TVL at risk, exploit value)
- Specific remediation with code fixes
- On-chain verification of the vulnerability

**Report structure**:
1. Vulnerability summary with financial impact
2. Root cause analysis with code review
3. Attack path with transaction examples
4. Financial impact calculation
5. Recommended fix with code implementation
6. Verification steps for the fix

**Result**: Accepted with critical severity. The detailed technical analysis and financial impact quantification supported the severity assessment.

### Case Study 5: Cross-Platform Adaptation

A researcher discovered the same vulnerability class across programs on different platforms. The report had to be adapted for each platform's specific requirements.

**Adaptation approach**:
- Base report created with complete technical details
- HackerOne version: Added CWE classification and CVSS scoring
- Bugcrowd version: Mapped to VRT and added severity override justification
- Intigriti version: Adapted formatting to platform conventions

**Result**: All three submissions accepted. The ability to adapt reports across platforms demonstrated versatility and understanding of platform-specific requirements.

### Case Study 6: Program-Specific Template Compliance

A program provided a custom report template with specific required sections. The researcher's original report didn't follow the template structure.

**Adaptation process**:
- Reviewed the program's custom template
- Restructured the report to match the template
- Added program-requested sections (threat model, risk assessment)
- Ensured all required fields were completed

**Result**: The adapted report was accepted faster than submissions from researchers who didn't follow the template. Program-specific compliance demonstrated professionalism.

### Case Study 7: Severity Override Justification

A researcher disagreed with the VRT's default severity rating for a finding. The report had to justify why the severity should be higher than the VRT default.

**Justification approach**:
- Documented the VRT default severity and rationale
- Provided evidence that the specific implementation increased impact
- Referenced similar findings with higher severity ratings
- Included CVSS calculation supporting the higher severity

**Result**: The triage team accepted the severity override. The detailed justification and supporting evidence convinced the triage team to override the VRT default.

### Case Study 8: Video Documentation for Complex Exploitation

A complex multi-step exploitation required video documentation to clearly demonstrate the attack path. The report had to include a video walkthrough.

**Video documentation approach**:
- Recorded step-by-step exploitation using screen capture
- Added voice-over explaining each step
- Included timestamps for key moments
- Provided written summary of the video content
- Ensured video quality was sufficient for clarity

**Result**: The video documentation significantly improved triage understanding. The visual demonstration made the complex attack path much clearer than written steps alone.

### Case Study 9: Code Snippet Documentation for Source Code Review

A researcher discovered vulnerabilities through source code review. The report had to include code snippets with proper formatting and explanation.

**Code documentation approach**:
- Included vulnerable code snippets with line numbers
- Explained the code flow and vulnerability mechanism
- Provided fixed code examples
- Referenced relevant security standards and best practices

**Result**: The code-level analysis provided clear evidence of the vulnerability and specific guidance for remediation.

### Case Study 10: Multi-Language Report Submission

A researcher discovered a vulnerability affecting users across multiple languages. The report had to document the impact in different language contexts.

**Multi-language documentation**:
- Documented the vulnerability in English (primary)
- Included examples in other affected languages
- Explained language-specific impact variations
- Provided screenshots demonstrating the vulnerability across languages

**Result**: The comprehensive language documentation demonstrated thorough testing and helped the triage team understand the full scope of the vulnerability.

### Case Study 11: Historical Report Analysis for Pattern Recognition

A researcher analyzed the program's historical reports to identify patterns in accepted vulnerabilities and triage decisions. This analysis informed the report formatting and severity justification.

**Pattern analysis approach**:
- Reviewed 50+ accepted reports for the program
- Identified common vulnerability types and severity levels
- Analyzed triage decision patterns
- Used insights to inform report structure and severity justification

**Result**: The informed report format aligned with program expectations, facilitating faster triage and higher acceptance rates.

### Case Study 12: Platform Migration Adaptation

A program migrated from one platform to another, requiring researchers to adapt their reporting approach. The researcher had to understand the new platform's requirements while maintaining consistency with previous submissions.

**Migration adaptation**:
- Reviewed the new platform's documentation and conventions
- Adapted report templates to the new platform's format
- Maintained consistency with previous submission quality
- Ensured historical context was available for triage teams

**Result**: The smooth adaptation to the new platform maintained the researcher's relationship with the program and continued access to high-value bounty opportunities.

### Case Study 13: Team Submission Formatting

A team of researchers submitted a collaborative report. The submission had to properly credit all team members and follow platform-specific team submission requirements.

**Team submission approach**:
- Listed all team members with their specific contributions
- Followed the platform's team submission guidelines
- Documented the collaboration agreement
- Ensured all team members were credited appropriately

**Result**: The team submission was processed smoothly, with bounties distributed according to the documented agreement.

### Case Study 14: Severity Escalation Documentation

A researcher discovered a vulnerability that escalated in severity during testing. The report had to document the severity escalation and justify the final assessment.

**Escalation documentation**:
- Documented initial severity assessment
- Explained the escalation factors discovered during testing
- Provided evidence supporting the higher severity
- Included CVSS calculations for both initial and escalated assessments

**Result**: The clear escalation documentation supported the final severity assessment and facilitated appropriate bounty payment.

### Case Study 15: Disclosure Timeline Compliance

A researcher discovered a critical vulnerability with a tight disclosure timeline. The report had to be submitted and formatted to meet the timeline requirements.

**Timeline compliance approach**:
- Prioritized rapid report completion
- Followed the program's disclosure timeline requirements
- Documented the timeline compliance in the report
- Maintained quality despite time pressure

**Result**: The report was submitted within the disclosure timeline, maintaining the researcher's reputation and the program's trust.

### Case Study 16: Cross-Program Learning

A researcher applied lessons learned from one program's triage feedback to improve submissions at another program. This cross-program learning enhanced overall submission quality.

**Learning application approach**:
- Analyzed triage feedback from Program A
- Identified common issues and improvement areas
- Applied lessons to submissions at Program B
- Measured improvement in acceptance rates and triage times

**Result**: The cross-program learning approach consistently improved submission quality and reduced triage times across programs.

### Case Study 17: Automated Report Generation

A researcher developed templates and scripts to automate report generation for common vulnerability classes. This automation improved consistency and reduced report preparation time.

**Automation approach**:
- Created report templates for common vulnerability types
- Developed scripts to generate HTTP request documentation
- Automated CVSS calculation based on vulnerability characteristics
- Implemented quality checks in the automation pipeline

**Result**: Automated report generation improved consistency, reduced preparation time, and allowed the researcher to focus on finding vulnerabilities rather than formatting reports.

### Case Study 18: Program Feedback Integration

A researcher systematically integrated program feedback into report improvements. This iterative approach led to consistently improving submission quality over time.

**Feedback integration approach**:
- Documented all program feedback
- Identified patterns in feedback themes
- Developed improvement plans based on feedback
- Tracked improvement metrics over time

**Result**: The systematic feedback integration approach led to measurable improvements in acceptance rates and bounty amounts.

### Case Study 19: Cultural Adaptation for International Programs

A researcher submitted reports to programs based in different countries, requiring cultural adaptation in communication style and report structure.

**Cultural adaptation approach**:
- Researched communication norms for each program's country
- Adapted report formality levels accordingly
- Modified evidence presentation styles
- Adjusted communication tone and formality

**Result**: The culturally adapted reports facilitated smoother communication and faster triage across international programs.

### Case Study 20: Accessibility Documentation

A researcher discovered a vulnerability that disproportionately affected users with disabilities. The report had to document the accessibility impact and recommend accessible remediation approaches.

**Accessibility documentation approach**:
- Documented the specific impact on users with disabilities
- Referenced relevant accessibility standards (WCAG)
- Recommended remediation approaches that maintained accessibility
- Included testing methodology for accessibility verification

**Result**: The accessibility-focused documentation demonstrated thorough impact analysis and comprehensive remediation guidance.

### Case Study 21: Chain Attack Documentation

A researcher discovered a complex chain attack involving multiple vulnerability classes. The report had to clearly document the chain and demonstrate cumulative impact beyond individual findings.

**Chain documentation approach**:
- Individual vulnerability documentation for each component
- Clear explanation of how vulnerabilities chain together
- Cumulative impact demonstration
- Severity assessment based on chain impact

**Result**: The chain attack documentation demonstrated the combined impact effectively, resulting in a higher severity assessment and bounty.

### Case Study 22: Zero-Day Vulnerability Reporting

A researcher discovered a zero-day vulnerability in a widely-used library. The report had to be formatted for responsible disclosure with timeline considerations.

**Zero-day reporting approach**:
- Documented the vulnerability completely
- Provided proof of concept demonstrating impact
- Included affected versions and potential mitigation
- Followed responsible disclosure timeline
- Coordinated with library maintainers

**Result**: The responsible disclosure approach protected users and established the researcher's reputation for ethical vulnerability reporting.

### Case Study 23: Business Impact Quantification

A researcher discovered a vulnerability with significant business impact. The report had to quantify the business impact beyond technical severity.

**Business impact quantification approach**:
- Calculated potential financial loss per affected user
- Estimated total affected user base
- Quantified regulatory compliance implications
- Assessed reputational damage potential
- Provided business-focused impact statement

**Result**: The business impact quantification elevated the report's perceived value and resulted in a higher bounty payment.

### Case Study 24: Remediation Guidance Quality

A researcher provided exceptionally detailed remediation guidance that went beyond basic recommendations. This detailed guidance was recognized by the program and led to additional recognition.

**Remediation approach**:
- Provided specific code changes for remediation
- Included testing recommendations for the fix
- Documented potential regression risks
- Suggested architectural improvements
- Offered to verify the remediation

**Result**: The detailed remediation guidance was recognized as exceptional, leading to additional bounty and invitation to the program's security advisory board.

### Case Study 25: Platform-Specific Video Requirements

Different platforms have different requirements for video documentation. A researcher had to adapt video content for platform-specific requirements.

**Video adaptation approach**:
- Created base video with complete exploitation demonstration
- Adapted video for HackerOne's video requirements
- Modified video for Bugcrowd's documentation standards
- Ensured video met platform-specific quality requirements

**Result**: The adapted video documentation met all platform requirements and facilitated efficient triage.

### Case Study 26: Low-Severity Finding Presentation

A researcher discovered a low-severity finding that still had value. The report had to present the finding in a way that demonstrated its value despite the low severity.

**Low-severity presentation approach**:
- Clearly documented the vulnerability
- Provided context for why the finding matters
- Suggested potential chain opportunities
- Demonstrated thorough testing methodology
- Maintained professional quality despite low severity

**Result**: The well-presented low-severity finding was accepted quickly and maintained the researcher's reputation for thorough testing.

### Case Study 27: Regression Testing Documentation

A researcher discovered that a previously reported vulnerability had regressed. The report had to document the regression and reference the original finding.

**Regression documentation approach**:
- Referenced the original finding and its remediation
- Documented the regression mechanism
- Provided evidence of the regression
- Recommended comprehensive regression testing

**Result**: The regression documentation demonstrated the importance of comprehensive testing and led to additional bounty for the regression finding.

### Case Study 28: Multi-Environment Testing

A researcher discovered a vulnerability that manifested differently across environments (production, staging, development). The report had to document the environment-specific behavior.

**Multi-environment documentation approach**:
- Documented the vulnerability in each environment
- Explained environment-specific variations
- Provided environment-specific reproduction steps
- Recommended environment-specific remediation

**Result**: The comprehensive environment documentation facilitated targeted remediation across all environments.

### Case Study 29: API Versioning Impact

A researcher discovered a vulnerability that existed in multiple API versions. The report had to document the version-specific impact and remediation requirements.

**Versioning documentation approach**:
- Documented the vulnerability across all affected versions
- Explained version-specific exploitation differences
- Provided version-specific remediation guidance
- Recommended version upgrade or deprecation strategy

**Result**: The version-specific documentation facilitated targeted remediation and informed the program's API versioning strategy.

### Case Study 30: Third-Party Component Disclosure

A researcher discovered a vulnerability in a third-party component used by the program. The report had to coordinate disclosure between the program and the component maintainer.

**Third-party coordination approach**:
- Documented the vulnerability completely
- Identified the third-party component and version
- Provided remediation guidance for the program
- Coordinated disclosure with the component maintainer
- Documented the coordination process

**Result**: The coordinated disclosure protected both the program and the third-party component maintainer, demonstrating responsible vulnerability management.

### Case Study 31: Compliance Framework Mapping

A researcher discovered a vulnerability that violated specific compliance frameworks (PCI DSS, HIPAA, GDPR). The report had to map the vulnerability to compliance requirements.

**Compliance mapping approach**:
- Identified applicable compliance frameworks
- Mapped the vulnerability to specific compliance requirements
- Documented the compliance implications
- Recommended compliance-focused remediation

**Result**: The compliance mapping elevated the report's business relevance and facilitated compliance-focused remediation prioritization.

### Case Study 32: Performance Impact Documentation

A researcher discovered a vulnerability that could be exploited to cause denial of service through resource exhaustion. The report had to document the performance impact alongside the security impact.

**Performance impact approach**:
- Documented the security vulnerability
- Quantified the performance impact (CPU, memory, network)
- Provided load testing results demonstrating the impact
- Recommended performance-focused remediation

**Result**: The combined security and performance impact documentation facilitated comprehensive remediation addressing both aspects.

### Case Study 33: Supply Chain Vulnerability Disclosure

A researcher discovered a vulnerability in a software supply chain component. The report had to address the broader supply chain implications.

**Supply chain disclosure approach**:
- Documented the vulnerability in the supply chain component
- Identified all affected downstream users
- Provided remediation guidance for direct and indirect users
- Coordinated with the supply chain component maintainer

**Result**: The comprehensive supply chain disclosure protected the entire ecosystem and demonstrated responsible vulnerability management.

### Case Study 34: Cloud Configuration Vulnerability

A researcher discovered a cloud configuration vulnerability that affected multiple services. The report had to document the cross-service impact and provide comprehensive remediation.

**Cloud configuration approach**:
- Documented the misconfiguration across all affected services
- Explained the cross-service implications
- Provided service-specific remediation guidance
- Recommended configuration management improvements

**Result**: The cross-service documentation facilitated comprehensive remediation and configuration management improvements.

### Case Study 35: Mobile Application Vulnerability

A researcher discovered a vulnerability in a mobile application that required platform-specific documentation. The report had to include mobile-specific evidence and reproduction steps.

**Mobile-specific approach**:
- Documented the vulnerability on both iOS and Android
- Provided platform-specific reproduction steps
- Included mobile-specific screenshots and recordings
- Recommended platform-specific remediation approaches

**Result**: The platform-specific documentation facilitated targeted remediation for both mobile platforms.

### Case Study 36: IoT Device Vulnerability

A researcher discovered a vulnerability in an IoT device that required physical access documentation. The report had to include hardware-specific evidence and reproduction steps.

**IoT-specific approach**:
- Documented the vulnerability with physical access requirements
- Provided hardware-specific reproduction steps
- Included hardware-specific photographs and diagrams
- Recommended hardware and firmware remediation approaches

**Result**: The hardware-specific documentation facilitated comprehensive remediation addressing both software and firmware aspects.

### Case Study 37: Social Engineering Vulnerability

A researcher discovered a vulnerability that could be exploited through social engineering. The report had to document the human element alongside the technical vulnerability.

**Social engineering documentation**:
- Documented the technical vulnerability
- Explained the social engineering attack vector
- Provided examples of potential social engineering scenarios
- Recommended both technical and human-focused remediation

**Result**: The comprehensive documentation addressed both technical and human elements, facilitating holistic remediation.

### Case Study 38: Race Condition Exploitation

A researcher discovered a race condition vulnerability that required specific timing documentation. The report had to document the timing requirements and provide evidence of the race condition.

**Race condition documentation**:
- Documented the race condition mechanics
- Provided timing-specific reproduction steps
- Included evidence demonstrating the race condition
- Recommended synchronization-based remediation

**Result**: The timing-specific documentation clearly demonstrated the race condition and facilitated targeted remediation.

### Case Study 39: Cryptographic Weakness

A researcher discovered a cryptographic weakness in the application's encryption implementation. The report had to document the cryptographic analysis and provide specific remediation guidance.

**Cryptographic analysis approach**:
- Documented the cryptographic weakness
- Provided analysis of the encryption implementation
- Recommended specific cryptographic improvements
- Included references to cryptographic best practices

**Result**: The cryptographic analysis provided clear evidence and specific guidance for remediation.

### Case Study 40: Authentication Bypass Chain

A researcher discovered an authentication bypass chain involving multiple components. The report had to document the complete chain and demonstrate the cumulative impact.

**Authentication bypass documentation**:
- Documented each component of the bypass chain
- Explained how the components chain together
- Provided complete bypass demonstration
- Recommended comprehensive authentication improvements

**Result**: The complete chain documentation demonstrated the critical impact and facilitated comprehensive authentication improvements.

### Case Study 41: Authorization Flaw Documentation

A researcher discovered an authorization flaw that allowed privilege escalation. The report had to document the authorization model and the flaw's impact on it.

**Authorization documentation**:
- Documented the authorization model
- Explained the flaw's impact on authorization
- Provided evidence of privilege escalation
- Recommended authorization model improvements

**Result**: The authorization-focused documentation facilitated comprehensive authorization model improvements.

### Case Study 42: Session Management Vulnerability

A researcher discovered a session management vulnerability that allowed session fixation. The report had to document the session management implementation and the vulnerability's impact.

**Session management documentation**:
- Documented the session management implementation
- Explained the session fixation vulnerability
- Provided evidence of session fixation
- Recommended session management improvements

**Result**: The session management documentation facilitated comprehensive session handling improvements.

### Case Study 43: Input Validation Bypass

A researcher discovered an input validation bypass that allowed malicious input. The report had to document the validation implementation and the bypass technique.

**Input validation documentation**:
- Documented the input validation implementation
- Explained the bypass technique
- Provided evidence of the bypass
- Recommended comprehensive input validation improvements

**Result**: The input validation documentation facilitated targeted validation improvements.

### Case Study 44: Error Handling Information Disclosure

A researcher discovered that error handling disclosed sensitive information. The report had to document the information disclosure and recommend error handling improvements.

**Error handling documentation**:
- Documented the information disclosure in error messages
- Explained the sensitivity of disclosed information
- Provided evidence of the disclosure
- Recommended error handling improvements

**Result**: The error handling documentation facilitated comprehensive error handling improvements.

### Case Study 45: File Upload Vulnerability

A researcher discovered a file upload vulnerability that allowed malicious file uploads. The report had to document the upload mechanism and the exploitation technique.

**File upload documentation**:
- Documented the file upload mechanism
- Explained the exploitation technique
- Provided evidence of malicious file upload
- Recommended comprehensive upload validation

**Result**: The file upload documentation facilitated targeted upload validation improvements.

### Case Study 46: XML External Entity Injection

A researcher discovered an XXE vulnerability in an XML processing component. The report had to document the XML processing implementation and the XXE exploitation.

**XXE documentation**:
- Documented the XML processing implementation
- Explained the XXE vulnerability
- Provided evidence of XXE exploitation
- Recommended XML processing improvements

**Result**: The XXE documentation facilitated comprehensive XML processing improvements.

### Case Study 47: Server-Side Request Forgery

A researcher discovered an SSRF vulnerability that allowed internal network access. The report had to document the request handling implementation and the SSRF exploitation.

**SSRF documentation**:
- Documented the request handling implementation
- Explained the SSRF vulnerability
- Provided evidence of internal network access
- Recommended request handling improvements

**Result**: The SSRF documentation facilitated comprehensive request handling improvements.

### Case Study 48: Deserialization Vulnerability

A researcher discovered a deserialization vulnerability that allowed remote code execution. The report had to document the deserialization implementation and the exploitation technique.

**Deserialization documentation**:
- Documented the deserialization implementation
- Explained the deserialization vulnerability
- Provided evidence of remote code execution
- Recommended deserialization improvements

**Result**: The deserialization documentation facilitated comprehensive deserialization improvements.

### Case Study 49: SQL Injection Documentation

A researcher discovered a SQL injection vulnerability that allowed database access. The report had to document the database interaction implementation and the SQL injection technique.

**SQL injection documentation**:
- Documented the database interaction implementation
- Explained the SQL injection vulnerability
- Provided evidence of database access
- Recommended parameterized query implementation

**Result**: The SQL injection documentation facilitated comprehensive database interaction improvements.

### Case Study 50: Cross-Site Request Forgery

A researcher discovered a CSRF vulnerability that allowed unauthorized actions. The report had to document the request handling implementation and the CSRF exploitation.

**CSRF documentation**:
- Documented the request handling implementation
- Explained the CSRF vulnerability
- Provided evidence of unauthorized action
- Recommended CSRF protection implementation

**Result**: The CSRF documentation facilitated comprehensive CSRF protection improvements.

## Advanced Techniques (40)

### Advanced Technique 1: Dynamic Report Templating

Create dynamic report templates that automatically adapt to platform and program requirements. Use template engines (Jinja2, Handlebars) to generate platform-specific reports from a single source of truth.

**Implementation**:
- Define a master report structure with platform-specific placeholders
- Create platform-specific template variations
- Use template variables for platform-specific content
- Automate template selection based on target platform
- Validate generated reports against platform requirements

### Advanced Technique 2: Automated VRT Mapping

Develop automated VRT mapping tools that suggest appropriate Bugcrowd VRT categories based on vulnerability descriptions. This automation improves mapping accuracy and reduces research time.

**Implementation**:
- Parse vulnerability descriptions to identify key characteristics
- Match characteristics against VRT category descriptions
- Suggest multiple candidate VRT categories with confidence scores
- Document mapping rationale for review
- Learn from feedback to improve mapping accuracy

### Advanced Technique 3: Platform-Specific Severity Calculators

Build severity calculators that automatically compute scores using platform-specific methodologies. These tools ensure consistent and accurate severity assessment across platforms.

**Implementation**:
- Implement CVSS 3.1 calculator with platform-specific adjustments
- Build VRT default severity lookup
- Create severity justification generators
- Validate severity assessments against program history
- Provide severity comparison across platforms

### Advanced Technique 4: Evidence Automation Pipeline

Develop automated pipelines for evidence capture and formatting. These pipelines reduce manual evidence preparation time and ensure consistent quality.

**Implementation**:
- Automate HTTP request/response capture
- Generate screenshots with consistent formatting
- Create video demonstrations with standardized quality
- Build evidence organization systems
- Validate evidence completeness against platform requirements

### Advanced Technique 5: Report Quality Scoring

Implement automated report quality scoring that evaluates reports against platform-specific criteria. This scoring identifies areas for improvement before submission.

**Implementation**:
- Define quality criteria for each platform
- Build automated scoring algorithms
- Provide detailed feedback on quality gaps
- Track quality improvements over time
- Benchmark against accepted report quality standards

### Advanced Technique 6: Cross-Platform Report Synchronization

Create systems for maintaining consistent reports across platforms when the same vulnerability affects multiple programs on different platforms. This synchronization ensures consistent documentation while adapting to platform-specific requirements.

**Implementation**:
- Maintain a master report for each vulnerability
- Generate platform-specific variations automatically
- Track submission status across platforms
- Coordinate disclosure timelines
- Ensure consistent messaging across platforms

### Advanced Technique 7: Program-Specific Analytics

Develop analytics systems that analyze program-specific reporting patterns. These analytics identify optimal formatting and presentation strategies for each program.

**Implementation**:
- Analyze program-specific acceptance patterns
- Identify optimal severity assessment strategies
- Track program-specific triage timelines
- Document program-specific communication preferences
- Generate program-specific recommendations

### Advanced Technique 8: Template Version Control

Implement version control systems for report templates that track changes and maintain consistency across submissions. This version control ensures template improvements are tracked and applied consistently.

**Implementation**:
- Use Git for template version control
- Document template changes and rationale
- Maintain backward compatibility
- Validate templates against platform requirements
- Provide template evolution analytics

### Advanced Technique 9: Collaborative Template Development

Create systems for collaborative template development that incorporate feedback from multiple researchers. This collaborative approach produces higher-quality templates.

**Implementation**:
- Establish template contribution guidelines
- Create feedback collection mechanisms
- Implement template review processes
- Maintain template quality standards
- Provide template contribution recognition

### Advanced Technique 10: Platform API Integration

Integrate with platform APIs to automate submission processes and improve reporting efficiency. API integration reduces manual submission overhead and ensures compliance.

**Implementation**:
- Use platform APIs for automated submission
- Implement status tracking through APIs
- Automate follow-up communication
- Generate submission reports from API data
- Validate submissions against platform requirements through APIs

## Detection (20)

### Detecting Platform Requirements

1. **Documentation review**: Thoroughly review platform documentation for formatting requirements
2. **Accepted report analysis**: Study accepted reports to identify formatting conventions
3. **Template identification**: Identify platform-provided report templates
4. **Classification system recognition**: Understand platform-specific classification systems
5. **Evidence format requirements**: Identify platform-specific evidence format preferences

### Detecting Program-Specific Requirements

6. **Vulnerability disclosure policy review**: Read the program's VDP thoroughly
7. **FAQ analysis**: Review the program's FAQ for submission guidance
8. **Historical submission analysis**: Study the program's historical submissions
9. **Communication pattern analysis**: Identify program-specific communication preferences
10. **Triage process understanding**: Understand the program's triage process

### Detecting Formatting Gaps

11. **Compliance checklist validation**: Use checklists to identify formatting gaps
12. **Peer review feedback**: Get feedback from other researchers on formatting
13. **Triage feedback analysis**: Analyze triage feedback for formatting issues
14. **Acceptance rate tracking**: Track acceptance rates to identify formatting improvements
15. **Platform guideline updates**: Monitor platform guideline changes

### Detecting Quality Issues

16. **Grammar and spelling check**: Automated and manual quality checks
17. **Technical accuracy verification**: Verify all technical claims before submission
18. **Evidence completeness validation**: Ensure all evidence is complete and relevant
19. **Severity assessment validation**: Validate severity assessments against criteria
20. **Impact documentation review**: Ensure impact documentation is comprehensive

## Impact (20)

### Impact on Triage Efficiency

1. **Reduced triage time**: Well-formatted reports are processed faster
2. **Clearer communication**: Consistent formatting reduces clarification requests
3. **Faster validation**: Complete evidence enables rapid validation
4. **Reduced back-and-forth**: Comprehensive reports require fewer follow-ups
5. **Improved triage team satisfaction**: Professional reports improve triage team experience

### Impact on Acceptance Rates

6. **Higher acceptance rates**: Compliant formatting improves acceptance likelihood
7. **Faster acceptance**: Well-formatted reports are accepted more quickly
8. **Reduced rejections**: Proper formatting reduces formatting-related rejections
9. **Severity accuracy**: Proper severity justification supports appropriate ratings
10. **Program trust**: Professional formatting builds program trust

### Impact on Bounty Amounts

11. **Appropriate severity assessment**: Proper justification supports fair bounty amounts
12. **Impact demonstration**: Clear impact documentation supports higher bounties
13. **Chain documentation**: Proper chain documentation supports cumulative bounty assessment
14. **Quality recognition**: Exceptional report quality may lead to bonus recognition
15. **Relationship building**: Professional reporting builds program relationships

### Impact on Researcher Reputation

16. **Professional reputation**: Consistent quality builds professional reputation
17. **Platform recognition**: High-quality submissions improve platform standing
18. **Program invitations**: Professional reporting leads to exclusive program invitations
19. **Community recognition**: Quality reports earn community recognition
20. **Career advancement**: Professional reputation supports career opportunities

## Pitfalls (25)

### Pitfall 1: Using Wrong Platform Template
**Problem**: Submitting a HackerOne-formatted report to Bugcrowd.
**Solution**: Always verify platform-specific requirements before submission.

### Pitfall 2: Incorrect VRT Mapping
**Problem**: Mapping vulnerabilities to incorrect VRT categories.
**Solution**: Study the VRT thoroughly and document mapping rationale.

### Pitfall 3: Insufficient Evidence
**Problem**: Providing incomplete evidence that doesn't support the vulnerability claim.
**Solution**: Ensure all evidence is complete and verifiable.

### Pitfall 4: Generic Impact Statement
**Problem**: Providing generic impact statements that don't quantify business risk.
**Solution**: Quantify impact with specific metrics and examples.

### Pitfall 5: Poor Severity Justification
**Problem**: Providing insufficient justification for severity assessments.
**Solution**: Use CVSS calculators and provide detailed justification.

### Pitfall 6: Ignoring Program Instructions
**Problem**: Not following program-specific submission instructions.
**Solution**: Read the program's VDP thoroughly before submission.

### Pitfall 7: Incomplete Reproduction Steps
**Problem**: Providing reproduction steps that can't be independently verified.
**Solution**: Test reproduction steps independently before submission.

### Pitfall 8: Grammar and Spelling Errors
**Problem**: Submitting reports with grammar and spelling errors.
**Solution**: Proofread reports thoroughly and use grammar checking tools.

### Pitfall 9: Incorrect HTTP Documentation
**Problem**: Providing truncated or incorrect HTTP requests.
**Solution**: Capture complete HTTP requests with all headers and parameters.

### Pitfall 10: Missing Screenshots
**Problem**: Not providing visual evidence to support the report.
**Solution**: Include clear, annotated screenshots for all key steps.

### Pitfall 11: Wrong Vulnerability Classification
**Problem**: Classifying vulnerabilities incorrectly using CWE or VRT.
**Solution**: Study classification systems and validate mappings.

### Pitfall 12: Aggressive Tone
**Problem**: Using aggressive or confrontational language in reports.
**Solution**: Maintain professional, objective tone throughout.

### Pitfall 13: Incomplete Remediation Guidance
**Problem**: Providing insufficient remediation recommendations.
**Solution**: Provide specific, actionable remediation guidance.

### Pitfall 14: Ignoring Disclosure Timelines
**Problem**: Not respecting program-specific disclosure timelines.
**Solution**: Document and adhere to all disclosure requirements.

### Pitfall 15: Submitting Out-of-Scope Findings
**Problem**: Submitting vulnerabilities that are out of program scope.
**Solution**: Verify scope before testing and submission.

### Pitfall 16: Excessive Report Length
**Problem**: Submitting unnecessarily lengthy reports that obscure key information.
**Solution**: Be concise while providing complete information.

### Pitfall 17: Missing CVSS Vector
**Problem**: Not including CVSS vector strings for severity justification.
**Solution**: Always include the complete CVSS vector string.

### Pitfall 18: Incorrect CWE Classification
**Problem**: Using incorrect CWE classifications for vulnerabilities.
**Solution**: Reference CWE database and validate classifications.

### Pitfall 19: Poor Evidence Organization
**Problem**: Providing disorganized evidence that doesn't support the narrative.
**Solution**: Organize evidence logically following the report structure.

### Pitfall 20: Ignoring Platform Updates
**Problem**: Not keeping up with platform documentation updates.
**Solution**: Monitor platform documentation changes regularly.

### Pitfall 21: Submitting Without Review
**Problem**: Submitting reports without thorough review and quality checks.
**Solution**: Implement pre-submission review processes.

### Pitfall 22: Inconsistent Report Quality
**Problem**: Varying report quality across submissions.
**Solution**: Maintain consistent quality standards for all submissions.

### Pitfall 23: Not Learning from Rejections
**Problem**: Not analyzing and learning from report rejections.
**Solution**: Systematically analyze rejections and improve future submissions.

### Pitfall 24: Overlooking Program History
**Problem**: Not reviewing program-specific history and patterns.
**Solution**: Analyze program history to inform submission strategy.

### Pitfall 25: Failing to Adapt
**Problem**: Not adapting reporting approach based on feedback.
**Solution**: Continuously improve based on feedback and results.

## Integration (25)

### Integration with Report Writing

Program-specific formatting integrates with report writing by:
- Providing structure and templates for consistent reporting
- Ensuring compliance with platform requirements
- Facilitating efficient triage processing
- Supporting appropriate severity assessment
- Enabling effective communication of findings

### Integration with Vulnerability Analysis

Formatting integrates with vulnerability analysis by:
- Providing classification frameworks for vulnerability types
- Supporting severity assessment methodologies
- Enabling impact quantification
- Facilitating remediation guidance
- Supporting disclosure coordination

### Integration with Evidence Documentation

Formatting integrates with evidence documentation by:
- Providing evidence format requirements
- Ensuring evidence completeness
- Supporting evidence organization
- Facilitating evidence presentation
- Enabling evidence verification

### Integration with Communication

Formatting integrates with program communication by:
- Providing communication templates
- Ensuring message consistency
- Facilitating professional interactions
- Supporting escalation procedures
- Enabling effective follow-up

### Integration with Quality Assurance

Formatting integrates with quality assurance by:
- Providing quality standards for reports
- Ensuring compliance with requirements
- Supporting peer review processes
- Facilitating continuous improvement
- Enabling quality metrics tracking

### Integration with Submission Processes

Formatting integrates with submission processes by:
- Ensuring submission compliance
- Facilitating automated submission
- Supporting status tracking
- Enabling submission validation
- Coordinating disclosure timelines

### Integration with Learning

Formatting integrates with learning by:
- Providing feedback mechanisms
- Supporting continuous improvement
- Facilitating knowledge sharing
- Enabling skill development
- Supporting mentorship

### Integration with Collaboration

Formatting integrates with collaboration by:
- Providing consistent templates for team submissions
- Ensuring uniform quality across contributors
- Facilitating joint report development
- Supporting contribution attribution
- Enabling collaborative quality assurance

### Integration with Business Development

Formatting integrates with business development by:
- Building professional reputation
- Supporting program relationship management
- Facilitating exclusive program access
- Enabling consulting opportunities
- Supporting career advancement

### Integration with Compliance

Formatting integrates with compliance by:
- Supporting regulatory requirements
- Facilitating audit documentation
- Enabling compliance mapping
- Supporting legal requirements
- Coordinating disclosure obligations

## Reporting (20)

### Platform-Specific Report Structures

**HackerOne report structure**:
1. Title
2. Vulnerability Type
3. Weakness (CWE)
4. CVSS Score and Vector
5. Affected Asset
6. Impact Statement
7. Steps to Reproduce
8. Supporting Material
9. Remediation Recommendation

**Bugcrowd report structure**:
1. Title
2. VRT Category
3. Severity
4. Description
5. Detailed Description
6. Impact
7. Step-by-step Instructions
8. Supporting Material
9. Remediation Recommendation

**Intigriti report structure**:
1. Title
2. Severity
3. Type
4. Description
5. Steps to Reproduce
6. Impact
7. Supporting Material
8. Remediation Recommendation

**Immunefi report structure**:
1. Title
2. Vulnerability Type
3. Severity with justification
4. Root Cause Analysis
5. Attack Path
6. Impact (financial quantification)
7. Code Snippets
8. Recommended Fix
9. Verification Steps

### Report Quality Checklist

1. **Platform compliance**: Report meets platform-specific requirements
2. **Program compliance**: Report follows program-specific instructions
3. **Classification accuracy**: Vulnerability is correctly classified
4. **Severity justification**: Severity assessment is supported by evidence
5. **Reproduction completeness**: All steps are included for independent verification
6. **Evidence quality**: All evidence is clear, complete, and relevant
7. **Impact quantification**: Business impact is quantified and justified
8. **Remediation actionability**: Recommendations are specific and implementable
9. **Grammar and spelling**: Report is free of grammar and spelling errors
10. **Professional tone**: Report maintains professional, objective tone

### Severity Assessment Guidelines

**CVSS 3.1 calculation factors**:
- Attack Vector (Network, Adjacent, Local, Physical)
- Attack Complexity (Low, High)
- Privileges Required (None, Low, High)
- User Interaction (None, Required)
- Scope (Changed, Unchanged)
- Confidentiality Impact (None, Low, High)
- Integrity Impact (None, Low, High)
- Availability Impact (None, Low, High)

**VRT severity mapping**:
- P1: Critical (9.0-10.0 CVSS)
- P2: High (7.0-8.9 CVSS)
- P3: Medium (4.0-6.9 CVSS)
- P4: Low (0.1-3.9 CVSS)
- P5: Informational (0.0 CVSS)

### Evidence Documentation Standards

1. **Screenshots**: Clear, annotated, showing relevant context
2. **HTTP requests**: Complete with all headers and parameters
3. **HTTP responses**: Complete with status codes and relevant headers
4. **Code snippets**: Properly formatted with syntax highlighting
5. **Video demonstrations**: Clear, step-by-step, with narration when helpful
6. **Database queries**: Complete with output showing the vulnerability
7. **Configuration files**: Relevant sections with sensitive data redacted
8. **Error messages**: Complete error messages showing information disclosure

### Report Submission Best Practices

1. **Pre-submission checklist**: Complete all quality checks before submission
2. **Platform verification**: Verify all platform requirements are met
3. **Program verification**: Verify all program requirements are met
4. **Evidence verification**: Verify all evidence is complete and accurate
5. **Severity verification**: Verify severity assessment is justified
6. **Timestamp recording**: Record submission timestamp for tracking
7. **Confirmation documentation**: Document submission confirmation
8. **Follow-up scheduling**: Schedule follow-up communication if needed

## Labs (20)

### Lab 1: Platform Documentation Review
Review the documentation for HackerOne, Bugcrowd, Intigriti, and Immunefi. Create a comparison matrix of their formatting requirements, classification systems, and severity methodologies.

### Lab 2: VRT Mapping Exercise
Map 10 different vulnerability descriptions to Bugcrowd's VRT. Document the mapping rationale for each, especially when no exact match exists.

### Lab 3: CVSS Calculation Practice
Calculate CVSS 3.1 scores for 10 different vulnerability scenarios. Justify each calculation using the CVSS vector string components.

### Lab 4: Report Template Creation
Create platform-specific report templates for each major platform. Ensure all required sections and fields are included.

### Lab 5: Evidence Documentation Practice
Capture and format evidence for a sample vulnerability. Include screenshots, HTTP requests, code snippets, and video demonstration as appropriate.

### Lab 6: Program-Specific Adaptation
Take a single vulnerability report and adapt it for three different programs with different requirements. Document the adaptation process and rationale.

### Lab 7: Severity Justification Writing
Write severity justification statements for vulnerabilities with different severity levels. Practice using CVSS scoring and program-specific severity guidelines.

### Lab 8: Impact Quantification Exercise
Quantify the business impact of 10 different vulnerabilities. Practice using different quantification methods (financial, operational, reputational).

### Lab 9: Remediation Guidance Writing
Write remediation guidance for 10 different vulnerability types. Practice providing specific, actionable, and implementable recommendations.

### Lab 10: Grammar and Style Review
Review sample reports for grammar, spelling, and style issues. Practice identifying and correcting common writing errors.

### Lab 11: Report Quality Scoring
Develop a quality scoring rubric and use it to evaluate 5 different reports. Identify areas for improvement and document recommendations.

### Lab 12: Platform API Exploration
Explore the APIs for major bug bounty platforms. Document available features and capabilities for automated submission and management.

### Lab 13: Template Version Control
Set up version control for report templates. Practice tracking changes and maintaining template consistency across versions.

### Lab 14: Cross-Platform Synchronization
Create a system for maintaining consistent reports across platforms. Practice generating platform-specific variations from a master report.

### Lab 15: Program History Analysis
Analyze the submission history for a specific program. Identify patterns in accepted vulnerabilities, severity levels, and triage decisions.

### Lab 16: Collaborative Template Development
Collaborate with other researchers to develop and refine report templates. Practice incorporating feedback and maintaining quality standards.

### Lab 17: Automated Quality Checking
Implement automated quality checking for report submissions. Practice using tools to validate formatting, completeness, and accuracy.

### Lab 18: Cultural Adaptation Exercise
Adapt report communication for programs based in different countries. Practice modifying tone, formality, and presentation for cultural appropriateness.

### Lab 19: Video Documentation Practice
Create a video demonstration of a sample vulnerability. Practice screen capture, narration, and editing for clear documentation.

### Lab 20: Platform-Specific Submission
Submit sample reports to each major platform (using test programs if available). Practice the complete submission process for each platform.

## Ethics (15)

### Ethical Principle 1: Transparency
Always be transparent about the vulnerability and its impact. Never minimize or exaggerate the severity for bounty purposes.

### Ethical Principle 2: Responsible Disclosure
Follow responsible disclosure practices regardless of platform requirements. Protect users by coordinating disclosure timelines appropriately.

### Ethical Principle 3: Accurate Documentation
Provide accurate and complete documentation of the vulnerability. Never fabricate evidence or misrepresent findings.

### Ethical Principle 4: Professional Conduct
Maintain professional conduct in all interactions with programs and platforms. Avoid aggressive, confrontational, or unprofessional behavior.

### Ethical Principle 5: Compliance
Comply with all platform terms of service and program-specific requirements. Never circumvent rules or policies for personal gain.

### Ethical Principle 6: Confidentiality
Maintain confidentiality of program-sensitive information. Never share vulnerability details outside authorized disclosure channels.

### Ethical Principle 7: User Protection
Prioritize user protection in all reporting activities. Ensure that disclosure practices protect user data and safety.

### Ethical Principle 8: Fair Assessment
Provide fair and accurate severity assessments. Never inflate severity for higher bounties or deflate it to appear less threatening.

### Ethical Principle 9: Quality Standards
Maintain high quality standards for all reports. Never submit low-quality reports that waste triage team time.

### Ethical Principle 10: Continuous Improvement
Continuously improve reporting skills and practices. Invest in professional development to provide better value to programs.

### Ethical Principle 11: Community Contribution
Contribute positively to the bug bounty community. Share knowledge, mentor others, and support community development.

### Ethical Principle 12: Integrity
Maintain integrity in all reporting activities. Never compromise ethical standards for bounty maximization.

### Ethical Principle 13: Respect
Respect the time and effort of triage teams. Provide complete, well-organized reports that facilitate efficient processing.

### Ethical Principle 14: Accountability
Take responsibility for your reports and their impact. Address any issues or mistakes promptly and professionally.

### Ethical Principle 15: Sustainability
Build sustainable reporting practices that benefit all stakeholders. Avoid short-term gains that harm long-term relationships.

## Cheat Sheet (20)

### Platform Formatting Quick Reference

1. **HackerOne**: Use CVSS scoring, CWE classification, structured templates
2. **Bugcrowd**: Map to VRT, justify severity overrides, use VRT-aligned templates
3. **Intigriti**: Follow program instructions, use markdown formatting, emphasize clarity
4. **Immunefi**: Quantify financial impact, document attack paths, provide code analysis

### Classification Systems

5. **CWE**: Common Weakness Enumeration for weakness classification
6. **VRT**: Bugcrowd's Vulnerability Rating Taxonomy
7. **CVSS**: Common Vulnerability Scoring System for severity
8. **OWASP Top 10**: Web application security risks reference

### Severity Assessment

9. **CVSS 3.1**: Use for HackerOne and Immunefi submissions
10. **VRT defaults**: Use for Bugcrowd submissions unless justifying override
11. **Program guidelines**: Follow program-specific severity guidelines
12. **Justify always**: Provide clear justification for severity assessments

### Evidence Standards

13. **Screenshots**: Clear, annotated, showing relevant context
14. **HTTP requests**: Complete with all headers and parameters
15. **Code snippets**: Properly formatted with syntax highlighting
16. **Video demonstrations**: Clear, step-by-step, well-documented

### Report Quality

17. **Grammar check**: Use automated tools and manual review
18. **Technical accuracy**: Verify all claims before submission
19. **Completeness**: Ensure all required sections are included
20. **Professional tone**: Maintain objective, professional language throughout
