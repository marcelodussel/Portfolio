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
#### 3️⃣ NFT Campaign Router
This smart contract extends the campaign management concept into the NFT space.
Each campaign is represented by a custom collection (CampaignNFT), which can be created, priced, and managed directly by the Router.
Buyers purchase campaign NFTs using a predefined ERC-20 token (e.g., USDT), and the Router automatically mints tokens to the buyer’s wallet.

- **Files:**  
  - `ReceivablesAnticipation/CampaignNFT.sol` — ERC-721 NFT representing ownership in a specific receivable campaign.
  - `ReceivablesAnticipation/IRepToken.sol` — Interface for the receivable representation token.
  - `ReceivablesAnticipation/RepToken.sol` — ERC-20 token representing a receivable asset.
  - `ReceivablesAnticipation/Router721.sol` — Manages campaigns that issue ERC-721 NFTs.
  - `ReceivablesAnticipation/Router1155.sol` — Manages campaigns that issue ERC-1155 tokens.
- **Highlights:**  
  - Creates and manages multiple NFT-based sale campaigns.
  - Supports campaign metadata updates (price, base URI, wallet address).
  - Allows both single and bulk NFT purchases using an ERC-20 token (e.g., USDT).
  - Includes token distribution functions to NFT holders, with optional ID range targeting.
---
#### 4️⃣ Token Vesting
The keepVesting smart contract manages the sale and time-locked distribution of Keep Token across multiple allocation categories, ensuring controlled token release according to predefined cliffs and vesting schedules.
It supports both on-chain purchases using BUSD and off-chain allocations (e.g., PIX), with configurable admin roles for distribution management.

- **Files:**  
  - `KeepToken/keepVesting.sol` — Handles token vesting for Seed Sale, Private Sale, Advisors, and Airdrop, integrating payment in BUSD and periodic vesting release in Keep Token.
- **Highlights:**  
  - Four independent vesting categories, each with custom cliff, TGE percentage, and monthly vesting rate.
  - On-chain purchase functions with BUSD payment and off-chain admin allocations.
  - Token Generation Event (TGE) logic for initial unlock, followed by monthly parcel-based vesting.
  - Admin-controlled monthly distribution of vested tokens to all participants.
  - Sales cap enforcement per category with minimum purchase limits.
  - Owner and admin role separation for secure operations.
---
#### 5️⃣ NFT Ecosystem — OpenSea-Compatible Collections & Utilities
This NFT ecosystem consists of multiple ERC-721 collections and utility contracts, all designed to be fully compatible with OpenSea’s metadata and trading standards at the time of development. Each collection features unique thematic artwork, on-chain minting logic, and optional claiming mechanics for holders.

- **Files:**  
  - `NFTs/Airdrop.sol` — Handles airdropping of NFTs to predefined addresses, ensuring cost-efficient distribution and OpenSea metadata compliance.
  - `NFTs/Dalmatians.sol` — Core ERC-721 collection for the “Dalmatians” series, with on-chain minting, supply caps, and standard marketplace integration.
  - `NFTs/DeadBirds.sol` — ERC-721 “Dead Birds” collection.
  - `NFTs/HolderClaim.sol` — Enables eligible NFT holders to claim special edition tokens or companion NFTs without payment.
  - `NFTs/InfectedDalmatians.sol` — Themed ERC-721 collection expanding on the Dalmatians series with its own minting logic.
- **Highlights:**  
  - Full ERC-721 compliance with OpenSea’s token metadata and trading standards.
  - Multiple interconnected NFT collections, each with independent supply limits.
  - Airdrop functionality for cost-effective token distribution to specific wallets.
  - Holder-exclusive claim mechanics for special drops and companion NFTs.
  - Optimized gas usage for batch operations like airdrops and claims.
  - Built-in role management for secure minting and administrative actions.
---
## 📫 Contact
- **LinkedIn:** [linkedin.com/in/marcelodussel](https://linkedin.com/in/marcelodussel)
