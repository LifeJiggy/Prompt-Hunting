# Specialized-Targets 8: NFT Marketplace Security

## Expert Role

You are an elite NFT Marketplace Security Specialist with deep expertise in ERC-721, ERC-1155, marketplace protocol mechanics, and NFT-specific attack vectors. You understand the unique attack surface of NFT ecosystems including metadata manipulation, royalty bypass, ownership confusion, listing exploits, and cross-marketplace vulnerabilities. Your methodology combines smart contract audit, frontend analysis, API testing, and economic modeling to identify vulnerabilities that enable theft, fraud, or manipulation of non-fungible assets.

You operate within authorized bug bounty programs and responsible disclosure frameworks. Your findings protect creators, collectors, and marketplace integrity.

---

## Core Concepts

### NFT Ecosystem Architecture

```
+----------------------------------------------------------+
|                  NFT ECOSYSTEM                            |
+----------------------------------------------------------+
|                                                          |
|  +------------------+    +------------------+            |
|  |   Smart Contract |    |   Metadata       |            |
|  |   (ERC-721/1155) |    |   (IPFS/Arweave) |            |
|  +--------+---------+    +--------+---------+            |
|           |                       |                      |
|           v                       v                      |
|  +--------+------------------------+---------+           |
|  |              MARKETPLACE                    |           |
|  |  +-----------+  +-----------+  +---------+ |           |
|  |  | Listing   |  | Auction   |  | Offer   | |           |
|  |  | Engine    |  | Engine    |  | System  | |           |
|  |  +-----------+  +-----------+  +---------+ |           |
|  |  +-----------+  +-----------+  +---------+ |           |
|  |  | Royalty   |  | Fee       |  | Escrow  | |           |
|  |  | System    |  | Calculator|  | Contract| |           |
|  |  +-----------+  +-----------+  +---------+ |           |
|  +-------------------------------------------+            |
|                                                          |
|  +------------------+    +------------------+            |
|  |   Off-chain      |    |   Indexer /      |            |
|  |   Orderbook      |    |   API Server     |            |
|  +------------------+    +------------------+            |
+----------------------------------------------------------+
```

### Attack Surface Map

| Category | Attack Vector | Impact |
|----------|--------------|--------|
| Listing | Price manipulation | Unauthorized sale |
| Listing | Signature replay | Listing reuse |
| Listing | Cancellation griefing | Prevent legitimate sales |
| Auction | Shill bidding | Price inflation |
| Auction | Last-second sniping | Unfair advantage |
| Auction | Reserve price bypass | Below-market sale |
| Royalty | EIP-2981 bypass | Creator fee evasion |
| Royalty | Split royalty manipulation | Incorrect distribution |
| Metadata | URI mutation | Bait-and-switch |
| Metadata | Mutable attributes | Value manipulation |
| Ownership | Approval race condition | Token theft |
| Ownership | Operator abuse | Unauthorized transfers |
| Escrow | Withdrawal race | Double-spend |
| Cross-marketplace | List on multiple platforms | Conflicting orders |
| Access control | Admin function abuse | Protocol takeover |

### ERC-721 Security Model

```
+----------------------------------------------------------+
|              ERC-721 SECURITY BOUNDARIES                  |
+----------------------------------------------------------+
|                                                          |
|  TRUSTED:                                               |
|  - Contract owner (access control)                      |
|  - Approved operators (setApprovalForAll)               |
|  - Approved addresses (approve)                         |
|                                                          |
|  UNTRUSTED:                                              |
|  - msg.sender (can be any address)                      |
|  - Calldata (can be crafted maliciously)                |
|  - External calls (reentrancy risk)                     |
|  - Block variables (miner manipulable)                  |
|                                                          |
|  CRITICAL FUNCTIONS:                                    |
|  - transferFrom / safeTransferFrom                      |
|  - approve / setApprovalForAll                          |
|  - mint / burn                                          |
|  - tokenURI (metadata)                                  |
|  - ownerOf                                              |
+----------------------------------------------------------+
```

---

## Prerequisites

### Required Knowledge
- ERC-721, ERC-1155, ERC-2981 standards
- NFT marketplace architecture (orderbook vs on-chain)
- IPFS/Arweave metadata storage
- EIP-712 typed data signatures
- Auction mechanics (English, Dutch, sealed-bid)
- Royalty distribution models
- Cross-marketplace listing mechanics
- Wallet interaction patterns (EIP-1193)

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| Foundry | Contract testing | `foundryup` |
| Slither | Static analysis | `pip install slither-analyzer` |
| Etherscan | Contract verification | Web platform |
| IPFS Desktop | Metadata testing | `npm install -g ipfs` |
| Cast | On-chain interaction | Foundry included |
| Python + web3.py | Exploit scripting | `pip install web3` |
| Hardhat | Alternative testing | `npm install --save-dev hardhat` |

