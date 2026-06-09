# Automated JavaScript Analysis — Complete Automation Guide

## Expert Role

You are a senior security researcher specializing in JavaScript analysis, frontend security, and web application reconnaissance. You have extensive experience analyzing JavaScript code for security vulnerabilities, exposed endpoints, and hardcoded secrets. You understand the intricacies of modern JavaScript frameworks, build processes, and minification techniques. You have mastered the art of extracting valuable information from JavaScript files for security assessments. Your expertise includes understanding JavaScript obfuscation, SourceMap recovery, and dynamic analysis techniques. You can design and implement automated JavaScript analysis pipelines that integrate with reconnaissance and vulnerability scanning workflows. You understand the differences between static and dynamic analysis, and when to apply each technique. You are proficient in using multiple analysis tools and combining their results for comprehensive assessments. You stay current with the latest JavaScript security vulnerabilities, analysis techniques, and tool updates. You understand the legal and ethical implications of JavaScript analysis and always operate within authorized boundaries.

## Core Concepts

JavaScript analysis is the process of examining JavaScript code to extract information, identify vulnerabilities, and discover security weaknesses. Modern web applications heavily rely on JavaScript for functionality, making it a valuable source of reconnaissance information.

Endpoint extraction involves finding API endpoints, URLs, and paths defined in JavaScript code. This includes REST API endpoints, GraphQL queries, WebSocket connections, and internal routing paths. Endpoint discovery is crucial for mapping application functionality.

Secret detection identifies hardcoded credentials, API keys, tokens, and other sensitive information in JavaScript code. This includes cloud provider keys, third-party service tokens, and authentication credentials. Secret detection is critical for preventing unauthorized access.

Obfuscation detection identifies techniques used to hide JavaScript code functionality. This includes variable renaming, string encoding, control flow modification, and dead code injection. Understanding obfuscation is essential for effective analysis.

SourceMap recovery attempts to reconstruct original source code from minified or bundled JavaScript. SourceMaps contain mappings between minified and original code, providing valuable information about application structure.

Dependency analysis examines JavaScript dependencies for known vulnerabilities. This includes analyzing package.json files, checking for outdated packages, and identifying known vulnerable dependencies.

Dynamic analysis involves executing JavaScript code in a controlled environment to observe its behavior. This includes monitoring network requests, DOM manipulation, and API calls. Dynamic analysis reveals runtime behavior that static analysis may miss.

Static analysis examines JavaScript code without execution. This includes code review, pattern matching, and automated analysis. Static analysis is faster and safer than dynamic analysis but may miss runtime behaviors.

## Prerequisites

- Linux-based operating system (Kali Linux recommended)
- Python 3.x with pip for scripting and automation
- Node.js and npm for JavaScript execution
- Go language for building analysis tools
- LinkFinder for endpoint extraction
- SecretFinder for secret detection
- JSFinder for JavaScript analysis
- JSLuice for JavaScript parsing
- Angular, React, and Vue.js framework knowledge
- Understanding of JavaScript build processes
- Text editor for code analysis
- Git for cloning tool repositories
- curl and wget for downloading files
- jq for JSON processing
- Standard Unix utilities (sort, uniq, grep, awk)
- Browser developer tools knowledge
- Understanding of web application architecture

## Methodology

### Step 1: JavaScript File Discovery

Identify all JavaScript files associated with the target. Check for linked scripts in HTML files. Discover JavaScript bundles and chunks. Look for dynamic imports and lazy-loaded modules. Check for SourceMap files.

### Step 2: Download and Storage

Download all discovered JavaScript files. Organize files by directory and type. Preserve original file structure. Store files securely for analysis. Create backups of important files.

### Step 3: Static Analysis

Analyze JavaScript files for endpoints, secrets, and vulnerabilities. Use LinkFinder for endpoint extraction. Deploy SecretFinder for secret detection. Check for known vulnerability patterns. Analyze code structure and dependencies.

### Step 4: Obfuscation Handling

Detect and handle obfuscated JavaScript. Use deobfuscation tools where available. Manual analysis for complex obfuscation. Document obfuscation techniques observed. Extract information despite obfuscation.

### Step 5: SourceMap Recovery

Check for SourceMap files (.map). Use tools to reconstruct original source code. Analyze SourceMap content for insights. Document recovery success and limitations. Store recovered source code.

### Step 6: Dynamic Analysis

Execute JavaScript in controlled environments. Monitor network requests and API calls. Analyze DOM manipulation and event handlers. Track authentication and session management. Document runtime behavior.

### Step 7: Dependency Analysis

Analyze package.json and lock files. Check for known vulnerable dependencies. Identify outdated packages. Analyze dependency trees. Document security implications.

### Step 8: API Endpoint Harvesting

Extract all API endpoints from JavaScript. Categorize endpoints by type and functionality. Identify authentication requirements. Document parameter structures. Map endpoint relationships.

### Step 9: Secret and Credential Detection

Scan for hardcoded secrets and credentials. Verify discovered secrets where possible. Document secret types and locations. Assess security impact of findings. Report for remediation.

### Step 10: Result Aggregation and Reporting

Combine findings from all analysis stages. Deduplicate and prioritize results. Create comprehensive reports. Provide actionable recommendations. Archive results for future reference.

## Tool Arsenal

### LinkFinder — Endpoint Extraction

