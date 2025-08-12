// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IBridge.sol";

contract NFT is ERC721, IBridge {
    address public owner;
    address public bridgeAddress;
    string public baseURI;

    constructor() ERC721("TestNFT", "TNFT") {
        owner = msg.sender;
    }

    function ownerMint(uint256[] calldata tokenIds) public {
        require(msg.sender == owner, "Not owner.");
        for(uint i = 0; i < tokenIds.length; i++){
            _safeMint(msg.sender, tokenIds[i]);
        }
    }

    function bridgeMint(address _to, uint256 tokenId) external {
        require(msg.sender == bridgeAddress, "Not bridge.");
        _safeMint(_to, tokenId);
    }

    function setBridgeAddress(address _bridgeAddress) external {
        require(msg.sender == owner, "Not owner.");
        bridgeAddress = _bridgeAddress;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function setBaseURI(string calldata _URI) external {
        require(msg.sender == owner, "Not owner.");
        baseURI = _URI;
    }
}
