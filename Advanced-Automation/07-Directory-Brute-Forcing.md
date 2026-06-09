# Automated Directory Brute-Forcing — Complete Automation Guide

## Expert Role

You are a senior penetration tester specializing in automated directory and file brute-forcing. You have extensive experience discovering hidden directories, files, and resources on web servers. You understand the intricacies of web server configurations, file systems, and access controls. You have mastered the art of designing efficient brute-forcing strategies that maximize coverage while minimizing time and resource consumption. Your expertise includes understanding different web server types (Apache, Nginx, IIS), file extensions, and response patterns. You can design and implement automated brute-forcing pipelines that integrate with reconnaissance and vulnerability scanning workflows. You understand the differences between wordlist-based brute-forcing, recursive scanning, and virtual host discovery. You are proficient in using multiple brute-forcing tools and combining their results for comprehensive coverage. You stay current with the latest brute-forcing techniques, tool updates, and emerging web server configurations. You understand the legal and ethical implications of brute-forcing and always operate within authorized boundaries.

## Core Concepts

Directory brute-forcing is the process of discovering hidden directories, files, and resources on web servers. This reconnaissance technique reveals application structure, configuration files, and potentially sensitive resources.

Web servers organize content in hierarchical directory structures. Directories may contain files, subdirectories, or serve as virtual hosts. Understanding directory structure aids in targeted brute-forcing.

File extensions indicate file types and potential content. Common extensions include .html, .php, .js, .txt, .xml, and .json. Extension detection helps identify different resource types.

Virtual hosting allows multiple domains on a single server. Virtual host discovery reveals additional applications and content. Virtual hosts may have different directory structures.

Response filtering analyzes server responses to identify valid resources. Different response codes, sizes, and content indicate resource availability. Response analysis helps prioritize findings.

Wildcard detection identifies servers that respond to all requests. Wildcard responses can create false positives in brute-forcing results. Wildcard handling is essential for accurate discovery.

Recursive scanning discovers nested directories and files. This approach expands coverage exponentially but increases time consumption. Recursive scanning should be depth-limited for efficiency.

Rate limiting controls brute-forcing speed. Appropriate rate limits avoid detection and denial of service. Rate limiting should balance speed with stealth.

Custom wordlists improve brute-forcing accuracy. Target-specific wordlists include application-relevant terms. Wordlist customization increases discovery probability.

## Prerequisites

- Linux-based operating system (Kali Linux recommended)
- ffuf for web fuzzing
- dirsearch for directory brute-forcing
- feroxbuster for recursive scanning
- gobuster for directory and DNS brute-forcing
- dirb for basic directory scanning
- curl for HTTP requests
- jq for JSON processing
- Understanding of web server configurations
- Familiarity with HTTP protocols and responses
- Text editor for customizing wordlists
- Git for cloning tool repositories
- Standard Unix utilities (sort, uniq, grep, awk)
- Knowledge of common directory patterns
- Understanding of response codes and content types

## Methodology

### Step 1: Initial Reconnaissance

Identify target web servers and their configurations. Check for common directories and files. Analyze robots.txt, sitemap.xml, and other discovery files. Map application structure from available information.

### Step 2: Wordlist Preparation

Create or download directory wordlists. Customize wordlists based on target technology. Include common directories and files. Add technology-specific paths. Organize wordlists by category.

### Step 3: Basic Directory Scanning

Use dirb for initial directory discovery. Test common directory patterns. Verify discovered directories. Document all findings. Create baseline directory list.

### Step 4: Advanced Brute-Forcing

Deploy ffuf for comprehensive scanning. Use feroxbuster for recursive scanning. Implement virtual host discovery. Test for different file extensions. Document all findings.

### Step 5: Response Analysis

Analyze server responses for resource validity. Identify different response patterns. Filter false positives based on responses. Prioritize findings based on impact. Document response patterns.

### Step 6: Wildcard Detection and Handling

Detect wildcard DNS responses. Filter wildcard results from scanning. Implement wildcard handling techniques. Document wildcard configurations. Adjust scanning based on wildcards.

### Step 7: Recursive Scanning

Implement recursive directory scanning. Set appropriate recursion depth. Monitor scan progress and performance. Document recursive findings. Limit recursion for efficiency.

### Step 8: File Extension Testing

Test for different file extensions. Identify backup files, configuration files, and source code. Test for common extensions (.php, .html, .js, .txt, .xml). Document extension-based findings.

### Step 9: Result Deduplication

Merge results from multiple tools. Remove duplicate findings. Validate findings through manual testing. Create comprehensive directory database. Document all validated findings.

### Step 10: Integration with Vulnerability Scanning

Feed discovered directories into vulnerability scanners. Prioritize scanning based on directory sensitivity. Correlate findings with other testing. Automate ongoing directory discovery. Document integration points.

## Tool Arsenal

### ffuf — Web Fuzzer

