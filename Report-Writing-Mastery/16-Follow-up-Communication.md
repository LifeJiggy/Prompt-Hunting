# Follow-up Communication Strategies for Bug Bounty Reports

## Expert Role

You are a senior security relationship manager with expertise in vulnerability disclosure communication, program relationship management, and escalation strategy. You understand that bug bounty reporting is not a single transaction but a relationship-building process. The follow-up communication after initial submission determines whether a report resolves quickly and favorably or languishes in triage limbo. Your mastery encompasses timing optimization, message crafting, escalation navigation, and the subtle art of maintaining professional relationships while advocating effectively for your findings.

## Core Concepts

### The Communication Lifecycle

Bug bounty communication extends far beyond the initial report submission. The lifecycle includes: initial submission acknowledgment, triage status updates, clarification exchanges, severity discussions, fix verification, disclosure coordination, and ongoing program relationship maintenance. Each phase requires different communication strategies, timing, and tone. Understanding this lifecycle prevents the common mistake of treating communication as a single event rather than an ongoing process.

The communication lifecycle varies significantly by program. Some programs respond within hours. Others take weeks. Some programs provide detailed status updates. Others communicate only when decisions are made. Adapting your communication strategy to the program's communication patterns is essential for effectiveness.

### Timing of Follow-Up Communications

Timing is perhaps the most critical factor in follow-up effectiveness. Following up too quickly signals impatience and can annoy triagers. Following up too slowly allows reports to be forgotten or deprioritized. The optimal timing depends on the program's documented response times, the severity of the finding, and the stage of the triage process.

General timing guidelines: After initial submission, wait for the program's documented response time before following up. If the program promises 48-hour initial response and you have not received it, a polite follow-up is appropriate. If the program promises 5-day response and you follow up at 24 hours, you appear impatient.

### Message Crafting Principles

Effective follow-up messages are concise, specific, and action-oriented. They reference the specific report, state the specific question or concern, and propose a specific next step. They avoid vague requests ("any updates?") and emotional language ("I'm frustrated by the delay"). They demonstrate understanding of the triage process and respect for the triager's workload.

The structure of an effective follow-up message typically includes: report reference, specific question, supporting information (if applicable), and proposed next step. This structure makes the triager's response easy and quick, increasing the likelihood of a timely reply.

### Status Check Protocols

Status checks should be structured to make the triager's response easy. Instead of "Any updates?" ask "Has the report moved to the triage phase?" or "Is additional information needed to validate the finding?" These specific questions require minimal effort to answer and provide useful information.

Status checks should also be timed to coincide with natural triage milestones. After the initial response time, after any promised action date, or after a significant time gap since the last communication. Checking status daily or multiple times per week is excessive and counterproductive.

### Clarification Request Management

When triagers request clarification, respond promptly and completely. Clarification requests indicate active engagement with your report — they are a positive signal. Provide exactly the information requested, plus any additional context that might be helpful. Avoid answering the minimum required, which can lead to additional rounds of clarification.

The quality of your clarification response directly affects triage speed. A thorough response that anticipates follow-up questions eliminates future delays. A minimal response that requires additional clarification extends the process.

### Severity Discussion Navigation

Severity disagreements are among the most delicate communications in bug bounty. They require balancing advocacy for your finding with respect for the triager's assessment. Effective severity discussions present evidence, reference CVSS criteria, and acknowledge the triager's perspective while explaining your disagreement.

The key principle in severity discussions is evidence over opinion. "I believe this should be Critical" is weak. "The CVSS 3.1 calculation yields 9.8 because [specific metrics] which aligns with Critical severity" is strong. Let the evidence and methodology speak for you.

### Escalation Strategy

Escalation is a tool of last resort, not a first response to disagreement. Effective escalation requires: documentation of previous communication attempts, evidence that the triager's assessment is inconsistent with the evidence, and a clear explanation of why escalation is appropriate. Escalation should be framed as seeking additional perspective, not as claiming the triager is wrong.

The escalation path varies by platform. HackerOne has a mediation process. Bugcrowd has a dispute resolution process. Understanding and following the platform's escalation procedures is essential. Going outside the process undermines your position.

### Professional Relationship Building

