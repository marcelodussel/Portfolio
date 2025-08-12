# Hi, I'm **Marcelo**, a blockchain developer.  


While I can't share my commercial projects due to confidentiality, I created this repository to showcase **public smart contracts** I've written for some of my projects.

---

## 📂 Repository Structure

Each folder in this repository contains a project with one or more smart contracts.  
I focus primarily on **Solidity**, but I also integrate with frontend and backend tools (TypeScript, Hardhat, Ethers.js, Web3.js, etc.).

### Example Projects
#### 1️⃣ Bridge (NFT Cross-Chain)
 This NFT bridge is designed with a modular architecture, allowing compatibility with any NFT contract. The only requirement is that the NFT contract must implement the IBridge.sol interface on the destination chain.
 
 The interface defines the bridgeMint function, which grants the Bridge Minter contract permission to mint tokens after verifying that the corresponding NFT has been stored on the originating chain via the Bridge Storage contract.
- **Files:**  
  - `Bridge/NFT.sol` — Example of a compatible ERC-721 NFT contract with the bridgeMint function implementation.
  - `Bridge/BridgeMinter.sol` — Mints NFTs on the destination chain.
  - `Bridge/BridgeStorage.sol` — Stores locked NFTs and emits events for cross-chain verification.
  - `Bridge/IBridge.sol` — Interface to be implemented on the destination chain contract.
- **Highlights:**  
  - Implements cross-chain minting logic.  
  - Uses events for bridge coordination.  
  - Modular architecture for integration with any ERC-721 collection.
---

## 📫 Contact
- **LinkedIn:** [linkedin.com/in/marcelodussel](https://linkedin.com/in/marcelodussel)