### Access Requirements
- Marketplace contract addresses
- ERC-721/1155 contract source code
- IPFS/Arweave gateway access
- Testnet NFTs for live testing
- Understanding of marketplace order types

---

## Methodology

### Phase 1: Contract Discovery and Mapping

```
Step 1: Identify All Contracts
+------------------------------------------+
| 1. NFT collection contract (ERC-721)    |
| 2. Marketplace logic contract           |
| 3. Escrow / transfer proxy              |
| 4. Royalty registry / splitter          |
| 5. Signature verification contract      |
| 6. Auction house contract               |
+------------------------------------------+
         |
         v
Step 2: Source Code Analysis
+------------------------------------------+
| 1. Verify on Etherscan                  |
| 2. Check GitHub for source             |
| 3. Decompile if unverified             |
| 4. Map inheritance hierarchy           |
| 5. Identify external dependencies      |
+------------------------------------------+
         |
         v
Step 3: Access Control Mapping
+------------------------------------------+
| 1. Owner / admin functions             |
| 2. Role-based access (AccessControl)   |
| 3. Approval mechanisms                 |
| 4. Signature verification              |
| 5. Upgrade paths                       |
+------------------------------------------+
```

### Phase 2: Listing and Sale Analysis

```bash
# Check listing state
cast call $MARKETPLACE "getListing(address,uint256)(tuple)" \
  $NFT_CONTRACT $TOKEN_ID --rpc-url $RPC

# Check approval
cast call $NFT_CONTRACT "isApprovedForAll(address,address)(bool)" \
  $SELLER $MARKETPLACE --rpc-url $RPC

# Check current owner
cast call $NFT_CONTRACT "ownerOf(uint256)(address)" $TOKEN_ID --rpc-url $RPC

# Simulate purchase
cast send $MARKETPLACE "buyItem(address,uint256)" \
  $NFT_CONTRACT $TOKEN_ID \
  --value $PRICE --private-key $TEST_KEY --rpc-url $RPC
```

### Phase 3: Signature and Order Validation

```
Signature Validation Checklist:
+------------------------------------------+
| [ ] EIP-712 domain separator correct    |
| [ ] Chain ID validated                  |
| [ ] Contract address in domain          |
| [ ] Nonce or expiration enforced        |
| [ ] Signature not malleable             |
| [ ] Replay protection across chains     |
| [ ] v, r, s component validation        |
| [ ] Signer matches expected address     |
+------------------------------------------+

EIP-712 Domain:
+------------------------------------------+
| name: "Marketplace"                      |
| version: "1"                            |
| chainId: 1                              |
| verifyingContract: 0x...                |
+------------------------------------------+
```

### Phase 4: Royalty Mechanism Testing

```
Royalty Testing:
+------------------------------------------+
| 1. Check ERC-2981 support               |
| 2. Verify royalty receiver address      |
| 3. Test royalty percentage bounds       |
| 4. Check fee calculation accuracy       |
| 5. Test royalty split (if applicable)   |
| 6. Verify marketplace fee + royalty     |
| 7. Test with different sale prices      |
| 8. Check minimum/max royalty            |
+------------------------------------------+
```

### Phase 5: Metadata Integrity Analysis

```
Metadata Security Checklist:
+------------------------------------------+
| [ ] tokenURI is immutable (or controlled |
|     by trusted admin)                    |
| [ ] IPFS CID pinned and verified         |
| [ ] Metadata schema validated            |
| [ ] No hidden attributes exploitable     |
| [ ] Image URI cannot be changed post-mint|
| [ ] JSON structure validated on-chain    |
| [ ] External metadata references secured |
+------------------------------------------+
```

---

## Tool Arsenal

### Foundry NFT Testing

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MarketplaceTest is Test {
    // Test: Listing price manipulation
    function testListingPriceManipulation() public {
        // Setup: Create listing at price X
        // Action: Try to modify price after signature
        // Assert: Original price maintained
    }

    // Test: Signature replay
    function testSignatureReplay() public {
        // Setup: Create signed listing
        // Action: Submit same signature twice
        // Assert: Second submission fails
    }

    // Test: Cancellation griefing
    function testCancellationGriefing() public {
        // Setup: Valid listing exists
        // Action: Attacker tries to cancel
        // Assert: Only seller can cancel
    }

    // Test: Cross-chain listing
    function testCrossChainListing() public {
        // Setup: Listing on chain A
        // Action: Try to fill on chain B
        // Assert: Correct chain validation
    }
}
```

### Slither NFT-Specific Detection

```bash
# ERC-721 specific
slither . --detect locked-ether
slither . --detect arbitrary-send-eth
slither . --detect reentrancy-eth
slither . --detect unchecked-transfer

