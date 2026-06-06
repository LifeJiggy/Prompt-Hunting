# Pastebin and Leak Searching

## Expert Role

You are a paste site intelligence specialist focused on discovering leaked credentials, internal information, and sensitive data exposed on paste sites. You understand that developers, sysadmins, and attackers frequently use paste sites to share code snippets, logs, and other data — often inadvertently exposing sensitive information. You approach paste site intelligence with the understanding that paste sites are a rich source of reconnaissance data, containing everything from leaked API keys to internal network configurations. You combine automated search techniques with manual analysis to build a comprehensive picture of what information about your target has been exposed.

## Core Concepts

### Paste Site Landscape

Paste sites are web-based services that allow users to share text content. They vary in privacy, retention, and searchability:

| Service | URL | Search | Retention | API |
|---------|-----|--------|-----------|-----|
| Pastebin | pastebin.com | Yes | Varies | Yes (Pro) |
| Ghostbin | ghostbin.co | Limited | 30 days | No |
| Hastebin | hastebin.com | No | Various | Yes |
| dpaste | dpaste.org | No | Various | Yes |
| Rentry | rentry.co | No | Various | No |
| Gist (GitHub) | gist.github.com | Yes | Permanent | Yes |
| GitLab Snippets | gitlab.com/explore/snippets | Yes | Permanent | Yes |
| JSFiddle | jsfiddle.net | Yes | Various | No |
| CodePen | codepen.io | Yes | Various | No |
| Paste.ee | paste.ee | Limited | Various | Yes |

### Types of Sensitive Data in Pastes

1. **Credentials**: Passwords, API keys, tokens, certificates
2. **Source Code**: Application code, configuration files, scripts
3. **Network Information**: IP addresses, hostnames, network diagrams
4. **Database Data**: Connection strings, query results, schema definitions
5. **Internal Documentation**: Wikis, README files, internal guides
6. **Logs**: Application logs, error messages, debug output
7. **Personal Information**: Email addresses, phone numbers, API keys
8. **Infrastructure Details**: Server configurations, deployment scripts, cloud credentials

### Why Pastes Get Created

Understanding motivation helps predict where to look:
- **Code Sharing**: Developers sharing snippets for help or collaboration
- **Debugging**: Sharing error logs for troubleshooting
- **Accidental Exposure**: Pasting sensitive data without thinking
- **Malicious Distribution**: Attackers sharing leaked data
- **Data Breach**: Stolen data published for public access
- **Temporary Storage**: Using paste sites as clipboard extensions
- **Collaboration**: Teams sharing information quickly

### Search Strategies

| Strategy | Description | Effectiveness |
|----------|-------------|---------------|
| Direct Search | Search target name directly | Medium |
| Domain Search | Search target domain | High |
| Email Search | Search target employee emails | High |
| API Key Search | Search for leaked API keys | High |
| Code Search | Search for target's code patterns | Medium |
| Regex Search | Use patterns for sensitive data | High |
| Historical Search | Search old/expired pastes | Medium |

## Prerequisites

Before beginning paste site intelligence, ensure you have:
- Understanding of common credential formats (API keys, tokens, passwords)
- Access to tools: curl, grep, jq
- Knowledge of regular expressions for pattern matching
- Familiarity with the target's domain names and employee emails
- Understanding of common programming languages and their syntax
- Access to search engines and paste search APIs
- Knowledge of common configuration file formats
- Familiarity with cloud service credential formats (AWS, Azure, GCP)

## Methodology

### Phase 1: Direct Pastebin Search

**Basic Pastebin Search**

```bash
# Search Pastebin for target domain
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for specific employee emails
curl -s "https://www.google.com/search?q=site:pastebin.com+employee@target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for company name
curl -s "https://www.google.com/search?q=site:pastebin.com+%22target+company%22" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

**Pastebin API Search (Pro)**

```bash
# If you have Pastebin Pro API key
PASTEBIN_API_KEY="your_api_key"

# Search for pastes
curl -s -X POST "https://pastebin.com/api/api_post.php" \
  -d "api_dev_key=$PASTEBIN_API_KEY" \
  -d "api_option=list" \
  -d "api_results_limit=100"
