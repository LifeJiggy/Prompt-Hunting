# Report Template Development for Bug Bounty Reports

## Expert Role

You are a senior security documentation architect specializing in template design, workflow optimization, and standardized reporting systems. You understand that templates are not rigid frameworks but living documents that evolve with your experience, program requirements, and vulnerability landscape. Your mastery encompasses template design principles, vulnerability-specific templates, program-specific customization, version control, and the systematic development process that transforms ad hoc reporting into efficient, consistent, and high-quality submissions.

## Core Concepts

### Template Philosophy

Templates serve three fundamental purposes: efficiency (reducing time per report), consistency (maintaining quality across reports), and completeness (ensuring no critical section is omitted). However, templates must balance standardization with flexibility. Overly rigid templates force researchers to contort their findings to fit predetermined structures. Overly flexible templates provide no benefit over starting from scratch.

The optimal template provides a structure that accommodates 80% of findings with minimal modification, while allowing 20% of findings to deviate from the standard structure. This balance requires thoughtful design and continuous refinement.

### The Anatomy of a Bug Bounty Report

Every bug bounty report contains core sections that serve specific functions: title (identification), summary (overview), severity assessment (classification), reproduction steps (validation), impact analysis (business context), remediation guidance (fix direction), and evidence (proof). Understanding the purpose of each section informs template design for each section.

The anatomy varies by platform: HackerOne uses a structured form with specific fields. Bugcrowd uses a template with VRT alignment. Intigriti allows more free-form submissions. Templates must accommodate platform-specific requirements while maintaining internal consistency.

### Template Layering

Effective template systems use layers: a base template for all reports, vulnerability-class templates for specific finding types, and program-specific templates for individual programs. This layering provides consistency while allowing customization. The base template ensures essential sections are always present. Vulnerability-class templates add specialized sections for specific finding types. Program-specific templates accommodate unique program requirements.

### Section Design Principles

Each template section should follow design principles: clear purpose statement, content guidelines, example snippets, and completion criteria. The purpose statement explains why the section exists. Content guidelines describe what to include. Example snippets provide reference implementations. Completion criteria define when the section is sufficient.

### Version Control for Templates

Templates evolve as you learn and as programs change. Version control ensures you can track changes, revert to previous versions, and understand the rationale for template modifications. Version control also prevents template degradation over time.

### Vulnerability-Specific Templates

Different vulnerability classes require different report structures. An XSS report needs sections for payload delivery, execution context, and session impact. An SSRF report needs sections for internal resource access, data exfiltration paths, and cloud metadata implications. Vulnerability-specific templates ensure these specialized sections are always included.

### Program-Specific Customization

Different programs have different requirements, expectations, and evaluation criteria. Program-specific templates accommodate these differences: specific scope documentation requirements, particular evidence formats, custom severity justifications, and unique communication protocols.

### Template Testing and Validation

Templates must be tested through actual use and validated through outcome tracking. A template that produces frequent follow-up questions needs revision. A template that consistently receives positive triager feedback should be preserved. Template testing is an ongoing process.

### Automation and Integration

Templates can be automated through: pre-filled forms, auto-generated sections, linked evidence libraries, and integrated calculation tools. Automation reduces manual effort while maintaining consistency. However, automation should enhance rather than replace human judgment.

### Template Governance

Template governance defines who can modify templates, when modifications are made, and how changes are communicated. For individual researchers, governance is simple: you control your templates. For teams, governance becomes more complex. Even for individuals, documenting template change rationale prevents ad hoc modifications that degrade quality.

## Prerequisites

### Documentation Design Skills
1. Information architecture fundamentals
2. Template design methodology
3. Document structure optimization
4. User experience design principles
5. Content strategy development

### Bug Bounty Platform Knowledge
1. HackerOne report format requirements
2. Bugcrowd submission templates
3. Intigriti report structure
4. Platform-specific field requirements
5. Platform limitations and workarounds

