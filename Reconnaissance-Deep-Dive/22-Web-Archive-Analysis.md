# Web Archive Analysis for Reconnaissance

## Expert Role

You are a digital archaeologist and reconnaissance specialist who leverages web archives to uncover historical information about targets. You understand that the internet never truly forgets — old versions of websites, leaked credentials, forgotten API endpoints, and decommissioned infrastructure all persist in web archives. You use the Wayback Machine, CDX APIs, and archive comparison techniques to build a temporal map of your target's digital footprint. You approach web archive analysis with the understanding that historical data often contains more sensitive information than current live sites, because developers were less security-conscious in the past.

## Core Concepts

### Why Web Archives Matter for Recon

Web archives provide a time machine for reconnaissance:

1. **Historical Data Exposure**: Old pages may contain credentials, API keys, or internal information that was removed from the live site
2. **Deleted Content Recovery**: Content removed by developers may still exist in archives
3. **Technology Evolution**: Track how the target's technology stack changed over time
4. **Infrastructure Changes**: Old DNS records, IP addresses, and subdomains
5. **Employee Information**: Former employees mentioned in old content
6. **Deprecated Endpoints**: Old API versions that may still be accessible
7. **Configuration Disclosure**: Old config files or debug pages that were removed

### Archive Sources

| Archive | URL | Coverage | API Access |
|---------|-----|----------|------------|
| Wayback Machine | web.archive.org | Largest | CDX API |
| Archive.today | archive.today | Snapshot-based | Limited |
| Common Crawl | commoncrawl.org | Massive | WARC files |
| Google Cache | webcache.googleusercontent.com | Recent | Limited |
| Bing Cache | cc.bingj.com | Recent | Limited |
| Coral CDN | cors.coralcdn.org | Mirrors | API |
| CachedView | cachedview.nl | Aggregator | Limited |

### Wayback Machine Architecture

The Wayback Machine stores snapshots of web pages:
- **Snapshots**: Individual page captures at specific timestamps
- **CDX Index**: Machine-readable index of all captures
- **WARC Files**: Raw archive files containing full HTTP responses
- **Metadata**: Timestamps, HTTP status codes, MIME types, digest hashes

### Key Terminology

- **CDX**: Comma-Delimited XML — machine-readable index format
- **WARC**: Web ARChive — raw format for storing HTTP transactions
- **MIME Type**: Content type of archived resources
- **Digest**: Hash of the archived content for deduplication
- **Timestamp**: YYYYMMDDHHMMSS format for archive captures
- **Status Code**: HTTP response code at time of capture

## Prerequisites

Before beginning web archive analysis, ensure you have:
- Understanding of HTTP protocol and status codes
- Familiarity with URL structures and query parameters
- Access to curl, grep, jq, and basic text processing tools
- Understanding of DNS records and subdomain structures
- Knowledge of common web application technologies
- Familiarity with API endpoint patterns
- Access to the Wayback Machine CDX API
- Understanding of JavaScript and its role in modern web apps
- Basic knowledge of file formats (HTML, JS, JSON, XML)
- Familiarity with command-line data processing (awk, sed, sort)

## Methodology

### Phase 1: Basic Wayback Machine Queries

**Get All Archived URLs for a Domain**

```bash
# CDX API query for all URLs under target.com
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode,mimetype&collapse=urlkey" | jq '.' > wayback_urls.json

# Get just unique URLs (sorted)
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&collapse=urlkey" | sort -u > wayback_unique_urls.txt

# Count total captures
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp" | jq 'length'
```

**Filter by Status Code**

```bash
# Get only successful captures (200 OK)
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&filter=statuscode:200&collapse=urlkey" | jq '.' > wayback_200.json

# Get error pages (might reveal hidden paths)
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&filter=statuscode:404&collapse=urlkey" | jq '.' > wayback_404.json

# Get redirects
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&filter=statuscode:301&collapse=urlkey" | jq '.' > wayback_redirects.json
```

**Filter by MIME Type**

