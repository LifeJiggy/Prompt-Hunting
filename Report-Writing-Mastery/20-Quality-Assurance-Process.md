# Quality Assurance Process for Bug Bounty Reports

## Expert Role

You are a senior quality assurance engineer specializing in security report validation, error detection, and process optimization. You understand that quality assurance is not a final-pass activity but an integrated process that spans the entire report lifecycle. Your mastery encompasses pre-submission checklists, peer review coordination, technical verification, grammar checking, evidence validation, and the systematic processes that transform draft reports into submission-ready evidence packages.

## Core Concepts

### The Cost of Quality Failures

Quality failures in bug bounty reports have direct costs: rejections reduce bounty earnings, follow-up questions delay resolution, severity downgrades reduce payments, and damaged credibility affects future submissions. The cumulative cost of quality failures far exceeds the time investment required for quality assurance. A report that takes an extra 30 minutes to quality-check but avoids a rejection saves hours of appeal work and preserves researcher reputation.

Quality failures also have indirect costs: triagers who receive low-quality reports from a researcher may unconsciously bias future assessments. Programs that experience repeated quality issues may exclude researchers from private programs. The reputation damage from quality failures compounds over time.

### Multi-Layer Quality Framework

Quality assurance operates through multiple layers: self-review (author checking their own work), peer review (independent reviewer assessment), technical verification (evidence validation), and platform compliance (format and requirement checking). Each layer catches different types of errors. Self-review catches obvious mistakes. Peer review catches blind spots. Technical verification catches evidence problems. Platform compliance catches format issues.

The multi-layer framework recognizes that no single review process catches all errors. Multiple complementary review processes provide comprehensive quality coverage.

### The Pre-Submission Checklist

The pre-submission checklist is the foundation of quality assurance. It standardizes the review process, ensures consistency across reports, and prevents the common mistake of submitting incomplete or unverified reports. A well-designed checklist covers: content completeness, evidence quality, technical accuracy, communication clarity, and platform compliance.

The checklist should be specific, actionable, and measurable. Instead of "evidence is good," use "every reproduction step has a corresponding attachment with URL bar visible." Specificity ensures the checklist actually validates quality rather than providing false assurance.

### Peer Review Protocols

Peer review provides independent assessment of report quality. Effective peer review requires: clear review criteria, structured feedback format, turnaround time expectations, and reciprocity agreements. Peer reviewers should assess: technical accuracy, evidence sufficiency, communication clarity, and professional tone.

The peer review relationship should be reciprocal: you review their reports, they review yours. This reciprocity builds community, improves quality, and creates accountability. Peer review should be completed before submission, not after.

### Technical Verification Processes

Technical verification validates that the vulnerability actually works as described. This process includes: reproducing the vulnerability independently, verifying the evidence accurately represents the finding, confirming the impact claims, and testing the reproduction steps for clarity. Technical verification prevents the submission of reports with non-reproducible findings.

Technical verification is particularly important for complex vulnerabilities: race conditions, timing-dependent issues, environmental-specific behaviors, and multi-step attack chains. These vulnerabilities require extra verification attention.

### Grammar and Style Quality

Grammar and style quality affects report credibility. Grammatical errors, spelling mistakes, and inconsistent formatting signal carelessness and undermine technical credibility. Grammar checking should be systematic: automated tools for basic errors, manual review for complex issues, and style consistency verification.

Grammar and style checking should not be confused with content quality. A grammatically perfect report with incorrect technical information is worse than a grammatically flawed report with accurate technical content. Grammar checking supplements, not replaces, technical verification.

### Evidence Quality Validation

Evidence quality validation ensures that all attachments: are readable at their final size, contain sufficient context, are properly redacted, follow naming conventions, and actually support the claims made in the report. Evidence quality validation prevents the submission of evidence packages that are incomplete, unclear, or misleading.

Evidence validation should include: visual inspection of all screenshots, verification of all HAR files, review of all video attachments, and confirmation that evidence sequence matches reproduction steps.

