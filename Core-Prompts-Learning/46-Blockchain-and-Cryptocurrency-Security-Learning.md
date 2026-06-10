You are an elite Blockchain and Cryptocurrency Security Learning AI, specializing in teaching decentralized system security assessment. Your expertise focuses on educating bug bounty hunters about smart contract vulnerabilities, blockchain protocol security, and cryptocurrency system weaknesses.

Your mission is to guide aspiring security researchers through blockchain and cryptocurrency security complexities, teaching them systematic approaches to testing smart contracts, assessing blockchain protocols, and developing secure decentralized implementations.

Key Learning Objectives:
- **Blockchain Fundamentals**: Master blockchain architecture and consensus mechanisms
- **Smart Contract Security**: Learn smart contract vulnerability assessment and testing
- **Cryptocurrency Protocols**: Study cryptocurrency transaction and wallet security
- **DeFi Security**: Assess decentralized finance protocol vulnerabilities
- **NFT Security**: Test non-fungible token contract and marketplace security
- **DAO Governance**: Learn decentralized autonomous organization security
- **Cross-Chain Security**: Assess cross-chain bridge and interoperability security

Advanced Learning Concepts:
- **Smart Contract Auditing**: Study formal verification and static analysis techniques
- **Flash Loan Attacks**: Learn DeFi flash loan exploitation techniques
- **Oracle Manipulation**: Assess blockchain oracle security and manipulation
- **Reentrancy Attacks**: Test smart contract reentrancy vulnerability exploitation
- **Integer Overflow**: Learn arithmetic operation security in smart contracts
- **Access Control**: Assess smart contract permission and role management
- **Gas Optimization**: Study gas-efficient and secure contract implementation

Learning Process:
1. **Blockchain Fundamentals**: Understand blockchain architecture and consensus
2. **Smart Contract Security**: Learn smart contract vulnerability assessment
3. **Cryptocurrency Security**: Study cryptocurrency transaction and wallet security
4. **DeFi Assessment**: Test decentralized finance protocol security
5. **NFT Security**: Assess non-fungible token contract security
6. **DAO Governance**: Learn decentralized governance security
7. **Secure Implementation**: Develop secure blockchain and cryptocurrency practices

Teaching Methodology:
- **Blockchain Labs**: Hands-on blockchain protocol security testing exercises
- **Smart Contract Workshops**: Smart contract vulnerability assessment training
- **Cryptocurrency Exercises**: Cryptocurrency security testing labs
- **DeFi Tutorials**: Decentralized finance security assessment guides
- **NFT Labs**: Non-fungible token security testing frameworks
- **DAO Workshops**: Decentralized governance security assessment exercises
- **Real-World Scenarios**: Case studies of blockchain and cryptocurrency vulnerabilities

Output Format:
- **Blockchain Modules**: Structured learning units for blockchain and cryptocurrency concepts
- **Smart Contract Exercises**: Practical smart contract security testing labs
- **Cryptocurrency Labs**: Cryptocurrency security assessment exercises
- **DeFi Workshops**: Decentralized finance security testing guides
- **NFT Tutorials**: Non-fungible token security assessment frameworks
- **DAO Labs**: Decentralized governance security testing exercises
- **Case Studies**: Real-world blockchain and cryptocurrency vulnerability examples

Example Learning Query: "Teach me blockchain and cryptocurrency security from basics to expert level"

Ensure learning materials are comprehensive, practical, and focused on developing expert-level blockchain and cryptocurrency security assessment skills.

---

# MODULE 1: Blockchain Architecture Fundamentals

## 1.1 Distributed Ledger Technology

A blockchain is a distributed, immutable ledger that records transactions across a network of computers. Understanding the core architecture is essential before assessing security.

**Core Components:**
- **Blocks**: Containers holding transaction data, timestamp, and previous block hash
- **Chain**: Cryptographic linking of blocks via hash pointers
- **Nodes**: Network participants maintaining ledger copies
- **Consensus Mechanisms**: Protocols for agreeing on ledger state

**Block Structure (Simplified):**
```json
{
  "index": 42,
  "timestamp": 1697000000,
  "transactions": [
    {
      "from": "0xABC123...",
      "to": "0xDEF456...",
      "value": 1.5,
      "gas": 21000,
      "data": "0x..."
    }
  ],
  "nonce": 1234567,
  "previous_hash": "0x89f3a2b...",
  "hash": "0x1c4e9d8..."
}
```

## 1.2 Consensus Mechanisms

**Proof of Work (PoW):**
- Miners solve computational puzzles to propose blocks
- Security depends on 51% attack cost
- Used by Bitcoin (SHA-256), Litecoin (Scrypt), Monero (RandomX)

**Proof of Stake (PoS):**
- Validators stake tokens to propose blocks
- Economic penalties (slashing) for malicious behavior
- Used by Ethereum 2.0, Cardano, Solana

**Delegated Proof of Stake (DPoS):**
- Token holders vote for block producers
- Faster finality but more centralized
- Used by EOS, TRON, Lisk

**Practical Byzantine Fault Tolerance (PBFT):**
- Consensus among known validators
- Tolerates up to 1/3 malicious nodes
- Used by Hyperledger Fabric, Zilliqa

**Security Implications:**
```
Consensus Attack Vectors:
+-- 51% Attack (PoW)
|   +-- Double spending
|   +-- Transaction censorship
|   +-- Chain reorganization
+-- Nothing-at-Stake (PoS)
|   +-- Multiple chain proposals
|   +-- Long-range attacks
+-- Validator Collusion
|   +-- Censorship
|   +-- MEV extraction
+-- Grinding Attacks
    +-- Validator selection manipulation
    +-- Randomness exploitation
```

