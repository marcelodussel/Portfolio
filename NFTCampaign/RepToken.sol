// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

contract RepToken is ERC20 {

    address immutable routerAddr;
    address[] private buyers;
    bool private isPaused;

    constructor(string memory name_, string memory symbol_, uint256 initialSupply_) ERC20(name_, symbol_) {
        _mint(msg.sender, initialSupply_);
        routerAddr = _msgSender();
        isPaused = true;
    }

    modifier onlyRouter() {
        require(_msgSender() == routerAddr, "Only Router is Allowed.");
        _;
    }

    function getIsPaused() public view returns (bool) {
        return isPaused;
    }

    function getBuyer(uint _index) public view returns (address) {
        return buyers[_index];
    }

    function getBuyers() public view returns (address[] memory) {
        return buyers;
    }

    function routerSetPause(bool _isPaused) public onlyRouter {
        isPaused = _isPaused;
    }

    function routerAddBuyer(address _address) public onlyRouter{
        buyers.push(_address);
    }

    function routerEditBuyer(address _address, uint _index) public onlyRouter{
        buyers[_index] = _address;
    }

    function routerBurn(address _address, uint256 _value) public onlyRouter{
        _burn(_address, _value);
    }

    function _update(address from, address to, uint256 value) internal virtual override {
        require(!isPaused || _msgSender() == routerAddr, "Only Router is Allowed to transfer tokens at this time.");
        super._update(from, to, value);
    }
}