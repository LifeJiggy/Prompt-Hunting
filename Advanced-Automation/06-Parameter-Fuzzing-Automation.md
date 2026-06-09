# Automated Parameter Fuzzing — Complete Automation Guide

## Expert Role

You are a senior security researcher specializing in automated parameter discovery and fuzzing. You have extensive experience identifying hidden parameters, testing input validation, and discovering security vulnerabilities through fuzzing techniques. You understand the intricacies of HTTP parameter handling, parameter pollution, and input-based vulnerabilities. You have mastered the art of designing efficient fuzzing strategies that maximize coverage while minimizing time and resource consumption. Your expertise includes understanding different parameter types (query, body, header, cookie), encoding techniques, and payload crafting. You can design and implement automated fuzzing pipelines that integrate with vulnerability scanning and penetration testing workflows. You understand the differences between wordlist-based fuzzing, mutation-based fuzzing, and generation-based fuzzing. You are proficient in using multiple fuzzing tools and combining their results for comprehensive coverage. You stay current with the latest fuzzing techniques, tool updates, and emerging vulnerability patterns. You understand the legal and ethical implications of fuzzing and always operate within authorized boundaries.

## Core Concepts

Parameter fuzzing is the process of discovering and testing parameters in web applications. Parameters are variables that pass data between client and server. Hidden parameters may expose additional functionality or vulnerabilities.

Parameter discovery involves identifying all parameters used by an application. This includes query parameters, POST body parameters, HTTP headers, and cookies. Undocumented parameters may reveal hidden functionality.

Parameter pollution involves injecting multiple values for the same parameter. This can cause unexpected behavior in application logic. Parameter pollution can lead to security vulnerabilities like authentication bypass.

Wordlist-based fuzzing uses predefined lists of parameter names and values. This approach is efficient for common parameters but may miss application-specific ones. Wordlists should be customized for each target.

Mutation-based fuzzing modifies existing parameters to discover new ones. This approach builds on known parameters to find variations. Mutation can include case changes, prefix/suffix additions, and encoding.

Generation-based fuzzing creates parameters from scratch based on patterns. This approach is useful for discovering application-specific parameters. Generation can use templates, rules, and machine learning.

Response-based filtering analyzes server responses to identify valid parameters. Different responses indicate parameter existence or impact. Response analysis helps prioritize findings.

Recursive fuzzing uses discovered parameters as seeds for further discovery. This approach can uncover nested parameters and complex parameter structures. Recursive fuzzing expands coverage exponentially.

## Prerequisites

- Linux-based operating system (Kali Linux recommended)
- Python 3.x with pip for scripting and automation
- ffuf for web fuzzing
- wfuzz for parameter fuzzing
- Arjun for parameter discovery
- Param Miner for parameter mining
- Burp Suite for manual testing
- curl for HTTP requests
- jq for JSON processing
- Understanding of HTTP protocols
- Familiarity with web application architectures
- Text editor for customizing wordlists
- Git for cloning tool repositories
- Standard Unix utilities (sort, uniq, grep, awk)
- Knowledge of common parameter names
- Understanding of encoding techniques

## Methodology

### Step 1: Initial Reconnaissance

Identify target endpoints and their parameters. Analyze existing parameters for patterns. Check for API documentation and specifications. Review JavaScript files for parameter references. Map application functionality.

### Step 2: Wordlist Preparation

Create or download parameter wordlists. Customize wordlists based on target technology. Include common parameter names and values. Add technology-specific parameters. Organize wordlists by category.

### Step 3: Basic Parameter Discovery

Use Arjun for initial parameter discovery. Test common parameter locations (query, body, header, cookie). Verify discovered parameters. Document all findings. Create baseline parameter list.

### Step 4: Advanced Fuzzing

Deploy ffuf for comprehensive fuzzing. Use wfuzz for parameter value testing. Implement recursive fuzzing for nested parameters. Test for parameter pollution. Document all findings.

### Step 5: Response Analysis

Analyze server responses for parameter impact. Identify different response patterns. Filter false positives based on responses. Prioritize findings based on impact. Document response patterns.

### Step 6: Hidden Parameter Mining

Use Param Miner for deep parameter mining. Test for hidden parameters in different contexts. Analyze application behavior with parameters. Identify parameter dependencies. Document hidden parameters.

### Step 7: Parameter Value Fuzzing

Test parameter values for vulnerabilities. Use payload lists for common vulnerabilities. Test for SQL injection, XSS, and command injection. Analyze responses for vulnerability indicators. Document potential vulnerabilities.

### Step 8: Parameter Pollution Testing

Test for parameter pollution vulnerabilities. Inject multiple values for same parameter. Analyze application behavior with polluted parameters. Identify bypass opportunities. Document pollution vulnerabilities.

