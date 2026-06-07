# 48 - Report Automation Tools: Automating Report Generation and Management

## Expert Role (15 lines)

You are a senior security automation engineer with 10+ years of experience building automated systems for vulnerability report generation, management, and submission. You have designed automation pipelines for enterprise security teams, bug bounty platforms, and government agencies. Your expertise spans template engines, scripting languages, API integrations, CI/CD pipelines, and workflow automation tools. You understand that manual report writing is the primary bottleneck in security research productivity, and that well-designed automation can reduce report writing time by 80% while improving consistency and quality. You have personally built automation systems that have generated over 10,000 vulnerability reports and trained 50+ teams on report automation practices.

## Core Concepts (40 lines)

### Automation Philosophy
Report automation should augment, not replace, human expertise. The goal is to eliminate repetitive tasks while preserving the researcher's judgment and creativity.

### Template Engine Architecture
Template engines separate content from presentation, enabling consistent formatting while allowing content customization. Understanding template syntax and logic is essential for effective automation.

### Auto-Generation Pipeline Design
An auto-generation pipeline transforms raw findings into formatted reports. The pipeline must handle data validation, content generation, formatting, and delivery.

### Platform API Integration
Each bug bounty platform has unique APIs, formats, and requirements. Automation must handle platform-specific differences while maintaining a unified workflow.

### Data Flow Automation
Data flows from discovery tools through analysis to report generation. Automating these data flows eliminates manual copying and reduces errors.

### Quality Assurance Automation
Automated quality checks ensure reports meet standards before human review. This catches formatting errors, missing sections, and style inconsistencies.

### Workflow Orchestration
Complex report workflows require orchestration of multiple tools and processes. Orchestration ensures proper sequencing and handles error recovery.

### Version Control Integration
Automated reports benefit from version control for tracking changes, enabling collaboration, and supporting rollback. Git integration is essential for serious automation.

### Continuous Integration for Reports
CI/CD pipelines can validate, build, and deploy reports automatically. This enables rapid iteration and quality improvement.

### Monitoring and Alerting
Automated systems need monitoring to detect failures and alerting to ensure issues are addressed promptly. Monitoring prevents silent failures.

### Configuration Management
Automation systems need configuration management for different environments, platforms, and report types. Configuration must be version-controlled and tested.

### Error Handling and Recovery
Automated pipelines must handle errors gracefully, with retry logic, fallback mechanisms, and clear error reporting. Robust error handling prevents data loss.

### Security Considerations
Automated systems handle sensitive data and credentials. Security must be built into automation from the start, not added as an afterthought.

### Scalability Design
Automation must scale from individual researchers to large teams. Scalability considerations affect architecture decisions from the beginning.

### Maintenance and Evolution
Automation systems require ongoing maintenance as platforms change and requirements evolve. Sustainable automation includes maintenance planning.

## Prerequisites (20 lines)

1. Proficiency in Python or similar scripting language
2. Understanding of template engines (Jinja2, Handlebars, Mustache)
3. Knowledge of REST API design and consumption
4. Familiarity with CI/CD concepts and tools
5. Understanding of version control systems (Git)
6. Knowledge of JSON, YAML, and XML data formats
7. Familiarity with command-line tools and scripting
8. Understanding of webhooks and event-driven architecture
9. Knowledge of database basics for result storage
10. Familiarity with Docker for containerization
11. Understanding of security credential management
12. Knowledge of error handling and logging best practices
13. Familiarity with workflow orchestration tools
14. Understanding of testing methodologies for automation
15. Knowledge of HTML/CSS for report formatting
16. Familiarity with Markdown for documentation
17. Understanding of file system operations and path handling
18. Knowledge of network programming basics
19. Familiarity with cloud services (AWS, Azure, GCP)
20. Understanding of security compliance requirements

## Methodology (60 lines)

### Phase 1: Requirements Analysis and Planning

**Step 1: Current State Assessment**
- Document current report writing workflow step-by-step
- Identify time-consuming manual tasks
- Quantify time spent on each activity
- Identify error-prone manual steps
- Assess current tool landscape

**Step 2: Automation Opportunity Identification**
- Rank manual tasks by automation potential
- Identify quick wins (high impact, low effort)
- Assess technical feasibility of each automation
- Consider dependencies between automation candidates
- Prioritize based on ROI and risk reduction