```bash
# Basic endpoint extraction
python3 linkfinder.py -i target.com -d -o cli

# Input from file
python3 linkfinder.py -i javascript.js -d -o cli

# Output to file
python3 linkfinder.py -i target.com -d -o file -f output.html

# Input from URL
python3 linkfinder.py -i https://target.com/app.js -d -o cli

# With JavaScript rendering
python3 linkfinder.py -i target.com -d --render -o cli

# Multiple inputs
python3 linkfinder.py -i urls.txt -d -o cli

# Input from stdin
cat urls.txt | python3 linkfinder.py -d -o cli

# Output formats
python3 linkfinder.py -i target.com -d -o cli  # CLI output
python3 linkfinder.py -i target.com -d -o file -f output.html  # HTML file
python3 linkfinder.py -i target.com -d -o file -f output.json  # JSON file

# Verbose output
python3 linkfinder.py -i target.com -d -v -o cli

# Custom regex patterns
python3 linkfinder.py -i target.com -d -r "api/v[0-9]+" -o cli

# Exclude patterns
python3 linkfinder.py -i target.com -d -e "\.(css|png|jpg)" -o cli

# Recursive analysis
python3 linkfinder.py -i target.com -d --recursive -o cli

# With authentication
python3 linkfinder.py -i target.com -d --cookie "session=abc123" -o cli

# Custom headers
python3 linkfinder.py -i target.com -d --header "Authorization: Bearer token" -o cli

# Proxy support
python3 linkfinder.py -i target.com -d --proxy http://127.0.0.1:8080 -o cli

# Timeout configuration
python3 linkfinder.py -i target.com -d --timeout 30 -o cli

# Rate limiting
python3 linkfinder.py -i target.com -d --rate-limit 10 -o cli

# Debug mode
python3 linkfinder.py -i target.com -d --debug -o cli

# Help
python3 linkfinder.py --help
```

Flags explained:
- `-i`: Input (URL, file, or stdin)
- `-d`: Use DOM (client-side) parsing
- `-o`: Output format (cli, file)
- `-f`: Output file path
- `-v`: Verbose output
- `-r`: Custom regex pattern
- `-e`: Exclude pattern
- `--recursive`: Recursive analysis
- `--cookie`: Authentication cookie
- `--header`: Custom headers
- `--proxy`: Proxy server
- `--timeout`: Request timeout
- `--rate-limit`: Rate limiting
- `--debug`: Debug mode
- `--help`: Show help

### SecretFinder — Secret Detection

```bash
# Basic secret detection
python3 SecretFinder.py -i javascript.js -o cli

# Input from URL
python3 SecretFinder.py -i https://target.com/app.js -o cli

# Output to file
python3 SecretFinder.py -i javascript.js -o file -f output.html

# With regex patterns
python3 SecretFinder.py -i javascript.js -r "api_key|secret|token" -o cli

# Exclude patterns
python3 SecretFinder.py -i javascript.js -e "example|test" -o cli

# Case insensitive
python3 SecretFinder.py -i javascript.js -c -o cli

# Verbose output
python3 SecretFinder.py -i javascript.js -v -o cli

# Multiple inputs
python3 SecretFinder.py -i urls.txt -o cli

# Input from stdin
cat urls.txt | python3 SecretFinder.py -o cli

# Custom wordlist
python3 SecretFinder.py -i javascript.js -w wordlist.txt -o cli

# With context
python3 SecretFinder.py -i javascript.js --context -o cli

# Output formats
python3 SecretFinder.py -i javascript.js -o cli  # CLI
python3 SecretFinder.py -i javascript.js -o file -f output.html  # HTML
python3 SecretFinder.py -i javascript.js -o file -f output.json  # JSON

# Debug mode
python3 SecretFinder.py -i javascript.js --debug -o cli

# Help
python3 SecretFinder.py --help
```

Flags explained:
- `-i`: Input (URL, file, or stdin)
- `-o`: Output format (cli, file)
- `-f`: Output file path
- `-r`: Custom regex pattern
- `-e`: Exclude pattern
- `-c`: Case insensitive
- `-v`: Verbose output
- `-w`: Custom wordlist
- `--context`: Show context around matches
- `--debug`: Debug mode
- `--help`: Show help

### JSFinder — JavaScript Analysis

```bash
# Basic JavaScript analysis
python3 JSFinder.py -u target.com -d

# With crawl depth
python3 JSFinder.py -u target.com -d --depth 3

# Output to file
python3 JSFinder.py -u target.com -d -o jsfinder_output.txt

# Include subdomains
python3 JSFinder.py -u target.com -d --subs

# Specific directory
python3 JSFinder.py -u target.com -d -d /api

# Verbose output
python3 JSFinder.py -u target.com -d -v

# With authentication
python3 JSFinder.py -u target.com -d --cookie "session=abc123"

# Custom headers
python3 JSFinder.py -u target.com -d --header "Authorization: Bearer token"

# Proxy support
python3 JSFinder.py -u target.com -d --proxy http://127.0.0.1:8080

# Timeout
python3 JSFinder.py -u target.com -d --timeout 30

# Rate limiting
python3 JSFinder.py -u target.com -d --rate-limit 10

# Multiple targets
python3 JSFinder.py -u urls.txt -d

# Input from stdin
cat urls.txt | python3 JSFinder.py -d

# Output formats
python3 JSFinder.py -u target.com -d -o cli
python3 JSFinder.py -u target.com -d -o file -f output.txt

# Debug mode
python3 JSFinder.py -u target.com -d --debug

# Help
python3 JSFinder.py --help
```

Flags explained:
- `-u`: Target URL
- `-d`: Use DOM parsing
- `-o`: Output file
- `--depth`: Crawl depth
- `--subs`: Include subdomains
- `-d`: Directory to scan
- `-v`: Verbose output
- `--cookie`: Authentication cookie
- `--header`: Custom headers
- `--proxy`: Proxy server
- `--timeout`: Request timeout
- `--rate-limit`: Rate limiting
- `--debug`: Debug mode
- `--help`: Show help

### JSLuice — JavaScript Parsing

