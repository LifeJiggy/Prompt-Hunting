# Code Repository Mining

## Expert Role

You are a code repository mining specialist who systematically searches public code repositories for sensitive information, credentials, and intelligence about targets. You understand that developers frequently commit code to public repositories (GitHub, GitLab, Bitbucket) that contains hardcoded secrets, internal APIs, configuration files, and other sensitive data. You approach code repository mining with the mindset that every commit is a potential intelligence source, and that the history of a repository often contains more sensitive information than its current state. You combine automated search techniques with manual code analysis to build a comprehensive picture of what information has been exposed through public code repositories.

## Core Concepts

### Code Repository Landscape

Public code repositories are a primary source of leaked credentials and sensitive information:

| Platform | Domain | Search API | Visibility |
|----------|--------|------------|------------|
| GitHub | github.com | Yes | Public/Private |
| GitLab | gitlab.com | Yes | Public/Private |
| Bitbucket | bitbucket.org | Yes | Public/Private |
| SourceForge | sourceforge.net | Limited | Public |
| Gitea | Various | Limited | Public/Private |
| Codeberg | codeberg.org | Limited | Public |

### Why Code Repositories Leak Secrets

Understanding why secrets end up in code helps predict where to find them:

1. **Developer Convenience**: Hardcoding credentials for quick testing
2. **Forgot to Remove**: Credentials left in code after development
3. **Copy-Paste Errors**: Accidentally including secrets in shared code
4. **Configuration Mistakes**: Committing config files with secrets
5. **Environment Variables**: Committing .env files
6. **Test Data**: Using real credentials in test cases
7. **Documentation**: Including credentials in README files
8. **Legacy Code**: Old code with previously valid credentials

### Types of Secrets Found in Repos

| Secret Type | Pattern | Risk Level |
|-------------|---------|------------|
| AWS Access Key | AKIA[0-9A-Z]{16} | Critical |
| AWS Secret Key | 40-character base64 | Critical |
| GitHub Token | ghp_[a-zA-Z0-9]{36} | High |
| GitLab Token | glpat-[a-zA-Z0-9-]{20,} | High |
| Slack Token | xox[bpsa]-[a-zA-Z0-9-]+ | Medium |
| Stripe Key | sk_live_[a-zA-Z0-9]+ | Critical |
| Google API Key | AIza[0-9A-Za-z_-]{35} | Medium |
| Private Key | BEGIN.*PRIVATE KEY | Critical |
| Database URL | (mysql|postgres|mongodb)://[^"]+ | High |
| Password | password["\s:=]+["'][^"']+ | Medium |

### Repository Mining Strategies

| Strategy | Description | Effectiveness |
|----------|-------------|---------------|
| Code Search | Search for specific patterns | High |
| Commit Search | Search commit messages and diffs | High |
| File Search | Search for specific file types | Medium |
| User Search | Search for specific users/orgs | Medium |
| Dependency Search | Search for vulnerable dependencies | Medium |
| Fork Analysis | Analyze forks for secrets | Low-Medium |

## Prerequisites

Before beginning code repository mining, ensure you have:
- Accounts on major code platforms (GitHub, GitLab, Bitbucket)
- Access to code search APIs (GitHub API, GitLab API)
- Knowledge of common secret patterns and formats
- Familiarity with git commands and repository structure
- Access to tools: curl, grep, jq, git
- Understanding of programming languages and their syntax
- Knowledge of common configuration file formats
- Familiarity with package manager files (package.json, requirements.txt)

## Methodology

### Phase 1: GitHub Code Search

**Basic Code Search**

```bash
# Search for target domain in code
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for target company name
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=%22Target+Company%22" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for specific file types
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=target.com+filename:config" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

**Advanced Code Search**

```bash
# Search for credentials patterns
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=AKIA+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for private keys
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=BEGIN+PRIVATE+KEY+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for database connection strings
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=mongodb://+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

### Phase 2: GitHub Commit Search

**Search Commit Messages**