```bash
# Get only HTML pages
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,mimetype&filter=mimetype:text/html&collapse=urlkey" | jq '.' > wayback_html.json

# Get JavaScript files
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,mimetype&filter=mimetype:application/javascript&collapse=urlkey" | jq '.' > wayback_js.json

# Get JSON files
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,mimetype&filter=mimetype:application/json&collapse=urlkey" | jq '.' > wayback_json.json
```

### Phase 2: Archived JavaScript Analysis

JavaScript files often contain more sensitive information than HTML.

**Extract and Analyze Archived JS Files**

```bash
# Get all archived JS files
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.js&output=json&fl=timestamp,original,statuscode&filter=statuscode:200&collapse=urlkey" | jq -r '.[] | "\(.[0]) \(.[1])"' > archived_js_files.txt

# Download and analyze each JS file
while read timestamp url; do
  echo "=== $url ($timestamp) ==="
  curl -s "https://web.archive.org/web/${timestamp}id_/${url}" | grep -oP '(api[_-]?key|apikey|secret|token|password|credential|auth)["\s:=]+["\x27][^"\x27]{8,}["\x27]'
done < archived_js_files.txt
```

**Search for API Endpoints in Archived JS**

```bash
# Look for API endpoint patterns in archived JavaScript
while read timestamp url; do
  echo "=== $url ==="
  curl -s "https://web.archive.org/web/${timestamp}id_/${url}" | grep -oP '(https?://[^"'"'"' ]+/api/[^"'"'"' ]+|/v[0-9]+/[^"'"'"' ]+|/graphql|/rest/[^"'"'"' ]+)' | sort -u
done < archived_js_files.txt
```

**Search for Hardcoded Secrets in Archived JS**

```bash
# Look for common secret patterns
while read timestamp url; do
  curl -s "https://web.archive.org/web/${timestamp}id_/${url}" | grep -oiP '(sk_live_[a-zA-Z0-9]+|pk_live_[a-zA-Z0-9]+|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|xox[bpsa]-[a-zA-Z0-9-]+)'
done < archived_js_files.txt
```

### Phase 3: Archived API Endpoint Discovery

```bash
# Look for API-related URLs in the CDX index
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/api/*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_api.json

# Look for REST endpoints
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/v1/*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_v1.json

curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/v2/*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_v2.json

# Look for GraphQL endpoints
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/graphql*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_graphql.json

# Look for webhook endpoints
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/webhook*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_webhooks.json
```

### Phase 4: Archived Config File Discovery

```bash
# Look for configuration files
for pattern in "*.env" "*.config" "*.json" "*.xml" "*.yml" "*.yaml" "*.ini" "*.properties"; do
  curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/${pattern}&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' >> wayback_configs.json
done

# Look for common config file paths
for path in "/.env" "/config.json" "/config.js" "/settings.json" "/application.json" "/database.yml" "/wp-config.php" "/.htaccess" "/web.config"; do
  curl -s "https://web.archive.org/cdx/search/cdx?url=target.com${path}&output=json&fl=timestamp,original,statuscode" | jq '.' >> wayback_specific_configs.json
done
```

### Phase 5: Archived Subdomain Discovery

```bash
# Search for subdomains in archived pages
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=original&collapse=urlkey" | jq -r '.[].original' | grep -oP 'https?://([a-zA-Z0-9-]+\.)*target\.com' | sort -u > archived_subdomains.txt

# Look for links in archived HTML
while read timestamp url; do
  curl -s "https://web.archive.org/web/${timestamp}id_/${url}" | grep -oP 'https?://[a-zA-Z0-9.-]+\.target\.com' | sort -u
done < <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original&filter=mimetype:text/html&collapse=urlkey&limit=50" | jq -r '.[] | "\(.[0]) \(.[1])"') >> archived_subdomains_from_pages.txt
```

### Phase 6: Archived Technology Detection

```bash
# Detect technologies from archived pages
while read timestamp url; do
  echo "=== $url ($timestamp) ==="
  content=$(curl -s "https://web.archive.org/web/${timestamp}id_/${url}")
  echo "$content" | grep -oP 'X-Powered-By: [^<]*' 
  echo "$content" | grep -oiP '(WordPress|Drupal|Joomla|Laravel|Django|Rails|Express|Spring|Angular|React|Vue)'
done < <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original&filter=mimetype:text/html&collapse=urlkey&limit=10" | jq -r '.[] | "\(.[0]) \(.[1])"')
```

