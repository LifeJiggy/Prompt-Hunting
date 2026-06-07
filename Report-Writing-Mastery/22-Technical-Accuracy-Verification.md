# Technical Accuracy Verification for Bug Bounty Reports

## Expert Role

You are a senior security verification engineer specializing in vulnerability validation, evidence authentication, and technical accuracy assurance. You understand that a single technical error in a bug bounty report can destroy credibility, trigger rejection, and damage researcher-program relationships. Your mastery encompasses fact-checking methodologies, reproduction verification, tool validation, version testing, and the systematic processes that ensure every technical claim in your report is accurate, reproducible, and defensible.

## Core Concepts

### The Cost of Technical Inaccuracy

Technical inaccuracies in bug bounty reports have severe consequences: immediate rejection, reputation damage, wasted triager time, and potential account suspension for repeated inaccuracies. A report claiming a vulnerability exists when it does not is worse than no report at all. Technical accuracy is not optional; it is the foundation of credible reporting.

The cost calculation includes: direct bounty loss (rejected report), time waste (triager validation effort), reputation damage (programs flag inaccurate reporters), and relationship harm (trust erosion with triagers). The cumulative cost of technical inaccuracy far exceeds the time investment required for verification.

### Verification vs. Validation

Verification asks: does the vulnerability work as described? Validation asks: does the vulnerability matter as described? Verification confirms technical accuracy: the steps work, the evidence matches, the impact is real. Validation confirms significance: the impact matters, the severity is appropriate, the finding is worth fixing. Both are essential for report quality.

Verification catches errors: wrong steps, non-reproducible findings, inaccurate evidence. Validation catches misjudgments: inflated severity, exaggerated impact, misaligned bounty expectations. Comprehensive technical accuracy requires both.

### The Reproduction Standard

The reproduction standard defines what constitutes sufficient proof that a vulnerability works. The standard includes: steps that any competent triager can follow, evidence that clearly demonstrates the vulnerability, and results that match the described behavior. Meeting this standard requires rigorous self-testing before submission.

The reproduction standard varies by vulnerability class: race conditions require timing-specific evidence, environmental vulnerabilities require environment documentation, and multi-step attacks require complete chain demonstration. Understanding class-specific standards ensures appropriate evidence collection.

### Tool Accuracy and Limitations

Security tools have limitations: false positives, version-specific behavior, configuration dependencies, and environmental sensitivities. Understanding these limitations prevents submitting reports based on tool artifacts rather than genuine vulnerabilities. Every tool result should be manually verified before reporting.

Tool accuracy verification includes: confirming tool version is current, verifying tool configuration is appropriate, testing tool results against known baselines, and manually validating findings that seem unusual.

### Version and Environment Dependency

Many vulnerabilities are version-specific: fixed in newer versions, present only in specific configurations, or dependent on environmental factors. Documenting version and environment details ensures the triager can reproduce the finding and prevents submissions of already-fixed vulnerabilities.

Version verification includes: confirming the vulnerability is present in the current version, documenting the exact version and build, noting any relevant configuration details, and testing against the latest available version.

### Evidence Authenticity

Evidence authenticity requires that attachments accurately represent the vulnerability: screenshots are from the actual exploitation, HAR files contain the actual requests and responses, and videos show the actual behavior. Fabricated, edited, or misleading evidence is a serious ethical violation.

Evidence authenticity verification includes: confirming timestamps are consistent, verifying URLs match the target domain, validating response codes and content match the described behavior, and ensuring no evidence is from testing against different targets.

### Impact Verification

Impact verification confirms that the claimed impact actually results from the vulnerability. If you claim "full database access," verify the evidence demonstrates full database access. If you claim "affects all users," verify the testing supports this claim. Impact overstatement undermines credibility.

Impact verification includes: quantifying affected resources, demonstrating actual data access, confirming the scope of impact, and distinguishing theoretical from demonstrated impact.

### Technical Consistency

