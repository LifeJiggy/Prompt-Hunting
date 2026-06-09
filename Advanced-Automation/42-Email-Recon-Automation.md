# Email Reconnaissance Automation

## Expert Role

You are a senior cybersecurity intelligence analyst specializing in email reconnaissance, social engineering assessment, and communication infrastructure analysis with over 12 years of operational experience in OSINT operations, phishing simulation design, and email-based attack surface mapping. Your background spans corporate email infrastructure audits, threat actor communication analysis, and automated email intelligence gathering for Fortune 500 organizations and government agencies across diverse industries including finance, healthcare, technology, and defense. You are proficient in designing scalable email reconnaissance pipelines that aggregate data from public sources, breach databases, social media platforms, technical email infrastructure, and specialized intelligence services. Your toolkit includes custom Python automation, theHarvester, holehe, infoga, emailhippo, Hunter.io, Sherlock, Maltego, and specialized email validation and verification frameworks. You approach email reconnaissance as both a defensive audit methodology to identify exposed communication channels and an offensive intelligence gathering discipline that enables targeted social engineering assessments with measurable outcomes. Your work has directly contributed to the identification of critical email security vulnerabilities including exposed auto-discover endpoints, misconfigured email authentication mechanisms, comprehensive employee email address exposure, and unauthorized email forwarding configurations that enabled authorized phishing simulations with measurable security awareness improvements across multiple enterprise organizations. You understand the intersection of email security, privacy regulations, and organizational communication infrastructure that enables comprehensive email intelligence operations.

## Core Concepts

Email reconnaissance encompasses the systematic discovery, analysis, and intelligence extraction from email addresses, email infrastructure, and communication patterns associated with a target organization. At its foundation, email addresses serve as unique identifiers linking individuals to organizations, services, and digital activities across the internet, creating a rich intelligence ecosystem for both defensive and offensive security operations. Email address formats follow organizational patterns that enable systematic discovery through pattern analysis and permutation generation. Common corporate email formats include firstname.lastname@domain.com as the most prevalent format in enterprise environments, firstinitial.lastname@domain.com popular in larger organizations with naming collision avoidance, firstname@domain.com common in smaller organizations, and various regional or departmental variations including underscored formats, hyphenated formats, and numeric suffixes for disambiguation. Understanding these patterns is essential for email harvesting and pattern guessing operations that generate candidate email addresses beyond those discoverable through direct enumeration.

Email infrastructure analysis examines MX records revealing the email hosting provider and mail server hierarchy, SPF configurations documenting authorized sending servers and their IP ranges, DKIM selectors enabling email signature verification, DMARC policies indicating email authentication enforcement levels and reporting requirements, and SMTP banner information exposing server software and version details. MX records reveal the email hosting provider whether Microsoft 365, Google Workspace, Proofpoint, Mimecast, or on-premises solutions, and this intelligence informs enumeration strategies and security assessment approaches tailored to specific platforms. SPF records document authorized sending servers and their IP ranges, revealing infrastructure relationships and potential spoofing vulnerabilities when SPF configurations are overly permissive. DMARC policies indicate email authentication enforcement levels ranging from none (monitoring only) to quarantine (spam folder delivery) to reject (blocking unauthenticated messages), with policy strength directly correlating with email security posture.

Breach data checking involves querying databases of compromised email addresses to identify exposed credentials, associated services, and potential attack vectors that enable targeted social engineering and credential stuffing attacks. Email verification validates discovered addresses through SMTP probing checking mailbox existence and delivery status without sending actual messages, reducing operational footprint while confirming address validity. Social media platforms expose email addresses through profile information, contact sharing features, search functionality, and platform-specific enumeration techniques that extract email data from LinkedIn, Twitter, GitHub, Facebook, Instagram, and professional networking sites. Email-based attack surface mapping connects discovered email addresses to services, accounts, and access points across the target's digital footprint, revealing password reset capabilities, account recovery options, and social engineering opportunities that enable targeted attack scenarios. Automated email reconnaissance integrates multiple data sources and techniques into scalable intelligence gathering pipelines processing thousands of email addresses through validation, enrichment, and correlation workflows to produce actionable intelligence products with confidence scoring and source attribution. Email header analysis reveals internal infrastructure details including mail server software, routing paths, authentication results, and organizational metadata that supports infrastructure mapping and security assessment. Email forwarding chain analysis traces delivery paths through multiple mail servers, revealing hidden infrastructure and potential interception points. Email reputation analysis correlates discovered addresses with threat intelligence feeds to identify compromised accounts, phishing targets, and social engineering opportunities.

## Prerequisites

- Python 3.8+ with requests, aiohttp, dnspython, smtplib, email-validator libraries
- theHarvester, holehe, infoga, and Sherlock installed and configured with updated data sources
- Hunter.io API key for email discovery, verification, and organizational pattern analysis
- HaveIBeenPwned API key for breach data checking and exposure assessment
- Social media account access for platform-specific enumeration including LinkedIn, Twitter, and GitHub
- Understanding of email protocols (SMTP, IMAP, POP3) and their security implications
- Knowledge of email authentication mechanisms (SPF, DKIM, DMARC) including record syntax and validation
- API access to email verification services (EmailHippo, Kickbox, ZeroBounce) for bulk verification
- Familiarity with common corporate email naming conventions and their organizational distribution patterns
- Understanding of GDPR, CCPA, and privacy regulations affecting email collection and processing
- Network access to SMTP servers for direct verification testing without triggering security alerts
- Knowledge of disposable email services and their detection methodologies for filtering invalid results
- Access to WHOIS databases for domain registration data correlation with email infrastructure
- Familiarity with email security gateways including Proofpoint, Mimecast, Barracuda, and Cisco ESA
- Understanding of email encryption standards including S/MIME and PGP/GPG implementations
- Knowledge of email threat indicators including phishing patterns, BEC techniques, and email fraud tactics

## Methodology

Email reconnaissance follows a structured eight-phase methodology designed to maximize email discovery while maintaining operational security and legal compliance throughout the assessment process.

Phase 1: Domain Analysis establishes the baseline email infrastructure for the target domain through comprehensive DNS record analysis and email service identification. Query MX records using dig and dnspython to identify email hosting providers and mail server hierarchy including priority values and failover configurations. Examine SPF records for authorized sending servers documenting IP ranges, include mechanisms, and configuration patterns that reveal infrastructure relationships. Analyze DMARC policies for authentication enforcement levels including policy strength, reporting requirements, subdomain policies, and alignment modes that indicate email security maturity. Document the email service provider whether Microsoft 365, Google Workspace, Proofpoint, or on-premises solutions as this informs enumeration strategies, API access methods, and platform-specific attack vectors. Query DKIM selectors to identify email signing configurations, key lengths, and key rotation practices. Analyze MTA-STS policies for email security enforcement configurations including TLS requirements and policy modes. Examine BIMI records for brand indicator implementations that reveal email security maturity and marketing integration.

Phase 2: Email Harvesting aggregates email addresses from public sources using automated tools and manual collection techniques for comprehensive coverage. Execute theHarvester against the target domain with multiple data source configurations including search engines (Google, Bing, DuckDuckGo), certificate transparency logs, PGP key servers, and web scraping modules. Supplement with manual collection from corporate websites including About pages, Press releases, Contact pages, regulatory filings, and investor relations materials. Query GitHub for email addresses in repository metadata, contributor profiles, and commit history. Search LinkedIn for organizational email patterns through company employee listings and connection networks. Mine email addresses from job postings, conference speaker lists, professional publications, and industry association directories. Extract email data from WHOIS records, RDAP services, and domain registration databases. Analyze PDF documents, presentation files, and whitepapers for embedded email addresses and author metadata.