### Step 9: Result Deduplication

Merge results from multiple tools. Remove duplicate findings. Validate findings through manual testing. Create comprehensive parameter database. Document all validated findings.

### Step 10: Integration with Vulnerability Scanning

Feed discovered parameters into vulnerability scanners. Prioritize scanning based on parameter sensitivity. Correlate findings with other testing. Automate ongoing parameter discovery. Document integration points.

## Tool Arsenal

### ffuf — Web Fuzzer

```bash
# Basic parameter fuzzing
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt

# POST parameter fuzzing
ffuf -u https://target.com/api -X POST -d "FUZZ=test" -w wordlist.txt

# Header fuzzing
ffuf -u https://target.com/api -H "FUZZ: test" -w wordlist.txt

# Cookie fuzzing
ffuf -u https://target.com/api -b "FUZZ=test" -w wordlist.txt

# Multiple parameters
ffuf -u https://target.com/api?FUZZ1=test&FUZZ2=test -w wordlist.txt

# Recursive fuzzing
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -recursion -recursion-depth 2

# Rate limiting
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -rate 100

# Output formats
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -o output.json -of json
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -o output.csv -of csv
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -o output.html -of html

# Verbose
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -v

# Silent
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -s

# Filter responses
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -fc 404
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -fs 0
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -fl 10

# Match responses
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -mc 200
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ms "success"
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ml 50

# Custom headers
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -H "Authorization: Bearer token"
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -H "Content-Type: application/json"

# Custom cookies
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -b "session=abc123"

# Custom data
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -d '{"key":"value"}'

# Custom method
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -X PUT

# Custom proxy
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -x http://127.0.0.1:8080

# Custom timeout
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -t 10

# Custom threads
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -t 50

# Custom delay
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -p 1

# Custom retries
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -retries 3

# Custom follow redirects
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -fr

# Custom user agent
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ua "Mozilla/5.0"

# Custom accept header
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ac "application/json"

# Custom content type
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ct "application/json"

# Custom auth
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -auth user:password

# Custom SSL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -k

# Custom HTTP version
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -http2

# Custom DNS
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -dns-mode custom

# Custom interface
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -i eth0

# Custom source port
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -sp 8080

# Custom resolve
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -rec target.com:443:192.168.1.1

# Custom preloaded
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -pl

# Custom happy eyeballs
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -he

# Custom TLS version
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls13

# Custom SSL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ssl

# Custom no SSL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -no-ssl

# Custom insecure
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -k

# Custom cert
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -cert cert.pem

# Custom key
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -key key.pem

# Custom CA
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ca ca.pem

# Custom pin
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -pin key.pub

# Custom HPKP
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -hpkp pin

# Custom HPKP backup
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -hkp-backup pin

# Custom CRL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -crl crl.pem

# Custom issuer
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -cert-status

# Custom OCSP
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ocsp

# Custom stapling
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -stapling

# Custom ALPN
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -alpn

# Custom NPN
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -npn

# Custom SNI
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -sni

# Custom TLS13
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls13

# Custom TLS12
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls12

# Custom TLS11
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls11

# Custom TLS10
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls10

# Custom TLS
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -tls

# Custom SSL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -ssl

# Custom no SSL
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -no-ssl

# Custom insecure
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -k
```

Flags explained:
- `-u`: Target URL with FUZZ keyword
- `-w`: Wordlist file
- `-X`: HTTP method
- `-d`: POST data
- `-H`: Custom headers
- `-b`: Custom cookies
- `-recursion`: Enable recursive fuzzing
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

### wfuzz — Web Fuzzer

