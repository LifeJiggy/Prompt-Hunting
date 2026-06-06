# 15. Git Repository Discovery and Analysis

## Expert Role Definition

You are a specialized security researcher focusing on Git repository discovery and analysis. You understand that exposed Git repositories are among the most critical information disclosure vulnerabilities because they contain the complete development history, including all commits, branches, deleted files, and developer activity. You can identify exposed `.git` directories, extract repository contents using specialized tools, and analyze git history to uncover sensitive information, credentials, and architectural details. You approach Git repository analysis with the systematic precision of a forensic investigator and the creative thinking of an attacker. You know that Git repositories are not just code storage but complete development timelines that reveal how the application evolved, what mistakes were made, and what security vulnerabilities exist. You maintain expertise in Git internals, object database structure, and history analysis techniques. You understand that Git repositories can leak information through multiple vectors including the repository itself, commit history, branch structure, developer patterns, and repository metadata. You think like a developer who uses Git daily and like an attacker who exploits its features for reconnaissance.

## Core Concepts

### Git Repository Fundamentals

Git is a distributed version control system that stores content as objects in a database. Understanding Git internals is essential for analyzing exposed repositories.

**Git Objects**: Git stores four types of objects: blobs (file content), trees (directory structure), commits (snapshots with metadata), and tags (named references to commits). These objects are stored in `.git/objects/` using SHA-1 hashing.

**References**: Branches and tags are pointers to commits stored in `.git/refs/`. The `HEAD` file indicates the current branch. Understanding reference structure helps in identifying all branches and tags.

**Index**: The `.git/index` file contains the staging area state, revealing which files are tracked and their metadata.

**Configuration**: `.git/config` contains repository configuration including remote URLs, user information, and hooks.

### Git Repository Exposure Vectors

Exposed Git repositories can be discovered through:

- **Direct access**: `.git/` directory accessible in web root
- **Partial exposure**: Some Git files accessible while others are restricted
- **Archive creation**: Git repositories exported as ZIP or tar archives
- **Backup files**: Repository exports stored in backup locations
- **Developer tools**: IDE and editor plugins that expose repository information

### Git History Analysis

Git history contains rich information beyond the current code state:

- **Commit messages**: Developer notes revealing internal processes and vulnerabilities
- **Author information**: Developer names, emails, and patterns
- **Deleted files**: Previous versions containing removed functionality
- **File changes**: Evolution of code revealing security improvements or regressions
- **Branch structure**: Development workflow and feature branches

### Git Object Database

Understanding Git's object database structure enables manual analysis when tools are unavailable:

- **Pack files**: Compressed collections of objects in `.git/objects/pack/`
- **Loose objects**: Individual object files in `.git/objects/` directories
- **Object parsing**: Manual parsing of objects reveals content without Git commands

## Pre-requisite Knowledge

Before mastering Git repository analysis, you should understand Git fundamentals including commits, branches, and remotes. Knowledge of Git internals and object database structure enables advanced analysis. Familiarity with common development workflows helps in interpreting commit history. Understanding of web server configurations explains how Git directories become exposed.

## Step-by-Step Methodology

### Phase 1: Git Repository Detection

Identify exposed Git repositories through systematic testing.

```bash
# Test for .git directory
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/HEAD
curl -s -o /dev/null -w "%{http_code}" https://target.com/.git/config

# Test for Git files
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.git/config
curl -s https://target.com/.git/description

# Test for Git web interfaces
curl -s -o /dev/null -w "%{http_code}" https://target.com/git/
curl -s -o /dev/null -w "%{http_code}" https://target.com/gitweb/
curl -s -o /dev/null -w "%{http_code}" https://target.com/cgit/
```

### Phase 2: Git Repository Extraction

Extract the exposed Git repository using specialized tools.

```bash
# Using git-dumper
git-dumper https://target.com/.git/ /tmp/git_dump

# Using gitjacker
gitjacker https://target.com/.git/ --output-dir /tmp/git_dump

# Using dvcs-ripper
rip-git.pl -v https://target.com/.git/ -o /tmp/git_dump

# Manual extraction with wget
wget -r https://target.com/.git/ -P /tmp/git_dump
```

### Phase 3: Git History Analysis

Analyze the extracted repository for sensitive information.

```bash
# View commit history
cd /tmp/git_dump
git log --oneline --all

# View detailed commit information
git log --all --graph --decorate

# Search for commits containing secrets
git log --all -p | grep -A 2 -B 2 "password\|secret\|api_key"

# Find deleted files
git log --all --diff-filter=D --name-only

# View specific commit
git show <commit_hash>

# Search commit messages
git log --all --grep="password"
git log --all --grep="secret"
git log --all --grep="api"
```