```bash
# Basic directory brute-forcing
ffuf -u https://target.com/FUZZ -w wordlist.txt

# With file extension
ffuf -u https://target.com/FUZZ -w wordlist.txt -e .php,.html,.js,.txt

# Recursive scanning
ffuf -u https://target.com/FUZZ -w wordlist.txt -recursion -recursion-depth 2

# Rate limiting
ffuf -u https://target.com/FUZZ -w wordlist.txt -rate 100

# Output formats
ffuf -u https://target.com/FUZZ -w wordlist.txt -o output.json -of json
ffuf -u https://target.com/FUZZ -w wordlist.txt -o output.csv -of csv
ffuf -u https://target.com/FUZZ -w wordlist.txt -o output.html -of html

# Verbose
ffuf -u https://target.com/FUZZ -w wordlist.txt -v

# Silent
ffuf -u https://target.com/FUZZ -w wordlist.txt -s

# Filter responses
ffuf -u https://target.com/FUZZ -w wordlist.txt -fc 404
ffuf -u https://target.com/FUZZ -w wordlist.txt -fs 0
ffuf -u https://target.com/FUZZ -w wordlist.txt -fl 10

# Match responses
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200
ffuf -u https://target.com/FUZZ -w wordlist.txt -ms "success"
ffuf -u https://target.com/FUZZ -w wordlist.txt -ml 50

# Custom headers
ffuf -u https://target.com/FUZZ -w wordlist.txt -H "Authorization: Bearer token"
ffuf -u https://target.com/FUZZ -w wordlist.txt -H "Content-Type: application/json"

# Custom cookies
ffuf -u https://target.com/FUZZ -w wordlist.txt -b "session=abc123"

# Custom proxy
ffuf -u https://target.com/FUZZ -w wordlist.txt -x http://127.0.0.1:8080

# Custom timeout
ffuf -u https://target.com/FUZZ -w wordlist.txt -t 10

# Custom threads
ffuf -u https://target.com/FUZZ -w wordlist.txt -t 50

# Custom delay
ffuf -u https://target.com/FUZZ -w wordlist.txt -p 1

# Custom retries
ffuf -u https://target.com/FUZZ -w wordlist.txt -retries 3

# Custom follow redirects
ffuf -u https://target.com/FUZZ -w wordlist.txt -fr

# Custom user agent
ffuf -u https://target.com/FUZZ -w wordlist.txt -ua "Mozilla/5.0"

# Custom accept header
ffuf -u https://target.com/FUZZ -w wordlist.txt -ac "application/json"

# Custom content type
ffuf -u https://target.com/FUZZ -w wordlist.txt -ct "application/json"

# Custom auth
ffuf -u https://target.com/FUZZ -w wordlist.txt -auth user:password

# Custom SSL
ffuf -u https://target.com/FUZZ -w wordlist.txt -k

# Custom HTTP version
ffuf -u https://target.com/FUZZ -w wordlist.txt -http2

# Custom DNS
ffuf -u https://target.com/FUZZ -w wordlist.txt -dns-mode custom

# Custom interface
ffuf -u https://target.com/FUZZ -w wordlist.txt -i eth0

# Custom source port
ffuf -u https://target.com/FUZZ -w wordlist.txt -sp 8080

# Custom resolve
ffuf -u https://target.com/FUZZ -w wordlist.txt -rec target.com:443:192.168.1.1

# Custom preloaded
ffuf -u https://target.com/FUZZ -w wordlist.txt -pl

# Custom happy eyeballs
ffuf -u https://target.com/FUZZ -w wordlist.txt -he

# Custom TLS version
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls13

# Custom SSL
ffuf -u https://target.com/FUZZ -w wordlist.txt -ssl

# Custom no SSL
ffuf -u https://target.com/FUZZ -w wordlist.txt -no-ssl

# Custom insecure
ffuf -u https://target.com/FUZZ -w wordlist.txt -k

# Custom cert
ffuf -u https://target.com/FUZZ -w wordlist.txt -cert cert.pem

# Custom key
ffuf -u https://target.com/FUZZ -w wordlist.txt -key key.pem

# Custom CA
ffuf -u https://target.com/FUZZ -w wordlist.txt -ca ca.pem

# Custom pin
ffuf -u https://target.com/FUZZ -w wordlist.txt -pin key.pub

# Custom HPKP
ffuf -u https://target.com/FUZZ -w wordlist.txt -hpkp pin

# Custom HPKP backup
ffuf -u https://target.com/FUZZ -w wordlist.txt -hkp-backup pin

# Custom CRL
ffuf -u https://target.com/FUZZ -w wordlist.txt -crl crl.pem

# Custom issuer
ffuf -u https://target.com/FUZZ -w wordlist.txt -cert-status

# Custom OCSP
ffuf -u https://target.com/FUZZ -w wordlist.txt -ocsp

# Custom stapling
ffuf -u https://target.com/FUZZ -w wordlist.txt -stapling

# Custom ALPN
ffuf -u https://target.com/FUZZ -w wordlist.txt -alpn

# Custom NPN
ffuf -u https://target.com/FUZZ -w wordlist.txt -npn

# Custom SNI
ffuf -u https://target.com/FUZZ -w wordlist.txt -sni

# Custom TLS13
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls13

# Custom TLS12
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls12

# Custom TLS11
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls11

# Custom TLS10
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls10

# Custom TLS
ffuf -u https://target.com/FUZZ -w wordlist.txt -tls

# Custom SSL
ffuf -u https://target.com/FUZZ -w wordlist.txt -ssl

# Custom no SSL
ffuf -u https://target.com/FUZZ -w wordlist.txt -no-ssl

# Custom insecure
ffuf -u https://target.com/FUZZ -w wordlist.txt -k
```

Flags explained:
- `-u`: Target URL with FUZZ keyword
- `-w`: Wordlist file
- `-e`: File extensions to append
- `-recursion`: Enable recursive scanning
- `-recursion-depth`: Recursive depth
- `-rate`: Rate limiting
- `-o`: Output file
- `-of`: Output format
- `-v`: Verbose mode
- `-s`: Silent mode
- `-fc`: Filter by response code
- `-fs`: Filter by response size
- `-fl`: Filter by line count
- `-mc`: Match by response code
- `-ms`: Match by response string
- `-ml`: Match by line count
- `-t`: Number of threads
- `-p`: Delay between requests
- `-retries`: Number of retries
- `-fr`: Follow redirects
- `-ua`: Custom user agent
- `-ac`: Accept header
- `-ct`: Content-Type header
- `-auth`: Basic authentication
- `-k`: Skip SSL verification
- `-http2`: Use HTTP/2
- `-dns-mode`: DNS mode
- `-i`: Network interface
- `-sp`: Source port
- `-rec`: Custom resolve
- `-pl`: Preloaded
- `-he`: Happy eyeballs
- `-tls13`: TLS 1.3
- `-ssl`: SSL
- `-no-ssl`: No SSL
- `-cert`: Client certificate
- `-key`: Client key
- `-ca`: CA certificate
- `-pin`: Pinned public key
- `-hpkp`: HPKP pin
- `-hkp-backup`: HPKP backup
- `-crl`: CRL file
- `-cert-status`: Certificate status
- `-ocsp`: OCSP stapling
- `-stapling`: Stapling
- `-alpn`: ALPN
- `-npn`: NPN
- `-sni`: SNI
- `-tls12`: TLS 1.2
- `-tls11`: TLS 1.1
- `-tls10`: TLS 1.0

