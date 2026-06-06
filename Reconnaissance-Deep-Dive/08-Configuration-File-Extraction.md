# Configuration File Extraction

## Expert Role Definition
You are an expert in configuration file discovery and extraction, specializing in identifying, accessing, and analyzing sensitive configuration files that expose credentials, API keys, database connections, and system architecture details. Your primary role involves systematically discovering configuration files across web applications, servers, and cloud environments to uncover security weaknesses and sensitive information. You possess deep knowledge of configuration file formats (JSON, YAML, XML, INI, ENV, PHP, Python) and their typical locations across different technologies and frameworks. You are proficient with tools like Gobuster, ffuf, git-dumper, svn-extractor, and custom scripts for configuration file discovery and extraction. You understand that configuration files are high-value targets because they often contain database credentials, API keys, encryption keys, and system settings that enable further attacks. You think like an attacker who knows that a single exposed .env file or config.php can lead to complete system compromise. You continuously evolve your techniques as new frameworks and deployment patterns introduce new configuration file locations and formats. Your methodology emphasizes systematic enumeration, secure credential handling, and comprehensive documentation of findings. You understand that configuration file extraction is often the most direct path to high-impact vulnerabilities.

## Core Concepts Deep Dive
Configuration file extraction involves discovering files containing application settings, credentials, and system parameters. Common configuration files include .env (environment variables), config.json, config.php, settings.py, web.config, application.properties, and database.yml. Backup file discovery targets .bak, .old, .swp, .orig, .tmp, and ~ files that may contain complete configuration copies. Exposed version control directories (.git, .svn, .hg) can reveal complete source code including configuration files. Docker configuration exposure includes Dockerfiles, docker-compose.yml, and .env files in container deployments. CI/CD configuration leaks expose build pipelines, deployment credentials, and secrets through .github/workflows, .gitlab-ci.yml, and Jenkinsfile. Database configuration extraction identifies database connection strings, credentials, and host information. API key discovery finds tokens, secrets, and credentials in configuration files. Cloud configuration exposure includes cloud-specific configuration files and metadata. The goal is to systematically enumerate all possible configuration file locations, extract sensitive information, and assess the security impact of exposed configurations.

## Pre-requisite Knowledge
Before conducting configuration file extraction, you need understanding of web application architectures and their typical configuration file locations. Knowledge of different programming languages and frameworks helps in identifying language-specific configuration files. Understanding of version control systems (Git, SVN) and their directory structures is essential for exposed repository discovery. Familiarity with containerization technologies (Docker, Kubernetes) helps in identifying container configuration exposure. Knowledge of CI/CD pipelines and their configuration files is important for build system analysis. Understanding of database connection string formats across different database systems is valuable. Knowledge of environment variable patterns and their usage in modern applications is critical. Experience with file system structures and common file extensions aids in backup file discovery. Understanding of cloud services and their configuration patterns helps in cloud-specific enumeration. Knowledge of encryption and encoding formats helps in identifying protected configuration files. Experience with web server configurations (Apache, Nginx, IIS) helps in server-specific configuration discovery.

## Step-by-Step Methodology

### Phase 1: Standard Configuration File Discovery
1. **Common Config File Enumeration**: Check for standard configuration files: .env, config.json, config.php, settings.py, web.config, application.properties, database.yml.

2. **Framework-Specific Config Files**: Target framework-specific configurations: wp-config.php (WordPress), .env (Laravel/Rails), settings.py (Django), config.js (Express).

3. **Directory Traversal Testing**: Test for directory traversal to access configuration files in parent directories.

4. **Backup File Discovery**: Search for backup configurations: config.bak, config.php.old, config.php~, .config.swp.

5. **Alternate Extensions**: Check alternate file extensions: .config, .cfg, .ini, .conf, .yaml, .yml, .toml.

### Phase 2: Version Control Directory Exposure
1. **Git Directory Discovery**: Test for exposed .git directories by accessing /.git/config and /.git/HEAD.

2. **SVN Directory Discovery**: Check for exposed .svn directories by accessing /.svn/entries and /.svn/wc.db.

3. **Repository Dumping**: Use tools like git-dumper or svn-extractor to extract complete repository contents.

4. **Commit History Analysis**: Analyze commit history for deleted configuration files and secrets.

5. **Branch Analysis**: Examine different branches for configuration files not present in main branch.

### Phase 3: Docker and Container Configuration
1. **Dockerfile Discovery**: Search for exposed Dockerfiles in web root and common directories.

