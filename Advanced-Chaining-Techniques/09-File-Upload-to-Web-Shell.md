# File Upload to Web Shell: Complete Exploitation Guide

## Expert Role Definition
You are a senior application security researcher specializing in file upload vulnerability exploitation and web shell deployment. You have deep expertise in bypassing upload restrictions across Apache, Nginx, IIS, and Tomcat web servers. You understand the complete attack chain from initial file upload bypass to persistent remote code execution, including WAF evasion, detection avoidance, and post-exploitation cleanup. You have successfully chained file upload flaws with SSRF, LFI, and command injection in real-world bug bounty engagements. Your methodology is systematic, evidence-based, and focused on achieving maximum impact while maintaining ethical standards and responsible disclosure practices. Every finding you report includes a complete proof of concept and actionable remediation guidance.

---

## Core Concepts

File upload vulnerabilities occur when an application accepts user-uploaded files without properly validating file type, content, or destination path. The ultimate goal is deploying a web shell: a script that executes arbitrary server-side code upon HTTP request.

**Why File Upload is Critical:**
- Direct path to Remote Code Execution (RCE)
- Often bypasses network-level defenses (firewalls, WAFs)
- Can establish persistent backdoor access
- Chains with privilege escalation and lateral movement

**Common Upload Restriction Types:**
1. MIME Type Validation - Checks Content-Type header (trivially spoofable)
2. Extension Blacklist - Blocks known dangerous extensions (bypassable via alternatives)
3. Extension Whitelist - Only allows specific safe extensions (harder to bypass)
4. Magic Bytes Validation - Checks file header bytes (spoofable by prepending valid headers)
5. File Content Analysis - Scans file body for executable code (advanced but bypassable)
6. Size Limits - Restricts upload file size (usually irrelevant to exploitation)
7. Rename on Upload - Server renames file to random name (may break exploitation)
8. Re-rendering - Server processes image through GD or Imagick (destroys embedded code)
9. Directory Relocation - Moves upload to non-web-accessible directory (blocks access)

**The Exploitation Mindset:**
Every restriction has a bypass. MIME type checks only inspect headers. Extension blacklists miss alternative extensions. Magic bytes can be forged. Even content analysis can be defeated with polyglot files. The key is identifying which restrictions exist and selecting the appropriate bypass.

**Chain Escalation Potential:**
File upload leads to web shell, then RCE, then credential harvesting, then lateral movement, then full infrastructure compromise. This chain often represents the highest-impact finding in a bug bounty program.

---

## Pre-requisite Knowledge

Before attempting file upload exploitation, you must understand:

1. HTTP Multipart Encoding - How multipart/form-data bodies are structured with boundary strings and Content-Disposition headers
2. Web Server Configuration - How Apache, Nginx, and IIS serve static files and execute scripts
3. PHP Execution Context - How PHP processes files based on extension, .htaccess, and server configuration
4. File System Permissions - Unix permissions, directory traversal, and symlink behavior
5. Image Processing Libraries - How GD, ImageMagick, and PIL handle uploaded images
6. WAF Behavior - How web application firewalls inspect upload requests
7. Content-Disposition Parsing - Browser and server differences in filename parsing
8. Null Byte Handling - How different PHP versions handle null bytes in filenames
9. Archive Extraction Logic - How ZIP, TAR, and RAR extractors handle paths and symlinks
10. Web Server Logging - What upload activity gets logged for forensic analysis

---

## Chain Architecture / Attack Flow Diagram

```
+-----------------------------------------------------------------------+
|                    FILE UPLOAD TO WEB SHELL CHAIN                      |
+-----------------------------------------------------------------------+

  +----------------+    +------------------+    +-----------------+
  |  Recon Phase   |    | Upload Discovery |    | Restriction ID  |
  |                |    |                  |    |                 |
  | Find upload    |--->| /upload          |--->| MIME check?     |
  | endpoints      |    | /avatar          |    | Extension       |
  | Map allowed    |    | /file            |    |   blacklist?    |
  | content types  |    | /import          |    | Magic bytes?    |
  +----------------+    | /attachment      |    | Content scan?   |
                        +------------------+    | Rename?         |
                                                | Re-render?      |
                                                +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        | Bypass Selection |<---|  Restriction    |
                        |                  |    |  Analysis       |
                        | Content-Type     |    +-----------------+
                        |   spoof          |
                        | Double ext       |
                        | Null byte        |
                        | .htaccess        |
                        | Magic bytes      |
                        | Polyglot file    |
                        +--------+---------+
                                 |
                                 v
                        +------------------+    +-----------------+
                        |  Upload Payload  |--->|  Verify Upload  |
                        |                  |    |                 |
                        | PHP webshell     |    | Response code   |
                        | JSP or ASPX      |    | File path       |
                        | Polyglot image   |    | Direct access   |
                        | SVG with JS      |    | MIME sniff test |
                        +------------------+    +--------+--------+
                                                         |
                                                         v
                        +------------------+    +-----------------+
                        |  Execute Shell   |--->|  Post-Exploit   |
                        |                  |    |                 |
                        | HTTP request     |    | Credential      |
                        | Browser access   |    |   harvesting    |
                        | Reverse shell    |    | Pivot hosts     |
                        | File read/write  |    | Persistence     |
                        +------------------+    +-----------------+
```