### dirsearch — Directory Scanner

```bash
# Basic directory scanning
dirsearch -u https://target.com -w wordlist.txt

# With extensions
dirsearch -u https://target.com -e php,html,js,txt

# Recursive scanning
dirsearch -u https://target.com -r -R 3

# Rate limiting
dirsearch -u https://target.com --rate-limit 100

# Output formats
dirsearch -u https://target.com -o output.json -f json
dirsearch -u https://target.com -o output.csv -f csv
dirsearch -u https://target.com -o output.html -f html

# Verbose
dirsearch -u https://target.com -v

# Silent
dirsearch -u https://target.com -s

# Filter responses
dirsearch -u https://target.com --exclude-status 404

# Match responses
dirsearch -u https://target.com --include-status 200

# Custom headers
dirsearch -u https://target.com -H "Authorization: Bearer token"
dirsearch -u https://target.com -H "Content-Type: application/json"

# Custom cookies
dirsearch -u https://target.com -c "session=abc123"

# Custom proxy
dirsearch -u https://target.com -x http://127.0.0.1:8080

# Custom timeout
dirsearch -u https://target.com --timeout 10

# Custom threads
dirsearch -u https://target.com -t 50

# Custom delay
dirsearch -u https://target.com --delay 1

# Custom retries
dirsearch -u https://target.com --retries 3

# Custom follow redirects
dirsearch -u https://target.com -L

# Custom user agent
dirsearch -u https://target.com -a "Mozilla/5.0"

# Custom accept header
dirsearch -u https://target.com -H "Accept: application/json"

# Custom content type
dirsearch -u https://target.com -H "Content-Type: application/json"

# Custom auth
dirsearch -u https://target.com --auth user:password

# Custom SSL
dirsearch -u https://target.com -k

# Custom HTTP version
dirsearch -u https://target.com --http2

# Custom DNS
dirsearch -u https://target.com --dns-mode custom

# Custom interface
dirsearch -u https://target.com -i eth0

# Custom source port
dirsearch -u https://target.com --source-port 8080

# Custom resolve
dirsearch -u https://target.com --resolve target.com:443:192.168.1.1

# Custom preloaded
dirsearch -u https://target.com --preloaded

# Custom happy eyeballs
dirsearch -u https://target.com --happy-eyeballs

# Custom TLS version
dirsearch -u https://target.com --tls13

# Custom SSL
dirsearch -u https://target.com --ssl

# Custom no SSL
dirsearch -u https://target.com --no-ssl

# Custom insecure
dirsearch -u https://target.com -k

# Custom cert
dirsearch -u https://target.com --cert cert.pem

# Custom key
dirsearch -u https://target.com --key key.pem

# Custom CA
dirsearch -u https://target.com --ca ca.pem

# Custom pin
dirsearch -u https://target.com --pin key.pub

# Custom HPKP
dirsearch -u https://target.com --hpkp pin

# Custom HPKP backup
dirsearch -u https://target.com --hkp-backup pin

# Custom CRL
dirsearch -u https://target.com --crl crl.pem

# Custom issuer
dirsearch -u https://target.com --cert-status

# Custom OCSP
dirsearch -u https://target.com --ocsp

# Custom stapling
dirsearch -u https://target.com --stapling

# Custom ALPN
dirsearch -u https://target.com --alpn

# Custom NPN
dirsearch -u https://target.com --npn

# Custom SNI
dirsearch -u https://target.com --sni

# Custom TLS13
dirsearch -u https://target.com --tls13

# Custom TLS12
dirsearch -u https://target.com --tls12

# Custom TLS11
dirsearch -u https://target.com --tls11

# Custom TLS10
dirsearch -u https://target.com --tls10

# Custom TLS
dirsearch -u https://target.com --tls

# Custom SSL
dirsearch -u https://target.com --ssl

# Custom no SSL
dirsearch -u https://target.com --no-ssl

# Custom insecure
dirsearch -u https://target.com -k
```

Flags explained:
- `-u`: Target URL
- `-w`: Wordlist file
- `-e`: File extensions
- `-r`: Recursive scanning
- `-R`: Recursion depth
- `--rate-limit`: Rate limiting
- `-o`: Output file
- `-f`: Output format
- `-v`: Verbose mode
- `-s`: Silent mode
- `--exclude-status`: Exclude response codes
- `--include-status`: Include response codes
- `-H`: Custom headers
- `-c`: Custom cookies
- `-x`: Proxy server
- `--timeout`: Request timeout
- `-t`: Number of threads
- `--delay`: Delay between requests
- `--retries`: Number of retries
- `-L`: Follow redirects
- `-a`: Custom user agent
- `--auth`: Basic authentication
- `-k`: Skip SSL verification
- `--http2`: Use HTTP/2
- `--dns-mode`: DNS mode
- `-i`: Network interface
- `--source-port`: Source port
- `--resolve`: Custom resolve
- `--preloaded`: Preloaded
- `--happy-eyeballs`: Happy eyeballs
- `--tls13`: TLS 1.3
- `--ssl`: SSL
- `--no-ssl`: No SSL
- `--cert`: Client certificate
- `--key`: Client key
- `--ca`: CA certificate
- `--pin`: Pinned public key
- `--hpkp`: HPKP pin
- `--hkp-backup`: HPKP backup
- `--crl`: CRL file
- `--cert-status`: Certificate status
- `--ocsp`: OCSP stapling
- `--stapling`: Stapling
- `--alpn`: ALPN
- `--npn`: NPN
- `--sni`: SNI
- `--tls12`: TLS 1.2
- `--tls11`: TLS 1.1
- `--tls10`: TLS 1.0

