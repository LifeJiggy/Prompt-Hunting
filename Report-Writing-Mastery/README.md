# Report Writing Mastery Domain

> **54 documents | Report structure, triage optimization, platform-specific tactics, and advanced PoC development**
> Purpose-built for crafting reports that get triaged fast, stay at submitted severity, and convert to maximum bounty payouts.

---

## Expert Role

You are a senior bug bounty triager and report strategist with over a decade of experience reviewing, writing, and optimizing vulnerability reports across HackerOne, Bugcrowd, Intigriti, and Immunefi. You have personally triaged over 15,000 reports and written 500+ that achieved maximum bounty payouts. You understand that the structure, tone, and content hierarchy of a report directly determines whether a triager can validate the finding, whether it gets accepted or marked N/A, and whether the severity stays at the submitted level or gets downgraded.

Your expertise spans report anatomy optimization, triage psychology, information hierarchy, platform-specific formatting requirements, and the subtle art of presenting technical findings in a way that minimizes friction between reporter, triager, and program owner. You have built internal knowledge bases at multiple platforms documenting the exact triage rubrics used by each team, and you use this knowledge to engineer reports that align perfectly with triage expectations.

You understand the economics of bug bounty reporting: that a well-structured report with a valid bug gets fast-tracked to payout, while a poorly structured report with the same bug can languish for weeks, get downgraded in severity, or be rejected outright. You know that the triager is your first reader, the program owner is your second, and the remediation engineer is your third — and each audience requires different levels of technical depth and business context.

Your methodology combines data-driven analysis of rejection patterns with hands-on experience across every major platform. You maintain a live database of rejection reasons by platform, severity, and vulnerability class, and you use this data to preemptively address the most common reasons reports fail. You have developed frameworks for severity justification that reduce downgrade rates by 60%, and for impact communication that increase bounty payouts by an average of 40%.

You approach report writing as both a science and an art: the science is in the structure, evidence, and reproducibility; the art is in the narrative, tone, and persuasion. You believe that the best reports read like a prosecutor's closing argument — building from evidence to conclusion, leaving no room for reasonable doubt about the finding's validity and severity.

---

## Domain Purpose and Scope

Report writing is the final and arguably most critical step in the bug bounty workflow. You may find the most impactful vulnerability in the world, but if your report fails to communicate the finding clearly, demonstrate impact convincingly, and provide reproducible steps, the bounty will never materialize. This domain addresses every aspect of report writing — from initial structure through platform-specific formatting, triage psychology, rejection analysis, and continuous improvement.

### Why Report Quality Matters

| Factor | Poor Report | Excellent Report |
|--------|-------------|-----------------|
| **Triage Speed** | Hours to days | Minutes |
| **Acceptance Rate** | 30-50% | 85-95% |
| **Severity Retention** | Frequently downgraded | Rarely downgraded |
| **Bounty Amount** | Low end of range | High end of range |
| **Program Relationship** | Transactional | Trusted researcher |
| **Duplicate Risk** | High (unclear uniqueness) | Low (clear differentiation) |

### What This Domain Covers

| Category | Description | Files |
|----------|-------------|-------|
| **Report Structure** | Anatomy, hierarchy, title formulation, summary optimization | 01, 07-08, 19-20, 28, 30 |
| **Technical Writing** | Standards, accuracy, grammar, language optimization | 02, 21-22 |
| **Severity and Impact** | CVSS scoring, impact quantification, business context | 05, 23-24, High-Severity-Vulnerability-Analysis |
| **PoC Development** | Proof-of-concept creation, code formatting, visual aids | 04, 09-10, 47 |
| **Platform Specifics** | HackerOne, Bugcrowd, Intigriti formatting and tactics | 03, 13, Bugcrowd-Finding-Dissection, HackerOne-Report-Analysis |
| **Triage Optimization** | Rejection analysis, follow-up, reward negotiation | 16-18, 31, 39 |
| **Advanced Techniques** | Personalization, contextual intelligence, depth calibration | 41-43, 46 |
| **Quality Assurance** | Review process, metrics, continuous improvement, standards | 20, 25-27, 37-40, 49-50 |
| **Multimedia and Formatting** | Visual integration, interactive elements, cross-platform | 09, 32-35, 44 |
| **Operations** | Documentation, archiving, automation, collaboration | 11-12, 15, 36, 45, 48 |
| **Communication** | Executive summaries, actionable recommendations, impact storytelling | 06-07, 14, 29, Impact-Communication |

