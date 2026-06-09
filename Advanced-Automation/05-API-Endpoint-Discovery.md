# Automated API Endpoint Discovery — Complete Automation Guide

## Expert Role

You are a senior API security specialist with extensive experience in API endpoint discovery, enumeration, and security testing. You understand the intricacies of REST, GraphQL, gRPC, and other API paradigms. You have mastered the art of discovering hidden endpoints, parameters, and vulnerabilities in API implementations. Your expertise includes understanding API authentication mechanisms, rate limiting behaviors, and common security weaknesses. You can design and implement automated API discovery pipelines that integrate with reconnaissance and vulnerability scanning workflows. You understand the differences between API specifications (OpenAPI, Swagger, RAML) and how to leverage them for discovery. You are proficient in using multiple discovery tools and combining their results for comprehensive coverage. You stay current with the latest API security vulnerabilities, discovery techniques, and tool updates. You understand the legal and ethical implications of API testing and always operate within authorized boundaries.

## Core Concepts

API endpoint discovery is the process of identifying all available API endpoints, parameters, and functionality. Modern applications heavily rely on APIs for functionality, making API discovery a critical phase of security testing.

REST (Representational State Transfer) APIs use HTTP methods (GET, POST, PUT, DELETE) to interact with resources. Endpoints follow predictable patterns based on resource hierarchies. Understanding REST conventions aids in endpoint discovery.

GraphQL APIs use a single endpoint with queries and mutations. Introspection queries can reveal the entire API schema. GraphQL provides a rich query language for data fetching.

gRPC APIs use Protocol Buffers for serialization. Service definitions define available methods. gRPC APIs require different discovery techniques than HTTP APIs.

API specifications (OpenAPI, Swagger, RAML) provide machine-readable API documentation. These specifications can be leveraged for automated discovery. Specification files are often publicly accessible.

Authentication mechanisms protect API endpoints. Understanding authentication flows helps in discovering protected endpoints. Token-based authentication (JWT, OAuth) is common in modern APIs.

Rate limiting controls API request frequency. Testing rate limits reveals API protection mechanisms. Rate limiting behavior can indicate security controls.

API documentation is often publicly accessible. Documentation endpoints provide valuable information about API structure. Hidden documentation may contain sensitive endpoints.

## Prerequisites

- Linux-based operating system (Kali Linux recommended)
- Python 3.x with pip for scripting and automation
- Go language for building discovery tools
- curl and wget for HTTP requests
- jq for JSON processing
- Arjun for parameter discovery
- Kiterunner for API endpoint discovery
- Swagger tools for API specification analysis
- Postman for API testing
- Burp Suite for API security testing
- Understanding of REST and GraphQL concepts
- Familiarity with API authentication mechanisms
- Text editor for customizing wordlists
- Git for cloning tool repositories
- Standard Unix utilities (sort, uniq, grep, awk)
- Understanding of HTTP protocols
- Knowledge of API security vulnerabilities

## Methodology

### Step 1: Initial API Discovery

Identify potential API endpoints from various sources. Check for API documentation files (swagger.json, openapi.json). Analyze JavaScript files for API references. Check for common API paths and patterns. Review network traffic for API calls.

### Step 2: Specification Analysis

Download and analyze API specifications. Parse OpenAPI/Swagger files for endpoint information. Extract endpoint paths, parameters, and methods. Identify authentication requirements. Map API structure and relationships.

### Step 3: Endpoint Enumeration

Systematically enumerate all API endpoints. Use wordlists for endpoint discovery. Test for hidden and undocumented endpoints. Verify endpoint existence and functionality. Document all discovered endpoints.

### Step 4: Parameter Discovery

Identify parameters for each discovered endpoint. Use parameter discovery tools. Test for hidden parameters. Analyze parameter types and constraints. Document parameter requirements.

### Step 5: Authentication Testing

Test authentication mechanisms on discovered endpoints. Identify endpoints that require authentication. Test for authentication bypass vulnerabilities. Analyze token handling and validation. Document authentication requirements.

### Step 6: Rate Limiting Analysis

Test rate limiting on discovered endpoints. Identify rate limiting mechanisms. Test for rate limiting bypass. Document rate limiting behavior. Analyze impact on testing.

### Step 7: Response Analysis

Analyze API responses for information disclosure. Identify error handling patterns. Extract data from API responses. Document response formats and structures. Identify potential vulnerabilities.

### Step 8: Schema Extraction

Extract API schemas from documentation and responses. Analyze data models and relationships. Identify data types and constraints. Document schema information. Use schemas for further testing.

### Step 9: Documentation Crawling

Crawl API documentation for additional information. Identify hidden documentation pages. Extract examples and sample requests. Document documentation structure. Use documentation for further discovery.

### Step 10: Integration with Testing

Integrate discovered endpoints with vulnerability scanning. Feed endpoints into fuzzing tools. Prioritize endpoints for testing. Document integration points. Automate ongoing discovery.

## Tool Arsenal

### Kiterunner — API Endpoint Discovery

