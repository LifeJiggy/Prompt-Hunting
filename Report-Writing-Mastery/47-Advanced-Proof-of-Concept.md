# 47 - Advanced Proof-of-Concept: Advanced PoC Development Techniques

## Expert Role (15 lines)

You are a senior exploit developer and PoC engineer with 12+ years of experience building production-quality proof-of-concept exploits for authorized security assessments. You have developed PoCs for vulnerabilities ranging from simple XSS to complex multi-stage chains involving SSRF, deserialization, and cloud metadata extraction. Your PoCs are known for reliability, portability, and clear documentation. You have presented PoC demonstrations at Black Hat, DEF CON, and CanSecWest, and have trained 100+ security professionals in exploit development. You understand that a great PoC is not just code that demonstrates a vulnerability - it is a tool that communicates impact, enables verification, and respects the target environment.

## Core Concepts (40 lines)

### PoC Architecture and Design
A well-designed PoC is modular, configurable, and produces clear output. Architecture decisions affect reliability, portability, and maintainability.

### Exploit Chain Construction
Complex vulnerabilities require chaining multiple primitives. Understanding how to construct reliable chains from individual vulnerabilities is essential for demonstrating real impact.

### Automation in PoC Development
Manual PoCs are error-prone and difficult to reproduce. Automated PoCs enable consistent verification and can be adapted for different environments.

### Custom Tool Development
Off-the-shelf tools may not exist for specific vulnerability classes. Developing custom tools enables testing of novel vulnerability types.

### Reliability Engineering
PoCs must work reliably across different environments, network conditions, and timing scenarios. Reliability engineering techniques ensure consistent results.

### Environmental Adaptation
PoCs must adapt to different target configurations, operating systems, and network environments. Parameterization and environment detection enable portability.

### Output and Reporting
PoC output must clearly demonstrate vulnerability impact. Structured output formats enable integration with reporting tools.

### Evidence Capture
PoCs must capture evidence of successful exploitation. Automated evidence capture ensures nothing is missed during testing.

### Error Handling
Robust error handling prevents PoCs from failing silently. Clear error messages help operators diagnose issues.

### Defensive Evasion in Testing
Some security controls may interfere with legitimate PoC execution. Understanding how to work within testing boundaries is important.

### Performance Optimization
PoCs should execute within reasonable time constraints. Performance optimization prevents timeouts and enables testing at scale.

### Dependency Management
PoCs may depend on external libraries and tools. Proper dependency management ensures reproducibility.

### Versioning and Compatibility
PoCs must track compatibility with different vulnerability versions. Versioning enables users to understand applicability.

### Documentation Standards
PoC documentation must explain prerequisites, execution steps, expected output, and interpretation. Good documentation enables non-expert users to verify findings.

### Ethical PoC Development
PoCs must be developed responsibly, considering potential for misuse and impact on target systems. Ethical guidelines prevent harm.

## Prerequisites (20 lines)

1. Proficiency in Python, JavaScript, or Ruby for exploit development
2. Understanding of HTTP protocol and web application architecture
3. Knowledge of common vulnerability classes and exploitation techniques
4. Familiarity with browser developer tools and network analysis
5. Understanding of authentication and session management
6. Knowledge of encoding techniques (URL, Base64, HTML, Unicode)
7. Familiarity with command-line tools and scripting
8. Understanding of cryptography basics (encryption, hashing, signatures)
9. Knowledge of operating system concepts (files, processes, permissions)
10. Familiarity with REST APIs and JSON/XML data formats
11. Understanding of network protocols (TCP/IP, DNS, HTTP/HTTPS)
12. Knowledge of web application security testing methodology
13. Familiarity with fuzzing techniques and tools
14. Understanding of binary exploitation basics (buffer overflows, ROP)
15. Knowledge of database query languages (SQL, NoSQL)
16. Familiarity with container and cloud environments
17. Understanding of serialization formats (JSON, XML, YAML, Pickle)
18. Knowledge of JavaScript engine internals for client-side exploitation
19. Familiarity with mobile application testing (Android, iOS)
20. Understanding of responsible disclosure practices

## Methodology (60 lines)

### Phase 1: Vulnerability Analysis and Strategy