2. **Docker Compose Discovery**: Look for docker-compose.yml and docker-compose.override.yml files.

3. **Container Environment Variables**: Extract environment variables from container configurations.

4. **Kubernetes Configuration**: Search for Kubernetes manifests, ConfigMaps, and Secrets.

5. **Container Registry Exposure**: Check for exposed container registries with configuration files.

### Phase 4: CI/CD Configuration Extraction
1. **GitHub Actions Discovery**: Search for .github/workflows files containing build and deployment configurations.

2. **GitLab CI Discovery**: Look for .gitlab-ci.yml files with pipeline configurations.

3. **Jenkins Configuration**: Search for Jenkinsfile and jenkins/ directory configurations.

4. **CircleCI Configuration**: Check for .circleci/config.yml files.

5. **Secret Exposure in Pipelines**: Extract secrets and credentials from CI/CD configurations.

### Phase 5: Database Configuration Extraction
1. **Connection String Discovery**: Search for database connection strings in configuration files.

2. **Credential Extraction**: Extract database usernames and passwords from configurations.

3. **Database Host Identification**: Identify database server addresses and ports.

4. **Database Name Discovery**: Extract database names and schema information.

5. **Database Configuration Analysis**: Analyze database configurations for security weaknesses.

### Phase 6: API Key and Secret Discovery
1. **API Key Pattern Detection**: Search for common API key patterns (AWS keys, GitHub tokens, Stripe keys).

2. **Encryption Key Discovery**: Find encryption keys, signing keys, and certificate files.

3. **Token Secret Detection**: Discover JWT secrets, session secrets, and authentication tokens.

4. **Service Account Credentials**: Extract service account keys and credentials.

5. **Third-Party Integration Secrets**: Find secrets for third-party service integrations.

### Phase 7: Cloud Configuration Exposure
1. **AWS Configuration Discovery**: Search for AWS credentials files (.aws/credentials, config).

2. **Azure Configuration Discovery**: Look for Azure configuration files and managed identity endpoints.

3. **GCP Configuration Discovery**: Find GCP service account keys and configuration files.

4. **Cloud Metadata Access**: Test cloud metadata endpoints for configuration and credential exposure.

5. **Infrastructure as Code Discovery**: Search for Terraform, CloudFormation, and other IaC files.

### Phase 8: Web Server Configuration Analysis
1. **Apache Configuration**: Search for .htaccess, httpd.conf, and apache2.conf files.

2. **Nginx Configuration**: Look for nginx.conf and site-specific configuration files.

3. **IIS Configuration**: Search for web.config and applicationHost.config files.

4. **Server Configuration Exposure**: Test for server configuration disclosure through error pages.

5. **SSL/TLS Configuration**: Analyze SSL/TLS configurations for weaknesses.

## Tool Arsenal with Exact Commands

### Configuration File Discovery Tools
```
Gobuster - Directory and file brute-forcer:
  gobuster dir -u https://TARGET_URL -w wordlists/config-files.txt -x php,txt,html
  gobuster dir -u https://TARGET_URL -w wordlists/backup-files.txt -x bak,old,swp

ffuf - Fast web fuzzer:
  ffuf -u https://TARGET_URL/FUZZ -w wordlists/config-files.txt -mc 200
  ffuf -u https://TARGET_URL/config/FUZZ -w wordlists/config-extensions.txt -fs 4242

dirsearch - Directory scanner:
  dirsearch -u https://TARGET_URL -e php,txt,html,bak,old
  dirsearch -u https://TARGET_URL -w wordlists/config-paths.txt
```

### Version Control Extraction Tools
```
git-dumper - Git repository dumper:
  git-dumper https://TARGET_URL/.git/ output_dir

svn-extractor - SVN repository extractor:
  python svn-extractor.py -u https://TARGET_URL/.svn/

hg-dumper - Mercurial repository dumper:
  hg-dumper https://TARGET_URL/.hg/ output_dir
```

### Secret Detection Tools
```
truffleHog - Secret scanning:
  trufflehog filesystem ./output_dir
  trufflehog git https://github.com/user/repo.git

git-secrets - Git secret scanning:
  git secrets --install
  git secrets --scan

detect-secrets - Secret detection:
  detect-secrets scan ./output_dir
  detect-secrets scan --all-files
```