```

### Phase 2: Google Dorking for Paste Sites

**Advanced Google Dorks**

```bash
# Domain-specific searches
for site in pastebin.com ghostbin.co hastebin.com dpaste.org rentry.co; do
  echo "=== Searching $site ==="
  curl -s "https://www.google.com/search?q=site:${site}+target.com" | grep -oP "https://${site}/[a-zA-Z0-9]+" | sort -u
done

# Credential-specific searches
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+password" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+api_key" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+secret" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Code-specific searches
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+config" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+database" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

**Bing Dorks**

```bash
# Bing may have different indexing
curl -s "https://www.bing.com/search?q=site:pastebin.com+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# DuckDuckGo
curl -s "https://html.duckduckgo.com/html/?q=site:pastebin.com+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

### Phase 3: Paste Site Enumeration

**Identify All Paste Sites**

```bash
# Use a comprehensive list of paste sites
PASTE_SITES=(
  "pastebin.com"
  "ghostbin.co"
  "hastebin.com"
  "dpaste.org"
  "rentry.co"
  "paste.ee"
  "paste.bin.com"
  "pastebin.fr"
  "pastebin.pl"
  "pastebin.fi"
  "paste.rs"
  "paste.gg"
  "paste.lol"
  "paste.nosuccess.com"
  "ix.io"
  "paste.ubuntu.com"
  "paste.debian.org"
  "paste.fedoraproject.org"
)

# Search each paste site
for site in "${PASTE_SITES[@]}"; do
  echo "=== Searching $site ==="
  curl -s "https://www.google.com/search?q=site:${site}+target.com" | grep -oP "https?://${site}/[a-zA-Z0-9]+" | sort -u
done
```

**GitHub Gist Search**

```bash
# Search GitHub Gists
curl -s "https://api.github.com/search/gists?q=target.com" | jq '.items[] | {url: .html_url, description: .description, created: .created_at}'

# Search for specific patterns in Gists
curl -s "https://api.github.com/search/code?q=target.com+filename:config" | jq '.items[] | {url: .html_url, name: .name}'

# Search GitLab snippets
curl -s "https://gitlab.com/api/v4/snippets?search=target.com" | jq '.[] | {url: .web_url, title: .title}'
```

### Phase 4: Leaked Credential Discovery

**Search for API Keys**

```bash
# Search for AWS keys
curl -s "https://www.google.com/search?q=site:pastebin.com+AKIA" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for GitHub tokens
curl -s "https://www.google.com/search?q=site:pastebin.com+ghp_" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for Stripe keys
curl -s "https://www.google.com/search?q=site:pastebin.com+sk_live_" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for Slack tokens
curl -s "https://www.google.com/search?q=site:pastebin.com+xoxb-" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for Google API keys
curl -s "https://www.google.com/search?q=site:pastebin.com+AIza" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

**Search for Passwords**

```bash
# Search for passwords associated with target
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+password" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for database passwords
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+db_pass" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for SSH keys
curl -s "https://www.google.com/search?q=site:pastebin.com+BEGIN+RSA+PRIVATE+KEY+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

### Phase 5: Internal Information in Pastes

**Search for Source Code**

```bash
# Search for target's code patterns
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+import" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for configuration files
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+config" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for API endpoints
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+api" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

**Search for Network Information**

```bash
# Search for IP addresses
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+192.168" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for hostnames
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+hostname" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Search for network configurations
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+subnet" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
```

### Phase 6: Paste Monitoring

**Set Up Monitoring for New Pastes**

```bash
#!/bin/bash
# paste_monitor.sh - Monitor for new paste mentions

TARGET="target.com"
LAST_COUNT=0
CHECK_INTERVAL=3600  # 1 hour

while true; do
  CURRENT_COUNT=$(curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u | wc -l)
  
  if [ "$CURRENT_COUNT" -gt "$LAST_COUNT" ]; then
    echo "[+] New paste(s) detected!"
    curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > new_pastes.txt
    cat new_pastes.txt
    # Send notification
    # mail -s "New paste detected for $TARGET" admin@target.com < new_pastes.txt
  fi
  
  LAST_COUNT=$CURRENT_COUNT
  sleep $CHECK_INTERVAL
done
```