```bash
# Basic parameter fuzzing
wfuzz -c -z file,wordlist.txt https://target.com/api?FUZZ=test

# POST parameter fuzzing
wfuzz -c -z file,wordlist.txt -d "FUZZ=test" https://target.com/api

# Header fuzzing
wfuzz -c -z file,wordlist.txt -H "FUZZ: test" https://target.com/api

# Cookie fuzzing
wfuzz -c -z file,wordlist.txt -b "FUZZ=test" https://target.com/api

# Multiple parameters
wfuzz -c -z file,wordlist.txt https://target.com/api?FUZZ1=test&FUZZ2=test

# Recursive fuzzing
wfuzz -c -z file,wordlist.txt -recursion https://target.com/api?FUZZ=test

# Rate limiting
wfuzz -c -z file,wordlist.txt --rate 100 https://target.com/api?FUZZ=test

# Output formats
wfuzz -c -z file,wordlist.txt -o json https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt -o csv https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt -o html https://target.com/api?FUZZ=test

# Verbose
wfuzz -c -z file,wordlist.txt -v https://target.com/api?FUZZ=test

# Silent
wfuzz -c -z file,wordlist.txt -s https://target.com/api?FUZZ=test

# Filter responses
wfuzz -c -z file,wordlist.txt --hc 404 https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt --hs 0 https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt --hl 10 https://target.com/api?FUZZ=test

# Match responses
wfuzz -c -z file,wordlist.txt --mc 200 https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt --ms "success" https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt --ml 50 https://target.com/api?FUZZ=test

# Custom headers
wfuzz -c -z file,wordlist.txt -H "Authorization: Bearer token" https://target.com/api?FUZZ=test
wfuzz -c -z file,wordlist.txt -H "Content-Type: application/json" https://target.com/api?FUZZ=test

# Custom cookies
wfuzz -c -z file,wordlist.txt -b "session=abc123" https://target.com/api?FUZZ=test

# Custom data
wfuzz -c -z file,wordlist.txt -d '{"key":"value"}' https://target.com/api?FUZZ=test

# Custom method
wfuzz -c -z file,wordlist.txt -X PUT https://target.com/api?FUZZ=test

# Custom proxy
wfuzz -c -z file,wordlist.txt -p http://127.0.0.1:8080 https://target.com/api?FUZZ=test

# Custom timeout
wfuzz -c -z file,wordlist.txt --timeout 10 https://target.com/api?FUZZ=test

# Custom threads
wfuzz -c -z file,wordlist.txt -t 50 https://target.com/api?FUZZ=test

# Custom delay
wfuzz -c -z file,wordlist.txt --delay 1 https://target.com/api?FUZZ=test

# Custom retries
wfuzz -c -z file,wordlist.txt --retries 3 https://target.com/api?FUZZ=test

# Custom follow redirects
wfuzz -c -z file,wordlist.txt -L https://target.com/api?FUZZ=test

# Custom user agent
wfuzz -c -z file,wordlist.txt -u "Mozilla/5.0" https://target.com/api?FUZZ=test

# Custom accept header
wfuzz -c -z file,wordlist.txt -H "Accept: application/json" https://target.com/api?FUZZ=test

# Custom content type
wfuzz -c -z file,wordlist.txt -H "Content-Type: application/json" https://target.com/api?FUZZ=test

# Custom auth
wfuzz -c -z file,wordlist.txt --basic user:password https://target.com/api?FUZZ=test

# Custom SSL
wfuzz -c -z file,wordlist.txt -k https://target.com/api?FUZZ=test

# Custom HTTP version
wfuzz -c -z file,wordlist.txt --http2 https://target.com/api?FUZZ=test

# Custom DNS
wfuzz -c -z file,wordlist.txt --dns-mode custom https://target.com/api?FUZZ=test

# Custom interface
wfuzz -c -z file,wordlist.txt -i eth0 https://target.com/api?FUZZ=test

# Custom source port
wfuzz -c -z file,wordlist.txt --source-port 8080 https://target.com/api?FUZZ=test

# Custom resolve
wfuzz -c -z file,wordlist.txt --resolve target.com:443:192.168.1.1 https://target.com/api?FUZZ=test

# Custom preloaded
wfuzz -c -z file,wordlist.txt --preloaded https://target.com/api?FUZZ=test

# Custom happy eyeballs
wfuzz -c -z file,wordlist.txt --happy-eyeballs https://target.com/api?FUZZ=test

# Custom TLS version
wfuzz -c -z file,wordlist.txt --tls13 https://target.com/api?FUZZ=test

# Custom SSL
wfuzz -c -z file,wordlist.txt --ssl https://target.com/api?FUZZ=test

# Custom no SSL
wfuzz -c -z file,wordlist.txt --no-ssl https://target.com/api?FUZZ=test

# Custom insecure
wfuzz -c -z file,wordlist.txt -k https://target.com/api?FUZZ=test

# Custom cert
wfuzz -c -z file,wordlist.txt --cert cert.pem https://target.com/api?FUZZ=test

# Custom key
wfuzz -c -z file,wordlist.txt --key key.pem https://target.com/api?FUZZ=test

# Custom CA
wfuzz -c -z file,wordlist.txt --ca ca.pem https://target.com/api?FUZZ=test

# Custom pin
wfuzz -c -z file,wordlist.txt --pin key.pub https://target.com/api?FUZZ=test

# Custom HPKP
wfuzz -c -z file,wordlist.txt --hpkp pin https://target.com/api?FUZZ=test

# Custom HPKP backup
wfuzz -c -z file,wordlist.txt --hkp-backup pin https://target.com/api?FUZZ=test

# Custom CRL
wfuzz -c -z file,wordlist.txt --crl crl.pem https://target.com/api?FUZZ=test

# Custom issuer
wfuzz -c -z file,wordlist.txt --cert-status https://target.com/api?FUZZ=test

# Custom OCSP
wfuzz -c -z file,wordlist.txt --ocsp https://target.com/api?FUZZ=test

# Custom stapling
wfuzz -c -z file,wordlist.txt --stapling https://target.com/api?FUZZ=test

# Custom ALPN
wfuzz -c -z file,wordlist.txt --alpn https://target.com/api?FUZZ=test

# Custom NPN
wfuzz -c -z file,wordlist.txt --npn https://target.com/api?FUZZ=test

# Custom SNI
wfuzz -c -z file,wordlist.txt --sni https://target.com/api?FUZZ=test

# Custom TLS13
wfuzz -c -z file,wordlist.txt --tls13 https://target.com/api?FUZZ=test

# Custom TLS12
wfuzz -c -z file,wordlist.txt --tls12 https://target.com/api?FUZZ=test

# Custom TLS11
wfuzz -c -z file,wordlist.txt --tls11 https://target.com/api?FUZZ=test

# Custom TLS10
wfuzz -c -z file,wordlist.txt --tls10 https://target.com/api?FUZZ=test

# Custom TLS
wfuzz -c -z file,wordlist.txt --tls https://target.com/api?FUZZ=test

# Custom SSL
wfuzz -c -z file,wordlist.txt --ssl https://target.com/api?FUZZ=test

# Custom no SSL
wfuzz -c -z file,wordlist.txt --no-ssl https://target.com/api?FUZZ=test

# Custom insecure
wfuzz -c -z file,wordlist.txt -k https://target.com/api?FUZZ=test
```

