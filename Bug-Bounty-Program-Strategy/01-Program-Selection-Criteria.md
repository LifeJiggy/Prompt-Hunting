# Strategy Guide: Program Selection Criteria for Bug Bounty Hunting

## Expert Role

You are a seasoned bug bounty program analyst with over a decade of experience evaluating and selecting optimal hunting targets. Your expertise lies in dissecting program structures, reward mechanisms, scope definitions, and historical payout patterns to identify the most lucrative and achievable opportunities in the bug bounty ecosystem. You have personally submitted over 500 reports across platforms including HackerOne, Bugcrowd, Intigriti, and Immunefi, giving you an intimate understanding of what makes a program worth pursuing versus a waste of time.

Your analytical framework combines quantitative metrics such as average bounty payouts, response times, and resolution rates with qualitative assessments like triager competence, program maturity, and scope clarity. You understand that the difference between a profitable month and a barren one often comes down to selecting the right programs at the right time. You have developed proprietary scoring models that weight dozens of variables to produce actionable program rankings.

Beyond raw numbers, you possess deep insight into the psychological and operational dynamics of bug bounty programs. You know which companies are actively investing in security, which ones are merely checkbox compliance, and which ones will fight you on valid submissions. Your selection methodology has been refined through years of trial, error, and systematic analysis of the bug bounty market landscape as it evolved from a niche community activity into a multi-billion dollar industry.

## Overview

Program selection is the single most impactful decision a bug bounty hunter makes. Choosing the wrong program can consume weeks of effort yielding zero return, while selecting the right one can produce consistent monthly income or even life-changing payouts. The bug bounty landscape is vast and heterogeneous, with thousands of active programs spanning every imaginable industry, technology stack, and reward structure. Navigating this landscape requires a systematic, data-driven approach that goes far beyond simply picking the highest bounties.

The modern bug bounty ecosystem presents both unprecedented opportunity and unprecedented complexity. Programs vary wildly in their scope definitions, reward ranges, response times, and overall hunter friendliness. Some programs are havens for hunters with clear scopes, generous bounties, and responsive triage teams. Others are traps that exist solely for compliance purposes, offering minimal rewards and rejecting valid findings on technicalities. Understanding these distinctions is the foundation of a sustainable bug bounty career.

This strategy guide provides a comprehensive framework for evaluating, scoring, and selecting bug bounty programs that align with your skills, goals, and risk tolerance. It covers every dimension of program analysis from basic metrics like bounty ranges to advanced considerations like competitive landscape, vulnerability class availability, and long-term program trajectory. Whether you are a newcomer seeking your first payout or a veteran looking to optimize your target portfolio, this framework will transform your approach to program selection.

---

## Strategic Framework

### Phase 1: Initial Program Discovery

The first phase of program selection involves identifying the universe of available programs and filtering them down to a manageable shortlist. This process begins with platform-level research and progresses through increasingly granular analysis.

**Step 1: Platform Portfolio Review**

Begin by cataloging all programs available on each major platform. HackerOne currently hosts over 2,000 programs, Bugcrowd hosts several hundred, Intigriti focuses on quality over quantity with curated programs, and Immunefi specializes in blockchain and DeFi targets. Each platform has distinct characteristics regarding program vetting, dispute resolution, and payment processing that affect your overall experience.

Create a master spreadsheet that captures program name, platform, industry, technology stack, bounty range, response time SLA, and your preliminary interest level. This spreadsheet becomes your living document for program management and will be updated continuously as you gather more information.

**Step 2: Scope Analysis**

Scope is the single most critical factor in program selection. A generous bounty means nothing if the target is out of scope. Analyze scope definitions for clarity, breadth, and alignment with your technical capabilities. Look for programs that include web applications, APIs, and mobile applications in scope while explicitly excluding areas where you lack expertise.

Pay particular attention to scope ambiguity. Programs with vague scope definitions like "any property owned by Company X" create both opportunity and risk. Opportunity because the attack surface is potentially enormous. Risk because out-of-scope claims can result in wasted effort and account penalties. Prefer programs with explicit, enumerated scope lists that include specific domains, subdomains, and application types.

**Step 3: Reward Structure Analysis**

Bug bounty programs employ various reward structures that significantly impact your earning potential. Fixed bounties offer predictable returns but may undervalue critical findings. Variable bounties based on CVSS scores introduce subjectivity but can result in higher payouts for impactful discoveries. Hall of fame only programs provide zero financial return and should generally be avoided unless the target is exceptionally valuable for portfolio or learning purposes.

Analyze the full reward range including minimum, maximum, and median payouts. Programs advertising $500-$10,000 bounties that consistently pay $500 are fundamentally different from those that regularly pay near the maximum. Historical payout data, when available, is far more reliable than advertised ranges.

### Phase 2: Deep Program Evaluation

Once you have a shortlist of potentially interesting programs, conduct deeper evaluation using both public information and direct reconnaissance.

**Step 4: Historical Performance Analysis**

Examine the program's track record through multiple lenses. Review disclosed reports on the platform to understand what types of vulnerabilities have been found and rewarded. Look for patterns in payout amounts relative to severity levels. Identify whether the program has a history of paying bounties for the vulnerability classes you specialize in.

Analyze response time metrics including time to first response, time to triage, and time to bounty. Programs that take months to triage reports create cash flow problems and reduce your ability to iterate on findings. Programs with rapid turnaround times allow you to maintain momentum and compound your earnings.

**Step 5: Competitive Landscape Assessment**

Evaluate the competitive intensity of each program. Highly publicized programs with generous bounties attract large numbers of skilled hunters, making it difficult for any individual to find unique vulnerabilities. Conversely, lesser-known programs in niche industries may have significantly lower competition despite offering comparable rewards.

Consider the program's age and visibility. Newly launched programs often have a window of opportunity before the hunter community fully converges on them. Established programs with long track records have typically had their low-hanging fruit harvested but may still offer value through deeper vulnerability classes and newer application features.

**Step 6: Technology Stack Assessment**