### Phase 7: Analyzing Discovered Pastes

**Download and Analyze Pastes**

```bash
# Download a paste
PASTE_URL="https://pastebin.com/abcdef123"
curl -s "$PASTE_URL" | grep -oP '<textarea[^>]*id="paste_code"[^>]*>(.*?)</textarea>' | sed 's/<[^>]*>//g' > paste_content.txt

# Or use raw URL
curl -s "https://pastebin.com/raw/abcdef123" > paste_content.txt

# Analyze for sensitive patterns
grep -oiP '(password|passwd|pwd|secret|api.?key|token|credential|auth)["\s:=]+["\x27][^"\x27]{4,}["\x27]' paste_content.txt

# Look for specific credential formats
grep -oP 'AKIA[0-9A-Z]{16}' paste_content.txt  # AWS Access Key
grep -oP 'sk_live_[a-zA-Z0-9]+' paste_content.txt  # Stripe Secret Key
grep -oP 'ghp_[a-zA-Z0-9]{36}' paste_content.txt  # GitHub Token
grep -oP 'xox[bpsa]-[a-zA-Z0-9-]+' paste_content.txt  # Slack Token
grep -oP 'AIza[0-9A-Za-z_-]{35}' paste_content.txt  # Google API Key
```

### Phase 8: Complete Paste Intelligence Workflow

```bash
#!/bin/bash
# paste_recon.sh - Complete paste site reconnaissance

TARGET=$1
TARGET_DOMAIN="${TARGET}.com"
EMPLOYEE_EMAILS="employees.txt"  # List of employee emails
OUTPUT_DIR="paste_recon_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting paste site reconnaissance for $TARGET"

# Step 1: Search for domain mentions
echo "[+] Searching for domain mentions..."
for site in pastebin.com ghostbin.co hastebin.com dpaste.org rentry.co; do
  echo "  Searching $site..."
  curl -s "https://www.google.com/search?q=site:${site}+${TARGET_DOMAIN}" | grep -oP "https?://${site}/[a-zA-Z0-9]+" | sort -u >> "$OUTPUT_DIR/domain_mentions.txt"
done

# Step 2: Search for employee email mentions
echo "[+] Searching for employee email mentions..."
if [ -f "$EMPLOYEE_EMAILS" ]; then
  while read email; do
    curl -s "https://www.google.com/search?q=site:pastebin.com+${email}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u >> "$OUTPUT_DIR/email_mentions.txt"
  done < "$EMPLOYEE_EMAILS"
fi

# Step 3: Search for credential patterns
echo "[+] Searching for credential patterns..."
curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET_DOMAIN}+password" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > "$OUTPUT_DIR/password_mentions.txt"

curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET_DOMAIN}+api_key" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > "$OUTPUT_DIR/api_key_mentions.txt"

curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET_DOMAIN}+secret" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > "$OUTPUT_DIR/secret_mentions.txt"

# Step 4: Search for code patterns
echo "[+] Searching for code patterns..."
curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET_DOMAIN}+config" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > "$OUTPUT_DIR/config_mentions.txt"

curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET_DOMAIN}+database" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u > "$OUTPUT_DIR/database_mentions.txt"

# Step 5: Analyze discovered pastes
echo "[+] Analyzing discovered pastes..."
while read paste_url; do
  paste_id=$(echo "$paste_url" | grep -oP '[a-zA-Z0-9]+$')
  content=$(curl -s "https://pastebin.com/raw/${paste_id}")
  
  # Check for credentials
  if echo "$content" | grep -qP '(password|api_key|secret|token)'; then
    echo "[!] Potential credentials found in $paste_url"
    echo "$content" > "$OUTPUT_DIR/credentials_$(echo $paste_id | head -c 10).txt"
  fi
  
  # Check for source code
  if echo "$content" | grep -qP '(import|require|function|class)'; then
    echo "[+] Source code found in $paste_url"
    echo "$content" > "$OUTPUT_DIR/code_$(echo $paste_id | head -c 10).txt"
  fi
done < "$OUTPUT_DIR/domain_mentions.txt"

# Step 6: Generate report
echo "[+] Generating report..."
echo "=== Paste Site Intelligence Report ===" > "$OUTPUT_DIR/report.txt"
echo "Target: $TARGET" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "Domain mentions: $(wc -l < "$OUTPUT_DIR/domain_mentions.txt")" >> "$OUTPUT_DIR/report.txt"
echo "Email mentions: $(wc -l < "$OUTPUT_DIR/email_mentions.txt" 2>/dev/null || echo 0)" >> "$OUTPUT_DIR/report.txt"
echo "Password mentions: $(wc -l < "$OUTPUT_DIR/password_mentions.txt")" >> "$OUTPUT_DIR/report.txt"
echo "API key mentions: $(wc -l < "$OUTPUT_DIR/api_key_mentions.txt")" >> "$OUTPUT_DIR/report.txt"
echo "Secret mentions: $(wc -l < "$OUTPUT_DIR/secret_mentions.txt")" >> "$OUTPUT_DIR/report.txt"

echo "[*] Reconnaissance complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### Google Search Tools

**gh (GitHub CLI) for Gist Search**
```bash
# Search public gists
gh api search/gists -X GET -f q="target.com" --jq '.items[] | {url: .html_url, description: .description}'
```

**Search Engine APIs**
```bash
# Google Custom Search API
API_KEY="your_google_api_key"
CX="your_search_engine_id"
curl -s "https://www.googleapis.com/customsearch/v1?key=$API_KEY&cx=$CX&q=site:pastebin.com+target.com"
```

### Paste Fetching Tools

**Custom Paste Fetcher**
```python
#!/usr/bin/env python3
import requests
import re
import json