```bash
# Basic JavaScript parsing
jsluice urls javascript.js

# With URLs extraction
jsluice urls javascript.js

# Parameters extraction
jsluice parameters javascript.js

# Secrets extraction
jsluice secrets javascript.js

# All extractions
jsluice all javascript.js

# From URL
curl -s https://target.com/app.js | jsluice urls

# Multiple files
cat urls.txt | xargs -I {} curl -s {} | jsluice urls

# Output formats
jsluice urls javascript.js -o json
jsluice urls javascript.js -o text

# With context
jsluice urls javascript.js --context

# Custom patterns
jsluice urls javascript.js -p "api/v[0-9]+"

# Exclude patterns
jsluice urls javascript.js -e "example.com"

# Verbose output
jsluice urls javascript.js -v

# Help
jsluice --help
```

Flags explained:
- `urls`: Extract URLs
- `parameters`: Extract parameters
- `secrets`: Extract secrets
- `all`: Extract everything
- `-o`: Output format (json, text)
- `--context`: Show context
- `-p`: Custom pattern
- `-e`: Exclude pattern
- `-v`: Verbose output
- `--help`: Show help

### linkextract — Bulk Endpoint Extraction

```bash
# Extract from URL
linkextract https://target.com

# Extract from file
linkextract -f javascript.js

# Multiple URLs
linkextract -l urls.txt

# Output to file
linkextract https://target.com -o endpoints.txt

# With regex
linkextract https://target.com -r "api/v[0-9]+"

# Exclude patterns
linkextract https://target.com -e "css,png,jpg"

# Verbose
linkextract https://target.com -v

# Help
linkextract --help
```

### getjs — JavaScript File Download

```bash
# Download JavaScript files
getjs --url target.com --output js_files.txt

# With depth
getjs --url target.com --depth 3 --output js_files.txt

# Verbose
getjs --url target.com --verbose

# Help
getjs --help
```

### SecretFinder.py — Advanced Secret Detection

```bash
# Scan for AWS keys
python3 SecretFinder.py -i javascript.js -r "AKIA[0-9A-Z]{16}" -o cli

# Scan for Google API keys
python3 SecretFinder.py -i javascript.js -r "AIza[0-9A-Za-z\-_]{35}" -o cli

# Scan for GitHub tokens
python3 SecretFinder.py -i javascript.js -r "ghp_[0-9a-zA-Z]{36}" -o cli

# Scan for Slack tokens
python3 SecretFinder.py -i javascript.js -r "xox[baprs]-[0-9a-zA-Z\-]{10,}" -o cli

# Scan for Stripe keys
python3 SecretFinder.py -i javascript.js -r "sk_live_[0-9a-zA-Z]{24,}" -o cli

# Scan for Heroku keys
python3 SecretFinder.py -i javascript.js -r "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}" -o cli

# Scan for private keys
python3 SecretFinder.py -i javascript.js -r "-----BEGIN (RSA |EC )?PRIVATE KEY-----" -o cli

# Scan for JWT tokens
python3 SecretFinder.py -i javascript.js -r "eyJ[0-9a-zA-Z\-_]*\.eyJ[0-9a-zA-Z\-_]*\.[0-9a-zA-Z\-_]*" -o cli

# Scan for database URLs
python3 SecretFinder.py -i javascript.js -r "(mysql|postgresql|mongodb)://[^\s]+" -o cli

# Scan for API endpoints with secrets
python3 SecretFinder.py -i javascript.js -r "api[_-]?key[_-]?[=:][^\s]+" -o cli

# Custom regex
python3 SecretFinder.py -i javascript.js -r "custom_pattern" -o cli

# Multiple patterns
python3 SecretFinder.py -i javascript.js -r "pattern1|pattern2|pattern3" -o cli

# With context
python3 SecretFinder.py -i javascript.js --context -o cli

# Output to HTML
python3 SecretFinder.py -i javascript.js -o file -f secrets.html

# Output to JSON
python3 SecretFinder.py -i javascript.js -o file -f secrets.json

# Scan multiple files
find . -name "*.js" -exec python3 SecretFinder.py -i {} -o cli \;

# Scan from URL list
cat urls.txt | while read url; do
    python3 SecretFinder.py -i "$url" -o cli
done

# Scan with authentication
python3 SecretFinder.py -i "https://target.com/app.js?token=abc123" -o cli

# Scan with proxy
python3 SecretFinder.py -i javascript.js --proxy http://127.0.0.1:8080 -o cli

# Scan with custom headers
python3 SecretFinder.py -i javascript.js --header "Authorization: Bearer token" -o cli

# Scan with cookies
python3 SecretFinder.py -i javascript.js --cookie "session=abc123" -o cli

# Scan with timeout
python3 SecretFinder.py -i javascript.js --timeout 30 -o cli

# Scan with rate limiting
python3 SecretFinder.py -i javascript.js --rate-limit 10 -o cli

# Scan with retries
python3 SecretFinder.py -i javascript.js --retries 3 -o cli

# Scan with user agent
python3 SecretFinder.py -i javascript.js --user-agent "Mozilla/5.0" -o cli

# Scan with debug
python3 SecretFinder.py -i javascript.js --debug -o cli

# Scan with verbose
python3 SecretFinder.py -i javascript.js -v -o cli

# Scan with help
python3 SecretFinder.py --help
```

### JSRecon — JavaScript Reconnaissance

```bash
# Basic reconnaissance
jsrecon https://target.com

# With output
jsrecon https://target.com -o jsrecon_output.txt

# Verbose
jsrecon https://target.com -v

# Help
jsrecon --help
```

### LinkFinder Custom Patterns

