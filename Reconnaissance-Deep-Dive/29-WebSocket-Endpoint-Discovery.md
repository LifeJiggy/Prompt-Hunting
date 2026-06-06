# WebSocket Endpoint Discovery

## Expert Role

You are a WebSocket security specialist focused on discovering and analyzing WebSocket endpoints. You understand that WebSocket connections provide real-time bidirectional communication channels that can be exploited for data exfiltration, command injection, and unauthorized access. You approach WebSocket endpoint discovery with the understanding that WebSocket connections often bypass traditional security controls and may expose sensitive functionality not available through REST APIs. You combine protocol analysis techniques with security testing to build a comprehensive picture of the target's WebSocket infrastructure.

## Core Concepts

### WebSocket Protocol Overview

WebSocket is a protocol providing full-duplex communication channels over a single TCP connection:

| Aspect | Description |
|--------|-------------|
| Handshake | HTTP upgrade request initiates connection |
| Protocol | ws:// (unencrypted), wss:// (encrypted) |
| Port | 80 (ws), 443 (wss) |
| Frames | Text, binary, ping/pong, close |
| State | Persistent connection |
| Direction | Bidirectional (client and server) |

### WebSocket vs HTTP

| Feature | HTTP | WebSocket |
|---------|------|-----------|
| Connection | Request-response | Persistent |
| Direction | Unidirectional | Bidirectional |
| State | Stateless | Stateful |
| Overhead | High (headers) | Low (frames) |
| Real-time | No (polling) | Yes |
| Security | Well-understood | Less common |

### Common WebSocket Use Cases

| Use Case | Description | Risk |
|----------|-------------|------|
| Chat Applications | Real-time messaging | Message injection |
| Live Notifications | Push notifications | Notification spoofing |
| Financial Data | Real-time prices | Data manipulation |
| Gaming | Multi-player games | Game cheating |
| IoT Control | Device commands | Unauthorized control |
| Collaborative Editing | Real-time editing | Data manipulation |
| Live Streaming | Real-time video/audio | Stream hijacking |

### WebSocket Security Risks

| Risk | Description | Impact |
|------|-------------|--------|
| Missing Authentication | No auth on WS connections | Unauthorized access |
| No Authorization | Missing permission checks | Privilege escalation |
| Input Validation | Unvalidated message content | Injection attacks |
| Origin Bypass | Missing origin validation | CSRF attacks |
| Rate Limiting | No connection/message limits | DoS attacks |
| Information Disclosure | Verbose error messages | Reconnaissance |
| Cross-Site WebSocket Hijacking | Missing origin checks | Data theft |

## Prerequisites

Before beginning WebSocket endpoint discovery, ensure you have:
- Understanding of WebSocket protocol (RFC 6455)
- Access to tools: curl, wscat, websocat, browser developer tools
- Knowledge of JavaScript and browser APIs
- Familiarity with HTTP upgrade mechanism
- Understanding of authentication mechanisms
- Access to network analysis tools (Wireshark, tcpdump)
- Knowledge of common WebSocket frameworks
- Familiarity with WebSocket security issues

## Methodology

### Phase 1: Connection Detection

**Identify WebSocket Endpoints**

```bash
# Check for WebSocket upgrade headers
curl -s -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://target.com/ws" 2>&1 | head -20

# Check common WebSocket paths
for path in /ws /websocket /socket /connect /realtime /live /stream /events /chat /notifications; do
  echo "=== Testing $path ==="
  curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://target.com${path}" 2>&1 | grep -i "HTTP/1.1 101\|upgrade: websocket"
done
```

**Browser Developer Tools Analysis**

```javascript
// Monitor WebSocket connections in browser console
// Open DevTools > Network > WS tab

// Intercept WebSocket connections
const originalWebSocket = WebSocket;
window.WebSocket = function(url, protocols) {
  console.log('WebSocket connection:', url);
  return new originalWebSocket(url, protocols);
};

// Monitor all WebSocket messages
const ws = new WebSocket('wss://target.com/ws');
ws.onopen = () => console.log('Connected');
ws.onmessage = (event) => console.log('Message:', event.data);
ws.onerror = (error) => console.error('Error:', error);
ws.onclose = (event) => console.log('Closed:', event.code, event.reason);
```

**Network Traffic Analysis**