**Step 3: Architecture Design**
- Design end-to-end automation pipeline
- Select tools and technologies for each component
- Define data flow between components
- Design error handling and recovery mechanisms
- Plan monitoring and alerting strategy

### Phase 2: Template and Pipeline Development

**Step 4: Template Design**
- Design report templates for each report type
- Implement conditional sections based on finding characteristics
- Create reusable components for common sections
- Design platform-specific template variations
- Validate templates against platform requirements

**Step 5: Data Extraction Automation**
- Build parsers for scanner output formats
- Implement extraction from ticketing systems
- Create integrations with reconnaissance tools
- Build parsers for browser developer tools output
- Implement evidence file processing

**Step 6: Content Generation**
- Implement structured content generation from data
- Build impact statement generators
- Create recommendation databases
- Implement severity calculation automation
- Build cross-reference generation

**Step 7: Formatting and Rendering**
- Implement multi-format output (Markdown, HTML, PDF)
- Build platform-specific formatting
- Create responsive report layouts
- Implement image processing and embedding
- Add table of contents and cross-reference generation

### Phase 3: Platform Integration

**Step 8: API Integration Development**
- Implement HackerOne API integration
- Build Bugcrowd API integration
- Create Intigriti API integration
- Implement custom platform adapters
- Build submission validation

**Step 9: Authentication and Credential Management**
- Implement secure credential storage
- Build token refresh mechanisms
- Create multi-platform credential management
- Implement audit logging for credential access
- Build credential rotation automation

**Step 10: Submission Automation**
- Implement automated submission workflows
- Build pre-submission validation
- Create submission confirmation tracking
- Implement status monitoring
- Build response automation for triage questions

### Phase 4: Quality Assurance and Deployment

**Step 11: Automated Quality Checks**
- Implement style guide validation
- Build completeness checking
- Create citation and reference validation
- Implement link checking
- Build formatting consistency validation

**Step 12: Testing Framework**
- Create unit tests for automation components
- Build integration tests for end-to-end pipeline
- Implement regression tests for template changes
- Create performance tests for large-scale generation
- Build security tests for credential handling

**Step 13: Deployment and Monitoring**
- Deploy automation in containerized environment
- Implement health monitoring and alerting
- Build performance dashboards
- Create usage analytics
- Implement logging and debugging tools

## Tool Arsenal (40 lines)

### Template Engines
1. **Jinja2** - Python template engine with rich logic
2. **Handlebars** - Logic-less templates with helpers
3. **Mustache** - Simple, logic-less templates
4. **EJS** - Embedded JavaScript templates
5. **Pug** - High-performance template engine

### Scripting and Automation
6. **Python** - Primary scripting language
7. **Bash/PowerShell** - Shell scripting
8. **Node.js** - JavaScript runtime
9. **Ruby** - Scripting language
10. **Go** - Compiled automation tools

### CI/CD Platforms
11. **GitHub Actions** - GitHub-native CI/CD
12. **GitLab CI** - GitLab CI/CD pipelines
13. **Jenkins** - Self-hosted automation server
14. **CircleCI** - Cloud CI/CD platform
15. **Azure DevOps** - Microsoft CI/CD platform

### API Testing and Integration
16. **Postman** - API development and testing
17. **Insomnia** - REST and GraphQL client
18. **HTTPie** - Command-line HTTP client
19. **cURL** - Command-line URL transfer
20. **requests** - Python HTTP library

### Document Generation
21. **Pandoc** - Universal document converter
22. **WeasyPrint** - HTML to PDF converter
23. **wkhtmltopdf** - HTML to PDF via WebKit
24. **LaTeX** - Professional document typesetting
25. **ReportLab** - PDF generation library

### Workflow Orchestration
26. **Apache Airflow** - Workflow orchestration
27. **Luigi** - Python workflow pipeline
28. **Prefect** - Modern workflow orchestration
29. **n8n** - Workflow automation
30. **Zapier** - No-code automation

### Monitoring and Alerting
31. **Prometheus** - Metrics collection
32. **Grafana** - Dashboard and alerting
33. **Sentry** - Error tracking
34. **Healthchecks.io** - Cron monitoring
35. **PagerDuty** - Incident management