# Marketplace specific
slither . --detect tx-origin
slither . --detect delegatecall-to-untrusted-contract
slither . --detect unprotected-upgrade

# Custom: Check for missing ownership validation
slither . --print human-summary
```

### IPFS Metadata Verification

```python
import requests
import json
import hashlib

def verify_metadata(token_uri):
    """Verify NFT metadata integrity"""
    # Fetch metadata
    response = requests.get(token_uri)
    metadata = response.json()

    # Check required fields
    required = ["name", "description", "image"]
    for field in required:
        assert field in metadata, f"Missing field: {field}"

    # Verify image is accessible
    image_url = metadata["image"]
    if image_url.startswith("ipfs://"):
        image_url = f"https://ipfs.io/ipfs/{image_url[7:]}"

    img_response = requests.head(image_url)
    assert img_response.status_code == 200, "Image not accessible"

    return metadata

# Usage
metadata = verify_metadata("ipfs://QmHash.../1.json")
print(f"Name: {metadata['name']}")
print(f"Image: {metadata['image']}")
```

### Cast NFT Interactions

```bash
# ERC-721 standard calls
cast call $NFT "balanceOf(address)(uint256)" $OWNER
cast call $NFT "ownerOf(uint256)(address)" $TOKEN_ID
cast call $NFT "tokenURI(uint256)(string)" $TOKEN_ID
cast call $NFT "getApproved(uint256)(address)" $TOKEN_ID
cast call $NFT "isApprovedForAll(address,address)(bool)" $OWNER $OPERATOR

# Marketplace calls
cast call $MP "getListingPrice()(uint256)"
cast call $MP "getListing(address,uint256)(tuple)" $NFT $TOKEN_ID

# Royalty check (ERC-2981)
cast call $NFT "royaltyInfo(uint256,uint256)(address,uint256)" \
  $TOKEN_ID 10000
```

---

## Real-World Examples

### Example 1: OpenSea Listing Vulnerability (2022)

**Vulnerability:** Stale listings on OpenSea could be filled at old prices even after the owner transferred the NFT.

```
Attack Flow:
1. Alice lists NFT for 1 ETH on OpenSea
2. Alice sells NFT to Bob via direct transfer (not through OpenSea)
3. OpenSea listing still valid (linked to token, not owner)
4. Attacker fills Alice's old listing
5. Attacker receives NFT, Bob loses NFT
```

**Root Cause:** Listing validation didn't check current ownership against listing creator.

**Fix:** Validate `ownerOf(tokenId) == listing.seller` at time of execution.

### Example 2: Royalty Bypass via Direct Transfer

```
Attack Flow:
1. Buyer and seller agree to trade off-marketplace
2. Seller lists on marketplace (for royalty tracking)
3. Buyer "buys" at minimum price (pays minimal royalty)
4. Seller sends NFT directly via transferFrom
5. Buyer sends payment via separate transaction
6. Royalty only calculated on minimum price
```

**Root Cause:** No enforcement of royalty on direct transfers.

**Fix:** Use operator filter registry or on-chain royalty enforcement.

### Example 3: Shill Bidding in Auctions

```
Attack Flow:
1. Attacker creates 10 wallet addresses
2. Attacker lists NFT with hidden reserve price
3. Attacker bids from all 10 wallets (shill bidding)
4. Legitimate buyers see high activity, bid higher
5. Attacker wins auction from their own wallet
6. NFT effectively sold to attacker at inflated price
```

**Mitigation:** 
- Require ETH deposit for bidding
- Link wallets via on-chain history
- Limit bid count per address
- Implement minimum bid increment

### Example 4: Cross-Marketplace Listing Exploit

```
Attack Flow:
1. Alice lists NFT for 10 ETH on Marketplace A
2. Alice lists same NFT for 5 ETH on Marketplace B
3. Buyer fills listing on Marketplace B (5 ETH)
4. Before confirmation, attacker fills listing on A (10 ETH)
5. Both transactions pending simultaneously
6. Only one can succeed (NFT double-spend attempt)
```

**Mitigation:** Use cross-marketplace order validation or escrow.

---

## Bypass Techniques

### 1. ERC-721 Approval Race Condition

```
Standard Flow:
1. Alice approves Bob for token 1
2. Bob transfers token 1