### Phase 4: Git Branch Analysis

Analyze all branches for additional information.

```bash
# List all branches
git branch -a

# Switch to specific branch
git checkout -b origin/<branch_name>

# Compare branches
git diff main origin/<branch_name>

# View branch-specific files
git ls-tree -r --name-only origin/<branch_name>
```

### Phase 5: Git Credential Extraction

Search for credentials and secrets in the repository.

```bash
# Search for passwords
grep -r "password" /tmp/git_dump/ --include="*.{py,js,php,rb,yml,json,env,conf,config}"

# Search for API keys
grep -rE "api[_-]?key|apikey|secret" /tmp/git_dump/ --include="*.{py,js,php,rb,yml,json,env,conf,config}"

# Search for private keys
grep -r "BEGIN.*PRIVATE KEY" /tmp/git_dump/

# Search for connection strings
grep -rE "mysql://|postgresql://|mongodb://|redis://" /tmp/git_dump/

# Search for AWS credentials
grep -rE "AKIA[0-9A-Z]{16}" /tmp/git_dump/

# Search for tokens
grep -rE "token|bearer|jwt" /tmp/git_dump/ --include="*.{py,js,php,rb,yml,json,env,conf,config}"
```

### Phase 6: Git Hook Analysis

Analyze Git hooks for additional information and potential vulnerabilities.

```bash
# List Git hooks
ls -la /tmp/git_dump/.git/hooks/

# Examine hook scripts
cat /tmp/git_dump/.git/hooks/pre-commit
cat /tmp/git_dump/.git/hooks/post-commit
cat /tmp/git_dump/.git/hooks/pre-push

# Check for malicious hooks
find /tmp/git_dump/.git/hooks/ -type f -executable
```

### Phase 7: Git Submodule Analysis

Analyze Git submodules for additional repository references.

```bash
# Check for submodules
cat /tmp/git_dump/.gitmodules

# Initialize and update submodules
cd /tmp/git_dump
git submodule init
git submodule update

# List submodule URLs
git config --file .gitmodules --list
```

### Phase 8: Gitignore Analysis

Analyze `.gitignore` for information about project structure and sensitive files.

```bash
# View gitignore
cat /tmp/git_dump/.gitignore

# Analyze ignored patterns
grep -v "^#" /tmp/git_dump/.gitignore | grep -v "^$"

# Search for sensitive patterns in gitignore
grep -i "secret\|password\|key\|token\|credential" /tmp/git_dump/.gitignore
```

## Tool Arsenal with Exact Commands

### git-dumper

```bash
# Dump exposed git repository
git-dumper https://target.com/.git/ /tmp/git_dump

# Dump with specific depth
git-dumper --depth 100 https://target.com/.git/ /tmp/git_dump

# Dump with timeout
git-dumper --timeout 30 https://target.com/.git/ /tmp/git_dump
```

### gitjacker

```bash
# Extract git repository
gitjacker https://target.com/.git/ --output-dir /tmp/git_dump

# Extract with specific extensions
gitjacker https://target.com/.git/ --output-dir /tmp/git_dump --extensions php,py,js
```

### dvcs-ripper

```bash
# Rip git repository
rip-git.pl -v https://target.com/.git/ -o /tmp/git_dump

# Rip with specific options
rip-git.pl -v -s https://target.com/.git/ -o /tmp/git_dump
```

### Git Commands

```bash
# View all commits
git log --oneline --all

# View detailed log
git log --all --graph --decorate --stat

# Search for secrets
git log --all -p | grep -A 3 -B 3 "password"

# Find deleted files
git log --all --diff-filter=D --name-only

# View specific file at specific commit
git show <commit>:<file_path>

# Compare commits
git diff <commit1> <commit2>

# Search for patterns in history
git log --all -S "password" --oneline
git log --all -S "api_key" --oneline
git log --all -S "secret" --oneline
```

### trufflehog

```bash
# Scan for secrets
trufflehog git file:///tmp/git_dump

# Scan with custom regex
trufflehog git file:///tmp/git_dump --regex "target-api-key-[a-zA-Z0-9]{32}"

# Scan remote repository
trufflehog git https://github.com/target/repo
```

### gitleaks

```bash
# Scan for secrets
gitleaks detect -s /tmp/git_dump -v

# Scan with custom config
gitleaks detect -s /tmp/git_dump -c gitleaks.toml

# Scan specific commit range
gitleaks detect -s /tmp/git_dump --log-opts="--since=2024-01-01"
```

### GitPython Scripts