```bash
# Search commit messages for target
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/commits?q=target.com" \
  -H "Accept: application/vnd.github.cloak-preview+json" | jq '.items[] | {message: .commit.message, url: .html_url, author: .commit.author.name}'

# Search for credential-related commits
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/commits?q=target.com+password" \
  -H "Accept: application/vnd.github.cloak-preview+json" | jq '.items[] | {message: .commit.message, url: .html_url}'
```

**Search Commit Diffs**

```bash
# Get commit diffs for specific repository
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/commits" | jq '.[].sha' | while read sha; do
  curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
    "https://api.github.com/repos/OWNER/REPO/commits/$sha" | jq '.files[].patch' | grep -i "password\|secret\|key\|token"
done
```

### Phase 3: GitHub File and Repository Search

**Search for Specific File Types**

```bash
# Search for .env files
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:.env+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for config files
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:config.json+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for docker files
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:Dockerfile+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for Kubernetes configs
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:deployment.yaml+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

**Search Repositories**

```bash
# Search for repositories belonging to target organization
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/orgs/ORG_NAME/repos?per_page=100" | jq '.[] | {name: .name, url: .html_url, description: .description}'

# Search for repositories mentioning target
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/repositories?q=target.com" | jq '.items[] | {name: .full_name, url: .html_url, description: .description}'
```

### Phase 4: GitLab Analysis

**GitLab Code Search**

```bash
# Search GitLab for target
curl -s "https://gitlab.com/api/v4/search?scope=blobs&search=target.com" | jq '.[] | {filename: .filename, path: .path, project_id: .project_id}'

# Search for specific patterns
curl -s "https://gitlab.com/api/v4/search?scope=blobs&search=AKIA+target.com" | jq '.[] | {filename: .filename, path: .path, project_id: .project_id}'

# Search for specific projects
curl -s "https://gitlab.com/api/v4/projects?search=target.com" | jq '.[] | {name: .name, url: .web_url, description: .description}'
```

**GitLab Commit Search**

```bash
# Search commits in specific project
curl -s "https://gitlab.com/api/v4/projects/PROJECT_ID/repository/commits?search=target.com" | jq '.[] | {title: .title, web_url: .web_url, author_name: .author_name}'
```

### Phase 5: Bitbucket Enumeration

**Bitbucket Search**

```bash
# Search Bitbucket for target
curl -s "https://api.bitbucket.org/2.0/repositories?q=target.com" | jq '.values[] | {name: .name, url: .links.html.href, description: .description}'

# Search code in Bitbucket
curl -s "https://api.bitbucket.org/2.0/search/code?q=target.com" | jq '.values[] | {filename: .file.name, path: .file.path, repository: .repository.name}'
```

### Phase 6: Credential Discovery in Repos

**Search for AWS Credentials**

```bash
# Search for AWS access keys
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=AKIA+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for AWS secret keys (pattern-based)
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=aws_secret_access_key+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

**Search for GitHub/GitLab Tokens**

```bash
# Search for GitHub tokens
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=ghp_+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

# Search for GitLab tokens
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=glpat-+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

**Search for Database Credentials**

```bash
# Search for database connection strings
curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=mongodb://+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=mysql://+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'

curl -s -H "Authorization: token YOUR_GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=postgres://+target.com" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}'
```

### Phase 7: Secret Scanning

**Using GitLeaks**

```bash
# Install GitLeaks
go install github.com/gitleaks/gitleaks@latest

# Scan a repository
gitleaks detect -v -r report.json -s /path/to/repo

# Scan with specific rules
gitleaks detect -v -r report.json -s /path/to/repo --config=.gitleaks.toml
```

**Using TruffleHog**

```bash
# Install TruffleHog
pip install trufflehog

# Scan GitHub organization
trufflehog github --org=target-org --json > trufflehog_results.json

# Scan specific repository
trufflehog github --repo=target-repo --json > trufflehog_results.json
```

**Custom Secret Scanning Script**

```bash
#!/bin/bash
# secret_scanner.sh - Custom secret scanner for repositories

REPO_URL=$1
OUTPUT_DIR="secret_scan_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

# Clone repository
git clone --mirror "$REPO_URL" "$OUTPUT_DIR/repo.git"

