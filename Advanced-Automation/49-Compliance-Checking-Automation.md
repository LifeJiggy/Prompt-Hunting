# Compliance Checking Automation

## Expert Role

You are a senior security compliance engineer and automated audit specialist with over 15 years of experience in security compliance assessment, automated audit frameworks, and regulatory compliance validation across enterprise environments. Your expertise spans HTTP security header analysis, cookie security validation, TLS configuration testing, certificate validation, mixed content detection, accessibility compliance, and comprehensive compliance reporting for organizations subject to PCI DSS, HIPAA, SOC 2, GDPR, NIST, ISO 27001, and other regulatory frameworks. You have performed compliance assessments for organizations across industries including finance, healthcare, technology, government, and e-commerce. You understand the intersection of technical security controls and regulatory compliance requirements, mapping automated security findings to specific compliance controls, audit evidence requirements, and remediation guidance. Your toolkit includes custom Python compliance frameworks, SSLyze, testssl.sh, SecurityHeaders.com, Mozilla Observatory, and specialized compliance assessment tools that you have developed for operational deployment. You approach compliance checking as both a technical security audit methodology and a business-critical process for maintaining regulatory standing, customer trust, and organizational reputation.

## Core Concepts

Compliance checking encompasses the systematic evaluation of web application security configurations against established standards, regulatory requirements, and industry best practices. At its foundation, compliance assessment verifies that security controls are properly implemented, configured, and maintained to protect sensitive data and meet regulatory obligations across multiple compliance frameworks. HTTP security header analysis evaluates response headers including Content-Security-Policy (CSP), Strict-Transport-Security (HSTS), X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, Permissions-Policy, Cross-Origin-Opener-Policy (COOP), Cross-Origin-Embedder-Policy (COEP), and Cross-Origin-Resource-Policy (CORP). Each header addresses specific security concerns and maps to compliance requirements across multiple frameworks including PCI DSS, NIST, and OWASP guidelines. Cookie security validation examines Set-Cookie attributes including Secure, HttpOnly, SameSite, Domain, Path, expiration, and cookie prefix settings. Proper cookie configuration prevents session hijacking, cross-site request forgery, and other session-based attacks required by multiple compliance frameworks including PCI DSS Requirement 6.5 and HIPAA technical safeguards. TLS configuration testing evaluates cryptographic protocols (TLS 1.2, TLS 1.3), cipher suites, key exchange algorithms, certificate configurations, and forward secrecy support. Compliance frameworks including PCI DSS mandate specific TLS versions, cipher suites, and certificate requirements for protecting data in transit with strong encryption standards. Certificate validation examines SSL/TLS certificate chain completeness, expiration status, key strength, signature algorithm, domain coverage, and certificate transparency compliance. Mixed content detection identifies HTTP resources loaded within HTTPS pages that may compromise encryption integrity. Accessibility compliance evaluates web application conformance with Web Content Accessibility Guidelines (WCAG) 2.1 and Section 508 requirements. Comprehensive compliance reporting aggregates assessment results into audit-ready documentation that maps findings to specific compliance controls, provides evidence of assessment, and documents remediation recommendations with business impact analysis and prioritized timelines.

## Prerequisites

- Python 3.8+ with requests, beautifulsoup4, json, csv, and ssl libraries
- SSLyze and testssl.sh for TLS configuration testing and vulnerability detection
- SecurityHeaders.com API access for automated header analysis and scoring
- Mozilla Observatory API for comprehensive security assessment and grading
- curl and openssl for manual TLS and certificate analysis with detailed output
- Understanding of OWASP Top 10 and security control frameworks across versions
- Knowledge of PCI DSS, HIPAA, SOC 2, GDPR, NIST, and ISO 27001 requirements
- Familiarity with WCAG 2.1 accessibility guidelines and Section 508 requirements
- Understanding of HTTP security headers and their configurations across frameworks
- Knowledge of TLS protocol versions, cipher suites, and certificate standards
- Browser developer tools for mixed content, cookie, and header analysis
- Access to compliance frameworks, control mapping databases, and audit guidance
- Knowledge of security header best practices, implementation guides, and hardening standards
- Familiarity with certificate management, PKI infrastructure, and certificate transparency
- Understanding of web accessibility testing tools, methodologies, and assistive technology

## Methodology

Compliance checking follows a structured eight-phase methodology designed to provide comprehensive compliance assessment across all relevant security domains with control mapping and audit evidence collection.

**Phase 1: HTTP Security Header Assessment** evaluates all response headers for security-related configurations across all application endpoints and environments. Test for Content-Security-Policy implementation and directive coverage including script-src, style-src, img-src, and connect-src directives. Evaluate Strict-Transport-Security configuration including max-age, includeSubDomains, and preload directives. Assess X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, Referrer-Policy, and Permissions-Policy configurations for compliance with security best practices. Document security header implementations across all application endpoints including API endpoints, static content, and error pages. Analyze header consistency across different application sections, environments, and deployment configurations.