### Phase 7: CDX API Advanced Queries

**Time-Range Filtering**

```bash
# Get captures from a specific year
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&from=20200101&to=20201231&collapse=urlkey" | jq '.' > wayback_2020.json

# Get the most recent captures
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&sort=reverse&limit=100" | jq '.' > wayback_recent.json

# Get the oldest captures
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&sort=closest&limit=10&from=20000101" | jq '.' > wayback_oldest.json
```

**Domain-Specific Queries**

```bash
# Search specific subdomain
curl -s "https://web.archive.org/cdx/search/cdx?url=api.target.com/*&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_api_subdomain.json

# Search with exact URL match
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/login&output=json&fl=timestamp,original,statuscode" | jq '.' > wayback_login.json

# Search for specific file types
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.pdf&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_pdfs.json

curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.zip&output=json&fl=timestamp,original,statuscode&collapse=urlkey" | jq '.' > wayback_archives.json
```

### Phase 8: Archive Comparison Techniques

**Detecting Changes Between Snapshots**

```bash
# Get two snapshots and compare
timestamp1="20200101120000"
timestamp2="20230101120000"

curl -s "https://web.archive.org/web/${timestamp1}id_/https://target.com/" > page1.html
curl -s "https://web.archive.org/web/${timestamp2}id_/https://target.com/" > page2.html

# Compare
diff page1.html page2.html | head -100
```

**Finding Removed Content**

```bash
# Get all URLs from 2020
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20200101&to=20201231&collapse=urlkey" | sort -u > urls_2020.txt

# Get all URLs from 2023
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20230101&to=20231231&collapse=urlkey" | sort -u > urls_2023.txt

# Find URLs that existed in 2020 but not in 2023 (removed content)
comm -23 urls_2020.txt urls_2023.txt > removed_urls.txt
```

**Tracking Technology Changes**

```bash
# Compare technology signatures across time periods
for year in 2018 2019 2020 2021 2022 2023; do
  echo "=== $year ==="
  curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original&from=${year}0101&to=${year}1231&filter=mimetype:text/html&limit=1" | jq -r '.[1][0]' | xargs -I{} curl -s "https://web.archive.org/web/{}id_/https://target.com/" | grep -oiP 'X-Powered-By: [^<]*'
done
```

### Phase 9: Complete Web Archive Reconnaissance Workflow