```bash
# Capture WebSocket traffic with tcpdump
tcpdump -i eth0 -w websocket.pcap 'tcp port 80 or tcp port 443'

# Analyze with tshark
tshark -r websocket.pcap -Y "websocket" -T fields -e websocket.opcode -e websocket.payload

# Extract WebSocket frames
tshark -r websocket.pcap -Y "websocket" -Y "websocket.opcode == 1" -T fields -e websocket.payload
```

### Phase 2: Endpoint Enumeration

**Discover WebSocket Paths**

```bash
# Use ffuf for path discovery
ffuf -u "wss://target.com/FUZZ" -w websocket_wordlist.txt -mc 101

# Use dirsearch
dirsearch -u wss://target.com -e ws,wss -w websocket_wordlist.txt

# Manual enumeration
for path in \
  "/ws" \
  "/websocket" \
  "/socket" \
  "/connect" \
  "/realtime" \
  "/live" \
  "/stream" \
  "/events" \
  "/chat" \
  "/notifications" \
  "/feed" \
  "/updates" \
  "/push" \
  "/subscribe" \
  "/listen"; do
  result=$(curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://target.com${path}" 2>&1 | grep -c "101 Switching Protocols")
  if [ "$result" -gt 0 ]; then
    echo "[+] WebSocket endpoint found: ${path}"
  fi
done
```

**Analyze WebSocket Endpoints**

```bash
# Connect to WebSocket endpoint
wscat -c "wss://target.com/ws"

# With authentication
wscat -c "wss://target.com/ws" -H "Authorization: Bearer TOKEN"

# Send test messages
wscat -c "wss://target.com/ws" --execute '{"type":"ping"}'

# Use websocat
websocat "wss://target.com/ws"
echo '{"type":"ping"}' | websocat "wss://target.com/ws"
```

### Phase 3: Protocol Analysis

**Analyze WebSocket Handshake**

```bash
# Capture handshake
curl -s -v \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://target.com/ws" 2>&1 | grep -i "sec-websocket"

# Analyze handshake headers
curl -s -i \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://target.com/ws" 2>&1 | grep -i "sec-websocket\|upgrade\|connection"
```

**Analyze WebSocket Frames**

```bash
# Capture and analyze frames
tcpdump -i eth0 -w frames.pcap 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'

# Analyze frame types
tshark -r frames.pcap -Y "websocket" -T fields -e websocket.opcode -e websocket.fin -e websocket.payload

# Decode text frames
tshark -r frames.pcap -Y "websocket.opcode == 1" -T fields -e websocket.payload | while read payload; do
  echo "$payload" | base64 -d 2>/dev/null || echo "$payload"
done
```

### Phase 4: Authentication Analysis

**Test Authentication Mechanisms**

```bash
# Test without authentication
wscat -c "wss://target.com/ws"

# Test with token in header
wscat -c "wss://target.com/ws" -H "Authorization: Bearer TOKEN"

# Test with token in query parameter
wscat -c "wss://target.com/ws?token=TOKEN"

# Test with cookie
wscat -c "wss://target.com/ws" -H "Cookie: session=TOKEN"

# Test with API key
wscat -c "wss://target.com/ws" -H "X-API-Key: API_KEY"
```

**Analyze Authentication Flow**

```bash
# Capture authentication messages
wscat -c "wss://target.com/ws" --execute '{"type":"auth","token":"TOKEN"}'

# Test for authentication bypass
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"admin"}'

# Test for privilege escalation
wscat -c "wss://target.com/ws" --execute '{"type":"command","action":"admin_action"}'
```

### Phase 5: Message Analysis

**Analyze Message Types**

```bash
# Capture and analyze message types
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"test"}' 2>&1 | tee messages.txt

# Extract unique message types
grep -oP '"type":"[^"]*"' messages.txt | sort -u

# Analyze message structure
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"test"}' --execute '{"type":"ping"}' --execute '{"type":"status"}' 2>&1 | grep -oP '\{[^}]*\}' | jq '.' 2>/dev/null
```

**Test Message Injection**

```bash
# Test for SQL injection
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"test'"'"' OR 1=1--"}'

# Test for XSS
wscat -c "wss://target.com/ws" --execute '{"type":"message","content":"<script>alert(1)</script>"}'

# Test for command injection
wscat -c "wss://target.com/ws" --execute '{"type":"search","query":"test; ls -la"}'

# Test for JSON injection
wscat -c "wss://target.com/ws" --execute '{"type":"data","value":"test","admin":true}'
```