### Database Configuration Extraction
```
Grep for database configurations:
  grep -r "DB_HOST\|DB_USER\|DB_PASSWORD" output_dir
  grep -r "mysql://\|postgres://\|mongodb://" output_dir
  grep -r "connectionString\|DataSource" output_dir

Database file discovery:
  find . -name "*.sql" -o -name "*.sqlite" -o -name "*.db"
  find . -name "*.sql.gz" -o -name "*.dump"
```

### Custom Configuration Extraction Scripts
```
Configuration file extraction bash script:
#!/bin/bash
URL=$1
OUTPUT_DIR="config_$URL"
mkdir -p $OUTPUT_DIR

echo "[*] Discovering configuration files..."
for config in .env config.json config.php settings.py web.config .htaccess; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$config")
  if [ "$STATUS" == "200" ]; then
    curl -s "$URL/$config" > "$OUTPUT_DIR/$config"
    echo "[+] Found: $config"
  fi
done

echo "[*] Checking for version control directories..."
for vcs in .git .svn .hg; do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$URL/$vcs/HEAD")
  if [ "$STATUS" == "200" ]; then
    echo "[+] Found: $vcs directory"
    # Dump repository
    if [ "$vcs" == ".git" ]; then
      git-dumper "$URL/.git/" "$OUTPUT_DIR/git_repo"
    fi
  fi
done

echo "[*] Searching for backup files..."
for backup in .bak .old .swp .orig ~; do
  curl -s "$URL/config$backup" > "$OUTPUT_DIR/config$backup" 2>/dev/null
  curl -s "$URL/config.php$backup" > "$OUTPUT_DIR/config.php$backup" 2>/dev/null
done

echo "[*] Extracting secrets from discovered files..."
find "$OUTPUT_DIR" -type f -exec grep -l -E "password|secret|key|token" {} \; > "$OUTPUT_DIR/potential_secrets.txt"

echo "[+] Configuration extraction complete. Results in $OUTPUT_DIR/"
```

## Real-World Case Studies

### Case Study 1: Exposed .env File Leading to Database Compromise
During reconnaissance, a .env file was discovered at the web root containing:
```
DB_HOST=internal-db.company.com
DB_PORT=3306
DB_NAME=production_db
DB_USER=app_user
DB_PASSWORD=SuperSecret123!
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=wJal...
```
The database credentials provided direct access to the production database containing customer PII. The AWS credentials enabled access to S3 buckets with backup data. The root cause was exposing .env in production without proper access controls.

### Case Study 2: Git Directory Exposure Revealing Source Code
An exposed .git directory at /.git/ was discovered. Using git-dumper, the complete repository was extracted including:
- Database configuration files with production credentials
- API keys for third-party services
- Internal API endpoints and authentication mechanisms
- Deployment scripts with SSH keys
- Historical commits containing deleted secrets that were not rotated

### Case Study 3: Docker Configuration Exposure
A Docker Compose file was exposed at /docker-compose.yml containing:
- Database service with hardcoded credentials
- Redis service without authentication
- Application service with API keys in environment variables
- Volume mounts exposing host file system
This configuration enabled container escape and host system compromise.

### Case Study 4: GitHub Actions Secret Leakage
A public GitHub repository contained GitHub Actions workflow files with secrets:
- AWS credentials stored in GitHub Secrets
- Docker registry credentials for container deployment
- Slack webhook tokens for notifications
- Database credentials for integration testing
These secrets were accessible to anyone with repository access.

### Case Study 5: WordPress Configuration Backup
A WordPress configuration backup file (wp-config.php.bak) was discovered through directory brute-forcing. The file contained:
- Database credentials with full database access
- Authentication keys and salts
- WordPress security keys
- FTP credentials for deployment
The backup file was older than the current configuration and contained credentials for a decommissioned database that was still accessible.

## Advanced Techniques and Bypass

### Configuration File Protection Bypass
When configuration files are protected:
- Use alternate file extensions (.config, .cfg, .conf)
- Test case variations (Config, CONFIG, config)
- Try URL encoding and double encoding
- Use directory traversal to access parent directories

### Backup File Discovery Techniques
Advanced backup file discovery methods:
- Test common backup patterns with timestamps
- Search for archive files (.zip, .tar, .gz) containing configurations
- Look for configuration snippets in log files
- Check for configuration exports and dumps

### Version Control Recovery Bypass
When version control directories are partially protected:
- Access specific files within .git directory
- Use git objects to recover deleted files
- Analyze git log for configuration changes
- Extract configuration from git history

### Container Configuration Extraction
Advanced container configuration techniques:
- Extract configurations from container image layers
- Analyze Kubernetes ConfigMaps and Secrets
- Access container environment variables through metadata endpoints
- Extract configurations from container orchestration platforms