### Version Control
36. **Git** - Version control system
37. **GitHub** - Git hosting and collaboration
38. **GitLab** - Git hosting with CI/CD
39. **Bitbucket** - Atlassian Git hosting
40. **Azure DevOps Repos** - Microsoft Git hosting

## Case Studies (50 lines)

### Case Study 1: Enterprise SOC Report Automation

**Background:**
A Fortune 500 SOC team of 15 analysts was spending 40% of their time writing vulnerability reports. Reports were inconsistent in format, quality, and depth. The CISO mandated automation to reduce report writing time and improve consistency.

**Implementation:**
The team built a Python-based automation pipeline with these components:
1. **Data Extraction Module**: Parsed findings from Nessus, Qualys, and Burp Suite output
2. **Template Engine**: Used Jinja2 with templates for different finding types
3. **Content Generator**: Built databases of remediation recommendations and impact statements
4. **Formatting Engine**: Generated Markdown, HTML, and PDF output
5. **Quality Checker**: Implemented automated style and completeness validation
6. **Submission Module**: Integrated with ServiceNow for ticket creation

**Results:**
- Report writing time reduced from 45 minutes to 8 minutes per finding
- Report consistency score improved from 65% to 95%
- Analyst satisfaction increased 40%
- Report quality audit findings reduced 75%
- Pipeline processed 500+ reports monthly

**Key Lessons:**
- Start with the most common report type for maximum impact
- Template version control prevents formatting regression
- Automated quality checks catch errors before human review
- Integration with existing ticketing systems reduces adoption friction

### Case Study 2: Bug Bounty Multi-Platform Submission

**Background:**
A bug bounty team submitting to 5 platforms (HackerOne, Bugcrowd, Intigriti, Immunefi, Self-hosted) needed to standardize submission across platforms. Each platform had different requirements, formats, and APIs.

**Implementation:**
They built a unified submission system:
1. **Platform Adapter Pattern**: Each platform had a dedicated adapter implementing a common interface
2. **Unified Data Model**: Common finding data model that mapped to platform-specific fields
3. **Template System**: Platform-specific templates using shared content
4. **Validation Layer**: Platform-specific validation before submission
5. **Status Tracking**: Unified tracking across all platforms
6. **Response Handler**: Automated initial responses to common triage questions

**Results:**
- Submission time reduced from 30 minutes to 5 minutes per platform
- Cross-platform submission consistency improved 90%
- Triage response time reduced 60%
- Platform-specific formatting errors eliminated
- Team could focus on research instead of submission mechanics

**Key Lessons:**
- Adapter pattern enables clean platform abstraction
- Common data model prevents data transformation errors
- Platform-specific validation prevents rejection
- Automated responses to common questions save significant time

### Case Study 3: Automated Evidence Capture Pipeline

**Background:**
A security research team needed to automate evidence capture during vulnerability testing. Manual evidence collection was time-consuming and often missed critical screenshots or request/response pairs.

**Implementation:**
They built an evidence automation system:
1. **Browser Extension**: Automated screenshot capture on finding detection
2. **Proxy Integration**: Automatic request/response logging through Burp Suite
3. **Command Logger**: Terminal session recording for command execution
4. **Evidence Processor**: Automatic redaction of sensitive data
5. **Report Integration**: Evidence automatically linked to report sections
6. **Storage Manager**: Organized evidence files with metadata

**Results:**
- Evidence capture time reduced 80%
- Evidence completeness improved from 70% to 98%
- Report writing time reduced 40%
- Evidence quality score improved 60%
- Team confidence in evidence increased significantly

**Key Lessons:**
- Automated evidence capture eliminates missed evidence
- Integration with testing tools reduces friction
- Automatic redaction prevents sensitive data exposure
- Organized storage enables quick evidence retrieval

### Case Study 4: AI-Assisted Report Writing

**Background:**
A security consultancy wanted to leverage AI to accelerate report writing while maintaining quality and accuracy. They needed to balance automation with human expertise.

**Implementation:**
They built an AI-assisted writing system:
1. **Finding Parser**: Extracted structured data from raw findings
2. **Content Generator**: Used LLMs to generate initial draft content
3. **Human Review Interface**: Enabled researchers to review and edit AI output
4. **Style Enforcer**: Applied consistent formatting and terminology
5. **Quality Scorer**: Automated quality scoring of draft reports
6. **Feedback Loop**: Captured human edits to improve AI generation