Flags explained:
- `-c`: Color output
- `-z`: Payload type and source
- `-d`: POST data
- `-H`: Custom headers
- `-b`: Custom cookies
- `--hc`: Hide by response code
- `--hs`: Hide by response size
- `--hl`: Hide by line count
- `--mc`: Match by response code
- `--ms`: Match by response string
- `--ml`: Match by line count
- `-o`: Output format
- `-v`: Verbose mode
- `-s`: Silent mode
- `-p`: Proxy server
- `--timeout`: Request timeout
- `-t`: Number of threads
- `--delay`: Delay between requests
- `--retries`: Number of retries
- `-L`: Follow redirects
- `-u`: Custom user agent
- `-X`: HTTP method
- `--basic`: Basic authentication
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

### Arjun — Parameter Discovery

```bash
# Basic parameter discovery
arjun -u https://target.com/api

# JSON data
arjun -u https://target.com/api -j '{"key":"value"}'

# POST data
arjun -u https://target.com/api -d "param=value"

# Headers
arjun -u https://target.com/api -H "Authorization: Bearer token"

# Cookies
arjun -u https://target.com/api -c "session=abc123"

# Custom wordlist
arjun -u https://target.com/api -w custom_wordlist.txt

# Output formats
arjun -u https://target.com/api -o json
arjun -u https://target.com/api -o csv

# Verbose
arjun -u https://target.com/api -v

# Include debug
arjun -u https://target.com/api -d

# Multiple URLs
arjun -u urls.txt

# Help
arjun --help
```

Flags explained:
- `-u`: Target URL
- `-j`: JSON data
- `-d`: POST data
- `-H`: Custom headers
- `-c`: Cookies
- `-w`: Custom wordlist
- `-o`: Output format
- `-v`: Verbose mode
- `-d`: Debug mode

### Param Miner — Parameter Mining

```bash
# Basic parameter mining
param-miner --target https://target.com/api --wordlist params.txt

# With authentication
param-miner --target https://target.com/api --wordlist params.txt --cookie "session=abc123"

# With headers
param-miner --target https://target.com/api --wordlist params.txt --header "Authorization: Bearer token"

# With custom wordlist
param-miner --target https://target.com/api --wordlist custom_params.txt

# With rate limiting
param-miner --target https://target.com/api --wordlist params.txt --rate 100

# With output
param-miner --target https://target.com/api --wordlist params.txt --output results.json

# With verbose
param-miner --target https://target.com/api --wordlist params.txt --verbose

# With debug
param-miner --target https://target.com/api --wordlist params.txt --debug

# Help
param-miner --help
```

### curl — Manual Testing