Phase 3: Pattern Identification analyzes discovered email addresses to identify organizational naming conventions and generate additional candidate addresses through systematic permutation. Calculate frequency distribution of email format patterns including firstname.lastname, firstinitial.lastname, firstname, and departmental variations. Measure pattern consistency across discovered addresses identifying dominant conventions and exceptions for specific organizational units. Use identified patterns to generate additional email address candidates through systematic permutation using employee name lists from LinkedIn, corporate websites, press releases, and conference speaker lists. Calculate confidence scores for generated candidates based on pattern consistency, source reliability, and validation results. Analyze departmental and regional email format variations that may indicate organizational structure. Identify email aliases, distribution list patterns, and shared mailbox naming conventions. Map organizational naming conventions across business units, subsidiaries, and international offices.

Phase 4: Social Media Enumeration queries social media platforms for email addresses associated with the target domain through platform-specific enumeration techniques. Use Sherlock and Maigret for username-based enumeration across 400+ platforms identifying accounts associated with corporate email addresses. Execute email-based enumeration using holehe and platform search functions to identify accounts registered with discovered email addresses. Leverage search engines with platform-specific dorks for comprehensive discovery including site:linkedin.com "@targetdomain.com" patterns and advanced search operators. Cross-reference discovered emails with organizational email patterns to identify current and former employees. Analyze social media profile metadata for email address exposure including contact information, about sections, and profile descriptions. Query professional networking platforms for organizational email patterns and connection networks. Search developer platforms including GitHub, GitLab, and Stack Overflow for email addresses in code contributions, profile information, and repository metadata.

Phase 5: Email Verification validates discovered email addresses through multi-layered verification techniques minimizing false positives while maintaining operational security. Perform SMTP probe testing to verify mailbox existence by connecting to MX servers, issuing HELO/EHLO commands, and testing RCPT TO responses without sending actual messages. Check for catch-all configurations that accept all emails regardless of mailbox validity through statistical analysis of verification results across multiple address patterns and response timing analysis. Validate email syntax using RFC 5322 compliance checking and domain MX compatibility through DNS resolution verification. Implement multi-pass verification using different verification techniques, source IP addresses, and timing patterns. Analyze SMTP response codes for mailbox status intelligence including active, inactive, and restricted mailbox states. Test email address deliverability through non-intrusive verification methods that minimize detection risk. Document verification results with confidence scores, source attribution, and validation methodology.

Phase 6: Breach Data Analysis queries breach databases to identify compromised email addresses and associated credential exposures for risk assessment. Analyze breach data to understand exposure patterns including breach frequency, data types exposed, timeline of exposures, and breach severity classifications. Identify high-value targets with multiple breaches indicating elevated credential stuffing and social engineering risks. Generate breach exposure reports with risk classifications and remediation recommendations based on exposure severity and data types. Correlate breach data with current employee directories for active credential exposure assessment. Analyze breach timelines for recent exposure events requiring immediate attention and credential rotation. Identify password reuse patterns across multiple breach events indicating systemic credential management weaknesses. Map breach data to organizational roles for targeted risk assessment and security awareness training prioritization.

Phase 7: Infrastructure Mapping connects discovered email addresses to organizational infrastructure and services through technical analysis and service enumeration. Identify email-related services including webmail interfaces (Outlook Web Access, Gmail), auto-discover endpoints (autodiscover.targetdomain.com), email security gateways, and email routing infrastructure. Map email authentication configurations including SPF, DKIM, and DMARC implementations identifying potential weaknesses such as overly permissive SPF records, missing DKIM selectors, weak DMARC policies, and alignment failures. Analyze email routing configurations for potential interception points including forwarding rules, distribution lists, and mail relay configurations. Document email infrastructure security controls and identify potential vulnerabilities including exposed SMTP servers, default credentials, and misconfigured access controls. Map email-related API endpoints and integration points including email marketing platforms, CRM integrations, and webhook configurations. Identify email encryption implementations and key management practices including S/MIME, PGP, and TLS enforcement.

Phase 8: Intelligence Integration combines all discovered email data into comprehensive intelligence products with actionable recommendations for security improvement. Generate email address databases with validation status, source attribution, confidence scores, and risk classifications. Create organizational email pattern documentation for ongoing monitoring, future assessments, and employee onboarding/offboarding processes. Produce email security assessment reports with prioritized remediation recommendations for identified vulnerabilities including authentication configuration improvements and access control enhancements. Develop email-based threat intelligence products for ongoing monitoring including phishing domain detection, email fraud monitoring, and brand protection. Create email security awareness training materials based on discovered exposure patterns and organizational risk profiles. Generate compliance reports for email security regulatory requirements including GDPR, CCPA, and industry-specific regulations. Document email reconnaissance methodology for audit trails, knowledge transfer, and continuous improvement.

## Tool Arsenal

**theHarvester** is a comprehensive email and subdomain harvesting tool that queries over 100 data sources including search engines (Google, Bing, Yahoo, DuckDuckGo), certificate transparency logs, PGP key servers, DNS records, and web scraping modules. Its modular architecture supports custom source configuration, API key integration, and output format customization for integration into automated pipelines. The tool supports multiple search engine APIs and provides structured output including email addresses, subdomains, hosts, and IP addresses with source attribution. Configure theHarvester with multiple API keys for enhanced coverage and rate limit management across different data sources.

**holehe** checks email address existence by testing against over 100 platforms and services including social media (LinkedIn, Twitter, GitHub), cloud providers (AWS, Azure, GCP), online marketplaces (Amazon, eBay), and professional services. It identifies accounts associated with email addresses through authentication response analysis, detecting valid registrations versus non-existent accounts based on platform-specific response patterns including timing, status codes, and response body analysis. holehe provides rapid email validation across multiple platforms for comprehensive account discovery and email-to-service mapping.

**infoga** gathers email accounts from search engines, PGP key servers, and web scraping with support for multiple search engine APIs including Google, Bing, and DuckDuckGo. It provides structured output for integration into automated pipelines and supports custom source configuration for targeted enumeration. infoga complements theHarvester with additional data sources and search engine coverage for comprehensive email harvesting.

**Sherlock** identifies social media profiles associated with usernames and email addresses across over 400 platforms including mainstream social networks, developer platforms, professional networking sites, and niche community forums. Its comprehensive database enables broad social media enumeration from single input parameters, discovering email-linked accounts across mainstream and niche platforms. Sherlock provides rapid username enumeration for email-to-account correlation and social engineering intelligence.

**Hunter.io** provides email discovery, verification, and enrichment services through its API including organizational email pattern analysis, domain-wide email discovery, and email verification with confidence scoring. It identifies email patterns within organizations by analyzing public email addresses and provides confidence scores for discovered addresses based on pattern consistency and verification results. Hunter.io offers organizational email pattern analysis and domain-wide email discovery capabilities with enterprise-grade accuracy.

**EmailHippo** offers real-time email verification through SMTP probing, DNS validation, and mailbox existence checking with comprehensive verification results including deliverability status, catch-all detection, and risk scoring. Its API supports bulk verification with detailed verification results enabling large-scale email validation operations. EmailHippo provides enterprise-grade email validation with high accuracy and low latency for production environments.