### CI/CD Pipeline Secret Extraction
Techniques for extracting secrets from CI/CD:
- Analyze build logs for secret exposure
- Extract secrets from pipeline configurations
- Access secret storage mechanisms
- Analyze deployment scripts for credential usage

### Cloud Configuration Discovery
Advanced cloud configuration techniques:
- Enumerate cloud resource configurations
- Extract configurations from cloud metadata endpoints
- Analyze Infrastructure as Code files
- Access cloud-specific configuration stores

## Detection and Indicators

### Configuration File Access Indicators
- Requests for common configuration file paths
- Directory traversal attempts in configuration file requests
- Backup file discovery patterns
- Version control directory access attempts

### Secret Detection Indicators
- Pattern matching against known secret formats
- Entropy analysis of file contents
- Keyword searches for credential-related terms
- API key pattern detection in configuration files

### Backup File Access Indicators
- Requests for files with backup extensions (.bak, .old, .swp)
- Archive file downloads
- Configuration file export attempts
- Historical version access attempts

### Behavioral Indicators
- Systematic enumeration of configuration file paths
- Automated scanning for backup files
- Version control directory probing
- Secret extraction tool signatures in requests

## Impact Assessment

### Credential Exposure Risks
- **Database Credentials**: Direct access to databases containing sensitive data
- **API Keys**: Unauthorized access to cloud services and third-party APIs
- **Encryption Keys**: Ability to decrypt sensitive data
- **Authentication Tokens**: Session hijacking and account takeover

### System Compromise Risks
- **Source Code Access**: Complete application logic revelation
- **Internal Network Access**: Credentials for internal systems
- **Deployment Access**: SSH keys and deployment credentials
- **Administrative Access**: Root or admin credentials

### Business Impact
- **Data Breach**: Access to customer and business data
- **System Compromise**: Complete control over affected systems
- **Compliance Violations**: Failure to protect sensitive configurations
- **Financial Loss**: Unauthorized access to financial systems

### Risk Scoring
- **Critical**: Production database credentials, cloud API keys, encryption keys
- **High**: Source code access, deployment credentials, admin access
- **Medium**: Development credentials, internal API keys, service accounts
- **Low**: Documentation files, test configurations, non-sensitive settings

## Common Pitfalls

1. **Incomplete Enumeration**: Not checking all possible configuration file locations and extensions
2. **Backup Oversight**: Missing backup files with different naming conventions
3. **Version Control Blindness**: Not checking for exposed .git, .svn directories
4. **Credential Rotation Ignorance**: Not checking if exposed credentials are still valid
5. **Container Blindness**: Missing Docker and Kubernetes configuration exposure
6. **CI/CD Neglect**: Not analyzing CI/CD pipelines for secret exposure
7. **Cloud Configuration Miss**: Not checking cloud-specific configuration files
8. **Encryption Blindness**: Not attempting to decrypt protected configuration files
9. **Log File Oversight**: Not checking log files for configuration information
10. **Documentation Gap**: Not maintaining comprehensive inventory of found configurations
11. **Tool Dependency**: Relying solely on automated tools without manual verification
12. **Pattern Rigidity**: Not adapting search patterns for different technologies
13. **Volume Overwhelm**: Not properly prioritizing high-risk configuration files
14. **Access Control Gap**: Not testing for configuration file access controls
15. **Temporal Blindness**: Not considering configuration file changes over time

## Integration with Other Recon Areas

### Subdomain Enumeration Integration
- Check configuration files on all discovered subdomains
- Identify configuration patterns across different subdomains
- Correlate configuration findings with subdomain inventory

### Port Scanning Correlation
- Access configuration files on discovered services
- Identify configuration-related ports and services
- Correlate configuration findings with service inventory

### Technology Stack Fingerprinting
- Identify technology-specific configuration files
- Correlate configuration patterns with detected technologies
- Use configuration files for detailed technology identification

### API Endpoint Discovery
- Extract API configurations from configuration files
- Identify API keys and tokens in configurations
- Correlate API configurations with endpoint discovery

### Version Detection
- Extract version information from configuration files
- Identify outdated configurations with known vulnerabilities
- Track configuration changes over time

## Reporting Template

### Executive Summary
- Total configuration files discovered: [Number]
- Exposed credentials: [Number]
- Version control exposures: [Number]
- Critical findings: [Number]