```bash
# Basic parameter testing
curl -s "https://target.com/api?test=value"

# POST parameter testing
curl -s -X POST -d "test=value" https://target.com/api

# Header testing
curl -s -H "X-Test: value" https://target.com/api

# Cookie testing
curl -s -b "test=value" https://target.com/api

# Multiple parameters
curl -s "https://target.com/api?param1=value1&param2=value2"

# JSON data
curl -s -X POST -H "Content-Type: application/json" -d '{"test":"value"}' https://target.com/api

# XML data
curl -s -X POST -H "Content-Type: application/xml" -d '<test>value</test>' https://target.com/api

# Form data
curl -s -X POST -d "test=value" https://target.com/api

# Multipart data
curl -s -F "test=value" https://target.com/api

# With authentication
curl -s -H "Authorization: Bearer token" https://target.com/api?test=value

# With cookies
curl -s -b "session=abc123" https://target.com/api?test=value

# With proxy
curl -s -x http://127.0.0.1:8080 https://target.com/api?test=value

# With timeout
curl -s --connect-timeout 10 https://target.com/api?test=value

# With retries
curl -s --retry 3 https://target.com/api?test=value

# With verbose
curl -v https://target.com/api?test=value

# With debug
curl -v https://target.com/api?test=value

# With user agent
curl -s -A "Mozilla/5.0" https://target.com/api?test=value

# With custom headers
curl -s -H "X-API-Key: key" https://target.com/api?test=value

# With SSL verification
curl -s --verify https://target.com/api?test=value

# With client certificate
curl -s --cert cert.pem --key key.pem https://target.com/api?test=value

# With form data
curl -s -F "file=@file.txt" https://target.com/api

# With multipart data
curl -s -F "name=test" -F "file=@file.txt" https://target.com/api

# With basic auth
curl -s -u user:password https://target.com/api?test=value

# With digest auth
curl -s --digest -u user:password https://target.com/api?test=value

# With NTLM auth
curl -s --ntlm -u user:password https://target.com/api?test=value

# With negotiate auth
curl -s --negotiate -u user:password https://target.com/api?test=value

# With bearer token
curl -s -H "Authorization: Bearer token" https://target.com/api?test=value

# With API key
curl -s -H "X-API-Key: key" https://target.com/api?test=value

# With OAuth
curl -s -H "Authorization: OAuth token" https://target.com/api?test=value

# With JWT
curl -s -H "Authorization: JWT token" https://target.com/api?test=value

# With session cookie
curl -s -b "session=abc123" https://target.com/api?test=value

# With CSRF token
curl -s -b "session=abc123" -d "csrf_token=token" https://target.com/api?test=value

# With rate limiting
for i in $(seq 1 100); do curl -s https://target.com/api?test=value; sleep 1; done

# With throttling
curl -s --limit-rate 100K https://target.com/api?test=value

# With compression
curl -s --compressed https://target.com/api?test=value

# With HTTP/2
curl -s --http2 https://target.com/api?test=value

# With HTTP/3
curl -s --http3 https://target.com/api?test=value

# With IPv4
curl -s -4 https://target.com/api?test=value

# With IPv6
curl -s -6 https://target.com/api?test=value

# With interface
curl -s --interface eth0 https://target.com/api?test=value

# With source IP
curl -s --local-port 8080 https://target.com/api?test=value

# With DNS server
curl -s --dns-servers 8.8.8.8 https://target.com/api?test=value

# With resolve
curl -s --resolve target.com:443:192.168.1.1 https://target.com/api?test=value

# With preloaded
curl -s --preloaded https://target.com/api?test=value

# With happy eyeballs
curl -s --happy-eye-balls https://target.com/api?test=value

# With TLS 1.3
curl -s --tlsv1.3 https://target.com/api?test=value

# With TLS 1.2
curl -s --tlsv1.2 https://target.com/api?test=value

# With TLS 1.1
curl -s --tlsv1.1 https://target.com/api?test=value

# With TLS 1.0
curl -s --tlsv1.0 https://target.com/api?test=value

# With SSL
curl -s --ssl https://target.com/api?test=value

# With no SSL
curl -s --no-ssl https://target.com/api?test=value

# With insecure
curl -s -k https://target.com/api?test=value

# With cert
curl -s --cert cert.pem https://target.com/api?test=value

# With key
curl -s --key key.pem https://target.com/api?test=value

# With CA
curl -s --cacert ca.pem https://target.com/api?test=value

# With pin
curl -s --pinnedpubkey key.pub https://target.com/api?test=value

# With HPKP
curl -s --hpkp pin https://target.com/api?test=value

# With HPKP backup
curl -s --hkp-backup pin https://target.com/api?test=value

# With CRL
curl -s --crlfile crl.pem https://target.com/api?test=value

# With issuer
curl -s --cert-status https://target.com/api?test=value

# With OCSP
curl -s --ocsp https://target.com/api?test=value

# With stapling
curl -s --stapling https://target.com/api?test=value

# With ALPN
curl -s --alpn https://target.com/api?test=value

# With NPN
curl -s --npn https://target.com/api?test=value

# With SNI
curl -s --sni https://target.com/api?test=value

# With TLS13
curl -s --tls13 https://target.com/api?test=value

# With TLS12
curl -s --tls12 https://target.com/api?test=value

# With TLS11
curl -s --tls11 https://target.com/api?test=value

# With TLS10
curl -s --tls10 https://target.com/api?test=value

# With TLS
curl -s --tls https://target.com/api?test=value

# With SSL
curl -s --ssl https://target.com/api?test=value

# With no SSL
curl -s --no-ssl https://target.com/api?test=value

# With insecure
curl -s -k https://target.com/api?test=value
```