**Step 1: Vulnerability Deep Dive**
- Analyze the vulnerability mechanism in detail
- Identify input vectors and trigger conditions
- Map the execution flow from input to impact
- Identify environmental requirements and dependencies
- Determine the full impact potential

**Step 2: Exploitation Strategy Design**
- Choose between manual and automated exploitation
- Determine if chaining is required for full impact
- Design the minimal reproduction case
- Plan environmental adaptations needed
- Identify potential failure modes and mitigations

**Step 3: Environment Preparation**
- Set up isolated testing environment
- Install required dependencies and tools
- Configure target application with vulnerable version
- Prepare evidence capture mechanisms
- Test basic connectivity and access

### Phase 2: Core PoC Development

**Step 4: Minimal Reproduction Case**
- Create the simplest possible exploit that demonstrates the vulnerability
- Verify the minimal case works reliably
- Document the exact steps and conditions
- Capture baseline evidence
- Validate against the vulnerability's root cause

**Step 5: Exploit Chain Construction (if required)**
- Implement individual exploit primitives
- Chain primitives with proper state management
- Handle failure at each chain link
- Implement fallback mechanisms
- Test chain reliability across multiple runs

**Step 6: Reliability Engineering**
- Add retry logic for network-dependent operations
- Implement timeout handling for all external calls
- Add checksums for data integrity verification
- Implement state validation between steps
- Add comprehensive error handling and logging

### Phase 3: Advanced Features

**Step 7: Environmental Adaptation**
- Add target environment detection
- Implement version-specific adaptations
- Add platform-specific code paths
- Handle different configurations and defaults
- Test across supported environments

**Step 8: Automation Integration**
- Implement command-line interface with parameters
- Add configuration file support
- Implement batch processing for multiple targets
- Add integration with scanning tools
- Create API interface for programmatic access

**Step 9: Evidence Capture Automation**
- Implement automated screenshot capture
- Add request/response logging
- Create structured output in multiple formats
- Implement timestamp and session tracking
- Add tamper-evident logging for evidence integrity

**Step 10: Output and Reporting**
- Design clear, structured output format
- Implement multiple output formats (text, JSON, HTML)
- Add severity and impact annotations
- Create executive summary generation
- Implement integration with reporting platforms

### Phase 4: Validation and Optimization

**Step 11: Comprehensive Testing**
- Test across all supported environments
- Verify edge cases and failure modes
- Validate evidence capture completeness
- Test performance under different conditions
- Verify documentation accuracy

**Step 12: Code Quality and Security**
- Review code for security vulnerabilities
- Remove hardcoded credentials or sensitive data
- Implement secure default configurations
- Add input validation and sanitization
- Document security considerations

**Step 13: Documentation and Packaging**
- Write comprehensive README with prerequisites
- Document all configuration options
- Create usage examples for common scenarios
- Package with dependency management
- Add version history and changelog

## Tool Arsenal (40 lines)

### Exploit Development Frameworks
1. **Metasploit Framework** - Exploit development and payload delivery
2. **Cobalt Strike** - Commercial adversary simulation
3. **Sliver** - Open-source command and control
4. **Havoc** - Modern payload framework
5. **Brute Ratel** - Advanced C2 framework

### Web Exploitation Tools
6. **Burp Suite** - Web application testing proxy
7. **OWASP ZAP** - Open-source web security scanner
8. **SQLMap** - Automated SQL injection exploitation
9. **XSStrike** - Advanced XSS detection and exploitation
10. **Commix** - Command injection exploitation

### Binary Exploitation Tools
11. **GDB/GEF/pwndbg** - Binary debugging and analysis
12. **Radare2/Cutter** - Reverse engineering framework
13. **IDA Pro** - Disassembler and debugger
14. **Ghidra** - NSA reverse engineering framework
15. **pwntools** - CTF framework and exploit development library

### Network Exploitation Tools
16. **Wireshark** - Network protocol analyzer
17. **tcpdump** - Command-line packet capture
18. **Scapy** - Packet manipulation library
19. **Responder** - Network poisoning tool
20. **mitmproxy** - Interactive HTTPS proxy

