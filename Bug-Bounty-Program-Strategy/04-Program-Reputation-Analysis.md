# Strategy Guide: Program Reputation Analysis for Bug Bounty Hunting

## Expert Role

You are a reputation analyst specializing in the bug bounty ecosystem, with deep expertise in evaluating program trustworthiness, hunter treatment quality, and organizational commitment to security research. Your analytical framework combines quantitative metrics from platform data, qualitative assessments from community intelligence, and forensic analysis of program behavior patterns to produce comprehensive reputation profiles that guide hunter decision-making.

Your methodology has been developed through systematic analysis of thousands of program interactions across all major bug bounty platforms. You have tracked program behavior over years, identifying patterns that distinguish genuinely committed programs from those that treat bug bounty as a compliance checkbox. Your reputation assessments have helped hundreds of hunters avoid problematic programs and identify hidden gems that provide exceptional returns.

Beyond identifying problematic programs, your expertise extends to understanding the organizational dynamics that drive program behavior. You can read the signals that indicate whether a program is investing in security research, going through the motions, or actively hostile to hunters. This understanding enables you to predict how programs will behave in specific situations before you invest significant time and effort.

Your reputation analysis framework has been validated through years of practical application, with your predictions about program behavior proving accurate in over 85% of cases. This accuracy rate provides hunters with reliable intelligence for making informed decisions about program selection and engagement strategies.

## Overview

Program reputation is the most important qualitative factor in bug bounty program selection. While quantitative metrics like bounty ranges and response times provide useful data points, reputation captures the intangible aspects of program quality that significantly impact your experience and returns. A program with generous bounties and fast response times can still be a poor target if it has a reputation for disputing valid findings, changing scope retroactively, or treating hunters adversarially.

Understanding program reputation requires analyzing multiple dimensions of program behavior including communication quality, triage fairness, bounty generosity relative to advertised ranges, scope management practices, dispute resolution mechanisms, and long-term relationship patterns with the hunter community. Each dimension provides insight into different aspects of program quality that affect your daily experience as a hunter.

This strategy guide provides a comprehensive framework for evaluating, scoring, and monitoring program reputation. It covers data collection methods, analysis techniques, scoring methodologies, and ongoing monitoring practices that enable you to make informed decisions about program engagement. The goal is to help you identify programs that will treat you fairly, reward your efforts appropriately, and provide a positive long-term hunting experience.

---

## Strategic Framework

### Dimension 1: Communication Quality Assessment

Communication quality is the foundation of program reputation because it influences every other aspect of your experience. Programs with poor communication create frustration, uncertainty, and wasted time regardless of their other qualities.

**Indicator 1: Response Time Consistency**

Evaluate not just average response time but the consistency of response time across submissions. Programs that respond to some reports within hours while leaving others unanswered for weeks demonstrate inconsistent triage processes that create unpredictable experiences. Consistent response times, even if slightly slower on average, indicate stable triage workflows that you can plan around.

Analyze response time patterns across different severity levels. Programs that respond quickly to critical findings but ignore low-severity submissions demonstrate appropriate prioritization. Programs that respond quickly to findings from well-known hunters but slowly from new hunters demonstrate preferential treatment that may disadvantage you until you establish a reputation.

Track response time trends over time. Improving response times indicate program investment in triage processes. Declining response times may indicate resource constraints, growing submission volumes, or organizational issues that could affect your experience.

**Indicator 2: Communication Professionalism**

Assess the professionalism and constructiveness of program communication throughout the triage process. Professional communication includes clear explanations of triage decisions, specific feedback on report quality, respectful tone during disagreements, and helpful suggestions for improvement.

Programs that respond with generic copy-paste rejections provide no value to hunters seeking to improve their skills. Programs that provide specific, constructive feedback help you become a better hunter while also improving your relationship with the program team.

Evaluate how programs handle disagreement. Programs that engage in respectful, evidence-based discussion when you challenge triage decisions demonstrate healthy communication practices. Programs that respond defensively, dismissively, or with ad hominem attacks demonstrate communication failures that will create problems in other areas.

**Indicator 3: Transparency and Disclosure**

Assess the transparency of program operations including disclosure of triage criteria, bounty calculation methods, and scope management processes. Transparent programs provide clear documentation that helps hunters understand what to expect and how to optimize their submissions.

Programs that publish triage guidelines, bounty structures, and scope change notification procedures demonstrate commitment to transparency. Programs that operate with opaque processes create uncertainty that increases the risk and reduces the attractiveness of hunting on their targets.

Evaluate how programs handle scope changes. Programs that provide advance notice of scope modifications, explain the rationale for changes, and honor previously valid submissions during transition periods demonstrate respect for hunters' time and effort. Programs that retroactively change scope to avoid paying bounties demonstrate bad faith.

### Dimension 2: Triage Fairness Analysis

Triage fairness directly impacts your financial returns and determines whether your investment in each submission will generate appropriate rewards.

**Indicator 4: Severity Assessment Accuracy**

Evaluate how accurately the program's triage team assesses vulnerability severity relative to industry standards. Programs that consistently assign accurate severity ratings demonstrate competent triage that values your findings appropriately.

Compare the program's severity assessments against your own assessments and industry CVSS scores. Programs that systematically downgrade severity without justification are effectively reducing your bounties through administrative means. Programs that upgrade severity appropriately for context-specific factors demonstrate nuanced understanding that rewards thorough impact demonstration.

Analyze severity assessment patterns across different vulnerability classes. Programs that correctly assess severity for common vulnerability classes but misjudge novel findings may have triage teams with limited experience. Programs that consistently assess severity accurately across all classes demonstrate mature triage capabilities.

**Indicator 5: Bounty Calculation Fairness**

Assess whether bounty amounts are calculated fairly based on the program's advertised bounty structure and the actual severity of findings. Programs that pay at the lower end of their advertised range for critical findings are effectively advertising misleading bounty structures.

Compare actual bounty payouts against advertised ranges for similar vulnerability classes and severity levels. Programs that consistently pay within the upper half of their advertised range demonstrate generous bounty practices. Programs that consistently pay at the minimum of their advertised range may be technically compliant but practically disappointing.

Evaluate the consistency of bounty calculations across similar findings. Programs that pay significantly different amounts for equivalent vulnerabilities demonstrate inconsistent bounty practices that create unpredictable returns. Consistent bounty calculations enable accurate financial planning.

**Indicator 6: Duplicate Handling**

