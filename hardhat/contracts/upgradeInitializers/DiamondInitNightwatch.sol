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
import { AppStorageNightwatch } from "../libraries/AppStorageNightwatch.sol";

contract DiamondInitNightwatch {
    AppStorageNightwatch internal s;

    function init() public {


        require(s.supportedInterfaces[0x80ac58cd] == false, "Double Entry");

        s.supportedInterfaces[type(IERC165).interfaceId] = true;
        s.supportedInterfaces[type(IDiamondCut).interfaceId] = true;
        s.supportedInterfaces[type(IDiamondLoupe).interfaceId] = true;
        s.supportedInterfaces[type(IERC173).interfaceId] = true;

        s.supportedInterfaces[0x80ac58cd] = true; //ERC721 support (NFT)
        s.supportedInterfaces[0x5b5e139f] = true; //ERC721Metadata  support (NFT images/json)
        s.supportedInterfaces[0x2a55205a] = true; //ERC2981 support (royalties)

        s.name = "The Nightwatch";
        s.symbol = "NWTCH";

    }

    function supportsInterface(bytes4 interfaceID) external view returns (bool){
        return  s.supportedInterfaces[interfaceID];
    }
}