## 1.3 Cryptographic Primitives in Blockchain

**Hash Functions:**
```solidity
// SHA-256 used in Bitcoin block hashing
bytes32 blockHash = sha256(abi.encodePacked(
    previousHash,
    merkleRoot,
    timestamp,
    nonce,
    difficulty
));

// Keccak-256 used in Ethereum
bytes32 storageKey = keccak256(abi.encodePacked(
    slot,
    address
));
```

**Digital Signatures (ECDSA):**
- Private key signs transaction
- Public key verifies authenticity
- Curve: secp256k1 (Bitcoin, Ethereum)

**Merkle Trees:**
- Efficient transaction verification
- O(log n) proof inclusion
- Used in SPV (Simplified Payment Verification)

## 1.4 Ethereum-Specific Architecture

**Account Types:**
- **EOA (Externally Owned Account)**: Controlled by private key
- **Contract Account**: Controlled by contract code

**Transaction Anatomy:**
```json
{
  "nonce": 0,
  "gasPrice": "20000000000",
  "gasLimit": 21000,
  "to": "0xRecipient",
  "value": "1000000000000000000",
  "data": "0x",
  "v": 27,
  "r": "0x...",
  "s": "0x..."
}
```

**EVM (Ethereum Virtual Machine):**
- Stack-based execution environment
- 256-bit word size
- Deterministic execution
- Gas metering for computation costs

## 1.5 Practical Exercise: Blockchain Data Analysis

**Exercise:** Use Etherscan API to analyze the last 100 blocks on Ethereum mainnet.

```python
import requests
import json

ETHERSCAN_API = "https://api.etherscan.io/api"
API_KEY = "YOUR_API_KEY"

def analyze_blocks(start_block, count):
    results = []
    for i in range(count):
        block_num = start_block + i
        resp = requests.get(ETHERSCAN_API, params={
            "module": "proxy",
            "action": "eth_getBlockByNumber",
            "tag": hex(block_num),
            "boolean": "true",
            "apikey": API_KEY
        })
        block = resp.json()["result"]
        results.append({
            "number": int(block["number"], 16),
            "tx_count": len(block["transactions"]),
            "gas_used": int(block["gasUsed"], 16),
            "gas_limit": int(block["gasLimit"], 16),
            "timestamp": int(block["timestamp"], 16),
            "miner": block["miner"]
        })
    return results

# Analyze recent blocks
blocks = analyze_blocks(18000000, 100)
for b in blocks:
    utilization = (b["gas_used"] / b["gas_limit"]) * 100
    print(f"Block {b['number']}: {b['tx_count']} txs, "
          f"Gas utilization: {utilization:.1f}%")
```

## 1.6 Assessment Questions

1. What are the key differences between PoW and PoS consensus mechanisms in terms of security guarantees?
2. Explain how a 51% attack works and what protections exist against it.
3. Why is Keccak-256 preferred over SHA-256 in Ethereum?
4. Describe the difference between an EOA and a contract account.
5. How does the gas mechanism prevent denial-of-service attacks on Ethereum?

---

# MODULE 2: Smart Contract Security Vulnerabilities

## 2.1 Reentrancy Attacks

The reentrancy vulnerability is one of the most critical smart contract bugs. It occurs when a contract makes an external call before updating its state.

**Classic Reentrancy Pattern:**
```solidity
// VULNERABLE CONTRACT
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Vulnerable: external call before state update
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        balances[msg.sender] -= amount; // State updated AFTER call
    }
}

// ATTACKER CONTRACT
contract Attacker {
    VulnerableBank public bank;

    constructor(address _bank) {
        bank = VulnerableBank(_bank);
    }

    function attack() public payable {
        bank.deposit{value: 1 ether}();
        bank.withdraw(1 ether);
    }

    // This function is called during the withdraw
    receive() external payable {
        if (address(bank).balance >= 1 ether) {
            bank.withdraw(1 ether);
        }
    }
}
```

**Defense - Checks-Effects-Interactions Pattern:**
```solidity
pragma solidity ^0.8.0;

contract SecureBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // CHECK: Validate state
        require(balances[msg.sender] >= amount);

        // EFFECT: Update state BEFORE external call
        balances[msg.sender] -= amount;

        // INTERACTION: External call last
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");
    }
}
```

**Reentrancy Variants:**
```
Reentrancy Types:
+-- Single-function Reentrancy
|   +-- Same function re-entered
+-- Cross-function Reentrancy
|   +-- Different function in same contract
+-- Cross-contract Reentrancy
|   +-- Different contract called during callback
+-- Read-only Reentrancy
|   +-- View functions return stale data during callback
+-- ERC777 Token Reentrancy
    +-- Token hooks enable reentrancy
```

**Reentrancy Guard Pattern:**
```solidity
pragma solidity ^0.8.0;

contract ReentrancyGuard {
    uint256 private _locked;

    modifier nonReentrant() {
        require(_locked == 0, "ReentrancyGuard: reentrant call");
        _locked = 1;
        _;
        _locked = 0;
    }
}

contract ProtectedBank is ReentrancyGuard {
    mapping(address => uint256) public balances;

    function withdraw(uint256 amount) public nonReentrant {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
    }
}
```

## 2.2 Flash Loan Attacks

Flash loans allow borrowing unlimited funds without collateral, provided the loan is repaid within the same transaction.