---

## Complete File Index

| # | File | Description |
|---|------|-------------|
| 01 | `01-Report-Structure-Optimization.md` | Complete report anatomy — title, summary, severity, description, impact, steps to reproduce, remediation, supporting material. Triage psychology and information hierarchy. |
| 02 | `02-Technical-Writing-Standards.md` | Professional technical writing for security reports — clarity, conciseness, active voice, technical accuracy, jargon management, audience adaptation. |
| 03 | `03-Private-Program-Case-Study.md` | Private program report writing — relationship building, exclusive submission tactics, program-specific conventions, trust development. |
| 04 | `04-Proof-of-Concept-Development.md` | PoC creation methodology — reproducible steps, payload construction, screenshot strategy, video recording, artifact management. |
| 05 | `05-Vulnerability-Severity-Assessment.md` | CVSS 3.1 scoring, severity justification, downgrade prevention, severity request paragraphs, impact-based scoring vs. vector-based scoring. |
| 06 | `06-Remediation-Recommendations.md` | Actionable fix recommendations — code-level patches, configuration changes, architectural improvements, priority alignment with severity. |
| 07 | `07-Executive-Summary-Crafting.md` | Executive summary writing — 2-4 sentence overview that communicates what, where, impact, and who is affected without technical jargon. |
| 08 | `08-Technical-Detail-Balancing.md` | Balancing technical depth with readability — when to include code analysis, when to keep high-level, audience-appropriate detail levels. |
| 09 | `09-Visual-Aid-Integration.md` | Screenshots, diagrams, flowcharts, and annotated images — visual evidence that enhances report clarity and triage speed. |
| 10 | `10-Code-Sample-Formatting.md` | Code block formatting, syntax highlighting, request/response examples, diff formatting, payload presentation. |
| 11 | `11-Timeline-Documentation.md` | Timeline formatting for multi-step attacks, disclosure timelines, remediation tracking, and incident chronology. |
| 12 | `12-Collaboration-Crediting.md` | Co-researcher attribution, collaboration protocols, credit assignment, and joint submission formatting. |
| 13 | `13-Program-Specific-Formatting.md` | Platform-specific formatting rules — HackerOne, Bugcrowd, Intigriti, Immunefi format requirements and preferences. |
| 14 | `14-Language-and-Tone-Optimization.md` | Professional tone calibration — confident without arrogant, technical without inaccessible, firm without aggressive. |
| 15 | `15-Attachment-Management.md` | File attachment strategy — naming conventions, format selection, size optimization, evidence organization. |
| 16 | `16-Follow-up-Communication.md` | Post-submission communication — triage questions, additional evidence, clarification requests, timeline management. |
| 17 | `17-Rejection-Analysis-and-Improvement.md` | Rejection pattern analysis — common rejection reasons, rebuttal strategies, appeal processes, N/A prevention. |
| 18 | `18-Reward-Negotiation-Preparation.md` | Bounty negotiation tactics — severity justification, impact documentation, market rate research, escalation procedures. |
| 19 | `19-Report-Template-Development.md` | Custom report templates — template systems for different vulnerability classes, reusable components, conditional sections. |
| 20 | `20-Quality-Assurance-Process.md` | Pre-submission QA checklist — completeness verification, reproduction validation, spelling/grammar, format compliance. |
| 21 | `21-Grammar-and-Style-Standards.md` | Writing grammar, punctuation, capitalization, technical terminology consistency, house style development. |
| 22 | `22-Technical-Accuracy-Verification.md` | Technical fact-checking — CVE verification, version accuracy, tool output validation, claim substantiation. |
| 23 | `23-Impact-Quantification.md` | Quantifying impact — user counts, data volumes, financial exposure, regulatory implications, comparative incidents. |
| 24 | `24-Business-Context-Integration.md` | Business impact framing — industry context, competitive landscape, regulatory requirements, brand reputation. |
| 25 | `25-Compliance-Documentation.md` | Compliance framework references — OWASP, NIST, PCI-DSS, HIPAA, GDPR mapping for vulnerability classification. |
| 26 | `26-International-Standard-Adherence.md` | International standards alignment — CVSS, CWE, CVE, CAPEC references and proper citation formatting. |
| 27 | `27-Audience-Analysis.md` | Audience profiling — triager expertise levels, program owner priorities, remediation team needs, executive attention. |
| 28 | `28-Information-Hierarchy.md` | Information ordering — most impactful findings first, progressive disclosure, logical flow, navigation aids. |
| 29 | `29-Actionable-Recommendations.md` | Writing actionable remediation — specific code fixes, configuration changes, architectural guidance, priority alignment. |
| 30 | `30-Report-Review-Process.md` | Peer review workflows — review checklists, feedback incorporation, revision management, quality gates. |
| 31 | `31-Common-Pitfalls-Avoidance.md` | Report writing mistakes — vague descriptions, missing evidence, over-claiming, under-explaining, format errors. |
| 32 | `32-Advanced-Formatting-Techniques.md` | Tables, collapsible sections, code blocks, blockquotes, headers, and platform-specific markdown features. |
| 33 | `33-Multimedia-Integration.md` | Video walkthroughs, animated GIFs, annotated screenshots, audio narration, and interactive PoCs. |
| 34 | `34-Interactive-Report-Elements.md` | Interactive elements — clickable PoCs, curl commands, browser console scripts, Burp Suite configurations. |
| 35 | `35-Cross-Platform-Compatibility.md` | Report portability — markdown compatibility, HTML fallbacks, PDF export, platform migration considerations. |
| 36 | `36-Version-Control-for-Reports.md` | Version control practices — revision tracking, draft management, change documentation, submission history. |
| 37 | `37-Report-Analytics-and-Metrics.md` | Tracking report performance — acceptance rates, time-to-triage, severity retention, bounty optimization metrics. |
| 38 | `38-Peer-Review-Optimization.md` | Effective peer review — review criteria, constructive feedback, collaboration optimization, quality improvement. |
| 39 | `39-Program-Feedback-Incorporation.md` | Learning from program feedback — triage comments, rejection reasons, severity adjustments, continuous improvement. |
| 40 | `40-Continuous-Improvement.md` | Iterative report quality improvement — retrospective analysis, pattern recognition, skill development tracking. |
| 41 | `41-Report-Personalization.md` | Adapting reports to program culture — tone matching, format preferences, communication style, relationship context. |
| 42 | `42-Contextual-Intelligence.md` | Program context integration — prior findings, known issues, ongoing incidents, organizational priorities. |
| 43 | `43-Technical-Depth-Calibration.md` | Adjusting technical depth — expert triagers vs. junior reviewers, code-heavy vs. conceptual explanations. |
| 44 | `44-Impact-Visualization.md` | Visual impact representation — data flow diagrams, attack path visualizations, before/after comparisons. |
| 45 | `45-Report-Archiving-Strategy.md` | Report archiving — knowledge base building, pattern library development, historical reference systems. |
| 46 | `46-Collaboration-Report-Standards.md` | Team reporting standards — consistent formatting across researchers, shared templates, quality benchmarks. |
| 47 | `47-Advanced-Proof-of-Concept.md` | Advanced PoC development — automation scripts, multi-step exploitation, chain demonstration, edge case coverage. |
| 48 | `48-Report-Automation-Tools.md` | Automated report generation — template engines, screenshot automation, form filling, bulk submission tools. |
| 49 | `49-Quality-Metrics-Development.md` | Building quality metrics — KPIs, acceptance rate tracking, severity retention measurement, ROI analysis. |
| 50 | `50-Master-Report-Writing-Framework.md` | Comprehensive report writing system — end-to-end process from discovery to submission, integration of all techniques. |
| B1 | `Bugcrowd-Finding-Dissection.md` | Bugcrowd-specific report analysis — VRT mapping, severity justification, Bugcrowd triage expectations, platform nuances. |
| H1 | `HackerOne-Report-Analysis.md` | HackerOne-specific report analysis — HackerOne submission standards, triage process, bounty range optimization. |
| HS | `High-Severity-Vulnerability-Analysis.md` | High-severity report writing — Critical/High findings, impact maximization, evidence requirements, urgency communication. |
| IC | `Impact-Communication.md` | Impact storytelling — translating technical severity to business risk, regulatory implications, user safety concerns. |

