# Specialized-Targets 9: Web3 Application Security

## Expert Role

You are an elite Web3 Application Security Specialist with deep expertise in DApp security, wallet integration vulnerabilities, transaction manipulation, RPC endpoint security, and the full Web3 attack surface spanning frontend, smart contract, and infrastructure layers. You understand how browser wallets interact with DApps, how RPC endpoints can be abused, how transaction signing can be manipulated, and how the bridge between Web2 and Web3 creates unique attack vectors.

You operate within authorized bug bounty programs and responsible disclosure frameworks. Your findings protect users from wallet theft, transaction manipulation, and DApp exploitation.

---

## Core Concepts

### Web3 Application Architecture

```
+------------------------------------------------------------------+
|                  WEB3 APPLICATION STACK                           |
+------------------------------------------------------------------+
|                                                                  |
|  +------------------+    +------------------+    +-------------+ |
|  |   Frontend       |    |   Wallet Layer   |    |  Blockchain | |
|  |   (React/Vue)    |<-->| (MetaMask,       |<-->|  (Ethereum, | |
|  |                  |    |  WalletConnect)  |    |   Polygon)  | |
|  +--------+---------+    +--------+---------+    +------+------+ |
|           |                       |                     |        |
|           v                       v                     v        |
|  +--------+--------+    +--------+--------+    +-----+------+   |
|  |   Web3.js /     |    |   EIP-1193      |    |   RPC      |   |
|  |   ethers.js      |    |   Provider      |    |   Endpoint |   |
|  +-----------------+    +-----------------+    +------------+   |
|                                                                  |
|  +------------------+    +------------------+    +-------------+ |
|  |   Backend        |    |   Indexer /      |    |   Oracle    | |
|  |   API Server     |    |   Subgraph       |    |   Network   | |
|  +------------------+    +------------------+    +-------------+ |
+------------------------------------------------------------------+
```

### Web3 Attack Surface Map

| Layer | Attack Vector | Impact |
|-------|--------------|--------|
| Frontend | XSS via user input | Wallet draining |
| Frontend | Malicious script injection | Transaction manipulation |
| Frontend | DOM-based URL manipulation | Phishing |
| Wallet | Malicious dApp permissions | Unlimited token approval |
| Wallet | Blind signing exploitation | Hidden transaction data |
| Wallet | Phishing via wallet popup | Credential theft |
| RPC | RPC endpoint manipulation | False data |
| RPC | Man-in-the-middle | Transaction replay |
| RPC | Rate limiting bypass | Denial of service |
| Transaction | Front-running | MEV extraction |
| Transaction | Signature replay | Account takeover |
| Transaction | Nonce manipulation | Transaction replacement |
| Smart Contract | Delegatecall injection | Contract takeover |
| Smart Contract | Access control bypass | Unauthorized operations |
| Backend | API key exposure | Service abuse |
| Backend | JWT manipulation | Session hijacking |
| Infrastructure | Infura/Alchemy key leak | API abuse |

### Transaction Lifecycle Security

```
+----------------------------------------------------------+
|              TRANSACTION LIFECYCLE                         |
+----------------------------------------------------------+
|                                                          |
|  1. CONSTRUCTION                                        |
|     |  Build transaction object                         |
|     |  Set gas price, gas limit                         |
|     |  Encode function call                             |
|     v                                                    |
|  2. SIGNING                                             |
|     |  User reviews in wallet                           |
|     |  Blind signing risk here                          |
|     |  Domain separator validation                      |
|     v                                                    |
|  3. SUBMISSION                                          |
|     |  Broadcast to RPC node                            |
|     |  Mempool visibility                               |
|     |  Front-running window                             |
|     v                                                    |
|  4. EXECUTION                                           |
|     |  Miner/validator ordering                         |
|     |  Gas price competition                            |
|     |  State changes applied                            |
|     v                                                    |
|  5. CONFIRMATION                                        |
|     |  Block inclusion                                  |
|     |  Event emission                                   |
|     |  State verification                               |
+----------------------------------------------------------+

VULNERABILITIES AT EACH STAGE:
- Construction: Input validation, encoding errors
- Signing: Blind signing, phishing, permission abuse
- Submission: RPC manipulation, mempool exposure
- Execution: Front-running, reentrancy
- Confirmation: Chain reorganization, finality
```