**Flash Loan Attack Pattern:**
```solidity
contract FlashLoanAttack {
    IUniswapV2Router02 public router;
    ISimpleSwapDEX public vulnerableDEX;

    function executeFlashLoan() external {
        // 1. Borrow flash loan
        uint256 loanAmount = 1000 ether;
        IERC20(WETH).approve(address(router), loanAmount);

        // 2. Swap on vulnerable DEX to manipulate price
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = TOKEN;

        router.swapExactTokensForTokens(
            loanAmount,
            0,
            path,
            address(this),
            block.timestamp
        );

        // 3. Exploit price difference on other protocol
        vulnerableDEX.deposit{value: 0}(tokenBalance);

        // 4. Repay flash loan + fee
        IERC20(WETH).transfer(
            address(router),
            loanAmount + (loanAmount * 9 / 10000)
        );
    }
}
```

**Real-World Flash Loan Attack Case Studies:**

| Attack | Year | Loss | Technique |
|--------|------|------|-----------|
| bZx | 2020 | $8M | Price oracle manipulation |
| Harvest Finance | 2020 | $34M | Curve pool price manipulation |
| Pancake Bunny | 2021 | $45M | Flash loan + oracle manipulation |
| Cream Finance | 2021 | $130M | Flash loan + reentrancy |
| Beanstalk | 2022 | $182M | Flash loan governance attack |
| Euler Finance | 2023 | $197M | Donated flash loan + reentrancy |

**Flash Loan Defense Checklist:**
```
Flash Loan Mitigation:
+-- Use TWAP oracles (time-weighted average price)
+-- Implement multi-block price averaging
+-- Add flash loan detection checks
+-- Use delay mechanisms for large operations
+-- Implement circuit breakers for abnormal values
+-- Validate price deviation bounds
```

## 2.3 Integer Overflow and Underflow

**Vulnerable Pre-0.8 Pattern:**
```solidity
// Vulnerable (Solidity <0.8.0)
contract Token {
    mapping(address => uint256) balances;

    function transfer(address to, uint256 amount) public {
        require(balances[msg.sender] >= amount);
        balances[msg.sender] -= amount;      // Underflow if amount > balance
        balances[to] += amount;               // Overflow possible
    }
}
```

**Protection Methods:**
```solidity
pragma solidity ^0.8.0;

// Method 1: Built-in overflow checks (0.8+)
function safeAdd(uint256 a, uint256 b) public pure returns (uint256) {
    return a + b; // Automatically reverts on overflow
}

// Method 2: SafeMath library (pre-0.8 compatibility)
using SafeMath for uint256;

function safeAddLegacy(uint256 a, uint256 b) public pure returns (uint256) {
    return a.add(b);
}

// Method 3: Unchecked blocks (explicit risk zones)
function riskyOperation(uint256 a, uint256 b) public pure returns (uint256) {
    unchecked {
        return a + b; // No overflow check - audit carefully
    }
}
```

## 2.4 Access Control Vulnerabilities

**Missing Access Control:**
```solidity
// VULNERABLE: No access control
contract AdminVault {
    address public owner;
    uint256 public secretValue;

    function setSecretValue(uint256 _value) public {
        secretValue = _value; // Any caller can modify
    }
}

// SECURE: Proper access control
contract SecureVault {
    address public owner;
    uint256 public secretValue;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setSecretValue(uint256 _value) public onlyOwner {
        secretValue = _value;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
    }
}
```

**Role-Based Access Control:**
```solidity
pragma solidity ^0.8.0;

contract RBAC {
    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    mapping(bytes32 => mapping(address => bool)) private _roles;

    modifier onlyRole(bytes32 role) {
        require(_roles[role][msg.sender], "Insufficient permissions");
        _;
    }

    constructor() {
        _grantRole(ADMIN_ROLE, msg.sender);
    }

    function grantRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        _roles[role][account] = true;
    }

    function revokeRole(bytes32 role, address account) public onlyRole(ADMIN_ROLE) {
        _roles[role][account] = false;
    }
}
```

## 2.5 Front-Running and MEV

**Sandwich Attack Mechanism:**
```
Sandwich Attack:
+-- Step 1: Front-run (buy before victim)
|   +-- Higher gas price to be mined first
+-- Step 2: Victim's transaction executes
|   +-- Price moves in attacker's favor
+-- Step 3: Back-run (sell after victim)
    +-- Capture profit from price movement
```

**Protection Techniques:**
```solidity
// 1. Commit-reveal scheme
contract CommitRevealSwap {
    mapping(bytes32 => bool) public commits;

    function commitSwap(bytes32 hash) public {
        commits[hash] = true;
    }

    function revealAndSwap(
        uint256 amountIn,
        uint256 minAmountOut,
        bytes32 salt
    ) public {
        bytes32 commitHash = keccak256(
            abi.encodePacked(msg.sender, amountIn, minAmountOut, salt)
        );
        require(commits[commitHash]);
        delete commits[commitHash];
        // Execute swap atomically
    }
}

// 2. Maximum slippage protection
function swap(uint256 amountIn, uint256 minAmountOut) public {
    uint256 amountOut = getAmountOut(amountIn);
    require(amountOut >= minAmountOut, "Slippage too high");
    // Execute swap
}

// 3. Private transaction pools (Flashbots-style)
// Submit bundles directly to block builders
```

## 2.6 Practical Exercise: Reentrancy Exploitation Lab

**Setup Instructions:**
1. Install Foundry: `curl -L https://foundry.paradigm.xyz | bash`
2. Create project: `forge init reentrancy-lab && cd reentrancy-lab`
3. Deploy vulnerable contract to local testnet
4. Write and execute attacker contract
5. Verify drain of contract balance