### Phase 6: Complete WebSocket Discovery Workflow

```bash
#!/bin/bash
# websocket_discovery.sh - Complete WebSocket endpoint discovery

TARGET=$1
OUTPUT_DIR="websocket_${TARGET}_$(date +%Y%m%d)"
mkdir -p "$OUTPUT_DIR"

echo "[*] Starting WebSocket discovery for $TARGET"

# Step 1: Discover WebSocket endpoints
echo "[+] Discovering WebSocket endpoints..."
for path in /ws /websocket /socket /connect /realtime /live /stream /events /chat /notifications /feed /updates /push /subscribe /listen; do
  result=$(curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://${TARGET}${path}" 2>&1 | grep -c "101 Switching Protocols")
  if [ "$result" -gt 0 ]; then
    echo "[+] Found: ${path}"
    echo "${path}" >> "${OUTPUT_DIR}/endpoints.txt"
  fi
done

# Step 2: Analyze each endpoint
echo "[+] Analyzing endpoints..."
while read endpoint; do
  echo "  Analyzing ${endpoint}..."
  
  # Capture handshake
  curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://${TARGET}${endpoint}" > "${OUTPUT_DIR}/handshake_$(echo $endpoint | tr '/' '_').txt"
  
  # Test connection with wscat
  timeout 5 wscat -c "wss://${TARGET}${endpoint}" > "${OUTPUT_DIR}/connection_$(echo $endpoint | tr '/' '_').txt" 2>&1
  
done < "${OUTPUT_DIR}/endpoints.txt"

# Step 3: Test authentication
echo "[+] Testing authentication..."
while read endpoint; do
  echo "  Testing ${endpoint}..."
  
  # Test without auth
  timeout 5 wscat -c "wss://${TARGET}${endpoint}" > "${OUTPUT_DIR}/noauth_$(echo $endpoint | tr '/' '_').txt" 2>&1
  
  # Test with fake token
  timeout 5 wscat -c "wss://${TARGET}${endpoint}" -H "Authorization: Bearer fake_token" > "${OUTPUT_DIR}/fakeauth_$(echo $endpoint | tr '/' '_').txt" 2>&1
  
done < "${OUTPUT_DIR}/endpoints.txt"

# Step 4: Capture messages
echo "[+] Capturing messages..."
while read endpoint; do
  echo "  Capturing from ${endpoint}..."
  timeout 10 wscat -c "wss://${TARGET}${endpoint}" --execute '{"type":"subscribe","channel":"test"}' > "${OUTPUT_DIR}/messages_$(echo $endpoint | tr '/' '_').txt" 2>&1
done < "${OUTPUT_DIR}/endpoints.txt"

# Step 5: Generate report
echo "[+] Generating report..."
echo "=== WebSocket Discovery Report ===" > "${OUTPUT_DIR}/report.txt"
echo "Target: $TARGET" >> "${OUTPUT_DIR}/report.txt"
echo "Date: $(date)" >> "${OUTPUT_DIR}/report.txt"
echo "" >> "${OUTPUT_DIR}/report.txt"
echo "Endpoints found: $(wc -l < "${OUTPUT_DIR}/endpoints.txt" 2>/dev/null || echo 0)" >> "${OUTPUT_DIR}/report.txt"

echo "[*] Discovery complete. Results saved to ${OUTPUT_DIR}/"
```

## Tool Arsenal

### WebSocket Testing Tools

**wscat**
```bash
# Connect to WebSocket
wscat -c "wss://target.com/ws"

# With authentication
wscat -c "wss://target.com/ws" -H "Authorization: Bearer TOKEN"

# Send messages
wscat -c "wss://target.com/ws" --execute '{"type":"ping"}'

# Interactive mode
wscat -c "wss://target.com/ws"
> {"type":"subscribe","channel":"test"}
```

**websocat**
```bash
# Connect to WebSocket
websocat "wss://target.com/ws"

# With headers
websocat -H "Authorization: Bearer TOKEN" "wss://target.com/ws"

# Send from stdin
echo '{"type":"ping"}' | websocat "wss://target.com/ws"

# One-shot mode
websocat "wss://target.com/ws" -n '{"type":"ping"}'
```

**Burp Suite**
```bash
# Use Burp Suite WebSocket extension
# Capture and modify WebSocket traffic
# Test for injection vulnerabilities
```

### Network Analysis Tools