Map the technology stacks used by each program's in-scope applications. Identify programs where your technical expertise gives you a meaningful advantage. If you specialize in React-based single-page applications, programs running legacy server-rendered applications may not play to your strengths. Conversely, if you have deep expertise in Node.js security, programs running Express.js or NestJS frameworks present natural hunting grounds.

Technology stack analysis also reveals potential vulnerability classes. Java applications may be susceptible to deserialization attacks. Applications using GraphQL endpoints may have introspection and authorization issues. Mobile applications built with React Native may expose hardcoded secrets in JavaScript bundles. Matching your skills to technology stacks maximizes your efficiency.

### Phase 3: Portfolio Construction

The final phase involves assembling a balanced portfolio of programs that optimizes for consistent income while maintaining upside potential.

**Step 7: Portfolio Diversification**

Construct your program portfolio like an investment portfolio. Include a mix of high-competition/high-reward programs for potential windfall discoveries, medium-competition/medium-reward programs for consistent income, and low-competition/niche programs for steady baseline returns. This diversification reduces your exposure to any single program's bounty decisions or scope changes.

Allocate your time across portfolio tiers based on your current financial needs and risk tolerance. Hunters in financial distress should weight their portfolio toward reliable, lower-variance programs. Hunters with stable income can afford to allocate more time to high-variance, high-upside programs.

**Step 8: Risk Assessment and Contingency**

Evaluate the downside risks of each program. Programs with aggressive legal terms, poor dispute resolution mechanisms, or histories of bounty disputes represent financial and legal risks. Consider programs' track records with vulnerability disclosure, coordinated disclosure practices, and hunter reputation management.

Develop contingency plans for common negative scenarios. If a program you depend on for income suddenly changes scope or reduces bounties, what is your fallback? If your account on a platform is suspended due to a disputed report, what is your recovery plan? Resilient hunters maintain relationships and skills across multiple platforms and program types.

---

## Real-World Examples

### Example 1: The Hidden Gem in Healthcare SaaS

A mid-sized healthcare SaaS company launched a bug bounty program on HackerOne with a private invitation list of 50 hunters. The program offered $200-$2,000 bounties for vulnerabilities in their patient management platform. Due to the niche industry and limited invitation scope, most hunters dismissed it as too specialized.

One hunter who had prior experience with healthcare applications and HIPAA compliance recognized the opportunity. The technology stack used Ruby on Rails with a React frontend and PostgreSQL database, which aligned perfectly with her expertise. She discovered an IDOR vulnerability in the patient records API that exposed Protected Health Information (PHI) across tenant boundaries. The bounty was $2,000, and she subsequently found three more vulnerabilities totaling $4,500 in payouts over two months.

The key lesson was that program selection criteria should include industry-specific factors. Healthcare programs often have higher severity multipliers due to regulatory implications, and the specialized knowledge required creates natural barriers to competition. Programs in regulated industries like healthcare, finance, and government frequently offer higher bounties for the same vulnerability classes due to the compliance risks involved.

### Example 2: The High-Payout Trap

A major cryptocurrency exchange launched a highly publicized bug bounty program with bounties up to $100,000 for critical vulnerabilities. The program attracted hundreds of hunters within the first week, and social media was flooded with announcements and discussions about the generous reward structure.

An experienced hunter analyzed the program and discovered several red flags despite the attractive bounties. The scope was extremely narrow, covering only recently launched features that had already undergone professional security audits. The triage time SLA was 30 business days with no intermediate communication. Historical disclosed reports showed that 90% of submissions were marked as informational or duplicates with no bounty. The program's terms of service included an indemnification clause that exposed hunters to legal liability.

The hunter allocated minimal time to this program and instead focused on a less publicized DeFi protocol with $1,000-$10,000 bounties but significantly less competition and clearer scope. Within three weeks, he found a reentrancy vulnerability worth $7,500 while hunters at the exchange were still waiting for triage decisions on their submissions.

This example illustrates that maximum advertised bounties are a poor selection criterion in isolation. The effective earning rate, calculated as total bounties earned divided by total hours invested, is the true measure of program value.

### Example 3: The Platform Migration Opportunity

A large e-commerce company migrated their bug bounty program from Bugcrowd to HackerOne, effectively creating a new program on the new platform. During the transition period, the company expanded scope to include newly acquired properties that had not been previously tested.

An alert hunter noticed the platform migration through public announcements and cross-referenced the new scope with known vulnerabilities from the old program's disclosed reports. He discovered that several subdomains included in the new scope had been previously tested under the old program but contained new features that had not been evaluated. By targeting these specific new features, he found an SSRF vulnerability in a product image processing service that led to internal network access, resulting in a $5,000 bounty.

The lesson here is that program lifecycle events create natural opportunities. Platform migrations, scope expansions, new feature launches, and organizational changes all introduce new attack surface that may not have been thoroughly tested. Hunters who monitor program announcements and adjust their targeting accordingly gain a significant advantage.

### Example 4: The Niche Industry Advantage

A manufacturing company that produces industrial control systems (ICS) launched a bug bounty program focused on their cloud management platform for connected devices. The program offered $500-$5,000 bounties but received very few submissions due to the specialized nature of the target.

A hunter with a background in embedded systems and IoT security recognized the unique opportunity. The cloud platform used MQTT for device communication and had a custom REST API for device management. He discovered a critical authentication bypass in the MQTT broker configuration that allowed unauthorized command execution on connected industrial devices. The bounty was $5,000, and the finding was additionally acknowledged by ICS-CERT (Industrial Control Systems Cyber Emergency Response Team).

This case demonstrates the value of domain expertise in program selection. Hunters with specialized knowledge in areas like IoT security, industrial systems, telecommunications, or financial services can access programs where their expertise provides an insurmountable advantage over generalist hunters. The reduced competition in these specialized programs often compensates for lower advertised bounty ranges.

### Example 5: The Long-Term Relationship Strategy

A SaaS company running a private bug bounty program on HackerOne maintained a small, trusted hunter community of approximately 100 researchers. The program offered modest bounties of $100-$1,000 but provided consistently fast triage (48 hours average) and never disputed valid findings. New features were regularly added to scope, creating fresh attack surface every quarter.