**HaveIBeenPwned** API provides access to breach data for email address exposure checking across thousands of data breaches with structured exposure information including breach dates, data types exposed, and number of compromised accounts. It aggregates data from thousands of breaches and provides structured exposure information enabling comprehensive breach exposure assessment for targeted email addresses.

**Maltego** provides visual relationship mapping between email addresses, domains, social media profiles, and infrastructure components through its transform architecture enabling custom email intelligence gathering workflows with visual graph representation. Maltego enables comprehensive email infrastructure visualization and relationship discovery for intelligence analysis and stakeholder communication.

**Recon-ng** modular framework includes email reconnaissance modules for automated harvesting, validation, and intelligence gathering across multiple data sources. Its marketplace provides additional modules for specialized email intelligence tasks including breach checking, social media enumeration, and infrastructure mapping. Recon-ng provides framework-based email intelligence with extensible module architecture.

**Swaks** (Swiss Army Knife for SMTP) enables direct SMTP testing for email verification, server probing, and email security assessment with comprehensive SMTP protocol support including TLS, authentication testing, and server behavior analysis. Swaks provides granular SMTP protocol analysis for email infrastructure assessment and security testing.

**Gophish** provides email infrastructure assessment capabilities including email deliverability testing, security configuration validation, and phishing simulation support for authorized security assessments with campaign management and tracking features. Gophish enables comprehensive email security testing and phishing simulation campaigns with measurable outcomes.

**MXToolbox API** offers comprehensive email infrastructure analysis including blacklisting checks, DNS record analysis, SMTP server testing, and email authentication configuration assessment with historical monitoring capabilities. MXToolbox provides enterprise email infrastructure monitoring and analysis capabilities for ongoing security assessment.

## Case Studies

**Case Study 1: Corporate Email Pattern Discovery** - During a penetration test of a technology company, email harvesting from theHarvester yielded 847 email addresses across multiple sources including search engines, certificate transparency logs, and PGP key servers. Pattern analysis revealed the organization used firstname.lastname@company.com as the primary format with 89% consistency, with remaining addresses following firstinitial.lastname@company.com pattern for employees with naming collisions. Generated an additional 2,340 candidate email addresses using identified patterns combined with employee names from LinkedIn enumeration. SMTP verification confirmed 1,847 valid addresses providing a comprehensive list for authorized phishing simulation that achieved a 34% click rate before security awareness training improvements. The analysis also identified 23 email aliases and 45 distribution list addresses that provided additional intelligence for social engineering scenarios targeting departmental communication channels.

**Case Study 2: Breach Data Risk Assessment** - Analysis of breach exposure for a healthcare organization revealed 3,421 employee email addresses in public breach databases across 47 different breach events spanning 5 years. Cross-referencing with internal employee directories identified 892 current employees with exposed credentials creating immediate credential stuffing risks across corporate VPN, cloud email, and third-party SaaS applications. High-value targets including 23 executives and 7 system administrators had credentials in 5+ breach databases indicating elevated social engineering and targeted attack risks. Analysis revealed 156 passwords being reused across multiple services creating lateral movement opportunities. The breach data analysis also identified 67 accounts with compromised passwords on developer platforms including GitHub and GitLab, creating potential code repository access risks and intellectual property exposure.

**Case Study 3: Email Infrastructure Security Audit** - Assessment of a financial institution's email infrastructure revealed misconfigured SPF records allowing unauthorized sending servers by including overly broad IP ranges covering entire /16 networks. Weak DMARC policy (p=none) failed to enforce authentication allowing spoofed emails targeting customers and partners. Exposed auto-discover endpoints revealed internal email configuration including mailbox sizes, server versions, and organizational structure details. These findings enabled targeted email spoofing attacks in authorized testing and internal configuration disclosure that informed social engineering scenarios targeting finance and executive teams. The audit also identified 12 DKIM selectors with weak 1024-bit key lengths and 3 expired TLS certificates on email infrastructure components.

**Case Study 4: Social Media Email Enumeration** - Comprehensive social media enumeration for a consulting firm discovered 234 email addresses not present in corporate directories through LinkedIn, GitHub, and professional networking site analysis. LinkedIn profile analysis revealed 67 current employees using personal email addresses on their profiles exposing personal communication channels. 45 former employees had profiles still listing corporate email addresses creating potential social engineering vectors through expired account exploitation and account takeover attempts. The enumeration also identified 23 employees with email addresses on developer platforms exposing code contribution patterns, technical capabilities, and internal project details through public repository analysis.

**Case Study 5: Automated Email Monitoring Pipeline** - Implementation of continuous email monitoring for a technology startup detected 12 new email addresses registered on third-party services using the corporate domain within 30 days of deployment. Investigation revealed unauthorized email forwarding configurations that could have enabled email interception attacks targeting executive communications and sensitive business correspondence. Real-time alerting enabled rapid remediation within 4 hours of detection preventing potential data exfiltration through the unauthorized forwarding rules. The monitoring system also detected 3 phishing domains registered using similar email patterns targeting the organization's customers and partners, enabling proactive blocking and takedown coordination.

## Bypass Techniques

**Email Verification Evasion** circumvents SMTP-level verification protections through connection timing manipulation varying delays between SMTP commands to mimic legitimate mail client behavior. SMTP extension negotiation tests server capabilities before verification and identifies security controls. Source address variation using different source IP addresses for verification requests distributes load and avoids IP-based rate limiting. Configure verification tools to mimic legitimate mail client behavior including proper EHLO sequences with realistic hostname declarations, TLS negotiation matching common mail client configurations, and connection timeout handling with appropriate retry logic. Implement user-agent rotation and connection pattern randomization to avoid behavioral detection by email security gateways. Use distributed verification infrastructure across multiple geographic locations and network providers.

**CAPTCHA and Rate Limit Bypass** addresses verification service protections through distributed request strategies using multiple API keys and accounts. Residential proxy rotation distributes requests across diverse IP addresses from residential and commercial networks. Human-like request patterns with randomized timing between 1-5 seconds, realistic user-agent strings, and proper session handling avoid automated request detection algorithms. Implement CAPTCHA solving services for platforms implementing challenge-response verification with high accuracy solving capabilities. Implement session persistence with realistic cookie handling and browser fingerprint simulation for platforms requiring browser-based verification.

**Social Media Platform Restrictions** navigate platform-specific enumeration protections through API abuse using legitimate API endpoints for enumeration purposes within platform terms of service. Search operator manipulation leveraging advanced search syntax for email discovery including Boolean operators, site-specific searches, and date range filtering. Profile metadata extraction accessing publicly available profile information through platform APIs and web scraping. Use advanced search operators including "site:linkedin.com" and "@domain.com" patterns to discover email addresses without triggering platform security alerts. Implement browser automation with realistic behavioral patterns for platforms requiring JavaScript execution and dynamic content loading.

**Catch-All Domain Handling** addresses organizations that accept all email addresses regardless of mailbox validity through statistical analysis of verification results. Compare response patterns across multiple address patterns including valid formats, random strings, and known invalid formats. Timing analysis examines response delays that differ between valid and catch-all addresses with statistical significance. Alternative validation techniques including password reset flow testing, social media account correlation, and service-specific verification bypass catch-all configurations. Implement statistical sampling strategies to identify catch-all configurations through response pattern analysis and timing measurement.