---

## Step-by-Step Exploitation Methodology

### Phase 1: Upload Endpoint Discovery

**Step 1.1** Crawl for upload forms using automated tools. Check common paths including /upload, /uploads, /files, /api/upload, /api/files, /avatar, /import, /attachment. Use directory fuzzing with wordlists targeting upload-specific paths.

**Step 1.2** Analyze upload form behavior by intercepting the request in Burp Suite. Note the HTTP method, Content-Type header, field names, CSRF tokens, Accept header restrictions, and maximum file size.

### Phase 2: Restriction Identification

**Step 2.1** Test MIME type validation by uploading with correct extension but wrong Content-Type, then wrong extension but correct Content-Type. Document which validation layer is enforced.

**Step 2.2** Test extension blacklist by systematically testing php, php3, php4, php5, php7, phtml, pht, phar, asp, aspx, jsp, cfm, cgi, pl, py, and rb extensions. Document which are blocked.

**Step 2.3** Test magic bytes validation by prepending valid PNG (89 50 4E 47), GIF (47 49 46 38 39 61), or JPEG (FF D8 FF E0) headers to PHP payloads.

### Phase 3: Bypass Execution

**Step 3.1** Content-Type bypass: If server only validates the Content-Type header, change it to image/jpeg while keeping the .php extension. The Content-Type is entirely client-controlled.

**Step 3.2** Double extension bypass: If server checks only the last extension, use shell.php.jpg. If checking first extension, use shell.jpg.php. Test both patterns.

**Step 3.3** Null byte injection: In PHP versions before 5.3.4, a null byte truncates the filename: shell.php%00.jpg becomes shell.php. Requires specific PHP and OS combinations.

**Step 3.4** Case variation bypass: Try shell.pHp, shell.PHP, shell.PhP, shell.pHP. Some blacklists are case-sensitive while servers may be case-insensitive.

**Step 3.5** .htaccess upload on Apache: Upload a .htaccess file with AddType directives to make .jpg files execute as PHP. Then upload PHP code with .jpg extension.

**Step 3.6** Alternative PHP extensions: When .php is blocked, test .php3, .php4, .php5, .php7, .phtml, .pht, and .phar. These may execute depending on server configuration.

### Phase 4: Web Shell Deployment

**Step 4.1** Select appropriate webshell based on target environment. PHP uses system execution functions, JSP uses Runtime.exec, ASPX uses System.Diagnostics.Process.

**Step 4.2** Upload webshell using identified bypass. Access the file via URL and verify command execution with id or whoami command.

**Step 4.3** Confirm command output appears in HTTP response. Some shells execute but do not display output; adjust shell type if needed.

### Phase 5: Post-Exploitation

**Step 5.1** Establish persistent access by uploading a more capable backdoor to a less-scanned location using obfuscated code.

**Step 5.2** Harvest credentials from application configuration files, environment variables, and database connection strings.

**Step 5.3** Pivot to internal network using extracted credentials and compromised host as relay point.

---

## Tool Arsenal with Exact Commands

### Tool 1: Multipart Upload Analysis
In Burp Suite Proxy, intercept the upload request. Examine the multipart body structure including boundary string, Content-Disposition with filename and field name, and actual file content.

### Tool 2: Extension Fuzzing
Use a scripting language to iterate through dangerous extensions. For each, create a test file, send it to the upload endpoint, and record response status. Compare blocked versus accepted extensions.

### Tool 3: Magic Byte Prepending
Prepend valid image headers to payload. PNG: 8-byte header. GIF: 6-byte header. JPEG: 4-byte header. Only the header needs to be valid for magic byte validation.

### Tool 4: .htaccess Payload
Create .htaccess files with AddType directives mapping image extensions to PHP execution. Test php_flag engine on directives for restricted environments.

### Tool 5: Webshell Obfuscation
Use string concatenation and variable variables to break WAF signatures. Build execution functions from individual characters to avoid pattern matching.

### Tool 6: Upload Directory Discovery
After successful upload, check common storage paths: /uploads/, /files/, /media/, /images/, /attachments/, /tmp/, /public/uploads/, /static/uploads/.

---

## Real-World Case Studies

