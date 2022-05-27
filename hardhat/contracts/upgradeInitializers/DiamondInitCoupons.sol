// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import {LibDiamond} from "../libraries/LibDiamond.sol";
import { IDiamondLoupe } from "../interfaces/IDiamondLoupe.sol";
import { IDiamondCut } from "../interfaces/IDiamondCut.sol";
import { IERC173 } from "../interfaces/IERC173.sol";
import { IERC165 } from "../interfaces/IERC165.sol";
import { AppStorageCoupons } from "../libraries/AppStorageCoupons.sol";

contract DiamondInitCoupons {
    AppStorageCoupons internal s;

    function init() public {

        // adding ERC165 data
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();

        require(ds.supportedInterfaces[0x80ac58cd] == false, "Double Entry");

        ds.supportedInterfaces[type(IERC165).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        ds.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        ds.supportedInterfaces[type(IERC173).interfaceId] = true;

        ds.supportedInterfaces[0x80ac58cd] = true; //ERC721 support (NFT)
        ds.supportedInterfaces[0x5b5e139f] = true; //ERC721Metadata  support (NFT images/json)


        s.name = "The Nightwatch Coupons";
        s.symbol = "XNWTCH";

    }
}