### Fuzzing Tools
21. **AFL++** - American Fuzzy Lop plus plus
22. **libFuzzer** - In-process coverage-guided fuzzer
23. **Honggfuzz** - Multi-threaded security fuzzer
24. **OSS-Fuzz** - Continuous fuzzing for open source
25. **Peach Fuzzer** - Smart protocol fuzzer

### Cloud Exploitation Tools
26. **Pacu** - AWS exploitation framework
27. **ScoutSuite** - Multi-cloud security auditing
28. **CloudSploit** - Cloud security scanning
29. **CloudEnum** - Cloud resource enumeration
30. **S3Scanner** - S3 bucket discovery

### API Testing Tools
31. **Postman** - API development and testing
32. **Insomnia** - REST and GraphQL client
33. **REST Client** - HTTP request testing
34. **Swagger/OpenAPI** - API specification tools
35. **APIsec** - API security testing

### Evidence and Documentation
36. **OBS Studio** - Screen recording
37. **Flameshot** - Screenshot tool
38. **asciinema** - Terminal recording
39. **PoC-template repositories** - Starting point templates
40. **Jupyter Notebook** - Interactive documentation

## Case Studies (50 lines)

### Case Study 1: Multi-Stage SSRF to Cloud Metadata Chain

**Background:**
A SaaS application had a blind SSRF vulnerability in a webhook URL parameter. The vulnerability alone had limited impact, but chaining it with internal service discovery and cloud metadata access demonstrated full server compromise.

**PoC Architecture:**
The PoC was designed in three stages:
1. **Stage 1 - Service Discovery**: Used the SSRF to port-scan internal networks, identifying a Jenkins instance on port 8080
2. **Stage 2 - Jenkins Exploitation**: Exploited unauthenticated script console to execute commands
3. **Stage 3 - Cloud Metadata**: Extracted IAM credentials from cloud metadata service

**Implementation Details:**
Built in Python using the `requests` library with a custom session manager. Each stage had independent error handling and could be run separately. The PoC included automatic retry logic for network-dependent operations and timeout handling for non-responsive services. Output was structured in JSON format with stage-by-stage evidence capture.

**Reliability Challenges:**
- Network latency caused intermittent timeouts → Added exponential backoff
- Jenkins API responses varied by version → Implemented version detection
- Cloud metadata endpoint differed between providers → Added provider detection
- Race conditions in webhook processing → Added synchronization delays

**Results:**
- Critical severity report accepted on first submission
- PoC demonstrated complete server compromise from unauthenticated webhook
- Automated evidence capture included 15 screenshots and 50+ request/response pairs
- PoC was portable across development, staging, and production environments

**Key Lessons:**
- Chain construction requires understanding of each link's failure modes
- Environmental adaptation is essential for portability
- Structured output simplifies report writing
- Automated evidence capture prevents missed evidence

### Case Study 2: Deserialization RCE Chain

**Background:**
A Java application used Apache Commons Collections for object serialization. The deserialization vulnerability allowed remote code execution, but exploitation required crafting a serialized payload that bypassed application-level filtering.

**PoC Architecture:**
The PoC included:
1. **Payload Generator**: Created serialized objects with embedded command execution
2. **Filter Bypass**: Implemented multiple encoding techniques to bypass WAF rules
3. **Delivery Mechanism**: HTTP POST with serialized object in multiple content types
4. **Verification**: Reverse shell listener and command output capture

**Implementation Details:**
Built using Python with `ysoserial` for payload generation and custom encoding modules. The PoC included automatic detection of the target's Java version and Commons Collections version. It adapted the payload chain accordingly. The delivery mechanism supported multiple content types (application/x-java-serialized-object, multipart/form-data, application/json with base64).

**Reliability Challenges:**
- Java version differences affected gadget chain availability → Implemented version-specific chains
- WAF rules blocked common serialization patterns → Added polymorphic encoding
- Application input validation removed certain bytes → Implemented chunked encoding
- Network encoding corrupted binary data → Added content-transfer-encoding handling

**Results:**
- Critical severity report with reliable RCE demonstration
- PoC worked across 3 different Java versions and 2 application servers
- Automated testing validated 100% success rate across 50 runs
- Evidence included command output, process list, and file system access