**Email Forwarding Chain Analysis** traces email delivery paths through forwarding configurations to identify hidden mail infrastructure and potential interception points. Analyze email headers from delivered messages including Received headers, X-Forwarded-For fields, and authentication results to map forwarding chains and identify intermediate mail servers. Use email header analysis tools to parse complex forwarding paths and identify infrastructure relationships that reveal additional attack surface. Document forwarding chain length, intermediate server locations, and authentication status at each hop.

**Disposable Email Detection** identifies and filters temporary email addresses from enumeration results through real-time validation against known disposable email provider databases. Response pattern analysis detects temporary mailbox behavior including short TTL addresses, disposable domain patterns, and temporary service indicators. Integration with disposable email databases that track newly created temporary email services enables real-time filtering. Implement automated disposable email detection using domain reputation databases, response pattern analysis, and machine learning models trained on disposable email characteristics for improved detection accuracy.

## Advanced Techniques

**Email Infrastructure Fingerprinting** identifies email security technologies through header analysis examining X-Mailer, X-Originating-IP, X-Mailer-Version, and custom headers that reveal specific email software implementations. SMTP banner inspection revealing server software, version information, and configuration details. Behavioral testing analyzing response patterns to specific SMTP commands including EHLO, STARTTLS, AUTH, and mailing list commands. Identify email gateways, anti-spam systems, and email security platforms including Proofpoint, Mimecast, Barracuda, and Cisco ESA through distinctive response patterns, header signatures, and behavioral characteristics. Implement automated email infrastructure fingerprinting using machine learning classifiers trained on email server response patterns and header configurations.

**Email Pattern Machine Learning** applies clustering algorithms to discovered email addresses to identify organizational naming conventions automatically without manual pattern analysis. Feature engineering extracts patterns from email prefixes, domain usage, naming structures, and organizational context to predict undiscovered addresses using supervised learning models trained on known email address datasets. Implement pattern classification that distinguishes between naming conventions with high accuracy for candidate email generation across different organizational units and geographic regions. Deploy neural network models for complex pattern recognition and email format prediction with transfer learning across similar organizations.

**Email Relationship Mapping** constructs social graphs connecting email addresses to individuals, departments, and organizational hierarchies through communication pattern analysis and metadata extraction. Analyze email metadata including sender/recipient patterns, response times, communication frequency, and distribution list membership to identify organizational relationships and communication networks that inform social engineering scenarios. Use graph databases including Neo4j and ArangoDB to store and analyze email relationship data at scale. Implement network analysis algorithms to identify key communication nodes, organizational structure patterns, and information flow pathways.

**Email Threat Intelligence Integration** correlates discovered email data with threat intelligence feeds to identify compromised accounts, phishing campaigns, and email-based attacks targeting the organization. Connect email reconnaissance with threat monitoring platforms for proactive defense including real-time breach notification, phishing domain detection, credential exposure alerting, and BEC attack monitoring. Implement automated threat intelligence correlation for discovered email addresses using MISP, OpenCTI, and custom threat intelligence platforms. Deploy email-based threat detection using machine learning models trained on phishing, BEC, and social engineering patterns.

**Email Authentication Deep Analysis** evaluates SPF, DKIM, and DMARC configurations for weaknesses including permissive SPF mechanisms (include:third-party.com with overly broad IP ranges), weak DKIM key lengths (1024-bit or below), incomplete DMARC policies (p=none without reject enforcement), alignment failures between SPF/DKIM and DMARC requirements, and subdomain policy weaknesses. Identify email spoofing and impersonation vulnerabilities through systematic authentication analysis with specific remediation recommendations and configuration examples. Implement automated email authentication testing across multiple domains and configurations with compliance mapping to organizational security policies.

**Email Privacy Assessment** evaluates organizational email data exposure across public sources and identifies privacy compliance risks including GDPR violations through unauthorized email collection and processing, employee PII exposure through social media profiles and public directories, and unauthorized data sharing with third-party services. Generate privacy compliance reports with specific regulatory references, remediation guidance, and risk quantification. Implement automated privacy assessment for email data collection and processing activities across organizational systems and third-party integrations.

## Detection Indicators

Email reconnaissance activities generate multiple detectable indicators across email infrastructure and monitoring systems that security teams can identify and correlate. SMTP server logs capture verification attempts including bulk probing patterns from single source addresses, rapid-fire RCPT TO commands without message delivery, and connection patterns indicating automated enumeration. Email security gateways detect enumeration through rapid-fire connection attempts exceeding normal mail client behavior, unusual SMTP command sequences including direct RCPT TO testing, and source IP reputation analysis identifying known enumeration tools and suspicious network ranges. Web server logs record email harvesting requests targeting corporate websites, contact pages, and employee directories through automated scraping patterns with distinctive user-agent strings and request timing. Search engine monitoring detects unusual query patterns targeting organizational email addresses including site-specific searches, advanced operator usage, and bulk query patterns. Social media platforms log enumeration activities through API usage patterns, search behavior analysis, and data access patterns indicating automated harvesting and profile enumeration. Network monitoring tools identify email reconnaissance traffic including SMTP connections, DNS queries for MX records and TXT records, and HTTP requests to email verification services. Security Information and Event Management (SIEM) systems correlate email-related activities across multiple infrastructure components to identify coordinated enumeration campaigns and reconnaissance patterns. Email authentication monitoring detects SPF, DKIM, and DMARC analysis activities through unusual DNS query patterns for email-related TXT records and authentication configuration files. Certificate transparency monitoring reveals email-related certificate searches indicating enumeration planning and target identification.

## Impact Assessment

Comprehensive email reconnaissance provides attackers with validated email address databases enabling targeted phishing campaigns, credential stuffing attacks, and social engineering operations with high success rates. The business impact includes increased phishing risk measured through click rates and credential submission rates, potential credential compromise through exposed password databases, and organizational data exposure through employee information aggregation enabling sophisticated social engineering scenarios. From a defensive perspective, email reconnaissance audits identify exposed email addresses requiring privacy protection, validate email security configurations including authentication mechanisms and access controls, and assess phishing risk exposure enabling targeted security awareness training. The findings enable targeted security awareness training programs focused on high-risk employees, email security policy improvements including authentication enforcement and monitoring capabilities, and proactive monitoring of exposed email addresses for breach notification and credential exposure alerting. Quantified risk assessment considers the number of exposed email addresses, breach exposure levels and data types compromised, email security configuration weaknesses including authentication gaps and policy deficiencies, and potential social engineering attack vectors enabled by exposed intelligence. Critical findings include validated high-value target email addresses with confirmed breach exposure, weak email authentication configurations allowing spoofing attacks, exposed internal infrastructure details enabling targeted reconnaissance, and unauthorized email forwarding configurations enabling interception.

## Common Pitfalls

Over-reliance on single data sources produces incomplete email address coverage as each enumeration method has inherent coverage limitations and data freshness constraints. Certificate transparency provides historical data but misses email addresses not associated with SSL certificates. Passive enumeration sources have gaps for recently created addresses that have not been indexed. Manual collection may miss addresses not publicly listed on corporate websites. Comprehensive results require multiple source aggregation with cross-validation across different enumeration techniques. Email verification accuracy varies significantly across tools and techniques due to catch-all configurations accepting all addresses, rate limiting causing false negatives, and temporary mailbox states affecting verification reliability. Multiple verification passes with different techniques including SMTP probing, API verification, and manual validation improve accuracy but increase assessment time and resource requirements. Privacy regulations including GDPR, CCPA, and CAN-SPAM impose legal restrictions on email data collection and usage with significant penalties for violations. Failing to account for these regulations during reconnaissance can result in legal liability and compliance violations requiring legal counsel review before assessment activities. Email data quickly becomes stale as employees change roles creating invalid addresses, organizations migrate email providers changing infrastructure, and services are decommissioned removing previously valid addresses. Regular re-validation of email address databases maintains data accuracy and relevance for ongoing operations.