```bash
# API endpoints
python3 linkfinder.py -i javascript.js -r "api/|/v[0-9]+/|/graphql" -o cli

# File paths
python3 linkfinder.py -i javascript.js -r "\.js|\.css|\.html|\.json" -o cli

# Query parameters
python3 linkfinder.py -i javascript.js -r "\?[a-zA-Z0-9]+=" -o cli

# Fragments
python3 linkfinder.py -i javascript.js -r "#[a-zA-Z0-9]+" -o cli

# Email addresses
python3 linkfinder.py -i javascript.js -r "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" -o cli

# IP addresses
python3 linkfinder.py -i javascript.js -r "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" -o cli

# Domain names
python3 linkfinder.py -i javascript.js -r "[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" -o cli

# Phone numbers
python3 linkfinder.py -i javascript.js -r "\+?[0-9]{10,13}" -o cli

# Credit card numbers
python3 linkfinder.py -i javascript.js -r "[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}[- ]?[0-9]{4}" -o cli

# Social security numbers
python3 linkfinder.py -i javascript.js -r "[0-9]{3}-[0-9]{2}-[0-9]{4}" -o cli

# Custom patterns
python3 linkfinder.py -i javascript.js -r "your_custom_pattern" -o cli
```

### JavaScript Download Scripts

```bash
# Download all JavaScript from website
wget -r -A "*.js" https://target.com -P js_files/

# Download with depth
wget -r -l 3 -A "*.js" https://target.com -P js_files/

# Download from URL list
cat urls.txt | xargs -I {} wget -q {} -P js_files/

# Download with curl
curl -s https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s {} > js_files.txt

# Download with wget and filter
wget -q -O - https://target.com | grep -oP '(?<=src=")[^"]+\.js' | xargs -I {} wget -q {} -P js_files/

# Download JavaScript bundles
curl -s https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | while read url; do
    curl -s "$url" > "js_files/$(basename $url)"
done

# Download from multiple pages
cat pages.txt | while read page; do
    curl -s "$page" | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2
done | sort -u | while read url; do
    curl -s "$url" > "js_files/$(basename $url)"
done

# Download with authentication
curl -s -b "session=abc123" https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s -b "session=abc123" {} > js_files.txt

# Download with custom headers
curl -s -H "Authorization: Bearer token" https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s -H "Authorization: Bearer token" {} > js_files.txt

# Download with proxy
curl -s -x http://127.0.0.1:8080 https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s -x http://127.0.0.1:8080 {} > js_files.txt

# Download with user agent
curl -s -A "Mozilla/5.0" https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s -A "Mozilla/5.0" {} > js_files.txt

# Download with timeout
curl -s --connect-timeout 10 https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s --connect-timeout 10 {} > js_files.txt

# Download with retries
curl -s --retry 3 https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -s --retry 3 {} > js_files.txt

# Download with rate limiting
curl -s https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | while read url; do
    curl -s "$url" > "js_files/$(basename $url)"
    sleep 1
done

# Download with debug
curl -v https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -v {} > js_files.txt

# Download with verbose
curl -v https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} curl -v {} > js_files.txt

# Download with help
curl --help
```

### JavaScript Analysis Scripts