Technical consistency requires that all technical claims in the report are mutually consistent: the vulnerability description matches the reproduction steps, the evidence matches the steps, the impact matches the evidence, and the severity matches the impact. Inconsistencies indicate either errors or incomplete understanding.

Technical consistency verification includes: cross-referencing all sections for agreement, verifying the narrative is coherent, ensuring no contradictions exist, and confirming the logical flow from vulnerability through impact.

### Error Detection Methodology

Systematic error detection uses multiple complementary approaches: independent reproduction (testing from scratch), peer verification (having someone else test), tool cross-checking (using multiple tools), and manual validation (hand-testing each step). Each approach catches different error types.

Error detection is most effective when applied before submission. The investment in verification before submission saves far more time than post-subjection error correction.

### The Verification Checklist

A verification checklist standardizes the verification process, ensuring consistency and completeness. The checklist should cover: vulnerability existence, reproduction accuracy, evidence authenticity, impact verification, technical consistency, version documentation, and tool validation.

The checklist should be specific and actionable: "verify screenshot shows URL bar" rather than "check evidence." Specificity ensures the checklist actually validates accuracy rather than providing false assurance.

### Continuous Verification Improvement

Verification processes must evolve based on: rejection patterns, error analysis, tool updates, and vulnerability landscape changes. Continuous improvement ensures verification keeps pace with changing requirements.

Continuous improvement requires: regular verification process review, error pattern analysis, tool proficiency development, and methodology refinement.

## Prerequisites

### Technical Skills
1. Vulnerability reproduction techniques
2. Security tool proficiency
3. Network protocol understanding
4. Application architecture knowledge
5. Version control awareness

### Verification Methodology
1. Independent testing techniques
2. Evidence validation methods
3. Impact quantification skills
4. Tool accuracy assessment
5. Error detection patterns

### Documentation Skills
1. Technical documentation standards
2. Evidence organization
3. Version documentation
4. Configuration recording
5. Reproducibility requirements

### Quality Assurance
1. Verification checklist design
2. Peer review coordination
3. Error pattern recognition
4. Continuous improvement processes
5. Quality metrics tracking

## Methodology

### Phase 1: Pre-Verification Preparation

**Step 1: Vulnerability Documentation Review**
Before verifying, review your own documentation: vulnerability description, reproduction steps, evidence claims, and impact assessment. Identify all technical claims that require verification.

**Step 2: Verification Checklist Selection**
Select the appropriate verification checklist for your vulnerability class. Different classes require different verification focuses: race conditions need timing verification, SSRF needs internal access verification, XSS needs execution verification.

**Step 3: Verification Environment Setup**
Prepare a clean verification environment: fresh browser session, clean network capture, proper tool configuration, and appropriate test accounts. A clean environment prevents contamination from previous testing.

### Phase 2: Vulnerability Existence Verification

**Step 4: Independent Reproduction**
Reproduce the vulnerability independently from your original testing. Follow your own reproduction steps exactly as written. If the steps work, they are accurate. If they fail, the steps need revision.

**Step 5: Edge Case Testing**
Test edge cases and boundary conditions: minimum and maximum inputs, special characters, empty values, and unusual configurations. Edge case testing reveals whether the vulnerability is robust or fragile.

**Step 6: Environmental Dependency Testing**
Test the vulnerability across different environments: browsers, operating systems, network conditions, and configurations. Document any environmental dependencies.

**Step 7: Version Verification**
Verify the vulnerability is present in the current version of the application. Test against the latest available version to ensure the vulnerability has not been patched.

### Phase 3: Reproduction Accuracy Verification

**Step 8: Step-by-Step Execution**
Execute each reproduction step precisely as written. Time each step. Note any ambiguities or assumptions. Any step that requires interpretation needs clarification.

**Step 9: Timing and Sequence Verification**
Verify the timing and sequence of steps: are steps dependent on each other? Does sequence matter? Are there timing dependencies? Document any timing requirements.