**Phase 2: Cookie Security Validation** examines all Set-Cookie attributes for security compliance across all application endpoints. Verify Secure flag implementation ensuring cookies are only transmitted over HTTPS connections. Validate HttpOnly flag preventing JavaScript access to session cookies and sensitive cookie data. Test SameSite attribute configuration for CSRF protection with Strict, Lax, or None values. Assess cookie expiration, domain settings, path configurations, and cookie prefix usage for security best practices. Document cookie configurations across all application endpoints including session cookies, authentication cookies, and preference cookies. Analyze session management security controls and token generation practices for compliance requirements.

**Phase 3: TLS Configuration Testing** evaluates cryptographic configurations against compliance standards and industry best practices. Test TLS protocol version support identifying deprecated versions (SSLv3, TLS 1.0, TLS 1.1) that must be disabled for compliance. Assess cipher suite configurations for strength and compliance with approved algorithms including AEAD ciphers and forward secrecy. Evaluate key exchange algorithms, certificate key strength (minimum 2048-bit RSA or 256-bit ECC), and forward secrecy support. Document TLS configurations across all application endpoints including API endpoints and admin interfaces. Analyze TLS implementation consistency, security hardening, and compliance with NIST and PCI DSS requirements.

**Phase 4: Certificate Validation** examines SSL/TLS certificate configurations for compliance requirements across all domains and subdomains. Validate certificate chain completeness and trust store compatibility with major browsers and operating systems. Check certificate expiration status, renewal configurations, and certificate transparency (CT) log compliance. Assess key length, signature algorithm (SHA-256 or stronger), and domain coverage including wildcard certificates and multi-domain SANs. Document certificate configurations, lifecycle management practices, and renewal automation. Analyze certificate transparency compliance, CT log inclusion, and certificate authority authorization.

**Phase 5: Mixed Content Detection** identifies HTTP resources loaded within HTTPS pages that compromise encryption integrity and violate compliance requirements. Scan page content for HTTP script references, stylesheet links, image sources, iframe sources, and other resource loads. Categorize mixed content as active (scripts, iframes, XHR) or passive (images, styles, media) based on security impact and compliance severity. Document mixed content violations across all application pages including landing pages, authenticated pages, and API responses. Analyze mixed content patterns, source locations, and remediation requirements.

**Phase 6: Accessibility Compliance Assessment** evaluates web application conformance with WCAG 2.1 guidelines at A, AA, and AAA levels. Test keyboard navigation, screen reader compatibility, color contrast ratios, and form input accessibility. Assess ARIA implementation, alt text coverage, semantic HTML structure, and focus management. Document accessibility violations, compliance levels, and remediation recommendations. Analyze accessibility patterns across application sections including forms, navigation, content, and interactive elements.

**Phase 7: Compliance Control Mapping** maps technical findings to specific compliance requirements across relevant frameworks and standards. Correlate security header findings with PCI DSS Requirement 6.5, HIPAA Security Rule technical safeguards, SOC 2 CC6.1, NIST SP 800-53 controls, and GDPR Article 32 requirements. Generate compliance gap analysis with specific control references, evidence requirements, and remediation timelines. Document compliance evidence requirements, audit preparation guidance, and documentation standards for each compliance framework.

**Phase 8: Compliance Report Generation** produces audit-ready documentation with executive summary, technical findings, control mapping, and remediation guidance organized by compliance framework. Generate compliance dashboards for ongoing monitoring, evidence collection for audit processes, and compliance trend analysis. Create compliance improvement tracking, remediation progress monitoring, and validation testing results. Document compliance status, gap analysis, and improvement recommendations for stakeholder communication.

## Tool Arsenal

**SSLyze** comprehensive TLS analysis tool evaluates server TLS configurations including protocol support, cipher suite analysis, certificate validation, OCSP stapling, and security feature detection. Its JSON output format enables automated compliance analysis and integration with compliance frameworks. SSLyze provides enterprise-grade TLS compliance testing with detailed reporting and compliance mapping.

**testssl.sh** feature-rich TLS testing tool provides detailed protocol analysis, cipher suite testing, vulnerability detection (BEAST, POODLE, Heartbleed, ROBOT, Ticketbleed), and certificate validation. Its compliance checking capabilities map findings to PCI DSS, NIST, and other standards with specific control references. testssl.sh provides comprehensive TLS security assessment with compliance mapping and remediation guidance.

**SecurityHeaders.com** web service analyzes HTTP security header configurations with scoring, compliance recommendations, and industry benchmarking. Its API enables automated header compliance assessment with historical tracking and trend analysis. SecurityHeaders.com provides security header compliance analysis with industry comparison and best practice guidance.

**Mozilla Observatory** comprehensive web security assessment tool evaluates security headers, TLS configuration, CSP implementation, and vulnerability exposure. Its grading system provides clear compliance indicators with detailed remediation guidance. Mozilla Observatory provides web security compliance assessment with scoring methodology and improvement recommendations.

**curl** command-line tool enables manual TLS testing, header analysis, and certificate validation for compliance verification with detailed protocol output. curl provides granular HTTP protocol analysis for compliance testing, configuration verification, and manual assessment.

**openssl** cryptographic toolkit provides certificate analysis, TLS protocol testing, cipher suite evaluation, and PKI validation for detailed compliance assessment. openssl provides comprehensive cryptographic analysis for compliance validation, certificate management, and security assessment.