### feroxbuster — Recursive Scanner

```bash
# Basic recursive scanning
feroxbuster -u https://target.com -w wordlist.txt

# With extensions
feroxbuster -u https://target.com -e php,html,js,txt

# Recursive scanning
feroxbuster -u https://target.com -r -d 3

# Rate limiting
feroxbuster -u https://target.com --rate-limit 100

# Output formats
feroxbuster -u https://target.com -o output.json -f json
feroxbuster -u https://target.com -o output.csv -f csv
feroxbuster -u https://target.com -o output.html -f html

# Verbose
feroxbuster -u https://target.com -v

# Silent
feroxbuster -u https://target.com -s

# Filter responses
feroxbuster -u https://target.com --exclude-status 404

# Match responses
feroxbuster -u https://target.com --include-status 200

# Custom headers
feroxbuster -u https://target.com -H "Authorization: Bearer token"
feroxbuster -u https://target.com -H "Content-Type: application/json"

# Custom cookies
feroxbuster -u https://target.com -b "session=abc123"

# Custom proxy
feroxbuster -u https://target.com -p http://127.0.0.1:8080

# Custom timeout
feroxbuster -u https://target.com --timeout 10

# Custom threads
feroxbuster -u https://target.com -t 50

# Custom delay
feroxbuster -u https://target.com --delay 1

# Custom retries
feroxbuster -u https://target.com --retries 3

# Custom follow redirects
feroxbuster -u https://target.com -L

# Custom user agent
feroxbuster -u https://target.com -a "Mozilla/5.0"

# Custom accept header
feroxbuster -u https://target.com -H "Accept: application/json"

# Custom content type
feroxbuster -u https://target.com -H "Content-Type: application/json"

# Custom auth
feroxbuster -u https://target.com --auth user:password

# Custom SSL
feroxbuster -u https://target.com -k

# Custom HTTP version
feroxbuster -u https://target.com --http2

# Custom DNS
feroxbuster -u https://target.com --dns-mode custom

# Custom interface
feroxbuster -u https://target.com -i eth0

# Custom source port
feroxbuster -u https://target.com --source-port 8080

# Custom resolve
feroxbuster -u https://target.com --resolve target.com:443:192.168.1.1

# Custom preloaded
feroxbuster -u https://target.com --preloaded

# Custom happy eyeballs
feroxbuster -u https://target.com --happy-eyeballs

# Custom TLS version
feroxbuster -u https://target.com --tls13

# Custom SSL
feroxbuster -u https://target.com --ssl

# Custom no SSL
feroxbuster -u https://target.com --no-ssl

# Custom insecure
feroxbuster -u https://target.com -k

# Custom cert
feroxbuster -u https://target.com --cert cert.pem

# Custom key
feroxbuster -u https://target.com --key key.pem

# Custom CA
feroxbuster -u https://target.com --ca ca.pem

# Custom pin
feroxbuster -u https://target.com --pin key.pub

# Custom HPKP
feroxbuster -u https://target.com --hpkp pin

# Custom HPKP backup
feroxbuster -u https://target.com --hkp-backup pin

# Custom CRL
feroxbuster -u https://target.com --crl crl.pem

# Custom issuer
feroxbuster -u https://target.com --cert-status

# Custom OCSP
feroxbuster -u https://target.com --ocsp

# Custom stapling
feroxbuster -u https://target.com --stapling

# Custom ALPN
feroxbuster -u https://target.com --alpn

# Custom NPN
feroxbuster -u https://target.com --npn

# Custom SNI
feroxbuster -u https://target.com --sni

# Custom TLS13
feroxbuster -u https://target.com --tls13

# Custom TLS12
feroxbuster -u https://target.com --tls12

# Custom TLS11
feroxbuster -u https://target.com --tls11

# Custom TLS10
feroxbuster -u https://target.com --tls10

# Custom TLS
feroxbuster -u https://target.com --tls

# Custom SSL
feroxbuster -u https://target.com --ssl

# Custom no SSL
feroxbuster -u https://target.com --no-ssl

# Custom insecure
feroxbuster -u https://target.com -k
```

Flags explained:
- `-u`: Target URL
- `-w`: Wordlist file
- `-e`: File extensions
- `-r`: Recursive scanning
- `-d`: Recursion depth
- `--rate-limit`: Rate limiting
- `-o`: Output file
- `-f`: Output format
- `-v`: Verbose mode
- `-s`: Silent mode
- `--exclude-status`: Exclude response codes
- `--include-status`: Include response codes
- `-H`: Custom headers
- `-b`: Custom cookies
- `-p`: Proxy server
- `--timeout`: Request timeout
- `-t`: Number of threads
- `--delay`: Delay between requests
- `--retries`: Number of retries
- `-L`: Follow redirects
- `-a`: Custom user agent
- `--auth`: Basic authentication
- `-k`: Skip SSL verification
- `--http2`: Use HTTP/2
- `--dns-mode`: DNS mode
- `-i`: Network interface
- `--source-port`: Source port
- `--resolve`: Custom resolve
- `--preloaded`: Preloaded
- `--happy-eyeballs`: Happy eyeballs
- `--tls13`: TLS 1.3
- `--ssl`: SSL
- `--no-ssl`: No SSL
- `--cert`: Client certificate
- `--key`: Client key
- `--ca`: CA certificate
- `--pin`: Pinned public key
- `--hpkp`: HPKP pin
- `--hkp-backup`: HPKP backup
- `--crl`: CRL file
- `--cert-status`: Certificate status
- `--ocsp`: OCSP stapling
- `--stapling`: Stapling
- `--alpn`: ALPN
- `--npn`: NPN
- `--sni`: SNI
- `--tls12`: TLS 1.2
- `--tls11`: TLS 1.1
- `--tls10`: TLS 1.0