**Step 10: Input Validation**
Verify all inputs in reproduction steps: correct URLs, correct parameters, correct values, and correct encoding. Input errors are common reproduction failures.

**Step 11: Expected Result Verification**
Verify that each step produces the expected result as described. If the actual result differs from the described result, update the description or investigate the discrepancy.

### Phase 4: Evidence Authenticity Verification

**Step 12: Screenshot Verification**
Verify all screenshots: URL bar is visible and shows correct domain, timestamps are consistent, content matches the described state, and annotations are accurate. Screenshots must faithfully represent the actual exploitation.

**Step 13: HAR File Verification**
Verify all HAR files: contain the described requests and responses, timestamps are consistent, URLs match the target domain, headers are accurate, and sensitive data is properly redacted. HAR files must contain actual traffic, not fabricated data.

**Step 14: Video Verification**
Verify all videos: show the actual exploitation in real-time, timestamps are accurate, content matches the described steps, and quality is sufficient for validation. Videos must demonstrate the actual behavior, not staged demonstrations.

**Step 15: Evidence Sequence Verification**
Verify the evidence sequence matches the reproduction steps: each step has corresponding evidence, evidence order matches step order, and evidence references are accurate. The evidence narrative must match the written narrative.

### Phase 5: Impact Verification

**Step 16: Impact Scope Verification**
Verify the impact scope: confirm the number of affected users, the data accessible, the actions possible, and the systems affected. Impact scope must be supported by evidence, not assumption.

**Step 17: Data Access Verification**
Verify actual data access: demonstrate the data that can be accessed, confirm the data is sensitive, and verify the data belongs to the target application. Data access claims must be demonstrable.

**Step 18: Action Capability Verification**
Verify claimed action capabilities: demonstrate the actions that can be performed, confirm the actions are unauthorized, and verify the actions affect the target application. Action capability claims must be demonstrable.

**Step 19: Business Impact Verification**
Verify business impact claims: quantify the impact, reference relevant regulations or standards, and demonstrate the business consequences. Business impact must be realistic and supportable.

### Phase 6: Technical Consistency Verification

**Step 20: Cross-Section Consistency Check**
Verify consistency across all report sections: vulnerability description matches reproduction steps, evidence matches steps, impact matches evidence, and severity matches impact. Inconsistencies indicate errors.

**Step 21: Narrative Coherence Check**
Verify the report narrative is coherent: logical flow from vulnerability through impact, no contradictions, and clear cause-and-effect relationships. Coherent narratives are more convincing and easier to validate.

**Step 22: Technical Terminology Consistency**
Verify technical terminology is used consistently: same terms for same concepts, no conflicting terminology, and accurate technical language. Inconsistent terminology confuses readers.

**Step 23: CVSS Calculation Verification**
Verify the CVSS calculation: metric selections are justified, the calculation is accurate, and the resulting score aligns with the severity rating. CVSS errors undermine severity justifications.

### Phase 7: Tool Validation

**Step 24: Tool Version Verification**
Verify all tools used: current versions, appropriate configurations, and known limitations. Outdated tools may produce inaccurate results.

**Step 25: Tool Result Verification**
Verify tool results against manual testing: confirm tool findings are genuine, not false positives. Manual verification is essential for all tool-dependent findings.

**Step 26: Tool Configuration Documentation**
Document all tool configurations: settings, parameters, and versions used. This documentation enables triager replication and demonstrates thorough testing.

**Step 27: Cross-Tool Validation**
Validate findings using multiple tools: if one tool identifies a vulnerability, confirm with a different tool or manual testing. Cross-tool validation reduces false positive risk.

### Phase 8: Final Verification

**Step 28: Complete Report Verification**
Perform a complete verification of the entire report: all claims verified, all evidence authenticated, all calculations checked, and all documentation complete. Final verification catches remaining errors.

**Step 29: Peer Verification**
If possible, have a peer independently verify the vulnerability. Peer verification provides independent confirmation and catches errors you may have missed.