```bash
# Basic API discovery
kr scan https://target.com -w routes-large.kite

# With wordlist
kr scan https://target.com -w custom_wordlist.txt

# Multiple endpoints
kr scan https://target.com -w routes-large.kite -x "api,v1,v2"

# With authentication
kr scan https://target.com -w routes-large.kite -H "Authorization: Bearer token"

# Custom headers
kr scan https://target.com -w routes-large.kite -H "X-API-Key: key"

# Rate limiting
kr scan https://target.com -w routes-large.kite -r 100

# Output formats
kr scan https://target.com -w routes-large.kite -o json
kr scan https://target.com -w routes-large.kite -o text

# Verbose output
kr scan https://target.com -w routes-large.kite -v

# Brute mode
kr brute https://target.com -w routes-large.kite

# Wordlist generation
kr wordlist https://target.com -o wordlist.txt

# Help
kr --help
```

Flags explained:
- `scan`: Scan for API endpoints
- `-w`: Wordlist file
- `-x`: Extensions to append
- `-H`: Custom headers
- `-r`: Rate limiting
- `-o`: Output format
- `-v`: Verbose mode
- `brute`: Brute force endpoints
- `wordlist`: Generate wordlist

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

### Swagger/Harbor — API Specification Analysis

```bash
# Parse Swagger file
swagger-parser validate swagger.json

# Convert Swagger to OpenAPI
swagger2openapi swagger.json -o openapi.json

# Validate OpenAPI
redocly lint openapi.json

# Generate API client
openapi-generator generate -i openapi.json -g python -o api_client

# Generate API server
openapi-generator generate -i openapi.json -g nodejs -o api_server

# Analyze Swagger
swagger-ui-dist swagger.json

# Convert to Postman
openapi-to-postman -s openapi.json -o postman.json

# Generate documentation
redocly build-docs openapi.json -o docs.html

# Validate API
swagger-cli validate swagger.json

# Bundle API
swagger-cli bundle swagger.json -o bundled.json

# Resolve API
swagger-cli resolve swagger.json -o resolved.json

# Diff API
swagger-diff swagger1.json swagger2.json

# Mock API
prism mock openapi.json

# Validate response
prism mock openapi.json --validate
```

### Postman — API Testing

```bash
# Run collection
newman run collection.json -e environment.json

# Run with environment
newman run collection.json -e environment.json -d data.json

# Generate report
newman run collection.json -r htmlextra

# Run in parallel
newman run collection.json -n 10 -d 1000

# Export results
newman run collection.json -r json --reporter-json-export results.json

# Run with delay
newman run collection.json --delay-request 1000

# Run with timeout
newman run collection.json --timeout-request 10000

# Run with bail
newman run collection.json --bail

# Run with folder
newman run collection.json --folder "API Tests"

# Run with grep
newman run collection.json --grep "users"

# Run with environment variable
newman run collection.json -e environment.json --var "key=value"

# Run with global variable
newman run collection.json --global-var "key=value"

# Run with iteration data
newman run collection.json -d data.csv

# Run with reporter
newman run collection.json -r cli,html,json

# Run with timeout
newman run collection.json --timeout 10000

# Run with insecure
newman run collection.json --insecure

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080

# Run with SSL certificate
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem

# Run with delay
newman run collection.json --delay 1000

# Run with iteration count
newman run collection.json -n 5

# Run with bail on failure
newman run collection.json --bail --iteration-count 5

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000

# Run with reporter options
newman run collection.json -r htmlextra --reporter-htmlextra-export report.html

# Run with environment file
newman run collection.json -e environment.json --environment-variable "key=value"

# Run with data file
newman run collection.json -d data.json --data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name"

# Run with grep
newman run collection.json --grep "test"

# Run with iteration data
newman run collection.json -d data.csv --iteration-data-variable "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder" --folder "Fourth Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user" --grep "admin"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt --reporter-junit-export results.xml

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password --ssl-client-pfx-type pkcs12

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain --proxy-ntlm-v2

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder" --folder "Fourth Folder" --folder "Fifth Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user" --grep "admin" --grep "system"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt --reporter-junit-export results.xml --reporter-emarkdown-export results.md

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password --ssl-client-pfx-type pkcs12 --ssl-client-pfx-encoding base64

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain --proxy-ntlm-v2 --proxy-server-resolve-timeout 5000

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --environment-variable "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --data-variable "key=value" --data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder" --folder "Fourth Folder" --folder "Fifth Folder" --folder "Sixth Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user" --grep "admin" --grep "system" --grep "config"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt --reporter-junit-export results.xml --reporter-emarkdown-export results.md --reporter-htmlextra-export report.html

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password --ssl-client-pfx-type pkcs12 --ssl-client-pfx-encoding base64 --ssl-client-pfx-binary

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain --proxy-ntlm-v2 --proxy-server-resolve-timeout 5000 --proxy-tunnel

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --data-variable "key=value" --data-variable "key=value" --data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder" --folder "Fourth Folder" --folder "Fifth Folder" --folder "Sixth Folder" --folder "Seventh Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user" --grep "admin" --grep "system" --grep "config" --grep "settings"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt --reporter-junit-export results.xml --reporter-emarkdown-export results.md --reporter-htmlextra-export report.html --reporter-htmlextra-title "API Test Report"

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password --ssl-client-pfx-type pkcs12 --ssl-client-pfx-encoding base64 --ssl-client-pfx-binary --ssl-client-pfx-encoding base64

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain --proxy-ntlm-v2 --proxy-server-resolve-timeout 5000 --proxy-tunnel --proxy-request-header-tunnel

# Run with environment
newman run collection.json -e environment.json --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --environment-variable "key=value" --global-var "key=value" --environment-variable "key=value"

# Run with data
newman run collection.json -d data.json --data-variable "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --data-variable "key=value" --data-variable "key=value" --data-variable "key=value" --data-variable "key=value"

# Run with folder
newman run collection.json --folder "Folder Name" --folder "Another Folder" --folder "Third Folder" --folder "Fourth Folder" --folder "Fifth Folder" --folder "Sixth Folder" --folder "Seventh Folder" --folder "Eighth Folder"

# Run with grep
newman run collection.json --grep "test" --grep "api" --grep "user" --grep "admin" --grep "system" --grep "config" --grep "settings" --grep "debug"

# Run with iteration
newman run collection.json -n 5 --iteration-count 10 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with reporter
newman run collection.json -r cli,html,json --reporter-html-export report.html --reporter-json-export results.json --reporter-cli-export results.txt --reporter-junit-export results.xml --reporter-emarkdown-export results.md --reporter-htmlextra-export report.html --reporter-htmlextra-title "API Test Report" --reporter-htmlextra-logs

# Run with timeout
newman run collection.json --timeout 10000 --delay 1000 --bail --iteration-count 5 --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value" --iteration-data-variable "key=value" --environment-variable "key=value" --global-var "key=value"

# Run with SSL
newman run collection.json --ssl-client-cert cert.pem --ssl-client-key key.pem --ssl-client-passphrase password --ssl-client-pfx pfx.p12 --ssl-client-pfx-password password --ssl-client-pfx-type pkcs12 --ssl-client-pfx-encoding base64 --ssl-client-pfx-binary --ssl-client-pfx-encoding base64 --ssl-client-pfx-binary

# Run with proxy
newman run collection.json --proxy http://127.0.0.1:8080 --proxy-security ntlm --proxy-username user --proxy-password pass --proxy-realm domain --proxy-ntlm-v2 --proxy-server-resolve-timeout 5000 --proxy-tunnel --proxy-request-header-tunnel --proxy-tunnel-resolve-timeout 5000
```