```bash
# Find all JavaScript files
find . -name "*.js" -type f > js_files.txt

# Find minified JavaScript
find . -name "*.min.js" -type f > minified_js.txt

# Find SourceMap files
find . -name "*.map" -type f > sourcemaps.txt

# Find package.json files
find . -name "package.json" -type f > package_files.txt

# Find configuration files
find . -name "config.js" -o -name "config.json" -o -name "config.ts" > config_files.txt

# Find environment files
find . -name ".env" -o -name ".env.*" -type f > env_files.txt

# Find TypeScript files
find . -name "*.ts" -type f > ts_files.txt

# Find React files
find . -name "*.jsx" -type f > react_files.txt

# Find Vue files
find . -name "*.vue" -type f > vue_files.txt

# Find Angular files
find . -name "*.angular.js" -type f > angular_files.txt

# Find all web files
find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -type f > web_files.txt

# Find all configuration files
find . -name "*.json" -o -name "*.yaml" -o -name "*.yml" -o -name "*.toml" -type f > config_files.txt

# Find all environment files
find . -name "*.env" -o -name "*.env.*" -o -name "*.config" -type f > env_files.txt

# Find all source files
find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" -o -name "*.vue" -o -name "*.json" -type f > source_files.txt

# Find all files
find . -type f > all_files.txt

# Find all directories
find . -type d > all_dirs.txt

# Find all symbolic links
find . -type l > all_links.txt

# Find all empty files
find . -type f -empty > empty_files.txt

# Find all empty directories
find . -type d -empty > empty_dirs.txt

# Find all files with specific extension
find . -name "*.js" -type f > js_only.txt

# Find all files with multiple extensions
find . -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" > ts_files.txt

# Find all files in specific directory
find ./src -name "*.js" -type f > src_js.txt

# Find all files with specific pattern
find . -name "*config*" -type f > config_pattern.txt

# Find all files with specific size
find . -name "*.js" -size +1M -type f > large_js.txt

# Find all files modified recently
find . -name "*.js" -mtime -7 -type f > recent_js.txt

# Find all files with specific permissions
find . -name "*.js" -perm 755 -type f > executable_js.txt

# Find all files with specific owner
find . -name "*.js" -user root -type f > root_js.txt

# Find all files with specific group
find . -name "*.js" -group root -type f > group_js.txt

# Find all files with specific inode
find . -name "*.js" -inum 12345 -type f > inode_js.txt

# Find all files with specific pattern in name
find . -name "*test*" -type f > test_files.txt

# Find all files with specific pattern in path
find . -path "*/test/*" -type f > test_path_files.txt

# Find all files with specific pattern in content
find . -name "*.js" -exec grep -l "api_key" {} \; > api_key_files.txt

# Find all files with specific pattern in content and name
find . -name "*.js" -exec grep -l "api_key" {} \; | grep -i "config" > config_api_files.txt

# Find all files with specific pattern in content and size
find . -name "*.js" -size +1M -exec grep -l "api_key" {} \; > large_api_files.txt

# Find all files with specific pattern in content and date
find . -name "*.js" -mtime -7 -exec grep -l "api_key" {} \; > recent_api_files.txt

# Find all files with specific pattern in content and permissions
find . -name "*.js" -perm 755 -exec grep -l "api_key" {} \; > executable_api_files.txt

# Find all files with specific pattern in content and owner
find . -name "*.js" -user root -exec grep -l "api_key" {} \; > root_api_files.txt

# Find all files with specific pattern in content and group
find . -name "*.js" -group root -exec grep -l "api_key" {} \; > group_api_files.txt

# Find all files with specific pattern in content and inode
find . -name "*.js" -inum 12345 -exec grep -l "api_key" {} \; > inode_api_files.txt

# Find all files with specific pattern in content and path
find . -name "*.js" -exec grep -l "api_key" {} \; | grep -i "config" > config_api_path_files.txt

# Find all files with specific pattern in content and name and size
find . -name "*.js" -size +1M -exec grep -l "api_key" {} \; | grep -i "config" > large_config_api_files.txt

# Find all files with specific pattern in content and name and date
find . -name "*.js" -mtime -7 -exec grep -l "api_key" {} \; | grep -i "config" > recent_config_api_files.txt

# Find all files with specific pattern in content and name and permissions
find . -name "*.js" -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > executable_config_api_files.txt

# Find all files with specific pattern in content and name and owner
find . -name "*.js" -user root -exec grep -l "api_key" {} \; | grep -i "config" > root_config_api_files.txt

# Find all files with specific pattern in content and name and group
find . -name "*.js" -group root -exec grep -l "api_key" {} \; | grep -i "config" > group_config_api_files.txt

# Find all files with specific pattern in content and name and inode
find . -name "*.js" -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > inode_config_api_files.txt

# Find all files with specific pattern in content and name and path
find . -name "*.js" -exec grep -l "api_key" {} \; | grep -i "config" > config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date
find . -name "*.js" -size +1M -mtime -7 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions
find . -name "*.js" -size +1M -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_config_api_files.txt

# Find all files with specific pattern in content and name and size and owner
find . -name "*.js" -size +1M -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_root_config_api_files.txt

# Find all files with specific pattern in content and name and size and group
find . -name "*.js" -size +1M -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and inode
find . -name "*.js" -size +1M -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and path
find . -name "*.js" -size +1M -exec grep -l "api_key" {} \; | grep -i "config" > large_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and permissions
find . -name "*.js" -mtime -7 -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_config_api_files.txt

# Find all files with specific pattern in content and name and date and owner
find . -name "*.js" -mtime -7 -user root -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_config_api_files.txt

# Find all files with specific pattern in content and name and date and group
find . -name "*.js" -mtime -7 -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_group_config_api_files.txt

# Find all files with specific pattern in content and name and date and inode
find . -name "*.js" -mtime -7 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and path
find . -name "*.js" -mtime -7 -exec grep -l "api_key" {} \; | grep -i "config" > recent_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and owner
find . -name "*.js" -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and group
find . -name "*.js" -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > executable_group_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and inode
find . -name "*.js" -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_inode_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and path
find . -name "*.js" -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > executable_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and owner and group
find . -name "*.js" -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > root_group_config_api_files.txt

# Find all files with specific pattern in content and name and owner and inode
find . -name "*.js" -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and owner and path
find . -name "*.js" -user root -exec grep -l "api_key" {} \; | grep -i "config" > root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and group and inode
find . -name "*.js" -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and group and path
find . -name "*.js" -group root -exec grep -l "api_key" {} \; | grep -i "config" > group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and inode and path
find . -name "*.js" -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date and permissions
find . -name "*.js" -size +1M -mtime -7 -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_executable_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and owner
find . -name "*.js" -size +1M -mtime -7 -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_root_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and group
find . -name "*.js" -size +1M -mtime -7 -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and inode
find . -name "*.js" -size +1M -mtime -7 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and path
find . -name "*.js" -size +1M -mtime -7 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and permissions and owner
find . -name "*.js" -size +1M -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_root_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and group
find . -name "*.js" -size +1M -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and inode
find . -name "*.js" -size +1M -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and path
find . -name "*.js" -size +1M -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and owner and group
find . -name "*.js" -size +1M -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and owner and inode
find . -name "*.js" -size +1M -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and owner and path
find . -name "*.js" -size +1M -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and group and inode
find . -name "*.js" -size +1M -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and group and path
find . -name "*.js" -size +1M -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and inode and path
find . -name "*.js" -size +1M -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and permissions and owner
find . -name "*.js" -mtime -7 -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_root_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and group
find . -name "*.js" -mtime -7 -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_group_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and inode
find . -name "*.js" -mtime -7 -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and path
find . -name "*.js" -mtime -7 -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and owner and group
find . -name "*.js" -mtime -7 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and date and owner and inode
find . -name "*.js" -mtime -7 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and owner and path
find . -name "*.js" -mtime -7 -user root -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and group and inode
find . -name "*.js" -mtime -7 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and group and path
find . -name "*.js" -mtime -7 -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and inode and path
find . -name "*.js" -mtime -7 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and owner and group
find . -name "*.js" -perm 755 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and owner and inode
find . -name "*.js" -perm 755 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and owner and path
find . -name "*.js" -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and group and inode
find . -name "*.js" -perm 755 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and group and path
find . -name "*.js" -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > executable_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and inode and path
find . -name "*.js" -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and owner and group and inode
find . -name "*.js" -user root -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > root_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and owner and group and path
find . -name "*.js" -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > root_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and owner and inode and path
find . -name "*.js" -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > root_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and group and inode and path
find . -name "*.js" -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > group_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date and permissions and owner
find . -name "*.js" -size +1M -mtime -7 -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_executable_root_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and permissions and group
find . -name "*.js" -size +1M -mtime -7 -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_executable_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and permissions and inode
find . -name "*.js" -size +1M -mtime -7 -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_executable_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and permissions and path
find . -name "*.js" -size +1M -mtime -7 -perm 755 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_executable_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date and owner and group
find . -name "*.js" -size +1M -mtime -7 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and owner and inode
find . -name "*.js" -size +1M -mtime -7 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and owner and path
find . -name "*.js" -size +1M -mtime -7 -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date and group and inode
find . -name "*.js" -size +1M -mtime -7 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and date and group and path
find . -name "*.js" -size +1M -mtime -7 -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and date and inode and path
find . -name "*.js" -size +1M -mtime -7 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_recent_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and permissions and owner and group
find . -name "*.js" -size +1M -perm 755 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and owner and inode
find . -name "*.js" -size +1M -perm 755 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and owner and path
find . -name "*.js" -size +1M -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and permissions and group and inode
find . -name "*.js" -size +1M -perm 755 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and permissions and group and path
find . -name "*.js" -size +1M -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and permissions and inode and path
find . -name "*.js" -size +1M -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_executable_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and owner and group and inode
find . -name "*.js" -size +1M -user root -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_root_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and size and owner and group and path
find . -name "*.js" -size +1M -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > large_root_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and owner and inode and path
find . -name "*.js" -size +1M -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_root_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and size and group and inode and path
find . -name "*.js" -size +1M -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > large_group_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and permissions and owner and group
find . -name "*.js" -mtime -7 -perm 755 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_root_group_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and owner and inode
find . -name "*.js" -mtime -7 -perm 755 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_root_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and owner and path
find . -name "*.js" -mtime -7 -perm 755 -user root -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_root_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and permissions and group and inode
find . -name "*.js" -mtime -7 -perm 755 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and permissions and group and path
find . -name "*.js" -mtime -7 -perm 755 -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and permissions and inode and path
find . -name "*.js" -mtime -7 -perm 755 -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_executable_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and owner and group and inode
find . -name "*.js" -mtime -7 -user root -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and date and owner and group and path
find . -name "*.js" -mtime -7 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and owner and inode and path
find . -name "*.js" -mtime -7 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_root_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and date and group and inode and path
find . -name "*.js" -mtime -7 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > recent_group_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and owner and group and inode
find . -name "*.js" -perm 755 -user root -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_group_inode_config_api_files.txt

# Find all files with specific pattern in content and name and permissions and owner and group and path
find . -name "*.js" -perm 755 -user root -group root -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_group_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and owner and inode and path
find . -name "*.js" -perm 755 -user root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_root_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and permissions and group and inode and path
find . -name "*.js" -perm 755 -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > executable_group_inode_config_api_name_path_files.txt

# Find all files with specific pattern in content and name and owner and group and inode and path
find . -name "*.js" -user root -group root -inum 12345 -exec grep -l "api_key" {} \; | grep -i "config" > root_group_inode_config_api_name_path_files.txt
```