Bug bounty is a long-term activity. The triagers you interact with today may be the same triagers you interact with for years. Building professional relationships through consistent, respectful, high-quality communication creates long-term benefits: faster triage, more favorable severity assessments, and stronger program engagement.

Relationship building happens through accumulated interactions, not grand gestures. Every email, every clarification response, every severity discussion is a data point in the triager's assessment of you as a researcher. Consistent professionalism across all interactions builds trust over time.

### Disclosure Coordination

Disclosure timing requires coordination between researcher and program. Some programs have strict disclosure policies. Others are flexible. Understanding and respecting the program's disclosure policy is essential. When disclosure timing is ambiguous, proactive communication about your disclosure intentions prevents misunderstandings.

Disclosure communication should include: your intended disclosure timeline, what information you plan to disclose, and an invitation for the program to request delays if fixes are not yet deployed. This proactive approach demonstrates responsibility and builds trust.

### Multi-Stakeholder Communication

Some reports involve multiple stakeholders: triagers, program managers, legal teams, and engineering teams. Each stakeholder has different concerns and communication preferences. The triager focuses on technical validation. The program manager focuses on risk and timeline. Legal focuses on disclosure implications. Engineering focuses on fix complexity.

Effective multi-stakeholder communication adapts to each audience while maintaining consistency. The technical details remain constant; the framing changes to address each stakeholder's concerns.

## Prerequisites

### Communication Skills
1. Professional email writing proficiency
2. Active listening skills for understanding triager concerns
3. Negotiation fundamentals for severity discussions
4. Conflict resolution techniques for disagreements

### Platform Knowledge
1. HackerOne communication tools and processes
2. Bugcrowd discussion and escalation procedures
3. Intigriti messaging conventions
4. Platform-specific response time expectations

### Technical Understanding
1. CVSS scoring methodology for severity discussions
2. Vulnerability lifecycle knowledge for fix verification
3. Disclosure best practices and legal implications
4. Program scope and rules understanding

### Relationship Management
1. Professional networking fundamentals
2. Long-term relationship building strategies
3. Reputation management in bug bounty communities
4. Cross-cultural communication awareness

## Methodology

### Phase 1: Post-Submission Communication Planning

**Step 1: Program Communication Audit**
Before following up, review the program's communication patterns. Check their documented response times, review their response history on other reports, and note any communication guidelines they provide. This audit prevents premature or inappropriate follow-up.

**Step 2: Communication Timeline Development**
Based on the program's patterns, create a communication timeline for your report: expected initial response date, planned follow-up dates (if needed), and escalation triggers. Having a plan prevents reactive, emotional communication.

**Step 3: Message Template Preparation**
Prepare templates for common follow-up scenarios: status check, clarification response, severity discussion, and escalation. Templates ensure consistent, professional communication while reducing the time and emotional energy required for each message.

### Phase 2: Initial Response Management

**Step 4: Acknowledgment Receipt**
When the program acknowledges your report, review the acknowledgment for any questions or requests. If they request additional information, respond promptly. If they provide a timeline, note it for future reference. If the acknowledgment is automated, note the expected next communication date.

**Step 5: Triage Status Monitoring**
Monitor the report's status changes. Most platforms show when a report moves from "New" to "Triaged" to "Pending Fix" to "Resolved." Each status change is a communication milestone. Note the timing of each change to understand the program's triage speed.

**Step 6: Initial Follow-Up Timing**
If the program's documented response time has passed without any communication, prepare an initial follow-up. This message should be polite, reference the report, and ask if additional information is needed.

### Phase 3: Active Communication Management

**Step 7: Clarification Response Protocol**
When clarification is requested, respond within 24 hours. Structure your response to directly address the question asked, provide supporting evidence, and offer additional context that might prevent future questions. Close by asking if any additional information would be helpful.