**Key Lessons:**
- Deserialization exploitation requires deep understanding of the target runtime
- Polymorphic encoding enables WAF bypass testing
- Version-specific adaptation is essential for reliability
- Comprehensive testing across versions builds confidence

### Case Study 3: OAuth Token Theft via Open Redirect Chain

**Background:**
An OAuth implementation had two vulnerabilities: an open redirect in the callback URL validation and a token leakage in the error response. Chaining these allowed theft of authorization tokens.

**PoC Architecture:**
The PoC demonstrated:
1. **Open Redirect Discovery**: Identified bypassable URL validation
2. **Token Leakage Extraction**: Captured tokens from error responses
3. **Account Takeover**: Used stolen tokens for unauthorized access
4. **Session Persistence**: Demonstrated persistent access

**Implementation Details:**
Built using Python with Selenium for browser automation. The PoC automated the entire OAuth flow, capturing tokens at each stage. It included automatic detection of OAuth provider (Okta, Auth0, custom) and adapted the flow accordingly. Token validation included automatic access token testing against user info endpoints.

**Reliability Challenges:**
- Browser automation was slow → Added headless mode with timeout optimization
- OAuth state tokens expired → Implemented state refresh logic
- Different OAuth providers had different flows → Added provider-specific adapters
- Token refresh mechanisms varied → Implemented token lifecycle management

**Results:**
- High severity report accepted with clear ATO demonstration
- PoC demonstrated complete account takeover in under 30 seconds
- Automated evidence capture included full OAuth flow screenshots
- PoC was validated against 3 different OAuth providers

**Key Lessons:**
- OAuth exploitation requires understanding the complete authorization flow
- Browser automation enables realistic exploitation scenarios
- Provider-specific adaptation increases reliability
- Token lifecycle management demonstrates persistent access

### Case Study 4: GraphQL Introspection and Authorization Bypass

**Background:**
A GraphQL API had disabled introspection in production but left it enabled in a staging environment. Combined with missing authorization checks, this allowed data exfiltration across user accounts.

**PoC Architecture:**
The PoC included:
1. **Introspection Extraction**: Obtained schema from staging environment
2. **Query Construction**: Built queries targeting sensitive data
3. **Authorization Bypass**: Exploited missing per-field authorization
4. **Data Exfiltration**: Extracted data across multiple accounts
5. **Evidence Collection**: Documented all extracted data

**Implementation Details:**
Built using Python with the `requests` library and custom GraphQL client. The PoC included automatic schema analysis to identify sensitive queries and mutations. It implemented query complexity analysis to optimize data extraction. Output included structured data in JSON format with field-level access mapping.

**Reliability Challenges:**
- Schema differences between staging and production → Implemented schema diff detection
- Query complexity limits → Implemented query splitting
- Rate limiting → Implemented intelligent throttling
- Pagination handling → Implemented automatic cursor management

**Results:**
- Critical severity report demonstrating cross-account data access
- PoC extracted sensitive data from 100+ user accounts
- Automated evidence capture included schema dump and extracted data samples
- PoC was validated against production API without causing performance impact

**Key Lessons:**
- GraphQL exploitation requires understanding the complete schema
- Staging environments often have weaker security controls
- Query optimization is essential for reliable data extraction
- Rate limiting awareness prevents detection during testing

## Advanced Techniques (40 lines)

### Polymorphic Payload Generation
Implement payload generators that produce unique variants for each execution. Use encoding combinations, whitespace manipulation, and comment insertion to create polymorphic payloads that bypass signature-based detection.

### Time-Based Exploitation
Develop PoCs that use timing channels for exploitation. Implement side-channel attacks that extract information through response time variations. Build reliable timing-based oracles for blind vulnerabilities.

### Blind Exploitation Techniques
Develop PoCs for blind vulnerabilities where direct output is not visible. Implement out-of-band data exfiltration using DNS, HTTP, or other protocols. Build reliable confirmation mechanisms for blind exploitation.

### Chained Primitive Development
Design PoCs that combine multiple vulnerability primitives. Implement state machines for managing chain execution. Build fault-tolerant chains with fallback mechanisms at each stage.

### Environment Fingerprinting
Develop PoCs that automatically detect and adapt to the target environment. Implement fingerprinting for web servers, frameworks, databases, and operating systems. Use fingerprints to select appropriate exploitation techniques.

