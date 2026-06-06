# 13. Backup File Discovery and Exploitation

## Expert Role Definition

You are a seasoned penetration tester specializing in backup file discovery and exploitation. You understand that backup files are among the most dangerous information disclosure vulnerabilities in web applications. You can identify backup file patterns across different operating systems, web servers, and development tools. You approach backup file discovery with systematic precision, understanding that developers, system administrators, and automated processes all create backups that may be inadvertently exposed. You know that a single backup file can contain database credentials, source code, API keys, and internal architecture details that provide a complete roadmap for exploitation. You understand the different backup mechanisms used by various systems including file system snapshots, database dumps, version control exports, and application-specific backup formats. You think like both an administrator who creates backups and an attacker who searches for them. You maintain expertise in backup file naming conventions, storage locations, and content analysis techniques. You know that backup files are often the lowest-hanging fruit in a security assessment because they are frequently overlooked and rarely monitored.

## Core Concepts

### Backup File Fundamentals

Backup files exist because humans and systems need to preserve data. Every backup mechanism creates files that, if exposed, reveal information about the system. Understanding backup file creation patterns helps predict where they might be found.

**User-Created Backups**: Developers often create manual backups before making changes. Common patterns include `index.php.bak`, `config.php.old`, `database.yml.backup`. These files are typically created with simple file copy operations and stored in the same directory as the original.

**System-Created Backups**: Operating systems and applications create automated backups through cron jobs, scheduled tasks, and built-in mechanisms. These may follow standardized naming patterns like `backup_20240101.tar.gz` or `database_dump.sql`.

**Editor Backups**: Text editors create temporary backup files during editing. Vim creates `.swp` files, Emacs creates `~` files, and VS Code creates `.orig` files. These contain the previous version of the file being edited.

**Version Control Exports**: Developers may export repositories or create archives of version control history. These contain complete source code including commit history, branch information, and potentially deleted files.

### Backup File Extensions

Understanding backup file naming conventions helps predict where backups might be found:

- **Common backup extensions**: `.bak`, `.old`, `.orig`, `.save`, `.tmp`, `.backup`
- **Compression formats**: `.gz`, `.tar`, `.zip`, `.rar`, `.7z`
- **Database dumps**: `.sql`, `.dump`, `.sqlite`, `.db`
- **Version control**: `.git`, `.svn`, `.hg`
- **Editor backups**: `.swp`, `.swo`, `~`, `.save`
- **Archive formats**: `.tar.gz`, `.tgz`, `.tar.bz2`

### Backup File Locations

Backup files are stored in predictable locations based on the system and application:

- **Web root**: Directories served by the web server
- **Parent directories**: `../backup`, `../../backup`
- **Temporary directories**: `/tmp`, `/var/tmp`, `/temp`
- **Log directories**: `/var/log`, `logs/`
- **Configuration directories**: `/etc`, `config/`
- **Development directories**: `/dev`, `/staging`, `/test`

### Backup File Content Analysis

Analyzing backup file content reveals the system's architecture and security posture:

- **Source code**: Application logic, algorithms, and business rules
- **Configuration**: Database connections, API keys, service credentials
- **Database structure**: Table schemas, relationships, and constraints
- **User data**: Personal information, credentials, and session data
- **Internal documentation**: Architecture diagrams, deployment guides

## Pre-requisite Knowledge

Before mastering backup file discovery, you should understand common web server directory structures and file handling. Knowledge of operating system backup mechanisms helps predict backup patterns. Familiarity with database management systems and their dump formats is essential for analyzing database backups. Understanding of version control systems helps identify repository exports. Knowledge of common development tools and their backup mechanisms enables targeted discovery.

## Step-by-Step Methodology

### Phase 1: Common Backup Extension Discovery

Test for common backup file extensions across the application.