**Results:**
- Draft generation time reduced 70%
- Human review time reduced 50%
- Overall report writing time reduced 60%
- Quality scores maintained or improved
- Researchers focused on high-value analysis tasks

**Key Lessons:**
- AI should augment, not replace, human expertise
- Human review is essential for accuracy and quality
- Feedback loops improve AI output over time
- Quality scoring ensures consistent output

## Advanced Techniques (40 lines)

### Intelligent Template Selection
Implement ML-based template selection that automatically chooses the best template based on finding characteristics. Use historical data to train selection models. Implement A/B testing for template optimization.

### Natural Language Generation
Implement advanced NLG for generating human-quality prose from structured data. Use transformer models for contextual content generation. Build domain-specific language models for security writing.

### Automated Impact Quantification
Build systems that automatically calculate financial, user, and regulatory impact from vulnerability characteristics. Use historical data and industry benchmarks for estimation. Implement confidence scoring for impact estimates.

### Cross-Reference Automation
Implement automatic cross-referencing between new findings and historical reports. Use semantic similarity to identify related vulnerabilities. Build automated trend analysis from cross-references.

### Dynamic Report Formatting
Implement responsive report formatting that adapts to different viewing contexts (screen, print, mobile). Use CSS media queries and conditional rendering. Build adaptive layouts based on content length.

### Multi-Language Report Generation
Implement automated translation of reports for international teams. Use neural machine translation with security domain adaptation. Build terminology consistency across languages.

### Version Diff and Comparison
Implement automated comparison between report versions. Highlight changes for reviewer efficiency. Build change impact analysis for report updates.

### Automated Report Testing
Build systems that automatically test report quality using metrics and heuristics. Implement readability scoring, impact clarity assessment, and completeness checking. Use historical acceptance rates to predict submission success.

### Pipeline as Code
Implement entire automation pipelines as code, stored in version control. Enable peer review of pipeline changes. Build testing frameworks for pipeline validation.

### Self-Healing Automation
Implement automation that detects and recovers from common failures automatically. Build retry logic with exponential backoff. Create fallback mechanisms for each pipeline stage.

### Real-Time Collaboration Automation
Implement real-time collaborative editing with automated formatting. Build conflict resolution for simultaneous edits. Enable seamless integration between collaborative editing and automated formatting.

### Predictive Analytics for Reporting
Build models that predict report acceptance probability based on content analysis. Use historical data to identify success factors. Implement recommendations for improving submission success.

### Automated Evidence Scoring
Implement automated scoring of evidence quality and completeness. Use computer vision for screenshot quality assessment. Build natural language processing for evidence description quality.

### Platform API Abstraction Layer
Build a comprehensive abstraction layer that normalizes differences between bug bounty platforms. Implement plugin architecture for easy platform addition. Create testing frameworks for platform adapters.

## Detection Methods (20 lines)

### Pipeline Health Monitoring
- Track pipeline execution success rates
- Monitor processing times for each stage
- Detect bottlenecks in the pipeline
- Alert on pipeline failures or degradation
- Track resource utilization

### Quality Metrics Detection
- Monitor report quality scores over time
- Track style guide compliance rates
- Measure completeness of automated reports
- Detect quality regression from template changes
- Track user satisfaction with automated output

### Performance Detection
- Measure end-to-end pipeline latency
- Track throughput (reports per hour)
- Monitor API response times
- Detect performance degradation
- Track scalability limits

### Security Detection
- Monitor credential usage and access
- Detect unauthorized API access attempts
- Track data flow through automation
- Monitor for sensitive data exposure
- Audit automation system access

### Adoption Detection
- Track automation usage rates
- Monitor user engagement with automated features
- Detect resistance to automation adoption
- Measure time savings realization
- Track feature utilization across users

## Impact Assessment (20 lines)

### Productivity Impact
- Time reduction per report
- Reports generated per researcher
- Researcher time available for analysis
- Report turnaround time reduction
- Throughput improvement during peak periods

### Quality Impact
- Report consistency improvement
- Error rate reduction
- Completeness improvement
- Style compliance improvement
- Evidence quality improvement

### Business Impact
- Cost per report reduction
- Researcher capacity increase
- Client satisfaction improvement
- Competitive advantage from faster reporting
- Revenue impact from efficiency gains