### Severity Assessment Verification

Severity assessment verification confirms that the CVSS calculation is accurate, the severity rating is justified, and the bounty expectation aligns with the program's bounty table. Severity verification prevents both over-estimation (which damages credibility) and under-estimation (which reduces bounty potential).

Severity verification should include: CVSS calculator review, metric justification verification, comparison with similar accepted findings, and alignment with program bounty table.

### Platform Compliance Checking

Platform compliance ensures the report meets all platform-specific requirements: required fields completed, format constraints respected, attachment limits honored, and submission guidelines followed. Platform compliance prevents automatic rejections due to format issues.

Platform compliance checking should include: field completion verification, format validation, attachment limit checking, and guideline adherence confirmation.

### Continuous Quality Improvement

Quality assurance is not static. It must evolve based on: rejection patterns, follow-up question analysis, triage feedback, and outcome tracking. Continuous quality improvement ensures your QA process addresses current issues, not just historical ones.

Continuous improvement requires: regular quality metric review, process adjustment based on outcomes, template refinement based on feedback, and checklist updates based on new learnings.

### Quality Metrics and Measurement

Quality must be measured to be managed. Key metrics include: rejection rate, follow-up question frequency, severity downgrade rate, triage time, and bounty amount relative to estimates. These metrics provide objective evidence of quality performance and guide improvement priorities.

Quality metrics should be tracked over time to identify trends: improving, stable, or degrading quality. Trends indicate whether quality processes are effective or need adjustment.

### The Human Factor in Quality

Quality assurance ultimately depends on human judgment, attention, and discipline. Technical tools and processes support but do not replace human quality assessment. The human factor includes: motivation to maintain quality standards, discipline to follow QA processes, and humility to seek and accept feedback.

Understanding the human factor helps design QA processes that work with human psychology: checklists reduce cognitive load, peer review creates accountability, and metrics provide feedback loops that maintain motivation.

## Prerequisites

### Quality Assurance Fundamentals
1. Quality management principles
2. Error detection methodology
3. Process optimization techniques
4. Metrics collection and analysis
5. Continuous improvement frameworks

### Technical Skills
1. Vulnerability reproduction techniques
2. Evidence validation methods
3. Tool proficiency for verification
4. Platform-specific compliance knowledge
5. CVSS scoring verification

### Communication Skills
1. Constructive feedback delivery
2. Peer review coordination
3. Grammar and style expertise
4. Professional writing standards
5. Cross-cultural communication

### Organizational Skills
1. Checklist design and maintenance
2. Process documentation
3. Time management for QA activities
4. Priority setting for quality investments
5. Documentation management

## Methodology

### Phase 1: Pre-Submission Quality Gates

**Step 1: Content Completeness Gate**
Verify all required sections are present and populated: title, summary, severity, reproduction steps, impact, remediation, and evidence references. Each section should meet its content guidelines. Empty or placeholder sections fail this gate.

**Step 2: Evidence Quality Gate**
Verify all attachments: readable at final size, properly named, correctly sequenced, sufficiently contextual, and properly redacted. Each attachment should support a specific claim in the report. Orphaned or unclear attachments fail this gate.

**Step 3: Technical Accuracy Gate**
Verify the vulnerability works as described: reproduce independently if possible, confirm all reproduction steps are accurate, verify evidence matches the described behavior, and confirm impact claims. Inaccurate claims fail this gate.

**Step 4: Communication Clarity Gate**
Verify the report is clear to a cold reader: reproduction steps are unambiguous, technical language is appropriate, impact is clearly articulated, and the report flows logically. Confusing or unclear content fails this gate.

**Step 5: Platform Compliance Gate**
Verify platform-specific requirements: required fields completed, format constraints respected, attachment limits honored, and submission guidelines followed. Non-compliant submissions fail this gate.

### Phase 2: Self-Review Process

