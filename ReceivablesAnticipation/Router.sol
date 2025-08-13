// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./shadowToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Router is Ownable{

    uint private keepPrice; //0.09311000 = 9311000
    uint public keepDenominator = 50; // (1/50) = 2%

    mapping(uint => mapping(address => uint)) private tokensAllowed;
    address public mainWithdrawWallet;

    address private keepToken; 
    uint constant public keepDECIMALS = 100000000;

    mapping(uint => shadowToken) shadowTokens;
    mapping(uint => uint) prices;

    constructor(address keepToken_, address mainWithdrawWallet_){
        keepToken = keepToken_;
        mainWithdrawWallet = mainWithdrawWallet_;
    }

    function campaignInfo(uint _campaignId) external view returns(
        address tokenAddress, 
        string memory tokenName, 
        string memory tokenSymbol, 
        uint tokenSupply, 
        uint tokensSold,
        uint tokenPrice){
        tokenAddress = address(shadowTokens[_campaignId]);
        tokenName = shadowTokens[_campaignId].name();
        tokenSymbol = shadowTokens[_campaignId].symbol();
        tokenSupply = shadowTokens[_campaignId].totalSupply() / 1 ether;
        tokensSold = tokenSupply - shadowTokens[_campaignId].balanceOf(address(this)) / 1 ether;
        tokenPrice = prices[_campaignId];
    }

    function getkeepPrice() external view returns(uint){
        return keepPrice;
    }   

    function getkeepTokenAddress() external view returns(address){
        return keepToken;
    }       

    function getTokensAllowed(uint _campaignId, address _user) external view returns(uint){
        return tokensAllowed[_campaignId][_user];
    }       

    function updatekeepPrice(uint _keepPrice) external onlyOwner{ 
        require(_keepPrice != 0, "Price cannot be zero.");
        keepPrice = _keepPrice;
    }

    function updateCampaignPrice(uint _campaignId, uint price_) external onlyOwner{
        prices[_campaignId] = price_;
    }

    function updatekeepAddress(address keepToken_) external onlyOwner{
        require(keepToken_ != address(0), "Zero address");
        keepToken = keepToken_;
    }

    function createCampaign(string memory name_, string memory symbol_, uint256 totalSupply_, uint price_, uint campaignId_) external onlyOwner{
        require(price_ != 0, "Price cannot be zero.");
        require(totalSupply_ != 0, "Total Supply cannot be zero.");
        
        shadowToken shadowToken = new shadowToken(name_, symbol_, totalSupply_);

        shadowTokens[campaignId_] = shadowToken;
        prices[campaignId_] = price_;
    }

    function addUser(uint _campaignId, address _address, uint _amount) external onlyOwner{
        require(_amount != 0, "Amount cannot be zero.");
        tokensAllowed[_campaignId][_address] = _amount;
    }

    function buy(uint _campaignId, uint _amount) external{
        require(shadowTokens[_campaignId].balanceOf(address(this)) >= _amount * 1 ether, "Insufficient tokens on Contract.");
        require(tokensAllowed[_campaignId][_msgSender()] == _amount, "Wrong amount.");
        require(keepPrice !=0, "keep token price is zero.");
        uint priceRequired = prices[_campaignId] / keepDenominator; // initial: 2%
        uint keepRequired = _amount * priceRequired * keepDECIMALS / keepPrice;
        require(ERC20(keepToken).balanceOf(_msgSender()) >= keepRequired, "Insufficient keep tokens.");
        tokensAllowed[_campaignId][_msgSender()] = 0;
        ERC20(keepToken).transferFrom(_msgSender(), mainWithdrawWallet, keepRequired); 
        shadowTokens[_campaignId].transfer(_msgSender(), _amount * 1 ether);
    }

    function setkeepRequiredDenominator(uint _denominator) external onlyOwner{
        keepDenominator = _denominator;
    }

    function setMainWithdrawWallet(address withdrawWallet_) external onlyOwner{
        mainWithdrawWallet = withdrawWallet_;
    }

    function withdraw() external{
        require(_msgSender() == mainWithdrawWallet, "Not permited.");
        ERC20(keepToken).transfer(_msgSender(), ERC20(keepToken).balanceOf(address(this)));
    }
}