**Lab Steps:**
```bash
# Initialize project
forge init reentrancy-lab
cd reentrancy-lab

# Create vulnerable contract
cat > src/VulnerableBank.sol << 'EOF'
pragma solidity ^0.8.0;

contract VulnerableBank {
    mapping(address => uint256) public balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount);
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success);
        balances[msg.sender] -= amount;
    }
}
EOF

# Create test file
cat > test/Reentrancy.t.sol << 'EOF'
// Test reentrancy attack
// Students implement the attacker contract
EOF

# Run tests
forge test -vvvv
```

## 2.7 Assessment Questions

1. Explain the Checks-Effects-Interactions pattern and why it prevents reentrancy.
2. How does a cross-contract reentrancy attack differ from a single-function reentrancy?
3. Why are TWAP oracles more resistant to flash loan manipulation than spot price oracles?
4. Describe how a sandwich attack extracts MEV from users.
5. What is the purpose of the nonReentrant modifier, and what edge cases does it handle?
6. How would you audit a Solidity contract for access control vulnerabilities?
7. Explain the commit-reveal pattern and how it prevents front-running.

---

# MODULE 3: DeFi Protocol Security

## 3.1 Automated Market Maker (AMM) Vulnerabilities

**Price Oracle Manipulation:**
```solidity
// Vulnerable: Using on-chain AMM price as oracle
contract VulnerableLending {
    IUniswapV2Pair public pair;

    function getPrice() public view returns (uint256) {
        (uint256 reserve0, uint256 reserve1, ) = pair.getReserves();
        return (reserve1 * 1e18) / reserve0;
    }

    function borrow(uint256 collateralAmount) public {
        uint256 price = getPrice();
        uint256 collateralValue = (collateralAmount * price) / 1e18;
        // Vulnerable to flash loan price manipulation
        uint256 maxBorrow = collateralValue * 80 / 100;
    }
}

// Secure: TWAP oracle with time-weighted averaging
contract SecureLending {
    IUniswapV2Oracle public oracle;

    function getPrice() public view returns (uint256) {
        return oracle.consult(token, 1e18);
    }
}
```

**AMM Attack Taxonomy:**
```
AMM Attack Vectors:
+-- Price Manipulation
|   +-- Single-block manipulation
|   +-- Flash loan assisted
|   +-- Multi-hop routing
+-- Liquidity Draining
|   +-- Sandwich attacks
|   +-- JIT liquidity extraction
+-- Oracle Abuse
|   +-- Spot price manipulation
|   +-- TWAP bypass attempts
|   +-- Cross-DEX arbitrage
+-- Impermanent Loss Exploitation
    +-- Volatility injection
    +-- Liquidity withdrawal timing
```

## 3.2 Lending Protocol Security

**Collateral Factor Exploitation:**
```
Lending Protocol Attack:
+-- Deposit: Low-collateral-factor asset
|   +-- e.g., deposit volatile token at 50% LTV
+-- Borrow: High-collateral-factor asset
|   +-- e.g., borrow stablecoin at 80% LTV
+-- Manipulate: Oracle price of deposited asset
|   +-- Artificially inflate collateral value
+-- Borrow More: Increase borrow against inflated value
|   +-- Extract maximum stablecoins
+-- Abandon: Leave bad debt in protocol
    +-- Protocol absorbs loss
```

**Interest Rate Manipulation:**
```solidity
// Flash loan to manipulate utilization rate
function manipulateUtilization() external {
    uint256 poolBalance = token.balanceOf(address(pool));
    // Borrow nearly all liquidity
    uint256 borrowAmount = poolBalance * 99 / 100;
    IERC20(borrowToken).approve(address(lending), borrowAmount);
    lending.borrow(borrowAmount);
    // Utilization spikes, affecting interest rates
    // Other users face higher rates or liquidation
}
```

**Lending Protocol Defense Matrix:**
```
Defense Mechanisms:
+-- Oracle Security
|   +-- TWAP with sufficient time window
|   +-- Multi-oracle aggregation
|   +-- Price deviation circuit breakers
|   +-- Staleness checks on oracle data
+-- Collateral Management
|   +-- Dynamic collateral factors
|   +-- Conservative LTV ratios
|   +-- Liquidation bonuses
|   +-- Health factor monitoring
+-- Interest Rate Models
|   +-- Utilization rate caps
|   +-- Kink-point curves
|   +-- Rate smoothing mechanisms
+-- Flash Loan Protection
    +-- Minimum borrow amounts
    +-- Time-delay for large withdrawals
    +-- Multi-block averaging
```

## 3.3 Yield Farming Security

**Smart Contract Rug Pull Indicators:**
```
Rug Pull Red Flags:
+-- Owner privileges
|   +-- Unrestricted mint function
|   +-- Pause capability
|   +-- Withdraw all liquidity function
|   +-- Transfer ownership without timelock
+-- Hidden mechanics
|   +-- Obfuscated code (unnamed variables)
|   +-- External contract calls with upgradeable addresses
|   +-- Hidden fees or tax functions
+-- Token economics
|   +-- Extremely high APY without clear source
|   +-- Inflationary tokenomics without utility
|   +-- Concentrated token ownership (>50% in few wallets)
+-- Operational risks
    +-- No timelock on admin functions
    +-- No multi-sig governance
    +-- Anonymous team with no audit
```

**Liquidity Lock Verification:**
```python
import requests
from web3 import Web3

def check_liquidity_lock(pair_address, lock_contract):
    """Verify LP tokens are locked in a timelock contract"""
    w3 = Web3(Web3.HTTPProvider("https://mainnet.infura.io/v3/YOUR_KEY"))

    # ERC20 balanceOf ABI
    abi = [{"inputs":[{"name":"account","type":"address"}],
            "name":"balanceOf","outputs":[{"type":"uint256"}],
            "stateMutability":"view","type":"function"}]

    pair = w3.eth.contract(address=pair_address, abi=abi)
    total_supply = pair.functions.totalSupply().call()
    locked = pair.functions.balanceOf(lock_contract).call()

    lock_percentage = (locked / total_supply) * 100
    print(f"Locked: {lock_percentage:.1f}% of LP tokens")

    if lock_percentage < 80:
        print("WARNING: Insufficient liquidity lock")
    return lock_percentage
```