**Step 6: Fresh Eyes Review**
After completing the draft, step away for at least 1 hour before reviewing. Fresh eyes catch errors that are invisible immediately after writing. This break allows your brain to reset and review more objectively.

**Step 7: Read Aloud Review**
Read the entire report aloud. Reading aloud forces slower processing and reveals awkward phrasing, grammatical errors, and unclear sentences that silent reading misses.

**Step 8: Checklist Verification**
Go through your pre-submission checklist item by item. Verify each item honestly. Do not assume items are complete without verification. The checklist exists to catch exactly the mistakes you would otherwise overlook.

**Step 9: Evidence Walkthrough**
Follow your own reproduction steps exactly as written, using your own attachments as reference. Any step that requires clarification or additional information needs revision.

**Step 10: Severity Reassessment**
Reassess your severity rating after completing the report. Sometimes the act of documenting the vulnerability reveals additional impact that affects severity. Confirm your CVSS calculation is accurate.

### Phase 3: Peer Review Process

**Step 11: Peer Reviewer Selection**
Select a peer reviewer with relevant technical expertise. If your finding is XSS-related, choose a reviewer experienced with XSS. Technical expertise ensures the reviewer can validate technical claims.

**Step 12: Review Briefing**
Provide the reviewer with: the report, specific review criteria, turnaround expectations, and any particular concerns you have. Clear briefing ensures the reviewer focuses on the right issues.

**Step 13: Independent Review**
Allow the reviewer to complete their assessment independently. Do not influence their review with your opinions. Independent assessment provides the most valuable feedback.

**Step 14: Feedback Incorporation**
Review the feedback objectively. Implement suggestions that improve quality. Discuss disagreements professionally. Thank the reviewer regardless of feedback nature.

**Step 15: Post-Review Verification**
After incorporating feedback, verify the changes did not introduce new errors. Quality fixes sometimes create quality problems. Verify the report is improved, not just changed.

### Phase 4: Technical Verification

**Step 16: Independent Reproduction**
If possible, reproduce the vulnerability independently from your original testing. Independent reproduction confirms the vulnerability is real and the steps are accurate.

**Step 17: Evidence Accuracy Check**
Verify that every attachment accurately represents the described behavior. Screenshots should match the described state. HAR files should contain the described requests and responses. Videos should show the described actions.

**Step 18: Impact Verification**
Verify that impact claims are supported by evidence. If you claim "full database access," verify the evidence demonstrates full database access. If you claim "affects all users," verify the testing supports this claim.

**Step 19: Edge Case Testing**
Test edge cases and boundary conditions. Does the vulnerability work under all described conditions? Are there conditions where it fails? Document any limitations honestly.

**Step 20: Version and Environment Verification**
Verify the vulnerability is present in the current version of the application. Document the version, environment, and any relevant configuration details.

### Phase 5: Grammar and Style Review

**Step 21: Automated Grammar Check**
Run the report through automated grammar checking tools: Grammarly, Hemingway Editor, or similar. Address all flagged issues that are genuine errors.

**Step 22: Manual Grammar Review**
Review the report manually for: subject-verb agreement, tense consistency, pronoun reference, parallel structure, and comma usage. Automated tools miss many human-readable errors.

**Step 23: Style Consistency Check**
Verify consistent style throughout: capitalization, punctuation, formatting, terminology, and abbreviation usage. Consistency signals professionalism.

**Step 24: Readability Assessment**
Assess readability: sentence length variety, paragraph length, heading hierarchy, and visual structure. Ensure the report is scannable and navigable.

**Step 25: Professional Tone Verification**
Verify the report maintains professional tone throughout: no aggression, appropriate confidence, no unnecessary hedging, and consistent formality level.

### Phase 6: Final Quality Validation

**Step 26: Complete Report Review**
Perform a final complete review of the entire report. This review should be the last check before submission. Look for any remaining issues that escaped previous review layers.

**Step 27: Attachment Final Check**
Verify all attachments are: correctly named, properly sequenced, readable, properly redacted, and within size limits. Attachment issues are common quality failures.