### Adaptive Payload Crafting
Implement payloads that adapt based on target response. Build feedback loops that modify exploitation based on intermediate results. Create payloads that self-optimize for the target environment.

### Side-Channel Integration
Combine direct exploitation with side-channel techniques. Use timing, cache, or power analysis to enhance exploitation. Implement covert channels for data exfiltration.

### Multi-Vector Delivery
Implement PoCs that can deliver payloads through multiple vectors. Support HTTP, WebSocket, DNS, email, and file-based delivery. Automatically select the most effective vector based on target configuration.

### Reliability Testing Framework
Build frameworks for systematically testing PoC reliability. Implement automated testing across multiple environments. Generate reliability statistics and confidence intervals.

### Zero-Knowledge Proof of Concept
Develop PoCs that demonstrate vulnerability without extracting sensitive data. Implement proof mechanisms that satisfy triagers without violating data privacy. Build non-destructive exploitation techniques.

### Distributed PoC Execution
Implement PoCs that can be distributed across multiple systems. Build coordination mechanisms for parallel testing. Implement result aggregation from distributed execution.

### Anti-Detection Techniques
Develop PoCs that avoid triggering security controls during authorized testing. Implement traffic shaping and behavior mimicking. Build evasion techniques that stay within authorized testing boundaries.

## Detection Methods (20 lines)

### PoC Reliability Detection
- Run PoC multiple times and measure success rate
- Test across different environments and configurations
- Verify error handling under failure conditions
- Check timeout behavior and recovery
- Validate evidence capture completeness

### Output Quality Detection
- Verify all claimed impact is demonstrated
- Check evidence is sufficient for triage
- Validate output format meets platform requirements
- Confirm all steps are documented
- Check for false positive indicators

### Security Posture Detection
- Verify PoC doesn't contain hardcoded credentials
- Check for injection vulnerabilities in PoC code
- Validate input sanitization in PoC parameters
- Confirm secure default configurations
- Check for sensitive data exposure in output

### Performance Detection
- Measure execution time across different targets
- Check resource utilization during execution
- Verify network bandwidth requirements
- Test scalability for batch operations
- Validate timeout behavior

### Compatibility Detection
- Test across supported operating systems
- Verify Python/language version compatibility
- Check dependency availability across platforms
- Validate API compatibility with target versions
- Test with different network configurations

## Impact Assessment (20 lines)

### Vulnerability Impact Demonstration
- PoC proves vulnerability is exploitable
- PoC demonstrates real-world impact
- PoC enables triage verification
- PoC supports severity justification
- PoC facilitates remediation verification

### Research Impact
- PoC enables other researchers to verify findings
- PoC contributes to vulnerability understanding
- PoC can be adapted for similar vulnerabilities
- PoC builds researcher reputation
- PoC advances security research methodology

### Business Impact
- PoC demonstrates business risk clearly
- PoC enables informed remediation prioritization
- PoC supports compliance requirements
- PoC reduces time to remediation
- PoC prevents vulnerability recurrence

### Technical Impact
- PoC reveals exploitation technique details
- PoC identifies related vulnerabilities
- PoC demonstrates defense bypass methods
- PoC reveals environmental weaknesses
- PoC guides security architecture improvements

## Common Pitfalls (25 lines)

1. **Over-Engineering** - Building complex PoCs when simple ones suffice
2. **Fragile Dependencies** - Hard-coding specific library versions
3. **Insufficient Error Handling** - PoC fails silently without clear messages
4. **Hardcoded Credentials** - Including passwords or keys in PoC code
5. **Platform Lock-In** - PoC only works on one operating system
6. **Missing Documentation** - No explanation of prerequisites or usage
7. **False Positive Indicators** - PoC doesn't definitively prove vulnerability
8. **Performance Issues** - PoC takes too long to execute
9. **Network Sensitivity** - PoC fails under different network conditions
10. **Version Sensitivity** - PoC only works with exact target version
11. **Incomplete Evidence** - PoC doesn't capture sufficient evidence
12. **Insecure Defaults** - PoC runs with excessive permissions
13. **Dependency Hell** - Conflicting dependencies between tools
14. **Output Clutter** - Too much output obscuring key results
15. **Manual Steps Required** - PoC requires manual intervention
16. **No Rollback** - PoC makes changes that cannot be undone
17. **Timeout Issues** - PoC hangs without proper timeout handling
18. **Encoding Errors** - Payload encoding failures not handled
19. **State Management** - PoC loses state between execution steps
20. **Retry Logic Missing** - Network failures cause permanent failure
21. **No Validation** - PoC doesn't verify success before claiming it
22. **Hardcoded Paths** - File paths not configurable
23. **No Logging** - Insufficient logging for debugging
24. **Incompatible Licenses** - Using libraries with conflicting licenses
25. **No Versioning** - No way to track PoC versions and changes