**Custom Python Compliance Framework** combines header analysis, cookie validation, TLS testing, certificate checking, and mixed content detection into comprehensive compliance assessment pipelines with control mapping, evidence collection, and reporting capabilities.

**OWASP ZAP** automated security scanner includes compliance checking capabilities for security headers, TLS configuration, cookie security, and common vulnerability detection with compliance reporting. OWASP ZAP provides open-source security compliance testing with extensible scanning and compliance frameworks.

**WAVE** web accessibility evaluation tool provides WCAG compliance assessment including keyboard navigation, screen reader compatibility, semantic structure analysis, and detailed violation reporting. WAVE provides accessibility compliance testing with visual feedback and remediation guidance.

**axe-core** accessibility testing engine provides automated WCAG compliance checking with detailed violation reporting, impact assessment, and remediation guidance. axe-core provides programmatic accessibility compliance testing with integration into development workflows.

**Lighthouse** Google web performance and quality tool includes accessibility, best practices, and SEO auditing with compliance scoring and improvement recommendations. Lighthouse provides comprehensive web quality compliance assessment with actionable insights.

**Nmap** network scanner includes SSL/TLS analysis scripts (ssl-enum-ciphers, ssl-cert, ssl-known-key) for compliance verification and security assessment. Nmap provides network-level TLS compliance testing with comprehensive protocol analysis.

**Qualys SSL Labs API** comprehensive SSL/TLS assessment with grading, compliance analysis, and industry benchmarking for server security configurations. Qualys SSL Labs provides enterprise TLS compliance assessment with detailed reporting and trend analysis.

## Case Studies

**Case Study 1: PCI DSS Web Application Compliance** - Comprehensive compliance assessment for an e-commerce platform identified 23 security header deficiencies, 7 cookie security violations, and TLS configuration issues including support for TLS 1.0 and weak cipher suites. Findings mapped to specific PCI DSS requirements including Requirement 6.5.1 (information leakage), Requirement 4.1 (encryption in transit), and Requirement 6.2 (security patches). Automated compliance reporting provided audit evidence for PCI DSS certification including configuration screenshots, scan results, and remediation documentation.

**Case Study 2: HIPAA Technical Safeguards Assessment** - Compliance assessment for a healthcare portal evaluated security configurations against HIPAA Security Rule technical safeguards including access controls, audit controls, integrity controls, and transmission security. Findings included missing Content-Security-Policy headers, inadequate HSTS configuration, and mixed content violations that could expose protected health information during transmission. Compliance gap analysis documented specific HIPAA sections requiring remediation with evidence requirements and timelines.

**Case Study 3: SOC 2 Type II Evidence Collection** - Automated compliance assessment for a SaaS platform generated continuous compliance evidence for SOC 2 Type II audit including security, availability, processing integrity, confidentiality, and privacy criteria. Real-time monitoring of security headers, TLS configurations, and cookie settings provided ongoing evidence of security control effectiveness with automated evidence collection and documentation.

**Case Study 4: GDPR Security Assessment** - Compliance assessment for a European e-commerce platform evaluated technical security controls supporting GDPR Article 32 requirements for appropriate technical and organizational measures to ensure a level of security appropriate to the risk. Findings included inadequate encryption configurations, insufficient access control headers, and privacy-related cookie compliance issues affecting data subject rights.

**Case Study 5: Multi-Framework Compliance Dashboard** - Implementation of automated compliance monitoring across 45 web applications consolidated compliance status into unified dashboards for PCI DSS, HIPAA, SOC 2, GDPR, and internal security standards. Real-time compliance tracking identified configuration drift, new compliance gaps, and remediation progress across all frameworks with automated alerting and escalation.

## Bypass Techniques

**Security Header Bypass Testing** evaluates whether security headers can be bypassed through content-type manipulation, encoding variations, request parameter injection, or endpoint-specific bypasses. Test header enforcement across different content types, HTTP methods, request parameters, and application endpoints to identify bypass possibilities. Implement automated bypass testing for comprehensive compliance validation across all application sections.

**TLS Configuration Bypass** tests whether deprecated protocols or weak cipher suites can be forced through protocol downgrade attacks, cipher suite manipulation, client-side configuration exploitation, or network-level manipulation. Assess TLS configuration resilience against known attack vectors including POODLE, DROWN, and BEAST. Implement protocol downgrade testing for compliance validation and security assessment.

**Cookie Security Bypass** evaluates cookie security attribute enforcement through subdomain testing, path manipulation, cross-origin request analysis, and browser-specific behavior testing. Verify SameSite, Secure, and HttpOnly attribute enforcement across different request contexts including subdomains, API calls, and embedded content. Implement automated cookie security bypass testing for compliance validation.

**Mixed Content Bypass** identifies cases where mixed content filtering can be circumvented through content injection, protocol-relative URLs, data URI schemes, or JavaScript-based resource loading. Test mixed content detection and prevention mechanisms across different browsers and content types. Implement mixed content bypass testing for compliance validation and security assessment.

**CSP Bypass** evaluates Content-Security-Policy enforcement by testing inline script execution, external resource loading, eval() usage, and policy directive compliance across different content types and contexts. Identify CSP weaknesses including weak directives, missing policies, and bypassable configurations that could be exploited despite policy implementation. Implement automated CSP bypass testing for compliance assessment.