### Technical Writing Proficiency
1. Markdown formatting mastery
2. Technical writing conventions
3. Style guide development
4. Content consistency maintenance
5. Version control for documents

### Quality Assurance Skills
1. Template testing methodology
2. Outcome tracking and analysis
3. Continuous improvement processes
4. Peer review coordination
5. Template validation techniques

## Methodology

### Phase 1: Needs Assessment

**Step 1: Report Inventory Analysis**
Analyze your last 20-30 reports to identify common sections, recurring content patterns, and consistent quality issues. This analysis reveals what your templates need to address.

**Step 2: Platform Requirement Documentation**
Document the specific requirements of each platform you use: required fields, format constraints, character limits, and upload limitations. These requirements form the foundation of your template system.

**Step 3: Vulnerability Class Identification**
Identify the vulnerability classes you most frequently report. For each class, document the specialized sections and content that reports typically require.

**Step 4: Program Requirement Cataloging**
Catalog the specific requirements of programs you frequently target: scope documentation, evidence formats, severity justifications, and communication protocols.

### Phase 2: Base Template Design

**Step 5: Core Section Definition**
Define the core sections that appear in every report: title, summary, severity, reproduction steps, impact, remediation, and evidence. For each section, define its purpose, content guidelines, and completion criteria.

**Step 6: Content Guidelines Development**
For each core section, develop content guidelines: what to include, what to exclude, how to structure content, and what quality standards apply. These guidelines ensure consistency across reports.

**Step 7: Example Library Creation**
Create example snippets for each section showing exemplary content. These examples serve as references when writing actual reports and help maintain quality standards.

**Step 8: Template Formatting**
Format the template in Markdown or the platform's native format. Ensure proper heading hierarchy, consistent formatting, and clear visual structure. Test the template across platforms for compatibility.

### Phase 3: Vulnerability-Specific Templates

**Step 9: XSS Template Development**
Create an XSS-specific template with sections for: payload type and delivery mechanism, execution context (DOM-based, reflected, stored), session impact (cookies, tokens, localStorage), CSP bypass (if applicable), and browser compatibility notes.