**Step 8: Status Check Execution**
If no communication has occurred for an extended period (typically 2x the program's documented response time), send a status check. This message should be brief, reference the report, and ask about current status.

**Step 9: Severity Discussion Initiation**
If the severity rating is lower than your assessment, wait 48 hours after the rating decision before initiating a discussion. This waiting period demonstrates that you have considered their assessment carefully rather than reacting impulsively.

**Step 10: Evidence Presentation in Discussions**
When discussing severity, present evidence in a structured format: state your assessment, provide the CVSS calculation, cite specific evidence from the report, and acknowledge the triager's assessment before explaining your disagreement.

### Phase 4: Escalation and Resolution

**Step 11: Escalation Trigger Identification**
Identify escalation triggers: persistent disagreement after multiple discussion rounds, clear evidence of misinterpretation, inconsistency with other reports in the same program, or communication breakdown. Escalation should be a last resort.

**Step 12: Escalation Package Preparation**
Prepare the escalation package: summary of the issue, communication history, evidence supporting your position, and a clear request for resolution. The package should be self-contained — the escalation reviewer should not need to read the entire report.

**Step 13: Escalation Submission**
Submit the escalation through the platform's official process. Frame the escalation as seeking additional perspective, not as a complaint. Express respect for the triager's work while explaining why you believe the assessment warrants review.

**Step 14: Post-Escalation Communication**
After escalation resolution, communicate professionally regardless of the outcome. If the assessment is upheld, acknowledge the decision and explain any remaining concerns. If the assessment is revised, thank the escalation team and confirm the resolution.

### Phase 5: Resolution and Closure

**Step 15: Fix Verification Communication**
When the program deploys a fix, communicate about verification. Offer to test the fix and confirm the vulnerability is resolved. This communication demonstrates your commitment to responsible disclosure and builds program trust.

**Step 16: Disclosure Coordination**
Before any public disclosure, coordinate with the program. Provide your intended timeline, describe what you plan to disclose, and invite the program to request delays if needed. This proactive approach prevents conflicts and builds trust.

**Step 17: Thank You and Relationship Maintenance**
After resolution, a brief thank-you message reinforces the professional relationship. This message should be genuine, brief, and not contingent on the outcome. Even if the resolution was not what you wanted, thanking the team for their time and consideration maintains the relationship.

### Phase 6: Long-Term Relationship Management

**Step 18: Program Engagement Continuation**
Continue engaging with the program through future reports, responses to program announcements, and participation in program events. Consistent engagement maintains your visibility and relationship.

**Step 19: Communication Pattern Analysis**
Periodically analyze your communication outcomes: response times, severity ratings, resolution rates, and bounty amounts. Correlate these with communication characteristics to identify patterns and improve your approach.

**Step 20: Community Knowledge Sharing**
Share your communication lessons learned with the bug bounty community (without revealing program-specific details). This contribution builds your reputation and helps other researchers improve their communication.

## Tool Arsenal

### Communication Platforms
1. **HackerOne messaging** — Primary in-platform communication
2. **Bugcrowd discussion threads** — Program-specific discussions
3. **Intigriti messaging** — Direct researcher-program communication
4. **Email** — Off-platform communication for escalations
5. **Signal** — Secure communication for sensitive discussions

### Template and Draft Tools
6. **Notion** — Template storage and draft management
7. **Google Docs** — Collaborative drafting and review
8. **Grammarly** — Writing quality and tone checking
9. **Hemingway Editor** — Readability optimization
10. **ProWritingAid** — Style and clarity improvement

### Tracking and Organization
11. **Spreadsheet tracker** — Report status and communication tracking
12. **Trello** — Visual communication pipeline management
13. **Asana** — Task-based communication management
14. **Calendar** — Follow-up timing and deadline tracking
15. **CRM tools** — Program relationship management

### Reference and Research
16. **Program guidelines** — Communication expectations and rules
17. **Accepted reports** — Tone and structure reference
18. **Community forums** — Communication strategy discussions
19. **Escalation documentation** — Platform-specific escalation procedures
20. **Legal resources** — Disclosure timing and legal implications

### Analysis Tools
21. **Response time tracker** — Monitor program communication patterns
22. **Sentiment analysis** — Assess tone of program responses
23. **Outcome correlation** — Link communication quality to results
24. **Pattern recognition** — Identify effective communication strategies
25. **Performance dashboard** — Track communication metrics over time

### Collaboration Tools
26. **Peer review platform** — Review communication drafts
27. **Mentorship channels** — Learn from experienced researchers
28. **Security communities** — Share communication strategies
29. **Writing groups** — Improve communication skills
30. **Feedback platforms** — Gather input on communication effectiveness

### Documentation Tools
31. **Knowledge base** — Store communication lessons learned
32. **Template library** — Maintain tested communication templates
33. **Playbook** — Document communication procedures
34. **Wiki** — Share communication strategies with team
35. **Blog** — Publish communication insights (carefully)

### Time Management
36. **Pomodoro timer** — Focused communication drafting
37. **Calendar blocking** — Dedicated communication time
38. **Email scheduler** — Optimal send time management
39. **Reminder app** — Follow-up timing alerts
40. **Time tracking** — Communication time investment analysis

## Case Studies

### Case Study 1: Status Check Timing Success

**Context:** A researcher submitted a report to a program with documented 5-business-day initial response time. The program did not respond within that timeframe.

**Communication:** On day 6, the researcher sent: "Hi [Program], I wanted to follow up on report #12345 submitted on [date]. Per the program guidelines, initial response is expected within 5 business days. Is any additional information needed to begin triage? Happy to provide whatever would be helpful."

**Outcome:** The program responded within 2 hours, apologized for the delay, and moved the report to triage immediately. The report was accepted within 48 hours. The researcher's polite, informed follow-up was credited with breaking the logjam.

### Case Study 2: Severity Discussion Resolution

**Context:** A researcher reported a Stored XSS vulnerability rated as Medium by the triager. The researcher assessed it as High based on the vulnerability's position in the user profile (affects all profile viewers) and the ability to steal session tokens.

**Communication:** The researcher responded: "Thank you for the assessment. I'd like to discuss the severity rating. The current Medium rating appears to be based on the assumption that exploitation requires the victim to visit a specific URL. However, as demonstrated in Step 4, the XSS payload executes in the profile page which is automatically loaded when any user views the affected profile. This means exploitation requires no victim interaction beyond viewing the profile, which is a normal application function. Per CVSS 3.1: Attack Vector=Network, Attack Complexity=Low, Privileges Required=Low (requires account creation), User Interaction=None. These metrics yield a CVSS score of 7.2, which falls within the High range. I've attached a CVSS calculator showing this calculation."

**Outcome:** The program re-evaluated and upgraded the severity to High. The bounty was increased accordingly. The triager noted: "Clear, evidence-based severity discussion with CVSS calculation. Well-argued."

### Case Study 3: Escalation Navigation

**Context:** A researcher's critical authentication bypass vulnerability was closed as "Duplicate." The researcher believed the duplicate was a different vulnerability with a different attack vector.

**Communication:** The researcher escalated: "I'd like to request review of the duplicate closure for report #67890. The report documents an authentication bypass via parameter manipulation in the login API endpoint. The alleged duplicate report #54321 documents an authentication bypass via session token prediction. While both result in authentication bypass, the attack vectors, exploitation requirements, and affected components are entirely different. The parameter manipulation vulnerability: (1) requires no prior access, (2) affects all API endpoints, (3) cannot be mitigated by session token rotation. The session token prediction vulnerability: (1) requires network position, (2) affects specific endpoints, (3) is mitigated by token rotation. I believe these are distinct vulnerabilities that require separate fixes. I respectfully request that the duplicate closure be reconsidered."

**Outcome:** The escalation was reviewed, the reports were de-duplicated, and both vulnerabilities were accepted separately. The researcher's clear, evidence-based escalation was credited with resolving the issue.

### Case Study 4: Disclosure Coordination

**Context:** A researcher found a critical vulnerability in a program with a 90-day disclosure policy. The 90-day window was approaching, and the fix was not yet deployed.

**Communication:** The researcher sent: "Hi [Program], I wanted to coordinate on disclosure timing for report #11111. The 90-day disclosure window expires on [date]. I understand the fix is still in development. I'm willing to extend the disclosure window by 30 days to allow sufficient time for deployment. Please confirm if this extension is needed and if 30 days is sufficient. I want to ensure responsible disclosure while giving your team adequate time to deploy the fix."

**Outcome:** The program appreciated the proactive communication, accepted the 30-day extension, and deployed the fix within the extended window. The coordinated approach prevented premature disclosure and maintained the researcher-program relationship.

### Case Study 5: Clarification Response Excellence

**Context:** A triager requested clarification about a race condition vulnerability: "Can you provide more details about the timing window? How consistent is the race condition?"

**Communication:** The researcher responded with comprehensive details: "The race condition has been tested 50 times with a 72% success rate. The timing window is approximately 50-150ms between requests. The most reliable reproduction method is using Burp Suite's Turbo Intruder with the following configuration: [detailed configuration]. I've attached: (1) A summary table of 50 test results showing success/failure rates, (2) A timing analysis showing the distribution of successful race windows, (3) An updated video showing the most reliable reproduction method. I've also updated the report's reproduction steps with the refined methodology."

**Outcome:** The comprehensive response eliminated the need for further clarification. The report was triaged within 24 hours of the response. The triager noted: "Excellent, thorough response. Report updated with additional testing data."

### Case Study 6: Professional Disagreement Maintenance

**Context:** A researcher's report was closed as "Informative" (no bounty) because the triager determined the vulnerability was out of scope. The researcher disagreed, believing the vulnerability was within scope.

**Communication:** The researcher responded professionally: "Thank you for the review. I'd like to discuss the scope determination. The report documents a vulnerability in the API endpoint at api.target.com/v2/users. The program scope includes *.target.com and all API endpoints. The triager's note indicates this endpoint is considered a third-party service. However, the endpoint responds with target.com CORS headers, uses target.com SSL certificates, and is documented in target.com's developer API documentation. I've attached: (1) CORS header response showing target.com origin, (2) SSL certificate details showing target.com issuance, (3) Target.com developer documentation listing this endpoint. I respectfully request re-evaluation of the scope determination."

**Outcome:** The program re-evaluated, agreed the endpoint was in scope, and reopened the report. The researcher's professional, evidence-based disagreement was effective without being confrontational.

### Case Study 7: Multi-Round Follow-Up Management

**Context:** A complex vulnerability required multiple rounds of clarification over 3 weeks. Each round required specific technical details.

**Communication Strategy:** The researcher maintained a communication log tracking each request and response. For each round, the researcher: (1) Acknowledged the request within 24 hours, (2) Provided the requested information within 48 hours, (3) Anticipated follow-up questions and proactively provided additional context, (4) Thanked the triager for their thorough review.

**Outcome:** The multi-round process concluded with the vulnerability accepted as Critical. The triager noted: "Patient, thorough researcher. Excellent communication throughout the triage process."

### Case Study 8: Post-Rejection Communication

**Context:** A researcher's report was rejected as "Not Applicable." The researcher believed the rejection was based on a misunderstanding of the vulnerability.

**Communication:** The researcher waited 48 hours, then sent: "I'd like to request reconsideration of the rejection for report #22222. I believe there may have been a misunderstanding regarding the vulnerability's exploitation path. The rejection note indicates the vulnerability requires 'admin access to exploit.' However, as shown in Step 3 of the reproduction steps, the vulnerability is exploitable by any authenticated user by modifying the user_id parameter in the profile endpoint. No admin access is required. I've attached an updated video showing the exploitation from a standard user account. I'd appreciate the opportunity to clarify any remaining questions."

**Outcome:** The report was reopened, triaged, and accepted. The researcher's patient, clear response addressed the misunderstanding without being defensive.

### Case Study 9: Bounty Negotiation Communication

**Context:** A researcher received a $500 bounty for a vulnerability they assessed as Critical (worth $5,000 per the program's published bounty table).

**Communication:** The researcher sent: "Thank you for the bounty. I'd like to discuss the bounty amount. The program's bounty table lists $5,000 for Critical severity. My report was rated Critical in the final assessment. I believe the bounty should reflect the Critical rating. The report documents: (1) Authentication bypass affecting all user accounts, (2) Full PII exposure for 50,000+ users, (3) Ability to modify any user's data. These impacts align with the Critical severity definition in the bounty table. I'd appreciate clarification on why the bounty does not match the published table."

**Outcome:** The program re-evaluated and increased the bounty to $5,000. The researcher's professional, evidence-based negotiation was effective.

### Case Study 10: Long-Term Relationship Building

**Context:** A researcher consistently submitted high-quality reports to the same program over 18 months, maintaining professional communication throughout.

**Cumulative Impact:** After 12 reports (all accepted, all with professional communication), the researcher received: (1) Invitation to the program's private bug bounty, (2) Faster triage times (average 24 hours vs. 5 days for new researchers), (3) More favorable severity assessments, (4) Direct communication channel with the program's security lead.

**Key Communication Patterns:** Consistent professionalism, prompt responses, evidence-based discussions, proactive disclosure coordination, and genuine thank-yous after resolution.

## Advanced Techniques

### Psychological Framing in Follow-Up

Frame follow-up messages to align with the triager's interests. Instead of "I need an update," try "I want to make sure you have everything needed to validate this finding." The first frames the message as your need; the second frames it as their benefit.

### Strategic Patience

Sometimes the most effective follow-up is no follow-up. If a report is in active triage (the triager is asking questions, requesting information), patience is more effective than repeated status checks. Active engagement indicates the report is being processed.

### Escalation Timing Optimization

Escalate when you have the strongest evidence and the clearest case. Escalating immediately after a disagreement is often premature — the triager may not have had time to fully consider your perspective. Waiting 48-72 hours demonstrates patience and allows the triager to reconsider before escalation becomes necessary.

### Communication Cadence Matching

Match your communication cadence to the program's. If the program responds in 24 hours, you should too. If the program takes a week, you can be more relaxed. Mismatched cadence creates friction — too-fast responses from you may seem demanding, while too-slow responses may seem disengaged.

### Narrative Construction for Escalations

Escalation narratives should be self-contained documents that tell a complete story: what was reported, what was assessed, why the assessment is inconsistent with the evidence, and what resolution you seek. The escalation reviewer should be able to make a decision without reading the original report.

### Proactive Issue Identification

If you identify a potential issue with your report (missing information, unclear steps, potential misunderstanding), proactively address it before the triager raises it. This demonstrates thoroughness and prevents delays.

### Positive Framing of Negative Outcomes

When communicating about unfavorable outcomes (rejection, downgrade, low bounty), frame the communication positively. Focus on what can be done rather than what went wrong. "I'd like to discuss how we can validate this finding" is more productive than "This assessment is wrong."

## Detection

### Communication Health Indicators

Monitor: response time trends, follow-up frequency, clarification request patterns, severity discussion frequency, and escalation rates. Healthy communication shows consistent, moderate interaction. Unhealthy communication shows either excessive or minimal interaction.

### Red Flags in Program Communication

Watch for: repeated requests for the same information, increasing delays between responses, tone shifts in program messages, and vague responses that avoid addressing specific points. These may indicate program-side issues that require adjusted communication strategy.

### Self-Assessment Questions

1. Am I following up at appropriate intervals?
2. Is my communication specific and action-oriented?
3. Am I maintaining professional tone throughout?
4. Am I providing sufficient evidence in discussions?
5. Am I respecting the program's communication patterns?

## Impact

### Resolution Time Correlation

Effective follow-up communication correlates with faster resolution times. Clear, timely, professional communication reduces back-and-forth, eliminates misunderstandings, and accelerates the triage process.

### Relationship Capital

Consistent professional communication builds relationship capital that benefits future interactions. Programs remember researchers who communicate well and prioritize their reports.

### Community Reputation

Communication quality contributes to your reputation in the bug bounty community. Programs share information about researcher quality, and good communication practices spread through community networks.

### Career Impact

Communication skills developed through bug bounty practice transfer to professional contexts. The ability to communicate complex technical issues clearly and professionally is valuable in any security career.

## Pitfalls

### Pitfall 1: Excessive Follow-Up
Following up daily or multiple times per week is counterproductive. It annoys triagers, signals impatience, and can result in your reports being deprioritized.

### Pitfall 2: Emotional Communication
Sending messages when frustrated, angry, or disappointed damages relationships. Always wait before sending emotionally charged messages.

### Pitfall 3: Vague Requests
"Any updates?" provides no useful information and requires the triager to determine what you want to know. Always ask specific questions.

### Pitfall 4: Ignoring Program Guidelines
Programs document their communication expectations. Ignoring these guidelines signals disrespect for the program's processes.

### Pitfall 5: Premature Escalation
Escalating before giving the triager adequate time to respond or reconsider is perceived as adversarial. Exhaust lower-level communication options first.

### Pitfall 6: Inconsistent Communication
Inconsistent tone, quality, or timing across messages creates confusion and undermines trust. Maintain consistency throughout the communication lifecycle.

### Pitfall 7: Over-Reliance on Templates
Templates are starting points, not finished products. Always customize templates to the specific situation. Generic template responses are obvious and ineffective.

### Pitfall 8: Ignoring Cultural Context
Communication norms vary across cultures. What is considered direct in one culture may be considered rude in another. Adapt to the program's cultural context.

### Pitfall 9: Failing to Document
Not keeping records of communication exchanges makes it difficult to reference previous discussions, track commitments, and build escalation cases.

### Pitfall 10: Neglecting Relationship Maintenance
Communication should not end when the report is resolved. Maintaining the relationship benefits future interactions.

## Integration

### With Report Writing
Communication quality should match report quality. A well-written report followed by poor communication creates a negative impression.

### With Severity Assessment
Severity discussions should reference specific evidence from the report and align with CVSS methodology.

### With Disclosure
Disclosure coordination should be proactive and follow the program's disclosure policy.

### With Peer Review
Communication drafts should be reviewed by peers before sending, especially for escalations and severity discussions.

### With Program Research
Understanding the program's communication patterns should inform your follow-up strategy.

## Reporting

### Communication Metrics to Track

Track: average response time from program, average follow-up frequency needed, clarification request rate, severity discussion rate, escalation rate, and bounty amounts correlated with communication quality.

### Documentation Standards

Maintain communication logs for each report: dates, messages sent and received, commitments made, and outcomes. This documentation is valuable for pattern analysis and escalation support.

### Continuous Improvement

Review communication outcomes regularly. Identify which strategies produce better results and refine your approach accordingly.

## Labs

### Lab 1: Template Development
Create templates for five common follow-up scenarios. Test them on real reports and refine based on outcomes.

### Lab 2: Timing Optimization
Vary your follow-up timing across five reports. Track response times and outcomes to identify optimal timing patterns.

### Lab 3: Severity Discussion Practice
Write three different severity discussion messages for the same vulnerability. Have peers evaluate which is most persuasive.

### Lab 4: Escalation Package Preparation
Create a complete escalation package for a hypothetical dispute. Include all necessary documentation and framing.

### Lab 5: Cultural Adaptation
Research communication norms for three different program cultures. Adapt your templates and approach for each.

### Lab 6: Relationship Building
Identify three programs you want to build relationships with. Develop a 6-month communication strategy for each.

### Lab 7: Outcome Analysis
Review your last 10 reports. Correlate communication patterns with outcomes. Identify what works and what doesn't.

## Ethics

### Honest Communication
All communication should be truthful and accurate. Misrepresenting facts, exaggerating issues, or making false claims damages trust and violates responsible disclosure principles.

### Respectful Disagreement
Disagreements should be expressed respectfully. Personal attacks, aggressive language, and adversarial framing damage relationships and undermine your position.

### Professional Boundaries
Maintain professional boundaries in all communications. Personal information, emotional content, and off-topic discussions are inappropriate in bug bounty communication.

### Confidentiality
Respect the confidentiality of program information, triage processes, and internal details. Do not share information from private communications without permission.

### Good Faith
Engage in all communications in good faith. The goal is to improve security, not to win arguments or maximize personal benefit at the expense of the program.

## Cheat Sheet

### Follow-Up Timing Guide
| Scenario | Wait Time | Action |
|----------|-----------|--------|
| No initial response | Program's stated response time + 1 business day | Polite status check |
| No response after status check | 3-5 business days | Second follow-up with specific question |
| After clarification response | 48-72 hours | Wait for triage progress |
| After severity rating | 48 hours | Prepare discussion if disagreeing |
| After escalation | Platform's stated timeline | Wait for resolution |
| After resolution | 24 hours | Thank you message |

### Message Structure Template
```
Subject: Report #[ID] - [Specific Question/Topic]

[Reference line]
[Specific question or concern]
[Supporting evidence if applicable]
[Proposed next step]
[Professional closing]
```

### Escalation Checklist
- [ ] Exhausted lower-level communication options
- [ ] Documented all previous communication
- [ ] Prepared evidence package
- [ ] Framed escalation as seeking perspective
- [ ] Used platform's official escalation process
- [ ] Maintained professional tone throughout

### Quick Communication Rules
1. Respond within 24 hours to any program communication
2. Ask specific questions, not vague status checks
3. Provide evidence, not opinions, in discussions
4. Match program communication cadence
5. Document all exchanges
6. Wait 48 hours before emotional responses
7. Escalate only as a last resort
8. Thank the team regardless of outcome
9. Maintain consistency across all interactions
10. Build relationships through cumulative quality