**Step 30: Verification Documentation**
Document the verification process: what was verified, how it was verified, and the results. This documentation demonstrates thoroughness and provides a reference for future similar findings.

## Tool Arsenal

### Reproduction Tools
1. **Burp Suite** - Request manipulation and replay
2. **Browser developer tools** - Client-side testing
3. **cURL** - Command-line HTTP testing
4. **Postman** - API testing and validation
5. **OWASP ZAP** - Automated vulnerability testing

### Evidence Capture Tools
6. **Screen recording software** - Video evidence capture
7. **Screenshot tools** - Visual evidence capture
8. **HAR capture tools** - Network traffic recording
9. **Terminal recording** - Command-line evidence
10. **Browser extensions** - Specialized capture tools

### Version Testing Tools
11. **Browser version managers** - Multiple browser testing
12. **Virtual machines** - Environment isolation
13. **Docker containers** - Consistent test environments
14. **Version control systems** - Code version tracking
15. **Build tools** - Application version testing

### Tool Validation Tools
16. **Multiple vulnerability scanners** - Cross-tool validation
17. **Manual testing frameworks** - Hand-testing verification
18. **Tool configuration validators** - Setup verification
19. **Result comparison tools** - Multi-tool analysis
20. **Tool version checkers** - Currency verification

### Evidence Verification Tools
21. **Image analysis tools** - Screenshot authenticity
22. **HAR validators** - Network capture verification
23. **Video analysis tools** - Recording verification
24. **Timestamp validators** - Time consistency checking
25. **URL validators** - Domain verification

### Impact Verification Tools
26. **Data quantification tools** - Impact measurement
27. **Regulatory reference databases** - Compliance impact
28. **Business impact calculators** - Financial impact estimation
29. **Scope analysis tools** - Affected resource counting
30. **Risk assessment frameworks** - Impact classification

### Quality Assurance Tools
31. **Verification checklists** - Standardized validation
32. **Peer review platforms** - Independent verification
33. **Error tracking systems** - Issue documentation
34. **Quality metrics dashboards** - Verification performance
35. **Process documentation tools** - Verification procedures

### Documentation Tools
36. **Technical documentation templates** - Verification records
37. **Version control systems** - Verification history
38. **Knowledge bases** - Verification methodology
39. **Training materials** - Verification skill development
40. **Reference libraries** - Technical standards

## Case Studies

### Case Study 1: False Positive Elimination

**Context:** A researcher submitted a report claiming SQL injection based on error messages. The triager could not reproduce the finding.

**Analysis:** The error messages were actually application-level errors, not database errors. The researcher had assumed SQL injection based on error message patterns without verifying the underlying behavior.

**Verification Improvement:** The researcher implemented a verification protocol: confirm database error characteristics, test with time-based techniques, verify data extraction capability, and cross-validate with multiple tools.

**Outcome:** Subsequent SQL injection reports included verification evidence: database fingerprinting, time-based confirmation, and data extraction proof. False positive submissions dropped to zero.

### Case Study 2: Version Dependency Discovery

**Context:** A researcher found an authentication bypass but did not document the version. The triager tested on a newer version where the vulnerability was fixed.

**Analysis:** The vulnerability existed in version 2.3.1 but was patched in version 2.3.2. The researcher's testing environment had not been updated, but the triager's environment had.

**Verification Improvement:** The researcher implemented version verification: document exact version and build, test against latest available version, note any version dependencies, and include version information in the report.

**Outcome:** Version documentation prevented future cannot-reproduce rejections for version-dependent vulnerabilities.

### Case Study 3: Evidence Authenticity Validation

**Context:** A triager suspected a screenshot was from a different application. The screenshot showed a vulnerability but the URL bar was partially obscured.

**Analysis:** The researcher had cropped the screenshot to focus on the vulnerability, inadvertently removing URL context. The triager could not verify the screenshot was from the target application.

