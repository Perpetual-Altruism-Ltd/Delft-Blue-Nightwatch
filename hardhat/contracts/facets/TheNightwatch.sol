// SPDX-License-Identifier: UNLICENSED
// © Copyright 2022. All rights reserved. Perpetual Altruism Ltd.
pragma solidity ^0.8.0;

import "../interfaces/IERC721.sol";
import "../interfaces/IERC721TokenReceiver.sol";
import "../interfaces/IERC165.sol";
import "../interfaces/IERC2981.sol";
import "../interfaces/Ownable.sol";
import "../libraries/AppStorageNightwatch.sol";
import "../libraries/LibDiamond.sol";

/// @title TheNightwatch NFT smart contract
/// @dev Implementation of the Nightwatch NFT smart contract. To be minted and distributed trough the owner airdropping every token independantly.
/// @author Guillaume Gonnaud for Delft Blue
contract TheNightwatch is IERC165, IERC721,  IERC721Metadata, IERC2981, ModifierNightwatch {

    /// @notice Constructor
    /// @dev Bear in mind that this constructor has no effect on the actual contract deployed as you are deploying a diamond
    constructor()
    {

    }   

    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                                  ERC-721 Implementation                          //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external override view returns (uint256){
        require(_owner != address(0x0));
        return s.internalBalanceOf[_owner];
    }

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external override view returns (address){
        require(s.ownerOfVar[_tokenId] != address(0x0), "ownerOf: ERC721 NFTs assigned to the zero address are considered invalid");
        return s.ownerOfVar[_tokenId];
    }

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external override payable{
        safeTransferFromInternal(_from, _to, _tokenId, data);
    }


    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external override payable{
        safeTransferFromInternal(_from, _to, _tokenId, "");
    }

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external override payable{
        transferFromInternal(_from, _to, _tokenId);
    }

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external override payable{
        require(msg.sender == s.ownerOfVar[_tokenId] || 
            s.approvedOperator[s.ownerOfVar[_tokenId]][msg.sender],
            "approve: msg.sender is not allowed to approve the token"
        );

        s.approvedTransferAddress[_tokenId] = _approved;
        emit Approval(s.ownerOfVar[_tokenId], _approved, _tokenId);
    }


    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external override {
        s.approvedOperator[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    
    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external override view returns (address){
        return s.approvedTransferAddress[_tokenId];
    }


    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external override view returns (bool){
        return  s.approvedOperator[_owner][_operator];
    }


    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                          ERC-721 Metadata Implementation                         //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////

    /// @notice A descriptive name for a collection of NFTs in this contract
    function name() external override view returns (string memory _name){
        return s.name;
    }

    /// @notice An abbreviated name for NFTs in this contract
    function symbol() external override view returns (string memory _symbol){
        return s.symbol;
    }

    /// @notice A distinct Uniform Resource Identifier (URI) for a given asset.
    /// @dev Throws if `_tokenId` is not a valid NFT. URIs are defined in RFC
    ///  3986. The URI may point to a JSON file that conforms to the "ERC721
    ///  Metadata JSON Schema".
    function tokenURI(uint256 _tokenId) external override view returns (string memory){

        if(keccak256(abi.encodePacked(s.tokenURI_suffix[_tokenId])) == keccak256(abi.encodePacked(""))){ //If no suffix have been recorded for the token
            return string(abi.encodePacked(s.tokenURI_prefix, uintToString(_tokenId)));
        } else {
            return string(abi.encodePacked(s.tokenURI_prefix, s.tokenURI_suffix[_tokenId]));
        }
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                                ERC-2981 Implementation                           //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////

    /// @notice Called with the sale price to determine how much royalty
    //          is owed and to whom.
    /// param _tokenId - the NFT asset queried for royalty information
    /// @param _salePrice - the sale price of the NFT asset specified by _tokenId
    /// @return receiver - address of who should be sent the royalty payment
    /// @return royaltyAmount - the royalty payment amount for _salePrice
    function royaltyInfo(uint256 /*_tokenId */, uint256 _salePrice) external override view returns (address receiver, uint256 royaltyAmount ){
        return (s.royaltyBeneficiary, (_salePrice * s.royaltyPercentktage) / 100000);
    }

    
    function supportsInterface(bytes4 interfaceID) external override view returns (bool){
        return s.supportedInterfaces[interfaceID];
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                              Administration Implementation                       //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////

    function mintFor(uint256 _tokenID, address _receiver) external onlyOwner() {
        require(s.ownerOfVar[_tokenID] == address(0x0), "Token already exist");

        s.totalSupply++;
        s.internalBalanceOf[_receiver] = s.internalBalanceOf[_receiver] + 1;

        //Changing ownership
        s.ownerOfVar[_tokenID] = _receiver;

        //Emitting transfer event
        emit Transfer(address(0x0), _receiver, _tokenID);
    }

    //Every call to TokenURI will return "" + _prefix + tokenID.
    //If suffix is set for the tokenID, then the result is  "" + _prefix + suffix
    function setTokenURIPrefix(string calldata _prefix) external onlyOwner() {
        s.tokenURI_prefix = _prefix;
    }

    //Every call to TokenURI will return "" + _prefix + tokenID.
    //If suffix is set for the tokenID, then the result is  "" + _prefix + suffix
    // Set suffix to "" if you want to return _prefix + tokenID
    function setTokenURISufix(uint _tokenID, string calldata _suffix) external onlyOwner() {
        s.tokenURI_suffix[_tokenID] = _suffix;
    }

    //Set the royalty rate per 100k unit of currency
    function setRoyaltyRate(uint _ratePer100k) external onlyOwner() {
        s.royaltyPercentktage = _ratePer100k;
    }

    //Set the royalty benficiary
    function setRoyaltyBeneficiary(address _beneficiary) external onlyOwner() {
        s.royaltyBeneficiary = _beneficiary;
    }

    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                              ERC-721 Internal Functions                          //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////
    
    /// @dev Called by both variants of Safetransfer. Is a transfer followed by a smartContract check and then
    /// an onERC721Received call
    function safeTransferFromInternal(address _from, address _to, uint256 _tokenId, bytes memory data) internal {
        transferFromInternal(_from, _to, _tokenId);
        
        if(isContract(_to)){
            //bytes4(keccak256("onERC721Received(address,address,uint256,bytes)")) == 0x150b7a02
            require(IERC721TokenReceiver(_to).onERC721Received(msg.sender, _from, _tokenId, data) == bytes4(0x150b7a02));
        }
    }


    /// @dev Actual token transfer code called by all the other functions
    function transferFromInternal(address _from, address _to, uint256 _tokenId) internal {
        require(_to != address(0x0), "transferFromInternal: Tokens cannot be send to 0x0. Use 0xdead instead ?");
        require(s.ownerOfVar[_tokenId] == _from, "transferFromInternal: _from is not the owner of the token");
        require(msg.sender == s.ownerOfVar[_tokenId] || 
            s.approvedOperator[s.ownerOfVar[_tokenId]][msg.sender] ||
            msg.sender == s.approvedTransferAddress[_tokenId],
            "transferFromInternal: msg.sender is not allowed to manipulate the token"
        );

        // Adjusting token balances
        if(_from != address(0x0)){
            s.internalBalanceOf[_from] = s.internalBalanceOf[_from] - 1;
        }
        s.internalBalanceOf[_to] = s.internalBalanceOf[_to] + 1;

        //Resetting approved addresse permission
        s.approvedTransferAddress[_tokenId] = address(0x0);

        //Changing ownership
        s.ownerOfVar[_tokenId] = _to;

        //Emitting transfer event
        emit Transfer(_from, _to, _tokenId);
        
    }

    /// @notice Check if an address is a contract
    /// @param _address The address you want to test
    /// @return true if the address has bytecode, false if not
    function isContract(address _address) internal view returns(bool){
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly { codehash := extcodehash(_address) }
        return (codehash != accountHash && codehash != 0x0);
    }


    //////////////////////////////////////////////////////////////////////////////////////
    //                                                                                  //
    //                       ERC-721 Metadata Internal Functions                        //
    //                                                                                  //
    //////////////////////////////////////////////////////////////////////////////////////

    /// @notice Return a string from an uint256
    /// @param _i The adress you want to test
    /// @return the uint as a decimal string
    function uintToString(uint256 _i) internal pure returns (string memory) {
        if (_i == 0) {
            return "0";
        }
        uint256 temp = _i;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_i != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(_i % 10)));
            _i /= 10;
        }
        return string(buffer);
    }

}