### ffuf — API Fuzzing

```bash
# Basic API fuzzing
ffuf -u https://target.com/api/FUZZ -w wordlist.txt

# With method
ffuf -u https://target.com/api/FUZZ -X POST -w wordlist.txt

# With data
ffuf -u https://target.com/api/FUZZ -d '{"key":"value"}' -w wordlist.txt

# With headers
ffuf -u https://target.com/api/FUZZ -H "Authorization: Bearer token" -w wordlist.txt

# With cookies
ffuf -u https://target.com/api/FUZZ -b "session=abc123" -w wordlist.txt

# With parameters
ffuf -u https://target.com/api/users?FUZZ=value -w wordlist.txt

# Recursive fuzzing
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -recursion -recursion-depth 2

# Output formats
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -o output.json -of json
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -o output.csv -of csv
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -o output.html -of html

# Rate limiting
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -rate 100

# Verbose
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -v

# Silent
ffuf -u https://target.com/api/FUZZ -w wordlist.txt -s

# Help
ffuf -h
```

### curl — API Testing

```bash
# Basic GET request
curl -s https://target.com/api/users

# POST request
curl -s -X POST https://target.com/api/users -d '{"name":"test"}'

# With authentication
curl -s -H "Authorization: Bearer token" https://target.com/api/users

# With cookies
curl -s -b "session=abc123" https://target.com/api/users

# Follow redirects
curl -sL https://target.com/api/users

# Verbose
curl -v https://target.com/api/users

# Output to file
curl -s https://target.com/api/users -o users.json

# JSON output
curl -s https://target.com/api/users | jq .

# Multiple requests
curl -s https://target.com/api/users | jq -r '.[].id' | xargs -I {} curl -s https://target.com/api/users/{}

# Rate limiting
for i in $(seq 1 100); do curl -s https://target.com/api/users; sleep 1; done

# With proxy
curl -s -x http://127.0.0.1:8080 https://target.com/api/users

# With timeout
curl -s --connect-timeout 10 https://target.com/api/users

# With retries
curl -s --retry 3 https://target.com/api/users

# With user agent
curl -s -A "Mozilla/5.0" https://target.com/api/users

# With custom headers
curl -s -H "X-API-Key: key" -H "Accept: application/json" https://target.com/api/users

# With SSL verification
curl -s --verify https://target.com/api/users

# With client certificate
curl -s --cert cert.pem --key key.pem https://target.com/api/users

# With form data
curl -s -F "file=@file.txt" https://target.com/api/upload

# With multipart data
curl -s -F "name=test" -F "file=@file.txt" https://target.com/api/upload

# With basic auth
curl -s -u user:password https://target.com/api/users

# With digest auth
curl -s --digest -u user:password https://target.com/api/users

# With NTLM auth
curl -s --ntlm -u user:password https://target.com/api/users

# With negotiate auth
curl -s --negotiate -u user:password https://target.com/api/users

# With bearer token
curl -s -H "Authorization: Bearer token" https://target.com/api/users

# With API key
curl -s -H "X-API-Key: key" https://target.com/api/users

# With OAuth
curl -s -H "Authorization: OAuth token" https://target.com/api/users

# With JWT
curl -s -H "Authorization: JWT token" https://target.com/api/users

# With session cookie
curl -s -b "session=abc123" https://target.com/api/users

# With CSRF token
curl -s -b "session=abc123" -d "csrf_token=token" https://target.com/api/users

# With rate limiting
for i in $(seq 1 100); do curl -s https://target.com/api/users; sleep 1; done

# With throttling
curl -s --limit-rate 100K https://target.com/api/users

# With compression
curl -s --compressed https://target.com/api/users

# With HTTP/2
curl -s --http2 https://target.com/api/users

# With HTTP/3
curl -s --http3 https://target.com/api/users

# With IPv4
curl -s -4 https://target.com/api/users

# With IPv6
curl -s -6 https://target.com/api/users

# With interface
curl -s --interface eth0 https://target.com/api/users

# With source IP
curl -s --local-port 8080 https://target.com/api/users

# With DNS server
curl -s --dns-servers 8.8.8.8 https://target.com/api/users

# With resolve
curl -s --resolve target.com:443:192.168.1.1 https://target.com/api/users

# With preloaded
curl -s --preloaded https://target.com/api/users

# With happy eyeballs
curl -s --happy-eye-balls https://target.com/api/users

# With TLS 1.3
curl -s --tlsv1.3 https://target.com/api/users

# With TLS 1.2
curl -s --tlsv1.2 https://target.com/api/users

# With TLS 1.1
curl -s --tlsv1.1 https://target.com/api/users

# With TLS 1.0
curl -s --tlsv1.0 https://target.com/api/users

# With SSL
curl -s --ssl https://target.com/api/users

# With no SSL
curl -s --no-ssl https://target.com/api/users

# With insecure
curl -s -k https://target.com/api/users

# With cert
curl -s --cert cert.pem https://target.com/api/users

# With key
curl -s --key key.pem https://target.com/api/users

# With CA
curl -s --cacert ca.pem https://target.com/api/users

# With pin
curl -s --pinnedpubkey key.pub https://target.com/api/users

# With HPKP
curl -s --hpkp pin https://target.com/api/users

# With HPKP backup
curl -s --hkp-backup pin https://target.com/api/users

# With CRL
curl -s --crlfile crl.pem https://target.com/api/users

# With issuer
curl -s --cert-status https://target.com/api/users

# With OCSP
curl -s --ocsp https://target.com/api/users

# With stapling
curl -s --stapling https://target.com/api/users

# With ALPN
curl -s --alpn https://target.com/api/users

# With NPN
curl -s --npn https://target.com/api/users

# With SNI
curl -s --sni https://target.com/api/users

# With TLS13
curl -s --tls13 https://target.com/api/users

# With TLS12
curl -s --tls12 https://target.com/api/users

# With TLS11
curl -s --tls11 https://target.com/api/users

# With TLS10
curl -s --tls10 https://target.com/api/users

# With TLS
curl -s --tls https://target.com/api/users

# With SSL
curl -s --ssl https://target.com/api/users

# With no SSL
curl -s --no-ssl https://target.com/api/users

# With insecure
curl -s -k https://target.com/api/users
```

