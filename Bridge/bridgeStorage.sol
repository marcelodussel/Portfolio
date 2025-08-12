// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract BridgeStorage is ReentrancyGuard {
    
    event NFTStored(address indexed user, address indexed nftContract, uint256 indexed tokenId);
    event NFTBatchStored(address indexed user, address indexed nftContract, uint256[] tokenIds);
    event NFTWithdrawn(address indexed user, address indexed nftContract, uint256 indexed tokenId);
    event NFTBatchWithdrawn(address indexed user, address indexed nftContract, uint256[] tokenIds);

    mapping(address => mapping(address => mapping(uint256 => bool))) private storedNFTs;

    function storeNFT(address nftContract, uint256 tokenId) external nonReentrant {
        IERC721 nft = IERC721(nftContract);
        require(nft.getApproved(tokenId) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "BridgeStorage: Not approved");

        nft.transferFrom(msg.sender, address(this), tokenId);
        storedNFTs[msg.sender][nftContract][tokenId] = true;

        emit NFTStored(msg.sender, nftContract, tokenId);
    }

    function storeMultipleNFTs(address nftContract, uint256[] calldata tokenIds) external nonReentrant {
        IERC721 nft = IERC721(nftContract);

        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(nft.getApproved(tokenIds[i]) == address(this) || nft.isApprovedForAll(msg.sender, address(this)), "BridgeStorage: Not approved");

            nft.transferFrom(msg.sender, address(this), tokenIds[i]);
            storedNFTs[msg.sender][nftContract][tokenIds[i]] = true;
        }

        emit NFTBatchStored(msg.sender, nftContract, tokenIds);
    }

    function isStored(address user, address nftContract, uint256 tokenId) external view returns (bool) {
        return storedNFTs[user][nftContract][tokenId];
    }
}
