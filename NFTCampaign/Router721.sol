// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/access/Ownable.sol";
import "./CampaignNFT.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

contract Router is Ownable{

    mapping(uint => CampaignNFT) private campaignNFTs;
    mapping(uint => uint) private prices;

    address private usdtAddr;
    address public mainWallet;

    constructor(address initialOwner_, address _usdtAddr) Ownable(initialOwner_){
        usdtAddr = _usdtAddr;
        mainWallet = initialOwner_;
    }

    function campaignInfo(uint _campaignId) external view returns(
        address tokenAddress, 
        string memory tokenName, 
        string memory tokenSymbol, 
        uint tokenCurrentSupply, 
        uint tokenMaxSupply,
        uint tokenPrice){
        tokenAddress = address(campaignNFTs[_campaignId]);
        tokenName = campaignNFTs[_campaignId].name();
        tokenSymbol = campaignNFTs[_campaignId].symbol();
        tokenCurrentSupply = campaignNFTs[_campaignId].totalSupply();
        tokenMaxSupply = campaignNFTs[_campaignId].maxSupply();
        tokenPrice = prices[_campaignId];
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

    function setCampaignBaseURI(uint _campaignId, string memory _newBaseURI) external onlyOwner{
        campaignNFTs[_campaignId].setBaseURI(_newBaseURI);
    }

    function createCampaign(string memory name_, string memory symbol_, string memory uri_, uint256 maxSupply_, uint price_, uint campaignId_) external onlyOwner{
        require(price_ != 0, "Price cannot be zero.");
        require(maxSupply_ != 0, "Total Supply cannot be zero.");
        
        CampaignNFT campaignNFT = new CampaignNFT(name_, symbol_, uri_ ,maxSupply_);

        campaignNFTs[campaignId_] = campaignNFT;
        prices[campaignId_] = price_;
    }

    function buy(uint _campaignId, uint _amount) external {
        ERC20(usdtAddr).transferFrom(_msgSender(), mainWallet, _amount * prices[_campaignId]);
        campaignNFTs[_campaignId].mint(_msgSender(), _amount);
    }

    function buy(uint[] calldata _campaignId, uint[] calldata _amount) external {
        require(_campaignId.length == _amount.length, "Campaign IDs and Amounts arrays must have the same length.");
        uint sum;
        for(uint i = 0; i < _campaignId.length; i++){
            sum += _amount[i] * prices[_campaignId[i]];
            campaignNFTs[_campaignId[i]].mint(_msgSender(), _amount[i]);
        }
        ERC20(usdtAddr).transferFrom(_msgSender(), mainWallet, sum);
    }

    function distribute(uint _campaignId, uint _amount, address _distributeTokenAddress) external onlyOwner {
        for(uint i = 1; i <= campaignNFTs[_campaignId].totalSupply(); i++){
            ERC20(_distributeTokenAddress).transferFrom(_msgSender(), campaignNFTs[_campaignId].ownerOf(i), _amount / campaignNFTs[_campaignId].totalSupply());
        }
    }

    function distributeByLimits(uint _campaignId, uint _amount, address _distributeTokenAddress, uint _start, uint _end) external onlyOwner {
        require(_start <= _end, "Out of Limits.");
        require(_end <= campaignNFTs[_campaignId].totalSupply(), "Out of Limits.");
        for(uint i = _start; i <= _end; i++){
            ERC20(_distributeTokenAddress).transferFrom(_msgSender(), campaignNFTs[_campaignId].ownerOf(i), _amount / campaignNFTs[_campaignId].totalSupply());
        }
    }

    function burnAll(uint _campaignId) external onlyOwner {
        campaignNFTs[_campaignId].routerBurn(1, campaignNFTs[_campaignId].totalSupply());
    }

    function burnByLimits(uint _campaignId, uint _start, uint _end) external onlyOwner {
        require(_start <= _end, "Out of Limits.");
        require(_end <= campaignNFTs[_campaignId].totalSupply(), "Out of Limits.");
        campaignNFTs[_campaignId].routerBurn(_start, _end);
    }

    function withdrawERC20(address _addr) external onlyOwner{
        ERC20(_addr).transfer(_msgSender(), ERC20(_addr).balanceOf(address(this)));
    }
}