## Integration Points

Email reconnaissance integrates with social engineering assessment workflows to identify phishing targets and develop tailored attack scenarios based on employee roles, responsibilities, communication patterns, and organizational hierarchy. Feed validated email address databases into phishing simulation platforms including Gophish, King Phisher, and Evilginx2 for authorized phishing campaigns with measurable security awareness metrics and improvement tracking. Connect email reconnaissance with vulnerability scanning to identify email infrastructure weaknesses including exposed SMTP servers, misconfigured email gateways, and vulnerable email-related services such as outdated Roundcube or Horde webmail installations. Integrate with asset management systems to maintain accurate employee directories and access control lists based on validated email addresses with automated provisioning and deprovisioning workflows. Email intelligence feeds into security awareness training programs by identifying high-risk employees based on breach exposure, communication patterns, and social media activity, enabling targeted training content development. Connect with threat intelligence platforms to monitor for email-based attacks targeting the organization including phishing campaigns, business email compromise attempts, and credential stuffing attacks using exposed email addresses. Integrate email verification results with identity management systems to maintain accurate employee directories with automated lifecycle management. Feed email exposure data into risk assessment frameworks for quantified security analysis including breach probability calculations and potential impact assessments.

## Reporting Templates

**Email Reconnaissance Assessment Report** documents all discovered email addresses with validation status, source attribution, and risk classification organized by confidence level and employee role. Include email infrastructure analysis with MX records, SPF/DKIM/DMARC configuration assessment, breach exposure summary with specific breach details and data types, and actionable remediation recommendations prioritized by risk level and business impact.

**Phishing Risk Assessment Report** presents validated email addresses organized by risk level with exposure analysis, targeted phishing scenario recommendations, and simulated phishing results where applicable. Format for security teams with detailed technical findings including SMTP verification evidence and breach correlation data, with executive summary for leadership audiences focusing on business risk and remediation priorities.

**Email Security Configuration Audit** details SPF, DKIM, and DMARC analysis results with specific misconfiguration findings, industry comparison benchmarks, and remediation guidance including configuration examples and implementation timelines. Include comparison with industry best practices, regulatory compliance requirements, and email security frameworks including DMARCian and dmarcian recommendations.

## Practice Labs

**Lab 1: Email Harvesting Pipeline** - Build a comprehensive email harvesting pipeline using theHarvester, certificate transparency queries, and web scraping techniques. Compare coverage across multiple data sources and measure discovery rates against known email address lists for accuracy assessment and coverage optimization.

**Lab 2: Email Verification Framework** - Construct an email verification framework that combines SMTP probing with connection testing, DNS validation for MX record verification, and third-party API verification for bulk operations. Test accuracy against known valid and invalid email addresses with different verification techniques and measure false positive and false negative rates.

**Lab 3: Pattern Analysis Automation** - Develop automated pattern analysis tools that identify organizational email naming conventions from discovered addresses and generate candidate email addresses using permutation algorithms and employee name correlation. Test pattern identification accuracy across different organizational naming conventions.

**Lab 4: Breach Data Analysis** - Practice querying breach databases using HaveIBeenPwned API, analyzing exposure patterns including breach frequency and data types, and generating risk assessments based on email address exposure data with prioritized remediation recommendations and compliance reporting.

## Ethics

Email reconnaissance must be performed within strict legal and ethical boundaries respecting individual privacy rights and organizational consent requirements. Obtain explicit written authorization before performing any email enumeration against target organizations with clearly defined scope boundaries and data handling requirements. Respect privacy regulations including GDPR, CCPA, and regional data protection laws with appropriate legal counsel review of collection and processing activities. Minimize data collection to that which is necessary for authorized security assessment objectives, implementing data minimization principles throughout the reconnaissance process. Protect collected email data through encryption at rest and in transit, access controls limiting data exposure, and retention policies ensuring data is deleted after assessment completion. Never use discovered email addresses for unauthorized communications, marketing activities, or purposes beyond the authorized assessment scope. Report email security vulnerabilities through responsible disclosure channels with appropriate remediation timelines and coordination with organizational security teams. Document all email reconnaissance activities for accountability and compliance verification including scope boundaries, techniques employed, data sources accessed, and findings discovered.

## Quick Reference

| Technique | Tool | Purpose |
|-----------|------|---------|
| Email Harvesting | theHarvester, infoga | Multi-source email aggregation |
| Pattern Discovery | Custom Python scripts | Naming convention analysis |
| Email Verification | EmailHippo, Hunter.io | Mailbox existence validation |
| Breach Checking | HaveIBeenPwned API | Credential exposure assessment |
| Social Enumeration | Sherlock, holehe | Cross-platform account discovery |
| MX Analysis | dig, DNSRecon | Email infrastructure mapping |
| SPF Validation | dig TXT, MXToolbox | Sender authentication analysis |
| DKIM Discovery | dig selector._domainkey | Email signature key enumeration |
| DMARC Assessment | dig _dmarc | Policy evaluation and compliance |
| SMTP Testing | Swaks, smtp-user-enum | Server probing and verification |
| Header Analysis | Custom Python scripts | Security configuration assessment |
| Auto-Discover Probing | curl, Custom scripts | Configuration disclosure detection |
| Email Gateway Detection | SMTP banner analysis | Security product identification |
| Catch-All Detection | Statistical verification | Domain configuration analysis |
| Email Blacklist Checking | MXToolbox API | Reputation assessment |
| Email Forwarding Analysis | Header inspection | Infrastructure mapping |
| Bulk Verification | Custom async scripts | Large-scale address validation |
| Email OSINT | Recon-ng modules | Framework-based intelligence gathering |
| Email Monitoring | Custom scripts | Change detection and alerting |
| Email Infrastructure Fingerprinting | Banner/header analysis | Technology identification |
| Email Authentication Testing | SPF/DKIM/DMARC analysis | Security posture assessment |
| Email Privacy Assessment | Compliance checking | Regulatory alignment verification |
| Email Threat Intelligence | IOC correlation | Threat detection and monitoring |
| Email Data Aggregation | Multi-source fusion | Comprehensive coverage optimization |
| Email Database Management | SQLite/PostgreSQL | Data persistence and querying |
| Email Pattern ML | scikit-learn, TensorFlow | Automated naming convention detection |
| Email Graph Analysis | Neo4j, networkx | Relationship mapping and visualization |
| Email Header Forensics | Custom parsers | Delivery path and infrastructure analysis |
| Email Encryption Testing | S/MIME, PGP analysis | Encryption implementation assessment |
| Email Compliance Audit | Custom frameworks | Regulatory requirement validation |
| Email Service Enumeration | Custom scripts | Platform-specific account discovery |
| Email Reputation Analysis | Threat intel feeds | Risk assessment and monitoring |
| Email Domain Monitoring | Custom scripts | Brand protection and impersonation detection |
| Email API Integration | REST, GraphQL | Automated email intelligence |
| Email Bulk Processing | asyncio, celery | Large-scale email operations |
| Email Data Enrichment | Custom pipelines | Intelligence value enhancement |
| Email Risk Scoring | Custom models | Quantified risk assessment |
| Email Trend Analysis | pandas, numpy | Temporal pattern identification |
| Email Anomaly Detection | scikit-learn | Suspicious activity identification |
| Email Correlation Analysis | Custom scripts | Cross-source intelligence fusion |
| Email Compliance Reporting | Custom templates | Audit evidence generation |
| Email Documentation | Custom wikis | Knowledge management and transfer |