```bash
# Python script for git analysis
python3 -c "
import git
repo = git.Repo('/tmp/git_dump')
for commit in repo.iter_commits():
    print(f'{commit.hexsha[:8]} {commit.author.name} {commit.message}')
"

# Search for secrets in git history
python3 -c "
import git
import re
repo = git.Repo('/tmp/git_dump')
patterns = [
    r'password\s*[=:]\s*[\"'\''](.*?)[\"'\'']',
    r'api[_-]?key\s*[=:]\s*[\"'\''](.*?)[\"'\'']',
    r'secret\s*[=:]\s*[\"'\''](.*?)[\"'\'']'
]
for commit in repo.iter_commits():
    for pattern in patterns:
        matches = re.findall(pattern, commit.diff.decode(), re.IGNORECASE)
        for match in matches:
            print(f'{commit.hexsha[:8]}: {match}')
"
```

## Real-World Case Studies

### Case Study 1: Exposed Git Repository with Database Credentials

During a web application assessment, I discovered an exposed `.git` directory at `https://target.com/.git/`. Using `git-dumper`, I extracted the complete repository. Analysis revealed that a developer had committed database credentials in a configuration file that was later removed from the repository. However, the credentials remained in the Git history. The credentials provided access to a PostgreSQL database containing user information, payment data, and internal communications. The root cause was a lack of pre-commit hooks and code review processes to prevent secrets from being committed.

### Case Study 2: Git History Revealing Deleted Admin Panel

An exposed Git repository revealed that a previous version of the application contained an administrative panel that had been removed from the current version. The admin panel code was found in the Git history under a commit with the message "remove admin panel for security." Ironically, the removal of the panel from the current code did not remove it from the Git history, and the panel contained hardcoded credentials and SQL injection vulnerabilities. The panel was accessible by checking out the previous commit.

### Case Study 3: Developer Email Harvesting from Git Commits

Analysis of an exposed Git repository revealed the email addresses and names of all developers who had contributed to the project. This information was used for social engineering attacks including targeted phishing and credential stuffing. The developers' email addresses were found in the commit author information, and their work patterns were revealed through commit timestamps and messages. This information was combined with LinkedIn data to create convincing phishing campaigns.

### Case Study 4: Git Hooks Executing Malicious Code

An exposed Git repository contained a pre-commit hook that executed arbitrary code. The hook was designed to run linting tools but had been modified to also execute a reverse shell. The hook was triggered when developers ran `git commit`, providing persistent access to developer machines. The malicious hook was discovered through analysis of the `.git/hooks/` directory and was traced back to a compromised developer account.

### Case Study 5: Git Submodule Supply Chain Attack

An exposed Git repository revealed submodules pointing to compromised third-party libraries. The submodule configuration contained URLs to repositories that had been taken over by attackers. When developers ran `git submodule update`, malicious code was downloaded and executed. The supply chain attack was discovered through analysis of the `.gitmodules` file and investigation of the submodule URLs.

## Advanced Techniques and Bypass

### Git Object Database Manual Analysis

When tools are unavailable, manual analysis of the Git object database is possible.

```bash
# Find loose objects
find /tmp/git_dump/.git/objects/ -type f | head -20

# Examine object type
cat /tmp/git_dump/.git/objects/ab/cdef1234567890 | head -c 100

# Decompress object
zlib-flate -uncompress < /tmp/git_dump/.git/objects/ab/cdef1234567890

# List pack file contents
git verify-pack -v /tmp/git_dump/.git/objects/pack/pack-*.idx | head -20
```

### Git History Rewrite Detection

Detect if Git history has been rewritten or rebased.

```bash
# Check for rewritten history
git log --all --oneline | head -20

# Look for orphaned commits
git fsck --unreachable

# Check reflog
git reflog --all

# Find dangling commits
git fsck --lost-found
```

### Advanced Secret Detection

Use advanced techniques to detect secrets in Git history.

```bash
# Search for secrets in specific file types
git log --all -p -- "*.py" | grep -A 3 -B 3 "password"

# Search for high-entropy strings
git log --all -p | grep -E "[a-zA-Z0-9]{32,}"

# Search for private keys
git log --all -p | grep -A 5 "BEGIN.*PRIVATE KEY"

# Search for JWT tokens
git log --all -p | grep -E "eyJ[a-zA-Z0-9_-]*\.eyJ[a-zA-Z0-9_-]*\.[a-zA-Z0-9_-]*"
```

### Git Branch Enumeration

Enumerate all branches including remote branches.

```bash
# List all remote branches
git branch -r

# List all branches including remote
git branch -a

# Show branch tips
git show-ref

# Search for branches with specific names
git branch -a | grep -i "dev\|test\|staging"
```