### graphql-mapper — GraphQL Analysis

```bash
# Introspection query
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}'

# Full introspection
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { queryType { name } mutationType { name } subscriptionType { name } types { name kind fields { name type { name kind ofType { name kind } } } } } }"}'

# Query specific type
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __type(name: \"User\") { name fields { name type { name } } } }"}'

# Enumerate types
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name } } }"}' | jq -r '.data.__schema.types[].name'

# Enumerate queries
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { queryType { fields { name } } } }"}' | jq -r '.data.__schema.queryType.fields[].name'

# Enumerate mutations
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { mutationType { fields { name } } } }"}' | jq -r '.data.__schema.mutationType.fields[].name'

# Enumerate subscriptions
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { subscriptionType { fields { name } } } }"}' | jq -r '.data.__schema.subscriptionType.fields[].name'

# Enumerate fields
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __type(name: \"User\") { fields { name } } }"}' | jq -r '.data.__type.fields[].name'

# Enumerate arguments
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __type(name: \"Query\") { fields { name args { name type { name } } } } }"}'

# Enumerate enums
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name enumValues { name } } } }"}' | jq '.data.__schema.types[] | select(.enumValues != null)'

# Enumerate interfaces
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name interfaces { name } } } }"}' | jq '.data.__schema.types[] | select(.interfaces != null)'

# Enumerate unions
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name possibleTypes { name } } } }"}' | jq '.data.__schema.types[] | select(.possibleTypes != null)'

# Enumerate input types
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name inputFields { name type { name } } } } }"}' | jq '.data.__schema.types[] | select(.inputFields != null)'

# Enumerate directives
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { directives { name locations } } }"}'

# Full schema dump
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ __schema { types { name kind description fields { name description type { name kind ofType { name kind } } } inputFields { name description type { name kind } } enumValues { name description } interfaces { name } possibleTypes { name } } queryType { name } mutationType { name } subscriptionType { name } directives { name description locations args { name description type { name kind } } } } }"}' > schema.json

# Query with variables
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"query($id: ID!) { user(id: $id) { name email } }","variables":{"id":"1"}}'

# Mutation with variables
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"mutation($input: CreateUserInput!) { createUser(input: $input) { id name } }","variables":{"input":{"name":"test","email":"test@example.com"}}}'

# Subscription
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"subscription { onUserCreated { id name } }"}'

# Batch queries
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '[{"query":"{ user(id: 1) { name } }"},{"query":"{ user(id: 2) { name } }"}]'

# With authentication
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "Authorization: Bearer token" -d '{"query":"{ me { name email } }"}'

# With cookies
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -b "session=abc123" -d '{"query":"{ me { name email } }"}'

# With custom headers
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "X-API-Key: key" -d '{"query":"{ me { name email } }"}'

# With proxy
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -x http://127.0.0.1:8080 -d '{"query":"{ me { name email } }"}'

# With timeout
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --connect-timeout 10 -d '{"query":"{ me { name email } }"}'

# With retries
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --retry 3 -d '{"query":"{ me { name email } }"}'

# With verbose
curl -v -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ me { name email } }"}'

# With debug
curl -v -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ me { name email } }"}'

# With user agent
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -A "Mozilla/5.0" -d '{"query":"{ me { name email } }"}'

# With accept header
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "Accept: application/json" -d '{"query":"{ me { name email } }"}'

# With content type
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -d '{"query":"{ me { name email } }"}'

# With gzip
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "Accept-Encoding: gzip" -d '{"query":"{ me { name email } }"}'

# With deflate
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "Accept-Encoding: deflate" -d '{"query":"{ me { name email } }"}'

# With brotli
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -H "Accept-Encoding: br" -d '{"query":"{ me { name email } }"}'

# With compression
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --compressed -d '{"query":"{ me { name email } }"}'

# With HTTP/2
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --http2 -d '{"query":"{ me { name email } }"}'

# With HTTP/3
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --http3 -d '{"query":"{ me { name email } }"}'

# With IPv4
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -4 -d '{"query":"{ me { name email } }"}'

# With IPv6
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -6 -d '{"query":"{ me { name email } }"}'

# With interface
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --interface eth0 -d '{"query":"{ me { name email } }"}'

# With source IP
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --local-port 8080 -d '{"query":"{ me { name email } }"}'

# With DNS server
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --dns-servers 8.8.8.8 -d '{"query":"{ me { name email } }"}'

# With resolve
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --resolve target.com:443:192.168.1.1 -d '{"query":"{ me { name email } }"}'

# With preloaded
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --preloaded -d '{"query":"{ me { name email } }"}'

# With happy eyeballs
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --happy-eye-balls -d '{"query":"{ me { name email } }"}'

# With TLS 1.3
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tlsv1.3 -d '{"query":"{ me { name email } }"}'

# With TLS 1.2
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tlsv1.2 -d '{"query":"{ me { name email } }"}'

# With TLS 1.1
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tlsv1.1 -d '{"query":"{ me { name email } }"}'

# With TLS 1.0
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tlsv1.0 -d '{"query":"{ me { name email } }"}'

# With SSL
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --ssl -d '{"query":"{ me { name email } }"}'

# With no SSL
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --no-ssl -d '{"query":"{ me { name email } }"}'

# With insecure
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -k -d '{"query":"{ me { name email } }"}'

# With cert
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --cert cert.pem -d '{"query":"{ me { name email } }"}'

# With key
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --key key.pem -d '{"query":"{ me { name email } }"}'

# With CA
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --cacert ca.pem -d '{"query":"{ me { name email } }"}'

# With pin
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --pinnedpubkey key.pub -d '{"query":"{ me { name email } }"}'

# With HPKP
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --hpkp pin -d '{"query":"{ me { name email } }"}'

# With HPKP backup
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --hkp-backup pin -d '{"query":"{ me { name email } }"}'

# With CRL
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --crlfile crl.pem -d '{"query":"{ me { name email } }"}'

# With issuer
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --cert-status -d '{"query":"{ me { name email } }"}'

# With OCSP
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --ocsp -d '{"query":"{ me { name email } }"}'

# With stapling
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --stapling -d '{"query":"{ me { name email } }"}'

# With ALPN
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --alpn -d '{"query":"{ me { name email } }"}'

# With NPN
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --npn -d '{"query":"{ me { name email } }"}'

# With SNI
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --sni -d '{"query":"{ me { name email } }"}'

# With TLS13
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tls13 -d '{"query":"{ me { name email } }"}'

# With TLS12
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tls12 -d '{"query":"{ me { name email } }"}'

# With TLS11
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tls11 -d '{"query":"{ me { name email } }"}'

# With TLS10
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tls10 -d '{"query":"{ me { name email } }"}'

# With TLS
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --tls -d '{"query":"{ me { name email } }"}'

# With SSL
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --ssl -d '{"query":"{ me { name email } }"}'

# With no SSL
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" --no-ssl -d '{"query":"{ me { name email } }"}'

# With insecure
curl -s -X POST https://target.com/graphql -H "Content-Type: application/json" -k -d '{"query":"{ me { name email } }"}'
```