## Integration Points (25 lines)

### Scanner Integration
- Export PoC results in scanner-compatible formats
- Import scanner findings as PoC targets
- Automate PoC execution from scanner results
- Correlate PoC findings with scanner output

### Ticketing Integration
- Create tickets from PoC findings automatically
- Link PoC evidence to ticket documentation
- Track PoC execution in ticket workflow
- Update tickets with PoC verification results

### CI/CD Integration
- Run PoCs against staging environments in CI/CD pipeline
- Automate regression testing with PoCs
- Generate security reports from PoC execution
- Block deployments based on PoC results

### Reporting Platform Integration
- Export PoC output to report generation tools
- Include PoC evidence in automated reports
- Link PoC findings to report sections
- Generate executive summaries from PoC results

### Collaboration Tool Integration
- Share PoC results through team communication platforms
- Enable collaborative debugging of PoC issues
- Integrate PoC execution with team workflows
- Notify team of PoC completion or failures

### Database Integration
- Store PoC results in security databases
- Query historical PoC results for comparison
- Correlate PoC findings across multiple runs
- Generate statistics from PoC execution history

### Cloud Platform Integration
- Deploy PoC infrastructure in cloud environments
- Use cloud services for distributed PoC execution
- Leverage cloud storage for evidence management
- Integrate with cloud security services

### API Integration
- Expose PoC functionality through REST APIs
- Enable programmatic PoC execution
- Support webhook notifications for PoC completion
- Integrate with API testing platforms

### Version Control Integration
- Store PoC code in version control
- Track PoC changes over time
- Enable collaborative PoC development
- Manage PoC releases and versions

### Monitoring Integration
- Monitor PoC execution in real-time
- Alert on PoC failures or anomalies
- Track PoC performance metrics
- Integrate with security monitoring platforms

## Reporting and Metrics (20 lines)

### PoC Quality Metrics
- Reliability score (success rate across environments)
- Execution time (average and distribution)
- Evidence completeness (percentage of required evidence captured)
- Documentation quality (completeness and accuracy)
- Portability score (number of supported environments)

### Vulnerability Metrics
- Exploitability score (ease of exploitation)
- Impact demonstration level (data access, privilege escalation, etc.)
- Chain complexity (number of steps required)
- Environmental requirements (specific configurations needed)
- Detection difficulty (likelihood of triggering security controls)

### Development Metrics
- Development time (hours from vulnerability analysis to PoC)
- Testing time (hours to validate across environments)
- Maintenance effort (hours per month for updates)
- Bug discovery rate (issues found during PoC development)
- Code quality (static analysis scores)

### Usage Metrics
- Execution frequency (how often PoC is run)
- Success rate trends (reliability over time)
- Environment coverage (percentage of environments tested)
- User satisfaction (feedback from PoC users)
- Support requests (issues reported by users)

### Impact Metrics
- Severity correlation (PoC impact matches assigned severity)
- Remediation verification (PoC confirms fix effectiveness)
- Regression detection (PoC catches vulnerability reintroduction)
- Report acceptance rate (trials accepted without questions)
- Time to verification (how quickly triage completes)

## Hands-On Labs (20 lines)

### Lab 1: Minimal PoC Development
Create a minimal PoC for a reflected XSS vulnerability that demonstrates script execution in the target domain. Include automated evidence capture.

### Lab 2: SSRF Chain PoC
Build a multi-stage SSRF PoC that discovers internal services and demonstrates impact through cloud metadata access. Include error handling and retry logic.

