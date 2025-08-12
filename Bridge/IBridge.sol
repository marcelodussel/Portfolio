// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

interface IBridge {

    function bridgeMint(address _to, uint256 tokenId) external;

}