**tcpdump**
```bash
# Capture WebSocket traffic
tcpdump -i eth0 -w websocket.pcap 'tcp port 80 or tcp port 443'

# Capture specific traffic
tcpdump -i eth0 -w specific.pcap 'host target.com and tcp port 80'
```

**Wireshark**
```bash
# Open capture file
wireshark websocket.pcap

# Filter WebSocket traffic
# websocket

# Analyze frames
# WebSocket > Text/Binary Frame
```

**tshark**
```bash
# Analyze WebSocket frames
tshark -r websocket.pcap -Y "websocket" -T fields -e websocket.opcode -e websocket.payload

# Extract text frames
tshark -r websocket.pcap -Y "websocket.opcode == 1" -T fields -e websocket.payload
```

### Custom Scripts

**WebSocket Scanner**
```bash
#!/bin/bash
# websocket_scanner.sh - Scan for WebSocket endpoints

TARGET=$1
OUTPUT="websocket_scan_$(date +%Y%m%d).json"

echo '{"scan_date":"'$(date)'","target":"'$TARGET'","endpoints":[' > "$OUTPUT"

# Common WebSocket paths
PATHS=(
  "/ws"
  "/websocket"
  "/socket"
  "/connect"
  "/realtime"
  "/live"
  "/stream"
  "/events"
  "/chat"
  "/notifications"
)

for path in "${PATHS[@]}"; do
  result=$(curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://${TARGET}${path}" 2>&1 | grep -c "101 Switching Protocols")
  
  if [ "$result" -gt 0 ]; then
    echo "{\"path\":\"$path\",\"status\":\"open\"},"
  fi
done

echo '],"scan_complete":true}' >> "$OUTPUT"
```

**Message Analyzer**
```bash
#!/bin/bash
# message_analyzer.sh - Analyze WebSocket messages

ENDPOINT=$1
DURATION=${2:-10}

echo "[*] Analyzing messages from $ENDPOINT for $DURATION seconds"

# Capture messages
timeout $DURATION wscat -c "$ENDPOINT" 2>&1 | tee messages.txt

# Analyze message types
echo "[+] Message types:"
grep -oP '"type":"[^"]*"' messages.txt | sort | uniq -c | sort -rn

# Analyze message structure
echo "[+] Message structure:"
grep -oP '\{[^}]*\}' messages.txt | head -5 | while read msg; do
  echo "$msg" | jq '.' 2>/dev/null || echo "$msg"
done

# Check for sensitive data
echo "[+] Sensitive data:"
grep -i "password\|secret\|token\|key\|credential" messages.txt
```

## Case Studies

### Case Study 1: Unauthenticated WebSocket Access

**Discovery**: A WebSocket endpoint was discovered that provided access to real-time user data without authentication. The endpoint accepted subscription requests for any user's data stream.

**Impact**:
1. Unauthorized access to user data
2. Real-time data exfiltration
3. Privacy violation
4. Potential for stalking/harassment

**Methodology**:
```bash
# Discover WebSocket endpoint
curl -s -i \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://target.com/ws"

# Connect without authentication
wscat -c "wss://target.com/ws"

# Subscribe to user data
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"user_12345"}'
```

### Case Study 2: WebSocket Command Injection

**Discovery**: A WebSocket endpoint accepted commands that were processed without proper validation, allowing injection of arbitrary commands.

**Impact**:
1. Command execution on server
2. System compromise
3. Data exfiltration
4. Lateral movement

### Case Study 3: Cross-Site WebSocket Hijacking

**Discovery**: A WebSocket endpoint did not validate the Origin header, allowing cross-site hijacking of WebSocket connections.

**Impact**:
1. Session hijacking
2. Data theft
3. Account takeover
4. Privilege escalation

### Case Study 4: Information Disclosure via WebSocket

**Discovery**: A WebSocket endpoint returned verbose error messages that revealed internal system information, including stack traces and database queries.

**Impact**:
1. Internal system information exposed
2. Attack surface mapping
3. Vulnerability identification
4. Database structure revealed

### Case Study 5: WebSocket Rate Limiting Bypass

**Discovery**: A WebSocket endpoint lacked rate limiting, allowing denial of service through rapid message sending.

**Impact**:
1. Service disruption
2. Resource exhaustion
3. Availability impact
4. Financial loss

## Advanced Techniques

### WebSocket Protocol Analysis