## Case Studies

### Case Study 1: Modern JavaScript Framework Application

**Target:** React-based single-page application
**Objective:** Extract all API endpoints and secrets

The application used React with Redux for state management, with multiple API endpoints and third-party integrations.

**Approach:**
1. Downloaded all JavaScript bundles using wget
2. Used LinkFinder to extract API endpoints
3. Deployed SecretFinder for secret detection
4. Analyzed Redux store for API patterns
5. Recovered SourceMaps for original source code

**Results:**
- 234 API endpoints discovered
- 12 hardcoded API keys found
- 56 internal endpoints identified
- 89 GraphQL queries extracted
- 23 environment-specific configurations

**Key Findings:**
- AWS access keys hardcoded in configuration
- GraphQL endpoints with introspection enabled
- Internal API endpoints exposed to frontend
- Development environment variables in production
- Third-party service tokens with excessive permissions

**Lessons Learned:**
- Modern frameworks often expose internal APIs
- SourceMaps can reveal entire application structure
- Environment variables may leak into production builds
- Third-party integrations create secret exposure risks

### Case Study 2: Enterprise Web Application

**Target:** Large enterprise application with multiple microservices
**Objective:** Comprehensive JavaScript analysis across all microservices

The enterprise had multiple microservices, each with their own JavaScript frontends. Traditional analysis was insufficient.

**Approach:**
1. Mapped all microservice frontends
2. Used JSFinder for bulk JavaScript discovery
3. Deployed custom scripts for pattern matching
4. Analyzed shared components and libraries
5. Implemented automated secret detection

**Results:**
- 1,234 JavaScript files analyzed
- 567 API endpoints discovered
- 89 secrets and credentials found
- 234 internal routes identified
- 56 configuration files exposed

**Key Findings:**
- Shared authentication tokens across microservices
- Internal service discovery endpoints exposed
- Database connection strings in configuration
- API keys for third-party services hardcoded
- Development credentials in production code

**Lessons Learned:**
- Microservices create complex JavaScript landscapes
- Shared components can leak secrets across services
- Configuration management is critical for security
- Automated analysis is essential for large applications

### Case Study 3: Mobile Web Application

**Target:** Progressive Web Application (PWA)
**Objective:** Analyze JavaScript for security vulnerabilities

The PWA had complex JavaScript with service workers, IndexedDB, and offline capabilities.

**Approach:**
1. Analyzed service worker scripts
2. Used SecretFinder for credential detection
3. Analyzed IndexedDB schemas
4. Tested offline functionality
5. Examined push notification implementations

**Results:**
- 234 JavaScript files analyzed
- 56 API endpoints discovered
- 12 secrets found in service workers
- 23 IndexedDB tables exposed
- 8 push notification endpoints identified

**Key Findings:**
- Service workers caching sensitive data
- IndexedDB storing unencrypted credentials
- Push notification tokens exposed
- Offline functionality bypassing security controls
- Background sync sending data without authorization

**Lessons Learned:**
- PWAs have unique security considerations
- Service workers can cache sensitive information
- Offline functionality may bypass security controls
- Client-side storage requires encryption

## Bypass Techniques