# Search for secrets in current code
echo "[+] Scanning current code..."
grep -r -i -E '(AKIA[0-9A-Z]{16}|sk_live_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36}|password["\s:=]+["\x27][^"\x27]{8,}["\x27])' "$OUTPUT_DIR/repo.git" > "$OUTPUT_DIR/current_secrets.txt"

# Search for secrets in git history
echo "[+] Scanning git history..."
cd "$OUTPUT_DIR/repo.git"
git log --all -p | grep -i -E '(AKIA[0-9A-Z]{16}|sk_live_[a-zA-Z0-9]+|ghp_[a-zA-Z0-9]{36}|password["\s:=]+["\x27][^"\x27]{8,}["\x27])' > "$OUTPUT_DIR/history_secrets.txt"
cd -

echo "[+] Scan complete. Results in $OUTPUT_DIR/"
```

### Phase 8: Complete Code Repository Mining Workflow

```bash
#!/bin/bash
# repo_mining.sh - Complete code repository mining workflow

TARGET=$1
GITHUB_TOKEN=$2
OUTPUT_DIR="repo_mining_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting code repository mining for $TARGET"

# Step 1: Search GitHub for target
echo "[+] Searching GitHub..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=$TARGET" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}' > "$OUTPUT_DIR/github_code.json"

# Step 2: Search for credentials
echo "[+] Searching for credentials..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=AKIA+$TARGET" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}' > "$OUTPUT_DIR/github_aws.json"

curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=sk_live_+$TARGET" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}' > "$OUTPUT_DIR/github_stripe.json"

# Step 3: Search for configuration files
echo "[+] Searching for configuration files..."
curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:.env+$TARGET" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}' > "$OUTPUT_DIR/github_env.json"

curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/search/code?q=filename:config.json+$TARGET" | jq '.items[] | {name: .name, repository: .repository.full_name, url: .html_url}' > "$OUTPUT_DIR/github_config.json"

# Step 4: Search GitLab
echo "[+] Searching GitLab..."
curl -s "https://gitlab.com/api/v4/search?scope=blobs&search=$TARGET" | jq '.[] | {filename: .filename, path: .path, project_id: .project_id}' > "$OUTPUT_DIR/gitlab_search.json"

# Step 5: Search Bitbucket
echo "[+] Searching Bitbucket..."
curl -s "https://api.bitbucket.org/2.0/search/code?q=$TARGET" | jq '.values[] | {filename: .file.name, path: .file.path, repository: .repository.name}' > "$OUTPUT_DIR/bitbucket_search.json"

# Step 6: Analyze found files
echo "[+] Analyzing found files..."
while read -r file_url; do
  echo "  Analyzing: $file_url"
  # Download and analyze file
  content=$(curl -s -H "Authorization: token $GITHUB_TOKEN" "$file_url" | jq -r '.content' | base64 -d)
  
  # Check for secrets
  if echo "$content" | grep -qP 'AKIA[0-9A-Z]{16}'; then
    echo "[!] AWS key found in $file_url" >> "$OUTPUT_DIR/findings.txt"
  fi
  if echo "$content" | grep -qP 'sk_live_[a-zA-Z0-9]+'; then
    echo "[!] Stripe key found in $file_url" >> "$OUTPUT_DIR/findings.txt"
  fi
done < <(jq -r '.[].url' "$OUTPUT_DIR/github_code.json")

# Step 7: Generate report
echo "[+] Generating report..."
echo "=== Code Repository Mining Report ===" > "$OUTPUT_DIR/report.txt"
echo "Target: $TARGET" >> "$OUTPUT_DIR/report.txt"
echo "Date: $(date)" >> "$OUTPUT_DIR/report.txt"
echo "" >> "$OUTPUT_DIR/report.txt"
echo "GitHub code results: $(jq 'length' "$OUTPUT_DIR/github_code.json")" >> "$OUTPUT_DIR/report.txt"
echo "AWS key results: $(jq 'length' "$OUTPUT_DIR/github_aws.json")" >> "$OUTPUT_DIR/report.txt"
echo "Stripe key results: $(jq 'length' "$OUTPUT_DIR/github_stripe.json")" >> "$OUTPUT_DIR/report.txt"
echo "Config file results: $(jq 'length' "$OUTPUT_DIR/github_config.json")" >> "$OUTPUT_DIR/report.txt"

