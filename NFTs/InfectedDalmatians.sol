// SPDX-License-Identifier: MIT

 /////////////////////////////////////////////////////////////////////////////////////////////////////////
 //                                                                              @@                     //
 // @@                @@          @@       @@@@@@@@    @@@@@@                    @@                     //
 //  @@              @@           @@              @@   @@                     @@@@@@@@      @@          //
 //   @@            @@   @@@@     @@             @@    @@      @@@@@@    @@@@    @@                     //
 //    @@    @@    @@   @@  @@    @@@@@    @@@@@@@@    @@@@@       @@   @@       @@         @@  @@@@@@  //
 //     @@  @@@@  @@    @@@@@     @@  @@          @@   @@      @@@@@@    @@@     @@         @@  @    @  //
 //      @@@@  @@@@     @@        @@  @@          @@   @@      @   @@      @@    @@    @@   @@  @   @@  //
 //       @@    @@       @@@@@    @@@@@    @@@@@@@@    @@      @@@@@@   @@@@     @@    @@   @@  @@@@@@  //
 //                                                                                                     //
 /////////////////////////////////////////////////////////////////////////////////////////////////////////

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';
import {ERC2981} from "@openzeppelin/contracts/token/common/ERC2981.sol";
import "operator-filter-registry/src/DefaultOperatorFilterer.sol";
import "./IBoxbies.sol";