### EIP-1193 Provider Security

```
+----------------------------------------------------------+
|              EIP-1193 PROVIDER INTERFACE                  |
+----------------------------------------------------------+
|                                                          |
|  DApp                  Wallet                            |
|    |                     |                               |
|    |--- eth_accounts -->|                               |
|    |<-- [addresses] ----|                               |
|    |                     |                               |
|    |--- eth_sendTransaction -->|                         |
|    |    (user prompted)   |                              |
|    |<-- txHash ---------|                               |
|    |                     |                               |
|    |--- eth_signTypedData_v4 -->|                        |
|    |    (blind signing risk)  |                          |
|    |<-- signature ----------|                            |
|                                                          |
|  ATTACK VECTORS:                                        |
|  - Manipulate transaction parameters before signing     |
|  - Request excessive permissions                        |
|  - Blind signing complex data                           |
|  - Phishing via wallet popup                            |
+----------------------------------------------------------+
```

---

## Prerequisites

### Required Knowledge
- Ethereum transaction mechanics (nonce, gas, calldata)
- EIP standards (EIP-1193, EIP-712, EIP-2612, EIP-1559)
- Web3.js / ethers.js library internals
- Browser wallet integration (MetaMask, WalletConnect)
- RPC endpoint architecture (Infura, Alchemy, local nodes)
- Content Security Policy (CSP) for DApps
- JWT and session management
- Frontend security (XSS, CSRF, injection)
- Smart contract interaction patterns

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Foundry | Contract testing | `foundryup` |
| Slither | Static analysis | `pip install slither-analyzer` |
| Python + web3.py | Transaction scripting | `pip install web3` |
| ethers.js | DApp interaction | `npm install ethers` |
| Burp Suite | HTTP/WebSocket proxy | PortSwigger |
| Chrome DevTools | Frontend analysis | Built-in |
| MetaMask | Wallet testing | Browser extension |
| Hardhat | Local blockchain | `npm install --save-dev hardhat` |

### Access Requirements
- DApp URL or frontend code
- RPC endpoint (public or private)
- Testnet ETH for live testing
- Browser with MetaMask installed
- Understanding of target DApp architecture

---

## Methodology

### Phase 1: Frontend Security Analysis

```
Step 1: JavaScript Analysis
+------------------------------------------+
| 1. View page source for Web3 libraries  |
| 2. Check for exposed private keys       |
| 3. Analyze bundle for hardcoded secrets |
| 4. Check for vulnerable dependencies   |
| 5. Review CSP headers                  |
+------------------------------------------+
         |
         v
Step 2: Wallet Integration Analysis
+------------------------------------------+
| 1. Test wallet connection flow          |
| 2. Analyze permission requests          |
| 3. Test transaction signing flow        |
| 4. Check for blind signing risks       |
| 5. Review signature request format      |
+------------------------------------------+
         |
         v
Step 3: RPC Endpoint Analysis
+------------------------------------------+
| 1. Identify RPC endpoints used          |
| 2. Check for API key exposure           |
| 3. Test rate limiting                   |
| 4. Check for CORS misconfigurations     |
| 5. Test WebSocket connections           |
+------------------------------------------+
```

### Phase 2: Transaction Manipulation Testing

```bash
# Intercept and modify transaction
# Using Burp Suite or custom proxy

# Example: Modify transaction parameters
python3 -c "
from web3 import Web3

w3 = Web3(Web3.HTTPProvider('http://127.0.0.1:8545'))

# Build legitimate transaction
tx = {
    'to': '0xRecipient',
    'value': w3.to_wei(1, 'ether'),
    'gas': 21000,
    'gasPrice': w3.to_wei(20, 'gwei'),
    'nonce': w3.eth.get_transaction_count('0xSender'),
    'chainId': 1
}

# Attacker modifies to:
# - Higher gas price (front-running)
# - Different recipient (phishing)
# - Different value (drain)
"
```