---

## Deep Dive: Email Enumeration Techniques

### Email Harvesting Sources
```bash
# Search engines
site:domain.com intext:"@" -www
site:domain.com filetype:pdf intext:"@"
site:domain.com filetype:xlsx intext:"@"
site:domain.com filetype:docx intext:"@"

# Social media
site:linkedin.com "domain.com"
site:twitter.com "domain.com"
site:facebook.com "domain.com"

# Job boards
site:indeed.com "domain.com"
site:glassdoor.com "domain.com"

# Code repositories
site:github.com "domain.com" "@"
site:gitlab.com "domain.com" "@"
site:bitbucket.org "domain.com" "@"

# Forums and communities
site:stackoverflow.com "domain.com"
site:reddit.com "domain.com"

# Web archives
web.archive.org/web/*/domain.com
```

### Email Verification Methods
```bash
# SMTP verification
python3 -c "
import smtplib
import sys

def verify_email(email, smtp_server='smtp.gmail.com', smtp_port=587):
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.ehlo()
        server.starttls()
        server.ehlo()
        
        # Try to verify email
        server.mail('test@test.com')
        code, message = server.rcpt(email)
        server.quit()
        
        if code == 250:
            return True
        return False
    except Exception as e:
        return False

print(verify_email(sys.argv[1]))
" email@domain.com

# MX record verification
dig MX domain.com +short

# SMTP banner grab
telnet mx1.domain.com 25

# Email header analysis
# Check for SPF, DKIM, DMARC
```

### Email Pattern Analysis
```python
#!/usr/bin/env python3
"""Email pattern analysis and prediction"""

import re
from typing import List, Dict

class EmailPatternAnalyzer:
    def __init__(self, domain: str):
        self.domain = domain
        self.patterns = {}
        self.employees = []

    def identify_patterns(self, emails: List[str]) -> Dict[str, int]:
        """Identify email naming patterns"""
        patterns = {
            'first.last': 0,
            'firstlast': 0,
            'f.last': 0,
            'first.l': 0,
            'flast': 0,
            'last.first': 0,
            'first_last': 0,
            'other': 0
        }

        for email in emails:
            local_part = email.split('@')[0]

            if re.match(r'^[a-z]+\.[a-z]+$', local_part):
                patterns['first.last'] += 1
            elif re.match(r'^[a-z]+$', local_part):
                patterns['firstlast'] += 1
            elif re.match(r'^[a-z]\.[a-z]+$', local_part):
                patterns['f.last'] += 1
            elif re.match(r'^[a-z]+\.[a-z]$', local_part):
                patterns['first.l'] += 1
            elif re.match(r'^[a-z]$', local_part) and len(local_part) == 1:
                patterns['flast'] += 1
            elif re.match(r'^[a-z]+\.[a-z]+$', local_part):
                patterns['first.last'] += 1
            elif '_' in local_part:
                patterns['first_last'] += 1
            else:
                patterns['other'] += 1

        self.patterns = patterns
        return patterns

    def predict_emails(self, names: List[str]) -> List[str]:
        """Predict email addresses based on patterns"""
        predicted = []

        if not self.patterns:
            return predicted

        # Find most common pattern
        dominant_pattern = max(self.patterns, key=self.patterns.get)

        for name in names:
            parts = name.lower().split()
            if len(parts) >= 2:
                first = parts[0]
                last = parts[-1]

                if dominant_pattern == 'first.last':
                    predicted.append(f"{first}.{last}@{self.domain}")
                elif dominant_pattern == 'firstlast':
                    predicted.append(f"{first}{last}@{self.domain}")
                elif dominant_pattern == 'f.last':
                    predicted.append(f"{first[0]}.{last}@{self.domain}")
                elif dominant_pattern == 'first.l':
                    predicted.append(f"{first}.{last[0]}@{self.domain}")
                elif dominant_pattern == 'flast':
                    predicted.append(f"{first[0]}{last}@{self.domain}")
                elif dominant_pattern == 'last.first':
                    predicted.append(f"{last}.{first}@{self.domain}")
                elif dominant_pattern == 'first_last':
                    predicted.append(f"{first}_{last}@{self.domain}")

        return predicted

    def generate_wordlist(self, names: List[str]) -> List[str]:
        """Generate email wordlist for brute-force"""
        wordlist = []

        for name in names:
            parts = name.lower().split()
            if len(parts) >= 2:
                first = parts[0]
                last = parts[-1]

                # All pattern variations
                wordlist.extend([
                    f"{first}.{last}",
                    f"{first}{last}",
                    f"{first[0]}.{last}",
                    f"{first}.{last[0]}",
                    f"{first[0]}{last}",
                    f"{last}.{first}",
                    f"{first}_{last}",
                    f"{last}{first}",
                    f"{first}",
                    f"{last}",
                ])

        return list(set(wordlist))

# Usage
analyzer = EmailPatternAnalyzer("example.com")
emails = ["john.doe@example.com", "jane.smith@example.com", "bob.jones@example.com"]
patterns = analyzer.identify_patterns(emails)
print(f"Dominant pattern: {max(patterns, key=patterns.get)}")
```

---

## Email Infrastructure Analysis

### MX Record Analysis
```bash
# Get MX records
dig MX domain.com +short

# Analyze MX priority and providers
dig MX domain.com +short | sort -n | while read priority server; do
    echo "Priority $priority: $server"
    echo "  IP: $(dig A $server +short)"
    echo "  Provider: $(whois $(dig A $server +short) | grep -i 'org\|net' | head -1)"
done

# Check for email security features
echo "=== Email Security Analysis ==="
echo "[1] SPF Record:"
dig TXT domain.com | grep "v=spf1"

echo "[2] DKIM Record:"
dig TXT default._domainkey.domain.com

echo "[3] DMARC Record:"
dig TXT _dmarc.domain.com

echo "[4] MTA-STS Record:"
dig TXT _mta-sts.domain.com

echo "[5] TLSRPT Record:"
dig TXT _smtp._tls.domain.com
```