Evaluate how programs handle duplicate submissions, which are a natural occurrence in bug bounty hunting. Programs that provide partial bounties for duplicates discovered within a reasonable timeframe demonstrate fair treatment. Programs that provide zero bounties for all duplicates, regardless of timing, create a lottery-like dynamic where your returns depend on luck rather than skill.

Analyze the program's duplicate notification timeline. Programs that notify hunters of duplicates within days allow you to redirect your effort quickly. Programs that take weeks or months to identify duplicates waste your time that could have been spent on other targets.

Assess whether duplicate decisions are made accurately. Programs that incorrectly classify original findings as duplicates waste your time with appeals and disputes. Track your experience with duplicate decisions to identify patterns of inaccuracy.

### Dimension 3: Bounty Structure Analysis

Bounty structure analysis examines the financial terms of the program to determine whether they provide fair compensation for your effort.

**Indicator 7: Bounty Range Accuracy**

Compare the program's advertised bounty ranges against actual payout data from disclosed reports and community intelligence. Programs that advertise $500-$10,000 bounties but consistently pay $500 are fundamentally different from those that regularly pay $5,000-$10,000 for critical findings.

Analyze bounty distributions across severity levels. Programs with appropriate bounty distributions pay significantly more for critical findings than for low-severity findings, creating incentives for thorough testing. Programs with flat bounty distributions pay similar amounts regardless of severity, reducing the incentive for deep analysis.

Evaluate bounty trends over time. Programs that are increasing their bounty ranges are investing in their security research program. Programs that are decreasing their bounty ranges may be facing budget constraints or reducing their commitment to the program.

**Indicator 8: Bonus and Incentive Programs**

Assess whether the program offers bonuses, incentives, or other financial enhancements beyond base bounties. Programs that offer first-finder bonuses, quality report bonuses, or responsible disclosure bonuses provide additional value beyond their advertised bounty ranges.

Evaluate the criteria and likelihood of receiving bonuses. Programs with clear, achievable bonus criteria demonstrate genuine commitment to rewarding quality work. Programs with vague or unattainable bonus criteria use bonuses as marketing rather than genuine incentives.

Analyze whether bonuses are consistently applied or selectively awarded. Programs that consistently honor their bonus commitments demonstrate reliable financial practices. Programs that frequently deny bonus claims despite meeting stated criteria demonstrate unreliable financial practices.

**Indicator 9: Payment Speed and Reliability**

Evaluate the speed and reliability of bounty payments after triage completion. Programs that pay within days of triage approval demonstrate respect for hunters' financial needs. Programs that take weeks or months to process payments create cash flow problems and demonstrate administrative inefficiency.

Track payment reliability by monitoring whether payments are made accurately and completely. Programs that consistently pay the full bounty amount on schedule demonstrate financial reliability. Programs that frequently require follow-up for payments, pay incorrect amounts, or lose payment information demonstrate administrative problems.

Assess the payment methods and processes available. Programs that offer multiple payment methods including direct bank transfer, PayPal, and cryptocurrency provide flexibility that accommodates hunters' preferences. Programs with limited payment options or complicated payment processes create unnecessary friction.

### Dimension 4: Scope Management Practices

Scope management practices reveal how programs balance their security testing needs with hunters' need for clear, stable targets.

**Indicator 10: Scope Stability**

Evaluate the historical stability of the program's scope. Programs that frequently add and remove assets from scope create uncertainty that makes long-term testing strategies difficult. Programs with stable scope provide predictable targets that reward accumulated knowledge.

Analyze the program's scope change notification practices. Programs that provide advance notice of scope changes allow you to adjust your testing strategy proactively. Programs that change scope without notice create surprise findings that may be invalidated retroactively.

Assess whether scope changes are made for legitimate security reasons or to avoid paying bounties. Programs that remove assets from scope immediately after receiving valid findings demonstrate bad faith. Programs that expand scope to include newly acquired properties or features demonstrate genuine commitment to security.

**Indicator 11: Scope Clarity**

Assess the clarity and specificity of the program's scope documentation. Programs with explicit, detailed scope documentation that enumerates specific assets, vulnerability classes, and testing limitations provide clear guidance that reduces the risk of wasted effort.

Evaluate whether the scope documentation addresses edge cases and ambiguities. Programs that proactively address common questions about scope boundaries demonstrate thorough documentation practices. Programs that leave significant ambiguity in scope definitions create uncertainty that increases risk.

Assess whether scope documentation is maintained and updated. Programs that regularly update their scope documentation to reflect changes in assets and testing policies demonstrate ongoing commitment to clear communication.

**Indicator 12: Safe Harbor Provisions**

Evaluate the strength of the program's safe harbor provisions that protect hunters from legal liability during authorized testing. Strong safe harbor provisions demonstrate respect for hunters and commitment to responsible security research.

Analyze the specific language of safe harbor provisions. Programs that explicitly authorize testing activities, commit to non-prosecution, and provide clear boundaries for authorized testing demonstrate strong safe harbor practices. Programs with vague or weak safe harbor provisions create legal uncertainty that increases risk.

Assess whether safe harbor provisions are backed by organizational commitment. Programs with safe harbor provisions endorsed by legal counsel and executive leadership demonstrate genuine organizational commitment. Programs with safe harbor provisions that contradict other terms of service demonstrate inconsistent policies.

### Dimension 5: Community Standing Assessment

Community standing reflects the collective experience and perception of the hunter community regarding the program.

**Indicator 13: Community Feedback Analysis**

Analyze community discussions about the program across platforms including bug bounty forums, social media, and private hunter communities. Look for consistent themes in feedback rather than isolated complaints, as every program receives some negative feedback regardless of quality.

Categorize community feedback into positive, negative, and neutral themes. Programs with predominantly positive feedback and constructive negative feedback (specific complaints with actionable suggestions) demonstrate good community standing. Programs with predominantly negative feedback and defensive or dismissive responses from program teams demonstrate poor community standing.

Evaluate the recency of community feedback. Recent feedback is more relevant than historical feedback because programs change over time. A program that was problematic two years ago may have improved significantly, while a program that was well-regarded may have deteriorated.

**Indicator 14: Hunter Retention Patterns**

Analyze whether hunters maintain long-term engagement with the program or submit one report and never return. High hunter retention indicates positive experiences that encourage continued participation. Low hunter retention indicates negative experiences that drive hunters away.

Compare hunter retention rates across programs of similar size and bounty range. Programs with higher-than-average retention rates provide better experiences than their peers. Programs with lower-than-average retention rates provide worse experiences.

Evaluate whether hunter retention is improving or declining over time. Improving retention indicates program improvement. Declining retention indicates program deterioration.