**Verification Improvement:** The researcher implemented evidence authenticity requirements: full URL bar visible in all screenshots, consistent timestamps across evidence, domain verification in all captures, and no cropping that removes context.

**Outcome:** Evidence authenticity verification eliminated credibility questions and accelerated triage.

### Case Study 4: Impact Overstatement Correction

**Context:** A researcher claimed "full database access" but the evidence only demonstrated access to a single table. The triager downgraded the severity.

**Analysis:** The researcher had extrapolated from single-table access to full database access without evidence. The extrapolation was reasonable but not demonstrated.

**Verification Improvement:** The researcher implemented impact verification: demonstrate actual data access, quantify affected resources, distinguish demonstrated from theoretical impact, and support all impact claims with evidence.

**Outcome:** Impact claims became supportable and severity assessments aligned with demonstrated impact rather than theoretical possibilities.

### Case Study 5: Race Condition Verification

**Context:** A researcher reported a race condition that only worked intermittently. The triager could not reproduce it consistently.

**Analysis:** The race condition had a narrow timing window (10-50ms) and was sensitive to network conditions. The researcher's testing environment had different latency than the triager's.

**Verification Improvement:** The researcher implemented race condition verification: test across multiple network conditions, document timing window precisely, provide Burp Suite configuration for reproduction, and include real-time video evidence.

**Outcome:** Race condition reports included environmental documentation and reproduction guidance. Cannot-reproduce rates for race conditions dropped significantly.

### Case Study 6: Tool False Positive Discovery

**Context:** A scanner reported XSS vulnerabilities in multiple parameters. The researcher submitted reports without manual verification. The triager found the parameters were not actually vulnerable.

**Analysis:** The scanner was flagging reflected input as potential XSS without confirming execution. The researcher trusted the scanner results without manual validation.

**Verification Improvement:** The researcher implemented tool verification: manually test all scanner findings, verify XSS execution (not just reflection), test in multiple browsers, and confirm session impact.

**Outcome:** Tool-dependent false positives were eliminated through manual verification. All subsequent XSS reports included execution verification.

### Case Study 7: Technical Consistency Fix

**Context:** A report described an IDOR vulnerability affecting "all user profiles" but the reproduction steps only demonstrated access to one profile. The inconsistency confused the triager.

**Analysis:** The researcher had tested multiple profiles but only documented one in the reproduction steps. The impact claim was broader than the demonstrated evidence.

**Verification Improvement:** The researcher implemented consistency verification: ensure impact claims match demonstrated evidence, document all tested cases (or note the testing methodology), and cross-reference all sections for agreement.

**Outcome:** Technical consistency improved across all reports. Triagers could follow the logic from evidence through impact without confusion.

### Case Study 8: CVSS Calculation Verification

**Context:** A researcher calculated CVSS 9.8 (Critical) for a vulnerability that the triager assessed as CVSS 6.5 (Medium). The researcher's metric selections were incorrect.

**Analysis:** The researcher incorrectly selected Attack Complexity=Low when it should have been High (requiring specific conditions). The incorrect metric inflated the score significantly.

**Verification Improvement:** The researcher implemented CVSS verification: review each metric against CVSS documentation, compare with similar accepted findings, and have peers verify calculations.

**Outcome:** CVSS calculations aligned with triage assessments within 1 point. Severity justifications became more credible.

### Case Study 9: Environmental Dependency Documentation

**Context:** A vulnerability only worked with a specific browser extension installed. The triager did not have the extension and could not reproduce.

**Analysis:** The researcher's testing environment included a browser extension that modified request behavior. The vulnerability was dependent on this modification but the dependency was not documented.

**Verification Improvement:** The researcher implemented environmental documentation: list all relevant environmental factors, test without environmental modifications when possible, and clearly document any dependencies.

**Outcome:** Environmental dependencies were documented in all reports. Triagers could set up appropriate testing environments.

### Case Study 10: Peer Verification Success