```bash
#!/bin/bash
# web_archive_recon.sh - Complete web archive reconnaissance script

TARGET=$1
OUTPUT_DIR="wayback_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting web archive reconnaissance for $TARGET"

# Step 1: Get all archived URLs
echo "[+] Fetching all archived URLs..."
curl -s "https://web.archive.org/cdx/search/cdx?url=${TARGET}/*&output=json&fl=timestamp,original,statuscode,mimetype&collapse=urlkey" | jq '.' > "$OUTPUT_DIR/all_urls.json"

# Step 2: Get unique URLs
jq -r '.[].original' "$OUTPUT_DIR/all_urls.json" | sort -u > "$OUTPUT_DIR/unique_urls.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/unique_urls.txt") unique URLs"

# Step 3: Filter by status code
jq -r 'select(.[2] == "200") | .[1]' "$OUTPUT_DIR/all_urls.json" | sort -u > "$OUTPUT_DIR/successful_urls.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/successful_urls.txt") successful URLs"

# Step 4: Extract subdomains
grep -oP "https?://([a-zA-Z0-9-]+\.)+${TARGET//./\\.}" "$OUTPUT_DIR/unique_urls.txt" | sort -u > "$OUTPUT_DIR/subdomains.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/subdomains.txt") unique subdomains"

# Step 5: Find JavaScript files
jq -r 'select(.[3] == "application/javascript") | .[1]' "$OUTPUT_DIR/all_urls.json" | sort -u > "$OUTPUT_DIR/js_files.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/js_files.txt") JavaScript files"

# Step 6: Find config files
grep -iE '\.(env|config|json|xml|yml|yaml|ini|properties)$' "$OUTPUT_DIR/unique_urls.txt" > "$OUTPUT_DIR/config_files.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/config_files.txt") potential config files"

# Step 7: Find API endpoints
grep -iE '(api|v[0-9]+|graphql|webhook|rest)' "$OUTPUT_DIR/unique_urls.txt" > "$OUTPUT_DIR/api_endpoints.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/api_endpoints.txt") API-related URLs"

# Step 8: Analyze JavaScript for secrets
echo "[+] Analyzing JavaScript files for secrets..."
while read js_url; do
  curl -s "https://web.archive.org/web/id_/${js_url}" | grep -oiP '(sk_live_[a-zA-Z0-9]+|pk_live_[a-zA-Z0-9]+|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}|xox[bpsa]-[a-zA-Z0-9-]+|api[_-]?key["\s:=]+["\x27][^"\x27]{8,}["\x27])' >> "$OUTPUT_DIR/potential_secrets.txt"
done < "$OUTPUT_DIR/js_files.txt"

# Step 9: Find deleted content
echo "[+] Checking for deleted content..."
recent_year=$(date +%Y)
old_year=$((recent_year - 3))
curl -s "https://web.archive.org/cdx/search/cdx?url=${TARGET}/*&output=text&fl=original&from=${old_year}0101&to=${old_year}1231&collapse=urlkey" | sort -u > "$OUTPUT_DIR/old_urls.txt"
curl -s "https://web.archive.org/cdx/search/cdx?url=${TARGET}/*&output=text&fl=original&from=${recent_year}0101&to=${recent_year}1231&collapse=urlkey" | sort -u > "$OUTPUT_DIR/current_urls.txt"
comm -23 "$OUTPUT_DIR/old_urls.txt" "$OUTPUT_DIR/current_urls.txt" > "$OUTPUT_DIR/potentially_removed.txt"
echo "[+] Found $(wc -l < "$OUTPUT_DIR/potentially_removed.txt") potentially removed URLs"

echo "[*] Reconnaissance complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### CDX API Tools

**curl-based Queries**
```bash
# Basic CDX query
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json"

# With all fields
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode,mimetype,digest,length"

# Pagination
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&limit=1000&offset=0"
```

### waybackurls (by Tomnomnom)

```bash
# Install
go install github.com/tomnomnom/waybackurls@latest

# Usage
echo "target.com" | waybackurls > wayback_urls.txt

# Get only unique URLs
echo "target.com" | waybackurls | sort -u > wayback_unique.txt

# Filter by year
echo "target.com" | waybackurls | grep "2023" > wayback_2023.txt
```

### gau (Get All URLs)

```bash
# Install
go install github.com/lc/gau/v2/cmd/gau@latest

# Usage
gau target.com > gau_urls.txt

# With providers
gau --providers wayback,commoncrawl,target.com > gau_comprehensive.txt

# Filter by extension
gau target.com | grep -E '\.(js|json|php|txt)$' > gau_filtered.txt
```

### Custom Archive Analysis Scripts

**Python Archive Analyzer**
```python
#!/usr/bin/env python3
import requests
import json
import sys
from datetime import datetime

def query_cdx(url, output='json', **kwargs):
    base = 'https://web.archive.org/cdx/search/cdx'
    params = {'url': url, 'output': output, **kwargs}
    r = requests.get(base, params=params)
    return r.json() if output == 'json' else r.text

def find_secrets_in_archives(target):
    """Search archived JavaScript files for secrets."""
    js_files = query_cdx(
        f'{target}/*.js',
        output='json',
        fl='timestamp,original,statuscode',
        filter='statuscode:200',
        collapse='urlkey'
    )
    
    secrets = []
    secret_patterns = [
        r'sk_live_[a-zA-Z0-9]+',
        r'pk_live_[a-zA-Z0-9]+',
        r'AKIA[0-9A-Z]{16}',
        r'ghp_[a-zA-Z0-9]{36}',
        r'xox[bpsa]-[a-zA-Z0-9-]+',
    ]
    
    for file in js_files[1:]:  # Skip header
        timestamp, url, status = file
        try:
            content = requests.get(
                f'https://web.archive.org/web/{timestamp}id_/{url}',
                timeout=10
            ).text
            for pattern in secret_patterns:
                import re
                matches = re.findall(pattern, content)
                if matches:
                    secrets.append({'url': url, 'timestamp': timestamp, 'secrets': matches})
        except:
            continue
    
    return secrets