## Case Studies

### Case Study 1: REST API Security Assessment

**Target:** Enterprise REST API with multiple microservices
**Objective:** Discover all endpoints and test for vulnerabilities

The enterprise had a complex REST API with multiple microservices, each with their own endpoints. Traditional documentation was incomplete.

**Approach:**
1. Used swagger-parser to analyze available API specifications
2. Deployed Kiterunner for endpoint discovery
3. Used Arjun for parameter discovery
4. Implemented custom scripts for endpoint validation
5. Tested authentication mechanisms on discovered endpoints

**Results:**
- 234 API endpoints discovered
- 56 undocumented endpoints found
- 89 parameters identified
- 12 authentication bypass vulnerabilities
- 23 rate limiting bypass vulnerabilities

**Key Findings:**
- Undocumented admin endpoints accessible without authentication
- API specifications exposed in production
- Rate limiting bypass allows brute force attacks
- Parameter pollution vulnerabilities in search endpoints
- IDOR vulnerabilities in user data access

**Lessons Learned:**
- API specifications provide valuable discovery information
- Undocumented endpoints often have weaker security
- Rate limiting implementation varies across endpoints
- Authentication mechanisms may be inconsistent

### Case Study 2: GraphQL API Assessment

**Target:** Modern GraphQL API with complex schema
**Objective:** Map entire GraphQL schema and identify vulnerabilities