An experienced hunter joined the program and invested three months building deep knowledge of the application architecture, authentication flows, and business logic. By month four, he was finding vulnerabilities at a rate of two per week, earning an average of $1,200 per month. While individual bounties were modest, the consistent volume and fast turnaround created a reliable income stream that exceeded what he earned from occasional high-value finds on public programs.

The strategic insight is that program selection should account for long-term relationship value. Programs with fast turnaround, fair treatment, and expanding scope create compounding returns as your knowledge of the target deepens. Building relationships with program teams through high-quality reports and professional communication can also lead to private program invitations, early access to new scope, and preferential treatment in triage.

---

## Best Practices

### Practice 1: Build and Maintain a Program Database

Create a comprehensive database of all programs you have evaluated, including both active targets and those you have decided not to pursue. Record program name, platform, industry, technology stack, bounty range, response time, your assessment score, and notes. Update this database monthly as programs change their structures, scopes, and reward mechanisms.

Use a structured format that allows sorting and filtering by multiple criteria. A spreadsheet with color coding for priority tiers works well for most hunters. More technical hunters may prefer a Notion database or custom application that integrates with platform APIs for automated updates.

The database serves multiple purposes beyond initial selection. It enables you to quickly identify opportunities when you develop new skills or when program conditions change. It also provides a historical record that helps you refine your selection criteria based on actual outcomes rather than initial impressions.

### Practice 2: Monitor Program Announcements Actively

Set up automated monitoring for program announcements across all major platforms. Most platforms have RSS feeds, email notifications, or API endpoints that provide real-time updates on program launches, scope changes, and policy modifications. Configure alerts for programs in industries and technology stacks that match your expertise.

In addition to platform-native notifications, follow bug bounty community channels including HackerOne Hacktivity, Bugcrowd blog, Intigriti announcements, and security researcher social media accounts. These channels often provide early intelligence on program changes and new opportunities before they are widely publicized.

Create a daily routine for reviewing program updates. Spend 10-15 each morning scanning announcements and adjusting your priority list. This small daily investment prevents you from missing opportunities and keeps your targeting aligned with current market conditions.

### Practice 3: Calculate Effective Hourly Rate

Develop a disciplined approach to calculating your effective hourly rate for each program. Track the total time invested in each program including reconnaissance, vulnerability discovery, report writing, and triage communication. Compare this time investment against total bounties earned to determine your true hourly return.

Most hunters drastically underestimate their time investment because they do not account for cognitive overhead, context-switching costs, and time spent on non-productive activities like reading documentation, setting up testing environments, and waiting for program responses. By rigorously tracking time, you may discover that programs with lower bounties but faster turnaround and simpler scope actually provide better hourly returns.

Review your effective hourly rate calculations quarterly and adjust your program portfolio accordingly. Programs that consistently deliver below your target hourly rate should be deprioritized or abandoned in favor of better opportunities.

### Practice 4: Understand Program Psychology

Invest time in understanding the organizational psychology behind each program. Programs run by dedicated security teams with budget authority tend to be more hunter-friendly than programs managed by compliance departments or outsourced to third-party vendors. Companies experiencing recent security incidents may be more generous with bounties to encourage responsible disclosure. Companies with activist investors or upcoming IPOs may be more motivated to maintain positive public perception.

Read the program's terms of service carefully for clues about organizational priorities. Programs that emphasize safe harbor provisions demonstrate commitment to hunter protection. Programs that include restrictive clauses about disclosure, liability, or intellectual property may signal organizational attitudes that could complicate your experience.

Engage with program teams professionally and observe their communication style. Responsive, respectful communication typically indicates a well-run program. Delayed, adversarial, or dismissive responses may indicate deeper organizational issues that will affect your experience.

### Practice 5: Leverage Community Intelligence

Actively participate in bug bounty communities to gather intelligence on program quality. Forums like BugBountyDiscord, HackerOne community, and Reddit regularly discuss program experiences including payout reliability, triage fairness, and scope changes. This community intelligence provides information that is not available through official program documentation.

When evaluating new programs, search for community discussions before investing significant time. Look for patterns in hunter feedback rather than isolated complaints. Every program receives some negative feedback, but consistent themes across multiple hunters are reliable indicators of systemic issues.

Contribute your own experiences to the community to build reputation and reciprocity. Hunters who share valuable insights about program quality earn social capital that can be leveraged for recommendations, private program invitations, and collaborative hunting opportunities.

### Practice 6: Develop Program-Specific Testing Methodologies

For your highest-priority programs, develop customized testing methodologies that account for the specific technology stack, application architecture, and vulnerability history. Generic testing approaches waste time on irrelevant vulnerability classes while missing program-specific attack vectors.

Study disclosed reports from your target programs to understand the types of vulnerabilities that have been found and the testing techniques that were effective. Use this intelligence to refine your testing methodology and focus your efforts on high-probability vulnerability classes.

Document your program-specific methodologies in a format that can be quickly reviewed before each testing session. This documentation should include target-specific reconnaissance steps, common vulnerability patterns, testing tool configurations, and reporting templates. Over time, these methodologies become valuable intellectual property that accelerates your testing across similar programs.

### Practice 7: Quarterly Portfolio Review

Conduct a formal quarterly review of your program portfolio. Reassess each program's performance against your key metrics including effective hourly rate, bounty consistency, triage speed, and overall satisfaction. Use this review to reallocate your time toward higher-performing programs and away from underperformers.

During the quarterly review, also reassess your personal skill development and how it aligns with your portfolio. If you have developed new capabilities in areas like API security, mobile application testing, or cloud infrastructure assessment, identify programs that would benefit from these new skills. Conversely, identify skill gaps that are limiting your effectiveness on current programs and develop learning plans to address them.

The quarterly review is also the appropriate time to explore new program categories. Consider expanding into adjacent industries, testing new platforms, or experimenting with different bounty structures. Controlled experimentation during quarterly reviews prevents stagnation while maintaining portfolio stability.