if __name__ == '__main__':
    target = sys.argv[1]
    secrets = find_secrets_in_archives(target)
    print(json.dumps(secrets, indent=2))
```

### Playwright-Based Archive Viewer

```javascript
const { chromium } = require('playwright');

async function viewArchivedPage(url, timestamp) {
  const browser = await chromium.launch();
  const page = await browser.newPage();
  
  const archiveUrl = `https://web.archive.org/web/${timestamp}/${url}`;
  await page.goto(archiveUrl, { waitUntil: 'networkidle' });
  
  // Extract all links
  const links = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('a[href]')).map(a => a.href);
  });
  
  // Extract scripts
  const scripts = await page.evaluate(() => {
    return Array.from(document.querySelectorAll('script[src]')).map(s => s.src);
  });
  
  await browser.close();
  return { links, scripts };
}
```

## Case Studies

### Case Study 1: Recovered Deleted API Keys from Archived JavaScript

**Discovery**: Analysis of archived JavaScript files from 2019 revealed a Stripe secret key (sk_live_...) that had been accidentally committed to client-side code and subsequently removed in 2020.

**Impact**: The leaked secret key could have been used to:
1. Create charges and refunds
2. Access customer data
3. Modify account settings
4. Full payment processor compromise

**Methodology**:
```bash
# Find JS files from 2019
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.js&output=json&fl=timestamp,original&from=20190101&to=20191231&filter=statuscode:200" | jq -r '.[1:][] | "\(.[0]) \(.[1])"' > js_2019.txt

# Analyze each file for secrets
while read timestamp url; do
  curl -s "https://web.archive.org/web/${timestamp}id_/${url}" | grep -oP 'sk_live_[a-zA-Z0-9]+'
done < js_2019.txt
```

### Case Study 2: Discovery of Deprecated Admin Panel

**Discovery**: Web archive analysis revealed that an admin panel (/admin/) existed on the target site until 2021, when it was removed. The archived version showed different authentication mechanisms than the current site.

**Impact**:
1. Deprecated admin panel may still be accessible on older infrastructure
2. Different authentication mechanism could be vulnerable
3. Historical admin credentials may work on current systems
4. Old admin functionality may reveal business logic

### Case Study 3: Historical Subdomain Takeover

**Discovery**: Archive analysis showed that subdomain blog.target.com was pointed to a GitHub Pages domain in 2020, then the CNAME was removed in 2021. However, the GitHub Pages repository was still active.

**Impact**:
1. Subdomain takeover opportunity on blog.target.com
2. Could serve malicious content under target.com domain
3. Phishing and credential theft via trusted domain
4. XSS attacks affecting all visitors

### Case Study 4: Old Configuration File with Database Credentials

**Discovery**: A configuration file (config.json) was archived in 2018 containing database connection strings with plaintext credentials.

**Impact**:
1. Database credentials for potentially still-active database server
2. Same credentials may be reused across environments
3. Direct database access could lead to data exfiltration
4. Internal network pivot point

### Case Study 5: Tracking Technology Evolution for Vulnerability Research

**Discovery**: Archive comparison showed the target migrated from Apache 2.2 to Nginx in 2019, then to a cloud-native architecture in 2022. Each migration left legacy endpoints accessible.

**Impact**:
1. Old Apache endpoints may not be handled by Nginx
2. Cloud migration may have left old servers running
3. Different technology stacks have different vulnerability profiles
4. Legacy endpoints can bypass modern security controls

## Advanced Techniques

### Cross-Reference with Other Archives

```bash
# Query multiple archive sources
# Wayback Machine
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&collapse=urlkey" | sort -u > wayback_urls.txt