echo "[*] Mining complete. Results saved to $OUTPUT_DIR/"
```

## Tool Arsenal

### Official Platform APIs

**GitHub API**
```bash
# Search code
curl -s -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/search/code?q=target.com"

# Get repository contents
curl -s -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/contents/path/to/file"

# Get commit history
curl -s -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/commits"
```

**GitLab API**
```bash
# Search code
curl -s "https://gitlab.com/api/v4/search?scope=blobs&search=target.com"

# Get project files
curl -s "https://gitlab.com/api/v4/projects/PROJECT_ID/repository/files/FILE_PATH/raw"

# Get commits
curl -s "https://gitlab.com/api/v4/projects/PROJECT_ID/repository/commits"
```

### Third-Party Tools

**truffleHog**
```bash
# Scan GitHub organization
trufflehog github --org=target-org --json

# Scan specific repository
trufflehog github --repo=https://github.com/org/repo --json
```

**GitLeaks**
```bash
# Scan repository
gitleaks detect -v -r report.json -s /path/to/repo

# Scan with custom config
gitleaks detect -v -r report.json -s /path/to/repo --config=.gitleaks.toml
```

**git-secrets**
```bash
# Install
brew install git-secrets

# Scan repository
git secrets --scan /path/to/repo
```

### Custom Scripts

**Automated Repository Cloner**
```bash
#!/bin/bash
# clone_repos.sh - Clone all repositories from an organization

ORG=$1
GITHUB_TOKEN=$2
OUTPUT_DIR="repos_${ORG}"
mkdir -p "$OUTPUT_DIR"

# Get all repositories
repos=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
  "https://api.github.com/orgs/$ORG/repos?per_page=100" | jq -r '.[].clone_url')

# Clone each repository
for repo in $repos; do
  repo_name=$(basename "$repo" .git)
  echo "Cloning $repo_name..."
  git clone --depth 1 "$repo" "$OUTPUT_DIR/$repo_name"
done

echo "[+] Cloned $(ls "$OUTPUT_DIR" | wc -l) repositories"
```

## Case Studies

### Case Study 1: AWS Credentials in GitHub Repository

**Discovery**: A developer accidentally committed AWS access keys and secret keys to a public GitHub repository. The credentials were in a configuration file that was supposed to be in .gitignore.

**Impact**:
1. Full AWS account compromise
2. Access to S3 buckets with customer data
3. Ability to launch EC2 instances
4. Potential for lateral movement

**Methodology**:
```bash
# Search for AWS keys
curl -s -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/search/code?q=AKIA+target.com"

# Analyze found file
curl -s -H "Authorization: token YOUR_TOKEN" \
  "https://api.github.com/repos/OWNER/REPO/contents/config.js" | jq -r '.content' | base64 -d
```

### Case Study 2: Database Credentials in Commit History

**Discovery**: While the current codebase contained placeholder credentials, the commit history revealed that real database credentials had been used during development and later removed.

**Impact**:
1. Direct access to production database
2. Historical data exposure
3. Potential for data exfiltration
4. Compliance violations

**Methodology**:
```bash
# Search commit history
git log --all -p | grep -i "password\|secret\|key"