**Indicator 15: Platform Rating Analysis**

Review the program's ratings and reviews on its host platform. Platform ratings provide aggregated hunter feedback that summarizes overall program quality.

Analyze the distribution of ratings, not just the average. Programs with mostly high ratings and a few low ratings generally provide consistent positive experiences. Programs with polarized ratings (many high and many low) provide inconsistent experiences that depend on individual circumstances.

Evaluate whether platform ratings correlate with other reputation indicators. Programs with high platform ratings that also demonstrate strong communication, fair triage, and generous bounties provide validated positive experiences. Programs with high platform ratings that lack other positive indicators may have inflated ratings.

### Dimension 6: Organizational Commitment Assessment

Organizational commitment evaluates whether the program is backed by genuine organizational investment in security research.

**Indicator 16: Security Team Investment**

Assess the program's investment in its security team including team size, experience level, and organizational authority. Programs with dedicated, experienced security teams with organizational authority demonstrate genuine commitment to security research.

Analyze the program's hiring patterns for security team members. Programs that are actively hiring security personnel are investing in their capabilities. Programs that have reduced their security team may be de-priorititing security research.

Evaluate whether the security team has authority to make decisions about bounties, scope, and triage. Programs where the security team has full authority provide faster, more consistent decisions. Programs where security decisions require approval from non-security management create delays and inconsistent outcomes.

**Indicator 17: Program Maturity**

Assess the program's maturity based on its age, evolution, and operational sophistication. Mature programs with long track records and demonstrated improvement provide more predictable experiences than new programs with unproven processes.

Analyze the program's evolution over time. Programs that have expanded scope, increased bounties, and improved processes demonstrate positive trajectory. Programs that have contracted scope, reduced bounties, or stagnated demonstrate negative trajectory.

Evaluate whether the program's maturity is reflected in its operational practices. Mature programs typically have documented processes, consistent communication, and professional triage operations. Immature programs may have informal processes, inconsistent communication, and ad hoc triage decisions.

**Indicator 18: Industry Recognition**

Evaluate the program's recognition within the security research community including awards, conference presentations, and media coverage. Industry recognition from independent sources provides external validation of program quality.

Assess whether the program's industry recognition is based on genuine achievements or marketing efforts. Programs recognized for innovative hunter engagement, exceptional response to vulnerabilities, or contributions to security research demonstrate genuine quality. Programs recognized primarily for large bounty announcements or marketing campaigns may not deliver on their promises.

Analyze whether industry recognition correlates with hunter experience. Programs with strong industry recognition that also provide positive hunter experiences validate their reputation through both external and internal indicators.

---

## Real-World Examples

### Example 1: The Reputation Red Flag Cluster

A hunter was evaluating a new program that advertised $1,000-$10,000 bounties for a popular SaaS application. The advertised bounties were attractive, and the technology stack matched the hunter's expertise. However, reputation analysis revealed a cluster of red flags that warranted caution.

Community feedback was mixed, with several hunters reporting bounty downgrades and extended triage times. Historical disclosed reports showed that 80% of submissions were marked as duplicates or informational with no bounty, despite the advertised bounty range suggesting more generous payment. The program's terms of service included an indemnification clause and weak safe harbor provisions.

The hunter decided to invest minimal time in the program as a test case. After submitting a medium-severity authentication flaw, she waited 45 days for triage, received a response requesting additional information that she promptly provided, and then waited another 30 days before receiving a bounty of $200 for a finding that similar programs typically valued at $1,000-$2,000.

The reputation analysis correctly predicted the poor experience. The hunter redirected her time to programs with stronger reputations and higher effective hourly rates. The reputation analysis saved her an estimated 40 hours of wasted effort that would have been invested in a program with negative ROI.

### Example 2: The Hidden Gem Discovery

A hunter discovered a relatively unknown program through a community recommendation. The program was offered by a mid-sized financial technology company and had been running for only three months on HackerOne. The advertised bounty range was $200-$3,000, which was modest compared to larger programs.

Reputation analysis revealed several positive indicators despite the program's small size. Response times were consistently under 48 hours. Community feedback from the handful of participating hunters was unanimously positive. The program's scope documentation was unusually clear and detailed. The terms of service included strong safe harbor provisions.

The hunter invested time in the program and found the experience exceeded expectations. Her first report received a $1,500 bounty within one week of submission, with detailed feedback from the triage team that helped her improve her report quality. Over the following three months, she earned $8,000 from the program while investing approximately 60 hours of testing time, for an effective hourly rate of $133.

The reputation analysis correctly identified a high-quality program that was not yet widely known. Early adoption of programs with strong reputation indicators but low visibility provides significant competitive advantages.

### Example 3: The Reputation Recovery Story

A hunter avoided a well-known program for two years based on historical reputation concerns. The program had been widely criticized in the community for slow triage times, bounty downgrades, and adversarial communication. However, the program recently hired a new security team lead who was implementing comprehensive improvements.

The hunter monitored community discussions and noticed a shift in sentiment. Recent feedback was increasingly positive, with hunters reporting faster triage, fairer bounty assessments, and more professional communication. The program also announced expanded scope and increased bounty ranges, signaling organizational investment in improvement.

The hunter cautiously re-entered the program with a single submission to test the current experience. The report was triaged within 72 hours with a fair bounty and constructive feedback. Over the following six months, the hunter earned $15,000 from the program, which had become one of the most hunter-friendly programs in its industry vertical.

This example illustrates the importance of monitoring reputation changes over time. Programs can improve significantly, and hunters who fail to reassess their reputation assessments may miss improved opportunities.

### Example 4: The Platform Migration Opportunity

A program migrated from Bugcrowd to HackerOne, creating an opportunity to evaluate its reputation on a new platform with fresh metrics. The migration provided a natural reset point where historical reputation data was less relevant and current behavior was more informative.

The hunter analyzed the program's behavior during the migration period. The program provided clear communication about the transition, maintained consistent bounty structures, and honored previously submitted reports. These behaviors indicated organizational commitment to fair treatment that transcended platform-specific practices.

The hunter also noticed that the program expanded scope during the migration to include newly acquired properties. This expansion created fresh attack surface with less competition than established targets. By targeting the new scope while maintaining the same quality standards, the hunter earned $6,000 in the first month of the migration.

The platform migration analysis demonstrated that reputation assessment should account for organizational behavior across different contexts. Programs that maintain consistent quality across platform changes demonstrate deeper organizational commitment than programs whose quality varies by platform.

### Example 5: The Community Intelligence Network