### gobuster — Directory and DNS Scanner

```bash
# Basic directory scanning
gobuster dir -u https://target.com -w wordlist.txt

# With extensions
gobuster dir -u https://target.com -w wordlist.txt -x php,html,js,txt

# Recursive scanning
gobuster dir -u https://target.com -w wordlist.txt -r

# Rate limiting
gobuster dir -u https://target.com -w wordlist.txt --delay 1s

# Output formats
gobuster dir -u https://target.com -w wordlist.txt -o output.txt
gobuster dir -u https://target.com -w wordlist.txt -o output.json -f json

# Verbose
gobuster dir -u https://target.com -w wordlist.txt -v

# Silent
gobuster dir -u https://target.com -w wordlist.txt -q

# Filter responses
gobuster dir -u https://target.com -w wordlist.txt -s 200,301,302

# Exclude responses
gobuster dir -u https://target.com -w wordlist.txt -b 404

# Custom headers
gobuster dir -u https://target.com -w wordlist.txt -H "Authorization: Bearer token"
gobuster dir -u https://target.com -w wordlist.txt -H "Content-Type: application/json"

# Custom cookies
gobuster dir -u https://target.com -w wordlist.txt -c "session=abc123"

# Custom proxy
gobuster dir -u https://target.com -w wordlist.txt -p http://127.0.0.1:8080

# Custom timeout
gobuster dir -u https://target.com -w wordlist.txt --timeout 10s

# Custom threads
gobuster dir -u https://target.com -w wordlist.txt -t 50

# Custom user agent
gobuster dir -u https://target.com -w wordlist.txt -a "Mozilla/5.0"

# Custom SSL
gobuster dir -u https://target.com -w wordlist.txt -k

# DNS scanning
gobuster dns -d target.com -w wordlist.txt

# DNS with threads
gobuster dns -d target.com -w wordlist.txt -t 50

# DNS with timeout
gobuster dns -d target.com -w wordlist.txt --timeout 10s

# DNS with resolver
gobuster dns -d target.com -w wordlist.txt -r 8.8.8.8

# DNS with show ips
gobuster dns -d target.com -w wordlist.txt -i

# DNS with wildcard
gobuster dns -d target.com -w wordlist.txt --wildcard

# VHOST scanning
gobuster vhost -u https://target.com -w wordlist.txt

# VHOST with threads
gobuster vhost -u https://target.com -w wordlist.txt -t 50

# VHOST with timeout
gobuster vhost -u https://target.com -w wordlist.txt --timeout 10s

# VHOST with append domain
gobuster vhost -u https://target.com -w wordlist.txt --append-domain

# FUZZ mode
gobuster fuzz -u https://target.com/FUZZ -w wordlist.txt

# FUZZ with threads
gobuster fuzz -u https://target.com/FUZZ -w wordlist.txt -t 50

# FUZZ with timeout
gobuster fuzz -u https://target.com/FUZZ -w wordlist.txt --timeout 10s
```

Flags explained:
- `dir`: Directory mode
- `-u`: Target URL
- `-w`: Wordlist file
- `-x`: File extensions
- `-r`: Recursive scanning
- `--delay`: Delay between requests
- `-o`: Output file
- `-f`: Output format
- `-v`: Verbose mode
- `-q`: Quiet mode
- `-s`: Include response codes
- `-b`: Exclude response codes
- `-H`: Custom headers
- `-c`: Custom cookies
- `-p`: Proxy server
- `--timeout`: Request timeout
- `-t`: Number of threads
- `-a`: Custom user agent
- `-k`: Skip SSL verification
- `dns`: DNS mode
- `-d`: Target domain
- `-r`: DNS resolver
- `-i`: Show IP addresses
- `--wildcard`: Force wildcard
- `vhost`: Virtual host mode
- `--append-domain`: Append domain
- `fuzz`: FUZZ mode

### dirb — Directory Scanner