```bash
# Test common backup extensions
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .bak,.old,.orig,.save,.tmp,.backup -mc 200,301,302,403

# Test for specific file backups
for ext in bak old orig save tmp backup; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/index.php.$ext
done

# Test for database backups
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .sql,.dump,.sqlite,.db,.mysql,.backup -mc 200,301,302,403
```

### Phase 2: Directory-Based Backup Discovery

Search for backup directories and files in common locations.

```bash
# Search for backup directories
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403 -fs 0

# Test common backup directory names
for dir in backup backups backup_db backup_database db_backup db_backups sqlbackup sql_backups dump dumps; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/$dir/
done

# Search for backup files in parent directories
curl -s -o /dev/null -w "%{http_code} " https://target.com/../backup/
curl -s -o /dev/null -w "%{http_code} " https://target.com/../../backup/
```

### Phase 3: Database Backup Discovery

Search for database backup files which may contain credentials and data.

```bash
# Test common database backup names
for name in database db backup dump mysql postgresql; do
    for ext in sql sql.gz tar.gz zip; do
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.$ext
        curl -s -o /dev/null -w "%{http_code} " https://target.com/backup/$name.$ext
    done
done

# Test for database dumps with dates
for date in $(date +%Y%m%d) $(date +%Y-%m-%d) $(date +%Y_%m_%d); do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/backup_$date.sql
done

# Search for database files
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .sql,.sqlite,.db,.mdb,.accdb,.mdb -mc 200,301,302,403
```

### Phase 4: Source Code Backup Discovery

Search for source code backups and archives.

```bash
# Test for source code archives
for name in source src code app application web www html; do
    for ext in zip tar.gz tar.bz2 7z rar; do
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.$ext
        curl -s -o /dev/null -w "%{http_code} " https://target.com/backup/$name.$ext
    done
done

# Test for git repository exports
curl -s -o /dev/null -w "%{http_code} " https://target.com/.git.zip
curl -s -o /dev/null -w "%{http_code} " https://target.com/git.zip
curl -s -o /dev/null -w "%{http_code} " https://target.com/repository.zip
```

### Phase 5: Configuration Backup Discovery

Search for configuration file backups which may contain credentials.

```bash
# Test for configuration backups
for name in config configuration settings env properties; do
    for ext in bak old orig save backup; do
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.$ext
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.php.$ext
    done
done

# Test for environment file backups
curl -s -o /dev/null -w "%{http_code} " https://target.com/.env.bak
curl -s -o /dev/null -w "%{http_code} " https://target.com/.env.old
curl -s -o /dev/null -w "%{http_code} " https://target.com/.env.backup

# Test for WordPress config backups
curl -s -o /dev/null -w "%{http_code} " https://target.com/wp-config.php.bak
curl -s -o /dev/null -w "%{http_code} " https://target.com/wp-config.php.old
curl -s -o /dev/null -w "%{http_code} " https://target.com/wp-config.php.save
```

### Phase 6: Log File Discovery

Search for log files which may contain sensitive information.

```bash
# Test for log files
for name in access error log debug info warning; do
    for ext in log txt; do
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.$ext
        curl -s -o /dev/null -w "%{http_code} " https://target.com/logs/$name.$ext
    done
done

# Test for application-specific logs
curl -s -o /dev/null -w "%{http_code} " https://target.com/app.log
curl -s -o /dev/null -w "%{http_code} " https://target.com/error.log
curl -s -o /dev/null -w "%{http_code} " https://target.com/debug.log

# Search for log directories
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -mc 200,301,302,403 -fs 0
```

### Phase 7: Temporary File Discovery

Search for temporary files created during application processing.

```bash
# Test for temporary files
for name in temp tmp cache session; do
    for ext in "" .tmp .temp .cache; do
        curl -s -o /dev/null -w "%{http_code} " https://target.com/$name$ext
    done
done

# Test for editor backup files
for editor in vim emacs nano; do
    case $editor in
        vim) ext=".swp";;
        emacs) ext="~";;
        nano) ext="~";;
    esac
    curl -s -o /dev/null -w "%{http_code} " https://target.com/index.php$ext
done
```

