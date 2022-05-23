// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

interface IMintable {
    function mint(address receiver) external returns(uint256);
    function batchMint(address receiver, uint256 amount) external;
}