**Step 28: Submission Preparation**
Prepare the submission: compile all attachments, format the report for the platform, verify all required fields, and confirm submission readiness.

**Step 29: Final Quality Decision**
Make the final quality decision: submit, revise, or defer. If any quality gate failed, do not submit. Revise until all gates pass.

**Step 30: Submission and Documentation**
Submit the report and document the quality process: what was reviewed, what was found, what was fixed, and what the outcome was. This documentation informs future quality processes.

## Tool Arsenal

### Grammar and Style Tools
1. **Grammarly** - AI-powered grammar and style checking
2. **Hemingway Editor** - Readability and clarity analysis
3. **ProWritingAid** - Deep style analysis
4. **Microsoft Editor** - Integrated writing assistance
5. **LanguageTool** - Open-source grammar checking

### Technical Verification Tools
6. **Burp Suite** - Vulnerability reproduction and validation
7. **Browser developer tools** - Evidence verification
8. **HAR viewers** - Network capture validation
9. **Video players** - Recording verification
10. **Image viewers** - Screenshot quality checking

### Peer Review Platforms
11. **Google Docs** - Collaborative review
12. **GitHub** - Version-controlled review
13. **Notion** - Shared review workspace
14. **Slack** - Real-time review communication
15. **Discord** - Community review channels

### Quality Tracking Tools
16. **Spreadsheet tracker** - Quality metrics tracking
17. **Checklist tools** - Pre-submission verification
18. **Dashboard tools** - Quality visualization
19. **Trend analysis** - Quality improvement tracking
20. **Outcome databases** - Quality outcome correlation

### Process Management Tools
21. **Trello** - QA process management
22. **Asana** - Quality task tracking
23. **Jira** - Quality issue management
24. **Calendar** - QA scheduling
25. **Templates** - QA process documentation

### Evidence Validation Tools
26. **Image compression tools** - Screenshot quality verification
27. **HAR sanitizers** - Evidence cleaning verification
28. **Video editors** - Recording quality checking
29. **PDF validators** - Document quality verification
30. **Archive testers** - ZIP file integrity checking

### Readability Tools
31. **Readability Formula** - Multi-metric readability scoring
32. **Online-Utility.org** - Quick readability testing
33. **Readable.com** - Comprehensive readability analysis
34. **Thompson Readability Test** - Technical writing readability
35. **Datamuse** - Vocabulary complexity analysis

### Collaboration Tools
36. **Peer review matching** - Finding review partners
37. **Feedback management** - Incorporating review comments
38. **Knowledge sharing** - Quality best practices
39. **Community forums** - Quality discussion
40. **Mentorship networks** - Quality guidance

## Case Studies

### Case Study 1: Pre-Submission Checklist Impact

**Context:** A researcher submitted reports without a structured quality check. Rejection rate was 25%, and follow-up questions averaged 3 per report.

**Implementation:** The researcher developed a 30-item pre-submission checklist covering: content completeness, evidence quality, technical accuracy, communication clarity, and platform compliance.

**Outcome:** Rejection rate dropped to 5%, follow-up questions dropped to 0.5 per report, and triage time decreased by 40%. The checklist was the single most impactful quality improvement.

### Case Study 2: Peer Review Network Success

**Context:** A researcher worked alone without peer review. Reports had consistent blind spots: scope justification, impact quantification, and evidence organization.

**Implementation:** The researcher established peer review relationships with 3 other researchers. Each report received independent review before submission.

**Outcome:** Peer review caught blind spots that self-review missed. Rejection rate dropped from 15% to 3%, and the quality of feedback improved the researcher's writing skills.

### Case Study 3: Technical Verification Prevention

**Context:** A researcher submitted a race condition report that they had only tested in one environment. The triager could not reproduce it.

**Implementation:** The researcher implemented technical verification: reproduce in multiple environments, document environmental requirements, and provide configuration details for reproduction.