**Context:** A researcher found a complex business logic vulnerability. They were confident in the finding but uncertain about the reproduction steps.

**Analysis:** The vulnerability involved a multi-step attack chain that was difficult to document clearly. The researcher's initial reproduction steps were ambiguous.

**Verification Improvement:** The researcher engaged a peer for verification. The peer followed the steps, identified ambiguities, and helped refine the reproduction documentation.

**Outcome:** Peer verification identified and corrected reproduction issues before submission. The report was accepted without follow-up questions.

## Advanced Techniques

### Automated Verification Workflows

Develop automated verification workflows: scripts that verify tool configurations, check evidence authenticity, validate CVSS calculations, and confirm version information. Automation reduces manual verification effort while maintaining consistency.

### Cross-Validation Methodology

Implement cross-validation for all findings: verify with multiple tools, test across environments, and validate with manual techniques. Cross-validation reduces false positive risk and increases report credibility.

### Verification Metrics

Track verification metrics: verification time per vulnerability class, error detection rate, false positive rate, and verification-related rejection rate. Metrics guide verification process improvement.

### Risk-Based Verification

Apply verification effort proportional to risk: complex vulnerabilities receive more verification, simple vulnerabilities receive standard verification, and tool-dependent findings receive extra verification. Risk-based allocation optimizes verification investment.

### Verification Template Development

Create verification templates for each vulnerability class: specific verification steps, evidence requirements, and quality criteria. Templates standardize verification across reports.

### Continuous Verification Improvement

Implement continuous verification improvement: analyze verification failures, update verification processes, and incorporate new verification techniques. Continuous improvement maintains verification effectiveness.

## Detection

### Verification Completeness Indicators
1. All reproduction steps independently verified
2. All evidence authenticated
3. All impact claims supported
4. All calculations verified
5. All technical claims consistent

### Verification Failure Indicators
1. Reproduction steps fail independently
2. Evidence does not match description
3. Impact claims exceed demonstrated impact
4. CVSS calculations are inaccurate
5. Technical sections contradict each other

### Self-Assessment Questions
1. Can I reproduce this finding from my own steps?
2. Does every claim have supporting evidence?
3. Is the impact accurately quantified?
4. Are all calculations correct?
5. Is the report technically consistent?

## Impact

### Rejection Prevention
Thorough verification prevents rejections due to: non-reproducible findings, inaccurate evidence, inflated impact, and technical errors.

### Credibility Building
Verified reports build researcher credibility. Programs trust researchers who submit accurate, reproducible findings.

### Triage Acceleration
Verified reports require less triager validation, reducing time to resolution and payment.

### Relationship Strengthening
Accurate reports strengthen researcher-program relationships. Trust built through accuracy benefits future interactions.

## Pitfalls

### Pitfall 1: Trusting Tool Results
Never trust tool results without manual verification. Tools produce false positives and version-specific errors.

### Pitfall 2: Skipping Edge Cases
Skipping edge case testing misses vulnerabilities that only work under specific conditions.

### Pitfall 3: Insufficient Documentation
Failing to document version, environment, and configuration details causes cannot-reproduce rejections.

### Pitfall 4: Impact Overstatement
Claiming impact beyond what evidence demonstrates undermines credibility.

### Pitfall 5: Evidence Fabrication
Fabricating or editing evidence is an ethical violation that results in permanent account suspension.

### Pitfall 6: Inconsistent Reporting
Inconsistent technical claims across report sections confuse triagers.

### Pitfall 7: Ignoring Version Changes
Not testing against the latest version risks submitting already-fixed vulnerabilities.

### Pitfall 8: Verification Fatigue
Reducing verification effort when busy or tired leads to errors.

### Pitfall 9: Solo Verification
Verifying without peer review misses errors that external perspective would catch.

### Pitfall 10: Stagnant Verification
Not updating verification processes based on new learnings leads to outdated practices.

## Integration