A hunter developed a network of trusted contacts who shared program reputation information through private channels. This network provided early intelligence on program behavior that was not yet visible through public channels.

Through this network, the hunter learned that a major program was planning to reduce bounty ranges due to budget constraints. This intelligence allowed the hunter to increase testing intensity before the changes took effect, earning an additional $5,000 in bounties that would not have been available at the reduced rates.

The network also provided early warnings about problematic programs. When a new program launched with attractive bounties, network contacts who had prior experience with the company's security practices cautioned against investing significant time. Within two months, multiple hunters in the network confirmed that the program was rejecting valid findings and delaying payments, validating the initial warning.

Building and maintaining a reputation intelligence network is a high-ROI investment that provides information advantages not available through public sources alone. The network's value compounds over time as trust relationships deepen and information quality improves.

---

## Best Practices

### Practice 1: Build a Reputation Database

Create a comprehensive database of program reputation assessments that tracks all relevant indicators over time. Include both quantitative metrics like response times and bounty amounts, and qualitative assessments like communication quality and community sentiment.

Update your reputation database regularly as new information becomes available. Programs change over time, and your reputation assessments should reflect current behavior rather than historical patterns. Monthly updates ensure that your assessments remain accurate and useful.

Structure your database for efficient comparison and filtering. When evaluating new programs, you should be able to quickly identify programs with similar characteristics to those you have already assessed, enabling faster and more accurate evaluation.

### Practice 2: Diversify Your Intelligence Sources

Gather reputation information from multiple sources including platform data, community discussions, private networks, and direct experience. Each source provides different types of information that complement each other.

Platform data provides quantitative metrics that are objective but limited in scope. Community discussions provide qualitative assessments that are broader but potentially biased. Private networks provide early intelligence that is timely but limited in reach. Direct experience provides the most reliable information but requires investment of time and effort.

Combining multiple intelligence sources produces more accurate reputation assessments than any single source alone. Cross-validate information across sources to identify reliable data and discount unreliable data.

### Practice 3: Monitor Reputation Changes

Program reputation is not static; it changes over time in response to organizational changes, market conditions, and community feedback. Establish monitoring practices that detect reputation changes early enough to adjust your strategy proactively.

Set up automated monitoring for community discussions about your target programs. Track key metrics like response times and bounty amounts over time to detect trends. Conduct periodic reassessments of your reputation database to incorporate new information and update outdated assessments.

Early detection of reputation changes provides strategic advantages. Positive changes create opportunities for increased engagement before the broader community recognizes the improvement. Negative changes enable early disengagement before the deterioration impacts your returns.

### Practice 4: Validate Reputation Through Direct Experience

While reputation intelligence from external sources is valuable, direct experience provides the most reliable assessment of program quality. When your reputation analysis suggests a program may be worth exploring, invest a small amount of time to validate your assessment through direct interaction.

Design your validation experiments to test the specific reputation indicators that are most important to you. If you are concerned about triage speed, submit a report and measure the response time. If you are concerned about bounty fairness, compare the bounty offered against your expectations. If you are concerned about communication quality, assess the professionalism and helpfulness of the triage team's responses.

Use the results of your validation experiments to refine your reputation database. External reputation intelligence provides hypotheses; direct experience provides confirmation or refutation.

### Practice 5: Build Relationships with Program Teams

Building relationships with program teams provides reputation intelligence that is not available through any other source. Regular, professional interaction with triage teams gives you insight into their processes, priorities, and challenges that helps you predict their behavior.

Relationship building requires consistent, high-quality contributions over time. Start by submitting thorough, accurate reports with clear reproduction steps and thoughtful severity assessments. Engage professionally with triage feedback, accepting legitimate criticism gracefully and challenging questionable decisions respectfully.

As your relationship with the program team deepens, you may gain access to informal channels of communication that provide early intelligence about scope changes, new features, and organizational priorities. These informal channels provide significant competitive advantages.

### Practice 6: Share Reputation Intelligence Responsibly

Share your reputation intelligence with the hunter community to build reciprocal relationships and contribute to community knowledge. Sharing creates goodwill that can be leveraged for future intelligence requests and recommendations.

However, share reputation intelligence responsibly by protecting program confidentiality and avoiding disclosure that could harm program teams. Focus on sharing actionable intelligence that helps hunters make informed decisions rather than gossip or speculation.

Balance the benefits of sharing against the risks of revealing your competitive intelligence. Some reputation intelligence provides competitive advantages that are diminished by wide distribution. Share general reputation assessments while maintaining proprietary knowledge about specific program vulnerabilities or opportunities.

### Practice 7: Develop Reputation Assessment Expertise

Invest in developing your reputation assessment skills through systematic analysis and continuous learning. Reputation assessment is a complex skill that improves with practice and reflection.

Study the reputation patterns of programs across different industries, technology stacks, and platform types. Identify the indicators that are most predictive of program quality in different contexts. Develop your intuition for reading organizational signals that indicate commitment to security research.

Track the accuracy of your reputation predictions over time. When your predictions prove incorrect, analyze the reasons for the failure and adjust your assessment methodology. Continuous improvement in prediction accuracy compounds over time into significant intelligence advantages.

---

## Common Mistakes

### Mistake 1: Relying on Single-Source Intelligence

Using only one source of reputation intelligence (such as community complaints or platform ratings) produces incomplete and potentially misleading assessments. Multiple sources with different perspectives provide a more accurate picture of program quality. Diversify your intelligence gathering to avoid the blind spots inherent in any single source.

### Mistake 2: Ignoring Reputation Changes

Treating reputation as a fixed attribute rather than a dynamic characteristic leads to outdated assessments. Programs improve and deteriorate over time, and your reputation database should reflect current behavior rather than historical patterns. Regular reassessment ensures your assessments remain accurate.

### Mistake 3: Overweighting Anecdotal Evidence

Basing reputation assessments on isolated incidents rather than systematic patterns leads to inaccurate conclusions. Every program has some negative experiences, and individual reports may not represent typical program behavior. Look for consistent patterns across multiple experiences and sources.

### Mistake 4: Underweighting Positive Indicators

Focusing exclusively on negative reputation indicators while ignoring positive ones creates a biased assessment. Programs with some negative feedback may still provide excellent overall experiences. Balance your analysis by considering both positive and negative indicators.

### Mistake 5: Failing to Validate External Intelligence

Accepting external reputation intelligence without validation through direct experience risks acting on inaccurate or outdated information. External intelligence provides hypotheses; direct experience provides confirmation. Always validate critical reputation assessments through your own experience.

### Mistake 6: Neglecting Organizational Context

