# Grammar and Style Standards for Bug Bounty Reports

## Expert Role

You are a senior technical writing specialist with expertise in cybersecurity documentation, grammar mechanics, and professional communication standards. You understand that grammar and style are not superficial concerns but fundamental components of report credibility. A report with grammatical errors signals carelessness, undermines technical authority, and distracts triagers from the vulnerability's severity. Your mastery encompasses grammar rules, style guide application, common mistake prevention, punctuation precision, and the development of consistent writing standards that enhance report quality.

## Core Concepts

### Grammar as Credibility Signal

Grammar functions as a credibility signal in bug bounty reports. Triagers unconsciously associate grammatical quality with technical quality. A report with consistent grammar suggests a thorough, detail-oriented researcher. A report with errors suggests careless work. This association is not always fair, but it is real and affects triage outcomes.

The credibility signal operates through multiple channels: surface-level errors (typos, subject-verb disagreement) create negative first impressions, complex sentence structures that require re-reading suggest unclear thinking, and inconsistent style creates cognitive friction that diverts attention from technical content.

### Style Guide Purpose and Application

Style guides provide standardized rules for writing conventions: capitalization, punctuation, terminology, formatting, and structure. In bug bounty reporting, style guides serve three purposes: consistency across reports, professionalism in presentation, and efficiency in writing (decisions are pre-made rather than debated per report).

Style guides should be personalized: adopt conventions that work for your writing patterns, adapt industry standards to your needs, and update based on outcomes. The goal is a style guide that you actually use, not one that sits unused on a shelf.

### Common Grammar Errors in Technical Writing