### Strategic Impact
- Scalability improvement
- Knowledge preservation
- Process standardization
- Innovation enablement
- Team morale improvement

## Common Pitfalls (25 lines)

1. **Over-Automation** - Automating tasks that benefit from human judgment
2. **Brittle Templates** - Templates that break with edge cases
3. **Hardcoded Logic** - Business rules embedded in code instead of configuration
4. **Insufficient Testing** - Not testing automation across all scenarios
5. **Credential Exposure** - Storing credentials insecurely
6. **Error Swallowing** - Automation failing silently without notification
7. **Platform Lock-In** - Automation tightly coupled to specific platforms
8. **No Rollback** - Unable to revert automated changes
9. **Version Skew** - Different components using incompatible versions
10. **Performance Blindness** - Not monitoring automation performance
11. **Documentation Gaps** - No documentation for automation system
12. **Maintenance Debt** - Accumulating technical debt in automation
13. **Scope Creep** - Automation expanding beyond original requirements
14. **Tool Sprawl** - Too many tools creating complexity
15. **Configuration Drift** - Configuration inconsistencies across environments
16. **Dependency Hell** - Conflicting dependencies between automation components
17. **Secrets in Code** - Hardcoded secrets in automation scripts
18. **No Logging** - Insufficient logging for debugging
19. **Manual Overrides** - No mechanism to override automated decisions
20. **Alert Fatigue** - Too many alerts reducing response effectiveness
21. **Data Loss** - Automation losing data during processing
22. **Compliance Violations** - Automation not meeting compliance requirements
23. **Single Point of Failure** - Critical components without redundancy
24. **Unscalable Architecture** - Architecture that doesn't scale with volume
25. **No Metrics** - Not measuring automation effectiveness

## Integration Points (25 lines)

### Vulnerability Scanner Integration
- Parse output from Nessus, Qualys, OpenVAS, Nikto
- Import findings from DAST and SAST tools
- Correlate scanner findings with manual research
- Automate scanner-to-report pipeline

### Ticketing System Integration
- Create tickets from automated reports
- Update tickets with report status
- Link reports to ticket workflows
- Automate ticket assignment based on finding type

### Communication Platform Integration
- Notify team of new reports via Slack/Teams
- Share report drafts for review
- Alert on report status changes
- Enable chatbot interaction with automation

### Cloud Storage Integration
- Store reports in cloud storage (S3, GCS, Azure Blob)
- Sync reports across team members
- Enable version history and recovery
- Implement access control for reports

### Analytics Platform Integration
- Feed report data into analytics dashboards
- Generate insights from report trends
- Track automation effectiveness
- Measure business impact

### CI/CD Pipeline Integration
- Run report validation in CI/CD
- Automate report deployment
- Enable continuous improvement of templates
- Test automation changes before deployment

### Identity Provider Integration
- Authenticate automation users through SSO
- Implement role-based access for automation
- Track user actions in automation
- Enable credential management through IAM

### Workflow Platform Integration
- Trigger automation from workflow events
- Feed automation results into workflows
- Enable complex multi-step automation
- Support approval workflows for reports

### Database Integration
- Store report metadata in databases
- Query historical reports for reference
- Generate statistics from report data
- Enable report search and discovery

### API Gateway Integration
- Expose automation capabilities through APIs
- Rate limit and authenticate API access
- Monitor API usage and performance
- Enable third-party integration

## Reporting and Metrics (20 lines)

### Pipeline Metrics
- Reports generated per day/week/month
- Average processing time per report
- Pipeline success rate
- Error rate by failure type
- Resource utilization (CPU, memory, network)

### Quality Metrics
- Report quality score trends
- Style guide compliance rate
- Completeness score
- Evidence quality score
- User satisfaction ratings

### Efficiency Metrics
- Time saved per report (manual vs. automated)
- Researcher productivity improvement
- Report turnaround time reduction
- Cost per report reduction
- Throughput improvement percentage

### Adoption Metrics
- Active automation users
- Feature utilization rates
- User engagement trends
- Support request volume
- Training completion rates

### Business Metrics
- ROI calculation for automation investment
- Revenue impact from efficiency gains
- Client satisfaction improvement
- Competitive advantage metrics
- Scalability achievement

## Hands-On Labs (20 lines)