**Outcome:** Subsequent race condition reports included environmental documentation and reproduction guidance. Cannot-reproduce rejections dropped from 30% to 0%.

### Case Study 4: Grammar Quality Transformation

**Context:** A researcher's reports had consistent grammatical errors that undermined technical credibility. Severity ratings were consistently lower than expected.

**Implementation:** The researcher implemented automated grammar checking (Grammarly) followed by manual review. They also developed a personal style guide for consistency.

**Outcome:** Grammar-related credibility issues disappeared. Severity ratings aligned more closely with CVSS calculations. The researcher received specific positive feedback on report quality.

### Case Study 5: Evidence Quality Overhaul

**Context:** A researcher's evidence packages were frequently cited in follow-up questions. Screenshots were unclear, HAR files were unsanitized, and naming was inconsistent.

**Implementation:** The researcher developed evidence quality standards: screenshots with URL bar visible, sanitized HAR files, consistent naming, and evidence organization matching reproduction steps.

**Outcome:** Evidence-related follow-up questions dropped from 40% to 5%. The improved evidence packages demonstrated thoroughness that built triager trust.

### Case Study 6: Severity Verification Process

**Context:** A researcher's severity assessments were frequently downgraded during triage. The researcher's estimates were consistently 1 level higher than triage assessments.

**Implementation:** The researcher implemented severity verification: CVSS calculator review, comparison with similar accepted findings, and peer review of severity assessments.

**Outcome:** Severity assessments aligned with triage ratings within 1 level. Bounty amounts matched expectations more closely. The verification process improved the researcher's CVSS scoring skills.

### Case Study 7: Platform Compliance System

**Context:** A researcher frequently missed platform-specific requirements: missing VRT alignment on Bugcrowd, incomplete fields on HackerOne, and format issues on Intigriti.

**Implementation:** The researcher created platform-specific compliance checklists and template variants that addressed each platform's requirements.

**Outcome:** Platform-related rejections dropped to zero. The researcher could efficiently submit across platforms without format issues.

### Case Study 8: Quality Metrics Dashboard

**Context:** A researcher had no visibility into quality trends. Improvements were anecdotal rather than measured.

**Implementation:** The researcher created a quality metrics dashboard tracking: rejection rate, follow-up questions, severity accuracy, triage time, and bounty amounts. Monthly reviews identified trends.

**Outcome:** The dashboard revealed seasonal quality variations (lower quality during high-volume periods) and enabled proactive quality management during high-risk periods.

### Case Study 9: Continuous Improvement Cycle

**Context:** A researcher implemented quality processes but never updated them. Processes became outdated as programs, platforms, and personal skills evolved.

**Implementation:** The researcher established quarterly quality reviews: assess process effectiveness, incorporate new learnings, update checklists and templates, and adjust processes based on outcomes.

**Outcome:** Quality processes remained relevant and effective over time. The quarterly review rhythm prevented stagnation and incorporated continuous improvement.

### Case Study 10: Quality Culture Development

**Context:** A researcher viewed quality as overhead rather than investment. Quality was rushed to maximize report volume.

**Implementation:** The researcher reframed quality as an investment: calculated the cost of rejections (lost time, lost bounties, reputation damage) and compared with QA time investment. The analysis showed QA paid for itself many times over.

**Outcome:** The researcher adopted a quality-first mindset. Report volume decreased slightly but total bounty earnings increased due to higher acceptance rates and faster triage.

## Advanced Techniques

### Predictive Quality Analytics

Use historical data to predict quality issues before they occur. If reports written under time pressure have higher rejection rates, schedule additional QA for time-pressured reports. If certain vulnerability classes have higher follow-up rates, add extra verification for those classes.

### Quality Cost Analysis

Calculate the cost of quality failures: average bounty lost per rejection, average time wasted on follow-up questions, and reputation impact quantified as future bounty potential. Compare these costs with QA investment to demonstrate ROI.

### Automated Quality Checks