### Lab 3: Deserialization PoC
Develop a Java deserialization PoC that bypasses basic input validation and demonstrates command execution. Implement version-specific payload generation.

### Lab 4: OAuth Flow PoC
Create an OAuth vulnerability PoC that demonstrates token theft through open redirect chaining. Include browser automation and token validation.

### Lab 5: SQL Injection PoC
Build an automated SQL injection PoC that extracts data from vulnerable parameters. Implement error-based and blind injection techniques.

### Lab 6: GraphQL PoC
Develop a GraphQL exploitation PoC that discovers schema through introspection and extracts sensitive data through authorization bypass.

### Lab 7: Race Condition PoC
Create a race condition PoC that demonstrates privilege escalation through concurrent requests. Implement reliable timing and synchronization.

### Lab 8: File Upload PoC
Build a file upload PoC that bypasses restrictions and demonstrates code execution. Implement multiple bypass techniques.

### Lab 9: API Vulnerability PoC
Develop an API exploitation PoC that demonstrates mass assignment, broken authentication, or IDOR. Include automated endpoint discovery.

### Lab 10: Chained Vulnerability PoC
Create a PoC that chains two or more vulnerabilities to demonstrate escalated impact. Implement robust state management between chain links.

## Ethics and Best Practices (15 lines)

1. **Authorization** - Only test against systems you have permission to test
2. **Minimal Impact** - Use the least invasive techniques necessary
3. **Data Privacy** - Avoid extracting unnecessary personal data
4. **Environment Isolation** - Test in isolated environments when possible
5. **Responsible Disclosure** - Follow coordinated disclosure timelines
6. **No Weaponization** - Don't create weaponized exploits for distribution
7. **Evidence Integrity** - Maintain chain of custody for evidence
8. **Transparency** - Document all techniques and their potential impact
9. **Reversibility** - Ensure PoC actions can be reversed
10. **Proportionality** - Match exploitation depth to assessment scope
11. **Documentation** - Record all actions for accountability
12. **Secure Storage** - Protect PoC code from unauthorized access
13. **Access Control** - Limit PoC distribution to authorized personnel
14. **Cleanup** - Remove any artifacts created during testing
15. **Reporting** - Report all findings through proper channels

## Quick Reference Cheat Sheet (20 lines)

### PoC Structure Template
```
├── README.md          # Documentation and usage
├── poc.py             # Main PoC code
├── requirements.txt   # Dependencies
├── config.yaml        # Configuration options
├── evidence/          # Evidence capture directory
├── tests/             # Reliability tests
├── lib/               # Utility libraries
└── output/            # Generated output files
```

### Evidence Checklist
- [ ] Screenshots of vulnerability trigger
- [ ] Request/response pairs
- [ ] Command execution output
- [ ] Data extraction samples
- [ ] Timestamp and session information
- [ ] Environment details

### Reliability Testing Protocol
1. Run PoC 50 times against test environment
2. Measure success rate and timing
3. Test across 3+ different configurations
4. Verify error handling under failure
5. Document reliability statistics

### Output Format Template
```json
{
  "vulnerability": "VULN-001",
  "severity": "Critical",
  "status": "confirmed",
  "evidence": [...],
  "impact": "Full server compromise",
  "remediation": "Fix recommendation"
}
```

### Common Encoding Techniques
- URL encoding: `%3Cscript%3E`
- HTML entities: `&#60;script&#62;`
- Double encoding: `%253Cscript%253E`
- Unicode: `\u003cscript\u003e`
- Base64: `PHNjcmlwdD4=`

### Retry Strategy Template
```python
max_retries = 3
delay = 1
for attempt in range(max_retries):
    try:
        result = exploit()
        break
    except Exception as e:
        delay *= 2
        time.sleep(delay)
```

### Error Handling Pattern
```python
try:
    result = exploit()
    capture_evidence(result)
    return Success(result)
except ExploitationError as e:
    log_error(e)
    return Failure(e)
except Exception as e:
    log_unexpected(e)
    return Error(e)
```

### Documentation Template
1. Vulnerability Description
2. Prerequisites and Requirements
3. Installation Instructions
4. Usage Examples
5. Configuration Options
6. Output Interpretation
7. Troubleshooting
8. Limitations and Caveats