### Obfuscation Bypass

When JavaScript is obfuscated, use deobfuscation tools like de4js or JSNice. Analyze runtime behavior using browser developer tools. Extract strings using regex patterns. Use dynamic analysis to understand obfuscated code.

### Minification Bypass

Use SourceMap recovery to reconstruct original code. Analyze minified code using AST parsers. Extract patterns using regex. Use dynamic analysis to understand minified code.

### Bundling Bypass

Analyze bundle manifests for chunk information. Use dynamic imports to identify lazy-loaded modules. Analyze webpack configuration files. Extract module information from bundle metadata.

### Content Security Policy Bypass

Analyze CSP headers for weaknesses. Test for CSP bypass techniques. Use base tag hijacking. Exploit unsafe-inline and unsafe-eval directives.

### Cache Bypass

Use cache-busting techniques. Analyze cache headers. Test for stale content. Exploit cache poisoning vulnerabilities.

### CORS Bypass

Test for CORS misconfigurations. Analyze CORS headers. Test for null origin bypass. Exploit wildcard with credentials.

## Advanced Techniques

### Dynamic Analysis with Puppeteer

Use Puppeteer for automated JavaScript execution. Monitor network requests and API calls. Analyze DOM manipulation. Track authentication flows. Document runtime behavior.

### AST-Based Analysis

Use Abstract Syntax Tree parsing for code analysis. Identify vulnerability patterns in code structure. Analyze control flow and data flow. Extract semantic information from code.

### Machine Learning for Pattern Recognition

Train models to identify vulnerability patterns. Use clustering to group similar code. Implement anomaly detection for zero-day vulnerabilities. Automate code review using ML.

### API Behavior Analysis

Monitor API request and response patterns. Analyze authentication mechanisms. Test for broken access controls. Document API behavior.

### SourceMap Recovery Automation

Automate SourceMap discovery and recovery. Reconstruct original source code. Analyze source code for vulnerabilities. Document recovery success rates.

### Secret Detection Enhancement

Develop custom regex patterns for secret detection. Implement contextual analysis for secret validation. Use machine learning for false positive reduction. Automate secret rotation recommendations.

## Detection Indicators

### Network-Level Indicators

High volume of JavaScript file downloads indicates analysis. Multiple requests to the same JavaScript files suggest scanning. Requests for SourceMap files reveal analysis activity. Unusual User-Agent strings indicate automated tools.

### Log Analysis Indicators

Web server logs show JavaScript file access patterns. CDN logs reveal download frequency. Application logs record analysis requests. Proxy logs capture analysis traffic.

### Behavioral Indicators

Sequential JavaScript file access indicates automated tools. Random access patterns suggest analysis activity. Consistent timing reveals scripted behavior. Large bursts of requests indicate bulk analysis.

### Source Indicators

Known analysis tool user agents appear in logs. IP addresses from known analysis infrastructure are flagged. Request patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

JavaScript analysis reveals application structure and functionality. Endpoint discovery enables further testing. Secret detection prevents unauthorized access. Vulnerability identification guides remediation.

### Indirect Impact

Analysis enables comprehensive security assessment. Findings guide further reconnaissance. Regular analysis reduces attack surface. Automated analysis enables continuous security assessment.

### Risk Quantification

Exposed secrets pose critical risk. Hardcoded credentials enable unauthorized access. Internal endpoints exposed to internet create high risk. Vulnerable dependencies pose medium to high risk.

### Business Impact

Comprehensive analysis improves security posture. Findings enable risk-based decision making. Regular analysis supports compliance requirements. Automated analysis reduces manual effort.

## Common Pitfalls

### Tool Configuration Errors

Incorrect input formats cause analysis failures. Missing dependencies prevent tool execution. Wrong output formats prevent integration. Inadequate memory causes analysis failures.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering false positives wastes time. Ignoring context creates inaccurate assessments. Missing output formats prevent integration.

### Scope Management Issues

Analyzing out-of-scope targets violates engagement rules. Not verifying authorization creates legal risks. Ignoring rate limits causes blocking. Failing to document scope complicates reporting.

### Resource Management Problems

Running too many analyses simultaneously causes resource exhaustion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Aggressive analysis without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### Reconnaissance Pipeline Integration

Integrate JavaScript analysis with reconnaissance workflows. Feed findings into vulnerability scanning. Correlate with other reconnaissance data. Automate analysis in scanning pipelines.

### CI/CD Pipeline Integration

Automate JavaScript analysis in continuous integration pipelines. Trigger analyses on code changes. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed analysis results into vulnerability scanners. Prioritize scanning based on findings. Correlate analysis data with vulnerabilities. Update scanner targets automatically.

### Monitoring System Integration

Integrate with JavaScript monitoring systems. Set up alerts for new secrets. Monitor for JavaScript changes. Track analysis trends over time.

### Ticketing System Integration

Automatically create tickets for new findings. Track remediation progress. Generate reports for security teams. Escalate critical findings.

## Reporting Templates

### Executive Summary

```
JavaScript Analysis Report
Date: [DATE]
Target: [SCOPE]
Tools Used: [LIST]
Total Files Analyzed: [NUMBER]
Endpoints Discovered: [NUMBER]
Secrets Found: [NUMBER]
Vulnerabilities Identified: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Analysis Methodology:
1. File Discovery: [METHOD]
2. Static Analysis: [TOOLS]
3. Dynamic Analysis: [APPROACH]
4. Secret Detection: [METHOD]

Results Breakdown:
- Total Files: [NUMBER]
- Endpoints: [NUMBER]
- Secrets: [NUMBER]
- Vulnerabilities: [NUMBER]
- Dependencies: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
File,Type,Endpoint,Secret,Vulnerability,Severity
app.js,API,https://target.com/api/users,N/A,SQL Injection,CRITICAL
config.js,Config,N/A,AWS Key,N/A,CRITICAL
auth.js,Auth,https://target.com/login,N/A,XSS,HIGH
```