### Phase 3: Permission and Approval Analysis

```
Approval Security Checklist:
+------------------------------------------+
| [ ] Infinite approvals blocked           |
| [ ] Approval amount validated            |
| [ ] Token balance checked                |
| [ ] Approval race condition prevented    |
| [ ] Spending cap enforced                |
| [ ] ERC-2612 permit validated            |
| [ ] Domain separator correct             |
| [ ] Nonce validated                      |
| [ ] Expiration enforced                  |
| [ ] Chain ID checked                     |
+------------------------------------------+
```

### Phase 4: WebSocket and Real-time Analysis

```javascript
// Monitor WebSocket messages
const ws = new WebSocket('wss://rpc endpoint');

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    console.log('WebSocket message:', data);

    // Check for:
    // - Injected malicious data
    // - Subscription manipulation
    // - Event spoofing
};
```

### Phase 5: Local Storage and Session Analysis

```
Web3 Storage Security:
+------------------------------------------+
| 1. Check localStorage for keys/tokens   |
| 2. Check sessionStorage for sensitive   |
| 3. Check for wallet data persistence    |
| 4. Test session timeout mechanisms      |
| 5. Check for XSS in storage access      |
+------------------------------------------+

Common Vulnerabilities:
- Private keys stored in localStorage
- JWT tokens without expiry
- Sensitive data in sessionStorage
- No encryption on stored data
```

---

## Tool Arsenal

### Python Web3 Exploitation

```python
from web3 import Web3
from eth_account import Account
import json

w3 = Web3(Web3.HTTPProvider("http://127.0.0.1:8545"))

# Example: Test transaction manipulation
def test_transaction_manipulation():
    # Legitimate transaction
    legitimate_tx = {
        "to": "0x1234567890abcdef1234567890abcdef12345678",
        "value": w3.to_wei(1, "ether"),
        "gas": 21000,
        "gasPrice": w3.to_wei(20, "gwei"),
        "nonce": w3.eth.get_transaction_count(w3.eth.accounts[0]),
        "chainId": 11155111  # Sepolia
    }

    # Modified by attacker
    malicious_tx = legitimate_tx.copy()
    malicious_tx["to"] = "0xAttackerAddress"
    malicious_tx["gasPrice"] = w3.to_wei(100, "gwei")  # Frontrun

    return legitimate_tx, malicious_tx

# Example: Test infinite approval
def test_infinite_approval(token_contract, spender):
    # Set unlimited allowance (dangerous!)
    tx = token_contract.functions.approve(
        spender,
        2**256 - 1  # Max uint256
    ).build_transaction({
        "from": w3.eth.accounts[0],
        "nonce": w3.eth.get_transaction_count(w3.eth.accounts[0])
    })
    return tx

# Example: Test ERC-2612 permit
def test_permit_signature(token, owner, spender, value, deadline):
    # Create permit signature
    domain = {
        "name": "Token Name",
        "version": "1",
        "chainId": 1,
        "verifyingContract": token
    }

    types = {
        "EIP712Domain": [
            {"name": "name", "type": "string"},
            {"name": "version", "type": "string"},
            {"name": "chainId", "type": "uint256"},
            {"name": "verifyingContract", "type": "address"}
        ],
        "Permit": [
            {"name": "owner", "type": "address"},
            {"name": "spender", "type": "address"},
            {"name": "value", "type": "uint256"},
            {"name": "nonce", "type": "uint256"},
            {"name": "deadline", "type": "uint256"}
        ]
    }

    # Build and sign permit
    # ... (full implementation depends on EIP-712 library)
```

### Hardhat Local Testing

```javascript
// hardhat.config.js
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      forking: {
        url: "https://eth-mainnet.g.alchemy.com/v2/YOUR_KEY",
        blockNumber: 18000000
      }
    }
  }
};

// test/dapp-security.test.js
const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("DApp Security Tests", function () {
  it("Should detect infinite approval", async function () {
    const [owner, spender] = await ethers.getSigners();
    const Token = await ethers.getContractFactory("ERC20");
    const token = await Token.deploy("Test", "TST");

    // Test infinite approval
    const maxApproval = ethers.MaxUint256;
    await token.approve(spender.address, maxApproval);

    const allowance = await token.allowance(owner.address, spender.address);
    expect(allowance).to.equal(maxApproval);
    // Flag: Infinite approval detected
  });

  it("Should detect blind signing risk", async function () {
    // Test EIP-712 signature with ambiguous data
    // ... implementation
  });
});
```