## 3.4 Governance Attack Vectors

**Flash Loan Governance Attack:**
```
DAO Governance Attack:
+-- Step 1: Flash loan large amount of governance tokens
|   +-- Borrow from Aave/Compound/DYDX
+-- Step 2: Delegate voting power to attacker
|   +-- Self-delegate to activate voting
+-- Step 3: Submit malicious proposal
|   +-- Transfer treasury funds to attacker
|   +-- Modify critical protocol parameters
+-- Step 4: Execute proposal within same block
|   +-- Exploit low quorum requirements
+-- Step 5: Repay flash loan
    +-- Keep stolen funds
```

**Governance Defense Mechanisms:**
```solidity
// Timelock + Quorum requirements
contract GovernanceGuard {
    uint256 public constant TIMELOCK_DELAY = 2 days;
    uint256 public constant MIN_QUORUM = 4; // percentage
    uint256 public constant VOTING_PERIOD = 7 days;

    mapping(uint256 => Proposal) public proposals;

    struct Proposal {
        uint256 createdAt;
        uint256 votedAt;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    modifier timelock() {
        require(block.timestamp >= proposals[_proposalId].votedAt + TIMELOCK_DELAY);
        _;
    }
}
```

## 3.5 Practical Exercise: DeFi Vulnerability Assessment

**Lab: Analyze a SimpleSwap DEX**
```bash
# Deploy a vulnerable DEX locally
forge install uniswap/v2-core --no-commit
forge install uniswap/v2-periphery --no-commit

# Create test scenarios
# 1. Flash loan price manipulation
# 2. Sandwich attack simulation
# 3. Oracle manipulation test
# 4. Liquidity extraction attempt
```

**Assessment Script:**
```python
from web3 import Web3
import json

class DeFiAuditor:
    def __init__(self, rpc_url):
        self.w3 = Web3(Web3.HTTPProvider(rpc_url))

    def check_oracle_reliability(self, oracle_address):
        """Check if oracle uses spot price or TWAP"""
        # ABI for common oracle interfaces
        result = {}
        result["type"] = self._identify_oracle_type(oracle_address)
        result["freshness"] = self._check_price_freshness(oracle_address)
        result["manipulation_risk"] = self._assess_manipulation_risk(oracle_address)
        return result

    def check_liquidation_safety(self, lending_address):
        """Verify liquidation mechanism is robust"""
        checks = {
            "oracle_dependency": self._check_single_oracle_risk(lending_address),
            "collateral_ratio": self._check_collateral_safety(lending_address),
            "liquidation_penalty": self._check_penalty合理性(lending_address),
            "circuit_breaker": self._check_circuit_breaker(lending_address)
        }
        return checks
```

## 3.6 Assessment Questions

1. How does a TWAP oracle resist flash loan price manipulation better than a spot oracle?
2. Explain how a flash loan governance attack can drain a DAO treasury.
3. What indicators suggest a DeFi protocol might be a rug pull?
4. Describe the collateral factor exploitation attack vector.
5. How do circuit breakers protect against oracle manipulation attacks?
6. What is JIT liquidity extraction and how does it affect DEX users?
7. Why is multi-oracle aggregation important for lending protocol security?

---

# MODULE 4: NFT and Marketplace Security

## 4.1 ERC-721 Vulnerabilities

**Metadata Manipulation:**
```solidity
// VULNERABLE: Off-chain metadata
contract VulnerableNFT is ERC721 {
    mapping(uint256 => string) private _tokenURIs;

    function tokenURI(uint256 tokenId) public view override returns (string) {
        return _tokenURIs[tokenId]; // Can be changed after minting
    }

    function setTokenURI(uint256 tokenId, string memory uri) public {
        _tokenURIs[tokenId] = uri; // Owner can change metadata
    }
}

// SECURE: On-chain or IPFS-pinned metadata
contract SecureNFT is ERC721 {
    mapping(uint256 => bytes32) private _tokenMetadataHash;

    function tokenURI(uint256 tokenId) public view override returns (string) {
        // Metadata hash stored on-chain, content on IPFS
        return string(abi.encodePacked("ipfs://", bytes20(_tokenMetadataHash[tokenId])));
    }
}
```

**Approval Vulnerabilities:**
```solidity
// Risk: setApprovalForAll gives full access
// Attack: Malicious marketplace contract
contract MaliciousMarketplace {
    function listNFT(address nftContract, uint256 tokenId) external {
        // After user approves this contract:
        IERC721(nftContract).transferFrom(
            msg.sender,
            address(this),
            tokenId
        );
        // NFT transferred to attacker
    }
}

// Defense: Use specific approvals
IERC721(nft).approve(marketplace, specificTokenId);
// Instead of:
IERC721(nft).setApprovalForAll(marketplace, true);
```

## 4.2 Marketplace Security

**Listing and Bidding Attacks:**
```
Marketplace Attack Vectors:
+-- Bid Manipulation
|   +-- Place bid, change listing price after
|   +-- Front-run higher bids
|   +-- Wash bidding (self-bidding to inflate price)
+-- Listing Attacks
|   +-- Fake listings to create false floor price
|   +-- Cancel listing after buyer commits
|   +-- Hidden reserves not shown to buyers
+-- Fee Bypass
|   +-- Direct transfer instead of marketplace sale
|   +-- Off-chain settlement circumventing royalties
+-- Flash Loan Purchase
    +-- Borrow ETH, buy NFT, use NFT as collateral, repay loan
```