## Case Studies

### Case Study 1: Enterprise Web Application

**Target:** Large enterprise web application with complex functionality
**Objective:** Discover all hidden parameters and test for vulnerabilities

The application had multiple user roles and complex business logic. Traditional parameter discovery was insufficient.

**Approach:**
1. Used Arjun for initial parameter discovery
2. Deployed ffuf for comprehensive fuzzing
3. Used Param Miner for deep parameter mining
4. Implemented recursive fuzzing for nested parameters
5. Tested parameter pollution vulnerabilities

**Results:**
- 234 parameters discovered
- 56 hidden parameters found
- 89 parameter pollution vulnerabilities
- 12 SQL injection vulnerabilities
- 23 XSS vulnerabilities

**Key Findings:**
- Hidden admin parameters accessible without authentication
- Parameter pollution bypasses access controls
- SQL injection in search parameters
- XSS in reflected parameters
- IDOR through parameter manipulation

**Lessons Learned:**
- Hidden parameters often have weaker security
- Parameter pollution can bypass security controls
- Recursive fuzzing reveals complex parameter structures
- Response analysis helps prioritize findings

### Case Study 2: REST API Security Assessment

**Target:** Modern REST API with complex data models
**Objective:** Discover all API parameters and test for vulnerabilities

The API had multiple endpoints with complex parameter structures. Documentation was incomplete.

**Approach:**
1. Analyzed API documentation for parameter patterns
2. Used ffuf for endpoint and parameter discovery
3. Deployed wfuzz for value fuzzing
4. Implemented custom scripts for parameter validation
5. Tested for common API vulnerabilities

**Results:**
- 123 endpoints discovered
- 234 parameters found
- 56 undocumented parameters
- 89 potential vulnerabilities
- 12 critical vulnerabilities

**Key Findings:**
- Undocumented parameters expose internal functionality
- Mass assignment vulnerabilities in user creation
- IDOR through parameter manipulation
- SQL injection in search parameters
- Rate limiting bypass through parameter pollution

**Lessons Learned:**
- API documentation is often incomplete
- Undocumented parameters may have weaker security
- Mass assignment is a common API vulnerability
- Parameter validation is critical for API security

### Case Study 3: GraphQL API Testing

**Target:** GraphQL API with complex schema
**Objective:** Discover all GraphQL parameters and test for vulnerabilities

The GraphQL API had complex query structures with nested parameters. Traditional fuzzing was insufficient.

**Approach:**
1. Analyzed GraphQL schema for parameter patterns
2. Used custom scripts for GraphQL parameter discovery
3. Implemented query complexity analysis
4. Tested for GraphQL-specific vulnerabilities
5. Analyzed authorization on discovered parameters

**Results:**
- 123 types discovered
- 234 fields enumerated
- 56 arguments found
- 89 potential vulnerabilities
- 12 authorization vulnerabilities

**Key Findings:**
- Introspection reveals entire schema
- Excessive data exposure through nested queries
- Missing authorization on sensitive fields
- Query complexity attacks possible
- Parameter injection in GraphQL queries

**Lessons Learned:**
- GraphQL requires specialized testing techniques
- Introspection is a powerful discovery tool
- Query complexity analysis is essential
- Authorization must be tested on every field

## Bypass Techniques

### Rate Limiting Bypass

Distribute requests across multiple source IPs. Implement random delays between requests. Use different session tokens for each request. Rotate user agents and headers. Exploit rate limiting inconsistencies across parameters.

### Input Validation Bypass

Test for common encoding bypasses. Use Unicode and UTF-8 encoding. Try different comment styles. Implement case variation. Test for parameter pollution.

### Authentication Bypass

Test for broken authentication mechanisms. Exploit JWT vulnerabilities. Test for session fixation. Analyze token handling and validation. Test for credential stuffing vulnerabilities.

### Authorization Bypass

Test for IDOR vulnerabilities. Exploit broken access control mechanisms. Test for privilege escalation. Analyze authorization logic. Test for horizontal and vertical privilege escalation.

### WAF Bypass

Use encoding techniques to bypass filters. Implement case variation in payloads. Use chunked transfer encoding to split requests. Try different HTTP methods and content types. Use HTTP/2 protocol features for bypass.