# Find specific commit with credentials
git log --all --grep="password" --oneline
```

### Case Study 3: Private Key Exposure

**Discovery**: A private SSH key was committed to a public repository, providing access to multiple servers and services.

**Impact**:
1. Direct server access
2. Potential for privilege escalation
3. Lateral movement across infrastructure
4. Persistent backdoor opportunity

### Case Study 4: API Key in Configuration File

**Discovery**: A configuration file committed to a public repository contained API keys for third-party services including Stripe, SendGrid, and Twilio.

**Impact**:
1. Financial fraud via Stripe key
2. Email spoofing via SendGrid key
3. SMS fraud via Twilio key
4. Third-party service abuse

### Case Study 5: Internal API Endpoints in Code

**Discovery**: Source code committed to a public repository revealed internal API endpoints, authentication mechanisms, and business logic.

**Impact**:
1. Internal API endpoints exposed
2. Authentication mechanism analyzed
3. Business logic vulnerabilities identified
4. Targeted attack development possible

## Advanced Techniques

### Commit Diff Analysis

```bash
# Analyze specific commit diffs for secrets
analyze_commit_diff() {
  local commit_sha=$1
  local repo_url=$2
  
  git clone --depth 100 "$repo_url" /tmp/repo_analysis
  cd /tmp/repo_analysis
  
  git show "$commit_sha" --stat | while read line; do
    if [[ $line == *"+"* ]]; then
      file=$(echo $line | awk '{print $1}')
      git show "$commit_sha:$file" | grep -i -E '(password|secret|key|token|credential)'
    fi
  done
  
  cd -
  rm -rf /tmp/repo_analysis
}
```

### Dependency Analysis

```bash
# Analyze package dependencies for vulnerabilities
analyze_dependencies() {
  local repo_path=$1
  
  # Check package.json
  if [ -f "$repo_path/package.json" ]; then
    cat "$repo_path/package.json" | jq '.dependencies, .devDependencies' | grep -i "target"
  fi
  
  # Check requirements.txt
  if [ -f "$repo_path/requirements.txt" ]; then
    grep -i "target" "$repo_path/requirements.txt"
  fi
  
  # Check Gemfile
  if [ -f "$repo_path/Gemfile" ]; then
    grep -i "target" "$repo_path/Gemfile"
  fi
}
```

### Fork Analysis

```bash
# Analyze forks for additional secrets
analyze_forks() {
  local repo_url=$1
  local github_token=$2
  
  # Get all forks
  forks=$(curl -s -H "Authorization: token $github_token" \
    "https://api.github.com/repos/OWNER/REPO/forks?per_page=100" | jq -r '.[].clone_url')
  
  # Clone and scan each fork
  for fork in $forks; do
    fork_name=$(basename "$fork" .git)
    git clone --depth 1 "$fork" "/tmp/fork_$fork_name"
    gitleaks detect -v -r "/tmp/fork_$fork_name.json" -s "/tmp/fork_$fork_name"
    rm -rf "/tmp/fork_$fork_name"
  done
}
```

## Detection Signatures

### Known Secret Patterns in Code

| Pattern | Description | Example |
|---------|-------------|---------|
| `AKIA[0-9A-Z]{16}` | AWS Access Key | `AKIAIOSFODNN7EXAMPLE` |
| `sk_live_[a-zA-Z0-9]+` | Stripe Secret Key | `sk_live_1234567890abcdef` |
| `ghp_[a-zA-Z0-9]{36}` | GitHub Token | `ghp_ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghij` |
| `glpat-[a-zA-Z0-9-]{20,}` | GitLab Token | `glpat-ABCDEF1234567890` |
| `xox[bpsa]-[a-zA-Z0-9-]+` | Slack Token | `xoxb-1234567890-1234567890-abcde` |
| `AIza[0-9A-Za-z_-]{35}` | Google API Key | `AIzaSyD-example1234567890abcdefghij` |

### File Type Indicators

| File Type | Risk | What to Look For |
|-----------|------|------------------|
| .env | High | Environment variables with secrets |
| config.json | High | Configuration with credentials |
| docker-compose.yml | Medium | Container configurations |
| deployment.yaml | Medium | Kubernetes deployments |
| .gitignore | Low | May reveal secret file names |

## Impact Assessment

Code repository mining can reveal:
1. **Active Credentials**: API keys, passwords, tokens
2. **Internal Architecture**: Code structure, business logic
3. **Employee Information**: Usernames, email addresses
4. **Technology Stack**: Languages, frameworks, dependencies
5. **Security Configurations**: Authentication mechanisms, access controls
6. **Infrastructure Details**: Server configurations, deployment scripts
7. **Business Logic**: Application workflows, data processing
8. **Third-Party Integrations**: Service credentials, API endpoints

## Common Pitfalls

1. **Rate limiting**: API rate limits may slow down large-scale searches
2. **Private repositories**: Not all repositories are publicly accessible
3. **Deleted commits**: Git history may be rewritten to remove secrets
4. **False positives**: Credential patterns may match non-sensitive data
5. **Encoding issues**: Secrets may be encoded or encrypted
6. **Access restrictions**: Some platforms require authentication for search
7. **Data volume**: Large organizations may have thousands of repositories
8. **Legal considerations**: Accessing certain repositories may have legal implications

## Integration with Other Recon Activities

Code repository mining connects to:
- **Subdomain enumeration**: Repository references to subdomains
- **JavaScript analysis**: Source code for API endpoints
- **API documentation discovery**: Code revealing API structures
- **Cloud infrastructure discovery**: Cloud credentials in code
- **Employee information gathering**: Developer usernames and emails
- **Technology fingerprinting**: Dependencies and frameworks

## Reporting

### Code Repository Mining Report Template

```markdown
# Code Repository Mining Report