### With Report Writing
Technical verification should be integrated into the writing process. Verify claims as you write, not as an afterthought.

### With Evidence Management
Evidence verification is part of technical accuracy. Every attachment must be authenticated.

### With Severity Assessment
Severity assessment must be verified: CVSS calculations, metric selections, and bounty alignment.

### With Quality Assurance
Technical verification is a core QA component. QA checklists should include verification requirements.

### With Peer Review
Peer verification is the most effective verification tool. Establish peer review relationships for technical validation.

## Reporting

### Verification Metrics to Track
- Verification time per report
- Error detection rate
- False positive rate
- Verification-related rejection rate
- Peer verification completion rate

### Documentation Standards
Maintain verification documentation: checklist completion, verification results, and error corrections. This documentation supports quality improvement.

### Continuous Improvement
Review verification metrics monthly. Update verification processes based on outcomes. Maintain verification effectiveness over time.

## Labs

### Lab 1: Independent Reproduction Practice
Take your last 5 reports and reproduce each independently from scratch. Document any reproduction failures and update the reports.

### Lab 2: Evidence Authenticity Audit
Audit your last 10 reports' evidence for authenticity. Verify: URL visibility, timestamp consistency, domain verification, and content accuracy.

### Lab 3: Impact Verification Exercise
Review 5 reports and verify all impact claims against evidence. Identify any overstatements and correct them.

### Lab 4: CVSS Calculation Verification
Recalculate CVSS for 10 previous findings. Compare with original calculations. Identify and correct any errors.

### Lab 5: Peer Verification Setup
Establish peer verification relationships with 2-3 researchers. Verify 3 findings for each partner.

### Lab 6: Tool Validation Protocol
Develop a tool validation protocol for your most-used tools. Test it on 5 findings.

### Lab 7: Environmental Documentation
Develop an environmental documentation template. Apply it to 5 findings with environmental dependencies.

### Lab 8: Verification Metrics Dashboard
Create a verification metrics dashboard. Track verification time, error detection, and rejection rates.

## Ethics

### Honest Verification
Verification must be honest. Do not ignore verification failures or rationalize inaccurate findings.

### Evidence Integrity
Maintain evidence integrity. Never fabricate, edit, or misrepresent evidence.

### Impact Accuracy
Report impact accurately. Do not overstate impact for higher bounties.

### Tool Transparency
Be transparent about tools used and their limitations. Tool-dependent findings should note this dependency.

### Community Responsibility
Contribute to verification best practices. Accurate reporting benefits the entire bug bounty community.

## Cheat Sheet

### Verification Checklist
- [ ] Vulnerability independently reproduced
- [ ] All edge cases tested
- [ ] Version verified as current
- [ ] Environment documented
- [ ] All screenshots authenticated
- [ ] HAR files verified
- [ ] Impact claims supported
- [ ] CVSS calculation verified
- [ ] Technical sections consistent
- [ ] Peer verification completed

### Quick Verification Rules
1. Never trust tool results without manual verification
2. Always document version and environment
3. Verify impact claims match demonstrated evidence
4. Cross-validate with multiple tools
5. Have peers verify complex findings
6. Test against latest available version
7. Document all environmental dependencies
8. Verify evidence authenticity
9. Check technical consistency across sections
10. Document the verification process

### Common Verification Errors
| Error | Prevention |
|-------|------------|
| False positive submission | Manual verification of all tool findings |
| Version mismatch | Document and verify version |
| Impact overstatement | Support all claims with evidence |
| Inconsistent reporting | Cross-reference all sections |
| Missing environment docs | Document all dependencies |

### Verification Priority Matrix
| Vulnerability Class | Verification Focus |
|--------------------|--------------------|
| Race condition | Timing, environment |
| XSS | Execution, browser compat |
| SSRF | Internal access, data exfil |
| SQLi | Database fingerprint, extraction |
| Auth bypass | Privilege level, scope |
| IDOR | Resource access, authorization |
