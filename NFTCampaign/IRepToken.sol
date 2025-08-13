// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v5.0.0/contracts/token/ERC20/ERC20.sol";

interface IRepToken {

    function getBuyer(uint _index) external view returns (address);

    function getBuyers() external view returns (address[] memory);

    function routerSetPause(bool _isPaused) external;

    function routerAddBuyer(address _address) external;

    function routerEditBuyer(address _address, uint _index) external;

    function routerBurn(address _address, uint256 _value) external;
}