contract InfectedDalmatians is ERC721A, Ownable, ReentrancyGuard, ERC2981, DefaultOperatorFilterer {
  using Strings for uint256;

  bytes32 public merkleRoot;

  mapping(address => bool) public whitelist2Claimed;
  mapping(address => bool) public whitelist;
  mapping(address => bool) public whitelist2;
  mapping(address => uint) public availableMints;

  address[] public airdropList;

  string public uriPrefix = '';
  string public uriSuffix = '.json';
  string public hiddenMetadataUri;

  uint256 public cost;
  uint256 public maxSupply;
  uint256 public maxMintAmountPerTx;
  uint256 public whitelist2MintAmount;
  uint256 public whitelist2Limit;

  bool public merkleTreeEnabled = true;
  bool public paused = true;
  bool public whitelistMintEnabled = false;
  bool public whitelistMint2Enabled = false;
  bool public revealed = false;

  ERC721A public boxbiesContract = ERC721A(0x5B38Da6a701c568545dCfcB03FcB875f56beddC4);
  mapping(uint256 => bool) public usedBoxbiesNFTs;

  constructor(
    string memory _tokenName,
    string memory _tokenSymbol,
    uint256 _cost,
    uint256 _maxSupply,
    uint256 _maxMintAmountPerTx,
    string memory _hiddenMetadataUri,
    address _royaltyReceiver,
    uint96 _royaltyNumerator,
    address _boxbiesContract
  ) ERC721A(_tokenName, _tokenSymbol) {
    setCost(_cost);
    maxSupply = _maxSupply;
    maxMintAmountPerTx = _maxMintAmountPerTx;
    setHiddenMetadataUri(_hiddenMetadataUri);
    _setDefaultRoyalty(_royaltyReceiver, _royaltyNumerator);
    boxbiesContract = ERC721A(_boxbiesContract);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    require(totalSupply() + _mintAmount <= maxSupply, 'Max supply exceeded!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  //@dev This function does not verify if the wallet has alredy claimed, allowing the same address to mint multiple times if they have enough Boxbies.
  function whitelistMint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    uint256 eligibleNfts = 0;

    uint256 dalmatiansCount = boxbiesContract.balanceOf(_msgSender());
    uint256[] memory tokens = new uint256[](dalmatiansCount);
    uint counter = 0;
      for(uint i = 1; i <= boxbiesContract.totalSupply(); i++){
        if(boxbiesContract.ownerOf(i) == _msgSender()){
         tokens[counter] = i;
         counter++;
        }
      }

    for (uint256 i = 0; i < tokens.length; i++) {
        if (usedBoxbiesNFTs[tokens[i]] == false) {
            eligibleNfts++;
            usedBoxbiesNFTs[tokens[i]] = true;
        }
    }
    uint availableToMint;

    if (eligibleNfts >= 50) {
      availableToMint = 100;

    } else if (eligibleNfts >= 30) {
      availableToMint = 60;

    } else if (eligibleNfts >= 10) {
      availableToMint = 20;

    } else if (eligibleNfts >= 5) {
      availableToMint = 10;

    } else if (eligibleNfts >= 1) {
      availableToMint = 2;

    } else {
        require(availableMints[_msgSender()] > 0, "No eligible NFTs found in the wallet.");
        availableToMint = availableMints[_msgSender()];
    }

    require(_mintAmount <= availableToMint, "Mint Amount limit exceeded.");

    if(_mintAmount < availableToMint){
      availableMints[_msgSender()] = availableToMint - _mintAmount;
    } else if (_mintAmount == availableToMint && availableMints[_msgSender()] > 0){
        availableMints[_msgSender()] = 0;
    }
    _safeMint(_msgSender(), _mintAmount);
  }

  function whitelistMint2(uint _amount, bytes32[] calldata _merkleProof) public payable mintCompliance(_amount) mintPriceCompliance(_amount) {
    // Verify whitelist requirements
    require(whitelistMint2Enabled, 'The whitelist 2 sale is not enabled!');
    require(!whitelist2Claimed[_msgSender()], 'Address already claimed!');
    require(whitelist2MintAmount <= whitelist2Limit, 'Minting Phase Supply reached.');

    if(merkleTreeEnabled){
      bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));
      require(MerkleProof.verify(_merkleProof, merkleRoot, leaf), 'Invalid proof!');
    } else {
      require(whitelist2[msg.sender]);
    }

    whitelist2MintAmount+= _amount;
    whitelist2Claimed[_msgSender()] = true;
    _safeMint(_msgSender(), _amount);
  }

  function markUsedNFTs(uint256[] calldata _tokenIds) external onlyOwner {
    for (uint256 i = 0; i < _tokenIds.length; i++) {
        usedBoxbiesNFTs[_tokenIds[i]] = true;
    }
  }

  function mint(uint256 _mintAmount) public payable mintCompliance(_mintAmount) mintPriceCompliance(_mintAmount) {
    require(!paused, 'The contract is paused!');

    _safeMint(_msgSender(), _mintAmount);
  }

  function airdrop() external mintCompliance(airdropList.length) onlyOwner {

    for(uint i = 0; i < airdropList.length; i++){
      _safeMint(airdropList[i], 1);
    }
  }

  function setWhitelist2Limit(uint _whitelist2Limit) external onlyOwner {
    whitelist2Limit = _whitelist2Limit;
  }

  function setAirdropList(address[] calldata _airdropList) external onlyOwner {
    airdropList = _airdropList;
  }
  
  function mintForAddress(uint256 _mintAmount, address _receiver) public mintCompliance(_mintAmount) onlyOwner {
    _safeMint(_receiver, _mintAmount);
  }

  function _startTokenId() internal view virtual override returns (uint256) {
    return 1;
  }

  function tokenURI(uint256 _tokenId) public view virtual override returns (string memory) {
    require(_exists(_tokenId), 'ERC721Metadata: URI query for nonexistent token');

    if (revealed == false) {
      return hiddenMetadataUri;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, _tokenId.toString(), uriSuffix))
        : '';
  }

  function setMerkleTreeStatus(bool _state) public onlyOwner {
    merkleTreeEnabled = _state;
  }

  function setWhitelist(bool firstWhitelist, address[] calldata addresses) public onlyOwner {
    if(firstWhitelist){
      for(uint i = 1; i < addresses.length; i++){
        whitelist[msg.sender] = true;
      }
    } else {
      for(uint i = 1; i < addresses.length; i++){
        whitelist2[msg.sender] = true;
      }
    }
  }

  function setRevealed(bool _state) public onlyOwner {
    revealed = _state;
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setHiddenMetadataUri(string memory _hiddenMetadataUri) public onlyOwner {
    hiddenMetadataUri = _hiddenMetadataUri;
  }

  function setUriPrefix(string memory _uriPrefix) public onlyOwner {
    uriPrefix = _uriPrefix;
  }

  function setUriSuffix(string memory _uriSuffix) public onlyOwner {
    uriSuffix = _uriSuffix;
  }

  function setPaused(bool _state) public onlyOwner {
    paused = _state;
  }

  function setMerkleRoot(bytes32 _merkleRoot) public onlyOwner {
    merkleRoot = _merkleRoot;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function setWhitelist2MintEnabled(bool _state) public onlyOwner {
    whitelistMint2Enabled = _state;
  }

  function withdraw() public onlyOwner nonReentrant {
    // Transfer the contract balance to the owner
    (bool success, ) = payable(owner()).call{value: address(this).balance}('');
    require(success, 'Withdrawal failed');
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return uriPrefix;
  }

  function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721A, ERC2981) returns (bool) {
    return ERC721A.supportsInterface(interfaceId) || ERC2981.supportsInterface(interfaceId);
  }

  function setDefaultRoyalty(address receiver, uint96 feeNumerator) public onlyOwner {
    _setDefaultRoyalty(receiver, feeNumerator);
  }

  //@dev following functions overrides the ERC721A methods in order to comply with OpenSea Standards:
  //https://github.com/ProjectOpenSea/operator-filter-registry

  function setApprovalForAll(address operator, bool approved) public override onlyAllowedOperatorApproval(operator) {
    super.setApprovalForAll(operator, approved);
  }

  function approve(address operator, uint256 tokenId) public payable override onlyAllowedOperatorApproval(operator) {
    super.approve(operator, tokenId);
  }

  function transferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
    super.transferFrom(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId) public payable override onlyAllowedOperator(from) {
    super.safeTransferFrom(from, to, tokenId);
  }

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public payable override onlyAllowedOperator(from) {
    super.safeTransferFrom(from, to, tokenId, data);
  }
}