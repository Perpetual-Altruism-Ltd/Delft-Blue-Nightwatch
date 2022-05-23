// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibDiamond} from "./LibDiamond.sol";


//Struct used by the Nightwatch NFT smart contract
struct AppStorageNightwatch {

    string name; // Returns the name of the token - e.g. "The Nightwatch NFT collection".
    string symbol; // Returns the symbol of the token. E.g. NGWTCH.

    mapping(address => uint256) internalBalanceOf; //The number of token an address own
    uint256 totalSupply; //The total amount of minted tokens

    mapping(uint256 => address) ownerOfVar; //Mapping storing NFT ownership
    mapping(uint256 => address) approvedTransferAddress; //Address allowed to Transfer a token
    mapping(address => mapping(address => bool)) approvedOperator; //Approved operators mapping: owner => operator => allowed?

    mapping(bytes4 => bool) supportedInterfaces; //ERC 165

    string tokenURI_prefix; //The prefix to use with every NFT Token URI
    mapping(uint256 => string) tokenURI_suffix; //The suffix for each tokenURI. If empty, will return the tokenID.

    address royaltyBeneficiary; //Who does the royalties goes trough;
    uint256 royaltyPercentktage; //the amount in percent of royalty due per 100k amount of currency.

}


contract ModifierNightwatch {
    AppStorageNightwatch internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
}