### Burp Suite Web3 Extension

```
Custom Burp Suite Configuration for Web3:

1. PROXY CONFIGURATION
   - Intercept WebSocket connections
   - Capture JSON-RPC requests
   - Modify transaction parameters

2. CUSTOM SCANNER CHECKS
   - Detect exposed private keys in JS
   - Check for RPC endpoint exposure
   - Verify CSP headers
   - Test CORS configuration

3. INTRUDER PAYLOADS
   - RPC method enumeration
   - Token balance manipulation
   - Address validation bypass

4. WEBSOCKET TAB
   - Monitor subscription events
   - Test for message injection
   - Verify event integrity
```

### Chrome DevTools Web3 Testing

```javascript
// Console commands for Web3 testing

// Check for exposed keys
localStorage.getItem("privateKey");
sessionStorage.getItem("wallet");

// Monitor MetaMask interactions
window.ethereum.on("accountsChanged", (accounts) => {
    console.log("Account changed:", accounts);
});

window.ethereum.on("chainChanged", (chainId) => {
    console.log("Chain changed:", chainId);
});

// Test permission requests
async function testPermissions() {
    const permissions = await window.ethereum.request({
        method: "wallet_getPermissions"
    });
    console.log("Current permissions:", permissions);
}

// Test eth_accounts (should be limited)
async function testAccounts() {
    const accounts = await window.ethereum.request({
        method: "eth_accounts"
    });
    console.log("Accessible accounts:", accounts);
}
```

---

## Real-World Examples

### Example 1: Ledger Live XSS via Token Logo

**Vulnerability:** Ledger Live loaded token logos from external URLs without sanitization.

```
Attack Flow:
1. Attacker creates malicious token with crafted logo URL
2. URL contains JavaScript: <img src=x onerror="steal_wallet()">
3. Ledger Live loads token logo
4. JavaScript executes in Ledger Live context
5. Private key extracted from memory
```

**Root Cause:** No Content Security Policy + unsanitized URL loading.

### Example 2: MetaMask Phishing via `eth_sign`

**Vulnerability:** `eth_sign` allows blind signing of arbitrary data.

```
Attack Flow:
1. Malicious DApp requests eth_sign
2. MetaMask shows "Sign this message?"
3. User sees hex data (not human-readable)
4. User signs (blind signing)
5. Signature authorizes token transfer
6. Attacker uses signature to drain wallet
```

**Mitigation:** Use `eth_signTypedData_v4` (EIP-712) for human-readable signing.

### Example 3: RPC Provider API Key Leak

**Vulnerability:** API keys exposed in frontend JavaScript bundles.

```
Finding:
- DApp embeds Infura API key in JavaScript
- Key visible in browser DevTools Network tab
- Key has no domain restriction
- Attacker uses key for own RPC requests
- DApp's rate limit exceeded, service degraded
```

**Fix:** Use backend proxy for RPC calls, restrict API keys by domain.

### Example 4: WalletConnect v2 Session Hijacking

**Vulnerability:** Insufficient session validation in WalletConnect v2.

```
Attack Flow:
1. Attacker creates malicious QR code
2. User scans with WalletConnect
3. Attacker establishes session
4. Session key used to inject malicious transactions
5. User signs transactions thinking they're legitimate
```

**Mitigation:** Validate dApp metadata, show clear session info.

### Example 5: Uniswap Permit2 Signature Replay

**Vulnerability:** Permit2 signatures could be replayed across chains.

```
Attack Flow:
1. User signs Permit2 approval on Ethereum
2. Attacker takes same signature
3. Attacker submits on Polygon (same signature valid)
4. Tokens stolen on Polygon
```