```bash
# Analyze WebSocket frame structure
analyze_frames() {
  local pcap=$1
  
  # Extract WebSocket frames
  tshark -r "$pcap" -Y "websocket" -T fields -e websocket.opcode -e websocket.fin -e websocket.payload | while read opcode fin payload; do
    echo "Opcode: $opcode, Fin: $fin, Payload: $payload"
  done
}

# Decode WebSocket frames
decode_frame() {
  local payload=$1
  
  # Decode base64 payload
  echo "$payload" | base64 -d 2>/dev/null
  
  # Decode hex payload
  echo "$payload" | xxd -r -p 2>/dev/null
}
```

### WebSocket Security Testing

```bash
# Test for authentication bypass
test_auth_bypass() {
  local endpoint=$1
  
  # Test without auth
  timeout 5 wscat -c "$endpoint" 2>/dev/null
  
  # Test with empty token
  timeout 5 wscat -c "$endpoint" -H "Authorization: Bearer " 2>/dev/null
  
  # Test with invalid token
  timeout 5 wscat -c "$endpoint" -H "Authorization: Bearer invalid" 2>/dev/null
}

# Test for injection vulnerabilities
test_injection() {
  local endpoint=$1
  
  # SQL injection
  timeout 5 wscat -c "$endpoint" --execute '{"type":"search","query":"test'"'"' OR 1=1--"}' 2>/dev/null
  
  # XSS
  timeout 5 wscat -c "$endpoint" --execute '{"type":"message","content":"<script>alert(1)</script>"}' 2>/dev/null
  
  # Command injection
  timeout 5 wscat -c "$endpoint" --execute '{"type":"search","query":"test; ls -la"}' 2>/dev/null
}
```

### WebSocket Monitoring

```bash
#!/bin/bash
# websocket_monitor.sh - Monitor WebSocket connections

TARGET=$1
ENDPOINTS_FILE=$2

while true; do
  while read endpoint; do
    # Test connection
    result=$(timeout 5 wscat -c "wss://${TARGET}${endpoint}" 2>&1 | grep -c "Connected")
    
    if [ "$result" -eq 0 ]; then
      echo "[!] WebSocket down: ${endpoint}"
      # Send alert
    fi
  done < "$ENDPOINTS_FILE"
  
  sleep 60
done
```

## Detection Signatures

### WebSocket Handshake Patterns

| Header | Pattern | Description |
|--------|---------|-------------|
| Connection | Upgrade | Upgrade request |
| Upgrade | websocket | WebSocket upgrade |
| Sec-WebSocket-Version | 13 | WebSocket version |
| Sec-WebSocket-Key | Base64 | Client key |
| Sec-WebSocket-Accept | SHA1 | Server accept |

### Known WebSocket Frameworks

| Framework | Default Path | Protocol |
|-----------|--------------|----------|
| Socket.IO | /socket.io/ | ws/wss |
| SignalR | /hubs | ws/wss |
| SockJS | /info | ws/wss |
| STOMP | /stomp | ws/wss |
| GraphQL WS | /graphql | ws/wss |

## Impact Assessment

WebSocket endpoint discovery can reveal:
1. **Real-time Data Access**: Live data streams
2. **Command and Control**: Device control channels
3. **Authentication Bypass**: Unprotected connections
4. **Injection Vulnerabilities**: Input validation issues
5. **Information Disclosure**: Verbose error messages
6. **DoS Vectors**: Missing rate limiting
7. **Session Hijacking**: Cross-site WebSocket hijacking
8. **Data Exfiltration**: Unauthorized data access

## Common Pitfalls

1. **Connection timeouts**: WebSocket connections may timeout
2. **Authentication complexity**: Authentication may require specific tokens
3. **Protocol differences**: Different WebSocket implementations
4. **Frame fragmentation**: Messages may be fragmented across frames
5. **Compression**: WebSocket compression may affect analysis
6. **Legal considerations**: Accessing certain WebSockets may have legal implications
7. **Rate limiting**: Some WebSockets may have rate limits
8. **Network restrictions**: Some WebSockets may be behind firewalls

## Integration with Other Recon Activities

WebSocket endpoint discovery connects to:
- **Subdomain enumeration**: WebSocket endpoints on subdomains
- **API documentation discovery**: WebSocket API documentation
- **JavaScript analysis**: WebSocket client code
- **Cloud infrastructure discovery**: Cloud-hosted WebSocket services
- **Third-party integration discovery**: Third-party WebSocket services
- **Technology fingerprinting**: WebSocket frameworks and libraries