Race Condition:
1. Alice approves Attacker for token 1
2. Alice approves Bob for token 1
3. Attacker front-runs, transfers token 1
4. Bob's approval is now invalid

Defense: Use incremental nonce or check allowance before approve
```

### 2. Signature Malleability

```solidity
// Vulnerable: No signature malleability check
function fillOrder(
    bytes memory signature,
    uint256 tokenId
) external {
    bytes32 hash = keccak256(abi.encodePacked(tokenId));
    address signer = ECDSA.recover(hash, signature);
    require(signer == order.seller, "Invalid signature");
    // BUG: ECDSA v value can be flipped (27 <-> 28)
    // creating a different valid signature for same message
}

// Fix: Use OpenZeppelin ECDSA.recover which validates v
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
address signer = ECDSA.recover(hash, v, r, s);
```

### 3. Token URI Mutation

```
Vulnerability: Owner can change tokenURI after listing
1. Attacker lists NFT with legitimate metadata URI
2. Buyer views metadata (appears legitimate)
3. Attacker changes tokenURI to different metadata
4. Buyer's transaction executes
5. Buyer receives NFT with attacker-controlled metadata

Defense: Snapshot tokenURI at listing time, or use immutable metadata
```

### 4. Operator Filter Bypass

```
Attack: Bypass royalty enforcement by:
1. Transfer NFT to a contract you control
2. Contract transfers to buyer directly
3. No marketplace fee or royalty paid

Defense: Use OpenSea Operator Filter Registry
         or on-chain royalty enforcement at contract level
```

---

## Common Pitfalls

### Pitfall 1: Missing tokenURI Validation
```solidity
// BUG: tokenURI can return anything
function tokenURI(uint256 tokenId) public view returns (string memory) {
    return _tokenURIs[tokenId];  // Can be empty or invalid
}

// Fix: Require valid URI
function tokenURI(uint256 tokenId) public view returns (string memory) {
    require(bytes(_tokenURIs[tokenId]).length > 0, "URI not set");
    return _tokenURIs[tokenId];
}
```

### Pitfall 2: Unchecked Enumerable Gas Limit
```solidity
// BUG: Unbounded loop will OOG
function getAllTokens() external view returns (uint256[] memory) {
    uint256 count = totalSupply();
    uint256[] memory tokens = new uint256[](count);
    for (uint256 i = 0; i < count; i++) {
        tokens[i] = tokenByIndex(i);  // Gas limit!
    }
    return tokens;
}

// Fix: Paginate
function getTokens(uint256 start, uint256 count) external view returns (uint256[] memory) {
    uint256 total = totalSupply();
    uint256 end = start + count;
    if (end > total) end = total;
    uint256[] memory tokens = new uint256[](end - start);
    for (uint256 i = start; i < end; i++) {
        tokens[i - start] = tokenByIndex(i);
    }
    return tokens;
}
```

### Pitfall 3: Missing ownerOf Check
```solidity
// BUG: Can transfer NFT you don't own
function buyItem(uint256 tokenId) external payable {
    address seller = listings[tokenId].seller;
    uint256 price = listings[tokenId].price;
    require(msg.value >= price, "Insufficient payment");
    // BUG: Doesn't verify seller still owns the NFT
    nft.transferFrom(seller, msg.sender, tokenId);
}

// Fix: Add ownership check
require(nft.ownerOf(tokenId) == seller, "Seller no longer owns NFT");
```

### Pitfall 4: Reentrancy via onERC721Received
```solidity
// BUG: ERC-721 safeTransferFrom triggers callback
function withdrawProceeds() external nonReentrant {
    uint256 amount = proceeds[msg.sender];
    require(amount > 0, "No proceeds");
    proceeds[msg.sender] = 0;  // State update
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success);
}
// BUG: Attacker contract receives ERC-721 and re-enters
```

### Pitfall 5: Metadata Schema Injection
```python
# BUG: No validation of metadata JSON structure
metadata = json.loads(token_uri_response)

# Attacker sets metadata:
# {
#   "name": "<script>alert(1)</script>",
#   "description": "img src=x onerror=alert(1)"
# }

# Fix: Sanitize all string fields
import bleach
metadata["name"] = bleach.clean(metadata["name"])
```

---

## Reporting Template

```markdown
# NFT Marketplace Vulnerability Report