**Wash Trading Detection:**
```python
def detect_wash_trading(transactions, time_window_hours=24):
    """Detect potential wash trading in NFT sales"""
    from collections import defaultdict
    from datetime import timedelta

    # Group transactions by buyer-seller pairs
    pair_activity = defaultdict(list)

    for tx in transactions:
        pair = tuple(sorted([tx["buyer"], tx["seller"]]))
        pair_activity[pair].append(tx)

    suspicious = []
    for pair, trades in pair_activity.items():
        # Check for repeated trades between same addresses
        if len(trades) >= 3:
            time_span = trades[-1]["timestamp"] - trades[0]["timestamp"]
            if time_span < timedelta(hours=time_window_hours):
                suspicious.append({
                    "pair": pair,
                    "trade_count": len(trades),
                    "volume": sum(t["price"] for t in trades),
                    "time_span": str(time_span),
                    "risk_score": len(trades) * (1 / max(time_span.total_seconds(), 1))
                })

    return suspicious
```

## 4.3 IPFS and Metadata Security

**Metadata Centralization Risk:**
```
Metadata Security Layers:
+-- Layer 1: Token URI
|   +-- On-chain (most secure, highest gas)
|   +-- IPFS (decentralized but mutable pointer)
|   +-- HTTP (centralized, fully mutable - HIGH RISK)
+-- Layer 2: Content
|   +-- Immutable (hash stored on-chain)
|   +-- Mutable (owner can update content)
+-- Layer 3: Rendering
    +-- Client-side rendering (bypassed by custom viewer)
    +-- Server-side rendering (centralized control)
```

**IPFS Pinning Verification:**
```python
import ipfshttpclient
import hashlib

def verify_nft_metadata(token_uri, expected_hash):
    """Verify NFT metadata hasn't been tampered with"""
    client = ipfshttpclient.connect("/ip4/127.0.0.1/tcp/5001")

    # Fetch content from IPFS
    content = client.cat(token_uri.replace("ipfs://", ""))

    # Verify hash matches
    actual_hash = hashlib.sha256(content).hexdigest()
    if actual_hash != expected_hash:
        print(f"HASH MISMATCH: Metadata tampered!")
        print(f"  Expected: {expected_hash}")
        print(f"  Actual:   {actual_hash}")
        return False

    # Parse and validate metadata structure
    import json
    metadata = json.loads(content)
    required_fields = ["name", "description", "image"]
    for field in required_fields:
        if field not in metadata:
            print(f"WARNING: Missing field '{field}' in metadata")

    return True
```

## 4.4 Practical Exercise: NFT Security Audit

**Lab: Audit an NFT Collection Contract**
```bash
# Clone a sample NFT project
git clone https://github.com/OpenZeppelin/openzeppelin-contracts.git
cd openzeppelin-contracts

# Audit checklist:
# 1. Check for reentrancy in mint/burn functions
# 2. Verify access control on admin functions
# 3. Test token URI manipulation vectors
# 4. Check approval and transferFrom logic
# 5. Verify royalty distribution (EIP-2981)
# 6. Test batch operations for gas griefing
```

**Audit Template:**
```python
class NFTAuditor:
    def __init__(self, contract_address, abi):
        self.w3 = Web3(Web3.HTTPProvider("http://localhost:8545"))
        self.contract = self.w3.eth.contract(address=contract_address, abi=abi)

    def check_mint_permissions(self):
        """Verify who can mint tokens"""
        issues = []
        # Check if mint is public or restricted
        # Check for supply caps
        # Check for mint price enforcement
        return issues

    def check_metadata_integrity(self):
        """Verify metadata cannot be manipulated"""
        issues = []
        # Check if tokenURI can be changed
        # Check if baseURI is centralized
        # Verify IPFS/Arweave usage
        return issues

    def check_royalty_enforcement(self):
        """Verify EIP-2981 royalty implementation"""
        issues = []
        # Check royaltyInfo function
        # Verify royalty is enforced on transfers
        return issues
```

## 4.5 Assessment Questions

1. What are the risks of using HTTP-based metadata for NFT collections?
2. How does wash trading manipulate NFT floor prices?
3. Explain the difference between setApprovalForAll and approve for ERC-721.
4. How can flash loans be used in NFT marketplace attacks?
5. What security measures protect against metadata manipulation?
6. Describe the risks of off-chain order book marketplaces.
7. How does EIP-2981 implement royalty standards?

---

# MODULE 5: Cross-Chain Bridge Security

## 5.1 Bridge Architecture Types

**Bridge Types and Their Risks:**
```
Bridge Architecture Taxonomy:
+-- Trusted Bridges
|   +-- Centralized operators
|   +-- Single point of failure
|   +-- Custodial risk
+-- Trustless Bridges
|   +-- Light client verification
|   +-- Zero-knowledge proofs
|   +-- Multi-party computation
+-- Relay Bridges
|   +-- Chain-to-chain messaging
|   +-- Validator set security
|   +-- Consensus mechanism dependency
+-- Liquidity Networks
    +-- Swap-based bridges
    +-- Liquidity pool risks
    +-- Arbitrage exploitation
```

**Bridge Attack Surface:**
```
Bridge Vulnerability Classes:
+-- Validator Compromise
|   +-- Insufficient validator set
|   +-- Key management failures
|   +-- Validator collusion
+-- Smart Contract Bugs
|   +-- Reentrancy in bridge contracts
|   +-- Access control bypass
|   +-- Signature verification flaws
+-- Consensus Attacks
|   +-- Chain reorganization exploitation
|   +-- Double-spending across chains
|   +-- Finality assumption violations
+-- Message Manipulation
    +-- Replay attacks across chains
    +-- Message tampering
    +-- Ordering attacks
```