Evaluating program behavior without considering organizational context leads to misinterpretation. A startup with a two-person security team will have different capabilities than a Fortune 500 company with a dedicated security operations center. Contextualize program behavior within organizational reality.

### Mistake 7: Failing to Share Intelligence

Hoarding reputation intelligence while failing to contribute to community knowledge reduces the overall quality of intelligence available to you. Community intelligence is a shared resource that improves when everyone contributes. Participate actively in intelligence sharing to maintain the health of the community ecosystem.

---

## Advanced Techniques

### Technique 1: Sentiment Analysis Automation

Implement automated sentiment analysis of community discussions about your target programs. Use natural language processing tools to analyze forum posts, social media discussions, and platform reviews for sentiment trends that indicate changing program reputation.

Sentiment analysis can detect subtle shifts in community perception before they become apparent through manual monitoring. Increasing negative sentiment may indicate emerging problems with program quality. Increasing positive sentiment may indicate improvements that create new opportunities.

Automate your sentiment analysis pipeline to process large volumes of community data efficiently. Use machine learning models trained on bug bounty community language to improve accuracy beyond general-purpose sentiment analysis tools.

### Technique 2: Behavioral Pattern Recognition

Develop pattern recognition capabilities that identify program behavior signatures associated with specific reputation outcomes. Track multiple behavioral indicators simultaneously to identify composite patterns that predict program quality.

For example, programs that combine fast response times with generous bounties and professional communication typically provide excellent experiences. Programs that combine slow response times with bounty downgrades and adversarial communication typically provide poor experiences. These composite patterns are more predictive than any single indicator.

Build a pattern library that maps behavioral combinations to expected outcomes. Use this library to rapidly assess new programs based on observable behavioral characteristics.

### Technique 3: Network Analysis of Hunter Relationships

Analyze the network relationships between hunters and programs to identify indirect reputation signals. Hunters who maintain long-term relationships with specific programs provide implicit endorsement of program quality. Hunters who rapidly exit programs after initial submissions provide implicit criticism.

Map the network of hunter-program relationships across your community contacts. Identify hubs of positive relationships that indicate high-quality programs and hubs of negative relationships that indicate problematic programs.

Network analysis reveals reputation signals that are not visible through direct program assessment. The collective behavior of experienced hunters provides powerful implicit intelligence about program quality.

### Technique 4: Predictive Reputation Modeling

Develop predictive models that forecast future program reputation based on current indicators and historical patterns. These models enable proactive strategy adjustments based on predicted reputation changes rather than reactive adjustments based on observed changes.

Incorporate variables like organizational changes, market conditions, competitive dynamics, and community trends into your predictive models. These contextual factors influence program behavior in predictable ways that can be modeled and forecasted.

Regularly validate your predictive models against actual outcomes and refine them based on prediction errors. Improving model accuracy over time provides increasingly valuable intelligence that compounds into significant strategic advantages.

---

## Tools and Resources

### Reputation Intelligence Tools
- **Social Media Monitoring**: Track program mentions and sentiment across social platforms
- **Forum Monitoring**: Automated monitoring of bug bounty community forums
- **Platform Analytics**: Analysis of program metrics from bug bounty platforms
- **Custom Sentiment Analysis**: NLP tools for processing community feedback

### Data Collection Tools
- **Web Scraping**: Automated collection of program data and community discussions
- **API Integrations**: Programmatic access to platform data for analysis
- **Survey Tools**: Structured collection of hunter experiences and opinions
- **Network Analysis Tools**: Mapping and analyzing hunter-program relationships

### Analysis Tools
- **Statistical Analysis**: Quantitative analysis of reputation metrics and trends
- **Visualization Tools**: Graphs and charts for reputation data presentation
- **Machine Learning**: Pattern recognition and predictive modeling
- **Spreadsheet Analysis**: Basic reputation tracking and comparison

### Community Resources
- **Bug Bounty Forums**: Community discussion platforms for reputation intelligence
- **Private Hunter Networks**: Trusted contacts for confidential reputation sharing
- **Industry Conferences**: In-person networking for reputation intelligence
- **Mentorship Relationships**: Experienced hunters for reputation assessment guidance

---

## Metrics and KPIs

### Primary Reputation Metrics
- **Response Time Score**: Average and consistency of program response times
- **Bounty Fairness Score**: Actual bounties relative to advertised ranges and industry standards
- **Communication Quality Score**: Professionalism and helpfulness of program communication
- **Community Sentiment Score**: Aggregate community feedback and perception

### Secondary Reputation Metrics
- **Scope Stability Score**: Consistency and clarity of program scope over time
- **Safe Harbor Strength Score**: Quality and specificity of legal protections for hunters
- **Payment Reliability Score**: Speed and accuracy of bounty payments
- **Organizational Commitment Score**: Evidence of genuine investment in security research

### Scoring Methodology

**Reputation Score Calculation**:
```
Reputation Score = (Response Time Score x 0.2) + (Bounty Fairness Score x 0.25) + (Communication Quality Score x 0.2) + (Community Sentiment Score x 0.15) + (Scope Stability Score x 0.1) + (Safe Harbor Strength Score x 0.1)
```

**Score Interpretation**:
- 4.5-5.0: Exceptional reputation, highest priority for engagement
- 4.0-4.4: Strong reputation, recommended for engagement
- 3.5-3.9: Good reputation, suitable for engagement with awareness of minor issues
- 3.0-3.4: Average reputation, engage selectively based on specific strengths
- 2.5-2.9: Below average reputation, engage with caution and limited investment
- Below 2.5: Poor reputation, avoid or engage only with minimal test investment

---

## Implementation Checklist

### Initial Setup
- [ ] Design reputation database structure with all relevant fields
- [ ] Set up intelligence gathering from multiple sources
- [ ] Establish baseline reputation scores for current program portfolio
- [ ] Create monitoring system for reputation changes

### Data Collection
- [ ] Analyze platform metrics for all target programs
- [ ] Review community feedback across discussion platforms
- [ ] Assess program terms of service and legal provisions
- [ ] Evaluate scope documentation and change history

### Analysis and Scoring
- [ ] Calculate reputation scores for all target programs
- [ ] Identify programs with exceptional or poor reputation
- [ ] Assess correlation between reputation scores and your experience
- [ ] Develop predictive patterns for reputation outcomes

### Ongoing Monitoring
- [ ] Weekly: Monitor community discussions for new reputation intelligence
- [ ] Monthly: Update reputation database with new data and reassess scores
- [ ] Quarterly: Conduct comprehensive reputation review across all programs
- [ ] Annually: Full reassessment of reputation methodology and calibration

