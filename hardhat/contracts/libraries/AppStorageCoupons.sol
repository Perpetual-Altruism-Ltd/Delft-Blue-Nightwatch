// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {LibDiamond} from "./LibDiamond.sol";


struct Link{
    uint256 head;
    uint256 tail;
    uint256 tokenID;
}

//Struct used by the Nightwatch NFT smart contract
struct AppStorageCoupons {

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


    //Coupon redemption mechanism


    //General principle : 
    // Ideas exploration : Purely salt offset
    // First we general "honnest salt". The blockhash of the end of the trading period is good enough for that.
    // The first couponID to be attributed is couponID 1. The token ID it will get is then equal to ( uint256(salt) % unclaimedSupply)
    // Then, if the second bit of the salt is a 0, the second couponID will then need to get a token ID equal to  ((uint256(salt) + couponID) % unclaimedSupply)
    // If the second bit is a 1, the second coupon ID  will then need to get a token ID equal to ((uint256(salt) - couponID) % unclaimedSupply)
    // need to keep tracks of 0/1 counts
    // Issue : Neighboring tokens have high probability of being neigbors. Someone acquiring say, the first 20 token in the auction will get 20 tokens in a line.

    // Idea exploration :
    // PseudoRNG sorting
    // Acquire RNG from several blockcash in a row, attribute part of the bytes to each CouponID. Sort them by uint16 of the byte rng value.
    // Issue : sorting extremely expensive as an algo onchain. Think several full blocks worth of gas.

    // Idea exploration : 
    // Pre-recorded orders offchain, randomly drafted by the blockhash.
    // Create a dozen different possible tokenID association. Store those on IPFS, register those dozen of link in an array. Then the uint256(blockhash) % array.length will give you wich tokenID association to use.




}


contract ModifierCoupons {
    AppStorageCoupons internal s;

    modifier onlyOwner() {
        LibDiamond.enforceIsContractOwner();
        _;
    }
}
