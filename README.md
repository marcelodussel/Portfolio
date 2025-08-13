# Hi, I'm **Marcelo**, a blockchain developer.  


While I can't share my commercial projects due to confidentiality, I created this repository to showcase **public smart contracts** I've written for some of my projects.

---

## 📂 Repository Structure

Each folder in this repository contains a project with one or more smart contracts that I have developed.
My primary focus is Solidity, but I also work on frontend and backend integrations using tools such as TypeScript, Hardhat, Ethers.js, and Web3.js.

To protect the privacy of the companies I’ve worked with, some variables, contract names, and certain logic have been altered. However, the core architecture, patterns, and functionality remain faithful to the original implementations.
This repository is only meant to showcase my coding style and problem-solving approach.

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
#### 2️⃣ Receivables Anticipation
The Router smart contract is designed to manage token sale campaigns. It was implemented for a platform focused on receivables anticipation, where each campaign represented a specific receivable.

Each campaign issues its own ERC-20 compliant shadowToken, representing the investment shares for that campaign. Investors can purchase these tokens using a specified ERC-20 token (keepToken), at a price defined per campaign.

- **Files:**  
  - `ReceivablesAnticipation/router.sol` — Manages campaigns for receivables anticipation, handling token creation, sales, and payment logic using a specific ERC-20 token as currency.
- **Highlights:**  
  - Allows creation of multiple campaigns, each with its own ERC-20 shadowToken.
  - Supports investor whitelisting with predefined purchase amounts.
  - Integrates a configurable fee mechanism via keepDenominator.
  - Handles payments in a designated ERC-20 token, with price conversion logic.
  - Centralized withdrawal wallet for collected funds.
---


## 📫 Contact
- **LinkedIn:** [linkedin.com/in/marcelodussel](https://linkedin.com/in/marcelodussel)