---

## Common Mistakes

### Mistake 1: Chasing Maximum Bounty Amounts

The most common selection mistake is choosing programs based solely on maximum advertised bounty amounts. A program offering $50,000 maximum bounties is worthless if the scope is impenetrable, the competition is overwhelming, or the triage process is dysfunctional. Effective program selection requires holistic evaluation of multiple factors, not just headline bounty numbers. Hunters who fall into this trap often find themselves competing with hundreds of skilled researchers for the same vulnerabilities, resulting in wasted time and zero bounties.

### Mistake 2: Ignoring Scope Boundaries

Failing to thoroughly analyze scope boundaries leads to wasted effort and potential account penalties. Hunters who invest days testing out-of-scope applications or features experience devastating setbacks. Always verify scope before beginning any testing activity, and when in doubt, contact the program team for clarification. Scope boundaries are not suggestions; they are contractual limitations that define what testing is authorized and what bounty is available.

### Mistake 3: Overlooking Response Time Metrics

Response time significantly impacts your effective earning rate. Programs that take 60+ days to triage reports create cash flow problems and prevent you from iterating on findings. A program with $500 bounties and 48-hour triage may be more profitable than one with $5,000 bounties and 90-day triage. Fast triage enables rapid iteration, which compounds your discovery rate over time.

### Mistake 4: Neglecting Competitive Analysis

Failing to assess competitive intensity leads to overinvestment in oversaturated programs. High-visibility programs attract large numbers of skilled hunters, making unique vulnerability discovery increasingly difficult. Balance high-competition programs with lower-competition alternatives to maintain consistent discovery rates. The marginal return on time invested decreases as competition increases, even if absolute bounty amounts remain attractive.

### Mistake 5: Skipping Community Research

Not researching community feedback before investing in a program is a preventable error. Community intelligence provides early warning about problematic programs and validates your own analysis. The 15 minutes spent reading community discussions can save weeks of wasted effort. Community research is the cheapest form of due diligence available to hunters.

### Mistake 6: Failing to Re-evaluate Programs

Programs change over time. Bounty structures, scope definitions, triage processes, and competitive landscapes evolve. Hunters who fail to periodically re-evaluate their program portfolio may continue investing in programs that no longer meet their criteria while missing improved opportunities elsewhere. Quarterly re-evaluation ensures your portfolio remains optimized for current conditions.

### Mistake 7: Over-Diversifying

While portfolio diversification is valuable, over-diversification spreads your attention too thin. Trying to maintain active testing across more than 10-15 programs simultaneously reduces your depth of knowledge on any individual target. Quality of engagement matters more than breadth of coverage. A focused portfolio of 8-12 well-understood programs typically outperforms a scattered approach across 30+ programs.

---

## Advanced Techniques

### Technique 1: Predictive Program Analysis

Develop predictive models for program success based on observable characteristics. Track variables like company funding rounds, security team hiring patterns, technology stack changes, and competitive landscape shifts. Use historical data from your program database to identify correlations between these variables and bounty outcomes.

For example, companies that recently raised significant funding rounds often expand their bug bounty budgets and scope. Companies that hire dedicated security engineers typically improve their triage processes and bounty generosity. Companies experiencing rapid growth may introduce new features faster than they can be secured, creating fresh vulnerability opportunities. By monitoring these signals, you can identify programs that are about to become more lucrative before the broader hunter community catches on.

### Technique 2: Cross-Platform Arbitrage

Identify programs that exist on multiple platforms and analyze differences in their configurations. Some companies run parallel programs on different platforms with different scopes, bounty ranges, or terms. Understanding these differences allows you to target the most favorable configuration and avoid redundant effort.

Additionally, monitor for programs that migrate between platforms. Migrations often create temporary periods of reduced competition as hunters on the old platform may not follow the program to the new one. Early adoption of migrated programs can yield significant advantages during the transition period when the target is less thoroughly tested than it will be once the migration stabilizes.

### Technique 3: Influence Program Development

For programs where you have established a strong relationship, provide constructive feedback on program structure, scope, and bounty configuration. Many program teams welcome hunter input on how to make their program more attractive to skilled researchers. By influencing program development, you can shape the program to better align with your strengths and preferences.

This technique requires professional credibility built through consistent, high-quality submissions and respectful communication. It is a long-term strategy that pays dividends over months and years rather than providing immediate returns. Hunters who become trusted advisors to program teams often gain early access to new scope and preferential treatment during triage.

### Technique 4: Temporal Optimization

Analyze the temporal patterns of program activity. Some programs release new features on predictable schedules, creating recurring opportunities for fresh vulnerability discovery. Others have seasonal patterns related to compliance deadlines, budget cycles, or organizational priorities. Align your testing schedule with these temporal patterns to maximize discovery rates.

Additionally, monitor for trigger events that signal opportunity. Security incidents, regulatory changes, executive turnover, and mergers and acquisitions all create conditions that affect program dynamics and vulnerability prevalence. Temporal optimization is the art of being in the right place at the right time with the right skills.

---

## Tools and Resources

### Platform Tools
- **HackerOne Hacktivity**: Public disclosure feed for discovering program patterns and successful submission techniques
- **Bugcrowd Program List**: Comprehensive directory with filtering by industry, bounty range, and technology
- **Intigriti Program Explorer**: Curated program listings with detailed scope and bounty information
- **Immunefi Prime**: Blockchain and DeFi focused program directory with specialized categorization

### Research Tools
- **BuiltWith**: Technology stack identification for target applications
- **Wappalyzer**: Browser extension for technology fingerprinting
- **Shodan**: Infrastructure reconnaissance for understanding target architecture
- **Censys**: Certificate transparency and infrastructure discovery
- **SecurityTrails**: Historical DNS data and subdomain enumeration

### Analytics Tools
- **Google Sheets / Excel**: Program database management and analysis
- **Notion**: Structured knowledge management for program research
- **Airtable**: Advanced database management with relational features
- **Custom Scripts**: Python/JavaScript automation for data collection and analysis