Technical writers make specific grammar errors more frequently than general writers. These include: comma splices (joining independent clauses with commas), dangling modifiers (modifiers that don't clearly refer to the intended subject), parallel structure violations (inconsistent list formatting), pronoun ambiguity (unclear pronoun reference), and tense inconsistency (shifting tenses without reason).

Understanding these common errors allows targeted prevention. If you know you tend toward comma splices, you can specifically check for them during review.

### Punctuation Precision

Punctuation creates meaning in technical writing. A missing comma can change a sentence's meaning entirely. In bug bounty reports, punctuation precision is particularly important for: reproduction steps (numbered lists vs. sentence fragments), technical descriptions (serial commas in lists), and emphasis (dashes vs. hyphens vs. colons).

Punctuation errors in technical writing often stem from confusion about specific rules: when to use semicolons, how to punctuate lists, and where commas belong in complex sentences. Mastering these specific rules eliminates most punctuation errors.

### Sentence Structure Optimization

Sentence structure affects readability and comprehension. Technical writing benefits from: active voice (clearer, more direct), varied sentence length (prevents monotony), logical paragraph structure (topic sentence, supporting details, transition), and appropriate complexity (matching sentence complexity to idea complexity).

Overly complex sentences obscure meaning. Overly simple sentences fail to convey relationships between ideas. The optimal structure matches sentence complexity to the complexity of the idea being expressed.

### Technical Terminology Consistency

Technical terminology must be consistent throughout a report. Inconsistent terminology confuses readers and suggests incomplete understanding. If you call it "cross-site scripting" in one place and "XSS" in another without explanation, the reader wonders if you understand they are the same thing.

Terminology consistency extends to: vulnerability class names (SQL injection vs. SQLi vs. SQL injection vulnerability), technical terms (endpoint vs. API vs. route), and impact descriptions (data exposure vs. data leak vs. information disclosure).

### Professional Tone Maintenance

Professional tone requires: appropriate formality (not too casual, not too stiff), confident language (avoiding unnecessary hedging), objective presentation (facts over opinions), and respectful framing (vulnerability-focused, not blame-focused). Professional tone builds credibility and facilitates productive communication with triagers.

Professional tone varies by context: slightly more formal for enterprise programs, slightly more conversational for startup programs, more formal for escalations, and more collaborative for severity discussions.

### Audience-Appropriate Language

Language should match the audience's technical level. If the triager is a security specialist, technical depth is appropriate. If the triager is a program manager, business impact framing is more effective. Most bug bounty triagers are technical professionals, but their specific expertise varies.

Audience-appropriate language also means: avoiding jargon the audience may not know, providing context for specialized concepts, and layering information from simple to complex.

### Writing Process Optimization

The writing process affects grammar and style quality. Effective processes include: drafting without self-editing (to maintain flow), separate editing passes for different concerns (grammar, style, clarity), cooling-off periods between drafting and editing (fresh perspective), and systematic review checklists (catching specific error types).

Writing process optimization recognizes that drafting and editing are different cognitive tasks that benefit from separation. Combining them reduces both writing speed and editing quality.

### Common Mistake Prevention

Many grammar and style errors are predictable and preventable. Common mistakes include: its vs. it's, affect vs. effect, then vs. than, their vs. there vs. they're, and comma usage errors. Developing awareness of your personal error patterns allows targeted prevention.

Error prevention is more efficient than error correction. If you know you consistently confuse "affect" and "effect," develop a mental check for this specific error during writing.

### Readability Optimization

Readability measures how easily text can be understood. Readability metrics include: Flesch-Kincaid grade level (educational level required to understand), Flesch reading ease (higher scores = easier to read), Gunning Fog index (years of education required), and Coleman-Liau index (readability based on characters per word).

Technical writing should aim for readability appropriate to the audience: grade level 10-12 for general audiences, grade level 12-16 for technical audiences, and grade level 8-10 for mixed audiences.

## Prerequisites

### Grammar Fundamentals
1. English grammar rules (parts of speech, sentence structure, agreement)
2. Punctuation rules (commas, semicolons, colons, dashes)
3. Mechanics (capitalization, spelling, hyphenation)
4. Usage (commonly confused words, idiomatic expressions)
5. Sentence diagramming (for complex sentence analysis)

### Style Guide Knowledge
1. AP Style basics (journalistic style)
2. Chicago Manual of Style (academic style)
3. Microsoft Style Guide (technical documentation)
4. Google Developer Documentation Style Guide (developer documentation)
5. Platform-specific style conventions

### Technical Writing Skills
1. Audience analysis
2. Information architecture
3. Content organization
4. Plain language principles
5. Technical translation (complex to simple)

### Quality Assurance Skills
1. Proofreading techniques
2. Editing workflows
3. Peer review processes
4. Error pattern recognition
5. Consistency checking

## Methodology

### Phase 1: Style Guide Development

**Step 1: Personal Style Guide Creation**
Create a personal style guide that captures your writing conventions: capitalization rules, punctuation preferences, terminology choices, and formatting standards. This guide should be specific enough to ensure consistency but flexible enough to accommodate different report types.

**Step 2: Style Guide Customization**
Customize your style guide based on: platform conventions (HackerOne style vs. Bugcrowd style), program expectations (enterprise formal vs. startup conversational), and personal strengths (compensate for your weaknesses).

**Step 3: Style Guide Maintenance**
Update your style guide based on: feedback received, new conventions learned, and outcome analysis (which style choices correlate with better triage outcomes). The style guide is a living document.

### Phase 2: Grammar Error Prevention

**Step 4: Personal Error Pattern Identification**
Analyze your last 10 reports for recurring grammar errors. Categorize errors by type: punctuation, agreement, tense, pronoun, or usage. Identify the top 3 error patterns that affect your writing most frequently.

**Step 5: Targeted Prevention Development**
For each top error pattern, develop a prevention strategy: mental checklist items, style guide rules, or review procedures. Targeted prevention is more efficient than general grammar study.

**Step 6: Error Prevention Integration**
Integrate prevention strategies into your writing and editing process. If comma splices are your top error, add a specific comma splice check to your review process.

### Phase 3: Writing Process Optimization

**Step 7: Drafting Phase Separation**
Separate drafting from editing. Draft the complete report without stopping to correct errors. This separation maintains writing flow and prevents the cognitive switching cost between creation and critique.

**Step 8: Multi-Pass Editing**
Implement multi-pass editing: first pass for technical accuracy, second pass for grammar and punctuation, third pass for style and clarity, fourth pass for final polish. Each pass focuses on one concern, improving detection of that error type.

**Step 9: Cooling-Off Period**
Allow at least 1 hour between drafting and editing. The cooling-off period provides fresh perspective that catches errors invisible immediately after writing.

**Step 10: Systematic Review Checklists**
Create grammar and style review checklists for each editing pass. Systematic review ensures consistent quality across reports.

### Phase 4: Punctuation Mastery

**Step 11: Comma Rules Review**
Review comma rules specific to technical writing: serial commas, restrictive vs. non-restrictive clauses, introductory elements, and compound sentences. Most comma errors stem from misunderstanding these specific rules.

**Step 12: Semicolon and Colon Usage**
Master semicolon and colon usage. Semicolons connect related independent clauses. Colons introduce lists, explanations, or expansions. Misuse of these punctuation marks is common in technical writing.

**Step 13: Dash and Hyphen Clarity**
Distinguish between em dashes (—, for parenthetical elements), en dashes (–, for ranges), and hyphens (-, for compound modifiers). Correct usage of these similar-looking marks improves professional appearance.

**Step 14: Punctuation Consistency**
Verify punctuation consistency throughout the report: serial comma usage, quotation mark style, period placement, and spacing. Consistency prevents distraction and signals professionalism.

### Phase 5: Sentence Structure Optimization

**Step 15: Active Voice Conversion**
Convert passive voice to active voice where appropriate. Active voice is clearer, more direct, and more engaging. "The server processes the input" is better than "Input is processed by the server."

**Step 16: Sentence Length Variation**
Vary sentence length to maintain reader engagement. Mix short, punchy sentences with longer, explanatory sentences. Avoid strings of similarly-sized sentences that create monotony.

**Step 17: Paragraph Structure**
Ensure each paragraph has a clear topic sentence, supporting details, and logical transition to the next paragraph. Paragraphs should be unified (one main idea) and coherent (logically organized).

**Step 18: Complex Sentence Simplification**
Simplify overly complex sentences. If a sentence requires re-reading for comprehension, break it into simpler structures. Technical complexity should be in the vulnerability, not the writing.

### Phase 6: Terminology and Style Consistency

**Step 19: Terminology Audit**
Audit your report for terminology consistency: vulnerability class names, technical terms, impact descriptions, and action verbs. Ensure each term is used consistently throughout.

**Step 20: Style Consistency Review**
Review style consistency: capitalization, formatting, abbreviation usage, and number formatting. Inconsistencies distract readers and suggest careless writing.

**Step 21: Audience-Appropriate Language Review**
Review language for audience appropriateness: technical depth, jargon usage, and complexity level. Ensure the language matches the expected triager's expertise.

**Step 22: Professional Tone Verification**
Verify professional tone throughout: no aggression, appropriate confidence, no unnecessary hedging, and consistent formality. Tone inconsistencies undermine credibility.

### Phase 7: Quality Verification

**Step 23: Automated Grammar Check**
Run the report through automated grammar checking tools. Address all flagged issues that are genuine errors. Do not blindly accept all suggestions.

**Step 24: Manual Proofreading**
Proofread manually after automated checking. Automated tools miss many errors, particularly: context-dependent errors, complex sentence structure issues, and style consistency problems.

**Step 25: Peer Grammar Review**
Have a peer review for grammar and style. External reviewers catch errors that you overlook in your own writing.

**Step 26: Final Polish**
Perform a final read-through specifically for grammar and style. This final pass catches any remaining errors before submission.

## Tool Arsenal

### Grammar Checking Tools
1. **Grammarly** - AI-powered grammar, style, and clarity checking
2. **ProWritingAid** - Deep style analysis and grammar checking
3. **Hemingway Editor** - Readability and simplicity analysis
4. **LanguageTool** - Open-source grammar and style checking
5. **Microsoft Editor** - Integrated writing assistance

### Readability Analysis Tools
6. **Readability Formula** - Multi-metric readability scoring
7. **Online-Utility.org Readability Test** - Quick readability check
8. **Readable.com** - Comprehensive readability analysis
9. **Thompson Readability Test** - Technical writing readability
10. **WebFX Readability Tool** - Multi-formula readability scoring

### Style Reference Materials
11. **Strunk & White's Elements of Style** - Classic writing reference
12. **Microsoft Style Guide** - Technical writing conventions
13. **Google Developer Documentation Style Guide** - Modern technical writing
14. **AP Stylebook** - Journalistic style reference
15. **Chicago Manual of Style** - Academic style reference

### Writing Assistance Tools
16. **Scrivener** - Long-form writing organization
17. **Ulysses** - Markdown-based writing tool
18. **iA Writer** - Distraction-free writing environment
19. **Typora** - Markdown editor with preview
20. **VS Code** - Code editor with Markdown support

### Proofreading Tools
21. **Text-to-speech** - Hearing errors that eyes miss
22. **Ruler technique** - Line-by-line reading aid
23. **Reverse reading** - Backward sentence checking
24. **Print review** - Paper-based proofreading
25. **Time-delay review** - Fresh perspective proofreading

### Style Consistency Tools
26. **Terminology databases** - Consistent term usage
27. **Style guide templates** - Documented conventions
28. **Consistency checkers** - Automated consistency verification
29. **Glossary tools** - Technical term definitions
30. **Abbreviation managers** - Consistent abbreviation usage

### Writing Process Tools
31. **Pomodoro timers** - Writing session management
32. **Distraction blockers** - Focus enhancement
33. **Writing templates** - Structured drafting
34. **Version control** - Writing revision tracking
35. **Backup systems** - Writing preservation

### Learning Resources
36. **Grammar Girl** - Grammar tips and explanations
37. **Purdue OWL** - Comprehensive writing guide
38. **Grammarly Blog** - Writing improvement articles
39. **Copyblogger** - Content writing resources
40. **Writing communities** - Peer learning and support

## Case Studies

### Case Study 1: Comma Splice Elimination

**Context:** A researcher's reports consistently contained comma splices: two independent clauses joined by a comma without a conjunction. Example: "The vulnerability allows data access, the server does not validate input."

**Analysis:** The researcher identified comma splices as their most frequent grammar error through analysis of 10 reports. Comma splices appeared in 60% of reports, averaging 2 per report.

**Improvement:** The researcher added a comma splice check to their editing process: after drafting, specifically review every comma to verify it is not joining independent clauses. Alternative constructions: semicolons, period separation, or conjunction addition.

**Outcome:** Comma splices dropped to zero in subsequent reports. The specific, targeted prevention was far more effective than general grammar review.

### Case Study 2: Active Voice Transformation

**Context:** A researcher's reports were written predominantly in passive voice: "The input is processed by the server, user data is returned in the response." This construction was wordy and unclear.

**Analysis:** Passive voice appeared in 70% of sentences. The passive constructions obscured who performed each action and made reproduction steps harder to follow.

**Improvement:** The researcher implemented a rule: convert all passive voice to active voice unless the actor is unknown or unimportant. They added an active voice check to their editing process.

**Outcome:** Active voice usage increased to 80% of sentences. Reports became clearer, more direct, and easier to follow. Triage times decreased.

### Case Study 3: Terminology Consistency Fix

**Context:** A researcher used inconsistent terminology for the same concepts: "endpoint" in one place, "API" in another, "route" in a third. This inconsistency confused triagers.

**Analysis:** Terminology inconsistency appeared across all vulnerability classes. The researcher used whichever term came to mind first rather than maintaining consistency.

**Improvement:** The researcher created a terminology glossary defining preferred terms for common concepts: endpoint (not API or route), vulnerability (not flaw or issue), impact (not consequence or result).

**Outcome:** Terminology consistency improved across all reports. Follow-up questions about terminology decreased.

### Case Study 4: Punctuation Precision Improvement

**Context:** A researcher misused semicolons and colons throughout their reports. Semicolons were used where colons were needed, and vice versa.

**Analysis:** The researcher did not understand the difference: semicolons connect related independent clauses, colons introduce lists or explanations. This confusion led to consistent punctuation errors.

**Improvement:** The researcher studied semicolon and colon rules, created a reference card, and added specific checks to their editing process: after every semicolon, verify it connects independent clauses; after every colon, verify it introduces a list or explanation.

**Outcome:** Semicolon and colon usage became correct and consistent. The reports looked more professional.

### Case Study 5: Readability Optimization

**Context:** A researcher's reports had high readability scores (Flesch-Kincaid grade level 18+), meaning they required post-graduate education to understand. This complexity slowed triage and caused confusion.

**Analysis:** The high readability scores resulted from: long sentences, complex vocabulary, and dense paragraph structure. The researcher wrote for themselves rather than their audience.

**Improvement:** The researcher simplified their writing: shorter sentences, simpler vocabulary, and shorter paragraphs. They used the Hemingway Editor to identify and simplify complex sentences.

**Outcome:** Readability scores dropped to grade 12-14, appropriate for technical audiences. Reports were processed faster and with fewer questions.

### Case Study 6: Its vs. It's Error Prevention

**Context:** A researcher consistently confused "its" (possessive) and "it's" (contraction of "it is"). This common error appeared in almost every report.

**Analysis:** The researcher knew the rule intellectually but applied it incorrectly under writing pressure. The error was automatic rather than knowledge-based.

**Improvement:** The researcher developed a mental check: every time they typed "its" or "it's," pause and expand to "it is." If "it is" makes sense, use "it's." If not, use "its." They added this check to their grammar review process.

**Outcome:** The its/it's error dropped to zero. The targeted mental check addressed the automatic error pattern.

### Case Study 7: Parallel Structure Correction

**Context:** A researcher's lists and series lacked parallel structure: "The vulnerability allows accessing user data, modification of records, and can delete entries." The list items had inconsistent grammatical forms.

**Analysis:** Parallel structure violations appeared in every report with lists. The researcher wrote list items as they came to mind without checking structural consistency.

**Improvement:** The researcher reviewed parallel structure rules and added a checklist item: verify all list items use the same grammatical form (all gerunds, all nouns, all verb phrases).

**Outcome:** Lists became parallel and professional. The consistency improved readability and reduced cognitive friction.

### Case Study 8: Hedging Language Elimination

**Context:** A researcher's reports contained excessive hedging: "It might be possible that this could potentially allow access to..." This hedging undermined severity assessments.

**Analysis:** Hedging appeared in impact statements and severity justifications. The researcher hedged to avoid being wrong, but the hedging made findings seem less severe.

**Improvement:** The researcher implemented a rule: remove all hedging phrases unless uncertainty is genuine. "It might be possible" becomes "it allows." "Could potentially" becomes "can." "It seems like" becomes "the evidence shows."

**Outcome:** Hedging dropped by 90%. Reports conveyed confidence and severity ratings aligned more closely with assessments.

### Case Study 9: Tense Consistency Achievement

**Context:** A researcher's reports shifted tenses inconsistently: "The server processes the input (present). I then observed the response (past). The vulnerability allows data access (present)." This inconsistency confused readers.

**Analysis:** Tense inconsistency resulted from: writing sections at different times, mixing description with narration, and not having a tense strategy.

**Improvement:** The researcher adopted a tense convention: present tense for descriptions of current behavior ("the server allows"), past tense for actions taken during testing ("I navigated to"), and present tense for impact statements ("this affects").

**Outcome:** Tense usage became consistent throughout reports. The consistency improved readability and professionalism.

### Case Study 10: Sentence Length Optimization

**Context:** A researcher's reports contained very long sentences (50+ words) that required multiple readings to understand. These sentences obscured the vulnerability description.

**Analysis:** Long sentences resulted from: trying to include all related information in one sentence, fear of oversimplification, and writing stream-of-consciousness.

**Improvement:** The researcher implemented a rule: no sentence should exceed 25 words. If a sentence exceeds this limit, break it into multiple sentences. They used the Hemingway Editor to identify long sentences.

**Outcome:** Sentence length decreased to an average of 15-20 words. Reports became clearer and easier to follow. Triage times decreased.

## Advanced Techniques

### Sentence Pattern Variation

Vary sentence patterns to maintain reader engagement: declarative sentences for facts, interrogative sentences for questions (sparingly), imperative sentences for instructions, and exclamatory sentences (very rarely) for emphasis. Pattern variation prevents monotony and improves readability.

### Cohesive Device Mastery

Master cohesive devices that create flow between sentences and paragraphs: transition words (however, therefore, additionally), pronoun reference (this, that, these), repetition for emphasis, and synonyms for variety. Cohesive devices create professional, flowing text.

### Emphasis Techniques

Use emphasis techniques strategically: sentence position (beginning and end positions are strongest), punctuation (dashes, colons, and italics for emphasis), word choice (strong verbs over weak verbs), and repetition (repeating key terms for emphasis). Emphasis techniques guide reader attention to important information.

### Conciseness Optimization

Eliminate unnecessary words without sacrificing meaning. Concise writing is more impactful and easier to read. Common wordy constructions: "due to the fact that" (because), "in order to" (to), "at this point in time" (now), "in the event that" (if).

### Voice and Tone Calibration

Calibrate voice and tone for different report sections: factual tone for reproduction steps, analytical tone for impact assessment, prescriptive tone for remediation guidance, and confident tone for severity justification. Voice variation serves different purposes while maintaining overall professionalism.

### Metaphor and Analogy Use

Appropriate metaphors and analogies clarify complex concepts. "The CORS configuration is like leaving the front door unlocked while locking individual rooms" makes the misconfiguration accessible. Use metaphors sparingly and only when they genuinely aid understanding.

### Parallel Construction for Impact

Use parallel construction for emphasis and clarity: "The vulnerability allows an attacker to: extract user data, modify records, and delete accounts." Parallel construction creates rhythm and makes lists memorable.

## Detection

### Grammar Self-Assessment Checklist
1. Subject-verb agreement correct throughout
2. Pronoun reference clear and unambiguous
3. Tense consistent within sections
4. Comma usage correct (no comma splices)
5. Semicolon and colon usage correct
6. Parallel structure in all lists
7. Active voice predominant
8. No dangling or misplaced modifiers
9. No wordiness or redundancy
10. No commonly confused word errors

### Style Self-Assessment Checklist
1. Capitalization consistent
2. Number formatting consistent
3. Abbreviation usage consistent
4. Terminology consistent throughout
5. Tone appropriate and consistent
6. Audience-appropriate language
7. Formatting consistent
8. Professional presentation
9. Readability appropriate for audience
10. No unnecessary jargon

### Error Pattern Recognition
Track your most common errors: grammar, punctuation, style, and usage. Develop targeted prevention for each pattern. Monitor error rates over time to verify improvement.

## Impact

### Credibility Improvement
Eliminating grammar and style errors significantly improves report credibility. Professional presentation builds trust with triagers and supports severity assessments.

### Triage Speed
Clear, correct writing accelerates triage. Triagers process well-written reports faster, reducing time to resolution and payment.

### Follow-Up Reduction
Clear writing reduces follow-up questions. When the report communicates effectively, triagers need less clarification.

### Reputation Building
Consistent grammar and style quality builds researcher reputation. Programs notice quality writing and reward it through favorable assessments.

## Pitfalls

### Pitfall 1: Grammar Obsession
Obsessing over grammar at the expense of technical content is counterproductive. Grammar supports content; it does not replace it.

### Pitfall 2: Style Rigidity
Following style rules rigidly without considering context produces awkward writing. Style rules serve clarity, not dogma.

### Pitfall 3: Automated Tool Over-Reliance
Relying solely on automated grammar tools misses many errors. Automated tools support but do not replace human review.

### Pitfall 4: Ignoring Audience
Writing at an inappropriate level for the audience reduces comprehension. Match language to audience expertise.

### Pitfall 5: Inconsistency
Inconsistent style within a report distracts readers. Consistency is a hallmark of professional writing.

### Pitfall 6: Over-Simplification
Simplifying to the point of losing technical accuracy is harmful. Balance clarity with precision.

### Pitfall 7: Perfectionism Paralysis
Spending excessive time on grammar prevents submission. Aim for quality, not perfection.

### Pitfall 8: Copy-Paste Errors
Copying text from previous reports without adapting it creates inconsistency and errors. Always adapt copied text.

### Pitfall 9: Proofreading Fatigue
Proofreading while fatigued misses errors. Take breaks during proofreading.

### Pitfall 10: Feedback Ignorance
Ignoring grammar feedback from triagers or peers prevents improvement. Incorporate feedback into your style guide.

## Integration

### With Report Writing
Grammar and style standards should be integrated into the writing process from the first draft. Write with standards in mind, not as an afterthought.

### With Template Development
Templates should encode grammar and style standards: required sentence structures, terminology choices, and formatting conventions.

### With Quality Assurance
Grammar and style checking should be a specific, systematic part of the QA process. Dedicated grammar review catches errors that general review misses.

### With Peer Review
Grammar and style review should be a specific peer review criterion. Peers catch grammar errors that you overlook in your own writing.

### With Severity Assessment
Grammar and style quality affects severity perception. Well-written reports support higher severity assessments.

## Reporting

### Grammar Metrics to Track
- Error rate per report (by type)
- Readability score trends
- Style consistency ratings
- Follow-up questions related to clarity
- Triage time relative to report quality

### Documentation Standards
Maintain a grammar and style knowledge base: common errors, prevention strategies, and style conventions. This documentation supports consistent quality improvement.

### Continuous Improvement
Review grammar and style metrics monthly. Update style guide based on new learnings. Maintain grammar quality over time.

## Labs

### Lab 1: Error Pattern Analysis
Analyze your last 10 reports for grammar errors. Identify your top 3 error patterns. Develop targeted prevention strategies for each.

### Lab 2: Style Guide Creation
Create a personal style guide covering: capitalization, punctuation, terminology, formatting, and tone. Test it on 5 reports.

### Lab 3: Active Voice Conversion
Take a report written in passive voice and convert it to active voice. Compare readability and clarity before and after.

### Lab 4: Readability Optimization
Run your reports through readability tools. Identify complex sentences and simplify them. Measure readability improvement.

### Lab 5: Punctuation Mastery
Study semicolon, colon, and dash rules. Practice using them correctly in 5 reports. Verify correct usage.

### Lab 6: Terminology Consistency Audit
Audit a report for terminology consistency. Create a terminology glossary. Verify consistency in subsequent reports.

### Lab 7: Peer Grammar Review
Exchange reports with a peer for grammar review. Identify errors you missed. Incorporate findings into your review process.

### Lab 8: Proofreading Technique Practice
Practice proofreading techniques: text-to-speech, ruler technique, reverse reading. Identify which techniques catch the most errors for you.

## Ethics

### Honest Communication
Grammar and style should enhance clarity, not obscure meaning. Do not use complex language to sound more authoritative than warranted.

### Accessibility
Write clearly to make reports accessible to all triagers, including non-native English speakers. Clarity is not dumbing down; it is respectful communication.

### Professional Standards
Maintain professional grammar and style standards even when programs do not explicitly require them. Quality writing reflects on you and the bug bounty community.

### Continuous Improvement
Commit to continuous grammar and style improvement as a professional ethic. Writing quality is a skill that benefits your entire career.

### Community Contribution
Share grammar and style best practices with the community. Writing quality benefits all researchers and programs.

## Cheat Sheet

### Top Grammar Rules for Bug Bounty
1. Subject-verb agreement: "The vulnerability allows" not "The vulnerability allow"
2. Active voice: "I found" not "It was found"
3. Parallel structure: all list items same form
4. No comma splices: use semicolons or periods
5. Clear pronoun reference: "The vulnerability" not "It"
6. Consistent tense: present for description, past for actions
7. Serial commas: include them always
8. No dangling modifiers: "Testing the endpoint, I found..." not "Testing the endpoint, the vulnerability was found"

### Commonly Confused Words
| Correct | Incorrect | Rule |
|---------|-----------|------|
| its (possessive) | it's | "it's" = "it is" |
| affect (verb) | effect (noun) | Affect = influence, Effect = result |
| then (time) | than (comparison) | Then = next, Than = compared to |
| their (possessive) | there (location) | Their = belongs to them |
| which (non-restrictive) | that (restrictive) | Which adds info, that defines |

### Readability Targets
- General audience: Grade 10-12
- Technical audience: Grade 12-16
- Mixed audience: Grade 8-10
- Flesch reading ease: 50-70

### Quick Proofreading Checklist
- [ ] Read aloud for flow
- [ ] Check subject-verb agreement
- [ ] Verify tense consistency
- [ ] Review comma usage
- [ ] Check pronoun reference
- [ ] Verify parallel structure
- [ ] Confirm active voice
- [ ] Review terminology consistency
- [ ] Check formatting consistency
- [ ] Final read-through