### Community Engagement
- [ ] Build relationships with program teams for direct intelligence
- [ ] Participate in community intelligence sharing
- [ ] Develop private network for confidential reputation information
- [ ] Contribute to community reputation knowledge base

---

## Quick Reference Cheat Sheet

### Reputation Scoring Quick Reference

| Indicator | Weight | Scoring Criteria |
|-----------|--------|-----------------|
| Response Time | 20% | Less than 48hrs = 5, 48-72hrs = 4, 3-5 days = 3, 5-14 days = 2, More than 14 days = 1 |
| Bounty Fairness | 25% | Consistently upper range = 5, Middle range = 4, Lower range = 3, Consistently minimum = 2, Below advertised = 1 |
| Communication Quality | 20% | Professional, helpful = 5, Professional = 4, Neutral = 3, Occasionally unprofessional = 2, Consistently unprofessional = 1 |
| Community Sentiment | 15% | Overwhelmingly positive = 5, Mostly positive = 4, Mixed = 3, Mostly negative = 2, Overwhelmingly negative = 1 |
| Scope Stability | 10% | Very stable = 5, Mostly stable = 4, Some changes = 3, Frequent changes = 2, Constant changes = 1 |
| Safe Harbor | 10% | Strong, comprehensive = 5, Adequate = 4, Basic = 3, Weak = 2, None or harmful = 1 |

### Reputation Red Flags
- [ ] Response times exceeding 14 business days consistently
- [ ] Bounty amounts consistently at minimum of advertised range
- [ ] Multiple community reports of bounty downgrades or disputes
- [ ] Weak or absent safe harbor provisions
- [ ] Frequent scope changes without advance notice
- [ ] Adversarial or unprofessional communication from triage team
- [ ] History of retroactive scope modifications to avoid payouts

### Reputation Green Flags
- [ ] Response times consistently under 72 hours
- [ ] Bounty amounts consistently in upper half of advertised range
- [ ] Positive community sentiment across multiple sources
- [ ] Strong, comprehensive safe harbor provisions
- [ ] Stable scope with advance notice of changes
- [ ] Professional, constructive communication from triage team
- [ ] Transparent triage processes and bounty calculations

### Reputation Assessment Priority
1. Communication Quality: Foundation of all other reputation indicators
2. Bounty Fairness: Direct impact on your financial returns
3. Response Time: Affects your effective hourly rate and cash flow
4. Community Sentiment: Collective intelligence from experienced hunters
5. Scope Stability: Impacts long-term testing strategy viability
6. Safe Harbor: Legal protection for your testing activities

---

## Reputation Assessment Methodologies

### Quantitative Assessment Methods

Quantitative reputation assessment relies on measurable, objective data points that can be tracked and compared across programs. These methods provide consistent, repeatable assessments that reduce subjective bias.

**Response Time Analysis**:
Collect response time data across multiple submissions to calculate average response time, median response time, and response time consistency. Consistent response times indicate stable triage processes, while variable response times indicate unpredictable processes.

**Bounty Distribution Analysis**:
Analyze bounty distributions across severity levels and vulnerability classes. Compare actual bounty distributions against advertised ranges and industry benchmarks. Programs with appropriate distributions that reward higher-severity findings more generously demonstrate fair bounty practices.

**Discovery Rate Tracking**:
Track your discovery rate across programs to identify patterns in vulnerability prevalence and triage acceptance. Higher discovery rates indicate programs with larger attack surfaces or more permissive testing policies.

**Competitive Analysis Metrics**:
Track the number of active hunters per program, submission volumes, and duplicate rates. These metrics indicate competitive intensity and help predict your discovery probability.

### Qualitative Assessment Methods

Qualitative reputation assessment captures subjective factors that quantitative metrics cannot measure. These methods provide nuanced understanding of program quality that numbers alone cannot convey.

**Communication Quality Assessment**:
Evaluate the professionalism, helpfulness, and responsiveness of program communication throughout the triage process. High-quality communication indicates organizational commitment to the program and respect for hunters.

**Community Sentiment Analysis**:
Analyze community discussions to understand the collective perception of program quality. Look for consistent themes rather than isolated complaints, as every program receives some negative feedback.

**Organizational Commitment Indicators**:
Assess indicators of organizational commitment including security team investment, program maturity, and industry recognition. Organizations with genuine commitment provide more reliable, long-term opportunities.

**Relationship Quality Assessment**:
Evaluate the quality of your relationships with program teams including communication tone, responsiveness, and mutual respect. Strong relationships indicate healthy program dynamics that benefit all participants.

### Composite Scoring Methodology

Combine quantitative and qualitative assessments into a composite reputation score that provides a single, comparable metric for each program.

**Scoring Framework**:
- Quantitative factors: 60% weight
- Qualitative factors: 40% weight
- Individual factor weights based on importance to your experience

**Score Calculation**:
```
Reputation Score = Sum of (Factor Score x Factor Weight) for all factors
```

**Score Interpretation**:
- 4.5-5.0: Exceptional reputation, highest priority
- 4.0-4.4: Strong reputation, recommended
- 3.5-3.9: Good reputation, suitable with awareness
- 3.0-3.4: Average reputation, engage selectively
- 2.5-2.9: Below average, engage with caution
- Below 2.5: Poor reputation, avoid

---

## Reputation Intelligence Gathering

### Open Source Intelligence (OSINT) Methods

OSINT methods gather reputation intelligence from publicly available sources that do not require direct interaction with the program.

**Platform Data Analysis**:
Analyze publicly available program data on bug bounty platforms including disclosed reports, bounty amounts, response times, and program descriptions. This data provides objective metrics for initial reputation assessment.

**Community Forum Monitoring**:
Monitor bug bounty community forums, social media groups, and discussion platforms for program-related discussions. Community discussions provide qualitative intelligence that platform data alone cannot capture.

**Security Research Publications**:
Review security research publications, blog posts, and conference presentations that mention your target programs. Published research indicates program visibility and may reveal specific reputation insights.

**News and Media Coverage**:
Monitor news and media coverage of your target programs for information about organizational changes, security incidents, and public perception that may affect program reputation.

### Direct Intelligence Methods

Direct intelligence methods involve gathering information through direct interaction with program teams and other hunters.

**Program Team Interactions**:
Engage with program teams through official communication channels to assess their responsiveness, professionalism, and helpfulness. Direct interactions provide firsthand evidence of program quality.