```bash
# Basic directory scanning
dirb https://target.com wordlist.txt

# With extensions
dirb https://target.com wordlist.txt -z 100

# Recursive scanning
dirb https://target.com wordlist.txt -r

# Rate limiting
dirb https://target.com wordlist.txt -z 100

# Output formats
dirb https://target.com wordlist.txt -o output.txt

# Verbose
dirb https://target.com wordlist.txt -v

# Silent
dirb https://target.com wordlist.txt -S

# Filter responses
dirb https://target.com wordlist.txt -N 404

# Match responses
dirb https://target.com wordlist.txt -M 200

# Custom headers
dirb https://target.com wordlist.txt -H "Authorization: Bearer token"
dirb https://target.com wordlist.txt -H "Content-Type: application/json"

# Custom cookies
dirb https://target.com wordlist.txt -c "session=abc123"

# Custom proxy
dirb https://target.com wordlist.txt -p http://127.0.0.1:8080

# Custom timeout
dirb https://target.com wordlist.txt -t 10

# Custom threads
dirb https://target.com wordlist.txt -T 50

# Custom user agent
dirb https://target.com wordlist.txt -a "Mozilla/5.0"

# Custom SSL
dirb https://target.com wordlist.txt -k

# Custom wordlist
dirb https://target.com /usr/share/wordlists/dirb/common.txt

# Custom extensions
dirb https://target.com wordlist.txt -X php,html,js,txt

# Custom forced extensions
dirb https://target.com wordlist.txt -f

# Custom no recursion
dirb https://target.com wordlist.txt -Z

# Custom test URL
dirb https://target.com wordlist.txt -t 10

# Custom use cache
dirb https://target.com wordlist.txt -c

# Custom no cache
dirb https://target.com wordlist.txt -C

# Custom only testing
dirb https://target.com wordlist.txt -z 100

# Custom stop on warning
dirb https://target.com wordlist.txt -W

# Custom debug mode
dirb https://target.com wordlist.txt -D

# Custom print cache
dirb https://target.com wordlist.txt -p

# Custom start from
dirb https://target.com wordlist.txt -S

# Custom not following redirections
dirb https://target.com wordlist.txt -N

# Custom extensions file
dirb https://target.com wordlist.txt -X extensions.txt

# Custom url list
dirb https://target.com wordlist.txt -l

# Custom force recursive
dirb https://target.com wordlist.txt -r

# Custom recursive with delay
dirb https://target.com wordlist.txt -r -z 100

# Custom recursive with threads
dirb https://target.com wordlist.txt -r -T 50

# Custom recursive with timeout
dirb https://target.com wordlist.txt -r -t 10

# Custom recursive with user agent
dirb https://target.com wordlist.txt -r -a "Mozilla/5.0"

# Custom recursive with proxy
dirb https://target.com wordlist.txt -r -p http://127.0.0.1:8080

# Custom recursive with cookies
dirb https://target.com wordlist.txt -r -c "session=abc123"

# Custom recursive with headers
dirb https://target.com wordlist.txt -r -H "Authorization: Bearer token"

# Custom recursive with SSL
dirb https://target.com wordlist.txt -r -k

# Custom recursive with output
dirb https://target.com wordlist.txt -r -o output.txt

# Custom recursive with verbose
dirb https://target.com wordlist.txt -r -v

# Custom recursive with silent
dirb https://target.com wordlist.txt -r -S

# Custom recursive with filter
dirb https://target.com wordlist.txt -r -N 404

# Custom recursive with match
dirb https://target.com wordlist.txt -r -M 200

# Custom recursive with extensions
dirb https://target.com wordlist.txt -r -X php,html,js,txt

# Custom recursive with forced extensions
dirb https://target.com wordlist.txt -r -f

# Custom recursive with no recursion
dirb https://target.com wordlist.txt -r -Z

# Custom recursive with test URL
dirb https://target.com wordlist.txt -r -t 10

# Custom recursive with use cache
dirb https://target.com wordlist.txt -r -c

# Custom recursive with no cache
dirb https://target.com wordlist.txt -r -C

# Custom recursive with only testing
dirb https://target.com wordlist.txt -r -z 100

# Custom recursive with stop on warning
dirb https://target.com wordlist.txt -r -W

# Custom recursive with debug mode
dirb https://target.com wordlist.txt -r -D

# Custom recursive with print cache
dirb https://target.com wordlist.txt -r -p

# Custom recursive with start from
dirb https://target.com wordlist.txt -r -S

# Custom recursive with not following redirections
dirb https://target.com wordlist.txt -r -N

# Custom recursive with extensions file
dirb https://target.com wordlist.txt -r -X extensions.txt

# Custom recursive with url list
dirb https://target.com wordlist.txt -r -l
```

Flags explained:
- `-z`: Delay between requests (milliseconds)
- `-r`: Recursive scanning
- `-o`: Output file
- `-v`: Verbose mode
- `-S`: Silent mode
- `-N`: Exclude response codes
- `-M`: Include response codes
- `-H`: Custom headers
- `-c`: Custom cookies
- `-p`: Proxy server
- `-t`: Request timeout
- `-T`: Number of threads
- `-a`: Custom user agent
- `-k`: Skip SSL verification
- `-X`: File extensions
- `-f`: Force extensions
- `-Z`: No recursion
- `-W`: Stop on warning
- `-D`: Debug mode
- `-l`: URL list
- `-C`: Use cache
- `-c`: Print cache
- `-S`: Start from
- `-N`: Not following redirections
- `-X`: Extensions file

## Case Studies

### Case Study 1: Enterprise Web Application

**Target:** Large enterprise web application with complex structure
**Objective:** Discover all hidden directories and files

The application had multiple web servers with different configurations. Traditional scanning was insufficient.

**Approach:**
1. Used gobuster for initial directory discovery
2. Deployed feroxbuster for recursive scanning
3. Implemented ffuf for advanced fuzzing
4. Tested for virtual host discovery
5. Analyzed responses for false positives

**Results:**
- 234 directories discovered
- 56 hidden files found
- 89 backup files identified
- 12 configuration files exposed
- 23 administration interfaces discovered

**Key Findings:**
- Backup files containing source code
- Configuration files with credentials
- Administration interfaces without authentication
- Directory listing enabled on multiple servers
- Sensitive files accessible without authentication

**Lessons Learned:**
- Recursive scanning reveals nested resources
- File extension testing discovers backup files
- Virtual host discovery reveals additional applications
- Response analysis helps filter false positives

### Case Study 2: Cloud-Hosted Application

**Target:** Cloud-hosted application with CDN
**Objective:** Discover directories behind CDN

The application was hosted behind a CDN with custom error pages. Traditional scanning was ineffective.

**Approach:**
1. Identified origin server IP addresses
2. Used ffuf for directory discovery on origin
3. Implemented custom error page detection
4. Tested for cloud-specific directories
5. Analyzed CDN cache behavior

**Results:**
- 123 directories discovered on origin
- 56 hidden files found
- 89 cloud-specific resources identified
- 12 misconfigured cloud resources
- 23 CDN bypass opportunities

**Key Findings:**
- Origin server accessible bypassing CDN
- Cloud storage buckets exposed
- CDN cache poisoning opportunities
- Misconfigured cloud permissions
- Sensitive files accessible through origin