### Community Resources
- **Bug Bounty Discourse**: Community discussion platform for program reviews
- **Reddit r/bugbounty**: Community forum for program discussions and recommendations
- **HackerOne Community**: Official community platform for HackerOne hunters
- **Security Social Media**: Real-time intelligence on program changes and opportunities

---

## Metrics and KPIs

### Primary Metrics
- **Effective Hourly Rate**: Total bounties earned divided by total hours invested per program
- **Discovery Rate**: Number of valid vulnerabilities found per month per program
- **Bounty Consistency**: Standard deviation of bounty amounts received per program
- **Response Time**: Average time from submission to first response and from submission to bounty

### Secondary Metrics
- **Competition Index**: Number of active hunters per program relative to program age
- **Scope Breadth**: Number of in-scope assets and vulnerability classes
- **Triager Quality**: Ratio of valid reports correctly triaged to total triage decisions
- **Program Loyalty**: Duration of active participation and trend in bounty amounts over time

### Calculation Methods

**Effective Hourly Rate Formula**:
```
EHR = (Total Bounties Earned - Platform Fees) / (Recon Hours + Testing Hours + Report Writing Hours + Communication Hours)
```

**Discovery Rate Formula**:
```
DR = (Valid Reports Submitted x Average Bounty) / (Total Hours Invested x 30)
```

**Program Score Formula**:
```
PS = (EHR x 0.3) + (DR x 0.25) + (Response Score x 0.2) + (Scope Score x 0.15) + (Community Score x 0.1)
```

---

## Implementation Checklist

### Initial Setup
- [ ] Create program database spreadsheet with all required fields
- [ ] Set up platform accounts on HackerOne, Bugcrowd, Intigriti, and Immunefi
- [ ] Configure notification alerts for new programs and scope changes
- [ ] Join bug bounty community channels and forums
- [ ] Install technology fingerprinting tools and browser extensions

### Program Evaluation
- [ ] Complete initial scope analysis for all candidate programs
- [ ] Calculate effective hourly rate estimates for each program
- [ ] Research community feedback on each candidate program
- [ ] Assess competitive landscape for each program
- [ ] Map technology stacks to your personal skill set

### Portfolio Construction
- [ ] Select 10-15 programs across multiple tiers
- [ ] Allocate time budgets for each program tier
- [ ] Establish priority ranking within each tier
- [ ] Create program-specific testing methodologies for top 5 programs
- [ ] Set up tracking for time investment and bounty outcomes

### Ongoing Management
- [ ] Daily: Review program announcements and community discussions
- [ ] Weekly: Update program database with new information and outcomes
- [ ] Monthly: Calculate effective hourly rates and adjust time allocation
- [ ] Quarterly: Conduct formal portfolio review and strategic planning
- [ ] Annually: Comprehensive reassessment of all programs and selection criteria

---

## Quick Reference Cheat Sheet

### Program Scoring Quick Reference

| Factor | Weight | Scoring Criteria |
|--------|--------|-----------------|
| Effective Hourly Rate | 30% | More than $100/hr = 5, $50-100 = 4, $25-50 = 3, $10-25 = 2, less than $10 = 1 |
| Bounty Consistency | 25% | Less than 20% variance = 5, 20-40% = 4, 40-60% = 3, 60-80% = 2, More than 80% = 1 |
| Response Time | 20% | Less than 48hrs = 5, 48-72hrs = 4, 3-5 days = 3, 5-14 days = 2, More than 14 days = 1 |
| Scope Clarity | 15% | Explicit list = 5, Mostly clear = 4, Somewhat clear = 3, Vague = 2, Very vague = 1 |
| Community Reputation | 10% | Excellent = 5, Good = 4, Neutral = 3, Mixed = 2, Poor = 1 |

### Red Flags Checklist
- [ ] Scope ambiguity or frequent scope changes
- [ ] Response time SLA exceeding 14 business days
- [ ] History of bounty disputes or downgrades
- [ ] Restrictive legal terms or indemnification clauses
- [ ] No safe harbor provision
- [ ] High competition with low discovery rate
- [ ] Negative community sentiment patterns

### Green Flags Checklist
- [ ] Explicit, detailed scope documentation
- [ ] Response time SLA under 72 hours
- [ ] History of fair bounty payments and positive hunter feedback
- [ ] Strong safe harbor provisions
- [ ] Dedicated security team with bug bounty experience
- [ ] Regular scope expansions and feature additions
- [ ] Professional, respectful communication

---

## Industry-Specific Selection Criteria

### Financial Services Programs

Financial services programs offer unique opportunities and challenges that require specialized selection criteria. These programs typically operate under strict regulatory frameworks including PCI-DSS, SOX, and various national financial regulations. The regulatory environment creates both higher bounty potential due to compliance risks and more restrictive scope definitions due to data sensitivity.

When evaluating financial services programs, prioritize programs with explicit authorization for testing payment processing flows, authentication systems, and data storage mechanisms. Financial services applications often have complex multi-tenant architectures with strict data isolation requirements, creating IDOR and access control vulnerability opportunities.

Assess the program's regulatory maturity by reviewing their compliance documentation and security policies. Programs backed by dedicated compliance teams typically provide clearer scope boundaries and more predictable triage processes. Programs without clear regulatory frameworks may have ambiguous scope that creates risk.

Consider the technology stack implications for financial services targets. Mainframe and legacy system integration creates unique vulnerability classes that generalist hunters may not be equipped to test. Cloud-native financial applications built on modern frameworks may present more familiar attack surfaces but with higher competition.

Evaluate the data sensitivity classifications for the program's scope. Programs that explicitly authorize testing with non-production data provide safer testing environments. Programs that require testing with production data create higher risk and may require specialized handling procedures.

### Healthcare and HIPAA Programs

Healthcare programs require specialized selection criteria due to the unique sensitivity of Protected Health Information (PHI) and the regulatory requirements of HIPAA and related frameworks. Healthcare applications often have complex data access patterns due to the need for medical professionals to access patient records across organizational boundaries.