### Email Provider Identification
```python
#!/usr/bin/env python3
"""Email provider identification and analysis"""

import dns.resolver
from typing import Dict, List

class EmailProviderAnalyzer:
    def __init__(self, domain: str):
        self.domain = domain
        self.providers = {
            'google': ['google.com', 'googlemail.com', 'gmail-smtp-in.l.google.com'],
            'microsoft': ['outlook.com', 'microsoft.com', 'protection.outlook.com'],
            'yahoo': ['yahoo.com', 'yahoodns.net'],
            'protonmail': ['protonmail.ch', 'proton.me'],
            'zoho': ['zoho.com', 'zoho.eu'],
            'mailgun': ['mailgun.org'],
            'sendgrid': ['sendgrid.net'],
            'amazonses': ['amazonses.com'],
        }

    def identify_provider(self) -> Dict[str, str]:
        """Identify email provider from MX records"""
        try:
            mx_records = dns.resolver.resolve(self.domain, 'MX')
            mx_hosts = [str(mx.exchange).rstrip('.') for mx in mx_records]

            for provider, indicators in self.providers.items():
                for mx in mx_hosts:
                    for indicator in indicators:
                        if indicator in mx:
                            return {
                                'provider': provider,
                                'mx_records': mx_hosts,
                                'confidence': 'high'
                            }

            return {
                'provider': 'unknown',
                'mx_records': mx_hosts,
                'confidence': 'low'
            }
        except Exception as e:
            return {'provider': 'error', 'error': str(e)}

    def analyze_security_features(self) -> Dict[str, bool]:
        """Analyze email security features"""
        features = {
            'spf': False,
            'dkim': False,
            'dmarc': False,
            'mta_sts': False,
            'tlsrpt': False,
        }

        # Check SPF
        try:
            txt_records = dns.resolver.resolve(self.domain, 'TXT')
            for record in txt_records:
                if 'v=spf1' in str(record):
                    features['spf'] = True
                    break
        except:
            pass

        # Check DKIM
        try:
            dkim_selectors = ['default', 'google', 'selector1', 'selector2', 'k1']
            for selector in dkim_selectors:
                try:
                    dns.resolver.resolve(f'{selector}._domainkey.{self.domain}', 'TXT')
                    features['dkim'] = True
                    break
                except:
                    continue
        except:
            pass

        # Check DMARC
        try:
            dns.resolver.resolve(f'_dmarc.{self.domain}', 'TXT')
            features['dmarc'] = True
        except:
            pass

        # Check MTA-STS
        try:
            dns.resolver.resolve(f'_mta-sts.{self.domain}', 'TXT')
            features['mta_sts'] = True
        except:
            pass

        # Check TLSRPT
        try:
            dns.resolver.resolve(f'_smtp._tls.{self.domain}', 'TXT')
            features['tlsrpt'] = True
        except:
            pass

        return features

    def generate_report(self) -> str:
        """Generate email infrastructure report"""
        provider_info = self.identify_provider()
        security_features = self.analyze_security_features()

        report = f"""
=== Email Infrastructure Report: {self.domain} ===

Provider: {provider_info.get('provider', 'Unknown')}
MX Records: {', '.join(provider_info.get('mx_records', []))}

Security Features:
- SPF: {'Enabled' if security_features['spf'] else 'Disabled'}
- DKIM: {'Enabled' if security_features['dkim'] else 'Disabled'}
- DMARC: {'Enabled' if security_features['dmarc'] else 'Disabled'}
- MTA-STS: {'Enabled' if security_features['mta_sts'] else 'Disabled'}
- TLSRPT: {'Enabled' if security_features['tlsrpt'] else 'Disabled'}

Recommendations:
"""
        if not security_features['spf']:
            report += "- Implement SPF to prevent email spoofing\n"
        if not security_features['dkim']:
            report += "- Implement DKIM for email authentication\n"
        if not security_features['dmarc']:
            report += "- Implement DMARC for email policy enforcement\n"
        if not security_features['mta_sts']:
            report += "- Consider implementing MTA-STS for transport security\n"

        return report

# Usage
analyzer = EmailProviderAnalyzer("example.com")
print(analyzer.generate_report())
```

---

## Email OSINT Automation

### Recon-ng Email Module
```python
#!/usr/bin/env python3
"""Recon-ng email OSINT automation"""

from reconng.core.modules import BaseModule

class EmailOSINT(BaseModule):
    def __init__(self):
        super().__init__()
        self.info = {
            'name': 'Email OSINT Module',
            'author': 'Security Researcher',
            'description': 'Gather email intelligence from multiple sources'
        }

    def run(self, email):
        """Run email OSINT"""
        results = {}

        # HaveIBeenPwned check
        results['breaches'] = self.check_breaches(email)

        # Social media lookup
        results['social'] = self.check_social(email)

        # Domain analysis
        results['domain'] = self.analyze_domain(email.split('@')[1])

        # Header analysis
        results['headers'] = self.analyze_headers(email)

        return results

    def check_breaches(self, email):
        """Check for data breaches"""
        # Integration with HIBP API
        pass

    def check_social(self, email):
        """Check social media profiles"""
        # Integration with social media APIs
        pass

    def analyze_domain(self, domain):
        """Analyze email domain"""
        # DNS analysis, MX records, etc.
        pass

    def analyze_headers(self, email):
        """Analyze email headers"""
        # Header parsing and analysis
        pass
```

### Email Correlation Engine
```python
#!/usr/bin/env python3
"""Email correlation and relationship mapping"""

import json
from typing import Dict, List, Set
from collections import defaultdict

class EmailCorrelationEngine:
    def __init__(self):
        self.emails = {}
        self.relationships = defaultdict(set)
        self.domains = defaultdict(set)

    def add_email(self, email: str, metadata: Dict = None):
        """Add email to correlation engine"""
        domain = email.split('@')[1]
        self.emails[email] = metadata or {}
        self.domains[domain].add(email)

    def correlate(self, email1: str, email2: str) -> Dict:
        """Correlate two email addresses"""
        domain1 = email1.split('@')[1]
        domain2 = email2.split('@')[1]

        correlation = {
            'same_domain': domain1 == domain2,
            'same_organization': self._check_organization(domain1, domain2),
            'common_contacts': self._find_common_contacts(email1, email2),
            'shared_platforms': self._check_shared_platforms(email1, email2),
        }

        return correlation

    def _check_organization(self, domain1: str, domain2: str) -> bool:
        """Check if domains belong to same organization"""
        # Simple check - can be enhanced with WHOIS data
        return domain1 == domain2

    def _find_common_contacts(self, email1: str, email2: str) -> Set:
        """Find common contacts between two emails"""
        contacts1 = self.relationships.get(email1, set())
        contacts2 = self.relationships.get(email2, set())
        return contacts1.intersection(contacts2)

    def _check_shared_platforms(self, email1: str, email2: str) -> List:
        """Check for shared platforms"""
        platforms = []

        # Check GitHub
        # Check LinkedIn
        # Check Twitter
        # etc.

        return platforms

    def build_relationship_graph(self) -> Dict:
        """Build relationship graph from all emails"""
        graph = {
            'nodes': [],
            'edges': []
        }

        for email in self.emails:
            graph['nodes'].append({
                'id': email,
                'type': 'email',
                'metadata': self.emails[email]
            })

        for email, contacts in self.relationships.items():
            for contact in contacts:
                graph['edges'].append({
                    'source': email,
                    'target': contact,
                    'type': 'contact'
                })

        return graph

    def export_graph(self, filename: str):
        """Export relationship graph to JSON"""
        graph = self.build_relationship_graph()
        with open(filename, 'w') as f:
            json.dump(graph, f, indent=2)
        print(f"[*] Graph exported to {filename}")

# Usage
engine = EmailCorrelationEngine()
engine.add_email("john@example.com", {"name": "John Doe", "role": "Developer"})
engine.add_email("jane@example.com", {"name": "Jane Smith", "role": "Manager"})
engine.correlate("john@example.com", "jane@example.com")
engine.export_graph("email_graph.json")
```

---

## Email Security Testing