**Certificate Validation Bypass** tests certificate chain validation enforcement by presenting invalid, expired, self-signed, or revoked certificates to assess strict validation compliance across different clients and configurations. Implement certificate validation bypass testing for compliance verification and security assessment.

## Advanced Techniques

**Automated Compliance Control Mapping** applies natural language processing to compliance frameworks for automated mapping between technical findings and compliance requirements. Parse regulatory documents, extract control requirements, and correlate with automated assessment results using text similarity and semantic analysis. Implement machine learning models for compliance requirement extraction, mapping, and gap identification across multiple frameworks.

**Continuous Compliance Monitoring** implements real-time compliance tracking that detects configuration changes, compliance drift, remediation progress, and new compliance gaps through automated scanning and baseline comparison. Event-driven architectures enable immediate alerting for compliance violations with configurable thresholds and escalation procedures. Implement compliance change detection and notification systems with audit trail documentation.

**Compliance Risk Scoring** calculates quantitative compliance risk scores based on finding severity, control criticality, exposure assessment, and business impact analysis. Risk scoring enables prioritized remediation, compliance gap prioritization, and resource allocation optimization. Implement compliance risk models for business impact analysis and executive reporting.

**Evidence Collection Automation** generates audit-ready evidence packages including technical findings, configuration snapshots, scan results, assessment methodology documentation, and compliance control mapping. Automated evidence collection streamlines audit preparation, reduces manual effort, and ensures consistent documentation. Implement evidence management systems for audit compliance with version control and retention policies.

**Compliance Trend Analysis** tracks compliance status over time, identifying improvement patterns, recurring issues, compliance drift trends, and remediation effectiveness. Historical analysis supports audit preparation, compliance program improvement, and continuous monitoring. Implement compliance trend visualization, reporting, and forecasting for stakeholder communication.

**Cross-Framework Compliance Correlation** maps compliance requirements across multiple frameworks (PCI DSS, HIPAA, SOC 2, GDPR, NIST, ISO 27001) to identify overlapping controls, unified compliance strategies, and assessment efficiency opportunities. Cross-framework analysis reduces assessment duplication, improves compliance efficiency, and enables unified control implementations.

## Detection Indicators

Compliance checking activities generate detectable indicators across web server monitoring, TLS infrastructure, and security systems. Web server logs capture compliance assessment requests including header analysis, TLS testing, certificate validation activities, and systematic security probing. TLS monitoring systems detect compliance testing through unusual cipher suite negotiation patterns, protocol version probing, and certificate validation attempts. Rate limiting systems monitor compliance assessment request frequency and trigger blocks for systematic assessment patterns. Security scanning detection identifies compliance assessment activities through signature-based request analysis, user-agent fingerprinting, and behavioral pattern detection. SIEM systems correlate compliance assessment activities with other security indicators including vulnerability scanning, penetration testing, and reconnaissance activities for comprehensive security monitoring.

## Impact Assessment

Successful compliance assessment provides organizations with actionable intelligence for maintaining regulatory compliance, addressing security deficiencies, demonstrating security control effectiveness, and preparing for audit processes. Automated compliance checking enables continuous compliance monitoring, evidence collection, and gap identification for ongoing compliance management. From a business perspective, compliance assessment identifies regulatory risk exposure, compliance gaps requiring remediation, evidence collection requirements for audit processes, and compliance program effectiveness metrics. Findings enable prioritized remediation, compliance roadmap development, audit preparation, and continuous compliance improvement. Quantified compliance assessment considers compliance gap severity, regulatory risk exposure, remediation priority, audit readiness, and business impact. Critical findings include high-risk compliance gaps, evidence of control failures, configuration drift from compliance baselines, and missing audit evidence documentation.

## Common Pitfalls

Compliance framework interpretation varies across organizations, auditors, and jurisdictions as regulatory requirements often contain ambiguous language, technology-neutral requirements, and evolving guidance. Technical implementation guidance requires careful mapping between regulatory language and specific technical controls with consideration for organizational context and risk appetite. Compliance testing accuracy varies across tools and methodologies as compliance requirements may require manual verification beyond automated assessment capabilities, judgment-based evaluation, and contextual assessment. Combining automated and manual assessment approaches improves compliance coverage and accuracy. Compliance monitoring scope limitations may miss compliance gaps in areas not covered by automated assessment tools, custom applications, and third-party integrations. Regular assessment scope reviews ensure comprehensive compliance coverage across all application components and environments.

## Integration Points

Compliance checking integrates with vulnerability scanning workflows to provide compliance context for security findings, risk prioritization, and remediation planning. Feed compliance assessment results into vulnerability management platforms for compliance-aware risk prioritization and remediation tracking. Connect compliance monitoring with change management processes for compliance impact assessment of infrastructure changes, deployments, and configuration modifications. Compliance assessment feeds into governance, risk, and compliance (GRC) platforms for enterprise compliance management, risk assessment, and executive reporting. Connect with audit management systems for evidence collection, compliance reporting, and audit workflow management. Integrate compliance monitoring with security information and event management (SIEM) systems for compliance event correlation and security monitoring.

## Reporting Templates