### Filter Evasion

Use comment injection in SQL queries. Implement Unicode and UTF-8 encoding. Try different comment styles. Use alternative encoding for payloads. Test for case sensitivity in filters.

## Advanced Techniques

### Machine Learning for Parameter Prediction

Use machine learning models to predict parameter patterns. Train models on known parameter structures. Implement anomaly detection for parameter behavior. Use clustering to group similar parameters.

### Automated Parameter Generation

Generate parameters based on application patterns. Use templates and rules for generation. Implement context-aware parameter creation. Automate parameter validation.

### Dynamic Parameter Analysis

Analyze application behavior with parameters. Monitor parameter impact on responses. Track parameter dependencies. Document parameter relationships.

### Schema-Based Parameter Testing

Use API schemas for test generation. Implement schema-based fuzzing. Validate parameter responses against schemas. Generate test cases from schemas.

### GraphQL-Specific Parameter Testing

Implement GraphQL-specific parameter testing. Analyze query complexity. Test for GraphQL injection. Validate parameter authorization.

### Continuous Parameter Monitoring

Monitor applications for new parameters. Track parameter changes over time. Alert on unauthorized parameter usage. Document parameter evolution.

## Detection Indicators

### Network-Level Indicators

High volume of parameter requests indicates fuzzing. Unusual parameter patterns suggest automated tools. Multiple requests to non-existent parameters indicate enumeration. Abnormal request timing reveals automated behavior.

### Log Analysis Indicators

Web server logs show parameter fuzzing patterns. Application logs record parameter attempts. WAF logs capture blocked requests. IDS/IPS logs detect fuzzing activity.

### Behavioral Indicators

Sequential parameter requests indicate automated fuzzing. Random parameter patterns suggest mutation testing. Consistent timing reveals scripted behavior. Large bursts of requests indicate aggressive fuzzing.

### Source Indicators

Known fuzzing tool user agents appear in logs. IP addresses from known fuzzing infrastructure are flagged. Request patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

Parameter discovery reveals hidden functionality. Each parameter represents a potential attack vector. Hidden parameters may expose sensitive functionality. Parameter vulnerabilities can lead to data exposure.

### Indirect Impact

Discovery enables further security testing. Findings guide vulnerability assessment. Regular discovery reduces attack surface. Automated discovery enables continuous security assessment.

### Risk Quantification

Hidden parameters pose high risk. Authentication vulnerabilities create critical risk. Authorization bypass enables data exposure. Parameter pollution can bypass security controls.

### Business Impact

Comprehensive parameter discovery improves security posture. Findings enable risk-based decision making. Regular discovery supports compliance requirements. Automated discovery reduces manual effort.

## Common Pitfalls

### Tool Configuration Errors

Incorrect wordlists miss parameters. Missing authentication credentials prevent access. Wrong endpoint patterns miss important parameters. Inadequate rate limits cause blocking.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering false positives wastes time. Ignoring response patterns creates inaccurate assessments. Missing output formats prevent integration.

### Scope Management Issues

Discovering out-of-scope parameters violates engagement rules. Not verifying authorization creates legal risks. Ignoring parameter boundaries leads to false assumptions. Failing to document scope complicates reporting.

### Resource Management Problems

Running too many fuzzing scans simultaneously causes network congestion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Aggressive fuzzing without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### CI/CD Pipeline Integration

Automate parameter discovery in continuous integration pipelines. Trigger discoveries on code changes. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed discovered parameters into vulnerability scanners. Prioritize scanning based on parameter sensitivity. Correlate findings with other testing. Update scanner targets automatically.

### API Gateway Integration

Integrate with API gateways for parameter analysis. Use gateway APIs for parameter enumeration. Analyze gateway configurations. Test gateway security controls.

### Monitoring System Integration

Integrate with application monitoring systems. Set up alerts for new parameters. Monitor for parameter changes. Track discovery trends over time.

### Documentation Platform Integration

Sync with API documentation platforms. Update documentation with discoveries. Track documentation accuracy. Generate documentation from discoveries.

## Reporting Templates

### Executive Summary

```
Parameter Fuzzing Report
Date: [DATE]
Target: [SCOPE]
Tools Used: [LIST]
Total Parameters: [NUMBER]
Hidden Parameters: [NUMBER]
Vulnerable: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Fuzzing Methodology:
1. Parameter Discovery: [METHOD]
2. Fuzzing Technique: [TOOLS]
3. Response Analysis: [APPROACH]
4. Validation: [METHOD]

Results Breakdown:
- Total Parameters: [NUMBER]
- Query Parameters: [NUMBER]
- POST Parameters: [NUMBER]
- Header Parameters: [NUMBER]
- Cookie Parameters: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
Parameter,Location,Method,Response,Status,Vulnerability
test,Query,GET,200,Valid,None
admin,Query,GET,403,Valid,Authorization Bypass
id,POST,POST,200,Valid,IDOR
search,Query,GET,200,Valid,SQL Injection
```