## Executive Summary
- Total repositories analyzed: X
- Secrets discovered: X
- Active credentials found: X
- Internal information exposed: X

## Credential Findings

### AWS Credentials
| Key Type | Access Key | Repository | File | Risk Level |
|----------|------------|------------|------|------------|
| Access Key | AKIA*** | org/repo | config.js | Critical |

### API Keys
| Service | Key (Redacted) | Repository | File | Risk Level |
|---------|----------------|------------|------|------------|
| Stripe | sk_live_*** | org/repo | .env | Critical |

### Database Credentials
| Database | Connection String | Repository | File | Risk Level |
|----------|-------------------|------------|------|------------|
| MongoDB | mongodb://*** | org/repo | config.json | High |

## Internal Information Findings

### Source Code
| File | Repository | Content Summary | Risk Level |
|------|------------|-----------------|------------|
| auth.js | org/repo | Authentication logic | Medium |

### Configuration
| File | Repository | Content Summary | Risk Level |
|------|------------|-----------------|------------|
| deployment.yaml | org/repo | K8s configuration | Medium |

## Recommendations
1. Immediately rotate all exposed credentials
2. Implement .gitignore for sensitive files
3. Use environment variables instead of hardcoded secrets
4. Implement pre-commit hooks for secret detection
5. Conduct security awareness training for developers
```

## Labs

### Lab 1: Basic GitHub Search
1. Set up a test GitHub repository with intentional secrets
2. Use GitHub API to search for the secrets
3. Download and analyze found files
4. Document all found credentials

### Lab 2: Commit History Analysis
1. Create commits with secrets and then remove them
2. Search git history for the removed secrets
3. Document the commit history findings
4. Verify if secrets are still valid

### Lab 3: Secret Scanning Tools
1. Install and configure GitLeaks or truffleHog
2. Scan a test repository
3. Analyze the scan results
4. Compare different scanning tools

### Lab 4: Fork Analysis
1. Fork a public repository
2. Add secrets to the fork
3. Search for secrets in forks
4. Document cross-fork exposure

## Ethics

Code repository mining should be conducted ethically:

1. **Authorization**: Only search repositories you have permission to access
2. **Data Handling**: Treat discovered credentials responsibly
3. **No Exploitation**: Do not use found credentials for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of developers mentioned in repositories
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Search GitHub code
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/code?q=target.com"

# Search for AWS keys
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/code?q=AKIA+target.com"

# Search for Stripe keys
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/code?q=sk_live_+target.com"

# Get repository contents
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/repos/OWNER/REPO/contents/path/to/file"

# Search GitLab
curl -s "https://gitlab.com/api/v4/search?scope=blobs&search=target.com"

# Clone and scan repository
git clone --depth 1 https://github.com/org/repo.git /tmp/repo
gitleaks detect -v -r report.json -s /tmp/repo

# Search commit history
git log --all -p | grep -i "password\|secret\|key\|token"

# Search for .env files
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/code?q=filename:.env+target.com"

# Search for config files
curl -s -H "Authorization: token YOUR_TOKEN" "https://api.github.com/search/code?q=filename:config.json+target.com"

# Analyze dependencies
cat package.json | jq '.dependencies, .devDependencies'
```
