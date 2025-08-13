// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./RepToken.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

contract Router is ERC1155Supply, Ownable{

    mapping(uint => uint) private campaignSupply;
    mapping(uint => uint) private prices;

    address private usdtAddr;
    address public mainWallet;

    constructor(address initialOwner_, address _usdtAddr) Ownable(initialOwner_){
        usdtAddr = _usdtAddr;
        mainWallet = initialOwner_;
    }

    function campaignInfo(uint _campaignId) external view returns(
        uint tokenSupply, 
        uint tokensSold,
        uint tokenPrice){
        tokenSupply = repTokens[_campaignId].totalSupply();
        tokensSold = tokenSupply - repTokens[_campaignId].balanceOf(address(this));
        tokenPrice = prices[_campaignId];
    }

    function createCampaign(uint campaignId_, uint256 campaignSupply_, uint price_) external onlyOwner{
        require(price_ != 0, "Price cannot be zero.");
        require(totalSupply_ != 0, "Total Supply cannot be zero.");
        campaignSupply[campaignId_] = campaignSupply_;
        prices[campaignId_] = price_;
    }

    function updateCampaignPrice(uint _campaignId, uint price_) external onlyOwner{
        prices[_campaignId] = price_;
    }

    function setMainWallet(address _mainWallet) external onlyOwner{
        mainWallet = _mainWallet;
    }

    function setUsdtAddr(address _usdtAddr) external onlyOwner{
        usdtAddr = _usdtAddr;
    }

    function buy(uint _campaignId, uint _amount) external {
        require(totalSupply(_campaignId) + _amount >= campaignSupply(_campaignId), "Amount exceeds supply.");
        ERC20(usdtAddr).transferFrom(_msgSender(), mainWallet, _amount * prices[_campaignId]);
        _mint(_msgSender(), _campaignId, _amount, "");
    }

    function distribute(uint _campaignId, uint _amount, address _distributeTokenAddress) external onlyOwner {
        address[] memory buyers = repTokens[_campaignId].getBuyers();
        for(uint i = 0; i < buyers.length; i++){
            ERC20(_distributeTokenAddress).transferFrom(_msgSender(), buyers[i], _amount * repTokens[_campaignId].balanceOf(buyers[i])/repTokens[_campaignId].totalSupply());
        }
    }

    function burnAll(uint _campaignId) external onlyOwner {
        address[] memory buyers = repTokens[_campaignId].getBuyers();
        for(uint i = 0; i < buyers.length; i++){
            repTokens[_campaignId].routerBurn(buyers[i], repTokens[_campaignId].balanceOf(buyers[i]));
        }
    }

    function withdrawERC20(address _addr) external onlyOwner{
        ERC20(_addr).transfer(_msgSender(), ERC20(_addr).balanceOf(address(this)));
    }
}