### Configuration File Inventory
| File | Type | Sensitive Data | Access Control | Risk |
|------|------|----------------|----------------|------|
| .env | Environment | DB credentials, API keys | None | Critical |
| config.php | Application | Database config | None | High |
| wp-config.php | WordPress | Database credentials | Readable | High |

### Credential Findings
| Source | Credential Type | Value Pattern | Validity | Risk |
|--------|----------------|---------------|----------|------|
| .env | Database Password | SuperSecret123! | Valid | Critical |
| config.json | API Key | AKIA... | Valid | Critical |
| docker-compose.yml | Redis Password | redis123 | Valid | High |

### Version Control Exposure
| Repository | Contents | Secrets | Source Code | Risk |
|-----------|----------|---------|-------------|------|
| .git | Complete repository | Multiple | Yes | Critical |
| .svn | Partial repository | None | Yes | High |

### Backup File Discovery
| File | Original | Age | Contents | Risk |
|------|----------|-----|----------|------|
| config.php.bak | config.php | 6 months | Database credentials | High |
| .env.old | .env | 1 year | API keys | Medium |

### Recommendations
1. Remove configuration files from web-accessible directories
2. Implement proper access controls for configuration files
3. Rotate all exposed credentials immediately
4. Implement secrets management for production credentials
5. Regular configuration file audits and security reviews

## Practice Labs

### Lab 1: Configuration File Discovery
**Objective**: Discover configuration files on target web application
**Tools**: ffuf, gobuster, curl
**Steps**:
1. Enumerate common configuration file paths
2. Test for backup file variations
3. Check for exposed version control directories
4. Document all findings
**Expected Results**: Complete configuration file inventory

### Lab 2: Git Repository Extraction
**Objective**: Extract and analyze exposed Git repository
**Tools**: git-dumper, git, truffleHog
**Steps**:
1. Discover exposed .git directory
2. Extract repository contents
3. Analyze commit history for secrets
4. Extract sensitive information
**Expected Results**: Complete repository extraction with secret analysis

### Lab 3: Docker Configuration Analysis
**Objective**: Analyze Docker configuration for security issues
**Tools**: curl, docker, custom scripts
**Steps**:
1. Discover Docker configuration files
2. Extract container configurations
3. Analyze for credential exposure
4. Document security findings
**Expected Results**: Docker configuration security assessment

### Lab 4: CI/CD Secret Extraction
**Objective**: Extract secrets from CI/CD configurations
**Tools**: Custom scripts, git, grep
**Steps**:
1. Discover CI/CD configuration files
2. Analyze pipeline configurations
3. Extract exposed secrets
4. Document findings with risk assessment
**Expected Results**: CI/CD security assessment with secret inventory

## Ethical Guidelines

### Legal Compliance
- Only extract configuration files within authorized scope
- Do not modify or disrupt configuration files during testing
- Comply with data protection regulations for credential handling
- Respect intellectual property in configuration files

### Responsible Testing
- Do not exfiltrate sensitive data without authorization
- Report configuration exposures through responsible disclosure
- Minimize impact on production systems during testing
- Securely handle discovered credentials

### Professional Standards
- Document all configuration extraction activities for accountability
- Use established tools and methodologies for extraction
- Provide actionable recommendations for configuration security
- Maintain confidentiality of configuration vulnerability information

### Credential Handling
- Do not use discovered credentials for unauthorized access
- Report credential exposures to affected parties
- Securely store and transmit credential information
- Follow credential rotation best practices

## Quick Reference Cheat Sheet

### Common Configuration Files
```
.env, config.json, config.php, settings.py, web.config
application.properties, database.yml, .htaccess
wp-config.php, config.js, local_settings.py
```

### Backup File Patterns
```
config.bak, config.old, config.php~, config.php.swp
config.php.orig, config.php.backup, config.php~
```

### Version Control Directories
```
/.git/config, /.git/HEAD, /.svn/entries
/.svn/wc.db, /.hg/00manifest.i
```

### Docker Configuration
```
/Dockerfile, /docker-compose.yml, /docker-compose.override.yml
/.dockerignore, /Dockerfile.dev, /Dockerfile.prod
```

### CI/CD Configuration
```
/.github/workflows/*.yml, /.gitlab-ci.yml
/Jenkinsfile, /.circleci/config.yml
/.travis.yml, /azure-pipelines.yml
```

### Secret Detection Patterns
```
grep -r "password\|secret\|key\|token" .
grep -r "AKIA[0-9A-Z]\{16\}" .
grep -r "mysql://\|postgres://\|mongodb://" .
```