### Lab 1: Template Development
Create a Jinja2 template for vulnerability reports that supports conditional sections, loops for evidence items, and platform-specific formatting.

### Lab 2: Scanner Output Parser
Build a Python parser that extracts structured findings from Nessus CSV output and maps them to your report template data model.

### Lab 3: Platform API Integration
Implement a submission module for HackerOne's API that validates report content and submits with proper authentication.

### Lab 4: Automated Quality Checker
Build a validation script that checks reports for completeness, style compliance, and formatting consistency.

### Lab 5: CI/CD Pipeline
Create a GitHub Actions workflow that automatically validates and formats reports on push.

### Lab 6: Evidence Processor
Build a script that automatically redacts sensitive information from screenshots and request/response logs.

### Lab 7: Multi-Format Output
Implement a report renderer that generates Markdown, HTML, and PDF from a single template.

### Lab 8: Status Monitoring
Create a dashboard that tracks automation pipeline health, processing times, and error rates.

### Lab 9: Credential Management
Implement secure credential storage and automatic token refresh for multi-platform API access.

### Lab 10: End-to-End Pipeline
Build a complete automation pipeline from scanner output to formatted report submission, including quality checks and monitoring.

## Ethics and Best Practices (15 lines)

1. **Human Review Required** - Always require human review before submission
2. **Transparency** - Disclose automation use where appropriate
3. **Quality First** - Never sacrifice quality for speed
4. **Secure by Design** - Build security into automation from the start
5. **Audit Trail** - Maintain complete logs of automated actions
6. **Fail Safe** - Default to safe behavior on failure
7. **Credential Security** - Never hardcode credentials
8. **Data Minimization** - Only collect data needed for automation
9. **Access Control** - Limit automation access to minimum required
10. **Monitoring** - Monitor automation for anomalies
11. **Testing** - Test automation thoroughly before deployment
12. **Documentation** - Document automation for maintainability
13. **Version Control** - Store all automation code in version control
14. **Continuous Improvement** - Regularly review and improve automation
15. **User Training** - Train users on automation capabilities and limitations

## Quick Reference Cheat Sheet (20 lines)

### Template Variable Reference
- `{{ finding.title }}` - Finding title
- `{{ finding.severity }}` - Severity level
- `{{ finding.description }}` - Detailed description
- `{{ finding.steps }}` - Reproduction steps (list)
- `{{ finding.evidence }}` - Evidence items (list)
- `{{ finding.impact }}` - Impact statement
- `{{ finding.remediation }}` - Remediation guidance
- `{{ finding.references }}` - External references (list)

### Common Pipeline Stages
1. Data Extraction (from scanners, tools, manual input)
2. Data Validation (schema, completeness)
3. Content Generation (templates, NLG)
4. Formatting (Markdown, HTML, PDF)
5. Quality Checks (style, completeness, accuracy)
6. Human Review (editorial, technical)
7. Platform Submission (API, manual)
8. Status Tracking (monitoring, alerting)

### Platform API Quick Reference
- **HackerOne**: POST /reports, auth via API token
- **Bugcrowd**: POST /submissions, auth via API key
- **Intigriti**: POST /submissions, auth via API token
- **Self-hosted**: Custom API, varies by platform

### Quality Check Template
```yaml
checks:
  - name: completeness
    required_fields: [title, description, steps, impact]
  - name: style
    max_passive_voice: 10%
    max_sentence_length: 25 words
  - name: formatting
    check_headers: true
    check_lists: true
    check_code_blocks: true
  - name: evidence
    min_screenshots: 1
    max_age_days: 30
```

### Automation Configuration Template
```yaml
pipeline:
  name: report-automation
  version: 1.0
  stages:
    - extract
    - validate
    - generate
    - format
    - check
    - review
    - submit
    - track
```

### Error Handling Template
```python
try:
    result = process_report(data)
except ValidationError as e:
    notify_user(f"Validation failed: {e}")
    queue_for_review(data)
except SubmissionError as e:
    log_error(e)
    retry_submission(data)
except Exception as e:
    alert_admin(f"Unexpected error: {e}")
    save_state(data)
```

### Monitoring Dashboard Metrics
- Pipeline success rate (target: >99%)
- Average processing time (target: <5 minutes)
- Error rate (target: <1%)
- User satisfaction (target: >4.5/5)
- Reports processed (daily trend)