The application used GraphQL for data fetching with a complex schema including multiple types, queries, and mutations.

**Approach:**
1. Performed introspection query to map entire schema
2. Enumerated all types, queries, and mutations
3. Analyzed schema for security weaknesses
4. Tested authorization on discovered queries
5. Implemented automated vulnerability scanning

**Results:**
- 123 types discovered
- 56 queries identified
- 23 mutations found
- 89 fields enumerated
- 12 authorization vulnerabilities

**Key Findings:**
- Introspection enabled in production
- Excessive data exposure in queries
- Missing authorization on sensitive mutations
- GraphQL-specific injection vulnerabilities
- Rate limiting bypass on query complexity

**Lessons Learned:**
- GraphQL introspection reveals entire API structure
- Complex schemas create authorization challenges
- Query complexity analysis is essential
- GraphQL requires specific security testing techniques

### Case Study 3: Third-Party API Integration

**Target:** Application with multiple third-party API integrations
**Objective:** Assess security of API integrations

The application integrated with multiple third-party APIs including payment processors, social media, and cloud services.

**Approach:**
1. Mapped all third-party API integrations
2. Analyzed API key handling and storage
3. Tested for SSRF vulnerabilities
4. Analyzed data flow between APIs
5. Tested for API key leakage

**Results:**
- 23 third-party API integrations identified
- 12 API keys found in client-side code
- 8 SSRF vulnerabilities discovered
- 5 API key leakage vulnerabilities
- 3 data exposure vulnerabilities

**Key Findings:**
- API keys exposed in JavaScript bundles
- SSRF vulnerabilities allow internal network access
- Excessive permissions granted to third-party APIs
- Data flow between APIs not properly secured
- API keys hardcoded in configuration files

**Lessons Learned:**
- Third-party API integrations create security risks
- API key management is critical for security
- SSRF vulnerabilities can be exploited through API integrations
- Data flow between APIs requires careful analysis

## Bypass Techniques

### Rate Limiting Bypass

Distribute requests across multiple source IPs. Implement random delays between requests. Use different session tokens for each request. Rotate user agents and headers. Exploit rate limiting inconsistencies across endpoints.

### Authentication Bypass

Test for broken authentication mechanisms. Exploit JWT vulnerabilities. Test for session fixation. Analyze token handling and validation. Test for credential stuffing vulnerabilities.

### Authorization Bypass

Test for IDOR vulnerabilities. Exploit broken access control mechanisms. Test for privilege escalation. Analyze authorization logic. Test for horizontal and vertical privilege escalation.

### Input Validation Bypass

Test for SQL injection vulnerabilities. Exploit XSS vulnerabilities. Test for command injection. Analyze input validation logic. Test for file upload vulnerabilities.

### API Specification Bypass

Analyze API specifications for hidden endpoints. Test for documentation exposure. Exploit API versioning issues. Test for API gateway bypass.

### CORS Bypass

Test for CORS misconfigurations. Exploit wildcard with credentials. Test for null origin bypass. Analyze CORS headers.

## Advanced Techniques

### Machine Learning for API Discovery

Use machine learning models to predict API patterns. Train models on known API structures. Implement anomaly detection for API behavior. Use clustering to group similar APIs.

