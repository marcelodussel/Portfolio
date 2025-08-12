// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./IBridge.sol";

contract BridgeMinter is Ownable {

    constructor() Ownable(msg.sender) {}

    event MintAuthorized(address indexed user, address indexed nftContract, uint256 indexed tokenId);
    event MintBatchAuthorized(address indexed user, address indexed nftContract, uint256[] tokenIds);
    event NFTMinted(address indexed user, address indexed nftContract, uint256 indexed tokenId);
    event NFTBatchMinted(address indexed user, address indexed nftContract, uint256[] tokenIds);

    mapping(address => mapping(address => mapping(uint256 => bool))) public authorizedMints;
    uint private taxAmount;

    function authorizeMint(address user, address nftContract, uint256 tokenId) external onlyOwner {
        require(!authorizedMints[user][nftContract][tokenId], "Token already authorized");
        authorizedMints[user][nftContract][tokenId] = true;
        emit MintAuthorized(user, nftContract, tokenId);
    }

    function authorizeBatchMint(address user, address nftContract, uint256[] calldata tokenIds) external onlyOwner {
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(!authorizedMints[user][nftContract][tokenIds[i]], "Token already authorized");
            authorizedMints[user][nftContract][tokenIds[i]] = true;
        }
        emit MintBatchAuthorized(user, nftContract, tokenIds);
    }

    function mintNFT(address nftContract, uint256 tokenId) external payable {
        require(msg.value >= taxAmount, "Not enough funds sent in transaction.");
        require(authorizedMints[msg.sender][nftContract][tokenId], "No authorization");
        
        authorizedMints[msg.sender][nftContract][tokenId] = false;

        IBridge nft = IBridge(nftContract);
        nft.bridgeMint(msg.sender, tokenId);

        emit NFTMinted(msg.sender, nftContract, tokenId);
    }

    function mintBatchNFTs(address nftContract, uint256[] calldata tokenIds) external {
        uint256 length = tokenIds.length;
        require(length > 0, "No tokens provided");

        IBridge nft = IBridge(nftContract);

        for (uint256 i = 0; i < length; i++) {
            uint256 tokenId = tokenIds[i];
            require(authorizedMints[msg.sender][nftContract][tokenId], "No authorization");

            authorizedMints[msg.sender][nftContract][tokenId] = false;

            nft.bridgeMint(msg.sender, tokenId);
        }

        emit NFTBatchMinted(msg.sender, nftContract, tokenIds);
    }

    function setTaxAmount(uint _newTax) external onlyOwner {
        require(_newTax <= 0.5 ether, "Tax too high.");
        taxAmount = _newTax;
    }

    function getTaxAmount() internal view returns(uint) {
        return taxAmount;
    }

    function isMintAuthorized(address user, address nftContract, uint256 tokenId) external view returns (bool) {
        return authorizedMints[user][nftContract][tokenId];
    }
}