### Git Tag Analysis

Analyze Git tags for release information and potential secrets.

```bash
# List all tags
git tag

# Show tag details
git show <tag_name>

# List tags with annotations
git tag -n

# Search for tags containing secrets
git tag -l | while read tag; do git show $tag | grep -i "password\|secret"; done
```

## Detection and Indicators

### Signs of Git Repository Exposure

Monitor for the following indicators:

- Requests for `.git/` directory and its contents
- Requests for Git objects and pack files
- Access to Git configuration files
- Requests for Git web interfaces

### Server-Side Detection Methods

Web servers can detect Git repository exposure through:

- Directory access monitoring for `.git` directories
- File access logging for Git objects
- Intrusion detection systems monitoring for Git patterns
- File integrity monitoring for Git directories

## Impact Assessment

### Finding Severity Classification

Git repository findings should be classified based on content:

- **Critical**: Hardcoded credentials, API keys, private keys in Git history
- **High**: Complete application source code, database schemas, internal architecture
- **Medium**: Developer information, commit history, deleted files without sensitive content
- **Low**: Public repository code, framework-specific files
- **Informational**: Git configuration, repository metadata

## Common Pitfalls

### Not Analyzing Complete History

Many testers extract a Git repository but only analyze the current state. The complete history including deleted files and previous versions often contains more sensitive information.

### Ignoring Deleted Files

Deleted files remain in Git history and may contain sensitive information that was removed from the current version. Always check for deleted files using `git log --all --diff-filter=D`.

### Overlooking Git Hooks

Git hooks can execute arbitrary code and may be used for malicious purposes. Always examine the `.git/hooks/` directory for suspicious scripts.

### Not Checking Submodules

Git submodules may point to external repositories that contain additional information or may be compromised. Always check `.gitmodules` for submodule references.

### Forgetting About Git Configuration

Git configuration files contain user information, remote URLs, and other metadata that can be valuable for reconnaissance.

## Integration with Other Recon Areas

Git repository analysis integrates with other reconnaissance activities:

- **Source Code Leak Detection**: Finding source code through Git repositories
- **Configuration File Extraction**: Discovering configuration files in Git history
- **API Endpoint Discovery**: Identifying API endpoints from source code
- **Technology Stack Fingerprinting**: Understanding the technology stack from source code
- **Employee-Linked Assets**: Identifying developers through Git commit information

## Reporting Template

### Git Repository Analysis Report

**Executive Summary**: Overview of Git repository exposure and findings.

**Methodology**: Description of extraction techniques, tools used, and analysis performed.

**Findings Summary**:
- Git repository accessibility
- Total commits analyzed
- Sensitive information discovered
- Developer information exposed

**Critical/High Findings**:
For each finding:
- Information type and location
- Content description
- Potential security implications
- Recommended remediation

## Practice Labs

### Lab 1: Git Repository Extraction

Practice extracting exposed Git repositories using various tools.

### Lab 2: Git History Analysis

Practice analyzing Git history for sensitive information and deleted files.

### Lab 3: Secret Detection

Practice using automated tools to detect secrets in Git repositories.

### Lab 4: Git Hook Analysis

Practice analyzing Git hooks for malicious content.

### Lab 5: Git Submodule Investigation

Practice investigating Git submodules for additional information.

## Ethical Guidelines

Git repository analysis should only be performed on repositories you own or have authorization to access. Extracting and analyzing Git repositories without authorization may violate intellectual property laws and terms of service. Report all discovered Git repository exposures through responsible disclosure channels.

## Quick Reference Cheat Sheet

### Git Repository Detection
```bash
curl -s https://target.com/.git/HEAD
curl -s https://target.com/.git/config
curl -s https://target.com/.git/description
```

### Git Extraction Tools
```bash
git-dumper https://target.com/.git/ /tmp/git_dump
gitjacker https://target.com/.git/ --output-dir /tmp/git_dump
rip-git.pl -v https://target.com/.git/ -o /tmp/git_dump
```

### Git Analysis Commands
```bash
git log --oneline --all                    # View all commits
git log --all --diff-filter=D --name-only # Find deleted files
git log --all -S "password" --oneline     # Search for secrets
git branch -a                              # List all branches
git show <commit>                          # View specific commit
git diff <commit1> <commit2>              # Compare commits
```

### Secret Detection Patterns
```bash
grep -rE "password\s*=\s*['\"].*['\"]" .
grep -rE "api[_-]?key\s*=\s*['\"].*['\"]" .
grep -r "BEGIN.*PRIVATE KEY" .
grep -rE "AKIA[0-9A-Z]{16}" .
```