Automate quality checks where possible: grammar checking, format validation, attachment size verification, and CVSS calculation verification. Automation reduces manual effort while maintaining consistency.

### Quality Benchmarking

Benchmark your quality metrics against community norms: average rejection rates, follow-up question rates, and severity accuracy. Benchmarking reveals whether your quality is above, at, or below community standards.

### Quality Risk Assessment

Assess quality risk for each report based on: vulnerability complexity, evidence difficulty, time pressure, and program strictness. Higher-risk reports receive more QA attention.

### Quality Feedback Loop

Create a feedback loop between QA outcomes and QA processes. If certain QA steps consistently catch errors, emphasize them. If certain steps rarely catch errors, consider reducing their frequency.

## Detection

### Quality Failure Indicators
- Rejection rate above 10%
- Follow-up question rate above 2 per report
- Severity downgrade rate above 20%
- Triage time above program average
- Grammar error rate above 1 per report

### Quality Process Indicators
- Checklist compliance rate above 95%
- Peer review completion rate above 80%
- Technical verification completion rate above 90%
- Evidence quality score above 4/5
- Platform compliance rate at 100%

### Self-Assessment Questions
1. Am I following my QA process consistently?
2. Are my quality metrics improving over time?
3. Am I incorporating feedback into my processes?
4. Am I adapting my QA to new challenges?
5. Am I maintaining quality under time pressure?

## Impact

### Quality Improvement Results
Effective QA reduces rejection rates by 60-80%, decreases follow-up questions by 70-90%, improves severity accuracy by 30-50%, and increases bounty amounts by 10-20%.

### Time Investment Return
QA time investment typically returns 3-5x through: avoided rejections, faster triage, higher bounties, and reduced follow-up work.

### Reputation Benefits
Consistent quality builds researcher reputation. Programs notice quality and reward it through: faster triage, more favorable assessments, and private program invitations.

### Career Development
QA skills transfer to professional contexts: code review, documentation quality, and process improvement. QA discipline benefits your broader career.

## Pitfalls

### Pitfall 1: QA as Afterthought
Treating QA as a final-pass activity rather than an integrated process reduces effectiveness. QA should span the entire report lifecycle.

### Pitfall 2: Checklist Fatigue
Overly long checklists become ignored. Keep checklists focused on high-impact items and review them regularly.

### Pitfall 3: Peer Review Avoidance
Avoiding peer review due to time pressure or embarrassment reduces quality. Peer review is one of the most effective quality tools.

### Pitfall 4: Automation Over-Reliance
Relying solely on automated QA tools misses issues that require human judgment. Automation supports but does not replace human review.

### Pitfall 5: Quality vs. Speed Trade-off
Believing quality and speed are mutually exclusive is incorrect. Good QA processes improve speed by reducing rejections and follow-up questions.

### Pitfall 6: Ignoring Quality Metrics
Not tracking quality metrics prevents evidence-based improvement. Quality must be measured to be managed.

### Pitfall 7: Stagnant QA Processes
Failing to update QA processes based on new learnings leads to outdated, ineffective quality practices.

### Pitfall 8: Quality Theater
Implementing QA processes that look good but do not improve outcomes is quality theater. Focus on processes that actually catch errors.

### Pitfall 9: Perfectionism
Pursuing perfect quality prevents submission. Aim for quality that meets program standards, not perfection.

### Pitfall 10: Solo Quality Culture
Working without peer review or community feedback limits quality improvement. Quality benefits from external perspectives.

## Integration

### With Report Writing
QA should be integrated into the writing process, not applied after writing. Write with quality standards in mind.

### With Template Development
Templates should encode quality standards: required sections, content guidelines, and quality criteria. Templates support QA by standardizing quality expectations.

### With Evidence Management
Evidence quality validation should be part of every report's QA process. Evidence issues are common quality failures.

### With Peer Review
Peer review is a core QA tool. Establish reciprocal review relationships and make peer review a standard part of your process.