class PasteFetcher:
    def __init__(self, target):
        self.target = target
        self.paste_sites = [
            'pastebin.com',
            'ghostbin.co',
            'hastebin.com',
            'dpaste.org',
            'paste.ee'
        ]
        
    def search_google(self, query):
        """Search Google for paste site mentions."""
        url = f"https://www.google.com/search?q={query}"
        headers = {'User-Agent': 'Mozilla/5.0'}
        response = requests.get(url, headers=headers)
        # Extract URLs from response
        urls = re.findall(r'https?://(?:pastebin|ghostbin|hastebin|dpaste|paste\.ee)\.com/[a-zA-Z0-9]+', response.text)
        return list(set(urls))
    
    def fetch_paste(self, url):
        """Fetch paste content."""
        if 'pastebin.com' in url:
            paste_id = url.split('/')[-1]
            raw_url = f"https://pastebin.com/raw/{paste_id}"
        else:
            raw_url = url
        
        response = requests.get(raw_url)
        return response.text
    
    def find_credentials(self, content):
        """Find potential credentials in content."""
        patterns = [
            r'AKIA[0-9A-Z]{16}',  # AWS
            r'sk_live_[a-zA-Z0-9]+',  # Stripe
            r'ghp_[a-zA-Z0-9]{36}',  # GitHub
            r'xox[bpsa]-[a-zA-Z0-9-]+',  # Slack
            r'AIza[0-9A-Za-z_-]{35}',  # Google
            r'password["\s:=]+["\'][^"\']{4,}["\']',  # Generic password
        ]
        
        findings = []
        for pattern in patterns:
            matches = re.findall(pattern, content)
            if matches:
                findings.extend(matches)
        
        return findings
    
    def scan(self):
        """Main scan method."""
        results = []
        
        for site in self.paste_sites:
            query = f"site:{site}+{self.target}"
            urls = self.search_google(query)
            
            for url in urls:
                content = self.fetch_paste(url)
                credentials = self.find_credentials(content)
                
                if credentials:
                    results.append({
                        'url': url,
                        'credentials': credentials
                    })
        
        return results

if __name__ == '__main__':
    fetcher = PasteFetcher('target.com')
    results = fetcher.scan()
    print(json.dumps(results, indent=2))