### Phase 8: Automated Backup Discovery Script

Create a comprehensive backup discovery script.

```bash
#!/bin/bash
# backup_discovery.sh - Automated backup file discovery

TARGET=$1
WORDLIST="/usr/share/seclists/Discovery/Web-Content/common.txt"

echo "=== Backup File Discovery for $TARGET ==="

# Common backup extensions
BACKUP_EXT="bak old orig save tmp backup swp swo"

# Test backup extensions on common files
for file in index config database settings web.config .env; do
    for ext in $BACKUP_EXT; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$file.$ext")
        if [ "$response" != "404" ]; then
            echo "[+] Found: $file.$ext ($response)"
        fi
    done
done

# Test backup directories
BACKUP_DIRS="backup backups backup_db db_backup dump dumps sqlbackup"
for dir in $BACKUP_DIRS; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$dir/")
    if [ "$response" != "404" ]; then
        echo "[+] Found backup directory: $dir/ ($response)"
    fi
done

# Test database backups
DB_NAMES="database db mysql postgresql mongodb"
for name in $DB_NAMES; do
    for ext in sql dump tar.gz zip; do
        response=$(curl -s -o /dev/null -w "%{http_code}" "$TARGET/$name.$ext")
        if [ "$response" != "404" ]; then
            echo "[+] Found database backup: $name.$ext ($response)"
        fi
    done
done
```

## Tool Arsenal with Exact Commands

### ffuf

```bash
# Backup file discovery with extensions
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .bak,.old,.orig,.save,.tmp,.backup -mc 200,301,302,403

# Database backup discovery
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .sql,.dump,.sqlite,.db -mc 200,301,302,403

# Archive backup discovery
ffuf -u https://target.com/FUZZ -w /usr/share/seclists/Discovery/Web-Content/common.txt -e .zip,.tar.gz,.tar.bz2,.7z,.rar -mc 200,301,302,403
```

### gobuster

```bash
# Backup directory discovery
gobuster dir -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt -x bak,old,backup -t 50

# Database backup discovery
gobuster dir -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt -x sql,dump -t 50
```

### Custom Scripts

```bash
# Python backup discovery script
python3 -c "
import requests
target = 'https://target.com'
extensions = ['.bak', '.old', '.orig', '.save', '.tmp', '.backup']
files = ['index', 'config', 'database', 'settings', '.env', 'web.config']

for f in files:
    for ext in extensions:
        url = f'{target}/{f}{ext}'
        r = requests.get(url, verify=False)
        if r.status_code != 404:
            print(f'[+] Found: {f}{ext} ({r.status_code}, {len(r.content)} bytes)')
"
```

### wget

```bash
# Mirror backup directories
wget --mirror --no-parent https://target.com/backup/

# Download specific backup files
wget https://target.com/backup.sql
wget https://target.com/backup.tar.gz

# Download with recursion
wget -r -l 2 https://target.com/backup/
```

### curl

```bash
# Test backup file existence
curl -s -o /dev/null -w "%{http_code}" https://target.com/index.php.bak

# Download backup files
curl -O https://target.com/backup.sql

# Test multiple backup extensions
for ext in bak old orig save; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/config.php.$ext
done
```

### dirsearch

```bash
# Backup file discovery
dirsearch -u https://target.com -e bak,old,orig,save,tmp,backup

# Database backup discovery
dirsearch -u https://target.com -e sql,dump,sqlite,db
```

## Real-World Case Studies

### Case Study 1: WordPress Configuration Backup

During a penetration test of a WordPress site, I discovered `wp-config.php.bak` accessible through the web server. The file contained database credentials, authentication keys, and salts. The backup was created during a migration process when the developer copied the configuration file before making changes. The backup was not removed after the migration was complete. The credentials provided access to the WordPress database containing user information and hashes.

