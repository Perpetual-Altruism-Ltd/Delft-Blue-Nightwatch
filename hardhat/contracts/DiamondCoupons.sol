// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/******************************************************************************\
* Author: Nick Mudge <nick@perfectabstractions.com> (https://twitter.com/mudgen)
* EIP-2535 Diamonds: https://eips.ethereum.org/EIPS/eip-2535
*
* Implementation of a diamond.
/******************************************************************************/

import { LibDiamond } from "./libraries/LibDiamond.sol";
import { IDiamondCut } from "./interfaces/IDiamondCut.sol";

import "./upgradeInitializers/DiamondInitCoupons.sol";
import "./facets/CouponTokens.sol";

contract DiamondCoupons {    

/* Default simplest constructor
    constructor(address _contractOwner, address _diamondCutFacet) payable {        
        LibDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");        
    }
*/
       constructor(address _contractOwner, address _diamondCutFacet, address _diamondInitCoupons, address _CouponToken) payable {        
        LibDiamond.setContractOwner(_contractOwner);

        // Add the diamondCut external function from the diamondCutFacet
        IDiamondCut.FacetCut[] memory cut = new IDiamondCut.FacetCut[](1);
        bytes4[] memory functionSelectors = new bytes4[](1);
        functionSelectors[0] = IDiamondCut.diamondCut.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondCutFacet, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");    

   
        //Adding the initialisation layer of the diamond and executing it. Could by by passed by using calldata in previous line.
        cut = new IDiamondCut.FacetCut[](1);
        functionSelectors = new bytes4[](1);
        functionSelectors[0] = DiamondInitCoupons.init.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondInitCoupons, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        bytes memory payload = abi.encodeWithSignature("init()", "");
        LibDiamond.diamondCut(cut, _diamondInitCoupons, payload);  
 

        //Adding the Nightawtch functions
        cut = new IDiamondCut.FacetCut[](1);
        functionSelectors = new bytes4[](20); //Make sure the number of function match
        functionSelectors[0] = CouponToken.balanceOf.selector;
        functionSelectors[1] = CouponToken.ownerOf.selector;
        functionSelectors[2] = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
        functionSelectors[3] = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
        functionSelectors[4] = CouponToken.transferFrom.selector;
        functionSelectors[5] = CouponToken.approve.selector;
        functionSelectors[6] = CouponToken.setApprovalForAll.selector;
        functionSelectors[7] = CouponToken.getApproved.selector;
        functionSelectors[8] = CouponToken.isApprovedForAll.selector;
        functionSelectors[9] = CouponToken.name.selector;
        functionSelectors[10] = CouponToken.symbol.selector;
        functionSelectors[11] = CouponToken.tokenURI.selector;
        functionSelectors[12] = CouponToken.registerARaffleOutcome.selector;
        functionSelectors[13] = CouponToken.mintFor.selector;
        functionSelectors[14] = CouponToken.setTokenURIPrefix.selector;
        functionSelectors[15] = CouponToken.drawRaffle.selector;
        functionSelectors[16] = CouponToken.readRaffleOutcome.selector;
        functionSelectors[17] = CouponToken.setTokenURISufix.selector;
        functionSelectors[18] = CouponToken.readAnOutcome.selector;
        functionSelectors[19] = CouponToken.supportsInterface.selector;

    
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _CouponToken, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        LibDiamond.diamondCut(cut, address(0), "");   



    }


    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external payable {
        LibDiamond.DiamondStorage storage ds;
        bytes32 position = LibDiamond.DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
        address facet = address(bytes20(ds.facets[msg.sig]));
        require(facet != address(0), "Diamond: Function does not exist");
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), facet, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
                case 0 {
                    revert(0, returndatasize())
                }
                default {
                    return(0, returndatasize())
                }
        }
    }

    receive() external payable {}
}