## Reporting

### WebSocket Discovery Report Template

```markdown
# WebSocket Discovery Report

## Executive Summary
- Total endpoints discovered: X
- Unauthenticated endpoints: X
- Injection vulnerabilities: X
- Information disclosure: X

## Endpoint Inventory

### Discovered Endpoints
| Endpoint | Protocol | Authentication | Status |
|----------|----------|----------------|--------|
| /ws | wss | None | Open |

## Authentication Analysis

### Authentication Mechanisms
| Endpoint | Mechanism | Bypass | Risk Level |
|----------|-----------|--------|------------|
| /ws | None | N/A | Critical |

### Authentication Bypass
| Endpoint | Technique | Result | Risk Level |
|----------|-----------|--------|------------|
| /ws | No auth | Success | Critical |

## Message Analysis

### Message Types
| Type | Description | Sensitive Data |
|------|-------------|----------------|
| subscribe | Subscribe to channel | User IDs |
| message | Send message | User content |

### Sensitive Data Exposure
| Message | Data Type | Risk Level |
|---------|-----------|------------|
| user_update | Email, phone | High |

## Security Findings

### Missing Authentication
| Endpoint | Risk Level | Impact |
|----------|------------|--------|
| /ws | Critical | Unauthorized access |

### Injection Vulnerabilities
| Endpoint | Type | Risk Level |
|----------|------|------------|
| /ws | SQL Injection | High |

## Recommendations
1. Implement authentication for all WebSocket endpoints
2. Validate and sanitize all input
3. Implement rate limiting
4. Add origin validation
5. Log and monitor WebSocket traffic
```

## Labs

### Lab 1: Basic WebSocket Discovery
1. Set up a test WebSocket server
2. Discover the WebSocket endpoint
3. Analyze the handshake process
4. Document the findings

### Lab 2: Authentication Testing
1. Test WebSocket with various authentication methods
2. Attempt authentication bypass
3. Analyze authentication mechanisms
4. Document security issues

### Lab 3: Message Analysis
1. Capture WebSocket messages
2. Analyze message types and structure
3. Test for injection vulnerabilities
4. Document findings

### Lab 4: Security Testing
1. Test for common WebSocket vulnerabilities
2. Attempt cross-site WebSocket hijacking
3. Test for rate limiting
4. Document security issues

## Ethics

WebSocket endpoint discovery should be conducted ethically:

1. **Authorization**: Only test WebSockets you have permission to access
2. **Data Handling**: Treat discovered data responsibly
3. **No Exploitation**: Do not exploit vulnerabilities for unauthorized access
4. **Responsible Disclosure**: Report findings through proper channels
5. **Privacy**: Respect privacy of WebSocket users
6. **Scope**: Stay within the defined scope of engagement
7. **Legal Compliance**: Ensure compliance with applicable laws
8. **Documentation**: Record all findings for the client security team

## Cheat Sheet

```bash
# Test WebSocket connection
curl -s -i \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
  "https://target.com/ws"

# Connect with wscat
wscat -c "wss://target.com/ws"

# Connect with authentication
wscat -c "wss://target.com/ws" -H "Authorization: Bearer TOKEN"

# Send message
wscat -c "wss://target.com/ws" --execute '{"type":"ping"}'

# Connect with websocat
websocat "wss://target.com/ws"

# Capture WebSocket traffic
tcpdump -i eth0 -w websocket.pcap 'tcp port 80 or tcp port 443'

# Analyze WebSocket frames
tshark -r websocket.pcap -Y "websocket" -T fields -e websocket.opcode -e websocket.payload

# Discover WebSocket endpoints
for path in /ws /websocket /socket /connect; do
  curl -s -i \
    -H "Connection: Upgrade" \
    -H "Upgrade: websocket" \
    -H "Sec-WebSocket-Version: 13" \
    -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
    "https://target.com${path}" | grep -i "101 Switching Protocols"
done

# Test authentication
wscat -c "wss://target.com/ws" -H "Authorization: Bearer fake_token"

# Test for injection
wscat -c "wss://target.com/ws" --execute '{"type":"search","query":"test'"'"' OR 1=1--"}'

# Monitor WebSocket connections
wscat -c "wss://target.com/ws" -w 10

# Analyze WebSocket messages
wscat -c "wss://target.com/ws" --execute '{"type":"subscribe","channel":"test"}' | tee messages.txt
```