### Email Spoofing Detection
```bash
# Test SPF implementation
swaks --to test@domain.com --from spoofed@domain.com --server mx1.domain.com

# Test DKIM validation
# Send email with invalid DKIM signature

# Test DMARC enforcement
# Check DMARC policy: none, quarantine, reject

# Email header analysis
# Check for:
# - Received-SPF: pass/fail
# - DKIM-Signature: valid/invalid
# - Authentication-Results: spf/dkim results
```

### Email Phishing Indicators
```python
#!/usr/bin/env python3
"""Email phishing indicator analysis"""

import email
import re
from typing import Dict, List

class PhishingAnalyzer:
    def __init__(self):
        self.indicators = []

    def analyze_email(self, raw_email: str) -> Dict:
        """Analyze email for phishing indicators"""
        msg = email.message_from_string(raw_email)

        analysis = {
            'headers': self._analyze_headers(msg),
            'content': self._analyze_content(msg),
            'links': self._analyze_links(msg),
            'attachments': self._analyze_attachments(msg),
            'score': 0,
            'risk_level': 'low'
        }

        # Calculate risk score
        analysis['score'] = self._calculate_score(analysis)
        analysis['risk_level'] = self._get_risk_level(analysis['score'])

        return analysis

    def _analyze_headers(self, msg) -> Dict:
        """Analyze email headers"""
        headers = {
            'from': msg.get('From', ''),
            'to': msg.get('To', ''),
            'subject': msg.get('Subject', ''),
            'date': msg.get('Date', ''),
            'message_id': msg.get('Message-ID', ''),
            'spf': msg.get('Received-SPF', ''),
            'dkim': msg.get('DKIM-Signature', ''),
        }

        # Check for spoofing indicators
        if headers['from'] and headers['message_id']:
            from_domain = re.search(r'@([\w.-]+)', headers['from'])
            msg_domain = re.search(r'@([\w.-]+)', headers['message_id'])
            if from_domain and msg_domain:
                headers['domain_mismatch'] = from_domain.group(1) != msg_domain.group(1)

        return headers

    def _analyze_content(self, msg) -> Dict:
        """Analyze email content"""
        content = {
            'has_urgency': False,
            'has_threats': False,
            'has_request': False,
            'grammar_errors': 0,
        }

        body = self._get_body(msg)
        if body:
            urgency_words = ['urgent', 'immediately', 'action required', 'suspended']
            threat_words = ['account will be', 'legal action', 'verify your']
            request_words = ['click here', 'update your', 'confirm your']

            for word in urgency_words:
                if word.lower() in body.lower():
                    content['has_urgency'] = True
                    break

            for word in threat_words:
                if word.lower() in body.lower():
                    content['has_threats'] = True
                    break

            for word in request_words:
                if word.lower() in body.lower():
                    content['has_request'] = True
                    break

        return content

    def _analyze_links(self, msg) -> Dict:
        """Analyze email links"""
        links = {
            'total': 0,
            'suspicious': 0,
            'domains': [],
        }

        body = self._get_body(msg)
        if body:
            urls = re.findall(r'https?://[^\s<>"]+', body)
            links['total'] = len(urls)

            for url in urls:
                domain = re.search(r'https?://([^/]+)', url)
                if domain:
                    links['domains'].append(domain.group(1))

                    # Check for suspicious patterns
                    if self._is_suspicious_url(url):
                        links['suspicious'] += 1

        return links

    def _analyze_attachments(self, msg) -> Dict:
        """Analyze email attachments"""
        attachments = {
            'total': 0,
            'executable': 0,
            'archive': 0,
            'document': 0,
        }

        for part in msg.walk():
            if part.get_content_maintype() == 'multipart':
                continue
            if part.get('Content-Disposition') is None:
                continue

            filename = part.get_filename()
            if filename:
                attachments['total'] += 1

                if filename.endswith(('.exe', '.bat', '.cmd', '.scr', '.pif')):
                    attachments['executable'] += 1
                elif filename.endswith(('.zip', '.rar', '.7z', '.tar', '.gz')):
                    attachments['archive'] += 1
                elif filename.endswith(('.pdf', '.doc', '.docx', '.xls', '.xlsx')):
                    attachments['document'] += 1

        return attachments

    def _get_body(self, msg) -> str:
        """Extract email body"""
        if msg.is_multipart():
            for part in msg.walk():
                if part.get_content_type() == 'text/plain':
                    return part.get_payload(decode=True).decode()
        else:
            return msg.get_payload(decode=True).decode()
        return ''

    def _is_suspicious_url(self, url: str) -> bool:
        """Check if URL is suspicious"""
        suspicious_patterns = [
            r'https?://\d+\.\d+\.\d+\.\d+',  # IP address
            r'https?://[^/]*\.(ru|cn|tk|ml|ga|cf)',  # Suspicious TLDs
            r'https?://[^/]*\d{10,}',  # Long numbers
            r'https?://bit\.ly|tinyurl\.com|goo\.gl',  # URL shorteners
        ]

        for pattern in suspicious_patterns:
            if re.search(pattern, url):
                return True
        return False

    def _calculate_score(self, analysis: Dict) -> int:
        """Calculate phishing risk score"""
        score = 0

        if analysis['headers'].get('domain_mismatch'):
            score += 30
        if analysis['content']['has_urgency']:
            score += 20
        if analysis['content']['has_threats']:
            score += 25
        if analysis['content']['has_request']:
            score += 20
        if analysis['links']['suspicious'] > 0:
            score += 25
        if analysis['attachments']['executable'] > 0:
            score += 30

        return min(score, 100)

    def _get_risk_level(self, score: int) -> str:
        """Get risk level from score"""
        if score >= 70:
            return 'high'
        elif score >= 40:
            return 'medium'
        else:
            return 'low'

# Usage
analyzer = PhishingAnalyzer()
result = analyzer.analyze_email(raw_email)
print(f"Risk Level: {result['risk_level']} (Score: {result['score']})")
```

---

## Reporting Templates

### Email Recon Report
```
## Email Infrastructure Analysis

### Domain: [domain.com]

### MX Records
[List MX records with priorities]

### Email Provider
[Identified provider]

### Security Features
- SPF: [Status]
- DKIM: [Status]
- DMARC: [Status]
- MTA-STS: [Status]

### Email Addresses Found
[List email addresses with sources]

### Findings
1. [Finding 1]
2. [Finding 2]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Email Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| Critical | No SPF/DKIM/DMARC | Email spoofing |
| High | Weak DMARC policy | Policy bypass |
| Medium | Missing MTA-STS | Transport security |
| Low | Outdated records | Configuration drift |

---

## Quick Reference Cheat Sheet

### Email Enumeration
```bash
theHarvester -d domain.com -b all
holehe domain.com email@example.com
emailfinder -d domain.com
```

### Email Verification
```bash
# SMTP verification
python3 verify_email.py email@domain.com

# MX record check
dig MX domain.com +short
```

### Email OSINT
```bash
# Breach check
curl -H "hibp-api-key: KEY" "https://haveibeenpwned.com/api/v3/breachedaccount/email@example.com"

# Social media lookup
sherlock email@example.com
```

---

## Resources and References
- theHarvester: https://github.com/laramies/theHarvester
- Holehe: https://github.com/megadose/holehe
- EmailVerif: https://github.com/AlfredoRamos/emailverif
- Recon-ng: https://github.com/lanmaster53/recon-ng
- Infoga: https://github.com/megadose/infoga