```

### Paste Monitoring Tools

**Continuous Monitoring Script**
```bash
#!/bin/bash
# paste_monitor.sh - Continuous paste monitoring

TARGET=$1
WEBHOOK_URL="your_webhook_url"
STATE_FILE="/tmp/paste_monitor_${TARGET}.txt"

# Initialize state file
if [ ! -f "$STATE_FILE" ]; then
  echo "0" > "$STATE_FILE"
fi

LAST_COUNT=$(cat "$STATE_FILE")

while true; do
  # Search for new mentions
  CURRENT_PASTES=$(curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u | wc -l)
  
  if [ "$CURRENT_PASTES" -gt "$LAST_COUNT" ]; then
    # Get new pastes
    NEW_PASTES=$(curl -s "https://www.google.com/search?q=site:pastebin.com+${TARGET}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u)
    
    # Send notification
    curl -X POST "$WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"text\":\"New paste detected for ${TARGET}\",\"pastes\":\"${NEW_PASTES}\"}"
    
    echo "$CURRENT_PASTES" > "$STATE_FILE"
  fi
  
  sleep 3600  # Check every hour
done
```

## Case Studies

### Case Study 1: AWS Credentials in Pastebin

**Discovery**: Google dorking for `site:pastebin.com target.com aws` revealed a paste containing AWS access keys and secret keys that had been accidentally shared by a developer.

**Impact**:
1. Full AWS account compromise possible
2. Access to S3 buckets containing customer data
3. Ability to launch EC2 instances for cryptocurrency mining
4. Potential for lateral movement to other AWS services

**Methodology**:
```bash
# Search for AWS credentials
curl -s "https://www.google.com/search?q=site:pastebin.com+AKIA+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u

# Download and analyze paste
curl -s "https://pastebin.com/raw/abcdef123" | grep -oP 'AKIA[0-9A-Z]{16}'
curl -s "https://pastebin.com/raw/abcdef123" | grep -oP 'aws_secret_access_key["\s:=]+["\x27][^"\x27]+["\x27]'
```

### Case Study 2: Database Connection String Exposure

**Discovery**: A paste search revealed a developer had shared a database connection string containing the production database hostname, username, and password.

**Impact**:
1. Direct access to production database
2. Potential for data exfiltration
3. Ability to modify or delete data
4. Compliance violations (PCI DSS, GDPR)

### Case Study 3: Source Code Leakage

**Discovery**: Multiple pastes contained code snippets from the target's application, including internal API endpoints, authentication logic, and business rules.

**Impact**:
1. Internal API endpoints exposed
2. Authentication mechanism analyzed
3. Business logic vulnerabilities identified
4. Potential for targeted attacks

### Case Study 4: Internal Network Information

**Discovery**: A paste contained network diagrams, internal IP addresses, and server configurations that had been shared during troubleshooting.

**Impact**:
1. Internal network topology revealed
2. Server IP addresses exposed
3. Port and service information available
4. Lateral movement path identified

### Case Study 5: SSH Private Key Exposure

**Discovery**: A paste search revealed an SSH private key that had been accidentally shared, providing access to multiple servers.

**Impact**:
1. Direct server access via SSH
2. Potential for privilege escalation
3. Lateral movement across infrastructure
4. Persistent backdoor opportunity

## Advanced Techniques

### Regex Pattern Matching

```bash
# Custom regex patterns for different credential types
PATTERNS=(
  'AKIA[0-9A-Z]{16}'  # AWS Access Key
  'sk_live_[a-zA-Z0-9]+'  # Stripe Secret Key
  'pk_live_[a-zA-Z0-9]+'  # Stripe Publishable Key
  'ghp_[a-zA-Z0-9]{36}'  # GitHub Personal Access Token
  'xox[bpsa]-[a-zA-Z0-9-]+'  # Slack Token
  'AIza[0-9A-Za-z_-]{35}'  # Google API Key
  'SG\.[a-zA-Z0-9_-]{22,}\.[a-zA-Z0-9_-]{43,}'  # SendGrid API Key
  'sk-[a-zA-Z0-9]{48}'  # OpenAI API Key
  'token["\s:=]+["\x27][a-zA-Z0-9]{32,}["\x27]'  # Generic token
  'password["\s:=]+["\x27][^"\x27]{8,}["\x27]'  # Generic password
)

# Search for all patterns
for pattern in "${PATTERNS[@]}"; do
  echo "=== Searching for: $pattern ==="
  curl -s "https://www.google.com/search?q=site:pastebin.com+${pattern}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
done
```

### Cross-Reference with Other Sources

```bash
# Cross-reference paste findings with other recon sources
# Check if leaked emails appear in paste sites
while read email; do
  echo "=== Checking $email ==="
  curl -s "https://www.google.com/search?q=site:pastebin.com+${email}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
done < employee_emails.txt

# Check if leaked domains appear in paste sites
while read domain; do
  echo "=== Checking $domain ==="
  curl -s "https://www.google.com/search?q=site:pastebin.com+${domain}" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+' | sort -u
done < discovered_domains.txt
```

### Paste Content Analysis

```bash
# Analyze paste content for sensitive patterns
analyze_paste() {
  local paste_url=$1
  local content=$(curl -s "$paste_url")
  
  # Check for different types of sensitive data
  echo "$content" | grep -qP 'AKIA[0-9A-Z]{16}' && echo "[!] AWS credentials found"
  echo "$content" | grep -qP 'sk_live_[a-zA-Z0-9]+' && echo "[!] Stripe key found"
  echo "$content" | grep -qP 'ghp_[a-zA-Z0-9]{36}' && echo "[!] GitHub token found"
  echo "$content" | grep -qP 'password["\s:=]+["\x27][^"\x27]{8,}["\x27]' && echo "[!] Password found"
  echo "$content" | grep -qP '(BEGIN.*PRIVATE KEY)' && echo "[!] Private key found"
  echo "$content" | grep -qP 'mongodb(\+srv)?://[^"]+' && echo "[!] MongoDB connection string found"
  echo "$content" | grep -qP 'mysql://[^"]+' && echo "[!] MySQL connection string found"
  echo "$content" | grep -qP 'postgres(ql)?://[^"]+' && echo "[!] PostgreSQL connection string found"
  echo "$content" | grep -qP 'redis://[^"]+' && echo "[!] Redis connection string found"
}
```

## Detection Signatures

### Known Paste Site Patterns

| Site | URL Pattern | Content Access |
|------|-------------|----------------|
| Pastebin | pastebin.com/[a-zA-Z0-9]+ | /raw/[id] |
| Ghostbin | ghostbin.co/paste/[id] | /raw/[id] |
| Hastebin | hastebin.com/[id] | /raw/[id] |
| dpaste | dpaste.org/[id] | /raw |
| Gist | gist.github.com/[user]/[id] | /raw |

### Credential Format Patterns

| Service | Pattern | Example |
|---------|---------|---------|
| AWS | AKIA[0-9A-Z]{16} | AKIAIOSFODNN7EXAMPLE |
| Stripe | sk_live_[a-zA-Z0-9]+ | sk_live_1234567890abcdef |
| GitHub | ghp_[a-zA-Z0-9]{36} | ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij |
| Slack | xox[bpsa]-[a-zA-Z0-9-]+ | xoxb-1234567890-1234567890-abcde |
| Google | AIza[0-9A-Za-z_-]{35} | AIzaSyD-example1234567890abcdefghij |

## Impact Assessment

Paste site intelligence can reveal:
1. **Active Credentials**: API keys, passwords, tokens that may still be valid
2. **Internal Architecture**: Network topology, server configurations
3. **Source Code**: Application logic, business rules, vulnerabilities
4. **Employee Information**: Email addresses, internal usernames
5. **Business Data**: Customer information, financial data
6. **Security Configurations**: Firewall rules, access controls
7. **Deployment Information**: Infrastructure details, cloud configurations
8. **Third-Party Integrations**: Service credentials, webhook URLs

## Common Pitfalls

1. **Search engine rate limiting**: Google may block automated searches
2. **Paste expiration**: Pastes may be deleted before analysis
3. **False positives**: Credential patterns may match non-sensitive data
4. **Incomplete indexing**: Not all paste sites are indexed by search engines
5. **Dynamic content**: Some paste sites load content via JavaScript
6. **Authentication required**: Some paste sites require login to view content
7. **Geographic restrictions**: Some paste sites may be blocked in certain regions
8. **Legal considerations**: Accessing certain pastes may have legal implications

## Integration with Other Recon Activities

Paste site intelligence connects to:
- **Subdomain enumeration**: Paste mentions of subdomains
- **JavaScript analysis**: Leaked API keys from JS files
- **API documentation discovery**: Leaked API documentation
- **Cloud infrastructure discovery**: Leaked cloud credentials
- **Employee information gathering**: Leaked employee data
- **Technology fingerprinting**: Leaked source code revealing tech stack

## Reporting

### Paste Intelligence Report Template

```markdown
# Paste Site Intelligence Report

## Executive Summary
- Total paste mentions found: X
- Active credentials discovered: X
- Source code leaks: X
- Internal information exposed: X

## Credential Findings

### Active Credentials
| Credential Type | Value (Redacted) | Paste URL | Risk Level |
|-----------------|------------------|-----------|------------|
| AWS Access Key | AKIA***EXAMPLE | pastebin.com/abc | Critical |

### Password Findings
| Service | Username | Paste URL | Risk Level |
|---------|----------|-----------|------------|
| Database | admin | pastebin.com/def | High |

## Source Code Findings
| File Type | Content Summary | Paste URL | Risk Level |
|-----------|-----------------|-----------|------------|
| Config | Database config | pastebin.com/ghi | High |

## Internal Information Findings
| Data Type | Content Summary | Paste URL | Risk Level |
|-----------|-----------------|-----------|------------|
| Network | IP addresses | pastebin.com/jkl | Medium |

## Recommendations
1. Immediately rotate all exposed credentials
2. Review and update access control policies
3. Implement credential monitoring for paste sites
4. Conduct security awareness training for developers
```

## Labs

### Lab 1: Basic Paste Search
1. Set up a test target with known paste mentions
2. Use Google dorks to find paste site mentions
3. Download and analyze discovered pastes
4. Document all found sensitive data

### Lab 2: Credential Pattern Matching
1. Create test paste with different credential formats
2. Use regex patterns to identify credentials
3. Categorize findings by type and severity
4. Verify if credentials are still valid

### Lab 3: Monitoring Setup
1. Set up automated paste monitoring
2. Configure notifications for new mentions
3. Test alerting mechanisms
4. Document monitoring workflow

### Lab 4: Cross-Reference Analysis
1. Combine paste findings with other recon sources
2. Identify patterns and correlations
3. Build comprehensive target profile
4. Prioritize findings for reporting

## Ethics

Paste site intelligence should be conducted ethically:

1. **Authorization**: Only search for targets you have permission to test
2. **Data Handling**: Treat discovered credentials responsibly
3. **No Exploitation**: Do not use found credentials for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of individuals mentioned in pastes
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Search Google for paste mentions
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Download paste content
curl -s "https://pastebin.com/raw/PASTE_ID"

# Search for AWS credentials
curl -s "https://www.google.com/search?q=site:pastebin.com+AKIA" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Search for GitHub tokens
curl -s "https://www.google.com/search?q=site:pastebin.com+ghp_" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Search for Stripe keys
curl -s "https://www.google.com/search?q=site:pastebin.com+sk_live_" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Search for Slack tokens
curl -s "https://www.google.com/search?q=site:pastebin.com+xoxb-" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Search for passwords
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+password" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Search for API keys
curl -s "https://www.google.com/search?q=site:pastebin.com+target.com+api_key" | grep -oP 'https://pastebin\.com/[a-zA-Z0-9]+'

# Analyze paste content
curl -s "https://pastebin.com/raw/PASTE_ID" | grep -oP 'AKIA[0-9A-Z]{16}|sk_live_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36}'

# Search multiple paste sites
for site in pastebin.com ghostbin.co hastebin.com dpaste.org; do
  curl -s "https://www.google.com/search?q=site:${site}+target.com" | grep -oP "https?://${site}/[a-zA-Z0-9]+"
done
```