**Compliance Assessment Report** documents all compliance findings organized by framework, control category, and risk severity. Include executive summary, detailed findings, control mapping, remediation recommendations, and compliance evidence with business impact assessment.

**Compliance Dashboard** presents real-time compliance status across monitored applications with framework-specific compliance scores, trend analysis, compliance gap tracking, and remediation progress. Designed for ongoing compliance monitoring and audit preparation with configurable views and filtering.

**Audit Evidence Package** provides comprehensive compliance evidence including technical findings, configuration snapshots, assessment methodology documentation, compliance control mapping, and remediation evidence. Formatted for audit team review and regulatory submission with proper documentation standards.

## Practice Labs

**Lab 1: Security Header Compliance Assessment** - Build a comprehensive security header compliance assessment tool that evaluates CSP, HSTS, X-Content-Type-Options, X-Frame-Options, and other headers against PCI DSS, NIST, and OWASP requirements with automated control mapping.

**Lab 2: TLS Compliance Testing** - Implement automated TLS compliance testing that evaluates protocol versions, cipher suites, certificate configurations, and security features against PCI DSS, NIST, and HIPAA compliance standards.

**Lab 3: Continuous Compliance Monitoring** - Develop a continuous compliance monitoring system that detects configuration changes, compliance drift, and new compliance gaps in real-time with automated alerting and evidence collection.

**Lab 4: Multi-Framework Compliance Mapping** - Build compliance control mapping tools that correlate technical findings across PCI DSS, HIPAA, SOC 2, and GDPR frameworks identifying overlapping controls and unified remediation strategies.

## Ethics

Compliance checking must be performed within authorized boundaries respecting target organization consent and scope limitations. Obtain proper authorization before performing compliance assessments against web applications. Minimize assessment activities to necessary scope for authorized compliance evaluations. Protect compliance assessment data through encryption, access controls, and retention policies. Report compliance vulnerabilities through responsible disclosure channels while respecting regulatory reporting requirements. Document all compliance assessment activities for accountability and audit trail requirements. Maintain assessment integrity by accurately representing findings without exaggeration or minimization of compliance gaps.

## Quick Reference

| Compliance Area | Tool | Assessment Target |
|----------------|------|-------------------|
| Security Headers | SecurityHeaders.com | CSP, HSTS, X-Frame-Options |
| TLS Configuration | SSLyze, testssl.sh | Protocols, cipher suites |
| Certificate Validation | openssl, SSLyze | Chain, expiration, key strength |
| Cookie Security | Custom scripts | Secure, HttpOnly, SameSite |
| Mixed Content | Browser tools | HTTP resources in HTTPS |
| Accessibility | WAVE, axe-core | WCAG 2.1 compliance |
| PCI DSS | Custom framework | Requirement 6.5, 4.1 mapping |
| HIPAA | Custom framework | Technical safeguards |
| SOC 2 | Custom framework | CC6.1 security controls |
| GDPR | Custom framework | Article 32 requirements |
| OWASP Top 10 | Custom framework | Vulnerability mapping |
| NIST 800-53 | Custom framework | Control assessment |
| ISO 27001 | Custom framework | Annex A controls |
| CSP Compliance | CSP evaluator | Directive validation |
| HSTS Compliance | HSTS preload list | Preload eligibility |
| Protocol Compliance | testssl.sh | Deprecated protocol check |
| Cipher Compliance | SSLyze | Approved cipher validation |
| Certificate Compliance | Qualys SSL Labs | Certificate standards |
| Mixed Content Compliance | Browser console | Content policy enforcement |
| Form Security | Custom scripts | CSRF, autocomplete settings |
| Referrer Policy | SecurityHeaders.com | Referrer leakage prevention |
| Permissions Policy | SecurityHeaders.com | Feature access control |
| Cross-Origin Policies | Custom scripts | COEP, CORP, COOP validation |
| Content Type Compliance | Custom scripts | MIME type validation |
| Caching Compliance | Custom scripts | Sensitive data caching |
| Session Security | Custom scripts | Session management validation |
| Input Validation | Custom scripts | XSS/injection prevention |
| Error Handling | Custom scripts | Information disclosure |
| Logging Security | Custom scripts | Sensitive data logging |
| Authentication | Custom scripts | Password policy compliance |
| Authorization | Custom scripts | Access control validation |
| Data Encryption | Custom scripts | Encryption at rest/transit |
| Privacy Controls | Custom scripts | Data protection validation |
| Audit Logging | Custom scripts | Audit trail compliance |

---

## Deep Dive: Compliance Checking Techniques

### Security Header Compliance
```bash
# Check all security headers
curl -I https://target.com | grep -i "strict-transport-security\|content-security-policy\|x-frame-options\|x-content-type-options\|x-xss-protection\|referrer-policy\|permissions-policy"

# SecurityHeaders.com API
curl "https://securityheaders.com/?q=https://target.com&followRedirects=on"

# Check HSTS preload list
curl "https://hstspreload.org/api/v2/status?domain=target.com"

# Check CSP
curl -I https://target.com | grep -i "content-security-policy"

# Check for mixed content
curl -I https://target.com | grep -i "upgrade-insecure-requests"
```