Prioritize programs with explicit HIPAA compliance documentation and clear authorization for testing data access controls. Healthcare applications frequently have IDOR vulnerabilities in patient record access due to the complex relationships between patients, providers, and organizations.

Assess the program's data handling requirements. Programs that provide synthetic or de-identified test data reduce your regulatory risk while maintaining testing effectiveness. Programs that require testing with real PHI create significant legal exposure that must be carefully evaluated.

Evaluate the program's incident response capabilities for healthcare-specific scenarios. Programs with established procedures for handling PHI exposure incidents demonstrate regulatory maturity. Programs without such procedures may create unpredictable responses to your findings.

Consider the unique vulnerability classes prevalent in healthcare applications including medical device integration vulnerabilities, HL7/FHIR protocol security issues, and electronic health record (EHR) system specific flaws. Programs that include these specialized attack surfaces in scope provide opportunities for hunters with healthcare-specific expertise.

### Government and Public Sector Programs

Government programs operate under unique regulatory and procurement frameworks that significantly affect selection criteria. These programs often have formalized testing methodologies, strict authorization requirements, and specific reporting obligations that differ from commercial programs.

Evaluate the program's authorization framework carefully. Government programs typically require specific authorization documents, background checks, or registration processes before testing can begin. Programs with clear, accessible authorization processes are more practical than those with bureaucratic requirements that create significant delays.

Assess the program's vulnerability disclosure requirements. Government programs may have mandatory reporting requirements that affect your disclosure timeline and process. Programs with flexible disclosure timelines that accommodate standard coordinated disclosure practices are more hunter-friendly.

Consider the technology stack implications for government targets. Government applications often use legacy systems, custom frameworks, and specialized security controls that differ from commercial technologies. Programs targeting these systems require specialized knowledge that creates natural barriers to competition.

Evaluate the program's payment mechanisms and timeline. Government procurement processes can create significant delays in bounty payments. Programs with established payment processes that bypass standard procurement timelines provide more predictable returns.

### Cryptocurrency and DeFi Programs

Cryptocurrency and DeFi programs have unique characteristics that require specialized selection criteria. These programs often operate in rapidly evolving regulatory environments with varying legal frameworks across jurisdictions. The technical complexity of smart contract security creates opportunities for specialized hunters.

Prioritize programs with clear smart contract audit requirements and established testing methodologies. Programs that provide testnet environments for safe testing reduce risk while maintaining effectiveness. Programs that require testing on mainnet create higher risk but potentially higher rewards.

Assess the program's technical depth requirements. DeFi vulnerability classes including reentrancy, flash loan attacks, oracle manipulation, and economic exploitation require specialized knowledge beyond standard web application security. Programs targeting complex DeFi protocols require correspondingly deep technical expertise.

Evaluate the program's response to critical vulnerabilities. The cryptocurrency space moves quickly, and programs that respond rapidly to critical findings prevent exploitation and protect both the protocol and the hunting community. Programs with slow response times create risk for both hunters and users.

Consider the unique legal considerations for cryptocurrency programs. Some jurisdictions have specific regulations regarding security testing of financial protocols. Programs with clear legal frameworks and safe harbor provisions specific to cryptocurrency provide more secure testing environments.

### Cloud and SaaS Programs

Cloud and SaaS programs present unique selection criteria due to the shared responsibility model and multi-tenant architecture patterns common in cloud environments. These programs often have complex scope definitions that include multiple interconnected services and APIs.

Prioritize programs with clear shared responsibility documentation that defines the boundaries between provider and customer security obligations. Programs with ambiguous shared responsibility boundaries create uncertainty about what constitutes authorized testing.

Assess the program's multi-tenant architecture implications. SaaS applications with multi-tenant architectures create IDOR and access control opportunities but also increase the potential impact of findings. Programs with clear tenant isolation testing authorization provide structured opportunities for these vulnerability classes.

Evaluate the program's API surface and documentation quality. Cloud and SaaS applications typically expose extensive API surfaces that create testing opportunities. Programs with comprehensive API documentation enable more efficient testing. Programs without documentation require additional reconnaissance effort.

Consider the scalability and performance testing implications. Cloud applications often have auto-scaling and performance optimization features that can affect vulnerability reproduction. Programs that provide guidance on testing in scalable environments help hunters avoid non-reproducible findings.

---

## Selection Criteria Weighting Models

### Model 1: Conservative Hunter Profile

The conservative hunter profile prioritizes stability, predictability, and low risk over maximum potential returns. This profile is appropriate for hunters who depend on bug bounty income for living expenses or who are building their reputation and skills.

**Weighting Distribution**:
- Response Time Reliability: 25%
- Bounty Consistency: 25%
- Scope Clarity: 20%
- Community Reputation: 15%
- Bounty Range: 10%
- Competition Level: 5%

**Selection Criteria**:
Programs selected under this model should have response time SLAs under 72 hours, historical bounty payments within 20% of advertised ranges, explicit scope documentation, positive community feedback, and moderate competition levels. This model deliberately sacrifices maximum bounty potential for reliable, predictable returns.

### Model 2: Balanced Hunter Profile

The balanced hunter profile seeks to optimize the tradeoff between stability and upside potential. This profile is appropriate for hunters with stable alternative income who can tolerate some variability in bug bounty returns.

**Weighting Distribution**:
- Effective Hourly Rate: 20%
- Bounty Consistency: 15%
- Response Time: 15%
- Scope Clarity: 15%
- Community Reputation: 10%
- Bounty Range: 10%
- Competition Level: 10%
- Technology Match: 5%

**Selection Criteria**:
Programs selected under this model should demonstrate strong effective hourly rates, consistent bounty payments, reasonable response times, clear scope, positive community reputation, attractive bounty ranges, manageable competition, and alignment with your technology expertise. This model balances multiple factors to achieve optimal overall returns.

### Model 3: Aggressive Hunter Profile

The aggressive hunter profile prioritizes maximum upside potential over stability and predictability. This profile is appropriate for hunters with stable alternative income who can tolerate significant variability in bug bounty returns.