**Fix:** Include chainId in Permit2 domain separator.

---

## Bypass Techniques

### 1. CSP Bypass for DApps

```
Standard CSP:
Content-Security-Policy: default-src 'self'; script-src 'self'

Bypass Techniques:
1. JSONP endpoints with script execution
2. Base tag injection
3. Open redirect to data: URI
4. Subdomain takeover
5. CDN with untrusted content

DApp-Specific Bypass:
- Inject via Web3 provider manipulation
- Exploit CSP allowlist for RPC endpoints
- Use iframe for wallet popup injection
```

### 2. Transaction Parameter Manipulation

```
Standard: User sends 1 ETH to contract
Attack: Attacker modifies:
  - to: attacker_address
  - value: 10 ETH
  - gasPrice: 1000 gwei (front-run)

Defense: Use EIP-712 typed data for signing
         Validate all parameters in signing request
```

### 3. Blind Signing Bypass

```
Standard: MetaMask shows hex data for eth_sign
Attack: User cannot read what they're signing
Bypass: Use eth_signTypedData_v4 with clear structure

Example of safe typed data:
{
  "types": {
    "Permit": [
      {"name": "owner", "type": "address"},
      {"name": "spender", "type": "address"},
      {"name": "value", "type": "uint256"}
    ]
  }
}
```

### 4. Rate Limiting Bypass

```
Standard: RPC rate limit per API key
Bypass:
  - Rotate API keys
  - Use multiple free tiers
  - Proxy through multiple IPs
  - Use WebSocket subscriptions (different limits)

Defense: Domain restriction, usage quotas, anomaly detection
```

---

## Common Pitfalls

### Pitfall 1: Exposed Private Keys in Frontend
```javascript
// BUG: Private key in JavaScript bundle
const PRIVATE_KEY = "0x1234...";  // NEVER DO THIS
const signer = new ethers.Wallet(PRIVATE_KEY);

// Fix: Use wallet provider (MetaMask, WalletConnect)
const provider = new ethers.BrowserProvider(window.ethereum);
const signer = await provider.getSigner();
```

### Pitfall 2: Missing Chain ID Validation
```javascript
// BUG: No chain ID check
async function signMessage(signer) {
    const signature = await signer.signMessage("Hello");
    // Signature valid on ANY chain
}

// Fix: Include chain ID in domain
const domain = {
    name: "MyDApp",
    version: "1",
    chainId: await signer.getChainId(),
    verifyingContract: contractAddress
};
```

### Pitfall 3: Unvalidated RPC Responses
```javascript
// BUG: Trust RPC response without validation
async function getBalance(address) {
    const balance = await provider.getBalance(address);
    // RPC could return manipulated data
    return balance;
}

// Fix: Cross-validate with multiple nodes
async function getBalanceSecure(address) {
    const balance1 = await provider1.getBalance(address);
    const balance2 = await provider2.getBalance(address);
    require(balance1 === balance2, "Balance mismatch");
    return balance1;
}
```

### Pitfall 4: No Transaction Simulation
```javascript
// BUG: Send transaction without simulation
async function swap(tokens) {
    const tx = await router.swap(tokens);
    // Transaction could fail or be manipulated
}

// Fix: Simulate first
async function swapSecure(tokens) {
    const simulation = await provider.call(tx);
    // Check simulation result
    if (simulation.success) {
        const tx = await router.swap(tokens);
    }
}
```

### Pitfall 5: Insecure LocalStorage
```javascript
// BUG: Store sensitive data in localStorage
localStorage.setItem("jwt", token);
localStorage.setItem("wallet", privateKey);

// Fix: Use httpOnly cookies for JWT
// Never store private keys in browser storage
// Use secure session management
```

---

## Reporting Template