### Case Study 1: WordPress Plugin Upload RCE
**Target:** WordPress site with vulnerable file uploader plugin
**Restriction:** Extension blacklist blocking .php and .phtml
**Bypass:** PHP5 extension not in blacklist
**Attack Flow:** Plugin checked .php and .phtml but omitted .php5. Uploaded .php5 with image/jpeg Content-Type. Apache mod_php executed the file. Extracted database credentials from wp-config.php.
**Impact:** Full site takeover, all user data accessible

### Case Study 2: Drupal File Upload Bypass
**Target:** Drupal 8.x with file entity module
**Restriction:** Extension whitelist allowing only jpg, png, gif
**Bypass:** Double extension with Apache handler
**Attack Flow:** Server checked only last extension. shell.php.jpg passed because .jpg was whitelisted. Apache AddHandler processed .php anywhere in filename.
**Impact:** Admin session hijacking, full CMS takeover

### Case Study 3: Apache Struts Multipart Bypass
**Target:** Enterprise Java application using Apache Struts 2
**Restriction:** Content-Type validation plus filename sanitization
**Bypass:** Content-Type manipulation with expression language injection
**Attack Flow:** Changed Content-Type to image/png with .action extension. Server did not sanitize filename. Uploaded file contained expression language payloads executed in application context.
**Impact:** Remote code execution as application server user

### Case Study 4: Enterprise CMS Upload Chain
**Target:** Custom CMS with image upload and processing
**Restriction:** Image re-rendering destroys embedded code
**Bypass:** SVG upload to stored XSS to admin function access
**Attack Flow:** CMS allowed SVG uploads. SVGs with embedded JavaScript executed when admin viewed page. Stored XSS provided access to admin template editing with server-side code execution.
**Impact:** Full server compromise through chained vulnerabilities

---

## Bypass Techniques and Evasion

### Extension Blacklist Bypass Matrix

| Web Server | Blocked | Alternatives |
|------------|---------|--------------|
| Apache + mod_php | .php, .phtml | .php3, .php4, .php5, .php7, .pht, .phar |
| IIS | .asp, .aspx | .cer, .asa, .cdx, .htr |
| Nginx + PHP-FPM | .php | .php5, .phtml if configured |
| Tomcat | .jsp | .jspx, .jsw, .jsv |

### MIME Type Bypass
Change Content-Type within multipart body to image type. Add double Content-Type headers for parser differential. Add extra spaces in Content-Disposition for bypass.

### Magic Byte Spoofing
Prepend valid image headers to payload. Only header bytes need to be valid. Actual image data need not conform to format specs.

### WAF Evasion
Chunked encoding prevents WAF reassembly. URL-encoded filenames bypass decode-before-inspection. Unusual boundary strings evade pattern matching.

---

## Defensive Indicators / Detection

### Server-Side Indicators
- Unexpected file extensions appearing in upload directories after requests
- Files with mismatched Content-Type and actual file type in the filesystem
- PHP, JSP, or ASPX files appearing in user-upload directories
- Increased CPU usage correlating with upload requests
- Unusual process trees showing webserver spawning shell commands

### WAF Detection Signatures
- PHP opening tags in uploaded file content
- Double file extensions matching dangerous patterns
- .htaccess or .user.ini file uploads
- Image files with executable code patterns
- Unusual Content-Type headers in multipart uploads

### Log Analysis
Check access logs for POST requests to upload endpoints followed by GET requests with command parameters. Look for unusual file extension patterns in the upload directory access logs.

---

## Impact Assessment Framework

| Factor | Low | Medium | High | Critical |
|--------|-----|--------|------|----------|
| Access Level | Read-only | Limited write | Full write | RCE with persistence |
| Data Exposure | None | Public files | User data | Credentials and secrets |
| Authentication | Not required | Low-priv user | Any user | Admin context |
| Chaining | None | LFI or SSRF | Priv escalation | Domain compromise |
| Business Impact | Minimal | Data modification | Data breach | Full system takeover |

**CVSS 3.1 Scoring:** Base RCE score: AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H = 8.8 (High). With domain compromise chain: AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H = 10.0 (Critical).

---

## Common Pitfalls and Anti-Patterns

1. Assuming MIME type validation is sufficient - Content-Type headers are client-controlled
2. Using blacklists instead of whitelists - New dangerous extensions emerge regularly
3. Not testing alternative extensions - PHP3, PHP4, PHP5, PHTML, PHT, PHAR may execute
4. Ignoring .htaccess uploads - Enables PHP execution in upload directories
5. Forgetting Nginx cgi.fix_pathinfo - Can pass image files to PHP-FPM
6. Not testing on actual web server - Local testing may not reflect production config
7. Skipping post-upload verification - Always verify file is accessible and executable
8. Not checking rename behavior - Server may rename files breaking access paths
9. Ignoring re-rendering - Image processing may destroy embedded code
10. Forgetting path traversal - Filenames with ../ can write outside upload directory

