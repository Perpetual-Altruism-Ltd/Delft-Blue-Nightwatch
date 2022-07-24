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

import "./upgradeInitializers/DiamondInitNightwatch.sol";
import "./facets/TheNightwatch.sol";

contract DiamondNightwatch {    

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
       constructor(address _contractOwner, address _diamondCutFacet, address _diamondInitNightwatch, address _TheNightwatch) payable {        
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
        functionSelectors[0] = DiamondInitNightwatch.init.selector;
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _diamondInitNightwatch, 
            action: IDiamondCut.FacetCutAction.Add, 
            functionSelectors: functionSelectors
        });
        bytes memory payload = abi.encodeWithSignature("init()", "");
        LibDiamond.diamondCut(cut, _diamondInitNightwatch, payload);  
 

        //Adding the Nightawtch functions
        cut = new IDiamondCut.FacetCut[](1);
        functionSelectors = new bytes4[](19); //Make sure the number of function match
        functionSelectors[0] = TheNightwatch.balanceOf.selector;
        functionSelectors[1] = TheNightwatch.ownerOf.selector;
        functionSelectors[2] = bytes4(keccak256("safeTransferFrom(address,address,uint256,bytes)"));
        functionSelectors[3] = bytes4(keccak256("safeTransferFrom(address,address,uint256)"));
        functionSelectors[4] = TheNightwatch.transferFrom.selector;
        functionSelectors[5] = TheNightwatch.approve.selector;
        functionSelectors[6] = TheNightwatch.setApprovalForAll.selector;
        functionSelectors[7] = TheNightwatch.getApproved.selector;
        functionSelectors[8] = TheNightwatch.isApprovedForAll.selector;
        functionSelectors[9] = TheNightwatch.name.selector;
        functionSelectors[10] = TheNightwatch.symbol.selector;
        functionSelectors[11] = TheNightwatch.tokenURI.selector;
        functionSelectors[12] = TheNightwatch.royaltyInfo.selector;
        functionSelectors[13] = TheNightwatch.mintFor.selector;
        functionSelectors[14] = TheNightwatch.setTokenURIPrefix.selector;
        functionSelectors[15] = TheNightwatch.setTokenURISufix.selector;
        functionSelectors[16] = TheNightwatch.setRoyaltyRate.selector;
        functionSelectors[17] = TheNightwatch.setRoyaltyBeneficiary.selector;
        functionSelectors[18] = TheNightwatch.supportsInterface.selector;
        
        cut[0] = IDiamondCut.FacetCut({
            facetAddress: _TheNightwatch, 
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