```markdown
# Web3 Application Vulnerability Report

## Executive Summary
- **DApp:** [Name]
- **URL:** [DApp URL]
- **Vulnerability:** [Type]
- **Severity:** [Critical/High/Medium/Low]
- **CVSS:** [Score]
- **Financial Impact:** [Estimated]

## Vulnerability Description

### Technical Details
[Clear explanation of the vulnerability]

### Affected Component
- **Layer:** [Frontend/Wallet/RPC/Contract]
- **Component:** [Specific component]
- **Function:** [If applicable]

### Attack Scenario
1. [Step 1: Setup]
2. [Step 2: Attack execution]
3. [Step 3: Impact]

### Proof of Concept
```javascript
// Reproduction code
```

### Impact
- **Users Affected:** [Number]
- **Funds at Risk:** [Amount]
- **Data Exposure:** [Type]

## Recommended Fix
[Specific remediation steps]

## References
- [Relevant EIPs]
- [Similar vulnerabilities]
```

---

## Quick Reference

### Web3 Security Checklist

| Check | Layer | Priority |
|-------|-------|----------|
| Private keys not in frontend | Frontend | Critical |
| CSP headers configured | Frontend | High |
| No blind signing | Wallet | Critical |
| Chain ID validated | Transaction | High |
| RPC responses validated | RPC | High |
| API keys not exposed | Backend | High |
| Transaction simulation | Transaction | Medium |
| Rate limiting enforced | RPC | Medium |
| Session management secure | Frontend | High |
| CORS configured correctly | Backend | Medium |

### EIP Standards Security Relevance

| EIP | Purpose | Security Concern |
|-----|---------|-----------------|
| EIP-1193 | Provider interface | Permission abuse |
| EIP-712 | Typed data signing | Blind signing |
| EIP-2612 | Token permits | Signature replay |
| EIP-1559 | Fee market | Gas manipulation |
| EIP-4337 | Account abstraction | Entrypoint abuse |
| EIP-7702 | EOAs as contracts | Delegatecall risk |

### RPC Method Security

| Method | Risk | Mitigation |
|--------|------|------------|
| eth_sendTransaction | Transaction manipulation | EIP-712 signing |
| eth_sign | Blind signing | Use eth_signTypedData |
| personal_sign | Message spoofing | Domain validation |
| eth_call | Data manipulation | Cross-validate |
| eth_getStorageAt | State reading | Access control |
| wallet_switchEthereumChain | Chain switching | User confirmation |

### Web3 Security Architecture

```
RECOMMENDED SECURITY LAYERS:
+----------------------------------------------------------+
|                                                          |
|  Layer 1: Frontend Security                              |
|  - Content Security Policy (CSP)                         |
|  - Subresource Integrity (SRI)                           |
|  - No sensitive data in localStorage                     |
|  - Input validation and sanitization                     |
|                                                          |
|  Layer 2: Wallet Integration                             |
|  - Use EIP-712 for all signing                           |
|  - Validate domain separator                             |
|  - Show clear transaction details                        |
|  - Block eth_sign (use typed data)                       |
|                                                          |
|  Layer 3: RPC Security                                   |
|  - Backend proxy for RPC calls                           |
|  - API key domain restriction                            |
|  - Rate limiting per user                                |
|  - Response validation                                   |
|                                                          |
|  Layer 4: Transaction Security                           |
|  - Simulate before sending                               |
|  - Validate all parameters                               |
|  - Use Flashbots for MEV protection                      |
|  - Implement deadline parameters                         |
|                                                          |
|  Layer 5: Monitoring and Alerting                        |
|  - Unusual transaction patterns                          |
|  - Large value transfers                                 |
|  - New contract deployments                              |
|  - Permission changes                                    |
+----------------------------------------------------------+
```

### Web3 Testing Commands

```bash
# Check for exposed keys in frontend
grep -r "privateKey" ./src/
grep -r "0x[0-9a-fA-F]{64}" ./src/
grep -r "INFURA" ./src/
grep -r "ALCHEMY" ./src/

# Test RPC endpoint
curl -X POST https://rpc.endpoint \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check CORS headers
curl -I -X OPTIONS https://rpc.endpoint \
  -H "Origin: https://evil.com" \
  -H "Access-Control-Request-Method: POST"

# Test WebSocket connection
wscat -c wss://rpc.endpoint

# Monitor MetaMask
# Open Chrome DevTools > Console
# Monitor network requests for JSON-RPC calls
```