**Lessons Learned:**
- CDN bypass reveals true attack surface
- Cloud environments have unique directory structures
- Origin server testing is essential
- Cache behavior can reveal hidden resources

### Case Study 3: Legacy Web Server

**Target:** Legacy Apache web server with custom configuration
**Objective:** Discover all resources on legacy server

The server had custom configurations and legacy technologies. Standard wordlists were insufficient.

**Approach:**
1. Analyzed server configuration from headers
2. Created custom wordlist for legacy technologies
3. Used dirb for initial discovery
4. Implemented custom extension testing
5. Tested for legacy vulnerability paths

**Results:**
- 89 directories discovered
- 34 hidden files found
- 12 legacy scripts identified
- 8 configuration files exposed
- 5 vulnerable scripts discovered

**Key Findings:**
- Legacy CGI scripts with vulnerabilities
- Custom configuration files exposed
- Server-side includes enabled
- Directory traversal vulnerabilities
- Default installation files present

**Lessons Learned:**
- Legacy servers require custom approaches
- Configuration analysis guides scanning
- Custom wordlists improve discovery
- Legacy vulnerabilities are common

## Bypass Techniques

### Rate Limiting Bypass

Distribute requests across multiple source IPs. Implement random delays between requests. Use different session tokens for each request. Rotate user agents and headers. Exploit rate limiting inconsistencies across paths.

### WAF Bypass

Use encoding techniques to bypass filters. Implement case variation in payloads. Use chunked transfer encoding to split requests. Try different HTTP methods and content types. Use HTTP/2 protocol features for bypass.

### Error Page Bypass

Analyze custom error pages for differences. Use response size and timing for detection. Test for hidden content in error responses. Exploit error page inconsistencies.

### Authentication Bypass

Test for default credentials on admin interfaces. Exploit broken authentication mechanisms. Test for session fixation. Analyze authentication bypass techniques.

### Path Traversal Bypass

Test for path traversal vulnerabilities. Use encoding to bypass filters. Test for null byte injection. Exploit file system navigation.

### Cache Bypass

Use cache-busting techniques. Test for cache poisoning. Exploit cache configuration. Analyze cache behavior.

## Advanced Techniques

### Machine Learning for Directory Prediction

Use machine learning models to predict directory patterns. Train models on known directory structures. Implement anomaly detection for directory behavior. Use clustering to group similar directories.

### Automated Wordlist Generation

Generate wordlists based on application patterns. Use templates and rules for generation. Implement context-aware wordlist creation. Automate wordlist validation.

### Dynamic Directory Analysis

Analyze application behavior with directories. Monitor directory impact on responses. Track directory dependencies. Document directory relationships.

### Cloud-Specific Directory Discovery

Discover cloud-specific directories and resources. Test for cloud misconfigurations. Analyze cloud storage structures. Identify cloud-specific vulnerabilities.

### Container and Microservices Discovery

Discover container orchestration platforms. Test for container-specific directories. Analyze microservice structures. Identify container vulnerabilities.

### Continuous Directory Monitoring

Monitor applications for new directories. Track directory changes over time. Alert on unauthorized directory access. Document directory evolution.

## Detection Indicators

### Network-Level Indicators

High volume of directory requests indicates scanning. Unusual directory patterns suggest automated tools. Multiple requests to non-existent directories indicate enumeration. Abnormal request timing reveals automated behavior.

### Log Analysis Indicators

Web server logs show directory scanning patterns. WAF logs capture blocked requests. Application logs record directory access attempts. Proxy logs reveal scanning traffic.

### Behavioral Indicators

Sequential directory requests indicate automated scanning. Random directory patterns suggest brute-forcing. Consistent timing reveals scripted behavior. Large bursts of requests indicate aggressive scanning.

### Source Indicators

Known scanning tool user agents appear in logs. IP addresses from known scanning infrastructure are flagged. Request patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

Directory discovery reveals application structure. Each directory represents a potential attack vector. Hidden directories may expose sensitive functionality. Configuration files may contain credentials.

### Indirect Impact

Discovery enables further security testing. Findings guide vulnerability assessment. Regular discovery reduces attack surface. Automated discovery enables continuous security assessment.

### Risk Quantification

Hidden directories pose high risk. Configuration file exposure creates critical risk. Administrative interfaces enable unauthorized access. Backup files may contain sensitive code.

### Business Impact

Comprehensive directory discovery improves security posture. Findings enable risk-based decision making. Regular discovery supports compliance requirements. Automated discovery reduces manual effort.

## Common Pitfalls

### Tool Configuration Errors

Incorrect wordlists miss directories. Missing authentication credentials prevent access. Wrong endpoint patterns miss important resources. Inadequate rate limits cause blocking.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering false positives wastes time. Ignoring response patterns creates inaccurate assessments. Missing output formats prevent integration.

### Scope Management Issues

Discovering out-of-scope directories violates engagement rules. Not verifying authorization creates legal risks. Ignoring directory boundaries leads to false assumptions. Failing to document scope complicates reporting.

### Resource Management Problems

Running too many scans simultaneously causes network congestion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Aggressive scanning without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### CI/CD Pipeline Integration

Automate directory discovery in continuous integration pipelines. Trigger discoveries on code changes. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed discovered directories into vulnerability scanners. Prioritize scanning based on directory sensitivity. Correlate findings with other testing. Update scanner targets automatically.

### Web Server Integration

Integrate with web server configurations. Use server APIs for directory enumeration. Analyze server configurations. Test server security controls.

### Monitoring System Integration

Integrate with web server monitoring systems. Set up alerts for new directories. Monitor for directory changes. Track discovery trends over time.

### Documentation Platform Integration

Sync with documentation platforms. Update documentation with discoveries. Track documentation accuracy. Generate documentation from discoveries.