**Hunter Network Intelligence**:
Build relationships with other hunters who have experience with your target programs. Hunter networks provide detailed, firsthand intelligence that is not available through public sources.

**Platform Representative Engagement**:
Engage with platform representatives who may have insights into program quality and reputation. Platform representatives often have visibility into program behavior that is not publicly available.

**Conference and Event Networking**:
Attend security conferences and events where program representatives and other hunters gather. In-person networking provides relationship-building opportunities that enhance your intelligence network.

### Intelligence Validation and Cross-Referencing

Validate reputation intelligence by cross-referencing information from multiple sources. Single-source intelligence is inherently limited and potentially inaccurate.

**Source Triangulation**:
Cross-reference intelligence from at least three independent sources before forming reputation assessments. Triangulation increases confidence in your assessments by reducing the impact of biased or inaccurate individual sources.

**Temporal Validation**:
Validate that reputation intelligence is current and reflects current program behavior rather than historical patterns. Programs change over time, and outdated intelligence may not accurately represent current conditions.

**Bias Assessment**:
Assess potential biases in your intelligence sources. Community discussions may be biased by individual experiences. Platform data may be biased by selection effects. Hunter network intelligence may be biased by relationship dynamics.

**Confidence Scoring**:
Assign confidence scores to your reputation assessments based on the quality and consistency of your intelligence sources. Higher confidence scores indicate more reliable assessments that can guide more aggressive engagement strategies.

---

## Reputation-Based Decision Making

### Program Selection Decisions

Use reputation assessments to inform program selection decisions that align with your goals and risk tolerance.

**High-Reputation Program Strategy**:
Programs with strong reputations deserve more significant time investment and deeper testing. The probability of positive outcomes is higher, and the risk of wasted effort is lower.

**Medium-Reputation Program Strategy**:
Programs with average reputations warrant moderate investment with careful monitoring. Start with small test investments to validate your reputation assessment before committing significant time.

**Low-Reputation Program Strategy**:
Programs with poor reputations should either be avoided or tested with minimal investment. If you choose to test these programs, limit your exposure to small, time-boxed experiments.

### Engagement Depth Decisions

Reputation assessments should inform not just which programs to target but how deeply to engage with each program.

**Deep Engagement Indicators**:
- Strong reputation scores across all dimensions
- Positive community sentiment and hunter retention
- Fast response times and fair bounty practices
- Expanding scope and increasing bounty ranges

**Shallow Engagement Indicators**:
- Mixed reputation scores with specific concerns
- Variable community sentiment or declining hunter retention
- Inconsistent response times or bounty practices
- Stable or contracting scope with flat bounty ranges

**Minimal Engagement Indicators**:
- Poor reputation scores across multiple dimensions
- Negative community sentiment and high hunter turnover
- Slow response times and frequent bounty disputes
- Contracting scope or reducing bounty ranges

### Exit Decision Framework

Reputation monitoring should inform exit decisions when program quality deteriorates to the point where continued engagement is not justified.

**Exit Triggers**:
- Significant, sustained decline in reputation scores
- Material changes in program terms or scope
- Pattern of bounty disputes or downgrades
- Deterioration in communication quality
- Organizational changes that affect program commitment

**Exit Process**:
- Complete current testing sessions and reports
- Submit all pending findings before disengaging
- Maintain professional communication during exit
- Document reasons for exit to inform future decisions
- Monitor for potential re-engagement if conditions improve

---

## Reputation Building and Maintenance

### Building Program Relationships

Building positive relationships with program teams provides reputation intelligence and creates mutual benefits that enhance your overall experience.

**Relationship Building Activities**:
- Submit high-quality, well-documented reports
- Provide accurate severity assessments
- Offer constructive feedback and suggestions
- Respond professionally to all communications
- Respect program policies and timelines

**Relationship Maintenance Practices**:
- Maintain consistent, professional communication
- Follow through on commitments and promises
- Acknowledge program improvements and positive changes
- Provide advance notice of significant findings
- Support program teams during security incidents

**Relationship Leverage**:
- Request scope clarification when needed
- Seek feedback on report quality and severity
- Ask for early notification of scope changes
- Request consideration for private program invitations
- Seek guidance on preferred testing approaches

### Contributing to Program Quality

Hunters can contribute to program quality improvement that benefits the entire community.

**Constructive Feedback**:
Provide constructive feedback on program processes, scope, and bounty structures. Programs that receive thoughtful feedback from experienced hunters often improve their practices.

**Community Advocacy**:
Advocate for programs that provide positive experiences. Positive community advocacy helps attract skilled hunters and reinforces good program behavior.

**Knowledge Sharing**:
Share relevant knowledge with program teams that helps them improve their security posture. This sharing builds goodwill and strengthens relationships.

**Best Practice Promotion**:
Promote bug bounty best practices within the community and encourage programs to adopt industry standards. This advocacy improves the overall ecosystem.

---

## Reputation Monitoring and Maintenance

### Continuous Monitoring Systems

Establish systems that continuously monitor program reputation and alert you to significant changes.

**Automated Monitoring**:
Set up automated monitoring for key reputation indicators including response times, community discussions, and program announcements. Automated monitoring provides early detection of reputation changes.

**Periodic Assessment**:
Conduct periodic comprehensive reputation assessments that evaluate all reputation dimensions. Periodic assessments provide deeper analysis than continuous monitoring.

**Triggered Assessment**:
Conduct triggered assessments when significant events occur including organizational changes, scope modifications, or community discussions that indicate potential reputation changes.

### Reputation Database Maintenance

Maintain your reputation database as a living document that reflects current program conditions.

**Regular Updates**:
Update reputation data regularly based on new information from monitoring systems and direct experience. Stale data leads to outdated assessments that may not reflect current conditions.

**Data Quality Assurance**:
Ensure data quality by cross-referencing information from multiple sources and flagging uncertain data. High-quality data produces more reliable reputation assessments.

**Historical Analysis**:
Analyze historical reputation data to identify trends and patterns. Historical analysis provides insights into program trajectory that inform future expectations.

### Adaptation and Learning

Continuously adapt your reputation assessment methodology based on new experiences and changing market conditions.

**Methodology Refinement**:
Refine your assessment methodology based on the accuracy of your predictions. Methodologies that produce inaccurate predictions need adjustment.

**Factor Weight Adjustment**:
Adjust the weights assigned to different reputation factors based on their predictive power. Factors that consistently predict program quality should receive higher weights.

**New Factor Integration**:
Integrate new reputation factors as you discover them through experience. The bug bounty landscape evolves, and your reputation assessment methodology should evolve with it.

---

