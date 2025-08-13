// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import './Dalmatians.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract Airdrop is Ownable{

    Dalmatians private dalmatiansContract;

    constructor(){
        dalmatiansContract = Dalmatians(0x7CE5Bebcb5368304054880B85f5D97330E6115Ef);
    }

    function getAmountTokens() external view onlyOwner returns(uint256){
        uint256 dalmatiansCount = dalmatiansContract.balanceOf(_msgSender());
        return dalmatiansCount;
    }

    function test(uint i) external view onlyOwner returns(address owneroftoken){
        owneroftoken = dalmatiansContract.ownerOf(i);
    }

    function getAvailableTokens() external view onlyOwner returns(uint256[] memory){
        uint256 dalmatiansCount = dalmatiansContract.balanceOf(_msgSender());
        uint256[] memory tokens = new uint256[](dalmatiansCount);
        uint counter = 0;
            for(uint i = 1; i <= dalmatiansContract.totalSupply(); i++){
                if(dalmatiansContract.ownerOf(i) == _msgSender()){
                tokens[counter] = i;
                counter++;
                }
            }
        return tokens;
    }

    function getIfAvailable(uint[] calldata ids) external view onlyOwner returns(uint){
        for(uint i = 0; i < ids.length; i++){
            if(dalmatiansContract.ownerOf(i) == _msgSender()){
                return i;
            }
        }
        return 0;
    }

    function sendAirdrop(address[] calldata addresses) external onlyOwner{

        uint256 dalmatiansCount = dalmatiansContract.balanceOf(_msgSender());
        uint256[] memory tokens = new uint256[](dalmatiansCount);
        uint counter = 0;
            for(uint i = 1; i <= dalmatiansContract.totalSupply(); i++){
                if(dalmatiansContract.ownerOf(i) == _msgSender()){
                tokens[counter] = i;
                counter++;
                }
            }

        for(uint i = 0; i < addresses.length; i++){
            dalmatiansContract.safeTransferFrom(msg.sender, addresses[i], tokens[i]);
        }
    }

}
