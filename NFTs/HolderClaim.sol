// SPDX-License-Identifier: MIT

pragma solidity >=0.8.9 <0.9.0;

import 'erc721a/contracts/extensions/ERC721AQueryable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/cryptography/MerkleProof.sol';
import '@openzeppelin/contracts/security/ReentrancyGuard.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract HolderClaim is Ownable, ReentrancyGuard {

  mapping(address => bool) public whitelistClaimed;
  mapping(address => bool) public whitelisted;

  uint256 public cost;
  uint256 public maxMintAmountPerTx = 2;

  bool public whitelistMintEnabled = false;

  address public dalmatiansContractAddr = 0x4ef680e308D813605C5eF38fEaFe497525F61F0C; //0x4ef680e308D813605C5eF38fEaFe497525F61F0C 0x7CE5Bebcb5368304054880B85f5D97330E6115Ef
  address public teamWallet = 0xa06788D55b933f67CdFB18960720CFCf968289eF;

  ERC721A private dalmatiansContract;

  constructor(uint256 _cost,uint256 _maxMintAmountPerTx){
    setCost(_cost);
    maxMintAmountPerTx = _maxMintAmountPerTx;
    dalmatiansContract = ERC721A(0x4ef680e308D813605C5eF38fEaFe497525F61F0C);
  }

  modifier mintCompliance(uint256 _mintAmount) {
    require(_mintAmount > 0 && _mintAmount <= maxMintAmountPerTx, 'Invalid mint amount!');
    _;
  }

  modifier mintPriceCompliance(uint256 _mintAmount) {
    require(msg.value >= cost * _mintAmount, 'Insufficient funds!');
    _;
  }

  function whitelistMint() public payable mintCompliance(2) mintPriceCompliance(2) {
    // Verify whitelist requirements
    require(whitelistMintEnabled, 'The whitelist sale is not enabled!');
    require(!whitelistClaimed[_msgSender()], 'Address already claimed!');
    require(whitelisted[_msgSender()], 'Not whitelisted!');

    //Check Available IDs
    uint256 dalmatiansCount = dalmatiansContract.balanceOf(teamWallet);
    uint256[] memory tokens = new uint256[](dalmatiansCount);
    uint counter = 0;
      for(uint i = 1; i <= dalmatiansContract.totalSupply(); i++){
        if(dalmatiansContract.ownerOf(i) == teamWallet){
         tokens[counter] = i;
         counter++;
        }
      }

    whitelistClaimed[_msgSender()] = true;

    dalmatiansContract.safeTransferFrom(teamWallet, _msgSender(), tokens[0]);
    dalmatiansContract.safeTransferFrom(teamWallet, _msgSender(), tokens[1]);
  }

  function setCost(uint256 _cost) public onlyOwner {
    cost = _cost;
  }

  function setMaxMintAmountPerTx(uint256 _maxMintAmountPerTx) public onlyOwner {
    maxMintAmountPerTx = _maxMintAmountPerTx;
  }

  function setWhitelistMintEnabled(bool _state) public onlyOwner {
    whitelistMintEnabled = _state;
  }

  function withdraw() public onlyOwner nonReentrant {
    // Transfer the contract balance to the owner
    (bool success, ) = payable(owner()).call{value: address(this).balance}('');
    require(success, 'Withdrawal failed');
  }
}