**Step 10: SSRF Template Development**
Create an SSRF-specific template with sections for: internal resource identification, data exfiltration paths, cloud metadata access, port scanning results, and protocol-specific findings (file://, gopher://, dict://).

**Step 11: SQLi Template Development**
Create a SQL injection template with sections for: injection type (union, blind, error-based, time-based), database fingerprinting, data extraction methodology, privilege escalation potential, and file system access.

**Step 12: Authentication Bypass Template**
Create an authentication bypass template with sections for: bypass mechanism, affected endpoints, privilege level achieved, session management implications, and account takeover potential.

**Step 13: Additional Vulnerability Templates**
Create templates for other frequently reported classes: IDOR, CSRF, race conditions, file upload, business logic, and any specialized classes relevant to your research focus.

### Phase 4: Program-Specific Customization

**Step 14: Program Template Layer**
For programs you frequently target, create a program-specific template layer that includes: program-specific scope documentation, required evidence formats, custom severity justification language, and communication protocols.

**Step 15: Platform Template Adaptation**
Adapt your templates for each platform: HackerOne's structured fields, Bugcrowd's VRT alignment, and Intigriti's format requirements. Create platform-specific variants that maintain your internal consistency while meeting platform requirements.

**Step 16: Template Integration**
Integrate your template system with your research workflow. Create template access points: quick-reference cards, auto-fill tools, and template selection guides that help you choose the right template for each finding.

### Phase 5: Testing and Refinement

**Step 17: Template Testing Protocol**
Use each template for at least 5 reports before finalizing. Track: time to complete, follow-up question frequency, triage speed, and bounty outcomes. Compare these metrics across template versions.

**Step 18: Peer Review Integration**
Have peers review your templates for clarity, completeness, and usability. External perspectives identify issues you may have missed in your own design.

**Step 19: Outcome Analysis**
Analyze outcomes by template: acceptance rates, severity ratings, bounty amounts, and triage times. Correlate these outcomes with template characteristics to identify effective design elements.

**Step 20: Iterative Refinement**
Refine templates based on testing outcomes. Update content guidelines, adjust section structures, and improve example libraries. Template development is an ongoing process.

### Phase 6: Version Control and Maintenance

**Step 21: Version Control Implementation**
Implement version control for your template system: Git repository, version numbering, change logs, and backup procedures. Version control ensures you can track and manage template evolution.

**Step 22: Change Documentation**
Document all template changes: what changed, why it changed, and what outcomes the change produced. This documentation informs future template decisions and prevents regression.

**Step 23: Template Archiving**
Archive deprecated template versions for reference. Previous versions may contain useful elements for future templates or provide context for current design decisions.

**Step 24: Regular Review Cycles**
Establish regular review cycles: monthly template usage reviews, quarterly outcome analysis, and annual template system overhaul. Regular reviews prevent template stagnation.

## Tool Arsenal

### Template Creation Tools
1. **Markdown editors** - Template authoring and formatting
2. **Google Docs** - Collaborative template development
3. **Notion** - Template database and management
4. **Confluence** - Enterprise template systems
5. **Obsidian** - Linked template knowledge bases

### Platform-Specific Tools
6. **HackerOne template fields** - Platform-native template support
7. **Bugcrowd submission forms** - Platform-specific structure
8. **Intigriti report editor** - Platform format requirements
9. **Platform APIs** - Automated template population
10. **Browser extensions** - Template quick-access tools

### Version Control
11. **Git** - Template version control
12. **GitHub/GitLab** - Remote template storage
13. **GitHub Desktop** - GUI-based version control
14. **VS Code** - Integrated template editing
15. **Template diff tools** - Change visualization

### Content Management
16. **Snippet libraries** - Reusable content blocks
17. **Example databases** - Reference implementations
18. **Style guides** - Content standards documentation
19. **Terminology glossaries** - Consistent language reference
20. **Calculation templates** - CVSS and impact calculators

### Quality Assurance
21. **Checklist tools** - Template completion verification
22. **Peer review platforms** - Template review workflows
23. **Outcome tracking** - Template performance measurement
24. **A/B testing frameworks** - Template comparison
25. **Survey tools** - User feedback collection

### Automation Tools
26. **Auto-fill templates** - Pre-populated content
27. **Template generators** - Dynamic template creation
28. **Integration scripts** - Workflow automation
29. **API integrations** - Platform data population
30. **Calendar integrations** - Template scheduling

### Reference Materials
31. **Platform documentation** - Format requirements
32. **Community templates** - Shared template examples
33. **Style guide libraries** - Writing standards
34. **Vulnerability references** - Class-specific content
35. **Industry standards** - Reporting frameworks

### Documentation Tools
36. **Template changelogs** - Version history
37. **Usage guides** - Template application instructions
38. **Training materials** - Template learning resources
39. **Quick-reference cards** - Template selection guides
40. **Knowledge bases** - Template documentation

## Case Studies

### Case Study 1: Base Template Success

**Context:** A researcher developed a base template after analyzing 30 previous reports. The template included: title formula, summary structure, severity justification format, step-by-step instructions, impact quantification template, and evidence organization guide.

**Implementation:** The researcher used the base template for all subsequent reports. Each report took 30% less time to write. Follow-up questions decreased by 50%. Triage times improved by 40%.

**Outcome:** The base template was the single most impactful improvement to the researcher's report quality and efficiency.

### Case Study 2: XSS Template Specialization

**Context:** A researcher frequently found XSS vulnerabilities. They developed an XSS-specific template with sections for: payload delivery mechanism, execution context, session impact, CSP analysis, and browser compatibility.

**Implementation:** The XSS template ensured every XSS report included: the specific delivery vector (URL parameter, form field, HTTP header), the execution context (DOM-based, reflected, stored), the session impact (cookies, tokens, localStorage), CSP bypass details (if applicable), and browser testing results.

**Outcome:** XSS reports using the specialized template received fewer follow-up questions, faster triage, and higher severity ratings than previous XSS reports using the generic template.

### Case Study 3: Program-Specific Customization

**Context:** A researcher submitted frequently to a specific program with unique requirements: mandatory scope justification, specific evidence format, and custom severity justification language.

**Implementation:** The researcher created a program-specific template layer that included: scope justification section, program-specific evidence requirements, custom severity language, and communication protocol notes.

**Outcome:** Program-specific reports consistently received faster triage and fewer scope-related follow-up questions. The program eventually invited the researcher to a private program based on report quality.

### Case Study 4: Template Version Control

**Context:** A researcher used templates without version control. After several months, the template had evolved significantly, but the rationale for changes was lost. Reverting to a previous version was impossible.

**Implementation:** The researcher implemented Git version control for templates. Each change was documented with: what changed, why it changed, and the outcome of the change.

**Outcome:** Version control prevented template degradation, enabled informed template decisions, and provided a historical record of template evolution.

### Case Study 5: Vulnerability Class Template Library

**Context:** A researcher reported across 8 different vulnerability classes. Each class required different content and structure. Using a single generic template resulted in either missing content or unnecessary sections.

**Implementation:** The researcher created vulnerability-specific templates for each class: XSS, SSRF, SQLi, IDOR, CSRF, authentication bypass, race conditions, and file upload. Each template included class-specific sections alongside the base template structure.

**Outcome:** The template library reduced report writing time by 40% and improved consistency across vulnerability classes. Each report included all necessary sections without unnecessary padding.

### Case Study 6: Platform Adaptation Success

**Context:** A researcher used the same template across HackerOne, Bugcrowd, and Intigriti. Platform differences caused formatting issues, missing required fields, and inconsistent presentations.

**Implementation:** The researcher created platform-specific template variants: HackerOne templates used the platform's structured fields, Bugcrowd templates aligned with VRT categories, and Intigriti templates used the platform's free-form format.

**Outcome:** Platform-specific templates eliminated formatting issues, ensured all required fields were completed, and maintained consistent quality across platforms.

### Case Study 7: Template Testing Protocol

**Context:** A researcher developed a new template but implemented it without testing. The template included sections that were rarely needed and omitted sections that were frequently required.

**Implementation:** The researcher implemented a testing protocol: each new template was used for 5 reports before finalization. Metrics tracked: time to complete, follow-up question frequency, and triage speed.

**Outcome:** Testing identified unnecessary sections that added time without value and missing sections that caused follow-up questions. The refined template was significantly more effective than the initial design.

### Case Study 8: Example Library Impact

**Context:** A researcher had a template with content guidelines but no examples. The guidelines were interpreted differently across reports, leading to inconsistent content quality.

**Implementation:** The researcher created an example library with exemplary content for each section. Examples showed: high-quality summary paragraphs, effective reproduction steps, quantified impact statements, and properly organized evidence.

**Outcome:** The example library standardized content quality across reports. New reports consistently matched the quality of the best previous reports.

### Case Study 9: Automation Integration

**Context:** A researcher spent significant time manually populating template sections with consistent information: program name, scope, CVSS calculation, and evidence references.

**Implementation:** The researcher created automation tools: auto-fill templates for consistent sections, CVSS calculator integration, evidence reference linking, and template population scripts.

**Outcome:** Automation reduced report writing time by 50% while maintaining consistency. The researcher redirected saved time to additional research.

### Case Study 10: Template Governance System

**Context:** A researcher made frequent ad hoc template changes based on individual report needs. Over time, the template became bloated with rarely-used sections and lost its structural integrity.

**Implementation:** The researcher implemented governance rules: template changes required documented rationale, changes were tested before full implementation, and regular reviews assessed template effectiveness.

**Outcome:** Governance prevented template degradation, ensured changes were evidence-based, and maintained template quality over time.

## Advanced Techniques

### Dynamic Template Generation

Create templates that dynamically adjust based on input parameters: vulnerability class, program requirements, and platform. Dynamic generation reduces the number of static templates while maintaining customization.

### Template Analytics

Track template usage metrics: sections most frequently modified, sections most frequently omitted, and sections most frequently causing follow-up questions. These analytics inform template optimization.

### Collaborative Template Development

Collaborate with other researchers on template development. Shared templates benefit from diverse perspectives and collective experience. Collaborative development also creates community resources.

### AI-Assisted Template Population

Use AI tools to assist with template population: generating reproduction steps from testing notes, quantifying impact from technical findings, and formatting evidence descriptions. AI assistance should enhance rather than replace human judgment.

### Template Interoperability

Design templates that work across multiple platforms without significant modification. Interoperability reduces the overhead of maintaining platform-specific variants.

### Knowledge Base Integration

Integrate templates with your knowledge base: link template sections to relevant documentation, reference previous reports for content patterns, and connect templates to your learning resources.

### Feedback Loop Automation

Automate the feedback loop between template usage and template improvement: track outcomes by template, identify improvement opportunities, and suggest template modifications based on data.

## Detection

### Template Quality Indicators
1. Consistent report structure across submissions
2. Reduced time per report
3. Fewer follow-up questions from triagers
4. Faster triage times
5. Higher acceptance rates

### Template Deficiency Signs
1. Frequent manual additions to template sections
2. Sections consistently left empty or irrelevant
3. Inconsistent content quality across reports
4. High follow-up question rates
5. Long time spent customizing templates

### Usability Assessment
1. Template selection is intuitive
2. Content guidelines are clear
3. Examples are relevant and helpful
4. Platform adaptation is straightforward
5. Version control is maintained

## Impact

### Efficiency Gains
Templates reduce report writing time by 30-50%, allowing more time for research and less time for documentation.

### Quality Improvement
Consistent templates improve report quality by ensuring all necessary sections are included and content standards are maintained.

### Triage Speed
Well-structured templates produce reports that triagers can process faster, reducing time to resolution and payment.

### Relationship Building
Consistent, high-quality reports build researcher reputation and strengthen program relationships.

## Pitfalls

### Pitfall 1: Over-Engineering
Creating overly complex templates with unnecessary sections wastes time and reduces usability. Keep templates focused on essential content.

### Pitfall 2: Rigidity
Templates that cannot accommodate unusual findings force researchers to contort their reports. Build flexibility into template design.

### Pitfall 3: No Version Control
Failing to version templates leads to template degradation and lost improvement history. Implement version control from the start.

### Pitfall 4: No Testing
Deploying templates without testing wastes time on ineffective designs. Test each template before full implementation.

### Pitfall 5: Ignoring Outcomes
Not tracking template outcomes prevents evidence-based improvement. Measure template effectiveness regularly.

### Pitfall 6: Copy-Paste Culture
Using templates as copy-paste sources without adaptation produces generic, low-quality reports. Templates guide, not replace, thoughtful writing.

### Pitfall 7: Platform Ignorance
Creating templates without considering platform requirements causes formatting issues and missing fields. Platform awareness is essential.

### Pitfall 8: No Peer Review
Developing templates without external input produces blind spots and missed opportunities. Peer review improves template quality.

### Pitfall 9: Stagnation
Failing to update templates based on new learnings leads to outdated, ineffective designs. Regular reviews prevent stagnation.

### Pitfall 10: Governance Neglect
Allowing ad hoc template changes without governance degrades template quality over time. Implement governance from the start.

## Integration

### With Report Writing
Templates should be the starting point for every report, not an afterthought. Select the appropriate template before beginning to write.

### With Severity Assessment
Templates should include structured severity justification sections that guide CVSS calculation and impact documentation.

### With Evidence Management
Templates should reference attachment requirements and provide guidance on evidence organization and naming.

### With Peer Review
Templates should be reviewed by peers regularly to identify improvement opportunities and ensure continued effectiveness.

### With Program Research
Program-specific template customization should be based on program research, including scope requirements and evaluation criteria.

## Reporting

### Template Metrics to Track
- Report writing time per template
- Follow-up question rate by template
- Triage speed by template
- Acceptance rate by template
- Bounty amount by template

### Documentation Standards
Maintain template documentation: design rationale, content guidelines, example libraries, and version history. This documentation supports template maintenance and improvement.

### Continuous Improvement
Review template performance monthly. Refine based on outcomes. Update example libraries with exemplary content. Maintain template quality over time.

## Labs

### Lab 1: Base Template Design
Analyze your last 20 reports. Identify common sections and content patterns. Design a base template that accommodates 80% of your findings.

### Lab 2: Vulnerability-Specific Template
Create a specialized template for your most frequently reported vulnerability class. Include class-specific sections alongside the base template structure.

### Lab 3: Platform Adaptation
Adapt your base template for 2 different platforms. Ensure all platform-specific requirements are met while maintaining template consistency.

### Lab 4: Template Testing
Use a new template for 5 reports. Track time to complete, follow-up questions, and triage speed. Compare with previous reports.

### Lab 5: Example Library Development
Create example snippets for each section of your template. Ensure examples demonstrate high-quality content standards.

### Lab 6: Version Control Implementation
Set up Git version control for your template system. Document the rationale for each change. Maintain a change log.

### Lab 7: Peer Review
Have a peer review your template system. Collect feedback on usability, completeness, and clarity. Revise based on feedback.

### Lab 8: Automation Integration
Identify repetitive template population tasks. Create automation tools for: CVSS calculation, evidence referencing, and section pre-population.

## Ethics

### Template Integrity
Templates should support honest, accurate reporting. Do not create templates that encourage exaggeration, misrepresentation, or incomplete disclosure.

### Accessibility
Templates should be accessible to researchers of all experience levels. Complex templates should include clear guidance and examples.

### Community Contribution
Share useful template designs with the community. Community contribution benefits all researchers and improves overall reporting quality.

### Continuous Improvement
Commit to continuous template improvement as a professional ethic. Outdated, ineffective templates harm both researchers and programs.

### Platform Compliance
Ensure templates comply with platform terms of service and reporting requirements. Non-compliant templates can result in account suspension.

## Cheat Sheet

### Template Selection Guide
| Finding Type | Template | Key Sections |
|--------------|----------|--------------|
| XSS | XSS-specific | Payload, execution context, session impact |
| SSRF | SSRF-specific | Internal resources, data exfil, cloud metadata |
| SQLi | SQLi-specific | Injection type, DB fingerprint, data extraction |
| IDOR | IDOR-specific | Affected resources, authorization bypass |
| Auth Bypass | Auth-specific | Mechanism, endpoints, privilege level |
| Race Condition | Race-specific | Timing window, concurrency, impact |
| File Upload | Upload-specific | Bypass, file type, execution |
| Business Logic | Logic-specific | Flow, flaw, impact |

### Template Quality Checklist
- [ ] Core sections present (title, summary, severity, steps, impact, remediation, evidence)
- [ ] Content guidelines clear and specific
- [ ] Examples provided for each section
- [ ] Platform requirements met
- [ ] Vulnerability-specific sections included
- [ ] Version control implemented
- [ ] Tested with actual reports
- [ ] Peer reviewed

### Quick Template Customization
1. Select appropriate base template
2. Add vulnerability-specific sections
3. Customize for program requirements
4. Adapt for platform format
5. Review and finalize

### Template Maintenance Schedule
- Monthly: Review template usage metrics
- Quarterly: Analyze template outcomes
- Annually: Major template system overhaul
- As needed: Update for platform changes