# Common Crawl (via their API)
curl -s "https://index.commoncrawl.org/CC-MAIN-2023-50-index?url=target.com/*&output=json" | jq '.' > commoncrawl_urls.txt

# Combine and deduplicate
cat wayback_urls.txt <(jq -r '.url' commoncrawl_urls.txt) | sort -u > combined_urls.txt
```

### Archive-Based Credential Hunting

```bash
# Search for credential patterns in archived content
for year in 2018 2019 2020 2021 2022 2023; do
  echo "=== Checking $year ==="
  curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original&from=${year}0101&to=${year}1231&filter=mimetype:text/html&limit=10" | jq -r '.[1:][] | "\(.[0]) \(.[1])"' | while read ts url; do
    curl -s "https://web.archive.org/web/${ts}id_/${url}" | grep -oiP '(password|passwd|pwd|secret|api.?key|token|credential)["\s:=]+["\x27][^"\x27]{4,}["\x27]'
  done
done
```

### Archive Diff Analysis

```bash
# Compare two time periods to find security-relevant changes
get_hashes() {
  local period=$1
  curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,digest&from=${period}&collapse=urlkey" | jq -r '.[1:][] | "\(.[1]) \(.[2])"' | sort
}

get_hashes "20220101-20220630" > hashes_2022_h1.txt
get_hashes "20230101-20230630" > hashes_2023_h1.txt

# Find URLs that changed content
join hashes_2022_h1.txt hashes_2023_h1.txt | awk '$2 != $3 {print $1}'
```

### Automated Archive Monitoring

```bash
# Set up monitoring for new archive captures
#!/bin/bash
# archive_monitor.sh

TARGET=$1
LAST_COUNT=0

while true; do
  CURRENT_COUNT=$(curl -s "https://web.archive.org/cdx/search/cdx?url=${TARGET}/*&output=json&fl=timestamp" | jq 'length')
  
  if [ "$CURRENT_COUNT" -gt "$LAST_COUNT" ]; then
    echo "[+] New archive captures detected!"
    curl -s "https://web.archive.org/cdx/search/cdx?url=${TARGET}/*&output=json&fl=timestamp,original,statuscode&sort=reverse&limit=10" | jq '.'
    LAST_COUNT=$CURRENT_COUNT
  fi
  
  sleep 3600  # Check every hour
done
```

## Detection Signatures

### Archive Access Patterns

The Wayback Machine can detect and log access:
- User-Agent: Archive.org_bot (for crawlers)
- Regular browser access is logged
- Rate limits apply to CDX API queries

### Known Archive Artifacts

| Artifact | Description |
|----------|-------------|
| __wm.rw | Wayback Machine toolbar script |
| wb.js | Wayback Machine JavaScript |
| /web/YYYYMMDD/ | Archive timestamp in URL |
| id_ | Raw (identity) archive prefix |
| if_ | If-modified-since archive prefix |
| *js | JavaScript archive capture |

## Impact Assessment

Web archive analysis can reveal:
1. **Historical Credentials**: Old passwords, API keys, tokens
2. **Deleted Content**: Pages removed for security reasons
3. **Infrastructure Changes**: Old servers, IPs, subdomains
4. **Employee Information**: Former staff, contact details
5. **Business Logic**: Old functionality, workflows
6. **Technology Stack**: Versions, configurations, dependencies
7. **Internal Documentation**: Wiki pages, README files
8. **Source Code Leaks**: accidentally exposed code

## Common Pitfalls

1. **Not all content is archived**: The Wayback Machine doesn't capture everything
2. **Archived content may be incomplete**: JavaScript and dynamic content often missing
3. **Rate limiting**: CDX API has rate limits
4. **Timestamp accuracy**: Archive timestamps may not reflect exact capture time
5. **Content drift**: Same URL may serve different content over time
6. **robots.txt blocking**: Some archives respect robots.txt exclusions
7. **Dynamic content**: SPA content may not be captured
8. **Authentication**: Archived pages behind login are not captured

## Integration with Other Recon Activities

Web archive analysis connects to:
- **Subdomain enumeration**: Historical subdomains in archives
- **JavaScript analysis**: Archived JS files for endpoint discovery
- **Secret scanning**: Historical credentials in archived content
- **Technology fingerprinting**: Technology evolution over time
- **Cloud infrastructure discovery**: Old cloud service references
- **API documentation discovery**: Archived API documentation

## Reporting

### Archive Analysis Report Template

```markdown
# Web Archive Analysis Report