### SSL/TLS Compliance
```bash
# TestSSL.sh
testssl.sh https://target.com

# SSLyze
sslyze --regular https://target.com

# Qualys SSL Labs API
curl "https://api.ssllabs.com/api/v3/analyze?host=target.com"

# Check for deprecated protocols
openssl s_client -connect target.com:443 -tls1
openssl s_client -connect target.com:443 -tls1_1

# Check certificate
openssl s_client -connect target.com:443 -servername target.com < /dev/null 2>/dev/null | openssl x509 -noout -dates
```

### CSP Compliance Analysis
```python
#!/usr/bin/env python3
"""Content Security Policy compliance analysis"""

import requests
import re
from typing import Dict, List

class CSPAnalyzer:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def analyze_csp(self) -> Dict:
        """Analyze Content Security Policy"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            csp_header = response.headers.get('Content-Security-Policy', '')

            if not csp_header:
                return {'status': 'missing', 'issues': ['No CSP header found']}

            analysis = {
                'status': 'present',
                'directives': self._parse_directives(csp_header),
                'issues': [],
                'recommendations': [],
            }

            # Check for common issues
            if "'unsafe-inline'" in csp_header:
                analysis['issues'].append("'unsafe-inline' allows inline scripts")

            if "'unsafe-eval'" in csp_header:
                analysis['issues'].append("'unsafe-eval' allows eval()")

            if "*" in csp_header:
                analysis['issues'].append("Wildcard (*) in source list")

            if "data:" in csp_header:
                analysis['issues'].append("data: URI scheme allowed")

            if "http:" in csp_header:
                analysis['issues'].append("HTTP sources allowed")

            # Generate recommendations
            if "'unsafe-inline'" in csp_header:
                analysis['recommendations'].append("Use nonces or hashes instead of 'unsafe-inline'")

            if "'unsafe-eval'" in csp_header:
                analysis['recommendations'].append("Remove 'unsafe-eval' and use safer alternatives")

            if "*" in csp_header:
                analysis['recommendations'].append("Replace wildcard with specific domains")

            return analysis

        except Exception:
            return {'status': 'error', 'issues': ['Failed to retrieve CSP']}

    def _parse_directives(self, csp: str) -> Dict[str, List[str]]:
        """Parse CSP directives"""
        directives = {}
        parts = csp.split(';')

        for part in parts:
            part = part.strip()
            if ' ' in part:
                directive, value = part.split(' ', 1)
                directives[directive] = value.split()

        return directives

    def check_csp_support(self) -> Dict:
        """Check CSP support via meta tags"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            meta_csp = re.search(
                r'<meta[^>]*http-equiv=["\']Content-Security-Policy["\'][^>]*content=["\']([^"\']+)["\']',
                response.text,
                re.IGNORECASE
            )

            if meta_csp:
                return {'supported': True, 'policy': meta_csp.group(1)}
            else:
                return {'supported': False}

        except Exception:
            return {'supported': False}

# Usage
analyzer = CSPAnalyzer("https://target.com")
csp_analysis = analyzer.analyze_csp()
print("CSP Analysis:", csp_analysis)
```

### HSTS Compliance Analysis
```python
#!/usr/bin/env python3
"""HTTP Strict Transport Security compliance analysis"""

import requests
from typing import Dict

class HSTSAnalyzer:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def analyze_hsts(self) -> Dict:
        """Analyze HSTS configuration"""
        try:
            response = self.session.get(self.base_url, timeout=5)
            hsts_header = response.headers.get('Strict-Transport-Security', '')

            if not hsts_header:
                return {'status': 'missing', 'issues': ['No HSTS header found']}

            analysis = {
                'status': 'present',
                'max_age': self._extract_max_age(hsts_header),
                'include_subdomains': 'includeSubDomains' in hsts_header,
                'preload': 'preload' in hsts_header,
                'issues': [],
                'recommendations': [],
            }

            # Check max-age
            if analysis['max_age'] < 31536000:  # 1 year
                analysis['issues'].append(f"max-age ({analysis['max_age']}) is less than 1 year")
                analysis['recommendations'].append("Set max-age to at least 31536000 (1 year)")

            if not analysis['include_subdomains']:
                analysis['issues'].append("includeSubDomains not set")
                analysis['recommendations'].append("Add includeSubDomains directive")

            if not analysis['preload']:
                analysis['issues'].append("preload not set")
                analysis['recommendations'].append("Add preload directive for HSTS preload list")

            return analysis

        except Exception:
            return {'status': 'error', 'issues': ['Failed to retrieve HSTS']}

    def _extract_max_age(self, hsts: str) -> int:
        """Extract max-age value"""
        import re
        match = re.search(r'max-age=(\d+)', hsts)
        return int(match.group(1)) if match else 0

    def check_preload_eligibility(self) -> Dict:
        """Check HSTS preload eligibility"""
        try:
            response = self.session.get(
                f"https://hstspreload.org/api/v2/status?domain={self.base_url.split('//')[1]}",
                timeout=5
            )
            data = response.json()

            return {
                'eligible': data.get('status') == 'ready',
                'status': data.get('status', 'unknown'),
                'errors': data.get('errors', []),
            }

        except Exception:
            return {'eligible': False, 'status': 'error'}

# Usage
analyzer = HSTSAnalyzer("https://target.com")
hsts_analysis = analyzer.analyze_hsts()
print("HSTS Analysis:", hsts_analysis)
```