## Practice Labs

### Lab 1: Basic Parameter Discovery

**Setup:** Create a web application with hidden parameters
**Exercise:** Use Arjun to discover all parameters
**Goal:** Find all documented and undocumented parameters

### Lab 2: Parameter Fuzzing

**Setup:** Application with parameter-based vulnerabilities
**Exercise:** Use ffuf for parameter fuzzing
**Goal:** Identify parameter vulnerabilities

### Lab 3: Parameter Pollution

**Setup:** Application vulnerable to parameter pollution
**Exercise:** Test parameter pollution bypass techniques
**Goal:** Bypass security controls using parameter pollution

### Lab 4: Response Analysis

**Setup:** Application with different responses to parameters
**Exercise:** Analyze responses to identify valid parameters
**Goal:** Filter false positives based on responses

## Ethics

Parameter fuzzing must be performed within legal and ethical boundaries. Always obtain written authorization before fuzzing any application. Respect rate limits and do not cause denial of service. Do not fuzz applications outside the authorized scope. Use appropriate fuzzing techniques for the environment. Store fuzzing results securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not fuzz personal applications without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Discover parameters
arjun -u https://target.com/api

# Fuzz parameters
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt

# Fuzz POST parameters
ffuf -u https://target.com/api -X POST -d "FUZZ=test" -w wordlist.txt

# Fuzz headers
ffuf -u https://target.com/api -H "FUZZ: test" -w wordlist.txt

# Fuzz cookies
ffuf -u https://target.com/api -b "FUZZ=test" -w wordlist.txt

# Recursive fuzzing
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -recursion

# Rate limiting
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -rate 100

# Output to JSON
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -o output.json -of json

# Verbose output
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -v

# Filter responses
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -fc 404

# Match responses
ffuf -u https://target.com/api?FUZZ=test -w wordlist.txt -mc 200
```

### Tool Comparison

| Tool | Type | Speed | Coverage | Ease |
|------|------|-------|----------|------|
| ffuf | Fuzzing | Fast | High | Medium |
| wfuzz | Fuzzing | Medium | High | Medium |
| Arjun | Discovery | Fast | High | High |
| Param Miner | Mining | Slow | Very High | Low |
| curl | Manual | Slow | Medium | High |

### Common Parameters

```
Query:
- id
- user
- page
- limit
- sort
- order
- filter
- search
- q
- query

POST:
- username
- password
- email
- name
- data
- json
- xml
- file
- upload

Headers:
- Authorization
- X-API-Key
- X-Auth-Token
- Cookie
- Session
- CSRF-Token

Cookies:
- session
- token
- auth
- user
- id
```

### Payload Lists

```
SQL Injection:
- ' OR '1'='1
- ' OR 1=1--
- ' OR 1=1#
- ' UNION SELECT NULL--
- admin'--

XSS:
- <script>alert(1)</script>
- <img src=x onerror=alert(1)>
- <svg onload=alert(1)>
- javascript:alert(1)

Command Injection:
- ; ls
- | ls
- `ls`
- $(ls)
- && ls

Path Traversal:
- ../../../etc/passwd
- ....//....//etc/passwd
- %2e%2e%2f%2e%2e%2fetc/passwd
```

### Response Codes

```
200: OK - Parameter exists and is valid
301/302: Redirect - Parameter may exist
400: Bad Request - Parameter may exist but invalid
403: Forbidden - Parameter exists but unauthorized
404: Not Found - Parameter does not exist
405: Method Not Allowed - Wrong HTTP method
429: Too Many Requests - Rate limited
500: Server Error - Parameter may cause issues
```

### Fuzzing Workflow

```
1. Discovery:
   - Identify endpoints
   - Analyze existing parameters
   - Create wordlists

2. Fuzzing:
   - Basic parameter discovery
   - Advanced fuzzing
   - Recursive fuzzing

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
curl -v "https://target.com/api?test=value"

# Debug curl
curl -v "https://target.com/api?test=value"

# Test connectivity
ping target.com

# Test DNS
nslookup target.com

# Test SSL
openssl s_client -connect target.com:443

# Test API
curl -s https://target.com/api/health

# Check response headers
curl -I "https://target.com/api?test=value"

# Check response body
curl -s "https://target.com/api?test=value" | jq .

# Check for errors
curl -s "https://target.com/api?test=value" | jq '.error'

# Check for rate limiting
curl -I "https://target.com/api?test=value" | grep -i "rate"
```
