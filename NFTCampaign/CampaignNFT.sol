// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract CampaignNFT is ERC721Enumerable {

  string public baseURI;
  address public immutable routerAddr;
  uint256 public immutable maxSupply;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    uint _maxSupply
  ) ERC721(_name, _symbol) {
    routerAddr = _msgSender();
    setBaseURI(_initBaseURI);
    maxSupply = _maxSupply;
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(address _to, uint256 _mintAmount) public {
    require(_msgSender() == routerAddr, "Mint is only allowed to Router.");
    uint256 supply = totalSupply();
    require(_mintAmount > 0, "Null mint amount.");
    require(supply + _mintAmount <= maxSupply, "Mint exceeds Max Supply.");

    for (uint256 i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
    }
  }

  function routerBurn(uint _start, uint _end) public {
    require(_msgSender() == routerAddr, "Burn is only allowed to Router.");

    for (uint256 i = _start; i <= _end; i++) { _burn(i); }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint256[] memory) {
    uint256 ownerTokenCount = balanceOf(_owner);
    uint256[] memory tokenIds = new uint256[](ownerTokenCount);
    for (uint256 i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function tokenURI(uint256 tokenId)
    public
    view
    virtual
    override
    returns (string memory) {
    require(ownerOf(tokenId) != address(0),"ERC721Metadata: URI query for nonexistent token");
    return _baseURI();
  }

  function setBaseURI(string memory _newBaseURI) public {
    require(_msgSender() == routerAddr, "Only allowed to Router.");
    baseURI = _newBaseURI;
  }
}