---

## Advanced Variations

### ZIP Slip for Arbitrary File Write
Create archive files with path traversal in filenames. When extracted by vulnerable libraries, files are written outside the intended directory. This bypasses upload directory restrictions entirely.

### ImageMagick Code Execution
Craft SVG files that trigger command execution during ImageMagick processing. The file passes content scanning as valid image but executes code when processed server-side.

### SVG Upload to Stored XSS
Upload SVG files with embedded JavaScript. When viewed, JavaScript executes in victim browser. Use to steal admin tokens or access admin functionality with server-side code execution.

### Symlink Attack in Archives
Create archives containing symbolic links to sensitive files like /etc/passwd or application configuration. When extracted, symlinks provide read access through normal file serving paths.

### Polyglot File Creation
Create files that are simultaneously valid images AND executable scripts. Use image format specifications allowing comment sections to contain executable code. Passes image validation while executing as a script.

---

## Integration with Other Chains

### File Upload to SSRF
Upload PHP webshell with SSRF capability. Use to make requests to internal network, cloud metadata endpoints, or services not directly accessible. Chain with cloud metadata for credential theft.

### File Upload to LFI
Upload webshell to non-standard directory. Exploit Local File Inclusion to include uploaded webshell. Combine with path traversal for deeper file inclusion.

### File Upload to Privilege Escalation
Upload webshell in low-privilege context. Read application configuration for database credentials. Use database access to find or create admin accounts. Chain with additional vulnerabilities.

### File Upload to Command Injection
Upload PHP webshell. Access admin panel functionality. Find command injection in admin tools. Achieve reverse shell with elevated privileges.

---

## Reporting and Documentation

**Title:** File Upload to RCE via [bypass technique]
**Severity:** Critical (CVSS 3.1: 8.8 to 10.0)
**Endpoint:** HTTP method and URL

**Description:** Application accepts file uploads but fails to properly validate [specific restriction]. This allows uploading a webshell executing arbitrary commands.

**Reproduction Steps:**
1. Navigate to upload endpoint
2. Intercept and modify request as described
3. Access uploaded file at URL
4. Observe command execution in response

**Impact:** Remote code execution, full server compromise, lateral movement potential
**Remediation:** Extension whitelist, content validation, store outside web root, random filenames, antivirus scanning

---

## Practice Labs and Exercises

Deploy local vulnerable upload applications for practice. Use purpose-built upload challenge apps and vulnerable CMS installations.

**Progressive Exercises:**
- Level 1: Bypass MIME type validation
- Level 2: Bypass extension blacklist
- Level 3: Upload .htaccess for PHP execution
- Level 4: Create polyglot file
- Level 5: Chain with path traversal
- Level 6: Complete chain to credential extraction
- Level 7: Evade WAF detection

**Self-Assessment:**
- [ ] Can identify all upload endpoints
- [ ] Can determine active restrictions
- [ ] Can bypass MIME and extension validation
- [ ] Can achieve command execution
- [ ] Can establish reverse shell

---

## Ethical Guidelines

1. **Authorization First** - Only test within authorized scope
2. **Document Everything** - Record all attempts and exploitation steps
3. **Minimize Footprint** - Upload only necessary test files
4. **No Real Data Exfiltration** - Use synthetic data only
5. **Responsible Disclosure** - Report through official channels
6. **Avoid Persistence** - Remove all webshells after testing
7. **Scope Boundaries** - Do not test out-of-scope systems
8. **Client Communication** - Report critical findings immediately
9. **Legal Compliance** - Comply with local laws and engagement rules
10. **Professional Standards** - Maintain confidentiality

---

## Quick Reference Cheat Sheet

### Bypass Decision Tree
```
Extension blacklisted? -> Try .php5, .phtml, .pht, .phar
MIME validated? -> Change Content-Type to image/jpeg
Magic bytes checked? -> Prepend PNG/GIF/JPEG header
.htaccess blocked? -> Try .user.ini
Content scanned? -> Use polyglot or obfuscated payload
```

### PHP Webshell Patterns
- System execution: Calls system functions with user input parameter
- Eval-based: Accepts encoded input evaluated as PHP
- File-based: Writes commands to file, reads output
- Callback-based: Uses PHP callback functions for execution

### Path Traversal Payloads
- Standard: dot-dot-slash sequences to parent directories
- URL-encoded: Percent-encoded dots and slashes
- Double-encoded: Double percent encoding for WAF bypass

### Post-Upload Verification
1. Confirm file accessible via direct URL
2. Confirm file content not modified during storage
3. Confirm command execution returns output