### Case Study 2: Database Dump on Public Server

A web application stored database dumps in a `/backups/` directory that was accessible without authentication. The dumps contained complete database schemas, stored procedures, and sample data including user accounts. The backup files were created by a nightly cron job that exported the database for disaster recovery purposes. The exposure of the database structure revealed the application's data model and potential injection points.

### Case Study 3: Source Code Archive in Web Root

A developer uploaded a compressed archive of the application source code to the web root for remote debugging. The archive contained the complete application including configuration files, API keys, and internal documentation. The archive was password-protected but the password was weak and crackable. The source code revealed multiple vulnerabilities including SQL injection points and hardcoded credentials.

### Case Study 4: Editor Backup Files

Vim swap files (`.swp`) were found for multiple PHP files in the web root. These files contained previous versions of the code that had been modified. The previous versions contained different functionality including debug endpoints and administrative interfaces that had been removed from the current version. The backup files also contained developer comments and TODO items that revealed internal architecture details.

### Case Study 5: Log File Exposure

Application log files were stored in a publicly accessible directory. The logs contained user login attempts, including usernames and passwords that were submitted in clear text. The logs also contained internal error messages that revealed database connection strings and file system paths. The log files were created by the application's error handling mechanism and were intended for internal debugging only.

## Advanced Techniques and Bypass

### Time-Based Backup Discovery

Some backup files are created periodically with timestamps in their names. Testing for time-based patterns can reveal recent backups.

```bash
# Test for date-based backup names
for date in $(date +%Y%m%d) $(date +%Y-%m-%d) $(date +%Y_%m_%d); do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/backup_$date.sql
    curl -s -o /dev/null -w "%{http_code} " https://target.com/backup_$date.tar.gz
done

# Test for version-based names
for version in 1.0 1.1 2.0 2.1; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/app_v$version.tar.gz
done
```

### Compression Bypass

Some backup files are compressed to reduce size. Testing for both compressed and uncompressed versions reveals more results.

```bash
# Test for compressed backups
for ext in gz bz2 xz zip; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/backup.tar.$ext
done

# Test for zip archives
for name in backup source code app; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/$name.zip
done
```

### Hidden File Discovery

Backup files may be hidden files starting with a dot. Testing for hidden files reveals additional content.

```bash
# Test for hidden backup files
for name in .backup .bak .old .save .env; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/$name
done

# Test for hidden directories
for name in .backup .git .svn .hg; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/$name/
done
```

### Recursive Backup Discovery

Search for backups in nested directories and subdirectories.

```bash
# Recursive directory discovery
feroxbuster -u https://target.com -w /usr/share/seclists/Discovery/Web-Content/common.txt -d 3 --extract-links

# Manual recursive search
for dir in $(feroxbuster -u https://target.com -w wordlist.txt -d 2 -q 2>/dev/null | grep 200); do
    for ext in bak old orig save; do
        curl -s -o /dev/null -w "%{http_code} " "$dir/index.php.$ext"
    done
done
```

### Content-Based Backup Discovery

Search for backup files based on content patterns rather than just filenames.

```bash
# Search for files containing database credentials
grep -r "password\|passwd\|pwd" /var/www/html/ 2>/dev/null

# Search for files containing API keys
grep -r "api_key\|apikey\|secret" /var/www/html/ 2>/dev/null

# Search for files containing database connection strings
grep -r "mysql_connect\|mysqli_connect\|PDO" /var/www/html/ 2>/dev/null
```

## Detection and Indicators

### Signs of Backup File Exposure

Monitor for the following indicators:

- Access to files with backup extensions
- Requests for database dump files
- Access to log files and temporary files
- Requests for configuration file backups
- Access to version control directories

### Server-Side Detection Methods

Web servers can detect backup file access through:

- File access logging and monitoring
- Intrusion detection systems monitoring for backup file patterns
- Web Application Firewall rules for backup file access
- File integrity monitoring for backup directories