## Executive Summary
- Total archived URLs analyzed: X
- Historical secrets found: X
- Deleted content recovered: X
- Subdomains discovered: X

## Historical Findings

### Secrets and Credentials
| File | Timestamp | Secret Type | Status |
|------|-----------|-------------|--------|
| app.js | 2019-03-15 | Stripe Key | Removed |

### Deleted Content
| URL | Last Archived | Content Type | Risk |
|-----|---------------|--------------|------|
| /admin/ | 2021-06 | Admin Panel | High |

### Subdomain Changes
| Subdomain | Status | Technology | Risk |
|-----------|--------|------------|------|
| blog.target.com | Taken over | GitHub Pages | Critical |

## Recommendations
1. Rotate any historically exposed credentials
2. Verify old subdomains are properly decommissioned
3. Review archived content for compliance issues
4. Implement archive-aware security monitoring
```

## Labs

### Lab 1: Basic Archive Queries
1. Query the Wayback Machine CDX API for your target
2. Filter results by status code and MIME type
3. Extract unique URLs and categorize them
4. Identify JavaScript files for further analysis

### Lab 2: Secret Recovery
1. Find JavaScript files archived in the last 5 years
2. Download and analyze each file for hardcoded secrets
3. Document any found credentials or API keys
4. Verify if found secrets are still valid

### Lab 3: Content Change Detection
1. Get archived snapshots from two different years
2. Compare the HTML content of the homepage
3. Identify changes in technology stack
4. Document any removed or added functionality

### Lab 4: Subdomain Discovery
1. Extract all subdomains from archived URLs
2. Cross-reference with DNS records
3. Identify abandoned subdomains
4. Test for subdomain takeover opportunities

## Ethics

Web archive analysis should be conducted ethically:

1. **Authorization**: Only analyze targets you have permission to test
2. **Data Sensitivity**: Handle archived credentials responsibly
3. **No Exploitation**: Do not use archived credentials for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Archive Respect**: Do not abuse archive.org services or rate limits
6. **Privacy**: Consider privacy implications of archived personal data
7. **Scope**: Stay within the defined scope of engagement
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Get all archived URLs
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&collapse=urlkey"

# Get only successful pages
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=json&fl=timestamp,original,statuscode&filter=statuscode:200&collapse=urlkey"

# Get JavaScript files
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.js&output=json&fl=timestamp,original&collapse=urlkey"

# Get config files
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.json&output=json&fl=timestamp,original&collapse=urlkey"

# Download archived page
curl -s "https://web.archive.org/web/TIMESTAMPid_/https://target.com/"

# Find removed content
comm -23 <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20200101&to=20201231&collapse=urlkey" | sort -u) <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20230101&to=20231231&collapse=urlkey" | sort -u)

# Search for secrets in archived JS
for url in $(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*.js&output=text&fl=original&collapse=urlkey"); do
  curl -s "https://web.archive.org/web/id_/${url}" | grep -oiP 'sk_live_[a-zA-Z0-9]+|AKIA[0-9A-Z]{16}|ghp_[a-zA-Z0-9]{36}'
done

# Get subdomains from archives
curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&collapse=urlkey" | grep -oP 'https?://([a-zA-Z0-9-]+\.)+target\.com' | sort -u

# Use waybackurls tool
echo "target.com" | waybackurls > wayback_urls.txt

# Use gau tool
gau target.com > gau_urls.txt

# Compare two time periods
diff <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20220101&to=20220630&collapse=urlkey" | sort -u) <(curl -s "https://web.archive.org/cdx/search/cdx?url=target.com/*&output=text&fl=original&from=20230101&to=20230630&collapse=urlkey" | sort -u)
```