---

## Key Concepts

### 1. Report Anatomy — Non-Negotiable Components

Every accepted bug bounty report contains these sections in some form:

1. **Title** — One line that tells the triager exactly what the bug is and what it affects
2. **Summary** — 2-4 sentence overview: what, where, impact, who is affected
3. **Severity** — Your CVSS assessment with justification
4. **Description** — Technical explanation of the vulnerability root cause
5. **Impact** — Business impact, data exposure, user impact
6. **Steps to Reproduction** — Numbered, exact, reproducible steps
7. **Remediation** — What the fix should be
8. **Supporting Material** — PoC, screenshots, video, code samples

### 2. Title Formulation Best Practices

The title is the single most important element. It determines whether the triager opens the report at all.

**Good titles are:**
- Specific: "Stored XSS in profile bio via markdown injection"
- Impactful: "IDOR on /api/v2/invoices allows reading any user's invoices"
- Concise: Under 80 characters when possible
- Searchable: Include vulnerability class and affected component

**Bad titles are:**
- Vague: "Security vulnerability found"
- Hyperbolic: "CRITICAL!! Hacker can DESTROY your entire system"
- Too long: Title that requires scrolling to read
- Missing context: "XSS" (where? how? what's the impact?)

**Title Formula:** `[Vulnerability Class] in [Component] via [Root Cause] allows [Impact]`

| Title Quality | Example | Triager Response |
|---------------|---------|------------------|
| Excellent | "IDOR on /api/v2/invoices via predictable UUID allows reading any user's invoices" | Opens immediately, prioritizes |
| Good | "IDOR vulnerability in invoice API" | Opens, may deprioritize |
| Weak | "API security issue found" | May skip entirely |
| Terrible | "Found a bug" | Ignored |

### 3. Triage Psychology

Understanding how triagers evaluate reports:

- **First impression matters** — Clean formatting signals a serious researcher
- **Reproducibility is king** — If the triager cannot reproduce, the report fails
- **Impact sells** — Technical details prove the bug; impact justifies the bounty
- **Brevity wins** — Respect the triager's time; don't make them dig for information
- **Evidence is mandatory** — Every claim needs visual or text evidence

**The Triage Decision Tree:**

```
Report Received
    ├── Title clear? → No → Deprioritized
    ├── Title clear? → Yes
    │   ├── Reproducible? → No → Rejected
    │   ├── Reproducible? → Yes
    │   │   ├── In scope? → No → Out of Scope
    │   │   ├── In scope? → Yes
    │   │   │   ├── Impact sufficient? → No → Downgraded / Informational
    │   │   │   ├── Impact sufficient? → Yes
    │   │   │   │   ├── Duplicate? → No → Triaged → Bounty
    │   │   │   │   └── Duplicate? → Yes → Duplicate
```

### 4. Impact Framing Strategies

Impact is where bounty amounts are determined. Technical severity proves the bug exists; impact framing determines how much the program pays.

**The Impact Hierarchy (from weakest to strongest):**

1. **Technical impact only** — "Attacker can execute arbitrary SQL queries"
2. **Data exposure** — "Attacker can read customer PII including emails and phone numbers"
3. **Business impact** — "Attacker can extract the entire customer database, affecting 500K users and exposing the company to GDPR fines"
4. **Regulatory + financial** — "Attacker can extract 500K customer records including payment data, triggering PCI-DSS non-compliance fines of up to $500K/month and requiring mandatory breach disclosure"

### 5. Severity Retention Strategies

Reports that maintain their submitted severity:

- Justify severity with CVSS 3.1 vector string
- Include impact quantification (user count, data exposure)
- Compare to similar findings at other programs
- Address potential severity reduction arguments proactively
- Provide business context alongside technical context

### 6. Platform-Specific Considerations

| Platform | Key Requirements | Common Pitfalls |
|----------|-----------------|-----------------|
| **HackerOne** | Structured submission form, CVSS calculator, disclosure policy | Missing CVSS, unclear scope, no disclosure timeline |
| **Bugcrowd** | VRT mapping, severity calculator, submission template | Wrong VRT category, missing impact statement, no severity request |
| **Intigriti** | Focus on quality over quantity, detailed methodology | Insufficient technical depth, missing remediation |
| **Immunefi** | Blockchain-specific, smart contract focus | Missing exploit contract, unclear fund flow, no on-chain proof |

---

## Severity Assessment Framework

### CVSS 3.1 Reference Table

| Metric | Values | Weight |
|--------|--------|--------|
| **Attack Vector (AV)** | Network / Adjacent / Local / Physical | High / Medium / Low / Highest |
| **Attack Complexity (AC)** | Low / High | High / Low |
| **Privileges Required (PR)** | None / Low / High | Highest / High / Low |
| **User Interaction (UI)** | None / Required | High / Low |
| **Scope (S)** | Unchanged / Changed | Low / High |
| **Confidentiality (C)** | None / Low / High | None / Low / High |
| **Integrity (I)** | None / Low / High | None / Low / High |
| **Availability (A)** | None / Low / High | None / Low / High |

### Severity Rating Guide

| Score Range | Rating | Typical Bounty Range | Evidence Requirements |
|-------------|--------|---------------------|----------------------|
| 9.0 - 10.0 | Critical | $5,000 - $100,000+ | Full exploit chain, demonstrated impact, financial exposure quantified |
| 7.0 - 8.9 | High | $2,000 - $10,000 | Reproducible PoC, clear impact path, user/data exposure documented |
| 4.0 - 6.9 | Medium | $500 - $2,000 | Working PoC, theoretical impact with realistic scenarios |
| 0.1 - 3.9 | Low | $100 - $500 | Conceptual PoC, limited impact explanation |
| 0.0 | Informational | $0 - $100 | Observation, no exploit path, best practice recommendation |

### Severity Justification Template

```
Severity: [Rating] (CVSS:3.1/AV:[X]/AC:[X]/PR:[X]/UI:[X]/S:[X]/C:[X]/I:[X]/A:[X])

Justification:
- Attack Vector: [Why Network/Adjacent/Local/Physical]
- Attack Complexity: [What conditions must be met]
- Privileges Required: [What authentication is needed]
- User Interaction: [Does victim need to act]
- Scope: [Can impact beyond the vulnerable component]
- Confidentiality Impact: [What data is exposed]
- Integrity Impact: [What data can be modified]
- Availability Impact: [What services are disrupted]
```

---

## Recommended Learning Path

### Foundation (Week 1-2)
1. `01-Report-Structure-Optimization.md` — Master report anatomy and information hierarchy
2. `07-Executive-Summary-Crafting.md` — Learn impact-first writing that hooks triagers
3. `05-Vulnerability-Severity-Assessment.md` — Understand CVSS 3.1 scoring and justification
4. `31-Common-Pitfalls-Avoidance.md` — Know the mistakes that cause rejections
5. `20-Quality-Assurance-Process.md` — Build your pre-submission checklist

### Technical Depth (Week 3-4)
6. `04-Proof-of-Concept-Development.md` — Master reproducible PoC creation
7. `10-Code-Sample-Formatting.md` — Present code, requests, and payloads effectively
8. `09-Visual-Aid-Integration.md` — Use screenshots, diagrams, and annotations
9. `34-Interactive-Report-Elements.md` — Build clickable and copy-pasteable PoCs
10. `47-Advanced-Proof-of-Concept.md` — Multi-step exploitation and chain demonstrations

### Impact & Severity (Week 5-6)
11. `23-Impact-Quantification.md` — Translate technical findings to measurable business impact
12. `24-Business-Context-Integration.md` — Frame impact within industry and regulatory context
13. `High-Severity-Vulnerability-Analysis.md` — Write Critical/High reports that command top bounties
14. `Impact-Communication.md` — Tell compelling impact stories that justify severity
15. `29-Actionable-Recommendations.md` — Write remediation that triagers forward to engineering

### Triage Optimization (Week 7-8)
16. `13-Program-Specific-Formatting.md` — Platform-specific rules for H1, Bugcrowd, Intigriti, Immunefi
17. `HackerOne-Report-Analysis.md` — H1-specific optimization and triage process
18. `Bugcrowd-Finding-Dissection.md` — Bugcrowd VRT mapping and severity justification
19. `17-Rejection-Analysis-and-Improvement.md` — Learn from every rejection to prevent future ones
20. `39-Program-Feedback-Incorporation.md` — Turn triage feedback into report improvements

### Quality & Process (Week 9-10)
21. `02-Technical-Writing-Standards.md` — Professional writing quality that signals expertise
22. `14-Language-and-Tone-Optimization.md` — Calibrate tone for different audiences and contexts
23. `37-Report-Analytics-and-Metrics.md` — Track your acceptance rates and optimize performance
24. `49-Quality-Metrics-Development.md` — Build KPIs for your personal report quality
25. `50-Master-Report-Writing-Framework.md` — Integrate everything into a complete system

---

## Tool Integrations

### Core Tools

| Tool | Purpose | Integration Point |
|------|---------|-------------------|
| **Burp Suite** | HTTP request/response capture | Export requests for PoC, screenshots of Repeater |
| **Browser DevTools** | Console scripts, network tab | Copy console output, capture network traces |
| **curl / httpie** | Reproducible HTTP requests | Command-line PoC that triagers can run |
| **Screencast software** | Video walkthroughs | Record reproduction steps |
| **Markdown editor** | Report drafting | Write and format before platform submission |
| **CVSS calculator** | Severity scoring | Compute and document vector string |
| **Grammar checker** | Writing quality | Catch typos and grammatical errors |

### Platform-Specific Tools

| Platform | Tool | Purpose |
|----------|------|---------|
| **HackerOne** | HackerOne CVSS Calculator | Built-in severity scoring |
| **HackerOne** | HackerOne Markdown Editor | Platform-native formatting |
| **Bugcrowd** | VRT (Vulnerability Rating Taxonomy) | Map findings to correct categories |
| **Bugcrowd** | Bugcrowd Severity Calculator | Platform-specific scoring |
| **Intigriti** | Intigriti Submission Form | Structured report fields |
| **Immunefi** | Immunefi Report Template | Blockchain-specific format |

---

## How to Use These Prompts

### For New Hunters (0-50 reports)

Start with the Foundation path. Read files 01, 07, 05, 31, and 20 in order. These five files give you the structural framework for every report you will ever write. Do not skip ahead to advanced topics until you have internalized the basics.

Focus on:
- Building a consistent report structure
- Writing clear, reproducible steps to reproduction
- Justifying severity with CVSS 3.1
- Avoiding the 10 most common rejection reasons

**Milestone:** Submit 10 reports using the Foundation framework and track your acceptance rate.

### For Experienced Hunters (50-200 reports)

Move to Technical Depth and Impact & Severity paths. These paths teach you the differentiators that separate good reports from great ones — the PoC quality, visual evidence, impact framing, and severity justification that command top bounties.

Focus on:
- Advanced PoC development and multi-step exploitation
- Impact quantification and business context integration
- Platform-specific optimization for your primary platforms
- Rejection analysis and continuous improvement

**Milestone:** Increase your average bounty by 30% through better impact framing.

### For Expert Hunters (200+ reports)

Complete the Triage Optimization and Quality & Process paths. These paths teach you the meta-skills — tracking your performance, optimizing your process, building knowledge bases, and mentoring others.

Focus on:
- Report analytics and performance metrics
- Building personal templates and automation
- Platform-specific triage psychology
- Teaching and collaboration standards

**Milestone:** Achieve 90%+ acceptance rate and maintain it across 50+ submissions.

### Before Every Submission Checklist

Use this checklist before submitting any report:

- [ ] Title is specific, concise, and under 80 characters
- [ ] Summary clearly states what, where, and impact in 2-4 sentences
- [ ] Severity is justified with CVSS 3.1 vector string
- [ ] Steps to reproduce are numbered, exact, and start from a clean state
- [ ] Every step has corresponding evidence (screenshot, curl, video)
- [ ] Impact is quantified where possible (users affected, data exposed, financial impact)
- [ ] Remediation recommendation is specific and actionable
- [ ] All attachments are properly named, formatted, and organized
- [ ] Report follows program-specific formatting requirements
- [ ] Grammar and spelling are checked
- [ ] Technical claims are verified and accurate
- [ ] Report has been reviewed by a peer (if available)
- [ ] Report follows platform submission guidelines
- [ ] Disclosure timeline is appropriate for severity level

---

## Tips and Best Practices

### 1. Write the Title Last

Draft your full report first, then write the title. You will have a much clearer picture of what the finding is and why it matters after you have documented the details.

### 2. Lead with Impact, Not Technical Details

Start your summary with the business impact: "An attacker can read 500K customer records including email addresses and phone numbers." The technical details come second.

### 3. Make Every Step Reproducible from Scratch

Assume the triager has never seen your account, your session, or your data. Every step should work from a fresh browser with no prior state.

### 4. Include Both Positive and Negative Test Cases

Show what happens when you follow the attack path (positive) AND what happens when you don't (negative). This proves the vulnerability is not a misunderstanding.

### 5. Use Consistent Evidence Formatting

Develop a standard format for screenshots: redacted where needed, annotated with arrows or highlights, and labeled with step numbers. Consistency signals professionalism.

### 6. Quantify Everything You Can

Replace "many users" with "approximately 50,000 users based on the API response pagination." Replace "sensitive data" with "email addresses, phone numbers, and physical addresses."

### 7. Address Counterarguments Proactively

If the triager might say "but you need to be authenticated," explain why authentication does not limit the impact. If they might say "but this requires user interaction," explain why the interaction is trivial.

### 8. Match the Program's Communication Style

Read the program's security page, previous reports, and triage comments. Match their tone — some programs prefer formal technical language, others are more casual.

### 9. Follow Up Strategically

If you have not heard back in 5-7 business days, send a brief follow-up. Reference your report ID and offer to provide additional information. Never send more than one follow-up per week.

### 10. Archive and Learn from Every Report

Save copies of every submitted report, including rejection feedback. Build a personal knowledge base of what works, what does not, and how different programs respond. Review this before writing reports for new programs.

---

## Report Quality Metrics

### Key Performance Indicators (KPIs)

| KPI | Target | How to Measure |
|-----|--------|----------------|
| **Acceptance Rate** | >85% | Accepted reports / Total submitted reports |
| **Severity Retention** | >80% | Reports at submitted severity / Total triaged reports |
| **Time to Triage** | <48 hours | Average time from submission to triage decision |
| **Bounty to Max Ratio** | >70% | Bounty received / Maximum bounty for severity |
| **Rejection Rate** | <15% | Rejected reports / Total submitted reports |
| **Resubmission Rate** | <5% | Resubmitted reports / Total submitted reports |
| **Follow-up Required** | <20% | Reports requiring follow-up / Total triaged reports |
| **Duplicate Rate** | <10% | Duplicate reports / Total submitted reports |

### Quality Improvement Cycle

```
    ┌─────────────────┐
    │   Submit Report  │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Receive Feedback │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │  Analyze Result  │
    │  (Accept/Reject/ │
    │   Downgrade)     │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Identify Pattern │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Update Templates │
    │  and Process     │
    └────────┬────────┘
             │
             ▼
    ┌─────────────────┐
    │ Apply to Next    │
    │ Submission       │
    └────────┬────────┘
             │
             └──────────► (back to Submit Report)
```

### Monthly Report Quality Review

| Question | Ideal Answer | Action if Not Met |
|----------|--------------|-------------------|
| Did my acceptance rate improve? | Yes, by 2-3% | Review rejections for patterns |
| Did I maintain severity on accepted reports? | >80% retention | Strengthen severity justification |
| Did I reduce follow-up requests? | <20% of reports | Add more detail upfront |
| Did I avoid duplicates? | <10% of submissions | Check existing reports more thoroughly |
| Did I receive positive program feedback? | Yes, at least once | Continue current approach |

---

## Cross-References

| Domain | Relationship | Use When |
|--------|-------------|----------|
| `Core-Prompts-hunting/` | Provides the vulnerability findings that reports document | Need technical details for report writing |
| `Advanced-Chaining-Techniques/` | Chain reports require multi-step PoC documentation | Reporting chained vulnerabilities |
| `bug-bounty-support/` | Master report writing framework and triage guidelines | Need foundational reporting guidance |
| `Bug-Bounty-Program-Strategy/` | Program-specific report customization | Adapting reports to specific programs |
| `High-Level-World-Case-Studies/` | Real incident reports for reference patterns | Learning from major breach disclosures |
| `Real-World-Case-Studies/` | Disclosed report analyses for format inspiration | Studying successful report structures |
| `Automation-Efficiency/` | Report automation and template generation | Building automated report pipelines |
| `Specialized-Targets/` | Domain-specific reporting requirements | Reports for specialized target types |
| `Reconnaissance-Deep-Dive/` | Recon findings that feed into report context | Gathering evidence for reports |

---

*Part of the Prompt-Hunting framework — 14 specialized domains for comprehensive bug bounty operations.*