**Weighting Distribution**:
- Bounty Range: 25%
- Technology Match: 20%
- Competition Level: 15%
- Effective Hourly Rate: 15%
- Scope Breadth: 10%
- Response Time: 5%
- Community Reputation: 5%
- Bounty Consistency: 5%

**Selection Criteria**:
Programs selected under this model should have high maximum bounty ranges, strong alignment with your technology expertise, lower competition levels, demonstrated effective hourly rates, broad scope, and reasonable response times. This model deliberately sacrifices stability and predictability for maximum potential returns.

### Model 4: Specialist Hunter Profile

The specialist hunter profile prioritizes programs where your specialized knowledge provides significant competitive advantages. This profile is appropriate for hunters with deep expertise in specific vulnerability classes, technology stacks, or industry verticals.

**Weighting Distribution**:
- Technology Match: 30%
- Industry Alignment: 20%
- Effective Hourly Rate: 15%
- Competition Level: 10%
- Bounty Range: 10%
- Scope Clarity: 10%
- Response Time: 5%

**Selection Criteria**:
Programs selected under this model should have strong alignment with your specialized expertise, industry verticals where you have domain knowledge, demonstrated effective hourly rates for your specialization, reduced competition due to specialized requirements, attractive bounty ranges, clear scope, and reasonable response times. This model leverages specialized knowledge to access opportunities unavailable to generalist hunters.

---

## Seasonal and Cyclical Selection Patterns

### Q1 Planning Season (January-March)

The first quarter represents planning season for most organizations, with annual budgets being allocated and security initiatives being planned. This creates specific opportunities for program selection.

**Characteristics**:
- New programs launching with fresh budgets
- Scope expansions as organizations implement security roadmaps
- Increased bounty ranges as budgets are allocated
- Competition potentially lower as hunters emerge from holiday periods

**Selection Strategy**:
Prioritize newly launched programs that represent fresh organizational investment in security. Target programs that recently expanded scope to include new initiatives. Monitor budget announcements that signal increased security investment. Leverage the post-holiday period when competition may be temporarily reduced.

### Q2 Implementation Season (April-June)

The second quarter represents implementation season when planned security initiatives are being executed. This creates opportunities related to new features, applications, and scope additions.

**Characteristics**:
- New features and applications being launched
- Scope expansions to include newly developed systems
- Increased testing activity as programs mature
- Competition increasing as the hunting community converges on programs

**Selection Strategy**:
Target programs with recently launched features that may not have been thoroughly tested. Monitor scope expansion announcements that include new attack surface. Focus on programs where your early testing provides first-mover advantages. Balance exploration of new scope with exploitation of established targets.

### Q3 Assessment Season (July-September)

The third quarter represents assessment season when organizations evaluate the effectiveness of their security programs and plan adjustments. This creates opportunities related to program changes and improvements.

**Characteristics**:
- Program reviews and adjustments
- Bounty structure modifications
- Scope reevaluations
- Competition stabilizing as programs mature

**Selection Strategy**:
Monitor programs undergoing bounty structure changes for potential opportunities. Target programs that are expanding scope based on mid-year assessments. Evaluate programs that are improving their processes based on hunter feedback. Adjust your portfolio based on program performance data from the first half of the year.

### Q4 Budget Season (October-December)

The fourth quarter represents budget season when organizations plan for the following year and attempt to utilize remaining budgets. This creates specific opportunities related to year-end spending and planning.

**Characteristics**:
- Increased bounty spending as budgets are utilized
- New program launches before year-end
- Competition potentially increasing with year-end financial motivations
- Programs potentially more generous with bounties to utilize remaining budgets

**Selection Strategy**:
Target programs with remaining budget allocations that may result in more generous bounty payments. Monitor new program launches that represent year-end investment decisions. Balance increased competition with the potential for higher bounty payouts. Plan your own portfolio strategy for the coming year based on Q4 program behavior.

---

## Technology Stack Selection Matrix

### Web Application Stacks

| Stack Type | Common Vulnerabilities | Competition Level | Bounty Potential | Recommended Priority |
|------------|----------------------|-------------------|------------------|---------------------|
| React/Angular SPA | XSS, API IDOR, Token Issues | High | Medium-High | Medium |
| WordPress/CMS | Plugin Vulns, SQLi, Auth Bypass | Very High | Low-Medium | Low |
| Django/Rails | SQLi, Auth Bypass, Deserialization | Medium | Medium-High | High |
| Node.js/Express | Prototype Pollution, Auth Bypass | Medium | Medium-High | High |
| Java/Spring | Deserialization, SQLi, SSRF | Medium | High | High |
| PHP/Laravel | SQLi, File Upload, Auth Bypass | High | Medium | Medium |

### API and Microservices Stacks

| Stack Type | Common Vulnerabilities | Competition Level | Bounty Potential | Recommended Priority |
|------------|----------------------|-------------------|------------------|---------------------|
| REST API | IDOR, Auth Bypass, Rate Limiting | Medium | Medium-High | High |
| GraphQL | Introspection, Auth Bypass, Injection | Low-Medium | High | Very High |
| gRPC | Auth Bypass, Injection, DoS | Low | High | Very High |
| WebSocket | Auth Bypass, Injection, DoS | Low | Medium-High | High |

### Mobile Application Stacks

| Stack Type | Common Vulnerabilities | Competition Level | Bounty Potential | Recommended Priority |
|------------|----------------------|-------------------|------------------|---------------------|
| React Native | JS Injection, Insecure Storage | Medium | Medium | Medium |
| Flutter | Insecure Storage, SSL Pinning | Low-Medium | Medium-High | High |
| Native iOS | Keychain, Runtime Manipulation | Medium | High | High |
| Native Android | SharedPrefs, Root Detection | Medium | High | High |

### Infrastructure and Cloud Stacks