### Cookie Security Analysis
```python
#!/usr/bin/env python3
"""Cookie security compliance analysis"""

import requests
from typing import Dict, List

class CookieAnalyzer:
    def __init__(self, base_url: str):
        self.base_url = base_url
        self.session = requests.Session()

    def analyze_cookies(self) -> Dict:
        """Analyze cookie security attributes"""
        try:
            response = self.session.get(self.base_url, timeout=5)

            analysis = {
                'cookies': [],
                'issues': [],
                'recommendations': [],
            }

            for cookie in response.cookies:
                cookie_info = {
                    'name': cookie.name,
                    'secure': cookie.secure,
                    'httponly': cookie.has_nonstandard_attr('httponly'),
                    'samesite': self._extract_samesite(cookie),
                    'domain': cookie.domain,
                    'path': cookie.path,
                }

                analysis['cookies'].append(cookie_info)

                # Check for issues
                if not cookie.secure:
                    analysis['issues'].append(f"Cookie '{cookie.name}' missing Secure flag")
                    analysis['recommendations'].append(f"Add Secure flag to '{cookie.name}'")

                if not cookie_info['httponly']:
                    analysis['issues'].append(f"Cookie '{cookie.name}' missing HttpOnly flag")
                    analysis['recommendations'].append(f"Add HttpOnly flag to '{cookie.name}'")

                if not cookie_info['samesite']:
                    analysis['issues'].append(f"Cookie '{cookie.name}' missing SameSite attribute")
                    analysis['recommendations'].append(f"Add SameSite=Strict or SameSite=Lax to '{cookie.name}'")

            return analysis

        except Exception:
            return {'cookies': [], 'issues': ['Failed to retrieve cookies']}

    def _extract_samesite(self, cookie) -> str:
        """Extract SameSite attribute"""
        for value in cookie._rest:
            if 'samesite' in value.lower():
                return value.split('=')[1].strip()
        return None

# Usage
analyzer = CookieAnalyzer("https://target.com")
cookie_analysis = analyzer.analyze_cookies()
print("Cookie Analysis:", cookie_analysis)
```

---

## Comprehensive Compliance Checking Script