## Practice Labs

### Lab 1: Basic JavaScript Analysis

**Setup:** Create a web application with JavaScript
**Exercise:** Use LinkFinder to extract endpoints
**Goal:** Discover all API endpoints

### Lab 2: Secret Detection

**Setup:** Application with hardcoded secrets
**Exercise:** Use SecretFinder to detect secrets
**Goal:** Find all hardcoded credentials

### Lab 3: Obfuscated Code Analysis

**Setup:** Obfuscated JavaScript application
**Exercise:** Analyze obfuscated code using deobfuscation tools
**Goal:** Extract information despite obfuscation

### Lab 4: Dynamic Analysis

**Setup:** JavaScript application with complex functionality
**Exercise:** Use Puppeteer for dynamic analysis
**Goal:** Document runtime behavior and API calls

## Ethics

JavaScript analysis must be performed within legal and ethical boundaries. Always obtain written authorization before analyzing any application. Respect rate limits and do not cause denial of service. Do not analyze applications outside the authorized scope. Use appropriate analysis techniques for the environment. Store analysis results securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not analyze personal applications without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Download JavaScript files
wget -r -A "*.js" https://target.com -P js_files/

# Extract endpoints
python3 linkfinder.py -i javascript.js -d -o cli

# Detect secrets
python3 SecretFinder.py -i javascript.js -o cli

# Analyze with JSLuice
cat javascript.js | jsluice urls

# Find all JavaScript files
find . -name "*.js" -type f > js_files.txt

# Find SourceMap files
find . -name "*.map" -type f > sourcemaps.txt

# Bulk endpoint extraction
cat js_files.txt | xargs -I {} python3 linkfinder.py -i {} -d -o cli

# Bulk secret detection
cat js_files.txt | xargs -I {} python3 SecretFinder.py -i {} -o cli

# Download and analyze
curl -s https://target.com | grep -oP 'src="[^"]+\.js"' | cut -d'"' -f2 | xargs -I {} python3 linkfinder.py -i {} -d -o cli

# Dynamic analysis
node -e "const puppeteer = require('puppeteer'); (async () => { const browser = await puppeteer.launch(); const page = await browser.newPage(); await page.goto('https://target.com'); const urls = await page.evaluate(() => { return performance.getEntriesByType('resource').map(r => r.name); }); console.log(urls); await browser.close(); })()"
```

### Tool Comparison

| Tool | Type | Speed | Coverage | Ease |
|------|------|-------|----------|------|
| LinkFinder | Endpoint | Fast | High | High |
| SecretFinder | Secret | Fast | High | High |
| JSFinder | Analysis | Medium | High | Medium |
| JSLuice | Parsing | Fast | Medium | Medium |
| Puppeteer | Dynamic | Slow | Very High | Low |

### Common Secrets

```
AWS:
- AKIA[0-9A-Z]{16}
- aws_access_key_id
- aws_secret_access_key

Google:
- AIza[0-9A-Za-z\-_]{35}
- google_api_key

GitHub:
- ghp_[0-9a-zA-Z]{36}
- github_token

Slack:
- xox[baprs]-[0-9a-zA-Z\-]{10,}
- slack_token

Stripe:
- sk_live_[0-9a-zA-Z]{24,}
- pk_live_[0-9a-zA-Z]{24,}

Private Keys:
- -----BEGIN (RSA |EC )?PRIVATE KEY-----

JWT:
- eyJ[0-9a-zA-Z\-_]*\.eyJ[0-9a-zA-Z\-_]*\.[0-9a-zA-Z\-_]*
```

### Endpoint Patterns

```
REST API:
- /api/v[0-9]+/
- /api/
- /rest/
- /graphql

Authentication:
- /login
- /logout
- /register
- /password
- /token

Admin:
- /admin
- /dashboard
- /manage
- /console

File Upload:
- /upload
- /file
- /import
- /export

Search:
- /search
- /query
- /find
- /lookup
```

### Obfuscation Types

```
Variable Renaming:
- a, b, c
- _0x1234
- __proto__

String Encoding:
- Hex encoding
- Base64 encoding
- Unicode escaping

Control Flow:
- Dead code injection
- Code reordering
- Function inlining

Other:
- Eval usage
- Dynamic loading
- Anti-debugging
```

### SourceMap Locations

```
Standard Locations:
- /app.js.map
- /static/js/*.map
- /dist/*.map
- /build/*.map

Framework Specific:
- React: /static/js/*.map
- Vue: /js/*.map
- Angular: /main.*.map
- Next.js: /_next/static/*.map
```

### Analysis Workflow

```
1. Discovery:
   - Find all JavaScript files
   - Identify SourceMaps
   - Download files

2. Static Analysis:
   - Extract endpoints
   - Detect secrets
   - Analyze dependencies

3. Dynamic Analysis:
   - Execute in browser
   - Monitor network
   - Track behavior

4. Reporting:
   - Aggregate findings
   - Prioritize issues
   - Create report
```

### Debugging Commands

```bash
# Verbose output
python3 linkfinder.py -i javascript.js -v -o cli

# Debug mode
python3 linkfinder.py -i javascript.js --debug -o cli

# Test connectivity
curl -v https://target.com/app.js

# Check file content
head -n 20 javascript.js

# Check file size
ls -lh javascript.js

# Check file type
file javascript.js

# Check for obfuscation
grep -o "eval\|Function\|atob\|btoa" javascript.js | wc -l

# Check for SourceMap
grep -o "sourceMappingURL" javascript.js | wc -l

# Check for secrets
grep -iE "(api_key|secret|token|password)" javascript.js | head -n 10

# Check for endpoints
grep -oE "(https?://[^\"]+|/api/[^\"]+)" javascript.js | head -n 10
```