## Reporting Templates

### Executive Summary

```
Directory Brute-Forcing Report
Date: [DATE]
Target: [SCOPE]
Tools Used: [LIST]
Total Directories: [NUMBER]
Hidden Files: [NUMBER]
Sensitive Files: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Brute-Forcing Methodology:
1. Initial Discovery: [METHOD]
2. Recursive Scanning: [TOOLS]
3. Response Analysis: [APPROACH]
4. Validation: [METHOD]

Results Breakdown:
- Total Directories: [NUMBER]
- Hidden Files: [NUMBER]
- Configuration Files: [NUMBER]
- Backup Files: [NUMBER]
- Administrative Interfaces: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
Path,Status,Size,Lines,Words,Characters,ContentType,Vulnerability
/admin,200,1234,50,100,5000,text/html,None
/config.php,200,5678,100,200,10000,text/php,None
/backup.zip,200,123456,N/A,N/A,N/A,application/zip,None
/.htaccess,403,0,0,0,0,text/plain,Information Disclosure
```

## Practice Labs

### Lab 1: Basic Directory Scanning

**Setup:** Create a web application with hidden directories
**Exercise:** Use gobuster to discover all directories
**Goal:** Find all documented and undocumented directories

### Lab 2: Recursive Scanning

**Setup:** Application with nested directory structure
**Exercise:** Use feroxbuster for recursive scanning
**Goal:** Discover all nested directories and files

### Lab 3: Virtual Host Discovery

**Setup:** Server with multiple virtual hosts
**Exercise:** Use gobuster for virtual host discovery
**Goal:** Find all virtual hosts and their content

### Lab 4: Response Analysis

**Setup:** Application with different response patterns
**Exercise:** Analyze responses to filter false positives
**Goal:** Accurately identify valid directories

## Ethics

Directory brute-forcing must be performed within legal and ethical boundaries. Always obtain written authorization before brute-forcing any application. Respect rate limits and do not cause denial of service. Do not brute-force applications outside the authorized scope. Use appropriate brute-forcing techniques for the environment. Store brute-forcing results securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not brute-force personal applications without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Basic directory scanning
gobuster dir -u https://target.com -w wordlist.txt

# With extensions
gobuster dir -u https://target.com -w wordlist.txt -x php,html,js,txt

# Recursive scanning
feroxbuster -u https://target.com -w wordlist.txt -r -d 3

# Rate limiting
ffuf -u https://target.com/FUZZ -w wordlist.txt -rate 100

# Output to JSON
ffuf -u https://target.com/FUZZ -w wordlist.txt -o output.json -of json

# Verbose output
gobuster dir -u https://target.com -w wordlist.txt -v

# Filter responses
ffuf -u https://target.com/FUZZ -w wordlist.txt -fc 404

# Match responses
ffuf -u https://target.com/FUZZ -w wordlist.txt -mc 200

# Custom headers
ffuf -u https://target.com/FUZZ -w wordlist.txt -H "Authorization: Bearer token"

# Virtual host discovery
gobuster vhost -u https://target.com -w wordlist.txt
```

### Tool Comparison

| Tool | Speed | Recursive | Extensions | Ease |
|------|-------|-----------|------------|------|
| ffuf | Fast | Yes | Yes | Medium |
| dirsearch | Fast | Yes | Yes | High |
| feroxbuster | Fast | Yes | Yes | High |
| gobuster | Fast | Yes | Yes | High |
| dirb | Medium | Yes | Yes | High |

### Common Directories

```
Web Root:
- /admin
- /backup
- /config
- /data
- /db
- /debug
- /dev
- /docs
- /dump
- /env
- /etc
- /files
- /git
- /hidden
- /images
- /includes
- /index
- /js
- /css
- /img
- /lib
- /logs
- /media
- /private
- /public
- /resources
- /scripts
- /secret
- /src
- /static
- /system
- /temp
- /tmp
- /uploads
- /var
- /vendor
- /wp-admin
- /wp-content
- /wp-includes
```

### Common File Extensions

```
Code:
- .php
- .html
- .js
- .css
- .py
- .rb
- .jsp
- .asp
- .aspx
- .cfm

Data:
- .json
- .xml
- .csv
- .txt
- .sql
- .db
- .sqlite
- .mdb

Config:
- .env
- .config
- .ini
- .yml
- .yaml
- .toml
- .htaccess
- .htpasswd
- web.config

Backup:
- .bak
- .backup
- .old
- .orig
- .save
- .swp
- .tar.gz
- .zip
- .rar
```

### Response Codes

```
200: OK - Resource exists
301: Moved Permanently - Redirect
302: Found - Redirect
403: Forbidden - Resource exists but unauthorized
404: Not Found - Resource does not exist
405: Method Not Allowed - Wrong HTTP method
429: Too Many Requests - Rate limited
500: Server Error - Resource may cause issues
```

### Scanning Workflow

```
1. Discovery:
   - Identify web servers
   - Analyze configurations
   - Create wordlists

2. Scanning:
   - Basic directory discovery
   - Recursive scanning
   - Virtual host discovery

3. Analysis:
   - Response analysis
   - False positive filtering
   - Vulnerability identification

4. Validation:
   - Manual verification
   - Impact assessment
   - Documentation
```

### Debugging Commands

```bash
# Verbose curl
curl -v https://target.com/

# Debug curl
curl -v https://target.com/

# Test connectivity
ping target.com

# Test DNS
nslookup target.com

# Test SSL
openssl s_client -connect target.com:443

# Test web server
curl -I https://target.com/

# Check response headers
curl -I https://target.com/

# Check response body
curl -s https://target.com/ | head -n 20

# Check for directory listing
curl -s https://target.com/ | grep -i "index of"

# Check for common files
curl -s https://target.com/robots.txt
```