## Impact Assessment

### Finding Severity Classification

Backup file findings should be classified based on content:

- **Critical**: Database credentials, API keys, private keys in backup files
- **High**: Complete source code, database dumps with user data
- **Medium**: Configuration files, application structure information
- **Low**: Log files, temporary files, editor backups without sensitive data
- **Informational**: Empty backup directories, backup file patterns

## Common Pitfalls

### Not Testing All Backup Extensions

Many testers only test common extensions like `.bak` and `.old`. Testing a comprehensive list of backup extensions including `.save`, `.tmp`, `.backup`, and editor-specific extensions is essential.

### Ignoring Compressed Backups

Compressed backup files (`.tar.gz`, `.zip`, `.rar`) are often overlooked. Testing for both compressed and uncompressed versions provides more complete coverage.

### Not Checking Parent Directories

Backup files are often stored in parent directories or sibling directories. Testing paths like `../backup/` and `../../backup/` can reveal backups outside the web root.

### Forgetting About Log Files

Log files can contain sensitive information including credentials, error messages, and internal details. Testing for log file exposure is essential for complete backup discovery.

### Not Analyzing Backup Content

Finding a backup file is only the first step. Analyzing its content reveals the actual security impact. A backup file with no sensitive content has lower impact than one with database credentials.

## Integration with Other Recon Areas

Backup file discovery integrates with other reconnaissance activities:

- **Source Code Leak Detection**: Finding source code in backup files
- **Configuration File Extraction**: Discovering configuration backups
- **Database Backup Discovery**: Finding database dumps and exports
- **Version Control Analysis**: Identifying repository exports and backups
- **Log File Analysis**: Analyzing exposed log files for intelligence

## Reporting Template

### Backup File Discovery Report

**Executive Summary**: Overview of backup file discovery activities and findings.

**Methodology**: Description of discovery techniques, tools used, and files examined.

**Findings Summary**:
- Total backup files discovered
- Breakdown by type (configuration, database, source code, logs)
- Files with sensitive content
- Files accessible without authentication

**Critical/High Findings**:
For each finding:
- File path and URL
- File type and size
- Content description
- Sensitive data exposed
- Access requirements
- Recommended remediation

## Practice Labs

### Lab 1: Common Backup Extension Discovery

Practice discovering backup files using common extensions and naming patterns.

### Lab 2: Database Backup Discovery

Practice finding database backup files and analyzing their content for credentials.

### Lab 3: Source Code Archive Discovery

Practice finding source code archives and extracting sensitive information.

### Lab 4: Log File Discovery

Practice finding exposed log files and analyzing them for intelligence.

### Lab 5: Automated Backup Discovery

Practice creating and using automated backup discovery scripts.

## Ethical Guidelines

Always obtain explicit authorization before performing backup file discovery. Backup files may contain sensitive data including personal information, credentials, and proprietary code. Accessing or downloading this data without authorization may violate privacy laws and regulations. Report all discovered backup files through responsible disclosure channels.

## Quick Reference Cheat Sheet

### Common Backup Extensions
```
.bak .old .orig .save .tmp .backup
.swp .swo .save ~
.sql .dump .sqlite .db
.zip .tar.gz .tar.bz2 .7z .rar
.log .txt .csv .xml .json
```

### Common Backup Directories
```
backup/ backups/ db_backup/ dump/ dumps/
sqlbackup/ log/ logs/ temp/ tmp/
.old/ .backup/ .bak/ .archive/
```

### Discovery Commands
```bash
# Test backup extensions
for ext in bak old orig save tmp backup; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/file.$ext
done

# Test backup directories
for dir in backup backups dump dumps; do
    curl -s -o /dev/null -w "%{http_code} " https://target.com/$dir/
done

# Download found backups
wget https://target.com/backup.sql
curl -O https://target.com/backup.tar.gz
```