## 5.2 Bridge Vulnerability Case Studies

**Ronin Bridge Attack ($625M):**
```
Attack Timeline:
1. Compromised validator private keys (social engineering)
2. 5 of 9 validators controlled by attacker
3. Signed fraudulent withdrawal transactions
4. 173,600 ETH + 25.5M USDC extracted

Root Causes:
+-- Insufficient validator distribution
+-- Single point of failure in key management
+-- No multi-party computation for signing
+-- Delayed detection of compromise
```

**Wormhole Attack ($326M):**
```
Attack Mechanism:
1. Signature verification bypass
2. Attacker forged validation of 120,000 wETH
3. mint_tokens instruction accepted forged signature
4. Exploited Solana program's verification logic

Root Cause:
+-- Signature verification did not validate guardian set
+-- Deprecated verification path still accessible
+-- Insufficient input validation
```

**Nomad Bridge Attack ($190M):**
```
Attack Mechanism:
1. Routine upgrade set initial trusted root to 0x00
2. Any message could be validated as authentic
3. Attacker deployed contracts to replay valid messages
4. White-hat hackers copied attack to rescue funds

Root Cause:
+-- Misconfiguration during upgrade
+-- Zero root allowed any message validation
+-- No sanity checks on root values
```

## 5.3 Bridge Security Assessment Framework

**Assessment Checklist:**
```
Bridge Security Audit Checklist:
+-- Validator Security
|   +-- Minimum validator count (>21 recommended)
|   +-- Geographic distribution
|   +-- Key management (HSM, MPC)
|   +-- Rotation schedule
|   +-- Slashing conditions
+-- Smart Contract Security
|   +-- Reentrancy protection
|   +-- Access control verification
|   +-- Input validation
|   +-- Upgrade safety
|   +-- Emergency pause mechanisms
+-- Message Verification
|   +-- Signature scheme security
|   +-- Replay protection (nonce, chain ID)
|   +-- Message ordering guarantees
|   +-- Timeout mechanisms
+-- Economic Security
|   +-- Fraud proof incentives
|   +-- Bond requirements
|   +-- Liquidation mechanisms
|   +-- Economic finality
+-- Operational Security
    +-- Incident response plan
    +-- Monitoring and alerting
    +-- Upgrade timelock
    +-- Multi-sig governance
```

**Automated Bridge Testing:**
```python
class BridgeTester:
    def __init__(self, bridge_contract, source_chain, dest_chain):
        self.bridge = bridge_contract
        self.source = source_chain
        self.dest = dest_chain

    def test_message_replay(self):
        """Verify messages cannot be replayed"""
        # Send valid message
        msg_id = self.bridge.send_message("test", 1000)

        # Attempt replay on destination
        try:
            self.bridge.receive_message(msg_id)
            return {"vulnerable": True, "type": "replay"}
        except Exception:
            return {"vulnerable": False}

    def test_signature_bypass(self):
        """Verify signature cannot be forged"""
        # Create unsigned message
        fake_msg = self._create_unsigned_message()

        # Attempt to submit as valid
        try:
            self.bridge.validate_message(fake_msg)
            return {"vulnerable": True, "type": "sig_bypass"}
        except Exception:
            return {"vulnerable": False}

    def test_validator_compromise(self):
        """Test threshold signature security"""
        # Simulate compromised validators
        compromised = self._get_validator_count() // 2 + 1
        # Verify attack requires threshold
        return self._check_threshold_security(compromised)
```

## 5.4 Assessment Questions

1. What makes the Ronin Bridge attack particularly significant in terms of lessons learned?
2. How does a zero-knowledge proof bridge differ from a multisig bridge in security properties?
3. Explain how the Nomad Bridge misconfiguration allowed unauthorized transfers.
4. What are the key security considerations for bridge validator sets?
5. How does chain reorganization affect bridge security guarantees?
6. Describe the fraud proof mechanism in optimistic bridge designs.
7. What monitoring should be in place for detecting bridge exploitation attempts?

---

# MODULE 6: DAO Governance Security

## 6.1 Governance Attack Vectors

**Voting Manipulation:**
```
DAO Governance Attacks:
+-- Flash Loan Governance
|   +-- Borrow tokens, vote, repay in one tx
|   +-- Exploit low quorum requirements
|   +-- Pass malicious proposals
+-- Vote Buying
|   +-- Bribe voters off-chain
|   +-- Conviction voting manipulation
|   +-- Delegation attacks
+-- Proposal Spam
|   +-- Gas griefing via numerous proposals
|   +-- Delay critical governance actions
|   +-- Resource exhaustion
+-- Sybil Attacks
    +-- Create multiple wallets
    +-- Dilute voting power distribution
    +-- Manipulate token distribution votes
```

## 6.2 Timelock and Multi-Sig Security

**Governance Defense Architecture:**
```solidity
// Timelock + Multi-sig governance
contract SecureGovernance {
    TimelockController public timelock;
    MultiSigWallet public multisig;
    uint256 public constant PROPOSAL_THRESHOLD = 100000 ether;
    uint256 public constant VOTING_PERIOD = 7 days;
    uint256 public constant TIMELOCK_DELAY = 2 days;

    function executeProposal(uint256 proposalId) public {
        Proposal storage p = proposals[proposalId];
        require(p.votesFor > p.votesAgainst, "Not passed");
        require(block.timestamp >= p.votedAt + TIMELOCK_DELAY, "Timelock active");
        require(block.timestamp <= p.votedAt + TIMELOCK_DELAY + 1 days, "Expired");

        // Execute through timelock
        timelock.scheduleBatch(
            p.targets,
            p.values,
            p.calldatas,
            block.timestamp
        );
    }
}
```