```python
#!/usr/bin/env python3
"""Comprehensive security compliance checking"""

import requests
import json
import sys
from typing import Dict, List, Any
from dataclasses import dataclass

@dataclass
class ComplianceCheck:
    name: str
    status: str  # 'pass', 'fail', 'warning'
    details: str
    severity: str  # 'critical', 'high', 'medium', 'low', 'info'

class ComplianceChecker:
    def __init__(self, url: str):
        self.url = url
        self.session = requests.Session()
        self.checks = []

    def run_all_checks(self) -> List[ComplianceCheck]:
        """Run all compliance checks"""
        print(f"[*] Running compliance checks for: {self.url}")

        # Security headers
        self._check_security_headers()

        # SSL/TLS
        self._check_ssl_tls()

        # Cookies
        self._check_cookies()

        # Content Security Policy
        self._check_csp()

        # HSTS
        self._check_hsts()

        # Information disclosure
        self._check_information_disclosure()

        return self.checks

    def _check_security_headers(self):
        """Check security headers"""
        try:
            response = self.session.get(self.url, timeout=5)
            headers = response.headers

            # X-Frame-Options
            if 'X-Frame-Options' in headers:
                self.checks.append(ComplianceCheck(
                    name='X-Frame-Options',
                    status='pass',
                    details=f"Header present: {headers['X-Frame-Options']}",
                    severity='medium'
                ))
            else:
                self.checks.append(ComplianceCheck(
                    name='X-Frame-Options',
                    status='fail',
                    details='Header missing',
                    severity='medium'
                ))

            # X-Content-Type-Options
            if 'X-Content-Type-Options' in headers:
                self.checks.append(ComplianceCheck(
                    name='X-Content-Type-Options',
                    status='pass',
                    details=f"Header present: {headers['X-Content-Type-Options']}",
                    severity='low'
                ))
            else:
                self.checks.append(ComplianceCheck(
                    name='X-Content-Type-Options',
                    status='fail',
                    details='Header missing',
                    severity='low'
                ))

            # X-XSS-Protection
            if 'X-XSS-Protection' in headers:
                self.checks.append(ComplianceCheck(
                    name='X-XSS-Protection',
                    status='pass',
                    details=f"Header present: {headers['X-XSS-Protection']}",
                    severity='low'
                ))
            else:
                self.checks.append(ComplianceCheck(
                    name='X-XSS-Protection',
                    status='warning',
                    details='Header missing (deprecated)',
                    severity='info'
                ))

        except Exception:
            pass

    def _check_ssl_tls(self):
        """Check SSL/TLS configuration"""
        # Simplified check
        try:
            response = self.session.get(self.url, timeout=5, verify=True)
            self.checks.append(ComplianceCheck(
                name='SSL/TLS',
                status='pass',
                details='SSL/TLS connection successful',
                severity='high'
            ))
        except Exception as e:
            self.checks.append(ComplianceCheck(
                name='SSL/TLS',
                status='fail',
                details=f'SSL/TLS error: {str(e)}',
                severity='high'
            ))

    def _check_cookies(self):
        """Check cookie security"""
        try:
            response = self.session.get(self.url, timeout=5)

            for cookie in response.cookies:
                if not cookie.secure:
                    self.checks.append(ComplianceCheck(
                        name=f'Cookie Security ({cookie.name})',
                        status='fail',
                        details='Missing Secure flag',
                        severity='medium'
                    ))

                if not cookie.has_nonstandard_attr('httponly'):
                    self.checks.append(ComplianceCheck(
                        name=f'Cookie HttpOnly ({cookie.name})',
                        status='fail',
                        details='Missing HttpOnly flag',
                        severity='medium'
                    ))

        except Exception:
            pass

    def _check_csp(self):
        """Check Content Security Policy"""
        try:
            response = self.session.get(self.url, timeout=5)
            csp = response.headers.get('Content-Security-Policy', '')

            if csp:
                if "'unsafe-inline'" in csp:
                    self.checks.append(ComplianceCheck(
                        name='CSP unsafe-inline',
                        status='fail',
                        details='unsafe-inline directive present',
                        severity='high'
                    ))
                else:
                    self.checks.append(ComplianceCheck(
                        name='CSP',
                        status='pass',
                        details='CSP header present',
                        severity='high'
                    ))
            else:
                self.checks.append(ComplianceCheck(
                    name='CSP',
                    status='fail',
                    details='No CSP header',
                    severity='high'
                ))

        except Exception:
            pass

    def _check_hsts(self):
        """Check HSTS configuration"""
        try:
            response = self.session.get(self.url, timeout=5)
            hsts = response.headers.get('Strict-Transport-Security', '')

            if hsts:
                self.checks.append(ComplianceCheck(
                    name='HSTS',
                    status='pass',
                    details=f'HSTS header present: {hsts}',
                    severity='high'
                ))
            else:
                self.checks.append(ComplianceCheck(
                    name='HSTS',
                    status='fail',
                    details='No HSTS header',
                    severity='high'
                ))

        except Exception:
            pass

    def _check_information_disclosure(self):
        """Check for information disclosure"""
        try:
            response = self.session.get(self.url, timeout=5)

            # Server header
            if 'Server' in response.headers:
                self.checks.append(ComplianceCheck(
                    name='Server Header',
                    status='warning',
                    details=f"Server header disclosed: {response.headers['Server']}",
                    severity='low'
                ))

            # X-Powered-By
            if 'X-Powered-By' in response.headers:
                self.checks.append(ComplianceCheck(
                    name='X-Powered-By',
                    status='warning',
                    details=f"X-Powered-By disclosed: {response.headers['X-Powered-By']}",
                    severity='low'
                ))

        except Exception:
            pass

    def generate_report(self) -> str:
        """Generate compliance report"""
        report = "=== Compliance Check Report ===\n"
        report += f"Target: {self.url}\n"
        report += f"Total Checks: {len(self.checks)}\n\n"

        # Group by status
        passed = [c for c in self.checks if c.status == 'pass']
        failed = [c for c in self.checks if c.status == 'fail']
        warnings = [c for c in self.checks if c.status == 'warning']

        report += f"Passed: {len(passed)}\n"
        report += f"Failed: {len(failed)}\n"
        report += f"Warnings: {len(warnings)}\n\n"

        if failed:
            report += "=== FAILED CHECKS ===\n"
            for check in failed:
                report += f"[{check.severity.upper()}] {check.name}: {check.details}\n"

        if warnings:
            report += "\n=== WARNINGS ===\n"
            for check in warnings:
                report += f"[{check.severity.upper()}] {check.name}: {check.details}\n"

        return report

# Usage
if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <url>")
        sys.exit(1)

    checker = ComplianceChecker(sys.argv[1])
    checks = checker.run_all_checks()
    print(checker.generate_report())
```

---

## Reporting Templates

### Compliance Report
```
## Security Compliance Report

### Target: [url]

### Compliance Summary
- Total checks: [count]
- Passed: [count]
- Failed: [count]
- Warnings: [count]

### Failed Checks
[List failed checks with severity and details]

### Warnings
[List warnings with severity and details]

### Recommendations
1. [Recommendation 1]
2. [Recommendation 2]
```

### Compliance Risk Matrix
| Severity | Condition | Impact |
|----------|-----------|--------|
| Critical | Missing SSL/TLS | Data exposure |
| High | No CSP | XSS risk |
| Medium | Missing security headers | Clickjacking |
| Low | Information disclosure | Reconnaissance aid |

---

## Quick Reference Cheat Sheet

### Security Headers
```bash
curl -I https://target.com | grep -i "strict-transport-security\|content-security-policy\|x-frame-options"
```

### SSL/TLS Check
```bash
testssl.sh https://target.com
sslyze --regular https://target.com
```

### Cookie Check
```bash
curl -I https://target.com | grep -i "set-cookie"
```

---

## Resources and References
- SecurityHeaders.com: https://securityheaders.com/
- SSL Labs: https://www.ssllabs.com/ssltest/
- Mozilla Observatory: https://observatory.mozilla.org/
- CSP Evaluator: https://csp-evaluator.withgoogle.com/
- HSTS Preload: https://hstspreload.org/