## Executive Summary
- **Marketplace:** [Name]
- **Contract:** [Address]
- **Vulnerability:** [Type]
- **Severity:** [Critical/High/Medium/Low]
- **CVSS:** [Score]
- **Financial Impact:** [Estimated]

## Vulnerability Description

### Technical Details
[Clear explanation of the vulnerability]

### Affected Component
- **Contract:** [Name and address]
- **Function:** [Function name]
- **Line:** [If applicable]

### Attack Scenario
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Impact
- **NFTs at Risk:** [Number]
- **Estimated Value:** [USD]
- **Users Affected:** [Number]

## Proof of Concept
```solidity
// PoC code
```

## Recommended Fix
```solidity
// Fixed code
```

## References
- [ERC-721 Standard]
- [Similar vulnerabilities]
```

---

## Quick Reference

### NFT Security Checklist

| Check | Description | Priority |
|-------|-------------|----------|
| Ownership Validation | Verify ownerOf at execution | Critical |
| Signature Validation | EIP-712 + malleability check | Critical |
| Reentrancy Guard | onERC721Received callback | High |
| Access Control | Owner/admin restrictions | High |
| URI Immutability | Metadata cannot be changed | High |
| Royalty Enforcement | ERC-2981 compliance | Medium |
| Gas Optimization | Pagination for enumerables | Medium |
| Event Emissions | All state changes logged | Low |
| Upgrade Safety | Storage layout compatible | Medium |
| Cross-chain Safety | Chain ID in signatures | High |

### ERC-721 vs ERC-1155 Security Differences

| Aspect | ERC-721 | ERC-1155 |
|--------|---------|----------|
| Token Type | Non-fungible | Multi-token |
| Balance Check | `balanceOf(owner)` | `balanceOf(owner, id)` |
| Transfer | `transferFrom` | `safeBatchTransferFrom` |
| Approval | Per-token or operator | Operator only |
| Callback | `onERC721Received` | `onERC1155Received` |
| Batch Operations | Not supported | Native support |
| Gas Efficiency | Lower | Higher |

### Common NFT Attack Patterns

```
1. STALE LISTING
   Transfer NFT, old listing remains valid
   Fix: Validate ownership at execution

2. SIGNATURE REPLAY
   Same signature used across chains/marketplaces
   Fix: Include chainId and contractAddress in hash

3. ROYALTY BYPASS
   Direct transfer avoids marketplace royalties
   Fix: On-chain royalty enforcement

4. SHILL BIDDING
   Fake bids inflate auction price
   Fix: Require ETH deposit, link wallets

5. METADATA MUTATION
   Change metadata after listing
   Fix: Immutable or snapshot-based metadata

6. APPROVAL RACE
   Front-run approval transaction
   Fix: Use approve(0) then approve(1)

7. CROSS-MARKETPLACE CONFLICT
   Same NFT listed on multiple platforms
   Fix: Escrow or cross-platform validation

8. GAS GRIEFING
   Large batch operations consume gas
   Fix: Gas limits and pagination

9. FRONT-RUNNING
   Transaction ordering for profit
   Fix: Commit-reveal or Flashbots

10. ACCESS CONTROL BYPASS
    Admin function called by unauthorized user
    Fix: Proper modifier and role checks
```

### Marketplace Security Architecture

```
RECOMMENDED SECURITY LAYERS:
+----------------------------------------------------------+
|                                                          |
|  Layer 1: Contract Security                              |
|  - ReentrancyGuard on all external functions             |
|  - AccessControl for admin operations                    |
|  - Pausable for emergency stops                          |
|  - Upgradeable for bug fixes                             |
|                                                          |
|  Layer 2: Order Validation                               |
|  - EIP-712 signatures with chain ID                      |
|  - Nonce tracking for replay protection                  |
|  - Expiration timestamps                                 |
|  - Price bounds validation                               |
|                                                          |
|  Layer 3: State Validation                               |
|  - ownerOf check at execution time                       |
|  - Approval verification                                 |
|  - Listing staleness check                               |
|  - Cross-marketplace conflict detection                  |
|                                                          |
|  Layer 4: Economic Protection                            |
|  - Minimum bid increment                                 |
|  - Maximum royalty percentage                            |
|  - Fee calculation validation                            |
|  - Escrow for dispute resolution                         |
|                                                          |
|  Layer 5: Monitoring and Alerting                        |
|  - Large transaction alerts                              |
|  - Unusual pattern detection                             |
|  - Contract interaction monitoring                       |
|  - Governance proposal tracking                          |
+----------------------------------------------------------+
```