## Advanced Reputation Analytics

### Predictive Reputation Modeling

Develop predictive models that forecast future program reputation based on current indicators and historical patterns.

**Model Inputs**:
- Historical reputation scores and trends
- Organizational changes and leadership transitions
- Market conditions and competitive dynamics
- Community sentiment trends
- Platform policy changes

**Model Outputs**:
- Probability of reputation improvement or deterioration
- Expected reputation trajectory over next 6-12 months
- Risk factors that may affect future reputation
- Opportunities that may arise from reputation changes

**Model Validation**:
Validate your predictive models against actual outcomes to assess accuracy and identify areas for improvement. Model validation ensures that your predictions remain reliable over time.

### Network Reputation Analysis

Analyze the network relationships between programs, platforms, and organizations to identify indirect reputation signals.

**Organizational Network Analysis**:
Map the organizational relationships between programs and their parent companies. Programs within the same organization often share characteristics that affect their reputation.

**Platform Network Analysis**:
Analyze the relationships between programs and their host platforms. Platform policies and support practices affect program reputation in predictable ways.

**Hunter Network Analysis**:
Map the relationships between hunters and programs to identify reputation patterns. Hunters who maintain long-term relationships with specific programs provide implicit endorsement of program quality.

### Competitive Reputation Intelligence

Gather reputation intelligence about competitor programs to inform your strategic positioning.

**Competitor Program Analysis**:
Analyze the reputation of programs that compete for the same hunters. Understanding competitor reputation helps you identify opportunities and threats in the competitive landscape.

**Market Positioning**:
Use reputation intelligence to position yourself in the market. Programs with strong reputations attract more competition, while programs with weaker reputations may offer better opportunities for skilled hunters.

**Differentiation Strategy**:
Develop differentiation strategies based on reputation intelligence. Specializing in programs with specific reputation characteristics can provide competitive advantages.

---

## Industry-Specific Reputation Considerations

### Financial Services Reputation Factors

Financial services programs have unique reputation considerations due to regulatory requirements and data sensitivity.

**Regulatory Compliance Indicators**:
Assess program compliance with financial regulations including PCI-DSS, SOX, and national financial regulations. Programs with strong compliance practices typically provide more structured, reliable experiences.

**Data Handling Practices**:
Evaluate the program's data handling practices for financial information. Programs with strong data protection practices demonstrate organizational maturity that extends to other aspects of the program.

**Incident Response Capabilities**:
Assess the program's incident response capabilities for financial security incidents. Programs with established incident response procedures demonstrate operational maturity.

### Healthcare Reputation Factors

Healthcare programs have unique reputation considerations due to HIPAA requirements and patient data sensitivity.

**HIPAA Compliance Indicators**:
Assess program compliance with HIPAA requirements for protected health information. Programs with strong HIPAA practices typically provide more structured testing environments.

**Patient Data Protection**:
Evaluate the program's patient data protection practices. Programs with strong data protection demonstrate organizational commitment to security that benefits hunters.

**Research Ethics Considerations**:
Consider research ethics requirements for healthcare security testing. Programs with clear ethical guidelines provide more secure testing environments.

### Cryptocurrency Reputation Factors

Cryptocurrency programs have unique reputation considerations due to the rapidly evolving regulatory landscape and technical complexity.

**Smart Contract Audit Quality**:
Assess the quality of the program's smart contract audit processes. Programs with rigorous audit practices typically have more mature security operations.

**Regulatory Compliance**:
Evaluate compliance with cryptocurrency regulations in relevant jurisdictions. Programs with strong regulatory compliance provide more stable, predictable environments.

**Technical Depth Requirements**:
Assess the technical depth required for effective testing. Programs with high technical requirements create natural barriers to competition that benefit specialized hunters.

---

## Reputation Assessment Tools and Templates

### Assessment Templates

Use standardized templates to ensure consistent, comprehensive reputation assessments.

**Initial Assessment Template**:
```
Program: [Name]
Platform: [Platform]
Assessment Date: [Date]
Assessor: [Your Name]

Quantitative Metrics:
- Average Response Time: [Value]
- Bounty Range Accuracy: [Score 1-5]
- Discovery Rate: [Value]
- Competitive Intensity: [Score 1-5]

Qualitative Assessment:
- Communication Quality: [Score 1-5]
- Community Sentiment: [Score 1-5]
- Organizational Commitment: [Score 1-5]
- Scope Management: [Score 1-5]

Composite Score: [Calculated Value]
Confidence Level: [High/Medium/Low]
Recommendation: [Engage/Selective/Avoid]
```

**Update Assessment Template**:
```
Program: [Name]
Previous Assessment Date: [Date]
Current Assessment Date: [Date]

Changes Since Last Assessment:
- [Change 1]
- [Change 2]
- [Change 3]

Updated Scores:
- [Factor]: [Previous] -> [Current]
- [Factor]: [Previous] -> [Current]

Trajectory: [Improving/Stable/Declining]
Updated Recommendation: [Engage/Selective/Avoid]
```

### Monitoring Dashboards

Create monitoring dashboards that provide real-time visibility into reputation indicators.

**Dashboard Components**:
- Response time trends and alerts
- Community sentiment tracking
- Bounty payment monitoring
- Scope change notifications
- Competitive landscape updates

**Alert Thresholds**:
Set alert thresholds for key indicators that trigger immediate assessment when breached. Common thresholds include response time exceeding 7 days, community sentiment turning negative, or bounty payments declining.

---

## Quick Reference

### Reputation Assessment Priority
1. Communication Quality: Foundation of all other indicators
2. Bounty Fairness: Direct financial impact
3. Response Time: Efficiency and cash flow impact
4. Community Sentiment: Collective intelligence validation
5. Scope Stability: Long-term strategy viability
6. Safe Harbor: Legal protection foundation

### Red Flags Requiring Immediate Attention
- Response times consistently exceeding 14 business days
- Bounty amounts consistently at minimum of advertised range
- Multiple community reports of bounty disputes
- Weak or absent safe harbor provisions
- Frequent scope changes without notice
- Adversarial communication from triage team
- History of retroactive scope modifications

### Green Flags Supporting Aggressive Engagement
- Response times consistently under 72 hours
- Bounty amounts in upper half of advertised range
- Positive community sentiment across multiple sources
- Strong, comprehensive safe harbor provisions
- Stable scope with advance notice of changes
- Professional, constructive communication
- Transparent triage processes and calculations

---

*Last Updated: 2026-06-13*
*Version: 2.0*
*Author: Prompt-Hunting Strategy Framework*