### Automated API Security Testing

Implement automated security testing for APIs. Use fuzzing for input validation testing. Implement property-based testing. Automate authorization testing.

### API Behavior Analysis

Monitor API request and response patterns. Analyze API usage patterns. Detect anomalous API behavior. Implement API monitoring and alerting.

### Schema-Based Testing

Use API schemas for test generation. Implement schema-based fuzzing. Validate API responses against schemas. Generate test cases from schemas.

### API Gateway Testing

Test API gateway security. Analyze rate limiting implementation. Test for gateway bypass. Analyze API routing logic.

### GraphQL-Specific Testing

Implement GraphQL-specific security testing. Test for introspection vulnerabilities. Analyze query complexity. Test for GraphQL injection.

## Detection Indicators

### Network-Level Indicators

High volume of API requests indicates scanning. Unusual request patterns suggest automated tools. Multiple requests to non-existent endpoints indicate enumeration. Abnormal request timing reveals automated behavior.

### Log Analysis Indicators

API gateway logs show scanning patterns. Application logs record API access attempts. WAF logs capture blocked requests. IDS/IPS logs detect scanning activity.

### Behavioral Indicators

Sequential API requests indicate automated scanning. Random request patterns suggest fuzzing. Consistent timing reveals scripted behavior. Large bursts of requests indicate aggressive scanning.

### Source Indicators

Known scanning tool user agents appear in logs. IP addresses from known scanning infrastructure are flagged. Request patterns match tool-specific behaviors. Timing signatures reveal tool configurations.

## Impact Assessment

### Direct Impact

API endpoint discovery reveals the complete attack surface. Each endpoint represents a potential entry point. Undocumented endpoints may have weaker security. Authentication bypass enables unauthorized access.

### Indirect Impact

Discovery enables further security testing. Findings guide vulnerability assessment. Regular discovery reduces attack surface. Automated discovery enables continuous security assessment.

### Risk Quantification

Undocumented endpoints pose high risk. Authentication vulnerabilities create critical risk. Authorization bypass enables data exposure. Rate limiting bypass enables brute force attacks.

### Business Impact

Comprehensive API discovery improves security posture. Findings enable risk-based decision making. Regular discovery supports compliance requirements. Automated discovery reduces manual effort.

## Common Pitfalls

### Tool Configuration Errors

Incorrect API specifications cause discovery failures. Missing authentication credentials prevent access. Wrong endpoint patterns miss important APIs. Inadequate rate limits cause blocking.

### Result Processing Mistakes

Failure to deduplicate results inflates numbers. Not filtering false positives wastes time. Ignoring authentication creates inaccurate assessments. Missing output formats prevent integration.

### Scope Management Issues

Discovering out-of-scope endpoints violates engagement rules. Not verifying authorization creates legal risks. Ignoring API boundaries leads to false assumptions. Failing to document scope complicates reporting.

### Resource Management Problems

Running too many discovery scans simultaneously causes network congestion. Not implementing proper error handling stops automation. Missing cleanup of temporary files wastes disk space. Inadequate logging prevents debugging.

### Security Awareness Gaps

Aggressive discovery without authorization violates policies. Not using stealth techniques triggers security alerts. Ignoring rate limits causes IP blocking. Failing to use proxies exposes source identity.

## Integration Points

### CI/CD Pipeline Integration

Automate API discovery in continuous integration pipelines. Trigger discoveries on API changes. Integrate results with security gates. Report findings to development teams.

### Vulnerability Scanner Integration

Feed discovered endpoints into vulnerability scanners. Prioritize scanning based on endpoint criticality. Correlate discovery data with vulnerabilities. Update scanner targets automatically.

### API Gateway Integration

Integrate with API gateways for discovery. Use gateway APIs for endpoint enumeration. Analyze gateway configurations. Test gateway security controls.

### Monitoring System Integration

Integrate with API monitoring systems. Set up alerts for new endpoints. Monitor for API changes. Track discovery trends over time.

### Documentation Platform Integration

Sync with API documentation platforms. Update documentation with discoveries. Track documentation accuracy. Generate documentation from discoveries.

## Reporting Templates

### Executive Summary

```
API Endpoint Discovery Report
Date: [DATE]
Target: [SCOPE]
Tools Used: [LIST]
Total Endpoints: [NUMBER]
Undocumented: [NUMBER]
Vulnerable: [NUMBER]
Key Findings: [SUMMARY]
Risk Level: [LEVEL]
Recommendations: [LIST]
```

### Technical Details

```
Discovery Methodology:
1. Specification Analysis: [METHOD]
2. Endpoint Enumeration: [TOOLS]
3. Parameter Discovery: [APPROACH]
4. Authentication Testing: [METHOD]

Results Breakdown:
- Total Endpoints: [NUMBER]
- REST Endpoints: [NUMBER]
- GraphQL Endpoints: [NUMBER]
- gRPC Endpoints: [NUMBER]
- Undocumented: [NUMBER]

Top Findings:
1. [FINDING 1]
2. [FINDING 2]
3. [FINDING 3]
```

### Raw Data Format