## 6.3 Practical Exercise: DAO Governance Audit

**Lab: Audit a Governor Contract**
```bash
# Deploy OpenZeppelin Governor
forge install OpenZeppelin/openzeppelin-contracts

# Test scenarios:
# 1. Flash loan voting attack simulation
# 2. Timelock bypass attempt
# 3. Quorum manipulation test
# 4. Proposal spam attack
# 5. Vote delegation exploit
```

## 6.4 Assessment Questions

1. How does a timelock protect against flash loan governance attacks?
2. What are the requirements for a secure DAO multi-sig wallet?
3. Explain the concept of vote buying and its implications for DAO governance.
4. How can Sybil attacks compromise token-based voting systems?
5. What role does quorum play in governance security?

---

# MODULE 7: Smart Contract Auditing Methodology

## 7.1 Audit Process Framework

**Complete Audit Workflow:**
```
Smart Contract Audit Process:
+-- Phase 1: Reconnaissance
|   +-- Codebase review
|   +-- Architecture documentation
|   +-- Dependency analysis
|   +-- Previous audit review
+-- Phase 2: Automated Analysis
|   +-- Slither static analysis
|   +-- Mythril symbolic execution
|   +-- Echidna fuzzing
|   +-- Manticore analysis
+-- Phase 3: Manual Review
|   +-- Line-by-line code review
|   +-- Business logic analysis
|   +-- Access control verification
|   +-- Mathematical correctness
+-- Phase 4: Exploitation
|   +-- Proof of concept development
|   +-- Attack scenario validation
|   +-- Impact assessment
+-- Phase 5: Reporting
    +-- Finding documentation
    +-- Severity classification
    +-- Remediation recommendations
    +-- Retest verification
```

## 7.2 Automated Analysis Tools

**Slither Usage:**
```bash
# Install slither
pip install slither-analyzer

# Run analysis
slither contract.sol --detect reentrancy-eth,reentrancy-no-eth

# Get JSON output
slither contract.sol --json output.json

# Detectors to always run:
# - reentrancy-eth
# - reentrancy-no-eth
# - uninitialized-state
# - arbitrary-send-eth
# - delegatecall
# - suicidal
# - unchecked-transfer
```

**Mythril Usage:**
```bash
# Install mythril
pip install mythril

# Analyze contract
myth analyze contract.sol --execution-timeout 90

# Specific vulnerability search
myth analyze contract.sol --strategy symbolic --max-depth 10
```

**Echidna Fuzzing:**
```python
# echidna_config.yaml
testMode: "property"
testLimit: 100000
shrinkLimit: 5000
seqLen: 100
```

```solidity
// Echidna test contract
contract EchidnaTest is VulnerableContract {
    function echidna_balance_never_negative() public view returns (bool) {
        return address(this).balance >= 0;
    }

    function echidna_total_supply_capped() public view returns (bool) {
        return totalSupply() <= MAX_SUPPLY;
    }
}
```

## 7.3 Finding Severity Classification

**CVSS 3.1 for Smart Contracts:**
```
Smart Contract Severity Matrix:
+-- Critical (9.0-10.0)
|   +-- Direct loss of funds > $1M
|   +-- Complete protocol compromise
|   +-- Permanent fund lock
|   +-- Privilege escalation to admin
+-- High (7.0-8.9)
|   +-- Significant fund loss risk
|   +-- Oracle manipulation
|   +-- Governance attack
|   +-- Reentrancy with fund theft
+-- Medium (4.0-6.9)
|   +-- Temporary DoS
|   +-- Griefing attacks
|   +-- Information disclosure
|   +-- Minor logic errors
+-- Low (0.1-3.9)
|   +-- Gas optimization issues
|   +-- Code quality concerns
|   +-- Missing events
|   +-- NatSpec documentation
+-- Informational
    +-- Best practice recommendations
    +-- Style guide violations
    +-- Unused variables
```

## 7.4 Assessment Questions

1. Describe the complete smart contract audit workflow from start to finish.
2. What are the differences between static analysis and symbolic execution?
3. How do you determine the severity of a smart contract vulnerability?
4. Explain how fuzzing helps discover smart contract bugs.
5. What are the most common findings in smart contract audits?
6. How should audit findings be prioritized for remediation?
7. What tools would you use for a comprehensive smart contract audit?

---

# FURTHER READING

## Books
- "Mastering Ethereum" by Andreas Antonopoulos
- "Mastering Blockchain" by Imran Bashir
- "Solidity Programming" by Gavin Wood

## Online Resources
- SWC Registry (Smart Contract Weakness Classification)
- ConsenSys Diligence Ethereum Smart Contract Best Practices
- OpenZeppelin Contracts Security Audit Guidelines
- Trail of Bits Smart Contract Security Best Practices

## Practice Platforms
- Ethernaut (OpenZeppelin) - Interactive Solidity challenges
- Damn Vulnerable DeFi - DeFi-specific security challenges
- Capture The Ether - Smart contract CTF challenges
- Paradox - Cross-chain security challenges
- Code4rena - Live audit competitions
- Sherlock - Audit contest platform
- Immunefi - Bug bounty platform for DeFi

## Tools Reference
- Foundry (forge, cast, anvil) - Development and testing framework
- Hardhat - Ethereum development environment
- Slither - Static analysis framework
- Mythril - Symbolic execution engine
- Echidna - Property-based fuzzing tool
- Certora Prover - Formal verification platform
- Tenderly - Transaction simulation platform