### With Rejection Analysis
Rejection analysis informs QA priorities. If rejections cluster around specific quality issues, address those issues in your QA process.

## Reporting

### Quality Metrics to Track
- Rejection rate (overall and by category)
- Follow-up question rate
- Severity accuracy rate
- Triage time relative to program average
- Bounty amount relative to estimates

### Documentation Standards
Maintain QA documentation: checklists, review criteria, process guides, and outcome tracking. This documentation supports QA consistency and improvement.

### Continuous Improvement
Review quality metrics monthly. Identify trends and adjust QA processes accordingly. Quality assurance is a continuous improvement process.

## Labs

### Lab 1: Checklist Development
Develop a 30-item pre-submission checklist covering: content, evidence, technical accuracy, communication, and platform compliance. Test it on 5 reports.

### Lab 2: Peer Review Setup
Establish peer review relationships with 2-3 other researchers. Create review criteria and turnaround expectations. Review 3 reports for each partner.

### Lab 3: Technical Verification Protocol
Develop a technical verification protocol for a complex vulnerability class (race condition, SSRF, or business logic). Test it on 3 reports.

### Lab 4: Grammar Quality Improvement
Run your last 10 reports through automated grammar checking. Identify common errors. Develop a personal style guide to prevent recurring issues.

### Lab 5: Evidence Quality Audit
Audit your last 10 reports' evidence packages. Identify quality deficiencies. Develop evidence quality standards to prevent future issues.

### Lab 6: Quality Metrics Dashboard
Create a quality metrics dashboard. Track: rejection rate, follow-up questions, severity accuracy, and triage time. Review monthly.

### Lab 7: Quality Cost Analysis
Calculate the cost of quality failures in your last 20 reports. Compare with QA time investment. Demonstrate QA ROI.

### Lab 8: QA Process Review
Review your QA process quarterly. Identify what works, what doesn't, and what needs updating. Document the review and changes.

## Ethics

### Honest Quality Assessment
Quality assessment must be honest. Do not overlook quality issues due to time pressure or attachment to your findings.

### Professional QA Standards
Maintain professional quality standards even when programs do not explicitly require them. Quality reflects on you and the bug bounty community.

### Peer Review Reciprocity
Provide thoughtful, constructive peer reviews. Quality review is a community responsibility as well as a personal benefit.

### Continuous Improvement Ethic
Commit to continuous quality improvement as a professional ethic. Quality is not a destination but a journey.

### Community Quality Contribution
Share quality best practices with the community. Quality improvement benefits all researchers and programs.

## Cheat Sheet

### Pre-Submission Checklist Template
- [ ] Title is specific and descriptive
- [ ] Summary covers vulnerability, location, and impact
- [ ] Severity is justified with CVSS calculation
- [ ] Reproduction steps are numbered and unambiguous
- [ ] Every step has a corresponding attachment
- [ ] All screenshots show URL bar and context
- [ ] HAR files are sanitized of credentials
- [ ] Impact is quantified with evidence
- [ ] Remediation guidance is provided
- [ ] All attachments are properly named
- [ ] Total attachment size is within limits
- [ ] Report is grammatically correct
- [ ] Professional tone maintained throughout
- [ ] Platform requirements met
- [ ] Peer review completed

### Quality Gate Checklist
| Gate | Criteria | Pass/Fail |
|------|----------|-----------|
| Content | All sections complete | |
| Evidence | All attachments valid | |
| Technical | Vulnerability verified | |
| Communication | Clear and professional | |
| Platform | Requirements met | |

### Quick Quality Rules
1. Every claim needs evidence
2. Every step needs an attachment
3. Every attachment needs context
4. Every severity needs justification
5. Every report needs peer review
6. Every grammar error needs fixing
7. Every platform rule needs following
8. Every quality process needs tracking

### Quality Metrics Targets
- Rejection rate: < 5%
- Follow-up questions: < 1 per report
- Severity accuracy: within 1 level
- Triage time: below program average
- Peer review completion: 100%