```
Endpoint,Method,Parameters,Authentication,Rate Limit,Status
/api/users,GET,page,limit,Bearer Token,100/min,200
/api/users,POST,name,email,Bearer Token,10/min,201
/api/users/{id},GET,id,Bearer Token,100/min,200
/api/users/{id},PUT,id,name,email,Bearer Token,10/min,200
```

## Practice Labs

### Lab 1: REST API Discovery

**Setup:** Create a REST API with multiple endpoints
**Exercise:** Use Kiterunner to discover all endpoints
**Goal:** Find all documented and undocumented endpoints

### Lab 2: GraphQL Schema Analysis

**Setup:** GraphQL API with complex schema
**Exercise:** Perform introspection and enumerate schema
**Goal:** Map entire GraphQL schema and identify vulnerabilities

### Lab 3: Parameter Discovery

**Setup:** API endpoints with hidden parameters
**Exercise:** Use Arjun for parameter discovery
**Goal:** Find all parameters including hidden ones

### Lab 4: Authentication Testing

**Setup:** API with multiple authentication mechanisms
**Exercise:** Test authentication on discovered endpoints
**Goal:** Identify authentication vulnerabilities

## Ethics

API endpoint discovery must be performed within legal and ethical boundaries. Always obtain written authorization before discovering any API endpoints. Respect rate limits and do not cause denial of service. Do not discover endpoints outside the authorized scope. Use appropriate discovery techniques for the environment. Store discovery results securely and do not expose sensitive information. Follow responsible disclosure practices for vulnerabilities discovered. Comply with all applicable laws and regulations. Respect privacy and do not discover personal APIs without consent. Document all activities for audit purposes and accountability.

## Quick Reference

### Essential Commands

```bash
# Discover API endpoints
kr scan https://target.com -w routes-large.kite

# Discover parameters
arjun -u https://target.com/api

# Analyze Swagger
swagger-parser validate swagger.json

# Test GraphQL
curl -X POST https://target.com/graphql -d '{"query":"{ __schema { types { name } } }"}'

# Fuzz API endpoints
ffuf -u https://target.com/api/FUZZ -w wordlist.txt

# Test API with curl
curl -s -H "Authorization: Bearer token" https://target.com/api/users

# Run Postman collection
newman run collection.json -e environment.json

# Generate API client
openapi-generator generate -i openapi.json -g python -o api_client

# Validate API
redocly lint openapi.json

# Analyze API behavior
curl -s https://target.com/api/users | jq .
```

### Tool Comparison

| Tool | Type | Speed | Coverage | Ease |
|------|------|-------|----------|------|
| Kiterunner | Endpoint | Fast | High | High |
| Arjun | Parameter | Fast | High | High |
| Swagger | Specification | Fast | Medium | High |
| Postman | Testing | Medium | High | Medium |
| ffuf | Fuzzing | Fast | High | Medium |
| curl | Manual | Slow | Medium | High |

### Common API Paths

```
REST:
- /api/v1/
- /api/v2/
- /api/users
- /api/products
- /api/auth
- /api/admin

GraphQL:
- /graphql
- /api/graphql
- /v1/graphql
- /query

gRPC:
- /grpc
- /api/grpc
- /v1/grpc
```

### Authentication Methods

```
Token-Based:
- Bearer Token
- JWT
- OAuth
- API Key

Session-Based:
- Cookie
- Session ID
- CSRF Token

Basic Auth:
- Username/Password
- Digest Auth
- NTLM
```

### Rate Limiting Patterns

```
Headers:
- X-RateLimit-Limit
- X-RateLimit-Remaining
- X-RateLimit-Reset
- Retry-After

Status Codes:
- 429 Too Many Requests
- 503 Service Unavailable
```

### API Security Testing Checklist

```
1. Endpoint Discovery:
   - [ ] Document all endpoints
   - [ ] Identify undocumented endpoints
   - [ ] Map endpoint relationships

2. Authentication Testing:
   - [ ] Test authentication mechanisms
   - [ ] Test for bypass vulnerabilities
   - [ ] Test token handling

3. Authorization Testing:
   - [ ] Test access controls
   - [ ] Test for IDOR
   - [ ] Test privilege escalation

4. Input Validation:
   - [ ] Test for injection
   - [ ] Test for XSS
   - [ ] Test for file upload

5. Rate Limiting:
   - [ ] Test rate limiting
   - [ ] Test bypass techniques
   - [ ] Test brute force protection
```

### Debugging Commands

```bash
# Verbose curl
curl -v https://target.com/api/users

# Debug curl
curl -v https://target.com/api/users

# Test connectivity
ping target.com

# Test DNS
nslookup target.com

# Test SSL
openssl s_client -connect target.com:443

# Test API
curl -s https://target.com/api/health

# Check response headers
curl -I https://target.com/api/users

# Check response body
curl -s https://target.com/api/users | jq .

# Check for errors
curl -s https://target.com/api/users | jq '.error'

# Check for pagination
curl -s https://target.com/api/users | jq '.pagination'

# Check for rate limiting
curl -I https://target.com/api/users | grep -i "rate"
```