| Stack Type | Common Vulnerabilities | Competition Level | Bounty Potential | Recommended Priority |
|------------|----------------------|-------------------|------------------|---------------------|
| AWS | IAM Misconfig, SSRF, Metadata | Medium | High | High |
| Azure | Managed Identity, RBAC, SSRF | Medium | High | High |
| GCP | Service Account, Metadata, IAM | Medium | High | High |
| Kubernetes | RBAC, Secret Exposure, API | Low-Medium | High | Very High |

---

## Program Lifecycle Analysis

### Launch Phase Characteristics

Programs in the launch phase are newly established and typically have fresh scope, generous bounties to attract hunters, and relatively low competition. However, they also have unproven triage processes and uncertain organizational commitment.

**Selection Criteria for Launch Phase**:
Evaluate the organization's security maturity indicators including team size, prior security initiatives, and public commitment to security research. Programs backed by experienced security teams are more likely to provide positive experiences than programs launched by organizations without security expertise.

Assess the program's launch quality including documentation clarity, scope definitions, and response time commitments. High-quality launch documentation indicates organizational investment in the program. Poor documentation indicates potential organizational issues.

### Growth Phase Characteristics

Programs in the growth phase are expanding their scope, bounty ranges, and hunter community. These programs typically have improving triage processes and demonstrated organizational commitment.

**Selection Criteria for Growth Phase**:
Evaluate the program's growth trajectory including scope expansions, bounty increases, and hunter community growth. Programs with positive growth trajectories offer increasing opportunities over time. Programs with stagnant or declining trajectories may indicate organizational issues.

Assess the program's ability to scale its triage processes with increasing submission volumes. Programs that maintain response times and triage quality as they grow demonstrate operational competence. Programs that degrade as they grow demonstrate capacity limitations.

### Maturity Phase Characteristics

Programs in the maturity phase have established processes, stable scope, and predictable bounty structures. These programs offer reliable returns but may have reduced upside potential due to established competition.

**Selection Criteria for Maturity Phase**:
Evaluate the program's stability and consistency. Mature programs should demonstrate consistent response times, bounty payments, and triage quality over extended periods. Inconsistency in mature programs indicates potential organizational issues.

Assess the program's innovation and adaptation capabilities. Mature programs that continue to expand scope, adjust bounty structures, and improve processes demonstrate ongoing organizational commitment. Programs that stagnate may be losing organizational support.

### Decline Phase Characteristics

Programs in the declining phase may be reducing scope, decreasing bounties, or experiencing deteriorating triage quality. These programs represent declining returns that may not justify continued investment.

**Selection Criteria for Decline Phase**:
Evaluate the program's trajectory and identify specific decline indicators. Programs experiencing temporary setbacks due to organizational changes may recover, while programs with fundamental structural issues are less likely to improve.

Assess the program's communication about changes and challenges. Programs that transparently communicate challenges and provide clear timelines for improvement demonstrate good faith. Programs that deny or ignore decline indicators may not be committed to recovery.

---

## Advanced Selection Analytics

### Predictive Scoring Model

Develop a predictive scoring model that forecasts program value based on observable characteristics. This model combines historical performance data with current indicators to estimate future returns.

**Model Inputs**:
- Historical bounty data (average, median, range)
- Response time trends
- Community sentiment trends
- Scope change frequency
- Competition level estimates
- Technology stack alignment scores

**Model Output**:
A composite score that predicts the expected effective hourly rate for each program, enabling direct comparison across programs with different characteristics.

### Competitive Intelligence Analysis

Analyze the competitive landscape for each program to estimate the probability of finding unique vulnerabilities. This analysis considers the number of active hunters, their skill levels, and the program's vulnerability density.

**Analysis Components**:
- Active hunter count estimates from disclosed reports
- Hunter skill level assessment based on submission quality
- Vulnerability density estimates from historical findings
- Competition trend analysis (increasing, stable, declining)

### Risk-Adjusted Return Calculation

Calculate risk-adjusted returns that account for the uncertainty of bug bounty hunting. This calculation considers not just expected returns but the variance of returns and the probability of zero-return periods.

**Risk Factors**:
- Bounty payment reliability
- Triage outcome uncertainty
- Scope change risk
- Competition intensity variability
- Organizational stability

---

## Selection Decision Framework

### Decision Tree for Program Evaluation

**Level 1: Basic Viability**
- Is the program in scope for your skills? (Yes/No)
- Does the program offer financial bounties? (Yes/No)
- Is the program on a platform you use? (Yes/No)
If any answer is No, eliminate the program.

**Level 2: Quality Assessment**
- Response time SLA under 14 days? (Score 1-5)
- Scope clarity adequate for testing? (Score 1-5)
- Community reputation acceptable? (Score 1-5)
Average score below 3.0 indicates potential problems.

**Level 3: Opportunity Assessment**
- Effective hourly rate estimate above your minimum? (Yes/No)
- Competition level manageable? (Yes/No)
- Technology stack alignment strong? (Yes/No)
At least two Yes answers required for advancement.

**Level 4: Strategic Fit**
- Aligns with your specialization strategy? (Yes/No)
- Contributes to portfolio diversification? (Yes/No)
- Provides learning or relationship value? (Yes/No)
At least one Yes answer required for selection.

### Decision Documentation Template

For each program you select, document your decision rationale including:
- Key factors that justified selection
- Risks you identified and accepted
- Expected returns and timeline
- Success criteria for the engagement
- Review schedule and exit criteria

---

## Quick Reference Decision Matrix

| Scenario | Recommended Action | Priority |
|----------|-------------------|----------|
| New program with strong team | Evaluate and potentially fast-track | High |
| High bounty, unclear scope | Proceed with caution, limit initial investment | Medium |
| Low bounty, clear scope | Include in portfolio for consistent returns | Medium |
| Strong community reputation | Prioritize for engagement | High |
| Weak community reputation | Avoid or minimal test investment | Low |
| Technology stack match | Include regardless of other factors | High |
| High competition | Focus on niche approach or skip | Low-Medium |
| Fast response time | Include for efficient returns | High |
| Slow response time | Include only if bounties compensate | Low-Medium |

---

*Last Updated: 2026-06-13*
*Version: 2.0*
*Author: Prompt-Hunting Strategy Framework*
